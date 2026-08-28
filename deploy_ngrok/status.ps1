# 顯示目前的 ngrok 網址，並比對「設定值」與「實際活著的 tunnel」是否一致。
#
# 存在的理由：網址每次重啟都會換，而 LINE webhook 與 nexusbot 的
# NEXUSBOT_BASE_URL 是各自獨立寫入的 —— 三者只要有一個沒跟上，
# 症狀都是「LINE 沒反應」，但從任何單一畫面都看不出是哪一個。
# 這支把三邊放在一起比，不做任何寫入。
#
# 作者：MinHao
# 建立日期：2026-08-25
# 異動歷史：
#     2026-08-25 MinHao 初版

[CmdletBinding()]
param([string]$Namespace = 'acenexus')

$here = Split-Path -Parent $PSCommandPath

# Invoke-WebRequest / Invoke-RestMethod 在 PS 5.1 會畫進度列，而且每次呼叫都
# 重繪 console 頂端 —— 這支連續發六個請求（健康探測 + LINE API），
# 視覺上就是「一直閃」。進度資訊在這裡完全用不到，實測也快了四成。
$ProgressPreference = 'SilentlyContinue'
$getUrl = Join-Path $here 'get_tunnel_url.ps1'

function Invoke-Native {
    param([string]$File, [string[]]$Arguments)
    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $out = & $File @Arguments 2>$null
        return [pscustomobject]@{ Code = $LASTEXITCODE; Output = (@($out) -join "`n").Trim() }
    } finally {
        $ErrorActionPreference = $previous
    }
}

function Read-DotEnv {
    param([string]$Path)
    $map = @{}
    if (-not (Test-Path $Path)) { return $map }
    foreach ($line in Get-Content -Path $Path -Encoding utf8) {
        $text = $line.Trim()
        if ($text -eq '' -or $text.StartsWith('#')) { continue }
        $split = $text.IndexOf('=')
        if ($split -lt 1) { continue }
        $map[$text.Substring(0, $split).Trim()] = $text.Substring($split + 1).Trim()
    }
    return $map
}

function Test-Http {
    param([string]$Uri)
    try {
        # ngrok 免費方案對瀏覽器 UA 會插一頁警告，這個 header 是官方的跳過方式。
        $response = Invoke-WebRequest -Uri $Uri -UseBasicParsing -TimeoutSec 15 -Headers @{ 'ngrok-skip-browser-warning' = '1' }
        return [string]$response.StatusCode
    } catch {
        if ($_.Exception.Response) { return [string][int]$_.Exception.Response.StatusCode }
        return '連不上'
    }
}

function Get-TunnelUrl {
    param([int]$Port)
    $value = & $getUrl -Port $Port
    if ($null -eq $value) { return '' }
    return ([string]$value).Trim()
}

$lines = @('', '======== ngrok status ========')

# ---- 容器 ----
Push-Location $here
try {
    $ps = Invoke-Native -File 'docker' -Arguments @('compose', 'ps', '--format', '{{.Name}} {{.Status}}')
    if ($ps.Output -eq '') {
        $lines += 'container : 未執行 -> 跑 ngrok-tunnel.bat 啟動'
    } else {
        $lines += "container : $($ps.Output)"
    }
} finally {
    Pop-Location
}

$gatewayUrl = Get-TunnelUrl -Port 8080
$subgoUrl = Get-TunnelUrl -Port 9000

if ($gatewayUrl -eq '' -and $subgoUrl -eq '') {
    $lines += 'tunnel    : 一個都沒有（ngrok 沒起來，或 4040 API 不通）'
    $lines += ''
    $lines += 'fix       : 跑 ngrok-tunnel.bat'
    $lines += ''
    Write-Host ($lines -join [Environment]::NewLine)
    exit 1
}

# ---- 兩個 tunnel ----
# 對齊用的標籤一律 ASCII：中文是雙寬字元，混在對齊欄裡會讓 console 的
# cell 推進算錯，症狀是前一個字被重畫（容容器器）。中文只放在冒號右邊。
$lines += ''
foreach ($item in @(
        [pscustomobject]@{ Label = 'SubGo     '; Url = $subgoUrl; Local = 'http://localhost:9000/'; Probe = '/' },
        [pscustomobject]@{ Label = 'gateway   '; Url = $gatewayUrl; Local = 'http://localhost:8080/actuator/health'; Probe = '/actuator/health' })) {

    if ($item.Url -eq '') {
        $lines += "$($item.Label): tunnel 不存在"
        continue
    }
    $localCode = Test-Http -Uri $item.Local
    $publicCode = Test-Http -Uri "$($item.Url)$($item.Probe)"
    $lines += "$($item.Label): $($item.Url)"
    $lines += "          : 本機 $localCode / 對外 $publicCode"
}

# ---- SubGo 資料庫 ----
# SubGo 是另一個 compose 專案，這裡只讀狀態、不動它。查 docker 而不是讀它的
# docker-compose.yml —— 這支腳本的用途是「實際跑起來的長什麼樣」，設定檔改了
# 但沒重建容器時，兩者會不一樣，而後者才是連得上的那個。
#
# ⚠️ **這裡會把資料庫密碼印在畫面上**（明確要求）。因此這份輸出等同憑證：
# 不要截圖貼進聊天室、issue 或簡報。subgo 的 users 表裡有真實使用者的
# email 與密碼雜湊，拿到這行的人就連得進去。
# 只在本機終端機看的前提下才成立。
$lines += ''
$subgoEnv = Read-DotEnv -Path 'D:\SubGo\.env'
$pgPorts = Invoke-Native -File 'docker' -Arguments @(
    'inspect', 'subgo-postgres-1',
    '--format', '{{range $p, $c := .NetworkSettings.Ports}}{{range $c}}{{.HostIp}}:{{.HostPort}} {{end}}{{end}}')

