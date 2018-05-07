$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)


#$runLocal = Split-Path -Parent $MyInvocation.MyCommand.Path
$moduleManifestName = 'AzurePS-V.psd1'
$moduleManifestPath = "$script:moduleRoot\$moduleManifestName"
#$moduleManifestPath = "$runLocal\$moduleManifestName"
$moduleName = 'AzurePS-V.psm1'
$moduleNamePath = "$script:moduleRoot\$moduleName"
#$moduleNamePath = "$runLocal\$moduleName"

$aFunctions = @(
    'Test-AzureSubscriptionAvailability',
    'Test-AzureSubscriptionContext',
    'Invoke-AzurePSVerification',
    'Install-PowerShellGet',
    'Install-AzurePSModule',
    'Install-NuGetProvider',
    'Test-PSGalleryTrusted',
    'Test-PowerShellGet',
    'Test-NuGetProvider',
    'Test-AzurePowerShell',
    'Test-PSGalleryConnection',
    'Test-OneGetConnection',
    'Get-PSGalleryModuleVersion',
    'Get-InstalledModuleVersion',
    'Get-PublicProviderVersion',
    'Get-InstalledProviderVersion',
    'Compare-PublicVersionToInstalledVersion'
)
$mFunctions = @(
    'Invoke-AzurePSVerification'
)
$hFunctions = @(
    'Test-AzureSubscriptionAvailability',
    'Test-AzureSubscriptionContext',
    'Install-PowerShellGet',
    'Install-AzurePSModule',
    'Install-NuGetProvider',
    'Test-PSGalleryTrusted',
    'Test-PowerShellGet',
    'Test-NuGetProvider'
    'Test-AzurePowerShell',
    'Test-PSGalleryConnection',
    'Test-OneGetConnection',
    'Get-PSGalleryModuleVersion',
    'Get-InstalledModuleVersion',
    'Get-PublicProviderVersion',
    'Get-InstalledProviderVersion',
    'Compare-PublicVersionToInstalledVersion'
)
$functionCount = 0
foreach ($function in $functionCount) {
    $functionCount++
}
Describe 'Module Tests' {
    Context "Module Tests" {
        It 'Passes Test-ModuleManifest' {
            Test-ModuleManifest -Path $moduleManifestPath | Should Not BeNullOrEmpty
            $? | Should Be $true
        }#manifestTest
        It 'root module AzurePS-V.psm1 should exist' {
            $moduleNamePath | Should Exist
            $? | Should Be $true
        }#psm1Exists
        It 'manifest should contain AzurePS-V.psm1' {
            $moduleManifestPath |
                Should -FileContentMatchExactly "AzurePS-V.psm1"
        }#validPSM1
        Context "Function Tests" {
            Context "Manifest Functions" {
                foreach ($function in $mFunctions) {
                    It "$function should exist in AzurePS-V.psd1" {
                        $moduleManifestPath |
                            Should -FileContentMatchExactly $function
                    }#mFunctions
                }#foreach
                foreach ($function in $hFunctions) {
                    It "$function should not exist in AzurePS-V.psd1" {
                        $moduleManifestPath |
                            Should -Not -FileContentMatchExactly $function
                    }#hFunctions
                }#foreach
            }#context_ManifestFunctions
            Context "Module Functions" {
                foreach ($function in $aFunctions) {
                    It "$function should exist in AzurePS-V.psm1" {
                        $moduleNamePath |
                            Should -FileContentMatchExactly $function
                    }#aFunctions
                }#foreach
            }#context_ModuleFunctions
        }#context_FunctionTests
        It 'AzurePS-V.psm1 should be valid PS code' {
            $moduleFile = Get-Content -Path $moduleNamePath `
                -ErrorAction Stop
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($moduleFile, [ref]$errors)
            $errors.Count | Should Be 0
        }#validPSCode
    }#contextModuleTests
}#describe_ModuleTests