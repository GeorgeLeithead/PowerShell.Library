#requires -Version 2.0

Function Update-SCCMPolicyRetrieval {
	<#
	.SYNOPSIS
	Update the DDR
	.DESCRIPTION
	Trigger an update schedule for policy retrieval
	.EXAMPLE
	Update-SCCMDiscoveryInventory

	This command triggers an update schedule for the policy retrieval on the current device, via the SCCM client.
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
		Write-Verbose "Re-Run Policy retrieval as the default policy retrieval is 60 minutes"
		Start-process WMIC "/namespace:\\root\ccm path sms_client CALL TriggerSchedule `"{00000000-0000-0000-0000-000000000021}`" /NOINTERACTIVE"
	}

	End {
		Write-Verbose "Ending $($MyInvocation.MyCommand)"
	}
} # function Update-SCCMPolicyRetrieval