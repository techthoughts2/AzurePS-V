#region variables

$Script:version = "0.9.4"
$Script:psGalleryResults = $false #boolean value to prevent multiple checks for PSGallery communication

#endregion
#region azureSubscription

<#
.Synopsis
    Determines if the specified subscription ID has an active authentication credential. If not, the user will be prompted for credentials for the specified subscription.
.DESCRIPTION
    Validates that the specified session subscription ID is authenticated and available. If not, the user will be prompted for credentials and a connection will be established specified subscription.
.EXAMPLE
    Test-AzureSubscriptionAvailability -SubscriptionID "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

    Determines if the specified Azure subscription ID has an authenticated session. If not, user will be prompted for credentials and a connection will be established.
.EXAMPLE
    Test-AzureSubscriptionAvailability -SubscriptionID $subID

    Determines if the specified Azure subscription ID has an authenticated session. If not, user will be prompted for credentials and a connection will be established.
.EXAMPLE
    Test-AzureSubscriptionAvailability -SubscriptionID "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" -Verbose

    Determines if the specified Azure subscription ID has an authenticated session. If not, user will be prompted for credentials and a connection will be established with verbose output.
.PARAMETER SubscriptionID
    Subscription ID of the Azure account you wish to engage with
.OUTPUTS
    System.Boolean. Indicates if provided subscriptionID has successful authentication and is available or not.
.NOTES
    Author: Jake Morrison - @jakemorrison - http://techthoughts.info
    Contributor: Lyon Till - @LJTill
#>
function Test-AzureSubscriptionAvailability {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
            HelpMessage = 'Azure subscription ID')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$SubscriptionID
    )
    begin {
        $result = $false
        Write-Verbose -Message "Evaluating if $SubscriptionID is currently viable..."
    }#begin
    process {
        $ErrorActionPreference = "SilentlyContinue"
        $availSubscriptions = Get-AzureRmSubscription -SubscriptionId $SubscriptionID -ErrorAction SilentlyContinue
        $ErrorActionPreference = "Continue"
        If ($availSubscriptions -eq $null) {
            Write-Warning -Message "The subscription ID specified is not active."
            Write-Verbose -Message "Establishing Azure login to that subscription..."
            try {
                Add-AzureRmAccount -SubscriptionId $SubscriptionID -ErrorAction Stop
                Write-Verbose -Message "Success."
                $result = $true
            }#try-addSubscription
            catch {
                Write-Warning -Message "An error was encountered adding the new Azure subscription:"
                Write-Error $_
            }#catch-addSubscription
        }#if-nullCheck
        else {
            Write-Verbose -Message "Verified."
            $result = $true
        }#else-nullCheck
    }#process
    end {
        return $result
    }#end
}#function_Test-AzureSubscriptionAvailability
<#
.Synopsis
    Evaluates if provided Azure subscription ID is currently set to the primary context for Azure REsource Manager requests.
.DESCRIPTION
    Evalutates provided Azure subscription ID and gets current metadata to determine the active targeted Azure environment. A boolean value is returned if the provided ID is currently the active target.
.EXAMPLE
    Test-AzureSubscriptionContext -SubscriptionID "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

    Evaluates if the provided Azure subscription ID is currently the actively targeted Azure environment.
.EXAMPLE
    Test-AzureSubscriptionContext -SubscriptionID "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" -Verbose

    Evaluates if the provided Azure subscription ID is currently the actively targeted Azure environment with verbose output.
.PARAMETER SubscriptionID
    Subscription ID of the Azure account you wish to engage with
.OUTPUTS
    System.Boolean. Returns true if Azure subscription ID is in scope, returns false if not in scope.
.NOTES
    Author: Jake Morrison - @jakemorrison - http://techthoughts.info
#>
function Test-AzureSubscriptionContext {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
            HelpMessage = 'Azure subscription ID')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$SubscriptionID
    )
    begin {
        $result = $false #assume the worst
        Write-Verbose -Message "Evaluating if $SubscriptionID is currently the active targeted Azure environment..."
    }#begin
    process {
        try {
            $contextSubscription = Get-AzureRmContext -ErrorAction Stop
            if ($contextSubscription -ne $null) {
                $actualContext = $contextSubscription.Subscription.Id
                if ($actualContext -eq $SubscriptionID) {
                    Write-Verbose "$SubscriptionID is confirmed to be the active context."
                    $result = $true
                }
                else {
                    Write-Verbose "$SubscriptionID is not in the active context."
                }
            }
            else {
                Write-Verbose "There are presently no subscriptions active."
            }
        }
        catch {
            Write-Warning "An error was encountered attempting to evaluate active Azure subscription:"
            Write-Error $_
        }
    }#process
    end {
        return $result
    }#end
}#function_Test-AzureSubscriptionContext

#endregion
#region installFunctions

<#
.Synopsis
   Installs the PowerShellGet module from PSGallery
.DESCRIPTION
   Will install the PowerShellGet module from the PSGallery on the current workstation. Install is scoped to the current user and the latest version will be installed. If current versions exist, the latest version will be installed in a side-by-side fashion.
.EXAMPLE
   Install-PowerShellGet

   Installs the PowerShellGet module from PSGallery on the current device for the currentuser.
.EXAMPLE
   Install-PowerShellGet -Verbose

   Installs the PowerShellGet module from PSGallery on the current device for the currentuser with verbose output.
.OUTPUTS
   N/A
.NOTES
   Author: Jake Morrison - @jakemorrison - http://techthoughts.info
