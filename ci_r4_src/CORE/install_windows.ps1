$ErrorActionPreference='Stop'
$Source=Split-Path -Parent $PSScriptRoot
function Can-Write([string]$Base){
  try{$d=Join-Path $Base 'TRINITY\universal';New-Item -ItemType Directory -Force $d|Out-Null;$t=Join-Path $d '.write_test';'x'|Set-Content $t;Remove-Item $t -Force;return $d}catch{return $null}
}
$existing=@((Join-Path $env:ProgramData 'TRINITY\universal'),(Join-Path $env:LOCALAPPDATA 'TRINITY\universal'),'D:\TRINITY\universal')|Where-Object {$_ -and (Test-Path (Join-Path $_ 'STATE'))}|Select-Object -First 1
if($existing){$Dest=$existing}else{
  $Dest=$null
  if(Test-Path 'D:\'){try{$d='D:\TRINITY\universal';New-Item -ItemType Directory -Force $d|Out-Null;$t=Join-Path $d '.write_test';'x'|Set-Content $t;Remove-Item $t -Force;$Dest=$d}catch{}}
  if(!$Dest){$Dest=Can-Write $env:ProgramData}
  if(!$Dest){$Dest=Can-Write $env:LOCALAPPDATA}
}
if(!$Dest){throw 'No writable TRINITY installation root was available.'}
$oldStop=Join-Path $Dest 'CORE\stop_local_edualc_windows.ps1';if(Test-Path $oldStop){try{& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $oldStop -Root $Dest|Out-Host}catch{}}
$Stamp=(Get-Date).ToUniversalTime().ToString('yyyyMMddTHHmmssZ')
$BackupRoot=Join-Path $Dest ("BACKUPS\preinstall_"+$Stamp)
New-Item -ItemType Directory -Force $BackupRoot|Out-Null
$Replaced=@()
foreach($d in @('CORE','CONFIG','APPS','POLICY','COMPONENTS','TOOLS','ADDONS','UPDATES','EDUALC')){
  if($d -eq 'EDUALC' -and (Test-Path (Join-Path $Dest 'EDUALC\MODELS\LOW\Qwen3.5-0.8B-Q4_0.gguf'))){
    try{$oldHash=(Get-FileHash -Algorithm SHA256 (Join-Path $Dest 'EDUALC\MODELS\LOW\Qwen3.5-0.8B-Q4_0.gguf')).Hash;$newHash=(Get-FileHash -Algorithm SHA256 (Join-Path $Source 'EDUALC\MODELS\LOW\Qwen3.5-0.8B-Q4_0.gguf')).Hash;if($oldHash -eq $newHash){continue}}catch{}
  }
  $src=Join-Path $Source $d;$dst=Join-Path $Dest $d;$tmp="$dst.new"
  if(Test-Path $tmp){Remove-Item -Recurse -Force $tmp}
  Copy-Item -Recurse -Force $src $tmp
  if(Test-Path $dst){
    $bak=Join-Path $BackupRoot $d
    Move-Item $dst $bak
    $Replaced += $d
  }
  try{Move-Item $tmp $dst}
  catch{
    if(Test-Path (Join-Path $BackupRoot $d)){Move-Item (Join-Path $BackupRoot $d) $dst -Force}
    throw
  }
}
Copy-Item -Force (Join-Path $Source 'START_TRINITY.cmd') $Dest -ErrorAction SilentlyContinue
Copy-Item -Force (Join-Path $Source 'INSTALL_TRINITY.cmd') $Dest -ErrorAction SilentlyContinue
$captain=Join-Path $Dest 'CORE\edualc_captain_windows.ps1'
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $captain -Root $Dest -Once | Out-Host
$localStarter=Join-Path $Dest 'CORE\start_local_edualc_windows.ps1'
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $localStarter -Root $Dest | Out-Host
$taskName="TRINITY EDUALC Captain $env:USERNAME"
$taskCommand='powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "'+$captain+'" -Root "'+$Dest+'"'
$taskOk=$false
try{& schtasks.exe /Create /F /SC ONLOGON /TN $taskName /TR $taskCommand | Out-Null;if($LASTEXITCODE -eq 0){$taskOk=$true}}catch{}
if(!$taskOk){
  $startup=[Environment]::GetFolderPath('Startup');$cmd=Join-Path $startup 'TRINITY_EDUALC_CAPTAIN.cmd'
  ('@echo off' + "`r`n" + 'start "" /min powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "'+$captain+'" -Root "'+$Dest+'"') | Set-Content -Encoding ASCII $cmd
  Start-Process powershell.exe -WindowStyle Hidden -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-File',$captain,'-Root',$Dest)
}
$localTaskName="TRINITY Local EDUALC $env:USERNAME"
$localTaskCommand='powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "'+$localStarter+'" -Root "'+$Dest+'"'
$localTaskOk=$false
try{& schtasks.exe /Create /F /SC ONLOGON /TN $localTaskName /TR $localTaskCommand | Out-Null;if($LASTEXITCODE -eq 0){$localTaskOk=$true}}catch{}
if(!$localTaskOk){
  $startup=[Environment]::GetFolderPath('Startup');$localCmd=Join-Path $startup 'TRINITY_LOCAL_EDUALC.cmd'
  ('@echo off' + "`r`n" + 'start "" /min powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "'+$localStarter+'" -Root "'+$Dest+'"') | Set-Content -Encoding ASCII $localCmd
}
# Visible desktop launcher for field use.
$desktop=[Environment]::GetFolderPath('Desktop')
if([string]::IsNullOrWhiteSpace($desktop)){$desktop=Join-Path $env:USERPROFILE 'Desktop'}
New-Item -ItemType Directory -Force $desktop|Out-Null
$link=Join-Path $desktop 'START TRINITY.lnk'
$ws=New-Object -ComObject WScript.Shell
$sc=$ws.CreateShortcut($link)
$sc.TargetPath=Join-Path $Dest 'START_TRINITY.cmd'
$sc.WorkingDirectory=$Dest
$sc.Description='Start TRINITY recovery, EDUALC captain, state and capability discovery'
$sc.IconLocation="$env:SystemRoot\System32\shell32.dll,25"
$sc.Save()
$installDir=Join-Path $Dest 'STATE\install';New-Item -ItemType Directory -Force $installDir|Out-Null
@{schema='trinity.install.v1';installed_at=(Get-Date).ToUniversalTime().ToString('o');source=$Source;destination=$Dest;captain_scheduled=$taskOk;desktop_launcher=$link;backup_root=$BackupRoot;replaced_package_directories=$Replaced;state_preserved=$true}|ConvertTo-Json -Depth 5|Set-Content -Encoding UTF8 (Join-Path $installDir 'current.json')
Write-Host "TRINITY CANDIDATE INSTALLED/STAGED AT: $Dest"
Write-Host "EDUALC captain state: $Dest\STATE"
Write-Host "Desktop launcher: $link"
Write-Host "Previous package-owned files backed up at: $BackupRoot"
Write-Host "PiSIGHT source/launcher: $Dest\APPS\PISIGHT"
