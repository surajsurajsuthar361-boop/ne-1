$source = $PSScriptRoot
$dest = "C:\Users\DELL\Downloads\nexa 1"

New-Item -ItemType Directory -Path $dest -Force | Out-Null

robocopy "$source" "$dest" /MIR /COPY:DAT /R:1 /W:1

if ($LASTEXITCODE -gt 7) {
    Write-Error "Sync completed with warnings or errors (exit code: $LASTEXITCODE)"
    exit $LASTEXITCODE
}

Write-Host "Project synced to nexa 1 successfully."
