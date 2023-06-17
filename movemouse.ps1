$BROWSER_PROCESS = Get-Process chrome |Where-Object MainWindowTitle -like *?
$handle = ($BROWSER_PROCESS |Sort-Object { $_.MainWindowTitle -match 'chrome' } |Select-Object -First 1).MainWindowHandle

$FROMHANDLE = [system.windows.forms.screen]::FromHandle($handle)

#Its not on PrimaryScreen
IF (!$FROMHANDLE.Primary) {

    $bounds = $FROMHANDLE.Bounds
    $center = $bounds.Location

    IF ($FROMHANDLE.WorkingArea.X -match "-") {
        $offset_x_negative = $true
    } ELSE {
        $offset_x_negative = $false
    }

    IF ($FROMHANDLE.WorkingArea.Y -match "-") {
        $offset_y_negative = $true
    } ELSE {
        $offset_y_negative = $false
    }

    #Not negative Y
    Write-Warning $bounds
    IF ($offset_y_negative -eq $false) {
        $center.Y = ($bounds.Height - ($bounds.Height/2))
    } ELSE {
        $center.Y = -($bounds.Height - ($bounds.Height/2))
    }

    #Not negative x
    IF ($offset_x_negative -eq $false) {
        $center.X = ($bounds.Width + ($bounds.Width/2))
    } ELSE {
        $center.X = -($bounds.Width - ($bounds.Width/2))
    }
    [system.windows.forms.cursor]::Position = $center

#Its on PrimaryScreen
} ELSE {
    $bounds = $FROMHANDLE.Bounds
    $center = $bounds.Location

    $center.X = ($bounds.Width/2)
    $center.Y = ($bounds.Height/2)
    [system.windows.forms.cursor]::Position = $center
}   