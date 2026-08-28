# 啟動 / 沿用 ngrok tunnel，並把 gateway 網址同步到 nexusbot 與 LINE webhook。
#
# 這支取代了原本寫在 ngrok-tunnel.bat 裡的流程，原因是開機時它會靜默失敗：
# Startup 捷徑在登入當下就執行，而 Docker Desktop 自己也還在啟動，
# docker compose 與 kubectl 一失敗就走進錯誤分支 —— 同步沒有發生，
# 而 LINE webhook 停在好幾輪前的網址，沒有任何地方會告訴你。
# 實際踩到的狀態：webhook 指向 c236，活著的 tunnel 是 b600。
#
# 兩個刻意的設計：
#
#   1. 容器已在跑且兩個 tunnel 都在時「沿用」，不 down/up。compose 設了
#      restart: always，Docker Desktop 一起來就會把容器帶起（並拿到新網址）；
#      再 down/up 等於同一次開機換兩次網址，而且緊接著重連很容易撞上
#      ERR_NGROK_108（ngrok 端認為舊 session 還在）。
#   2. 只在「目前值與新網址不同」時才寫入。kubectl set env 會觸發 nexusbot
#      滾動重啟，LINE 那側則是對外部 API 的寫入 —— 兩者都不該每次開機都做一次。
#
# 作者：MinHao
# 建立日期：2026-08-25
# 異動歷史：
#     2026-08-25 MinHao 初版，自 ngrok-tunnel.bat 抽出並補上開機就緒等待

[CmdletBinding()]
param(
    # 開機模式：先等 Docker Desktop 與 K8s 就緒。手動執行時不需要（都已經在跑了）。
    [switch]$Boot,
    [int]$DockerTimeoutSec = 240,
    [int]$K8sTimeoutSec = 180,
    [int]$TunnelTimeoutSec = 60,
    [string]$Namespace = 'acenexus'
)

$ErrorActionPreference = 'Stop'

# Invoke-WebRequest / Invoke-RestMethod 在 PS 5.1 會畫進度列，而且每次呼叫都
# 重繪 console 頂端 —— 這支連續發六個請求（健康探測 + LINE API），
# 視覺上就是「一直閃」。進度資訊在這裡完全用不到，實測也快了四成。
$ProgressPreference = 'SilentlyContinue'

$here = Split-Path -Parent $PSCommandPath
$notify = Join-Path $here 'notify.ps1'
$getUrl = Join-Path $here 'get_tunnel_url.ps1'
$updateWebhook = Join-Path $here 'update_webhook.ps1'

function Write-Step { param([string]$m) Write-Host "[資訊] $m" }
function Write-Done { param([string]$m) Write-Host "[成功] $m" }
function Write-Warn { param([string]$m) Write-Host "[警告] $m" }
function Write-Fail { param([string]$m) Write-Host "[錯誤] $m" }

# 呼叫外部執行檔。ErrorActionPreference = Stop 之下，原生指令往 stderr 寫東西
# 會被包成 ErrorRecord 而中斷腳本（即使 exit code 是 0），因此這裡暫時放寬。
function Invoke-Native {
    param([string]$File, [string[]]$Arguments)
    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $out = & $File @Arguments 2>$null
        return [pscustomobject]@{
            Code   = $LASTEXITCODE
            Output = (@($out) -join "`n").Trim()
        }
    } finally {
        $ErrorActionPreference = $previous
    }
}

