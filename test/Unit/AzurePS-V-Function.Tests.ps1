#if the module is already in memory, remove it
Get-Module AzurePS-V | Remove-Module -Force
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$moduleName = 'AzurePS-V.psm1'
$moduleNamePath = "$script:moduleRoot\$moduleName"
#import the module from the local path
Import-Module $moduleNamePath -Force

InModuleScope AzurePS-V {
    Describe 'AzurePS-V Prerequisite Function Tests' {
        Context 'Test-PSGalleryTrusted' -Tag Unit {
            it 'should return $true when the PSGallery is a trusted repository' {
                mock 'Get-PSRepository' -MockWith {
                    [PSCustomObject]@{
                        Name               = 'PSGallery'
                        InstallationPolicy = 'Trusted'
                        SourceLocation     = 'https://www.powershellgallery.com/api/v2/'
                    }
                }#endMock
                Test-PSGalleryTrusted | Should be $true
            }
            it 'should return $false when the PSGallery is not a trusted repository' {
                mock 'Get-PSRepository' -MockWith {
                    [PSCustomObject]@{
                        Name               = 'PSGallery'
                        InstallationPolicy = 'Untrusted'
                        SourceLocation     = 'https://www.powershellgallery.com/api/v2/'
                    }
                }#endMock
                Test-PSGalleryTrusted | Should be $false
            }
        }#context_Test-PSGalleryTrusted
        Context 'Test-PowerShellGet' -Tag Unit {
            it 'should return $true when the PowerShellGet module is installed' {
                mock 'Get-Module' -MockWith {
                    [PSCustomObject]@{
                        Name       = 'PowerShellGet'
                        Version    = '1.0.0.1'
                        ModuleType = 'Script'
                    }
                }#endMock
                Test-PowerShellGet | Should be $true
            }
            it 'should return $false when the PowerShellGet module is not installed' {
                mock 'Get-Module' -MockWith {}#endMock
                Test-PowerShellGet | Should be $false
            }
        }#context_Test-PowerShellGet
        Context 'Test-NuGetProvider' -Tag Unit {
            it 'should return $true when the NuGet provider is installed' {
                mock 'Get-PackageProvider' -MockWith {
                    [PSCustomObject]@{
                        Name           = 'NuGet'
                        Version        = '2.8.5.201'
                        DynamicOptions = ''
                    }
                }#endMock
                Test-NuGetProvider | Should be $true
            }
            it 'should return $false when the NuGet provider is not installed' {
                mock 'Get-PackageProvider' -MockWith {}#endMock
                Test-NuGetProvider | Should be $false
            }
        }#context_Test-NuGetProvider
        Context 'Test-AzurePowerShell' -Tag Unit {
            it 'should return $true when the Azure module is installed' {
                mock 'Get-Module' -MockWith {
                    [PSCustomObject]@{
                        Name       = 'AzureRM'
                        Version    = '6.0.0'
                        ModuleType = 'Script'
                    }
                }#endMock
                Test-AzurePowerShell | Should be $true
            }
            it 'should return $false when the PowerShellGet module is not installed' {
                mock 'Get-Module' -MockWith {}#endMock
                Test-AzurePowerShell | Should be $false
            }
        }#context_Test-AzurePowerShell
        Context 'Test-PSGalleryConnection' -Tag Unit {
            it 'should return $true when the PowerShell Gallery can be accessed' {
                mock 'Test-NetConnection' -MockWith {
                    [PSCustomObject]@{
                        ComputerName     = 'powershellgallery.com'
                        RemoteAddress    = '191.234.42.116'
                        RemotePort       = '443'
                        InterfaceAlias   = 'Public'
                        SourceAddress    = '192.168.1.100'
                        PingSucceeded    = $true
                        TcpTestSucceeded = $true
                    }
                }#endMock
                Test-PSGalleryConnection | Should be $true
            }
            $Script:psGalleryResults = $false
            it 'should return $false when the PowerShell Gallery cannot be accessed' {
                mock 'Test-NetConnection' -MockWith {
                    [PSCustomObject]@{
                        ComputerName     = 'powershellgallery.com'
                        RemoteAddress    = '191.234.42.116'
                        RemotePort       = '443'
                        InterfaceAlias   = 'Public'
                        SourceAddress    = '192.168.1.100'
                        PingSucceeded    = $false
                        TcpTestSucceeded = $false
                    }
                }#endMock
                Test-PSGalleryConnection | Should be $false
            }
        }#context_Test-PSGalleryConnection
        Context 'Test-OneGetConnection' -Tag Unit {
            it 'should return $true when OneGet can be accessed' {
                mock 'Test-NetConnection' -MockWith {
                    [PSCustomObject]@{
                        ComputerName     = 'oneget.org'
                        RemoteAddress    = '40.112.143.134'
                        RemotePort       = '443'
                        InterfaceAlias   = 'Public'
                        SourceAddress    = '192.168.1.100'
                        PingSucceeded    = $true
                        TcpTestSucceeded = $true
                    }
                }#endMock
                Test-OneGetConnection | Should be $true
            }
            it 'should return $false when OneGet cannot be accessed' {
                mock 'Test-NetConnection' -MockWith {
                    [PSCustomObject]@{
                        ComputerName     = 'oneget.org'
                        RemoteAddress    = '40.112.143.134'
                        RemotePort       = '443'
                        InterfaceAlias   = 'Public'
                        SourceAddress    = '192.168.1.100'
                        PingSucceeded    = $false
                        TcpTestSucceeded = $false
                    }
                }#endMock
                Test-OneGetConnection | Should be $false
            }
        }#context_Test-OneGetConnection
        Context 'Get-PSGalleryModuleVersion' -Tag Unit {
            mock 'Find-Module' -MockWith {
                [PSCustomObject]@{
                    Version     = @{
                        Major    = 5
                        Minor    = 1
                        Build    = 2
                        Revision = -1
                    }
                    Name        = "Azure"
                    Repository  = "PSGallery"
                    Description = "Microsoft Azure PowerShell - Service Management"
                }
            }#endMock
            it 'when a module version is found on PSGallery, return should contain a PSCustomObject' {
                Get-PSGalleryModuleVersion -moduleName Azure | Should -BeOfType System.Management.Automation.PSCustomObject
            }
            it 'when a module version is found on PSGallery, Major, Minor, Build should be returned with type int' {
                Get-InstalledModuleVersion -moduleName Azure | Select-Object -ExpandProperty Major | Should -BeOfType int
                Get-InstalledModuleVersion -moduleName Azure | Select-Object -ExpandProperty Minor | Should -BeOfType int
                Get-InstalledModuleVersion -moduleName Azure | Select-Object -ExpandProperty Build | Should -BeOfType int
            }
            it 'should return null if no module is found in the PSGallery' {
                mock 'Find-Module' -MockWith {
                    [PSCustomObject]@{}
                }#endMock
                Get-PSGalleryModuleVersion -moduleName Azure | Should -Be $null
            }
        }#context_Get-PSGalleryModuleVersion
        Context 'Get-InstalledModuleVersion' -Tag Unit {
            mock 'Get-Module' -MockWith {
                [PSCustomObject]@{
                    ModuleType = "Script"
                    Version    = @{
                        Major    = 5
                        Minor    = 1
                        Build    = 2
                        Revision = -1
                    }
                    Name       = "Azure"
                }
            }#endMock
            it 'when a module version is found installed, return should contain a PSCustomObject' {
                Get-InstalledModuleVersion -moduleName Azure | Should -BeOfType System.Management.Automation.PSCustomObject
            }
            it 'when a module version is found installed, Major, Minor, Build should be returned with type int' {
                Get-InstalledModuleVersion -moduleName Azure | Select-Object -ExpandProperty Major | Should -BeOfType int
                Get-InstalledModuleVersion -moduleName Azure | Select-Object -ExpandProperty Minor | Should -BeOfType int
                Get-InstalledModuleVersion -moduleName Azure | Select-Object -ExpandProperty Build | Should -BeOfType int
            }
            it 'should return null if no module is found on the local device' {
                mock 'Get-Module' -MockWith {
                    [PSCustomObject]@{}
                }#endMock
                Get-InstalledModuleVersion -moduleName Azure | Should -Be $null
            }
        }#context_Get-InstalledModuleVersion
        Context 'Get-PublicProviderVersion' -Tag Unit {
            it 'should return a psobject of package provider version number from public repo' {
                mock 'Find-PackageProvider' -MockWith {
                    [PSCustomObject]@{
                        Name    = "NuGet"
                        Version = "2.8.5.208"
                        Source  = "https://oneget.org/nuget-2.8.5.208.package.swidtag"
                        Summary = "NuGet provider for the OneGet meta-package manager"
                    }
                }#endMock
                Get-PublicProviderVersion -providerName NuGet | Should -BeOfType System.Management.Automation.PSCustomObject
            }
            it 'should return null if no provider is found' {
                mock 'Find-PackageProvider' -MockWith { $null }#endMock
                Get-PublicProviderVersion -providerName NuGet | Should -Be $null
            }
        }#context_Get-PublicProviderVersion
        Context 'Get-InstalledProviderVersion' -Tag Unit {
            it 'should return a psobject of package provider version number currently installed' {
                mock 'Get-PackageProvider' -MockWith {
                    [PSCustomObject]@{
                        Name    = "NuGet"
                        Version = "2.8.5.208"
                        Source  = "https://oneget.org/nuget-2.8.5.208.package.swidtag"
                        Summary = "NuGet provider for the OneGet meta-package manager"
                    }
                 }#endMock
                 Get-InstalledProviderVersion -providerName NuGet | Should -BeOfType System.Management.Automation.PSCustomObject
            }
            it 'should return null if no provider is found' {
                mock 'Get-PackageProvider' -MockWith { $null }#endMock
                Get-InstalledProviderVersion -providerName NuGet | Should -Be $null
            }
        }#context_Get-InstalledProviderVersion
        Context 'Test-AzureSubscriptionAvailability' -Tag Unit {
            it 'should return true if specified Azure subscription is found' {
                mock 'Get-AzureRmSubscription' -MockWith {
                    [PSCustomObject]@{
                        Name    = "SubName"
                        Id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
                        TenantID  = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
                        State = "Enabled"
                    }
                 }#endMock
                 Test-AzureSubscriptionAvailability -SubscriptionID xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx | Should -Be $true
            }
        }#context_Test-AzureSubscriptionAvailability
        Context 'Test-AzureSubscriptionContext' -Tag Unit {
            it 'should return true if specified Azure subscription is found to be in active context' {
                mock 'Get-AzureRmContext' -MockWith {
                    [PSCustomObject]@{
                        Name    = "[an.email@domain.COM, xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx]"
                        Account = "2.8.5.208"
                        Environment  = "AzureStuffz"
                        Subscription = @{
                            Name = "SubName"
                            Id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
                            TenantId = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
                            State = "Enabled"
                        }
                    }
                 }#endMock
                 Test-AzureSubscriptionContext -SubscriptionID xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx | Should be $true
            }
            it 'should return false if specified Azure subscription is found to not be in active context' {
                mock 'Get-AzureRmContext' -MockWith { $null }#endMock
                Test-AzureSubscriptionContext -SubscriptionID xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx | Should be $false
            }
        }#context_Test-AzureSubscriptionContext
    }#describe
}#inModule
