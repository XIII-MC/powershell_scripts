$dateStart = Get-Date -Format "dddd MM/dd/yyyy HH:mm"
Write-Host "===================================================================================="
Write-Host "     BENCHMARK STARTED - RUNNING SCRIPT | v05052023 |" $dateStart
$StopWatch = New-Object System.Diagnostics.Stopwatch
$StopWatch.Start()
Write-Host "===================================================================================="
Write-Host ""

try {
    [int] $n = Read-Host Entrez un nombre
} catch [System.InvalidCastException] {
    Write-Warning "Ceci n'est pas un nombre! >>> (System.InvalidCastException)"
    exit
}

$Result = $n % 2
 
IF ($Result -eq 0)
{
    Write-Host Pair
} ELSEIF($Result -ne 1 -and $Result -ne 0) {
    Write-Host Pas entier
} ELSE {
    Write-Host Impair
}

$StopWatch.Stop()
sleep(3)
cls

Write-Host ""
Write-Host "===================================================================================="
Write-Host "Started at:" $dateStart
Write-Host "Took:" $StopWatch.Elapsed
Write-Host "Took (ms):" $StopWatch.ElapsedMilliseconds
Write-Host "===================================================================================="