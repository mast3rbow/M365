install-module az.accounts
install-module az.automation
 
#Update the values below specific to your tenant!
$tenantID = "YOUR TENANTID HERE"
$subscriptionID = "YOUR SUBSCRIPTION ID HERE"
$automationAccount = "Your M365Automation Account Here"
$resourceGroup = "Your Azure Resource Group Here"

$moduleName = "Microsoft365dsc"
Connect-AzAccount -SubscriptionId $subscriptionID -Tenant $tenantID
 
Function Get-Dependency {
#Function modifed from: https://4bes.nl/2019/09/05/script-update-all-powershell-modules-in-your-automation-account/
    param(
        [Parameter(Mandatory = $true)]
        [string] $ModuleName   
    )
 
    $OrderedModules = [System.Collections.ArrayList]@()
     
    # Getting dependencies from the gallery
    Write-Verbose "Checking dependencies for $ModuleName"
    $ModuleUri = "https://www.powershellgallery.com/api/v2/Search()?`$filter={1}&searchTerm=%27{0}%27&targetFramework=%27%27&includePrerelease=false&`$skip=0&`$top=40"
    $CurrentModuleUrl = $ModuleUri -f $ModuleName, 'IsLatestVersion'
    $SearchResult = Invoke-RestMethod -Method Get -Uri $CurrentModuleUrl -UseBasicParsing | Where-Object { $_.title.InnerText -eq $ModuleName }
 
    if ($null -eq $SearchResult) {
        Write-Output "Could not find module $ModuleName in PowerShell Gallery."
        Continue
    }
    $ModuleInformation = (Invoke-RestMethod -Method Get -UseBasicParsing -Uri $SearchResult.id)
 
    #Creating Variables to get an object
    $ModuleVersion = $ModuleInformation.entry.properties.version
    $Dependencies = $ModuleInformation.entry.properties.dependencies
    $DependencyReadable = $Dependencies -split ":\|"
 
    $ModuleObject = [PSCustomObject]@{
        ModuleName    = $ModuleName
        ModuleVersion = $ModuleVersion
    }
     
    # If no dependencies are found, the module is added to the list
    if (![string]::IsNullOrEmpty($Dependencies) ) {
        foreach ($dependency in $DependencyReadable){
            $DepenencyObject = [PSCustomObject]@{
                ModuleName    = $($dependency.split(':')[0])
                ModuleVersion = $($dependency.split(':')[1].substring(1).split(',')[0])
            }
            $OrderedModules.Add($DepenencyObject) | Out-Null
        }
    }
 
    $OrderedModules.Add($ModuleObject) | Out-Null
 
    return $OrderedModules
}
 
$ModulesAndDependencies = Get-Dependency -moduleName $moduleName
#$ModulesAndDependencies
 
write-output "Installing $($ModulesAndDependencies | ConvertTo-Json)"
 
#Install Module and Dependencies into Automation Account
foreach($module in $ModulesAndDependencies){
    $CheckInstalled = get-AzAutomationModule -AutomationAccountName $automationAccount -ResourceGroupName $resourceGroup -Name $($module.modulename) -ErrorAction SilentlyContinue
    if($CheckInstalled.ProvisioningState -eq "Succeeded" -and $CheckInstalled.Version -ge $module.ModuleVersion){
        write-output "$($module.modulename) existing: v$($CheckInstalled.Version), required: v$($module.moduleVersion)"
    }
    else{
        New-AzAutomationModule -AutomationAccountName $automationAccount -ResourceGroupName $resourceGroup -Name $($module.modulename) -ContentLinkUri "https://www.powershellgallery.com/api/v2/package/$($module.modulename)/$($module.moduleVersion)" -Verbose    
        While($(get-AzAutomationModule -AutomationAccountName $automationAccount -ResourceGroupName $resourceGroup -Name $($module.modulename)).ProvisioningState -eq 'Creating'){
            Write-output 'Importing $($module.modulename)...'
            start-sleep -Seconds 10
        }
    }
}