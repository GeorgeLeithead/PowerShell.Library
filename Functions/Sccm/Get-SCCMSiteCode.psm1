#requires -Version 4.0

Function Get-SCCMSiteCode {
	<#
	.SYNOPSIS
	Get SCCM site code
	.DESCRIPTION
	Get the SCCM default site code for a provider location.
	.EXAMPLE
	Get-SCCMSiteCode

	This command gets the default SCCM site code from the local connection
	.INPUTS
	None
	.OUTPUTS
	System.String - SCCM Site code
	.NOTES
	Author	: George Leithead - InternetWideWorld.com
	Created	: 23/09/2020
	.LINK
	Get-CallerPreference
#>
 
	[CmdletBinding(DefaultParameterSetName = 'Default', ConfirmImpact = 'Low')]
	[OutputType([System.String])]
	Param()

	Begin {
		Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
		Write-Verbose "Starting $($MyInvocation.MyCommand)"
		Write-Verbose "Using parameter set $($PSCmdLet.ParameterSetName)"
		[HashTable]$SccmSiteCode = @{
			NameSpace = "root\ccm"
			Class     = "SMS_Authority"
		} # HashTable for Get-WmiObject
	}

	Process {
		Write-Verbose "Getting default SCCM site code"
		$SmsAuthority = Get-WmiObject @SccmSiteCode #Splat the HashTable for Get-WmiObject
	}

	End {
		Write-Verbose "Ending $($MyInvocation.MyCommand)"
		return $SmsAuthority.Name.Remove(0, 4)
	}
} #function Get-SCCMSiteCode