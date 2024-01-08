function Create-TokenKey {
    $ByteLenght = Read-Host "Enter byte lenght (16, 24, 32)"
    $TKey = New-Object Byte[] $ByteLenght
    [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($TKey)
    $TKey | Out-File -FilePath C:\TEMP\AES.KEY -Encoding UTF8
    return Get-Content -Path C:\TEMP\AES.KEY
}

$TokenKey = Create-TokenKey
Remove-Item C:\TEMP\AES.KEY -Force
Write-Host "AES Key: $TokenKey"
Write-Warning "You have to replace all white spaces with ', '! Use a text editor like Notepad++ to do that faster!"