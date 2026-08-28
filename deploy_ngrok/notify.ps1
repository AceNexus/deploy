# 以 Windows 通知（toast）顯示訊息。
#
# 為什麼需要獨立一支：開機時的 cmd 視窗會被其他啟動程式的視窗蓋掉，
# 而 toast 會留在通知中心裡，事後還找得到。
#
# AppId 借用 Windows PowerShell 的 AUMID —— toast 必須掛在一個已註冊的
# 應用程式下才顯示得出來，自訂字串會被系統靜默丟棄。
#
# 通知失敗時（使用者關閉通知、WinRT 不可用）退到桌面文字檔，
# 至少留下痕跡而不是什麼都沒有。
#
# 作者：MinHao
# 建立日期：2026-08-25
# 異動歷史：
#     2026-08-25 MinHao 初版

param(
    [Parameter(Mandatory = $true)][string]$Title,
    [string[]]$Lines = @(),
    [string]$FallbackFile = "$env:USERPROFILE\Desktop\ngrok-urls.txt"
)

function Write-FallbackFile {
    param([string]$Path, [string]$Title, [string[]]$Lines)
    try {
        $stamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        $body = @("$Title（$stamp）") + $Lines
        Set-Content -Path $Path -Value $body -Encoding utf8
        Write-Host "[提示] 通知顯示失敗，已改寫入 $Path"
    } catch {
        Write-Host "[警告] 通知與桌面檔案都寫不出來:$($_.Exception.Message)"
    }
}

try {
    [void][Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]
    [void][Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom, ContentType = WindowsRuntime]

    # ToastGeneric 實務上只穩定顯示前三段文字（標題 + 兩行），
    # 多的併到最後一行，免得被系統截掉而看不見。
    $shown = @()
    if ($Lines.Count -le 2) {
        $shown = $Lines
    } else {
        $shown = @($Lines[0], (($Lines[1..($Lines.Count - 1)]) -join ' '))
    }

    $parts = @("<text>$([System.Security.SecurityElement]::Escape($Title))</text>")
    foreach ($line in $shown) {
        $parts += "<text>$([System.Security.SecurityElement]::Escape($line))</text>"
    }

    $xmlText = "<toast><visual><binding template='ToastGeneric'>$($parts -join '')</binding></visual></toast>"

    $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $xml.LoadXml($xmlText)

    $appId = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
    $toast = New-Object Windows.UI.Notifications.ToastNotification $xml
    [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($appId).Show($toast)
    exit 0
} catch {
    Write-FallbackFile -Path $FallbackFile -Title $Title -Lines $Lines
    exit 1
}
