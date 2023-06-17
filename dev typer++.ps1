Start-Process "C:\Program Files\Google\Chrome\Application\chrome.exe" "xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
sleep(3)
#This is for testing purposes ONLY. ^^^^^^^^^^^^^^^^

IF ((Get-Process -Name '*chrome*' | Measure-Object).Count -ge 1) {
    Set-Clipboard -Value $null
    $wshell=New-Object -ComObject wscript.shell

    $wshell.SendKeys("{F6}")
    sleep -Milliseconds 100
    $wshell.SendKeys("^c")
    sleep -Milliseconds 100
    $wshell.SendKeys("{ESC}")
    sleep -Milliseconds 100
    $URL = Get-Clipboard
    sleep -Milliseconds 100

    IF ($URL -ne "xxxxxxxxxxxxxxxxxxxxxxxx") {
        $wshell.SendKeys("xxxxxxxxxxxxxxxxxxxxxxxxxx")
        $wshell.SendKeys("{ENTER}")
    }
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.Clipboard]::Clear()
}