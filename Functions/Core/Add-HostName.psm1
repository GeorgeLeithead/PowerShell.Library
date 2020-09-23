#requires -Version 4.0

Function Add-HostName {
	<#
	.Synopsis
	   Add a host name to hosts file
	.DESCRIPTION
	   Add a host name to the HOSTS file on the current computer
	.EXAMPLE
	   Add-HostName -HostName "www.internetwideworld.com	51.141.12.112"

	This command adds to the host file and mapping for the host name "www.internetwideworld.com" to the IP address of "51.141.12.112"
	.INPUTS
	   None
	.OUTPUTS
	   None
	.NOTES
	Author	: George Leithead - InternetWideWorld.com
	Created	: 23/09/2020
	.LINK
	Get-CallerPreference
	#>

	[CmdletBinding(DefaultParameterSetName = 'Default', SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
	param (
		[Parameter(Mandatory = $true)]
		[System.String]$HostName
	)

	Begin {
		Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
		Write-Verbose "Starting $($MyInvocation.MyCommand)"
		Write-Verbose "Using parameter set $($PSCmdLet.ParameterSetName)"
		$HostsLocation = "$env:windir\System32\drivers\etc\hosts"
	}
	
	Process {
		Write-Verbose "Adding host name to HOSTS file"
		if ((Get-Content $HostsLocation) -contains $HostName) {
			Write-Verbose "HOSTS file already contains an entry for $HostName"
		}
		else {
			Write-Verbose "Adding entry for $HostName to HOSTS file"
			Add-Content -Path $HostsLocation -Value $HostName
		}
	}

	End {
		Write-Verbose "Ending $($MyInvocation.MyCommand)"
	}
} # function Add-HostName