Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Size = New-Object System.Drawing.Size(900,800)
$form.StartPosition = 'CenterScreen'

$form.Text = "Monitor"

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(280,20)
$label.Text = 'Loading CPU Usage infos...'

$form.Controls.Add($label)
$form.ShowDialog()

WHILE ($True) {
    $CPU_USAGE = [math]::Round(((((Get-Counter -Counter '\Informations sur le processeur(_Total)\% temps processeur').Countersamples | where CookedValue).CookedValue | measure -sum).sum),2)
    $label.Text = "$CPU_USAGE%"
    $form.Controls.Add($label)
    $form.ShowDialog()
    Start-Sleep -Seconds 3
}