function Wait-Ready {
    param([string]$Label, [scriptblock]$Probe, [int]$TimeoutSec)
    $watch = [System.Diagnostics.Stopwatch]::StartNew()
    $announced = $false
    while ($true) {
        $ok = $false
        try { $ok = [bool](& $Probe) } catch { $ok = $false }
        if ($ok) {
            if ($announced) { Write-Done "$Label 已就緒（等了 $([int]$watch.Elapsed.TotalSeconds) 秒）" }
            return $true
        }
        if ($watch.Elapsed.TotalSeconds -ge $TimeoutSec) {
            Write-Fail "等待 $Label 逾時（$TimeoutSec 秒）"
            return $false
        }
        if (-not $announced) { Write-Step "等待 $Label 就緒..."; $announced = $true }
        Start-Sleep -Seconds 5
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

function Get-TunnelUrl {
    param([int]$Port)
    $value = & $getUrl -Port $Port
    if ($null -eq $value) { return '' }
    return ([string]$value).Trim()
}

function Stop-WithNotice {
    param([string]$Reason, [string[]]$Detail = @())
    Write-Fail $Reason
    & $notify -Title 'ngrok 同步失敗' -Lines (@($Reason) + $Detail) | Out-Host
    exit 1
}

# ============================================================
# 1. 等待前置條件（僅開機模式）
# ============================================================
if ($Boot) {
    $dockerOk = Wait-Ready -Label 'Docker Desktop' -TimeoutSec $DockerTimeoutSec -Probe {
        (Invoke-Native -File 'docker' -Arguments @('info')).Code -eq 0
    }
    if (-not $dockerOk) { Stop-WithNotice -Reason 'Docker Desktop 未就緒，tunnel 沒有啟動' }

    $k8sOk = Wait-Ready -Label 'Kubernetes' -TimeoutSec $K8sTimeoutSec -Probe {
        (Invoke-Native -File 'kubectl' -Arguments @('get', 'ns', $Namespace)).Code -eq 0
    }
    if (-not $k8sOk) {
        # K8s 沒起來仍可繼續：tunnel 本身與 LINE webhook 不依賴它，
        # 只有 nexusbot 的 NEXUSBOT_BASE_URL 會同步不到。
        Write-Warn '略過 nexusbot 的 NEXUSBOT_BASE_URL 同步（Kubernetes 未就緒）'
    }
} else {
    $k8sOk = (Invoke-Native -File 'kubectl' -Arguments @('get', 'ns', $Namespace)).Code -eq 0
}

# ============================================================
# 2. 確保 ngrok 容器在跑，並取得兩個 tunnel 的網址
# ============================================================
Push-Location $here
try {
    $existing = Invoke-Native -File 'docker' -Arguments @('compose', 'ps', '-q', 'ngrok')
    if ($existing.Code -ne 0) { Stop-WithNotice -Reason "docker compose 無法執行:$($existing.Output)" }

    if ($existing.Output -eq '') {
        Write-Step 'ngrok 容器未執行，啟動中...'
        $up = Invoke-Native -File 'docker' -Arguments @('compose', 'up', '-d')
        if ($up.Code -ne 0) { Stop-WithNotice -Reason "ngrok 容器啟動失敗:$($up.Output)" }
    } else {
        Write-Step 'ngrok 容器已在執行，沿用現有 tunnel（不重建，避免再換一次網址）'
    }

    # 探測兩個 tunnel。沿用既有容器時若少了 tunnel（例如 ngrok.yml 改過但
    # 容器還是舊的），才重建一次 —— 這是唯一會主動換掉網址的路徑。
    $gatewayUrl = ''
    $subgoUrl = ''
    $recreated = $false
    $watch = [System.Diagnostics.Stopwatch]::StartNew()

    while ($true) {
        $gatewayUrl = Get-TunnelUrl -Port 8080
        $subgoUrl = Get-TunnelUrl -Port 9000
        if ($gatewayUrl -ne '' -and $subgoUrl -ne '') { break }

        $logs = Invoke-Native -File 'docker' -Arguments @('compose', 'logs', 'ngrok', '--tail', '30')
        if ($logs.Output -match 'ERR_NGROK_108') {
            Stop-WithNotice -Reason 'ngrok 連線數已滿（ERR_NGROK_108）' -Detail @(
                '等 5 分鐘讓舊 session 自動斷開，或到 https://dashboard.ngrok.com/agents 手動終止'
            )
        }

        if ($watch.Elapsed.TotalSeconds -ge $TunnelTimeoutSec) {
            if (-not $recreated) {
                Write-Warn 'tunnel 未全部出現，重建容器一次（網址會更換）'
                $recreated = $true
                $watch.Restart()
                $force = Invoke-Native -File 'docker' -Arguments @('compose', 'up', '-d', '--force-recreate')
                if ($force.Code -ne 0) { Stop-WithNotice -Reason "ngrok 容器重建失敗:$($force.Output)" }
                Start-Sleep -Seconds 5
                continue
            }
            $gwText = $gatewayUrl
            $sgText = $subgoUrl
            if ($gwText -eq '') { $gwText = '未取得' }
            if ($sgText -eq '') { $sgText = '未取得' }
            Stop-WithNotice -Reason 'ngrok tunnel 沒有全部起來' -Detail @("gateway=$gwText", "subgo=$sgText")
        }
        Start-Sleep -Seconds 3
    }

    Write-Done "gateway tunnel:$gatewayUrl"
    Write-Done "subgo   tunnel:$subgoUrl"
} finally {
    Pop-Location
}

# ============================================================
# 3. 同步 nexusbot 的 NEXUSBOT_BASE_URL（只在不同時才寫）
# ============================================================
$nexusbotSynced = $false
if ($k8sOk) {
    # jsonpath 的過濾條件必須用單引號 —— 在 Windows 上寫成 @.name=="..." 時
    # kubectl 會回 exit 1 且沒有輸出，看起來像「這個 env 不存在」。
    $jsonPath = "{.spec.template.spec.containers[0].env[?(@.name=='NEXUSBOT_BASE_URL')].value}"
    $current = Invoke-Native -File 'kubectl' -Arguments @(
        'get', 'deployment', 'nexusbot', '-n', $Namespace, '-o', "jsonpath=$jsonPath"
    )
    if ($current.Code -ne 0) {
        Write-Warn "讀不到 nexusbot 的 NEXUSBOT_BASE_URL:$($current.Output)"
    } elseif ($current.Output -eq $gatewayUrl) {
        Write-Step 'NEXUSBOT_BASE_URL 已是最新，略過（避免多餘的滾動重啟）'
        $nexusbotSynced = $true
    } else {
        Write-Step "更新 NEXUSBOT_BASE_URL:$($current.Output) -> $gatewayUrl"
        $set = Invoke-Native -File 'kubectl' -Arguments @(
            'set', 'env', 'deployment/nexusbot', "NEXUSBOT_BASE_URL=$gatewayUrl", '-n', $Namespace
        )
        if ($set.Code -ne 0) {
            Write-Warn "kubectl set env 失敗:$($set.Output)"
        } else {
            Write-Step 'nexusbot 滾動重啟中...'
            $rollout = Invoke-Native -File 'kubectl' -Arguments @(
                'rollout', 'status', 'deployment/nexusbot', '-n', $Namespace, '--timeout=180s'
            )
            if ($rollout.Code -ne 0) {
                Write-Warn "nexusbot rollout 未在時限內完成:$($rollout.Output)"
            } else {
                Write-Done 'nexusbot 已套用新的 NEXUSBOT_BASE_URL'
                $nexusbotSynced = $true
            }
        }
    }
}

# ============================================================
# 4. 同步 LINE webhook（只在不同時才寫）
# ============================================================
$envMap = Read-DotEnv -Path (Join-Path $here '.env')

$bots = @(
    [pscustomobject]@{
        Label   = 'bot1'
        Token   = $envMap['LINE_CHANNEL_ACCESS_TOKEN']
        Path    = $envMap['LINE_WEBHOOK_PATH']
        Default = '/api/linebot/webhook'
    },
    [pscustomobject]@{
        Label   = 'bot2-test'
        Token   = $envMap['LINE_CHANNEL_ACCESS_TOKEN_TEST']
        Path    = $envMap['LINE_WEBHOOK_PATH_TEST']
        Default = '/api/linebot-test/webhook'
    }
)

$webhookLines = @()
foreach ($bot in $bots) {
    if ([string]::IsNullOrWhiteSpace($bot.Path)) { $bot.Path = $bot.Default }
    if ([string]::IsNullOrWhiteSpace($bot.Token) -or $bot.Token -like 'your_*') {
        Write-Step "$($bot.Label):未設定 token，略過"
        continue
    }

    $wanted = "$gatewayUrl$($bot.Path)"
    $headers = @{ Authorization = "Bearer $($bot.Token)" }

    $currentEndpoint = ''
    try {
        $response = Invoke-RestMethod -Uri 'https://api.line.me/v2/bot/channel/webhook/endpoint' -Headers $headers -Method Get -TimeoutSec 20
        $currentEndpoint = [string]$response.endpoint
    } catch {
        Write-Warn "$($bot.Label):讀取 webhook 設定失敗（$($_.Exception.Message)），仍嘗試寫入"
    }

    if ($currentEndpoint -eq $wanted) {
        Write-Step "$($bot.Label):webhook 已是最新，略過"
    } else {
        Write-Step "$($bot.Label):更新 webhook -> $wanted"
        $env:TEMP_LINE_TOKEN = $bot.Token
        $env:TEMP_WEBHOOK_URL = $wanted
        try {
            & $updateWebhook | Out-Host
        } finally {
            Remove-Item Env:\TEMP_LINE_TOKEN -ErrorAction SilentlyContinue
            Remove-Item Env:\TEMP_WEBHOOK_URL -ErrorAction SilentlyContinue
        }
    }

    # LINE 自己發一個請求過來，這是唯一能證明整條路（LINE → tunnel → gateway
    # → nexusbot）真的通的方法；讀設定值只能證明我們寫進去了。
    try {
        $test = Invoke-RestMethod -Uri 'https://api.line.me/v2/bot/channel/webhook/test' -Headers $headers -Method Post -ContentType 'application/json' -Body '{}' -TimeoutSec 30
        if ($test.success) {
            Write-Done "$($bot.Label):連通測試 $($test.statusCode) OK"
            $webhookLines += "$($bot.Label) OK"
        } else {
            Write-Warn "$($bot.Label):連通測試失敗（$($test.statusCode) $($test.reason)）"
            $webhookLines += "$($bot.Label) $($test.statusCode)"
        }
    } catch {
        Write-Warn "$($bot.Label):連通測試無法執行（$($_.Exception.Message)）"
        $webhookLines += "$($bot.Label) 測試失敗"
    }
}

# ============================================================
# 5. 顯示結果
# ============================================================
try {
    Set-Clipboard -Value $gatewayUrl
    Write-Done 'gateway 網址已複製到剪貼簿'
} catch {
    Write-Warn "無法寫入剪貼簿:$($_.Exception.Message)"
}

$banner = @(
    '',
    '========================================',
    '  ngrok 已就緒',
    '========================================',
    "  SubGo   : $subgoUrl",
    "  gateway : $gatewayUrl"
)
if ($webhookLines.Count -gt 0) { $banner += "  LINE    : $($webhookLines -join ', ')" }
if ($k8sOk -and -not $nexusbotSynced) { $banner += '  [!] nexusbot 的 NEXUSBOT_BASE_URL 未同步成功' }
$banner += '========================================'
$banner += ''
$banner += '  流量監控 http://localhost:4040'
$banner += '  隨時查詢 ngrok-status.bat'
$banner += ''

# 一次寫出。對齊用的標籤一律 ASCII —— 中文是雙寬字元，混在對齊欄裡會讓
# console 的 cell 推進算錯，症狀是前一個字被重畫（容容器器）。
Write-Host ($banner -join [Environment]::NewLine)

$toastLines = @("SubGo: $subgoUrl", "gateway: $gatewayUrl")
if ($webhookLines.Count -gt 0) { $toastLines += "LINE: $($webhookLines -join ', ')" }
& $notify -Title 'ngrok 已就緒' -Lines $toastLines | Out-Host

exit 0
