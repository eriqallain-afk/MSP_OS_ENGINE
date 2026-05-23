DISM /Online /Cleanup-Image /ScanHealth
DISM /Online /Cleanup-Image /RestoreHealth
sfc /scannow
# Restart-Computer -Force  ⚠️ NE PAS décommenter sans validation explicite du technicien
Write-Host 'DISM/SFC terminé. Valider les résultats avant tout reboot.' -ForegroundColor Yellow
