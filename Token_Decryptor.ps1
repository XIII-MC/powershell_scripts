$TOKEN_KEY = 238, 121, 2, 5, 102, 154, 136, 255, 29, 107, 208, 248, 96, 50, 65, 229, 29, 122, 171, 118, 109, 55, 144, 221, 171, 220, 137, 162, 228, 103, 17, 216

Function Get-SecureToPlaintext {

    param(
         [Parameter(Mandatory=$true)][String]$String
    )

    $stringSecure = ConvertTo-SecureString -String $String -Key $TOKEN_KEY
    $return = (New-Object PSCredential "dummy",$stringSecure).GetNetworkCredential().Password
    return $return

}

$input = Read-Host "Texte a décrypté"

$decrypted = Get-SecureToPlaintext -String $input

Write-Host "Saisie:" $input
Write-Host
Write-Host "Décrypté:" $decrypted