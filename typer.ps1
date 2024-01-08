IF (-Not (Test-Path -Path 'XXXXXXXXXXXXXXXXXXX' -PathType Leaf)) { New-Item -Path 'XXXXXXXXXXXXX' -Value "XXXXXXXXXXXXXXXXXXX" -Force }
Start-Sleep -Seconds 5
[void][reflection.assembly]::loadwithpartialname("system.windows.forms")
$mail = XXXXXXXXXXXXXXXXXXX
[system.windows.forms.sendkeys]::sendwait($mail)
[system.windows.forms.sendkeys]::sendwait("{ENTER}")