#>
function Install-PowerShellGet {
    [CmdletBinding()]
    param()
    begin {
        Write-Verbose "Starting PowerShellGet Module install..."
    }#begin
    process {
        try {
            Install-Module -Name PowerShellGet -Repository PSGallery -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
            Write-Verbose "PowerShellGet Module installed."
        }#try
        catch {
            Write-Warning "An error was encountered attempting to install PowerShellGet module"
            Write-Error $_
        }#catch
    }#process
    end {
        Write-Verbose "Completed PowerShellGet module install function."
    }#end
}#function_Install-PowerShellGet
<#
.Synopsis
   Installs the Azure PowerShell module from PSGallery.
.DESCRIPTION
   Will install the Azure PowerShell module from the PSGallery on the current workstation. Install is scoped to the current user and the latest version will be installed. If current versions exist, the latest version will be installed in a side-by-side fashion.
.EXAMPLE
   Install-AzurePSModule

   Installs the Azure PowerShell module from PSGallery on the current device for the currentuser.
.EXAMPLE
   Install-AzurePSModule -Verbose

   Installs the Azure PowerShell module from PSGallery on the current device for the currentuser with verbose output.
.OUTPUTS
   N/A
.NOTES
   Author: Jake Morrison - @jakemorrison - http://techthoughts.info
#>
function Install-AzurePSModule {
    [CmdletBinding()]
    param()
    begin {
        Write-Verbose "Starting Azure PowerShell Module install..."
    }#begin
    process {
        try {
            Install-Module -Name Azure -Repository PSGallery -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
            Write-Verbose "Azure PowerShell Module installed."
        }#try
        catch {
            Write-Warning "An error was encountered attempting to install Azure PowerShell module"
            Write-Error $_
        }#catch
    }#process
    end {
        Write-Verbose "Completed Azure PowerShell module install function."
    }#end
}#function_Install-AzurePSModule
<#
.Synopsis
   Installs the NuGet provider from OneGet.
.DESCRIPTION
   Installs the NuGet provider from OneGet.
.EXAMPLE
   Install-NuGetProvider

   Installs the NuGet provider from OneGet.
.EXAMPLE
   Install-NuGetProvider -Verbose

   Installs the NuGet provider from OneGet with verbose output
.OUTPUTS
   N/A
.NOTES
   Author: Jake Morrison - @jakemorrison - http://techthoughts.info
#>
function Install-NuGetProvider {
    [CmdletBinding()]
    param()
    begin {
        Write-Verbose "Starting NuGet provider install..."
    }#begin
    process {
        try {
            Install-PackageProvider -Name NuGet -Force -ErrorAction Stop | Out-Null
            Write-Verbose "NuGet provider installed."
        }#try
        catch {
            Write-Warning "An error was encountered attempting to install NuGet package provider"
            Write-Error $_
        }#catch
    }#process
    end {
        Write-Verbose "Completed Azure PowerShell module install function."
    }#end
}#function_Install-NuGetProvider

#endregion
#region prerequisiteChecks

<#
.Synopsis
   Tests if PowerShell Session is running as Admin
.DESCRIPTION
   Evaluates if current PowerShell session is running under the context of an Administrator
.EXAMPLE
    Test-RunningAsAdmin

    This will verify if the current PowerShell session is running under the context of an Administrator
.EXAMPLE
    Test-RunningAsAdmin -Verbose

    This will verify if the current PowerShell session is running under the context of an Administrator with verbose output
.OUTPUTS
   System.Boolean
.NOTES
   Author: Jake Morrison - @jakemorrison - http://techthoughts.info
#>
function Test-RunningAsAdmin {
    [CmdletBinding()]
    Param()
    $result = $false #assume the worst
    try {
        Write-Verbose -Message "Testing if current PS session is running as admin..."
        $eval = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        if ($eval -eq $true) {
            Write-Verbose -Message "PS Session is running as Administrator."
            $result = $true
        }
        else {
            Write-Verbose -Message "PS Session is NOT running as Administrator"
        }
    }#try
    catch {
        Write-Warning -Message "Error encountering evaluating runas status of PS session"
        Write-Error $_
    }#catch
    return $result
}
<#
.Synopsis
   Evaluates if the PowerShellGet module is currently installed on the system.
.DESCRIPTION
   Evaluates if the PowerShellGet module is currently installed on the system.
.EXAMPLE
   Test-PowerShellGet

   Tests if the PowerShellGet module is currently installed on the system and returns a true/false result.
.EXAMPLE
   Test-PowerShellGet -Verbose

   Tests if the PowerShellGet module is currently installed on the system and returns a true/false result with verbose output.
.OUTPUTS
   System.Boolean. True if found, false if not found.
.NOTES
   Author: Jake Morrison - @jakemorrison - http://techthoughts.info
#>
function Test-PowerShellGet {
    [CmdletBinding()]
    param()
    begin {
        $result = $true #assume the best
    }#begin
    process {
        try {
            $psGetEval = Get-Module -Name PowerShellGet -ListAvailable -ErrorAction Stop
            if ($psGetEval) {
                Write-Verbose "PowerShellGet module verified."
            }#if
            else {
                Write-Verbose "PowerShellGet module not found on this device."
                $result = $false
            }#else
        }#try
        catch {
            $result = $false
            Write-Verbose "An error was encountered looking up the PowerShellGet module:"
            Write-Error $_
        }#catch
    }#process
    end {
        return $result
    }#end
}#function_Test-PowerShellGet
<#
.Synopsis
   Evaluates if the NuGet provider is currently installed on the system.
