---
external help file: AzurePS-V-help.xml
Module Name: AzurePS-V
online version:
schema: 2.0.0
---

# Invoke-AzurePSVerification

## SYNOPSIS
Verifies the local system is capable of running AzureRM PowerShell and is capable of taking corrective actions to ensure all prerequisites for Azure PowerShell are in place. AzureRM cmdlets can also be scoped to a specific Azure subscription.

## SYNTAX

```
Invoke-AzurePSVerification [-InstallNoInteraction] [-Latest] [[-SubscriptionID] <String>] [<CommonParameters>]
```

## DESCRIPTION
Evaluates the local system to determine that all prerequisites are met to successfully run Azure RM PowerShell commands.

**Prerequisites**
* NuGet installed
* PowerShellGet module installed
* Azure PowerShell module instaled

Any prerequisites found missing will be installed automatically if the [-InstallNoInteraction] parameter is specified, otherwise confirmation prompts are presented to the user for each missing component.

If the [-Latest] parameter is provided each component will be evaluated to determine if there is a higher version number available from its respective public repository.  If used in conjunction with the [-InstallNoInteraction] parameter the latest version will automatically be installed, otherwise confirmation prompts are presented to the user for each upgrade.

Once all requirements are met, Azure RM commands can be scoped to a specific Azure subscription with use of the [[-SubscriptionID] <String>] parameter. The specified Azure Subscription ID will be verified, and the user will be prompted for credentials to authenticate to that subscription if not currently active. Once authenticated, the provided ID will be set to the primary context for Azure RM commands.

## EXAMPLES

### EXAMPLE 1
```
Invoke-AzurePSVerification
```
Evaluates prerequisites for Azure Powershell. If any are found missing, user is prompted to install them. Returns boolean value indicating if system is ready to run Azure PowerShell.

### EXAMPLE 2
```
Invoke-AzurePSVerification -Verbose
```
Evaluates prerequisites for Azure Powershell. If any are found missing, user is prompted to install them. Returns boolean value indicating if system is ready to run Azure PowerShell. A detailed verbose output is provided which gives the end user insight into what actions are being performed.

### EXAMPLE 3
```
Invoke-AzurePSVerification -Latest
```
Evaluates prerequisites for Azure Powershell. If any are found missing, user is prompted to install them. Each component is also evaluated to determine if there is a higher version number available from its respective public repository. If a higher version is found, the user will be prompted to install the latest version. Returns boolean value indicating if system is ready to run Azure PowerShell. If the user elects not to install the latest version, this does not fail the evaluation, only warnings are provided.

### EXAMPLE 4
```
Invoke-AzurePSVerification -InstallNoInteraction
```
Evaluates prerequisites for Azure Powershell. If any are found missing, they will be automatically installed. Returns boolean value indicating if system is ready to run Azure PowerShell.

### EXAMPLE 5
```
Invoke-AzurePSVerification -InstallNoInteraction -Latest
```
Evaluates prerequisites for Azure Powershell. If any are found missing, they will be automatically installed. Each component is also evaluated to determine if there is a higher version number available from its respective public repository. If a higher version is found, it will be automatically installed. Returns boolean value indicating if system is ready to run Azure PowerShell.

### EXAMPLE 6
```
Invoke-AzurePSVerification -SubscriptionID "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```
Evaluates prerequisites for Azure Powershell. If any are found missing, user is prompted to install them. The provided Azure Subscription ID will then be evaluated. If that ID is not currently available the user is prompted for authentication. Once authenticated and available the specified ID will be set as the primary context for Azure RM commands. Returns boolean value indicating if system is ready to run Azure PowerShell - and run it in the context of the provided Azure Subscription ID.

### EXAMPLE 7
```
Invoke-AzurePSVerification -InstallNoInteraction -Latest -SubscriptionID "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```
Evaluates prerequisites for Azure Powershell. If any are found missing, they will be automatically installed. Each component is also evaluated to determine if there is a higher version number available from its respective public repository. If a higher version is found, it will be automatically installed. The provided Azure Subscription ID will then be evaluated. If that ID is not currently available the user is prompted for authentication. Once authenticated and available the specified ID will be set as the primary context for Azure RM commands. Returns boolean value indicating if system is ready to run Azure PowerShell - and run it in the context of the provided Azure Subscription ID.

## PARAMETERS

### -InstallNoInteraction
Removes user prompt confirmations. Prerequisites will be installed automatically - with no user involvement.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Latest
Enables evaluation of all components to determine if there is a higher version number available from their respective public repository.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SubscriptionID
Azure subscription ID you wish to connect to and set context for.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Boolean

## NOTES
Author: [Jake Morrison](https://twitter.com/JakeMorrison) - http://techthoughts.info

Contributor: [Lyon Till](https://twitter.com/LJTill)

Testers: [Justin Saylor](https://twitter.com/XJustinSaylorX)

*Pointers*
* If you specify a Subscription ID the overall true/false return will be impacted. The Subscription ID will be treated as a required prerequisite and if it can't be set, will fail the overall check.
* Keep time impact in mind when specifiying options. Here are a couple of examples:
  * Invoke-AzurePSVerification
    * 1 second (if all prerequisites already met)
  * Invoke-AzurePSVerification -Latest
    * 35 seconds (if no components require an upgrade)
  * Invoke-AzurePSVerification -InstallNoInteraction -Latest
    * 2.55 minutes (if all components missing)

## RELATED LINKS
