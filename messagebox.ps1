$d = [System.Windows.MessageBox]::Show("LA CONNEXION CE FAIT AUTOMATIQUEMENT, LES IDENTIFIANTS ET LES MOTS DE PASSE SONT EUX AUSSI COMPLETER AUTOMATIQUEMENT.`n`nAPRES AVOIR CLIQUEZ SUR 'OUI' CI-DESSOUS, NOUS VOUS PRIONS DE BIEN VOULOIR PATIENTEZ.`n`nApres avoir cliqué sur 'OUI' vous addmettez avoir pris connaissance de cette information, et donc d'appliquer cette dernière.", "                     VOTRE ATTENTION EST REQUISE POUR CONTINUER", "YesNo", "Warning")
IF ($d -eq "Yes") {
    Write-Host Good!
} ELSE {
    Add-Type -AssemblyName System.Windows.Forms 
    $global:balloon = New-Object System.Windows.Forms.NotifyIcon
    $path = (Get-Process -id $pid).Path
    $balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path) 
    $balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Error
    $balloon.Icon = [System.Drawing.SystemIcons]::Warning
    $balloon.BalloonTipText = "Vous n'avez pas accepté l'information, l'accès à la base documentaire vous à donc été refusé."
    $balloon.BalloonTipTitle = "Accès refusé." 
    $balloon.Visible = $true 
    $balloon.ShowBalloonTip(5000)
}