.DESCRIPTION
   Evaluates if the NuGet provider is currently installed on the system.
.EXAMPLE
   Test-NuGetProvider

   Tests if the NuGet provider is currently installed on the system and returns a true/false result.
.EXAMPLE
   Test-NuGetProvider -Verbose

   Tests if the NuGet provider is currently installed on the system and returns a true/false result with a verbose output.
.OUTPUTS
   System.Boolean. True if found, false if not found.
.NOTES
   Author: Jake Morrison - @jakemorrison - http://techthoughts.info
#>
function Test-NuGetProvider {
    [CmdletBinding()]
    param()
    begin {
        $result = $false #assume the worst
        Write-Verbose "Evaluating if NuGet provider is installed..."
    }#begin
    process {
        $nuGetEval = Get-PackageProvider
        if ($nuGetEval) {
            foreach ($provider in $nuGetEval) {
                if ($provider.Name -eq "NuGet") {
                    Write-Verbose "NuGet provider verified."
                    $result = $true
                }#if
            }#foreach
            if ($result -eq $false) {
                Write-Verbose "NuGet provider not found on this device."
            }#if
        }#if
        else {
            Write-Verbose "NuGet provider not found on this device."
        }#else
    }#process
    end {
        return $result
    }#end
}#function_Test-NuGetProvider
<#
.Synopsis
   Evaluates if the Azure PowerShell module is currently installed on the system.
.DESCRIPTION
   Evaluates if the Azure PowerShell module is currently installed on the system.
.EXAMPLE
   Test-AzurePowerShell

   Tests if the Azure PowerShell module is currently installed on the system and returns a true/false result.
.EXAMPLE
   Test-AzurePowerShell -Verbose

   Tests if the Azure PowerShell module is currently installed on the system and returns a true/false result with verbose output.
.OUTPUTS
   System.Boolean. True if found, false if not found.
.NOTES
   Author: Jake Morrison - @jakemorrison - http://techthoughts.info
#>
function Test-AzurePowerShell {
    [CmdletBinding()]
    param()
    begin {
        $result = $true #assume the best
    }#begin
    process {
        try {
            $azureEval = Get-Module -Name Azure -ListAvailable -ErrorAction Stop
            if ($azureEval) {
                Write-Verbose "Azure module verified."
            }#if
            else {
                Write-Verbose "Azure module not found on this device."
                $result = $false
            }#else
        }#try
        catch {
            $result = $false
            Write-Verbose "An error was encountered looking up the Azure module:"
            Write-Error $_
        }#catch
    }#process
    end {
        return $result
    }#end
}#function_Test-AzurePowerShell
<#
.Synopsis
   Gets the latest version of the specified module from the PSGallery.
.DESCRIPTION
   Looks up the specified module in the PSGallery and pulls in the latest version number. The version numbers are then returned in a PSCustomObject.
.EXAMPLE
   Get-PSGalleryModuleVersion -moduleName Diag-V

   Returns the latest version of the specified module from the PSGallery.
.EXAMPLE
   Get-PSGalleryModuleVersion -moduleName Diag-V -Verbose

   Returns the latest version of the specified module from the PSGallery with verbose output.
.PARAMETER moduleName
   Name of module you wish to look up in the PSGallery.
.OUTPUTS
   System.Management.Automation.PSCustomObject. Major, Minor, Build, Revision. $null is returned if no module is found.
.NOTES
   Author: Jake Morrison - @jakemorrison - http://techthoughts.info
#>
function Get-PSGalleryModuleVersion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,
            Position = 0,
            HelpMessage = 'Name of module you wish to query in PSGallery')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]
        $moduleName
    )
    begin {
        $psGalleryModuleVersion = $null
    }#begin
    process {
        try {
            $moduleInfo = Find-Module -Name $moduleName -Repository PSGallery -ErrorAction Stop
            if ($moduleInfo.Version -ne $null) {
                $psGalleryModuleVersionObj = $moduleInfo | Select-Object -ExpandProperty Version
                $psGalleryModuleVersion = [PSCustomObject]@{
                    Major    = $psGalleryModuleVersionObj.Major
                    Minor    = $psGalleryModuleVersionObj.Minor
                    Build    = $psGalleryModuleVersionObj.Build
                    Revision = $psGalleryModuleVersionObj.Revision
                }#PSCustomObject
            }#if
        }#try
        catch {
            Write-Verbose "An error was encountered retrieving PowerShell Gallery Azure Module version:"
            Write-Error $_
        }#catch
    }#process
    end {
        return $psGalleryModuleVersion
    }#end
}#function_Get-PSGalleryModuleVersion
<#
.Synopsis
   Gets the highest version of the specified module currently installed on the local system.
.DESCRIPTION
   Looks up the specified module on the local system and gets the highest version current installed.
.EXAMPLE
   Get-InstalledModuleVersion -moduleName Diag-V

   Returns the highest version of the specified module installed on the local system.
.EXAMPLE
   Get-InstalledModuleVersion -moduleName Diag-V -Verbose

   Returns the highest version of the specified module installed on the local system with verbose output.
.PARAMETER moduleName
   Name of module you wish to look up on the current system.
.OUTPUTS
   System.Management.Automation.PSCustomObject. Major, Minor, Build, Revision. $null is returned if no module is found.
.NOTES
   Author: Jake Morrison - @jakemorrison - http://techthoughts.info
