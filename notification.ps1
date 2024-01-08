Add-Type -AssemblyName System.Windows.Forms 
$global:balloon = New-Object System.Windows.Forms.NotifyIcon
$path = (Get-Process -id $pid).Path
$balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path) 
$balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning 
$balloon.Icon = [System.Drawing.SystemIcons]::Information
$balloon.BalloonTipText = 'LE MOT DE PASSE ET LA CONNEXION SONT AUTOMATIQUE.

MERCI DE NE BIEN VOULOIR PATIENTER'
$balloon.BalloonTipTitle = "*** VEUILLEZ PATIENTEZ ***" 
$balloon.Visible = $true 
$balloon.ShowBalloonTip(5000)