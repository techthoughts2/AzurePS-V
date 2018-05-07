#if the module is already in memory, remove it
Get-Module AzurePS-V | Remove-Module -Force
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$moduleName = 'AzurePS-V.psm1'
$moduleNamePath = "$script:moduleRoot\$moduleName"
#import the module from the local path
Import-Module $moduleNamePath -Force

Describe 'Infrastructure Tests' {
    Context "PSGallery" -Tag Infrastructure {
        It 'Should have connectivity to the PSGallery' {
            Test-PSGalleryConnection | Should be $true
        }
        It 'Should have the PSGallery as a trusted repository' {
            Test-PSGalleryConnection | Should be $true
        }
    }#context_PSGallery
    Context "NuGet" -Tag Infrastructure {
        It 'Should have connectivity to OneGet'{
            Test-OneGetConnection | Should be $true
        }
        It 'Should have NuGet installed'{
            Test-NuGetProvider | Should be $true
        }
        $a = Get-PublicProviderVersion -providerName NuGet
        $b = Get-InstalledProviderVersion -providerName NuGet
        It 'Should have the latest version of NuGet installed' {
            Compare-PublicVersionToInstalledVersion -publicVersion $a -installedVersion $b |
                Should Be $false
        }
    }
    Context "PowerShellGet" -Tag Infrastructure {
        It 'Should have PowerShellGet installed' {
            Test-PowerShellGet | should be $true
        }
        $a = Get-PSGalleryModuleVersion -moduleName PowerShellGet
        $b = Get-InstalledModuleVersion -moduleName PowerShellGet
        It 'Should have the latest version of PowerShellGet installed' {
            Compare-PublicVersionToInstalledVersion -publicVersion $a -installedVersion $b |
                Should Be $false
        }#PowerShellGet
    }#context_PowerShellGet
    Context "AzurePSModule" -Tag Infrastructure {
        It 'Should have the Azure PS Module installed' {
            Test-AzurePowerShell | Should be $true
        }
        $a = Get-PSGalleryModuleVersion -moduleName Azure
        $b = Get-InstalledModuleVersion -moduleName Azure
        It 'Should have the latest version of Azure PS module installed' {
            Compare-PublicVersionToInstalledVersion -publicVersion $a -installedVersion $b |
                Should Be $false
        }#AzurePSModule
    }#context_AzurePSModule
}#describe_ModuleTests