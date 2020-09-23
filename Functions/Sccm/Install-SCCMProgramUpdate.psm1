#requires -Version 4.0

Function Install-SCCMProgramUpdate {
	<#
	.SYNOPSIS
	Install or uninstall SCCM Program
	.DESCRIPTION
	Force install/uninstall of available software in software centre through CIM/WMI
	.EXAMPLE
	Install-SCCMProgramUpdate -AppName "Some App name" -Method Install

	This command installs the application name "Some App name" on the current device, via the SCCM client.
	.EXAMPLE
	Install-SCCMProgramUpdate -AppName "Some App name" -Method Uninstall

	This command uninstalls the application name "Some App Name" on the current device, via the SCCM client.
	.INPUTS
	None
	.OUTPUTS
	None
	.NOTES
	Author	: George Leithead - InternetWideWorld.com
	Created	: 23/09/2020
	.COMPONENT
	Get-CallerPreference
#>


	[CmdletBinding(DefaultParameterSetName = 'Default', ConfirmImpact = 'Low')]
	[OutputType([System.Boolean])]
	Param(
		[Parameter(Mandatory = $True, HelpMessage = "You must supply the application/package name.")]
		[ValidateNotNullOrEmpty()]
		[Alias("PKG_Name", "PKG", "ApplicationName")]
		[System.String]$AppName,

		[Parameter(Mandatory = $true, HelpMessage = "You must indicate if this is to install or uninstall the application.")]
		[ValidateSet("Install", "Uninstall")]
		[System.String]$Method
	)

	Begin {
		Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
		Write-Verbose "Starting $($MyInvocation.MyCommand)"
		Write-Verbose "Using parameter set $($PSCmdLet.ParameterSetName)"
	}

	Process {
		Write-Verbose "Performing $Method for application $AppName"
		[System.Management.ManagementBaseObject]$Application = $null
		While ($null -eq $Application) {
			try {
				$Application = Get-WmiObject -Class CCM_Program -Namespace "root\ccm\clientsdk" | Where-Object { $_.Name -like $AppName }
				$UI = New-Object -ComObject "UIResource.UIResourceMgr"
				$UI.ExecuteProgram($Application.ProgramID, $Application.PackageID, $true)
			}
			catch {
				$Application = $null
				Write-Verbose " - No matching adverts yet found for application $AppName"
				Start-Sleep -Seconds 30
			}
		}
	}

	End {
		Write-Verbose "Ending $($MyInvocation.MyCommand)"
	}
} # function Install-SCCMProgramUpdate