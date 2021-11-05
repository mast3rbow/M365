<#
===================================================
.NOTES
 Author: Bryton I. Wishart
 Filename: NetworkAssessment.ps1
 ===================================================

#>
# Webhook provider
$webhook = "https://prod-23.australiasoutheast.logic.azure.com:443/workflows/43a12597f45a494e8940004e1faa1ac7/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=D3W0MDDN023lNRuxhFZLrvAXiS478RKgmOM7loekZ_g"
$customer ="ACME"
$site = "Site B"


# Run shell file
push-location "C:\Program Files (x86)\Microsoft Teams Network Assessment Tool";
$exe = "NetworkAssessmentTool" 
$proc = (Start-Process $exe -PassThru -ArgumentList @('/qualitycheck'))
$proc | Wait-Process


# Get the file from AppData
$profile = $env:APPDATA
$destination = Split-Path -Path $profile -Parent
$file = Get-Item "$destination\Local\Microsoft Teams Network Assessment Tool\*.*"

# Parse the file and compress to JSON
$csvjson = Import-Csv -Path $file | ConvertTo-Json -Compress
$cleancsv = $csvjson.Replace('\','')

# JSON object - creates the Logging object to be sent to the webhook reciever
$obj = New-object -Type psobject
$obj | Add-Member -MemberType NoteProperty -Name Customer -Value $customer -Force
$obj | Add-Member -MemberType NoteProperty -Name Site -Value $site -Force
$obj | Add-Member -MemberType NoteProperty -Name Data -Value $cleancsv -Force


# Constructor script to put object into array
$data = $obj | ConvertTo-Json

# sends the restful response t owebhook
Invoke-RestMethod -Uri $webhook -Method POST -Body $data -ContentType "application/json"

Remove-Item $file