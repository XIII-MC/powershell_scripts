#Load the required assemblies
[void] [System.Reflection.Assembly]::LoadWithPartialName(“System.Windows.Forms”)#Remove any registered events related to notifications
Remove-Event BalloonClicked_event -ea SilentlyContinue
Unregister-Event -SourceIdentifier BalloonClicked_event -ea silentlycontinue
Remove-Event BalloonClosed_event -ea SilentlyContinue
Unregister-Event -SourceIdentifier BalloonClosed_event -ea silentlycontinue#Create the notification object
$notification = New-Object System.Windows.Forms.NotifyIcon 
#Define the icon for the system tray
$notification.Icon = [System.Drawing.SystemIcons]::Information

#Display title of balloon window
$notification.BalloonTipTitle = “This is a Balloon Title”

#Type of balloon icon
$notification.BalloonTipIcon = “Info”

#Notification message
$title = “This is the message in the balloon tip.”
$notification.BalloonTipText = $title

#Make balloon tip visible when called
$notification.Visible = $True

## Register a click event with action to take based on event
#Balloon message clicked
register-objectevent $notification BalloonTipClicked BalloonClicked_event `
-Action {[System.Windows.Forms.MessageBox]::Show(“Balloon message clicked”,”Information”);$notification.Visible = $False} | Out-Null

#Balloon message closed
register-objectevent $notification BalloonTipClosed BalloonClosed_event `
-Action {[System.Windows.Forms.MessageBox]::Show(“Balloon message closed”,”Information”);$notification.Visible = $False} | Out-Null

#Call the balloon notification
$notification.ShowBalloonTip(600)