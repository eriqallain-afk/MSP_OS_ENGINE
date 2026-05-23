# INFRA-SRV-SQL_PrePost_Validation_V2
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-SysAdmin | @IT-MaintenanceMaster | @IT-Commandare-Infra | @IT-Assistant-N3
**Département :** INFRA | **Source :** IT MSP Intelligence Platform

---

**Agents :** IT-MaintenanceMaster | IT-SysAdmin

## Services
```powershell
Get-Service | Where-Object {$_.Name -match '^MSSQL' -or $_.Name -match '^SQL'} | Sort-Object Name | Format-Table Name,Status,StartType
```

## Connectivité (local)
> Option A : `Invoke-Sqlcmd` si module dispo.

```powershell
if (Get-Command Invoke-Sqlcmd -ErrorAction SilentlyContinue) {
  Invoke-Sqlcmd -Query "SELECT @@SERVERNAME AS ServerName, @@VERSION AS Version" | Format-Table -Auto
} else {
  "Invoke-Sqlcmd indisponible — fallback .NET"
  $cn = New-Object System.Data.SqlClient.SqlConnection
  $cn.ConnectionString = "Server=localhost;Database=master;Integrated Security=True;Connection Timeout=5"
  $cn.Open();
  $cmd = $cn.CreateCommand();
  $cmd.CommandText = "SELECT @@SERVERNAME AS ServerName";
  $r = $cmd.ExecuteScalar();
  $cn.Close();
  "ServerName=$r"
}
```

## Journaux Windows (SQL-related)
```powershell
$Start=(Get-Date).AddHours(-2)
Get-WinEvent -FilterHashtable @{LogName='Application'; StartTime=$Start} |
  Where-Object { $_.LevelDisplayName -in 'Error','Critical' -and ($_.ProviderName -match 'MSSQL|SQLSERVERAGENT|SQL' -or $_.Message -match 'SQL') } |
  Select-Object -First 30 TimeCreated,Id,ProviderName,Message | Format-Table -Wrap
```

## Postcheck après reboot
- Services MSSQL/Agent running.
- Test SELECT OK.
- Vérifier EventLog 1h post.

## Note opérationnelle
- Certains environnements (CU/patch) peuvent nécessiter **2 reboots**. Documenter la raison (pending reboot flags).
