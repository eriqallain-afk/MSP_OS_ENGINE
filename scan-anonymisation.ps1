$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Patterns = @(
  'Service\s+Ticket\s+#?\s*T?17\d{5}',
  'Billet\s+#?\s*T?17\d{5}',
  'Ticket\s+#?\s*T?17\d{5}',
  '#T?17\d{5}',
  'T17\d{5}',
  '(?<!\d)17\d{5}(?!\d)'
)
$Files = Get-ChildItem -Path $Root -Recurse -File -Include *.html,*.md,*.txt,*.js,*.json,*.css,*.yml,*.yaml | Where-Object { $_.FullName -notmatch '\\.git\\' }
$Findings = foreach ($Pattern in $Patterns) { $Files | Select-String -Pattern $Pattern -ErrorAction SilentlyContinue }
if ($Findings) {
  Write-Host "ATTENTION : numéros de billets potentiels détectés" -ForegroundColor Red
  $Findings | Select-Object Path,LineNumber,Line | Format-Table -AutoSize
  exit 1
}
Write-Host "OK : aucun numéro de billet réel détecté." -ForegroundColor Green
