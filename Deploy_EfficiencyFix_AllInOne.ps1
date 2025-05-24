Write-Host "Starting Windows Efficiency Fis Script that will add a Task in Task Scheduler"
Write-Host "This will set up in C:\Program Files\EfficicneyFix"
Start-Sleep -Seconds 1
$baseDir = "C:\Program Files\EfficiencyFix"
if (-not (Test-Path $baseDir)) {
    New-Item -ItemType Directory -Path $baseDir -Force | Out-Null
}

# Define paths
$ps1Path = "$baseDir\EfficiencyFix.ps1"
$xmlPath = "$baseDir\EfficiencyFixTask.xml"
$listPath = "C:\Program Files\EfficiencyFix\EfficiencyFixList.txt"

Write-Host "Creating text file for known Efficiency Mode executables (you can edit the file later)"
Start-Sleep -seconds 5
# Known Efficiency Mode offenders
$exeList = @"
chrome
msedge
msedgewebview2
firefox
discord
spotify
steam
epicgameslauncher
notepad
zoom
ms-teams
vlc
powershell
code
obs64
explorer
excel
winword
outlook
"@
Set-Content -Path $listPath -Value $exeList -Encoding UTF8

Write-Host "Creating the PowerShell script that performs the task"
Start-Sleep -Seconds 5

# Write ResetPriority.ps1
$psScriptContent = @'
$logFile = "C:\Program Files\EfficiencyFix\EfficiencyFix.log"
$listPath = "C:\Program Files\EfficiencyFix\EfficiencyFixList.txt"

if (-not (Test-Path $listPath)) {
    Write-Output "No process list found. Exiting."
    exit 1
}

$rawList = Get-Content $listPath -ErrorAction SilentlyContinue
$processList = $rawList -join "," -split "," | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" } | Select-Object -Unique

# Start-Transcript -Path $logFile -Append

foreach ($proc in $processList) {
    Get-Process -Name $proc -ErrorAction SilentlyContinue | ForEach-Object {
        try {
            $_.PriorityClass = 'Normal'
            Write-Output "Set: $($_.Name) [$($_.Id)]"
        } catch {
            Write-Output "FAIL: $($_.Name) [$($_.Id)] — $($_.Exception.Message)"
        }
    }
}

# Stop-Transcript
exit 0
'@
Set-Content -Path $ps1Path -Value $psScriptContent -Encoding UTF8

Write-Host "Creating the XML settings that perform the task"
Start-Sleep -Seconds 5

# Write Task XML
$xmlContent = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Description>Scheduled task that will set the Efficiency Mode to normal on Programs exe on task run</Description>
    <URI>\EfficiencyFix</URI>
  </RegistrationInfo>
  <Triggers>
    <TimeTrigger>
    <Repetition>
      <Interval>PT5M</Interval>
      <StopAtDurationEnd>false</StopAtDurationEnd>
    </Repetition>
    <StartBoundary>2000-01-01T00:00:00</StartBoundary>
    <Enabled>true</Enabled>
    </TimeTrigger>
    <LogonTrigger>
      <Repetition>
        <Interval>PT10M</Interval>
        <StopAtDurationEnd>false</StopAtDurationEnd>
      </Repetition>
      <Enabled>true</Enabled>						  
    </LogonTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>S-1-5-18</UserId>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>StopExisting</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>true</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>false</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <DisallowStartOnRemoteAppSession>false</DisallowStartOnRemoteAppSession>
    <UseUnifiedSchedulingEngine>true</UseUnifiedSchedulingEngine>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT2M</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>powershell.exe</Command>
      <Arguments>-ExecutionPolicy Bypass -File "$ps1Path"</Arguments>
    </Exec>
  </Actions>
</Task>
"@

$utf16 = New-Object System.Text.UnicodeEncoding $False, $True
[System.IO.File]::WriteAllText($xmlPath, $xmlContent, $utf16)

# Register the task and run it immediately
Write-Host "Creating the task in Task Scheduler"
schtasks /Create /TN "EfficiencyFix" /XML "$xmlPath" /F
Start-Sleep -Seconds 1
Write-Host "Starting the task"
schtasks /Run /TN "EfficiencyFix"
