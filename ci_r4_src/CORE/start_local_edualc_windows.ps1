param([Parameter(Mandatory=$true)][string]$Root,[int]$Port=8090)
$ErrorActionPreference='Stop'
$ModelSha='57d1997790d1744fba5b40a7317df71ea5e2acee28c47e78f0cce39c0703f8cf'
$State=Join-Path $Root 'STATE\edualc';New-Item -ItemType Directory -Force $State|Out-Null
$Runtime=Join-Path $State 'runtime.json'
function Get-Sha256([string]$Path){
  $sha=[System.Security.Cryptography.SHA256]::Create()
  $stream=[System.IO.File]::OpenRead($Path)
  try{$hash=$sha.ComputeHash($stream)}finally{$stream.Dispose();$sha.Dispose()}
  return ([System.BitConverter]::ToString($hash)).Replace('-','').ToLowerInvariant()
}
function Test-Health([int]$P){try{$r=Invoke-WebRequest -UseBasicParsing -Uri "http://127.0.0.1:$P/health" -TimeoutSec 2;return ($r.StatusCode -ge 200 -and $r.StatusCode -lt 300)}catch{return $false}}
function Port-Free([int]$P){$used=[System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties().GetActiveTcpListeners().Port;return -not ($used -contains $P)}
if(Test-Path $Runtime){
  try{$prior=Get-Content -Raw $Runtime|ConvertFrom-Json;$pp=[int]$prior.port;if($prior.owned_process -and -not $prior.reused_existing -and $pp -gt 0 -and (Test-Health $pp)){$prior.status='HEALTHY';$prior|Add-Member -Force NoteProperty observed_at ((Get-Date).ToUniversalTime().ToString('o'));$prior|ConvertTo-Json -Depth 6|Set-Content -Encoding UTF8 $Runtime;Write-Host "EDUALC_LOCAL_ALREADY_OWNED port=$pp pid=$($prior.pid)";exit 0}}catch{}
}
if(Test-Health $Port){@{schema='trinity.edualc.runtime.v1';status='HEALTHY';port=$Port;endpoint="http://127.0.0.1:$Port/v1";reused_existing=$true;owned_process=$false;pid=$null;observed_at=(Get-Date).ToUniversalTime().ToString('o')}|ConvertTo-Json -Depth 5|Set-Content -Encoding UTF8 $Runtime;Write-Host "EDUALC_LOCAL_REUSED port=$Port";exit 0}
if(!(Port-Free $Port)){foreach($p in 18080..18149){if(Port-Free $p){$Port=$p;break}};if(!(Port-Free $Port)){throw 'No free EDUALC port in 18080-18149'}}
$model=Join-Path $Root 'EDUALC\MODELS\LOW\Qwen3.5-0.8B-Q4_0.gguf';if(!(Test-Path $model)){throw 'Bundled EDUALC model missing'}
$actual=Get-Sha256 $model;if($actual -ne $ModelSha){throw "Bundled EDUALC model SHA-256 mismatch: $actual"}
$arch=[System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString();$family=if($arch -match 'Arm64'){'WINDOWS_ARM64_CPU'}else{'WINDOWS_X64_CPU'}
$dir=Join-Path $Root "EDUALC\RUNTIMES\LLAMA\$family";$server=Get-ChildItem $dir -Filter llama-server.exe -File -Recurse -ErrorAction SilentlyContinue|Select-Object -First 1;if(!$server){throw "Bundled runtime missing: $family/llama-server.exe"}
$log=Join-Path $State 'llama-server.log';$err=Join-Path $State 'llama-server.err.log'
$args=@('-m',$model,'--alias','captain','--host','127.0.0.1','--port',[string]$Port,'--ctx-size','4096','--jinja','--reasoning','off','-ngl','0')
$proc=Start-Process -FilePath $server.FullName -ArgumentList $args -WorkingDirectory $server.DirectoryName -WindowStyle Hidden -RedirectStandardOutput $log -RedirectStandardError $err -PassThru
$healthy=$false;for($i=0;$i -lt 360;$i++){Start-Sleep -Milliseconds 500;if(Test-Health $Port){$healthy=$true;break};if($proc.HasExited){throw "llama-server exited early: $($proc.ExitCode); see $err"}}
if(!$healthy){try{Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue}catch{};throw "Local EDUALC health timeout; see $err"}
@{schema='trinity.edualc.runtime.v1';status='HEALTHY';port=$Port;endpoint="http://127.0.0.1:$Port/v1";model=$model;model_sha256=$actual;runtime_family=$family;server=$server.FullName;pid=$proc.Id;reused_existing=$false;owned_process=$true;reasoning_mode='off';ctx_size=4096;started_at=(Get-Date).ToUniversalTime().ToString('o')}|ConvertTo-Json -Depth 6|Set-Content -Encoding UTF8 $Runtime
Write-Host "EDUALC_LOCAL_STARTED port=$Port pid=$($proc.Id) runtime=$family"
