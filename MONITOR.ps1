[System.Threading.Thread]::CurrentThread.Priority = 'Highest'

$INITTIME = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
$RAM_LastAlert = 0
$FINISHINIT = 0
$KEYPRESS_CLEAR_LASTTIME = $INITTIME
$KEYPRESS_STOP = $false
$CPU_LastTime = $INITTIME
[double]$CPU_AlertCount = 0
[int]$CPU_AFKTIME = 0
[double]$RAM_AlertCount = 0

$docname = $INITTIME

#Setup settings
function Setup-Settings() {
    Clear-Host
    Write-Host "Welcome to the Monitor's setting setup!"
    Write-Host "First off, please choose the method to Monitor this computer."
    Write-Host 
    Write-Host "[0] DEFAULT"
    Write-Host "This method simply returns alerts to the console."
    Write-Host 
    Write-Host "[1] LOG"
    Write-Host "This method will only log alerts into a file."
    Write-Host
    Write-Host "[2] SENTRY"
    Write-Host "This method will both log and return alerts to the console."
    Write-Host 
    TRY {
        [int]$temp_SETTINGS_MODE = Read-Host "To select a method, press the number assigned to it."
        return $temp_SETTINGS_MODE
    } CATCH [System.Exception] {
        Setup-Settings
        sleep(1)
        Write-Warning "The entered value was incorrect. >>> (System.Exception)"
    }
}

$SETTINGS_MODE = Setup-Settings

$INITTIME = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()

Write-Host "Initialization started! Please wait...."

Remove-Job -Name "MONITOR_*" -Force

Out-File -FilePath C:\MONITOR\$docname.temp

#Function to get any key presses while running
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

Start-Job -Name "MONITOR_GPUUSAGE_JOB" -ScriptBlock {
    WHILE ($True) {

        $GPUUSAGE_3D = [math]::Round((((Get-Counter -Counter "\GPU Engine(*_engtype_3d)\Utilization Percentage").CounterSamples | where CookedValue).CookedValue | measure -sum).sum,2)
        $GPUUSAGE_COPY = [math]::Round((((Get-Counter -Counter "\GPU Engine(*_engtype_copy)\Utilization Percentage").CounterSamples | where CookedValue).CookedValue | measure -sum).sum,2)
        $GPUUSAGE_VDCD = [math]::Round((((Get-Counter -Counter "\GPU Engine(*_engtype_videodecode)\Utilization Percentage").CounterSamples | where CookedValue).CookedValue | measure -sum).sum,2)
        $GPUUSAGE_VPRC = [math]::Round((((Get-Counter -Counter "\GPU Engine(*_engtype_videoprocessing)\Utilization Percentage").CounterSamples | where CookedValue).CookedValue | measure -sum).sum,2)
        
        $Date = Get-Date

        IF ($GPUUSAGE_3D -ge 35) {
            Write-Output "$Date | Abnormal GPU 3D Usage! ($GPUUSAGE_3D%)"
        }

        IF ($GPUUSAGE_COPY -ge 5) {
            Write-Output "$Date | Abnormal GPU Copy Usage! ($GPUUSAGE_COPY%)"
        }

        IF ($GPUUSAGE_VDCD -ge 25) {
            Write-Output "$Date | Abnormal GPU Video Decode Usage! ($GPUUSAGE_VDCD%)"
        }

        IF ($GPUUSAGE_VPRC -ge 20) {
            Write-Output "$Date | Abnormal GPU Video Processing Usage! ($GPUUSAGE_VPRC%)"
        }
    }
}

Start-Job -Name "MONITOR_GPUVRAM_JOB" -ScriptBlock {
    WHILE ($True) {

        TRY {

            $GPUVRAM_USAGE = [math]::Round(((((Get-Counter -Counter "\GPU Local Adapter Memory(*)\Local Usage").Countersamples | where CookedValue).CookedValue | measure -sum).sum)/1GB,2)

            IF ($GPUVRAM_USAGE -ge 1) {
                $Date = Get-Date
                Write-Output "$Date | Abnormal VRAM Usage! ($GPUVRAM_USAGE Gb)"
            }

        } CATCH [System.Exception] {}
    }
}

