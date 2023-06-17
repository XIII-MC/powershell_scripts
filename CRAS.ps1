#Last updated: EN Date format: 05/18/2023 | FR Date format: 18/05/2023

##########################################################################
#                             SETTINGS                                   #
##########################################################################

#The URL you want to open
$URL = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'

#The mail adress in case a login is required
$MAIL = 'XXXXXXXXXXXXXXX@XXXXX.XXX'

##########################################################################

#Initialization
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
#Get the default browser from the registery
$BROWSER_CODENAME = (Get-ItemProperty HKCU:\Software\Microsoft\windows\Shell\Associations\UrlAssociations\http\UserChoice).Progid

FUNCTION Send-Notification {

    param (
        [string] $Title,
        [string] $Message
    )
    
    $global:balmsg = New-Object System.Windows.Forms.NotifyIcon
    $path = (Get-Process -id $pid).Path
    $balmsg.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
    $balmsg.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
    $balmsg.BalloonTipText = $Message
    $balmsg.BalloonTipTitle = $Title
    $balmsg.Visible = $true
    $balmsg.ShowBalloonTip(20000)
}

FUNCTION Focus-Broswer() {
    #Focus on the browser

    #Edge: MicrosoftEdge/CD/SH/Edge
    #Chrome: chrome
    #Firefox: firefox
    #Opera: opera

    [void][System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
    #Activate window
    [Microsoft.VisualBasic.Interaction]::AppActivate($BROWSER_NAME)

}


FUNCTION Get-URL() {
    $wshell = (New-Object -ComObject wscript.shell) 

    #Get the current's tab URL, needs to be adapted to each browser (Thanks again Edge for not letting us use F6 to select the current's tab URL...)
    $wshell.SendKeys("%{d}") #ALT + D

    #Give it time to select it
    sleep -Milliseconds 500

    #Copy the URL in the clipboard to check if its the login page
    $wshell.SendKeys("^{c}") # CTRL + C

    #Give it time to copy it to clipboard
    sleep -Milliseconds 500

    #Edge is picky on shortcuts too!
    IF ($BROWSER_NAME -eq "Edge") {
        $wshell.SendKeys("{F6}")
    } ELSE {
        $wshell.SendKeys("{ESC}")
    }
    return Get-Clipboard -Raw
}

#Get a more readable browser name (Looking at you Edge...)

#Edge
IF ($BROWSER_CODENAME -eq "AppXq0fevzme2pys62n3e0fbqa7peapykr8v") {
    $BROWSER_NAME = "Edge"
#Chrome
} ELSEIF ($BROWSER_CODENAME -eq "ChromeHTML") {
    $BROWSER_NAME = "Chrome"
#Firefox
} ELSEIF ($BROWSER_CODENAME -eq "FirefoxURL-308046B0AF4A39CB") {
    $BROWSER_NAME = "Firefox"
#Opera
} ELSEIF ($BROWSER_CODENAME -eq "OperaStable") {
    $BROWSER_NAME = "Opera"
#Default
} ELSE {
    $BROWSER_NAME = $BROWSER_CODENAME
    Send-Notification "An error occurred." "It seems like the default web browser is not supported."
}

#Edge: AppXq0fevzme2pys62n3e0fbqa7peapykr8v
#Chrome: ChromeHTML
#Firefox: FirefoxURL-308046B0AF4A39CB
#Opera: OperaStable

#Launch default browser and open the URL
Start-Process $URL -WindowStyle Maximized

#Wait for the process to have the main window created, Edge will get stuck on that for some reasons
IF ($BROWSER_NAME -ne "Edge") { WHILE ((Get-Process -ErrorAction Ignore $BROWSER_NAME).Where({ $_.MainWindowTitle }, 'First').MainWindowHandle -eq $Null) {} }

#Give time to start the window
sleep -Seconds 8

#Focus on broswer window
Focus-Broswer
sleep -Seconds 2

#Check URL and send proper sendkeys if needed
IF ("$(Get-URL)" -ne "$URL") {
    
    #The current's tab URL is not the same as the desired one

    #Center cursor in the middle of the screen
    $bounds = [system.windows.forms.screen]::PrimaryScreen.Bounds
    $center = $bounds.Location
    $center.X += $bounds.Width / 2
    $center.Y += ($bounds.Height / 2) - 50
    [System.Windows.Forms.Cursor]::Position = $center

    sleep -Milliseconds 500

    #Send mouse click to make sure that we selected the text field where you have to type the mail adress, below is the import, then the left click
    Add-Type -MemberDefinition '[DllImport("user32.dll")] public static extern void mouse_event(int flags, int dx, int dy, int cButtons, int info);' -Name U32 -Namespace W;
    [W.U32]::mouse_event(6,0,0,0,0);

    sleep -Milliseconds 500

    $wshell = (New-Object -ComObject wscript.shell)

    #Select all already entered text to prevent typing wrong adress (In case something here is already present)
    $wshell.SendKeys("^{a}") #CTRL + A

    #Send the keys to auto-type the mail adress and enter to login
    $wshell.SendKeys($MAIL) #The mail adress that is entered at the top of the script
    $wshell.SendKeys("{ENTER}") #ENTER
    
    #Wait to get the page asking if we want to stay logged in
    sleep -Seconds 15

    #Focus again to make sure
    Focus-Broswer

    #If we are on the page asking if we want to stay logged in
    IF ("$(Get-URL)" -match "/ppsecure/post.srf") {
        (New-Object -ComObject wscript.shell).SendKeys("{ENTER}") #ENTER
    }
}