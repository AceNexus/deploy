param(
    [string]$Token    = $env:TEMP_LINE_TOKEN,
    [string]$Endpoint = $env:TEMP_WEBHOOK_URL
)

$Token    = $Token.Trim()
$Endpoint = $Endpoint.Trim()

Write-Host "  Webhook URL : $Endpoint"
Write-Host "  Token 前 12 : $($Token.Substring(0, [Math]::Min(12, $Token.Length)))..."

$body = '{"endpoint":"' + $Endpoint + '"}'
Write-Host "  Body        : $body"

try {
    $wc = New-Object System.Net.WebClient
    $wc.Headers.Add("Authorization", "Bearer $Token")
    $wc.Headers.Add("Content-Type",  "application/json")

    $response = $wc.UploadString(
        "https://api.line.me/v2/bot/channel/webhook/endpoint",
        "PUT",
        $body
    )

    Write-Host "[成功] LINE Bot Webhook 已更新為: $Endpoint"
    exit 0
} catch [System.Net.WebException] {
    $errBody = ""
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $errBody = $reader.ReadToEnd()
    }
    Write-Host "[警告] $($_.Exception.Message)"
    if ($errBody) { Write-Host "  LINE 回應: $errBody" }
    exit 1
} catch {
    Write-Host "[錯誤] $($_.Exception.Message)"
    exit 1
}