Start-Job -Name "MONITOR_DISKWRITE_JOB" -ScriptBlock {
    WHILE ($True) {

        $DISKWRITE_SPEED = [math]::Round(((((Get-Counter -Counter "\Activité du disque système de fichiers(_Total)\Octets écrits par le système de fichiers").Countersamples | where CookedValue).CookedValue | measure -sum).sum)/1MB,2)
        
        IF ($DISKWRITE_SPEED -ge 50) {
            $Date = Get-Date
            Write-Output "$Date | Abnormal high Disk Write speeds! ($DISKWRITE_SPEED Mb/s)"
        }
    }
}

Start-Job -Name "MONITOR_DISKREAD_JOB" -ScriptBlock {
    WHILE ($True) {

        $DISKREAD_SPEED = [math]::Round(((((Get-Counter -Counter "\Activité du disque système de fichiers(_Total)\Octets lus par le système de fichiers").Countersamples | where CookedValue).CookedValue | measure -sum).sum)/1MB,2)
        
        IF ($DISKREAD_SPEED -ge 50) {
            $Date = Get-Date
            Write-Output "$Date | Abnormal high Disk Read speeds! ($DISKREAD_SPEED Mb/s)"
        }
    }
}

Start-Job -Name "MONITOR_CPUUSAGE_JOB" -ScriptBlock {
    WHILE ($True) {
        
        $CPU_USAGE = [math]::Round(((((Get-Counter -Counter '\Informations sur le processeur(_Total)\% temps processeur').Countersamples | where CookedValue).CookedValue | measure -sum).sum),2)
        
        IF ($CPU_USAGE -ge 80) {
            $Date = Get-Date
            Write-Output "$Date | High CPU Usage! ($CPU_USAGE%)"
        }
    }
}

Start-Job -Name "MONITOR_DISK_JOB" -ScriptBlock {
    WHILE ($True) {

        $DISK_WMIO = Get-WmiObject Win32_LogicalDisk

        Foreach ($item in $DISK_WMIO) {

            $item_freespace = [math]::Round(($item.FreeSpace/1MB))
            $item_id = $item.DeviceID

            IF ($item_freespace -cle 10000) {
                $Date = Get-Date
                Write-Output "$Date | Low disk space on $item_id drive: $item_freespace MB left"
            }
        }

        Start-Sleep -Seconds 360
    }
}

Start-Job -Name "MONITOR_RAM_JOB" -ScriptBlock {
    WHILE ($True) {

        $RAM_WMIO =  Get-WmiObject -Class WIN32_OperatingSystem

        $RAM_Max = [math]::Round(($RAM_WMIO.TotalVisibleMemorySize/1024/1024),2)
        $RAM_Current = [math]::Round((($RAM_WMIO.TotalVisibleMemorySize - $RAM_WMIO.FreePhysicalMemory)/1024/1024), 2)
        $RAM_Percentage = [math]::Round((($RAM_Current/$RAM_Max)*100),2)

        IF ($RAM_Percentage -ge 80) {

            $Date = Get-Date
            $RAM_AlertCount++

            Write-Output "$Date | High RAM usage! $RAM_Current/$RAM_Max GB ($RAM_Percentage%) ($RAM_AlertCount/12)"

            IF ($RAM_AlertCount -ge 12) {
                Write-Host "$Date | Cleaning up RAM..."
                $RAM_AlertCount = 0
                Cscript.exe D:\Bureau\PS_scripts\RAMCLEAN.vbs //nologo
            }

        } ELSEIF ($RAM_AlertCount -ge 1) {
            $RAM_AlertCount--
        }

        Start-Sleep -Seconds 5
    }
}

