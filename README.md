# AzurePS-V
PowerShell module that verifies a local system meets all prerequisites and is capable of running AzureRM PowerShell.

## Synopsis
Verifies the local system is capable of running AzureRM PowerShell and is capable of taking corrective actions to ensure all prerequisites for Azure PowerShell are in place. AzureRM cmdlets can also be scoped to a specific Azure subscription.

This module can be referenced by other modules that run Azure PowerShell so that you can ensure an end device is capable of properly running Azure RM commands.

## Description
Evaluates the local system to determine that all prerequisites are met to successfully run Azure RM PowerShell commands.

**Prerequisites Evaluated**:
* NuGet installed
* PowerShellGet module installed
* Azure PowerShell module instaled

Any prerequisites found missing will be installed automatically if the [-InstallNoInteraction] parameter is specified, otherwise confirmation prompts are presented to the user for each missing component.

If the [-Latest] parameter is provided each component will be evaluated to determine if there is a higher version number available from its respective public repository.  If used in conjunction with the [-InstallNoInteraction] parameter the latest version will automatically be installed, otherwise confirmation prompts are presented to the user for each upgrade.

Once all requirements are met, Azure RM commands can be scoped to a specific Azure subscription with use of the [[-SubscriptionID] <String>] parameter. The specified Azure Subscription ID will be verified, and the user will be prompted for credentials to authenticate to that subscription if not currently active. Once authenticated, the provided ID will be set to the primary context for Azure RM commands.

## Use Case

The intended use case for AzurePS-V is to serve as a supplementary module for your own module that is using Azure PowerShell.

Rather than writing an extensive amount of error control to ensure your end user is capable of running Azure RM commands, you can simply leverage AzurePS-V to verify all prerequisites.

If any components are missing AzurePS-V can handle the installation of everything, allowing your user to focus on using your module, and not getting Azure PowerShell working.

In cases where you want to ensure that your end users are only running your module against a specific Azure subscription, AzurePS-V can also help ensure end users are properly authenticated and have the correct context set for Azure RM commands.

## Prerequisites
* PowerShell 5.1

## How to run
1. ```Import-Module -Name "AzurePS-V"```
2. ```Invoke-AzurePSVerification``` with desired parameters

## Author
[Jake Morrison](https://twitter.com/JakeMorrison) - http://techthoughts.info
## Contributors
* [Lyon Till](https://twitter.com/LJTill)
* [Justin Saylor](https://twitter.com/XJustinSaylorX)

## Notes

* If you specify a Subscription ID the overall true/false return will be impacted. The Subscription ID will be treated as a required prerequisite and if it can't be set, will fail the overall check.
* Keep time impact in mind when specifiying options. Here are a couple of examples:
  * Invoke-AzurePSVerification
    * 1 second (if all prerequisites already met)
  * Invoke-AzurePSVerification -Latest
    * 35 seconds (if no components require an upgrade)
  * Invoke-AzurePSVerification -InstallNoInteraction -Latest
    * 2.55 minutes (if all components missing)