#>
function Get-InstalledModuleVersion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,
            Position = 0,
            HelpMessage = 'Name of module you wish to query installed on local device')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]
        $moduleName
    )
    begin {
        $installedModuleVersion = $null
    }#begin
    process {
        try {
            $moduleInfo = Get-Module -Name $moduleName -ListAvailable -ErrorAction Stop
            if ($moduleInfo.Version -ne $null) {
                $moduleInfo = $moduleInfo | Select-Object -First 1
                $installedModuleVersionObj = $moduleInfo | Select-Object -ExpandProperty Version
                $installedModuleVersion = [PSCustomObject]@{
                    Major    = $installedModuleVersionObj.Major
                    Minor    = $installedModuleVersionObj.Minor
                    Build    = $installedModuleVersionObj.Build
                    Revision = $installedModuleVersionObj.Revision
                }#PSCustomObject
            }#if
        }#try
        catch {
            Write-Warning "An error was encountered retrieving installed $moduleName version:"
            Write-Error $_
        }#catch
    }#process
    end {
        return $installedModuleVersion
    }#end
}#function_Get-InstalledModuleVersion
<#
.Synopsis
   Compares public version number to installed version number to determine if public version has a higher revision available.
.DESCRIPTION
   Evaluates two provided psobjects that contain version information. The public parameter object is then compared to the installed parameter object and evaluated to determine if the public object version has a higher revision available.
.EXAMPLE
   Compare-PublicVersionToInstalledVersion -publicVersion $publicVersionObject -installedVersion $installedVersionObject

   Evalutes the public and installed version objects to determine if the public has a higher available revision.
.EXAMPLE
   Compare-PublicVersionToInstalledVersion -publicVersion $publicVersionObject -installedVersion $installedVersionObject -Verbose

   Evalutes the public and installed version objects to determine if the public has a higher available revision with verbose output.
.PARAMETER publicVersion
   PSObject containing version number retrieved from public gallery or other source. Major, Minor, Build, are expected.
.PARAMETER installedVersion
   PSObject containing version number retrieved from local system. Major, Minor, Build, are expected.
.OUTPUTS
   System.Boolean. True if public has higher version. False otherwise.
.NOTES
   Author: Jake Morrison - @jakemorrison - http://techthoughts.info
#>
function Compare-PublicVersionToInstalledVersion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,
            Position = 0,
            HelpMessage = 'PSObject of public version')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [psobject]
        $publicVersion,
        [Parameter(Mandatory = $true,
            Position = 1,
            HelpMessage = 'PSObject of currently installed version')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [psobject]
        $installedVersion
    )
    begin {
        $publicHigher = $false
    }#begin
    process {
        #nested if comparing versions
        Write-Verbose "Comparing Major versions..."
        if ($publicVersion.Major -gt $installedVersion.Major) {
            Write-Verbose "Public source has higher major version."
            $publicHigher = $true
        }
        else {
            Write-Verbose "Major versions match."
            Write-Verbose "Comparing Minor versions..."
            if ($publicVersion.Minor -gt $installedVersion.Minor) {
                Write-Verbose "Public source has higher minor version."
                $publicHigher = $true
            }
            else {
                Write-Verbose "Minor versions match."
                Write-Verbose "Comparing Build versions..."
                if ($publicVersion.Build -gt $installedVersion.Build) {
                    Write-Verbose "Public source has higher build version."
                    $publicHigher = $true
                }
                else {
                    Write-Verbose "Build versions match."
                    Write-Verbose "Installed version is identical to Public version."
                    $publicHigher = $false
                }
            }
        }
    }#process
    end {
        return $publicHigher
    }#end
}#function_Compare-PublicVersionToInstalledVersion
<#
.Synopsis
   Gets the latest version of the specified provider from internet.
.DESCRIPTION
   Looks up the specified provider on the internet and pulls in the latest version number. The version numbers are then returned in a PSCustomObject.
.EXAMPLE
   Get-PublicProviderVersion -providerName NuGet

   Returns the latest version of the specified provider from the internet.
.EXAMPLE
   Get-PublicProviderVersion -providerName NuGet -Verbose

   Returns the latest version of the specified provider from the internet with verbose output.
.PARAMETER providerName
   Name of provider you wish to look up on the internet.
.OUTPUTS
   System.Management.Automation.PSCustomObject. Major, Minor, Build, Revision.
.NOTES
   Author: Jake Morrison - @jakemorrison - http://techthoughts.info
#>
function Get-PublicProviderVersion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,
            Position = 0,
            HelpMessage = 'Name of package provider you wish to query')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]
        $providerName
    )
    begin {
        $publicProviderVersion = $null
    }#begin
    process {
        try {
            $providerInfo = Find-PackageProvider -Name $providerName -ErrorAction Stop
            if ($providerInfo -ne $null) {
                $temp = $providerInfo.version.Split(".")
                $publicProviderVersion = [PSCustomObject]@{
                    Major    = $temp[0]
                    Minor    = $temp[1]
                    Build    = $temp[2]
                    Revision = $temp[3]
                }#PSCustomObject
            }#if_nullCheck
        }#try
        catch {
            Write-Verbose "An error was encountered retrieving public package provider version:"
            Write-Error $_
        }#catch
    }#process
    end {
        return $publicProviderVersion
    }#end
}#function_Get-PublicProviderVersion
<#
.Synopsis
   Gets the latest version of the specified provider from the local system.
.DESCRIPTION
   Looks up the specified provider on the local system and pulls in the latest version number. The version numbers are then returned in a PSCustomObject.
.EXAMPLE
   Get-InstalledProviderVersion -providerName NuGet

   Returns the latest version of the specified provider from the local system.
