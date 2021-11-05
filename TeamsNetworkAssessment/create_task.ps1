<#
===================================================
.NOTES
 Author: Bryton I. Wishart
 Filename: NetworkAssessment.ps1
 ===================================================

<#
THis script will automatically create the scheduled task to run every hour.
#>

# Scheduled Task Variables
$name = "TeamsNetworkAssessment"
$toolfolder = "C:\Program Files (x86)\Microsoft Teams Network Assessment Tool"

$toolpath = $toolfolder+"\NetworkAssessment.ps1"


# Create schedulded Job
$action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-nologo -noninteractive -file $toolpath"
$trigger = New-ScheduledTaskTrigger -Daily -At 8:00

Register-ScheduledTask -TaskName $name -Action $action -Trigger $trigger -TaskPath 'MicrosoftTeams' -Description "Microsoft Teams Call Quality Logging"

Start-Sleep -Seconds 5
Get-ScheduledTask -name $name

$task = Get-ScheduledTask -TaskName $name
$task.Triggers.repetition.Duration = 'PT30M'
$task | Set-ScheduledTask