if ($pgPorts.Code -ne 0) {
    $lines += 'subgo-db  : 容器不在（SubGo 的 compose 沒起來）'
} else {
    $health = (Invoke-Native -File 'docker' -Arguments @(
            'inspect', 'subgo-postgres-1', '--format', '{{.State.Health.Status}}')).Output
    $bind = ($pgPorts.Output -split '\s+' | Where-Object { $_ -ne '' } | Select-Object -First 1)

    if ([string]::IsNullOrWhiteSpace($bind)) {
        # 沒有 port 映射：容器活著，但只有 compose 網路內連得到。
        $lines += "subgo-db  : 未對外映射（$health）-> 用 docker compose exec postgres psql -U subgo -d subgo"
    } else {
        $hostPart, $portPart = $bind -split ':', 2

        # TcpClient 而非 Test-NetConnection：後者在 PS 5.1 會做一輪 ping 與
        # 路由查詢，本機探測要等一秒以上，而這支總共只該跑幾秒。
        $reachable = '不通'
        try {
            $client = New-Object System.Net.Sockets.TcpClient
            if ($client.ConnectAsync($hostPart, [int]$portPart).Wait(1500)) { $reachable = '通' }
            $client.Close()
        } catch { $reachable = '不通' }

        # .env 讀不到時不要顯示空白 —— 那看起來像「密碼是空的」。
        $user = if ($subgoEnv['POSTGRES_USER']) { $subgoEnv['POSTGRES_USER'] } else { 'subgo' }
        $db = if ($subgoEnv['POSTGRES_DB']) { $subgoEnv['POSTGRES_DB'] } else { 'subgo' }
        $pw = if ($subgoEnv['POSTGRES_PASSWORD']) { $subgoEnv['POSTGRES_PASSWORD'] } else { '(讀不到 D:\SubGo\.env)' }

        $lines += "subgo-db  : $bind  db=$db  user=$user"
        $lines += "          : pw=$pw"
        $lines += "          : 容器 $health / 連線 $reachable"
    }
}

# Adminer 是選用的網頁介面，沒開就不是問題 —— 因此只在跑著的時候才列一行。
$adminer = Invoke-Native -File 'docker' -Arguments @(
    'inspect', 'subgo-adminer-1', '--format', '{{.State.Status}}')
if ($adminer.Code -eq 0 -and $adminer.Output -eq 'running') {
    $lines += '          : Adminer http://localhost:9003  (Server 欄填 postgres)'
}

# ---- nexusbot ----
$lines += ''
# jsonpath 的過濾條件必須用單引號 —— 在 Windows 上寫成 @.name=="..." 時
# kubectl 會回 exit 1 且沒有輸出，看起來像「這個 env 不存在」。
$jsonPath = "{.spec.template.spec.containers[0].env[?(@.name=='NEXUSBOT_BASE_URL')].value}"
$nexusbot = Invoke-Native -File 'kubectl' -Arguments @('get', 'deployment', 'nexusbot', '-n', $Namespace, '-o', "jsonpath=$jsonPath")
if ($nexusbot.Code -ne 0) {
    $lines += 'nexusbot  : 讀不到（Kubernetes 未就緒？）'
} elseif ($nexusbot.Output -eq $gatewayUrl) {
    $lines += 'nexusbot  : 一致'
} else {
    $lines += "nexusbot  : 不一致，目前是 $($nexusbot.Output)"
}

# ---- LINE webhook ----
$envMap = Read-DotEnv -Path (Join-Path $here '.env')
$bots = @(
    [pscustomobject]@{ Label = 'bot1      '; Token = $envMap['LINE_CHANNEL_ACCESS_TOKEN']; Path = $envMap['LINE_WEBHOOK_PATH']; Default = '/api/linebot/webhook' },
    [pscustomobject]@{ Label = 'bot2-test '; Token = $envMap['LINE_CHANNEL_ACCESS_TOKEN_TEST']; Path = $envMap['LINE_WEBHOOK_PATH_TEST']; Default = '/api/linebot-test/webhook' }
)

$stale = $false
foreach ($bot in $bots) {
    if ([string]::IsNullOrWhiteSpace($bot.Path)) { $bot.Path = $bot.Default }
    if ([string]::IsNullOrWhiteSpace($bot.Token) -or $bot.Token -like 'your_*') {
        $lines += "$($bot.Label): 未設定 token"
        continue
    }
    try {
        $response = Invoke-RestMethod -Uri 'https://api.line.me/v2/bot/channel/webhook/endpoint' -Headers @{ Authorization = "Bearer $($bot.Token)" } -Method Get -TimeoutSec 20
        $wanted = "$gatewayUrl$($bot.Path)"
        if ([string]$response.endpoint -eq $wanted) {
            $lines += "$($bot.Label): 一致"
        } else {
            $lines += "$($bot.Label): 不一致，目前是 $($response.endpoint)"
            $stale = $true
        }
    } catch {
        $lines += "$($bot.Label): 查不到（$($_.Exception.Message)）"
    }
}

$lines += ''
if ($stale -or ($nexusbot.Code -eq 0 -and $nexusbot.Output -ne $gatewayUrl)) {
    $lines += '有項目不一致 -> 跑 ngrok-tunnel.bat 同步（容器還在跑就沿用，不會換網址）'
} else {
    $lines += '全部一致。流量監控 http://localhost:4040'
}
$lines += ''

# 一次寫出。逐行 Write-Host 在 UTF-8 console 下比較容易觸發重畫。
Write-Host ($lines -join [Environment]::NewLine)
