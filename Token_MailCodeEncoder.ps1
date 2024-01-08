$CODE = @'XXXX'@

[Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($CODE))