Start-Job -Name "MONITOR_CPUTIME_JOB" -ScriptBlock {
    WHILE ($True) {

        Add-Type -AssemblyName System.Windows.Forms
        $p1 = [System.Windows.Forms.Cursor]::Position

        $CPU_deltaTime = ([DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds() - $CPU_LastTime) - 500

        IF ($CPU_deltaTime -cle 5) {
            $CPU_AFKTIME++
        } ELSEIF ($CPU_deltaTime -ge 20) {
            $CPU_AFKTIME = 0
        }

        IF ($p1.X -ne $p2.X -and $p1.Y -ne $p2.Y) {
            IF ($CPU_AFKTIME -ge 30*2) {
                Write-Host "$Date | CPU was idle for $($CPU_AFKTIME/2)s (Woke up by $CPU_deltatime ms)"
                $CPU_AFKTIME = 0
            }
        }

        IF ($CPU_deltaTime -ge 21) {

            $CPU_AlertCount++

            IF ($CPU_AlertCount -ge 2) {
                $Date = Get-Date
                Write-Output "$Date | CPU Monitor process is taking too long! ($CPU_deltaTime ms)"
            }
        } ELSEIF ($CPU_AlertCount -ge 0.5) {
            $CPU_AlertCount -= 0.5
        }

        $CPU_LastTime = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
        Add-Type -AssemblyName System.Windows.Forms
        $p2 = [System.Windows.Forms.Cursor]::Position
        Start-Sleep -Milliseconds 500
    }
}

function MichelinMessage() {
    Clear-Host
    Write-Host
    Write-Host "REMINDER: You are running in Monitor Method's number $SETTINGS_MODE!"
    Write-Host "(CTRL+SHIFT+K=STOP | CTRL+SHIFT+N=CLEAR)"
}

WHILE ($True) {

    $KEYPRESS_STOP = Test-KeyPress -Key K -ModifierKey 'Control,Shift'

    IF ($KEYPRESS_STOP) {
        Write-Host "CTRL+SHIFT+K Key press detected! Exiting..."
        Stop-Job -Name "MONITOR_*"
        Remove-Job -Name "MONITOR_*"
        Write-Host
        Remove-Item -Path C:\MONITOR\$docname.temp
        IF ([String]::IsNullOrWhiteSpace((Get-content C:\MONITOR\$docname.txt))) {
            Remove-Item -Path C:\MONITOR\$docname.txt
            Write-Warning "The Monitor's log file ($docname.txt) was empty therefore it was deleted."
        }
        Remove-Variable * -ErrorAction SilentlyContinue; Remove-Module *; $error.Clear()
        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()
        Read-Host "Press any key to exit."
        exit
    }
    
    $KEYPRESS_CLEAR = Test-KeyPress -Key N -ModifierKey 'Control,Shift'

    IF ($KEYPRESS_CLEAR -and ([DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds() - $KEYPRESS_CLEAR_LASTTIME -ge 10000)) {
        $KEYPRESS_CLEAR_LASTTIME = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
        $KEYPRESS_CLEAR = false
        MichelinMessage
        Write-Host "$(Get-Date) CTRL+SHIFT+N Key press detected! Clearing..."
        Write-Host
    }

    IF($FINISHINIT -eq 0) {
        $FINISHINIT = 1
        MichelinMessage
        Write-Host "Initialization finished! Took $(([DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds() - $INITTIME))ms"
        Write-Host
    }

    [System.Threading.Thread]::CurrentThread.Priority = 'Highest'

    IF ($SETTINGS_MODE -eq 0) {
        Get-Job | ForEach-Object {
            Receive-Job -Name $_.Name
            $ALERTMESSAGE = Get-Content -Path C:\MONITOR\$docname.temp
            IF ($ALERTMESSAGE -ne $null) { Write-Warning $ALERTMESSAGE }
        }
    }
    IF ($SETTINGS_MODE -eq 1) { 
        Receive-Job -Name "MONITOR_*" | Out-File -FilePath C:\MONITOR\$docname.txt -Append
    }
    IF ($SETTINGS_MODE -eq 2) { 
        Get-Job | ForEach-Object {
            $NULL_CHECKER = @(Receive-Job -Name $_.Name)
            IF ($NULL_CHECKER.Count -ge 1) {
                $NULL_CHECKER | ForEach-Object {
                    $_ | Out-File -FilePath C:\MONITOR\$docname.txt -Append
                    Write-Warning "$_"
                }
            }
        }
    }
    Start-Sleep -Seconds 1
}