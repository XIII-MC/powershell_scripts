function Test-KeyPress
{
    param
    (
        [Parameter(Mandatory)]
        [ConsoleKey]
        $Key,

        [System.ConsoleModifiers]
        $ModifierKey = 0
    )
    if ([Console]::KeyAvailable)
    {
        $pressedKey = [Console]::ReadKey($true)

        $isPressedKey = $key -eq $pressedKey.Key
        if ($isPressedKey)
        {
            $pressedKey.Modifiers -eq $ModifierKey
        }
        else
        {
            [Console]::Beep(1800, 200)
            $false
        }
    }
}

Write-Host "————————————————————————————————————————————————————————————————————————————————————" -ForegroundColor White -BackgroundColor Green
Write-Host "                                 CPU Monitoring started                             ” -ForegroundColor White -BackgroundColor Green
Write-Host "                       Press Ctrl+Shift+K to exit monitoring!                       " -ForegroundColor White -BackgroundColor Green
write-host "————————————————————————————————————————————————————————————————————————————————————" -ForegroundColor White -BackgroundColor Green

$i = 0
[double] $lagCount = 0

#$folder = Read-Host “What would you like to call the folder that you would like to save the Top Proccesses in?”
#$docname = Read-Host “What would you like to name the text file?”

$folder = "MONITOR"
$date = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
$docname = "CPU_USAGE - $date"

if ( -Not (Test-Path “c:\$folder”))
{
New-Item -Path “c:\$Folder” -ItemType directory | out-null
}

if ( -Not (Test-Path “c:\$folder\$docname”))
{
New-Item -Path “c:\$Folder\$docname.txt” -ItemType file -Force | out-null
}

$CPUPercent = @{
Name = ‘CPUPercent’
Expression = {
$TotalSec = (New-TimeSpan -Start $_.StartTime).TotalSeconds
[Math]::Round( ($_.CPU * 100 / $TotalSec), 2)
}
}

$ScriptBlock = {
Get-Process |
Select-Object -Property Name, CPU, $CPUPercent, Description |
Sort-Object -Property CPUPercent -Descending |
where-object {$_.CPUPercent -gt 5} |
out-file -filepath c:\$Folder\$docname.txt -encoding ASCII -width 70 -Append
}

Start-Job $ScriptBlock -ArgumentList $_

WHILE ($True) {

$pressed = Test-KeyPress -Key K -ModifierKey 'Control,Shift'
IF ($pressed) {
Write-Host "————————————————————————————————————————————————————————————————————————————————————" -ForegroundColor White -BackgroundColor Red
Write-Host “                                 CPU Monitoring ended                               ” -ForegroundColor White -BackgroundColor Red
Write-Host "                      Ctrl+Shift+K key press detected! Exiting...                 " -ForegroundColor White -BackgroundColor Red
Write-host "————————————————————————————————————————————————————————————————————————————————————" -ForegroundColor White -BackgroundColor Red
break
}

$currentCPUTime = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
$deltaCPUTime = $currentCPUTime - $lastCPUTime
Write-Host $lagCount
$lastCPUTime = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()

IF ($deltaCPUTime -ge 50) 
{
Write-Warning "CPU Lag spike detected! $(Get-Date) ($deltaCPUTime ms)"
}

IF ($deltaCPUTime -ge 17) 
{
$lagCount++
IF ($lagCount -ge 10)
{
Write-Warning "CPU Is taking too long to process! $(Get-Date) ($deltaCPUTime ms)"
}
} ELSEIF ($lagCount -ge 0.5) {
$lagCount -= 0.5
}


$i++

Start-Sleep -Milliseconds 2
}

pause

Invoke-Item c:\$folder\$docname.txt