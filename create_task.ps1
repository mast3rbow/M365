<#
===================================================
.NOTES
 Organization: Telstra
 Author: Bryton I. Wishart
 Filename: NetworkAssessment.ps1
 ===================================================

<#
THis script will automatically create the 
#>

# Customer Variables
$customer = ""
$site = ""
$date = (Get-Date).Date


# Scheduled Task Variables
$name = "TeamsNetworkAssessment"
 

# Webhook Reciever Information
$webhook = ""
# Install the Network Assessment Tool locally on the PC


# Powershell script name


# Create schedulded Job
Register-ScheduledJob -Name $name -Trigger $trigger -ScriptBlock $action -MaxResultCount 4
Start-Sleep -Seconds 5
Get-ScheduledJob -name $name

$task = Get-ScheduledTask -TaskName $Name
$task.Triggers.repetition.Duration = 'PT30M'
$task | Set-ScheduledTask


