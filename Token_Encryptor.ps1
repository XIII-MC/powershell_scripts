$TOKEN_KEY = 238, 121, 2, 5, 102, 154, 136, 255, 29, 107, 208, 248, 96, 50, 65, 229, 29, 122, 171, 118, 109, 55, 144, 221, 171, 220, 137, 162, 228, 103, 17, 216

Function Get-PlaintextToSecure {

    param(
         [Parameter(Mandatory=$true)][String]$String
    )

    $stringSecure = ConvertTo-secureString -String $String -asplaintext -force
    $return = ConvertFrom-SecureString $stringSecure -Key $TOKEN_KEY
    return $return
}

Function Get-SecureToPlaintext {

    param(
         [Parameter(Mandatory=$true)][String]$String
    )

    $stringSecure = ConvertTo-SecureString -String $String -Key $TOKEN_KEY
    $return = (New-Object PSCredential "dummy",$stringSecure).GetNetworkCredential().Password
    return $return

}

$input = Read-Host "Texte a encrypté"

$encrypted = Get-PlaintextToSecure -String $input
$decrypted = Get-SecureToPlaintext -String $encrypted

Write-Host "Saisie:" $input
Write-Host
Write-Host "Encrypté:" $encrypted
Write-Host
Write-Host "Décrypté:" $decrypted