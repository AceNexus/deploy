# 依 upstream port 取出對應的 ngrok public URL。
#
# 為什麼不直接用 tunnels[0]：agent 同時開 gateway(:8080) 與 SubGo(:9000)
# 兩個 tunnel，ngrok API 回傳的順序不保證。取錯的後果不是拿不到網址，
# 而是把 LINE webhook 指到 SubGo 的網頁上 —— LINE 收到 200 卻永遠沒反應。
#
# 找不到對應的 tunnel 時以 exit code 1 表示，不輸出任何字串，
# 讓呼叫端的 for /f 拿到空值後走既有的重試路徑。
#
# 作者：MinHao
# 建立日期：2026-08-24
# 異動歷史：
#     2026-08-24 MinHao 初版

param(
    [Parameter(Mandatory = $true)][int]$Port,
    [string]$ApiUrl = 'http://localhost:4040/api/tunnels'
)

try {
    $payload = (Invoke-WebRequest -Uri $ApiUrl -UseBasicParsing -ErrorAction Stop).Content | ConvertFrom-Json

    # config.addr 形如 http://host.docker.internal:8080，故比對結尾的 :<port>
    $match = $payload.tunnels |
        Where-Object { $_.config.addr -match ":$Port$" } |
        Select-Object -First 1

    if ($null -eq $match) { exit 1 }

    Write-Output $match.public_url
    exit 0
} catch {
    exit 1
}
