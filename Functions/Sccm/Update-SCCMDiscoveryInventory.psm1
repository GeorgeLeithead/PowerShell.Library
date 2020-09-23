#requires -Version 4.0

Function Update-SCCMDiscoveryInventory
{
<#
	.SYNOPSIS
	Update the DDR
	.DESCRIPTION
	Trigger an update schedule for the Discovery Inventory
	.EXAMPLE
	Update-SCCMDiscoveryInventory

	This command triggers an update schedule for the discovery inventory on the current device, via the SCCM client.
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


	[CmdletBinding(DefaultParameterSetName = 'Default', SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
	Param()

	Begin {
		Write-Verbose "Starting $($MyInvocation.MyCommand)"
		Write-Verbose "Using parameter set $($PSCmdLet.ParameterSetName)"
	}

	Process {
		Write-Verbose "Re-Run Discovery Inventory"
		Start-Process WMIC "/namespace:\\root\ccm path sms_client CALL TriggerSchedule `"{00000000-0000-0000-0000-000000000003}`" /NOINTERACTIVE"
	}

	End {
		Write-Verbose "Ending $($MyInvocation.MyCommand)"
	}
} # function Update-SCCMDiscoveryInventory