.EXAMPLE
   Get-InstalledProviderVersion -providerName NuGet -Verbose

   Returns the latest version of the specified provider from the local system with verbose output.
.PARAMETER providerName
   Name of provider you wish to look up on the local system.
.OUTPUTS
   System.Management.Automation.PSCustomObject. Major, Minor, Build, Revision.
.NOTES
   Author: Jake Morrison - @jakemorrison - http://techthoughts.info
#>
function Get-InstalledProviderVersion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,
            Position = 0,
            HelpMessage = 'Name of package provider you wish to query installed on local device')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]
        $providerName
    )
    begin {
        $installedProviderVersion = $null
    }#begin
    process {
        try {
            $providerInfo = Get-PackageProvider -Name $providerName -ErrorAction Stop
            if ($providerInfo.Version -ne $null) {
                $providerInfo = $providerInfo | Select-Object -First 1
                $installedProviderVersionObj = $providerInfo | Select-Object -ExpandProperty Version
                $installedProviderVersion = [PSCustomObject]@{
                    Major    = $installedProviderVersionObj.Major
                    Minor    = $installedProviderVersionObj.Minor
                    Build    = $installedProviderVersionObj.Build
                    Revision = $installedProviderVersionObj.Revision
                }#PSCustomObject
            }#if_nullCheck
        }#try
        catch {
            Write-Verbose "An error was encountered retrieving installed package provider version:"
            Write-Error $_
        }#catch
    }#process
    end {
        return $installedProviderVersion
    }#end
}#function_Get-InstalledProviderVersion
<#
.Synopsis
   Tests if connectivity is possible to the PSGallery from the local system.
.DESCRIPTION
   Evaluates of the local system is capable of access to the PSGallery over 443 to powershellgallery.com
.EXAMPLE
   Test-PSGalleryConnection

   Tests if local system can connect to the PSGallery.
.EXAMPLE
   Test-PSGalleryConnection -Verbose

   Tests if local system can connect to the PSGallery with verbose output.
.OUTPUTS
   System.Boolean. True if system can access PSGallery, false if system cannot.
.NOTES
   Author: Jake Morrison - @jakemorrison - http://techthoughts.info
   https://www.powershellgallery.com/api/v2/
#>
function Test-PSGalleryConnection {
    [CmdletBinding()]
    param()
    begin {
        Write-Verbose "Determining if communication to PSGallery is possible..."
        $result = $true #assume the best
    }#begin
    process {
        if ($Script:psGalleryResults -eq $false) {
            try {
                $psGalleryEval = Test-NetConnection powershellgallery.com -Port 443 -ErrorAction Stop
                if ($psGalleryEval.TcpTestSucceeded -eq $true) {
                    Write-Verbose "PowerShell Gallery connection verified."
                    $Script:psGalleryResults = $true
                }#if
                else {
                    Write-Verbose "PowerShell Gallery connection failed."
                    $result = $false
                }#else
            }#try
            catch {
                $result = $false
                Write-Verbose "An error was encountered testing PowerShell Gallery connection:"
                Write-Error $_
            }#catch
        }#if
        else {
            Write-Verbose "PSGallery connectivity already verified. Check not re-run."
            $result = $true
        }
    }#process
    end {
        return $result
    }#end
}#function_Test-PSGalleryConnection
<#
.Synopsis
   Tests if connectivity is possible to OneGet from the local system.
.DESCRIPTION
   Evaluates of the local system is capable of access to oneget.org over 443.
.EXAMPLE
   Test-OneGetConnection

   Tests if local system can connect to OneGet.
.EXAMPLE
   Test-OneGetConnection -Verbose

   Tests if local system can connect to OneGet with verbose output.
.OUTPUTS
   System.Boolean. True if system can access OneGet, false if system cannot.
.NOTES
   Author: Jake Morrison - @jakemorrison - http://techthoughts.info
   https://oneget.org/nuget-
#>
function Test-OneGetConnection {
    [CmdletBinding()]
    param()
    begin {
        Write-Verbose "Determining if communication to OneGet is possible..."
        $result = $true #assume the best
    }#begin
    process {
        try {
            $oneGetEval = Test-NetConnection oneget.org -Port 443 -ErrorAction Stop
            if ($oneGetEval.TcpTestSucceeded -eq $true) {
                Write-Verbose "OneGet connection verified."
            }#if
            else {
                Write-Verbose "OneGet connection failed."
                $result = $false
            }#else
        }#try
        catch {
            $result = $false
            Write-Verbose "An error was encountered testing OneGet connection:"
            Write-Error $_
        }#catch
    }#process
    end {
        return $result
    }#end
}#function_Test-OneGetConnection
<#
.Synopsis
   Evaluates if PSGallery is a trusted repository on the local system.
.DESCRIPTION
   Evaluates if PSGallery is a trusted repository on the local system.
.EXAMPLE
   Test-PSGalleryTrusted

   Looks up PSRepository on local system and determines if PSGallery is a trusted repository.
.EXAMPLE
   Test-PSGalleryTrusted -Verbose

   Looks up PSRepository on local system and determines if PSGallery is a trusted repository with verbose output.
.OUTPUTS
   System.Boolean. True if PSGallery is a trusted repository, false if not.
.NOTES
   Author: Jake Morrison - @jakemorrison - http://techthoughts.info
