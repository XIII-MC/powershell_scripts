Remove-Variable * -ErrorAction SilentlyContinue; Remove-Module *; $error.Clear()
[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()