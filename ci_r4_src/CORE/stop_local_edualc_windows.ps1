param([Parameter(Mandatory=$true)][string]$Root)
$Runtime=Join-Path $Root 'STATE\edualc\runtime.json';if(!(Test-Path $Runtime)){Write-Host 'EDUALC_LOCAL_STOP_NOTHING';exit 0}
try{$d=Get-Content -Raw $Runtime|ConvertFrom-Json}catch{Write-Host 'EDUALC_LOCAL_STOP_STATE_UNREADABLE';exit 0}
if($d.reused_existing -or -not $d.owned_process){Write-Host 'EDUALC_LOCAL_STOP_PRESERVE_EXTERNAL';exit 0}
if($d.pid){try{Stop-Process -Id ([int]$d.pid) -Force -ErrorAction SilentlyContinue}catch{}}
$d.status='STOPPED';$d|Add-Member -Force NoteProperty stopped_at ((Get-Date).ToUniversalTime().ToString('o'));$d|ConvertTo-Json -Depth 6|Set-Content -Encoding UTF8 $Runtime
Write-Host 'EDUALC_LOCAL_STOPPED'