#>
function Test-PSGalleryTrusted {
    [CmdletBinding()]
    param()
    begin {
        $result = $true #assume the best
    }#begin
    process {
        try {
            $psGalleryEval = Get-PSRepository -Name PSGallery
            if ($psGalleryEval.InstallationPolicy -eq "Trusted") {
                Write-Verbose "PowerShell Gallery verified trusted."
            }#if
            else {
                Write-Verbose "PowerShell Gallery not trusted."
                $result = $false
            }#else
        }#try
        catch {
            $result = $false
            Write-Verbose "An error was encountered testing PowerShell Gallery as trusted:"
            Write-Error $_
        }#catch
    }#process
    end {
        return $result
    }#end
}#function_Test-PSGalleryTrusted

#endregion
#region main

<#
.ExternalHelp .\docs\en-us\AzurePS-V-help.xml
#>
function Invoke-AzurePSVerification {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false,
            HelpMessage = 'No user prompts or interaction mode.')]
        [switch]$InstallNoInteraction,
        [Parameter(Mandatory = $false,
            HelpMessage = 'Check for latest version for all modules and provider.')]
        [switch]$Latest,
        [Parameter(Mandatory = $false,
            HelpMessage = 'Azure subscription ID you wish to connect to and set context for.')]
        [ValidateNotNullOrEmpty()]
        [string]$SubscriptionID
    )
    begin {
        $result = $true #assume the best
        $nuGetRecent = $false #used to determine if new version check should be skipped
        $psGetRecent = $false #used to determine if new version check should be skipped
        $azureRecent = $false #used to determine if new version check should be skipped
        $Script:psGalleryResults = $false #reset this script value
        $adminEval = $false #user to determine if module is running under the context of an administrator
    }#begin
    process {
        #----------------------------------------------------------------------------------------
        $adminEval = Test-RunningAsAdmin
        #----------------------------------------------------------------------------------------
        Write-Verbose "Determining version of PowerShell..."
        if ($PSVersionTable.PSVersion.Major -lt 5) {
            Write-Warning "For best results you should seriously consider upgrading to PowerShell 5"
            Write-Warning "WMF 5.1 Link - https://www.microsoft.com/en-us/download/details.aspx?id=54616"
            Write-Warning "It is possible to run Azure PowerShell on older version of PowerShell if you have PackageManagement PowerShell Modules:"
            Write-Warning "https://www.microsoft.com/en-us/download/details.aspx?id=51451"
            Write-Warning "This module does not support this configuration though - again, consider upgrading to 5.1"
            $result = $false
            return
        }
        else {
            Write-Verbose "PowerShell version verified."
        }
        #----------------------------------------------------------------------------------------
        $nuGetResults = Test-NuGetProvider
        if ($nuGetResults -eq $false) {
            if ($adminEval -eq $true) {
                if ((Test-OneGetConnection) -eq $true) {
                    if (!$InstallNoInteraction) {
                        Write-Verbose "Prompting user..."
                        while ("Y", "N" -notcontains $userChoice) {
                            $userChoice = Read-Host "NuGet provider not found on this system. Would you like to install? (Y/N)"
                            $userchoice = $userChoice.ToUpper()
                        }
                        if ($userChoice -eq "Y") {
                            Write-Verbose "User has elected to install NuGet provider."
                            Install-NuGetProvider
                            $nuGetRecent = $true
                            $nuGetResults = Test-NuGetProvider
                        }
                        else {
                            Write-Verbose "User has elected not to install NuGet provider."
                        }
                    }#if_installNoInteraction
                    else {
                        Write-Verbose "NuGet provider not found on this system. Installing with no interaction..."
                        Install-NuGetProvider
                        $nuGetResults = Test-NuGetProvider
                    }#else_installNoInteraction
                }#if_OneGetConnection
                else {
                    Write-Warning "OneGet communication check failed. NuGet installation and upgrade will not be possible as a result."
                    Write-Warning "Unable to attempt NuGet provider install."
                }#else_OneGetConnection
            }#if_adminCheck
            else {
                Write-Warning "Not currently running as Administrator. Unable to attempt NuGet install."
            }#else_adminCheck
        }#if_NuGetInstallCheck
        if ($nuGetResults -ne $true) {
            Write-Verbose "NuGet not present and is a required provider. Exiting."
            $result = $false
            return
        }
        $userChoice = $null
        #----------------------------------------------------------------------------------------
        if ($Latest -and $nuGetRecent -eq $false) {
            Write-Verbose "Latest flag detected, and NuGet not just installed."
            if ((Test-OneGetConnection) -eq $true) {
                Write-Verbose "Verifying if NuGet provider is latest version available..."
                $a = Get-PublicProviderVersion -providerName NuGet
                $b = Get-InstalledProviderVersion -providerName NuGet
                $vResults = Compare-PublicVersionToInstalledVersion -publicVersion $a -installedVersion $b
                if ($vResults -eq $true) {
                    Write-Verbose "A higher version of NuGet is available..."
                    if ($adminEval -eq $true) {
                        if (!$InstallNoInteraction) {
                            Write-Verbose "Prompting user..."
                            while ("Y", "N" -notcontains $userChoice) {
                                $userChoice = Read-Host "A higher version of NuGet is available. Would you like to install the latest version? (Y/N)"
                                $userchoice = $userChoice.ToUpper()
                            }
                            if ($userChoice -eq "Y") {
                                Write-Verbose "User has elected to install latest version of NuGet."
                                Install-NuGetProvider
                                $b = Get-InstalledProviderVersion -providerName NuGet
                                $vResults = Compare-PublicVersionToInstalledVersion -publicVersion $a -installedVersion $b
                            }
                            else {
                                Write-Verbose "User has elected not to install latest version of NuGet."
                            }
                        }
                        else {
                            Write-Verbose "Installing latest version of NuGet with no interaction..."
                            Install-NuGetProvider
                            $b = Get-InstalledProviderVersion -providerName NuGet
                            $vResults = Compare-PublicVersionToInstalledVersion -publicVersion $a -installedVersion $b
                        }
                    }#if_adminCheck
                    else {
                        Write-Warning "Not currently running as Administrator. Unable to attempt NuGet upgrade."
                    }#else_adminCheck
                }#if_versioncheck
                if ($vResults -eq $true) {
                    Write-Warning "It is recommended that you be running the latest available version of NuGet"
                }
            }#if_OneGetConnection
            else {
                Write-Warning "NuGet package verified but unable to determine if NuGet is latest version."
            }#else_if_OneGetConnection
        }#if_latest_recent
        else {
            Write-Verbose "NuGet latest version check skipped."
        }#else_latest_recent
        $userChoice = $null
        #----------------------------------------------------------------------------------------
        Write-Verbose "Determining if PSGallery is a trusted repository..."
        $psGalleryTrustResults = Test-PSGalleryTrusted
        if ($psGalleryTrustResults -eq $false) {
            if ($InstallNoInteraction) {
                Write-Verbose "Setting PSGallery to trusted with no user interaction..."
                try {
                    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -ErrorAction Stop
                    Write-Verbose "PSGallery set to trusted."
                }
                catch {
                    Write-Warning "An error was encountered setting the PSGallery to a trusted repository:"
                    Write-Error $_
                }
            }
            else {
                Write-Warning "The PSGallery is not a trusted repository on this device. You will see several prompts to trust it as a result."
            }
        }
        #----------------------------------------------------------------------------------------
        Write-Verbose "Verifying if PowerShellGet module is installed..."
        $psGetResults = Test-PowerShellGet
        if ($psGetResults -eq $false) {
            if ($adminEval -eq $true) {
                if ((Test-PSGalleryConnection) -eq $true) {
                    if (!$InstallNoInteraction) {
                        Write-Verbose "Prompting user..."
                        while ("Y", "N" -notcontains $userChoice) {
                            $userChoice = Read-Host "PowerShellGet not found on this system. Would you like to install? (Y/N)"
                            $userchoice = $userChoice.ToUpper()
                        }
                        if ($userChoice -eq "Y") {
                            Write-Verbose "User has elected to install PowerShellGet."
                            Install-PowerShellGet
                            $psGetRecent = $true
                            $psGetResults = Test-PowerShellGet
                        }
                        else {
                            Write-Verbose "User has elected not to install PowerShellGet."
                        }
                    }#if_installNoInteraction
                    else {
                        Write-Verbose "PowerShellGet not found on this system. Installing with no interaction..."
                        Install-PowerShellGet
                        $psGetRecent = $true
                        $psGetResults = Test-PowerShellGet
                    }#else_installNoInteraction
                }#if_psgalleryConnection
                else {
                    Write-Warning "Unable to attempt PowerShellGet module install."
                }#else_psgalleryConnection
            }#if_adminCheck
            else {
                Write-Warning "Not currently running as Administrator. Unable to attempt PowerShellGet install."
            }#else_adminCheck
        }
        if ($psGetResults -ne $true) {
            Write-Verbose "PowerShellGet not present and is a required module. Exiting."
            $result = $false
            return
        }
        $userChoice = $null
        #----------------------------------------------------------------------------------------
        if ($Latest -and $psGetRecent -eq $false) {
            if ((Test-PSGalleryConnection) -eq $true) {
                Write-Verbose "Verifying if PowerShellGet is latest version available..."
                $a = Get-PSGalleryModuleVersion -moduleName PowerShellGet
                $b = Get-InstalledModuleVersion -moduleName PowerShellGet
                $vResults = Compare-PublicVersionToInstalledVersion -publicVersion $a -installedVersion $b
                if ($vResults -eq $true) {
                    Write-Verbose "A higher version of PowerShellGet is available..."
                    if ($adminEval -eq $true) {
                        if (!$InstallNoInteraction) {
                            Write-Verbose "Prompting user..."
                            while ("Y", "N" -notcontains $userChoice) {
                                $userChoice = Read-Host "A higher version of PowerShellGet is available. Would you like to install the latest version? (Y/N)"
                                $userchoice = $userChoice.ToUpper()
                            }
                            if ($userChoice -eq "Y") {
                                Write-Verbose "User has elected to install latest version of PowerShellGet."
                                Install-PowerShellGet
                                $b = Get-InstalledModuleVersion -moduleName PowerShellGet
                                $vResults = Compare-PublicVersionToInstalledVersion -publicVersion $a -installedVersion $b
                            }
                            else {
                                Write-Verbose "User has elected not to install latest version of PowerShellGet."
                            }
                        }
                        else {
                            Write-Verbose "Installing latest version of PowerShellGet with no interaction..."
                            Install-PowerShellGet
                            $b = Get-InstalledModuleVersion -moduleName PowerShellGet
                            $vResults = Compare-PublicVersionToInstalledVersion -publicVersion $a -installedVersion $b
                        }
                    }#if_adminCheck
                    else {
                        Write-Warning "Not currently running as Administrator. Unable to attempt PowerShellGet upgrade."
                    }#else_adminCheck
                }#if_versioncheck
                if ($vResults -eq $true) {
                    Write-Warning "It is recommended that you be running the latest available version of PowerShellGet"
                }
            }#if_psgalleryConnection
            else {
                Write-Warning "PowerShellGet Module verified but unable to determine if PowerShellGet module is latest version."
            }#else_psgalleryConnection
        }#if_latest_recent
        else {
            Write-Verbose "PowerShellGet latest version check skipped."
        }#else_latest_recent
        $userChoice = $null
        #----------------------------------------------------------------------------------------
        Write-Verbose "Verifying if Azure PowerShell module is installed..."
        $azurePSResults = Test-AzurePowerShell
        if ($azurePSResults -eq $false) {
            if ($adminEval -eq $true) {
                if ((Test-PSGalleryConnection) -eq $true) {
                    if (!$InstallNoInteraction) {
                        Write-Verbose "Prompting user..."
                        while ("Y", "N" -notcontains $userChoice) {
                            $userChoice = Read-Host "Azure PowerShell module not found on this system. Would you like to install? (Y/N)"
                            $userchoice = $userChoice.ToUpper()
                        }
                        if ($userChoice -eq "Y") {
                            Write-Verbose "User has elected to install Azure PowerShell module."
                            Install-AzurePSModule
                            $azureRecent = $true
                            $azurePSResults = Test-AzurePowerShell
                        }
                        else {
                            Write-Verbose "User has elected not to install Azure PowerShell module."
                        }
                    }
                    else {
                        Write-Verbose "Azure PowerShell module not found on this system. Installing with no interaction..."
                        Install-AzurePSModule
                        $azureRecent = $true
                        $azurePSResults = Test-AzurePowerShell
                    }
                }#if_psgalleryConnection
                else {
                    Write-Warning "Unable to attempt Azure PowerShell module install."
                }#else_psgalleryConnection
            }#if_adminCheck
            else {
                Write-Warning "Not currently running as Administrator. Unable to attempt Azure PowerShell install."
            }#else_adminCheck
        }
        if ($azurePSResults -ne $true) {
            Write-Verbose "Azure PowerShell module not present and is a required module. Exiting."
            $result = $false
            return
        }
        $userChoice = $null
        #----------------------------------------------------------------------------------------
        if ($Latest -and $azureRecent -eq $false) {
            if ((Test-PSGalleryConnection) -eq $true) {
                Write-Verbose "Verifying if Azure PowerShell is latest version available..."
                $a = Get-PSGalleryModuleVersion -moduleName Azure
                $b = Get-InstalledModuleVersion -moduleName Azure
                $vResults = Compare-PublicVersionToInstalledVersion -publicVersion $a -installedVersion $b
                if ($vResults -eq $true) {
                    Write-Verbose "A higher version of Azure PowerShell is available..."
                    if ($adminEval -eq $true) {
                        if (!$InstallNoInteraction) {
                            Write-Verbose "Prompting user..."
                            while ("Y", "N" -notcontains $userChoice) {
                                $userChoice = Read-Host "A higher version of Azure PowerShell is available. Would you like to install the latest version? (Y/N)"
                                $userchoice = $userChoice.ToUpper()
                            }
                            if ($userChoice -eq "Y") {
                                Write-Verbose "User has elected to install latest version of Azure PowerShell."
                                Install-AzurePSModule
                                $b = Get-InstalledModuleVersion -moduleName Azure
                                $vResults = Compare-PublicVersionToInstalledVersion -publicVersion $a -installedVersion $b
                            }
                            else {
                                Write-Verbose "User has elected not to install latest version of Azure PowerShell."
                            }
                        }
                        else {
                            Write-Verbose "Installing latest version of Azure PowerShell with no interaction..."
                            Install-AzurePSModule
                            $b = Get-InstalledModuleVersion -moduleName Azure
                            $vResults = Compare-PublicVersionToInstalledVersion -publicVersion $a -installedVersion $b
                        }
                    }#if_adminCheck
                    else {
                        Write-Warning "Not currently running as Administrator. Unable to attempt Azure PowerShell upgrade."
                    }#else_adminCheck
                }#if_versioncheck
                if ($vResults -eq $true) {
                    Write-Warning "It is recommended that you be running the latest available version of Azure PowerShell"
                }
            }#if_psgalleryConnection
            else {
                Write-Warning "Azure PowerShell Module verified but unable to determine if Azure PowerShell module is latest version."
            }#else_psgalleryConnection
        }#if_latest_recent
        else {
            Write-Verbose "Azure PowerShell latest version check skipped."
        }#else_latest_recent
        $userChoice = $null
        #----------------------------------------------------------------------------------------
        if ($SubscriptionID) {
            Write-Verbose "SubscriptionID specified. Performing Azure subscription checks..."
            $azureSubResults = Test-AzureSubscriptionAvailability -SubscriptionID $SubscriptionID
            if ($azureSubResults -eq $true) {
                $azureContext = Test-AzureSubscriptionContext -SubscriptionID $SubscriptionID
                if ($azureContext -ne $true) {
                    try {
                        Set-AzureRmContext -Subscription $SubscriptionID
                    }
                    catch {
                        Write-Warning "An error was encountered setting the AzureRM Context:"
                        Write-Error $_
                        $result = $false
                    }
                }
            }
            else {
                Write-Warning "Unable to establish Azure connection to $SubscriptionID"
                $result = $false
            }
        }
        #----------------------------------------------------------------------------------------
    }#process
    end {
        $Script:psGalleryResults = $false #reset this script value
        return $result
    }#end

}#function_Invoke-AzurePSVerification

#endregion