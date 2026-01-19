$settingsPath = "$env:APPDATA\Code\User\settings.json"
$json = @{
    "git.openRepositoryInParentFolders" = "always"
    "cSpell.enabled" = $true
    "cSpell.language" = "en"
    "cSpell.diagnosticLevel" = "Warning"
    "cSpell.showStatus" = $true
}
$json | ConvertTo-Json -Depth 10 | Set-Content $settingsPath -Force
Write-Host "Global settings updated!"
Write-Host "NOW RESTART VS CODE!"
