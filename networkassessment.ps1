<#
===================================================
.NOTES
 Organization: Perficient Inc.
 Filename: NetworkAssessment.ps1
 ===================================================
PowerShell script to automate the Microsoft Network Assessment Tool
Step 1 - Create NetworkAssessment folder at root of C:
Step 2 - Copy network assessment PowerShell script to install directory of the network assessment tool
Step 3 - Create scheduled task to run the PowerShell(AS SHOWN BELOW)
Step 4 - Modify network assessment config file parameters
powershell -nologo -noninteractive -command & ("{C:\Program Files\Microsoft Skype for Business Network Assessment Tool\NetworkAssessment.ps1}")
#>
<#
Start the Network Assessment Process
Wait for process to complete before renaming the file in order to prevent overwriting prior data
#>
push-location "C:\Program Files\Microsoft Skype for Business Network Assessment Tool";
$exe = "NetworkAssessmentTool" 
$proc = (Start-Process $exe -PassThru)
$proc | Wait-Process
<#
Rename output file
#>
$file = Get-Item C:\Networkassessment\performance_results.*

$TSVjson = Import-Csv -Delimiter "`t" -Path $file | ConvertTo-Json -Compress | Add-content -Path "output.json"


# JSON object - creates the Logging object to be sent to the webhook reciever
$obj = New-object -Type psobject
$obj | Add-Member -MemberType NoteProperty -Name Customer -Value $customer -Force
$obj | Add-Member -MemberType NoteProperty -Name Site -Value $site -Force
$obj | Add-Member -MemberType NoteProperty -Name datetime -Value $date -Force


# Constructor script to put object into array
$final_data="["
$final_data+=$obj | ConvertTo-Json
$final_data=+","+$TSVjson+"]"

log $final_data


# sends the restful response t owebhook
#Invoke-RestMethod -Uri $webhook -Method POST -Body $final_data -ContentType "application/json"
