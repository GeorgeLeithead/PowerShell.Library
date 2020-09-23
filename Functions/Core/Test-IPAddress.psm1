#requires -Version 4.0

Function Test-IPAddress {
	<#
	.SYNOPSIS
		Test validity of an IP Address.
	.DESCRIPTION
		Test the validity of a supplied IP address.
	.PARAMETER IPAddress
		IP address of the touch point device
	.EXAMPLE
	PS> Test-IPAddress -IPAddress "10.11.12.14"

	This command tests if the string "10.11.12.14" is a valid IP address.
	.EXAMPLE
	PS> "10.11.12.14" | Test-IPAddress

	This command tests if the string "10.11.12.14" is a valid IP address.
	.EXAMPLE
	PS> "10.11.12.14","10.11.12.15" | Test-IPAddress

	This command tests if the string "10.11.12.14" and "10.11.12.15" are valid IP addresses.
	.EXAMPLE
	PS> if (Test-IPAddress "10.11.12.14X") {Write-Host "Is valid"} else {Write-Host "Is Invalid"}

	This command tests if the string "10.11.12.14X" is a valid IP address and then writes to the host the result of the test.
	.NOTES
	Author		: George Leithead - InternetWideWorld.com
	Last Updated: 23/09/2020
	.OUTPUTS
	IPAddress - A valid IP Address object; otherwise $false
	.LINK
	Get-CallerPreference
	#>


	[CmdletBinding(DefaultParameterSetName = 'Default', ConfirmImpact = 'Low')]
	[OutputType([IPAddress])]
	Param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0, HelpMessage = "You must supply the expected AMT IPV4 address for the device.")]
		[ValidateNotNullOrEmpty()]
		[Alias("IP", "Address", "Computer", "Device")]
		[System.String]$IPAddress
	)

	Begin {
		Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
		Write-Verbose "Starting $($MyInvocation.MyCommand)"
		Write-Verbose "Using parameter set $($PSCmdLet.ParameterSetName)"
	}

	Process {
		$IPAddress | ForEach-Object {
			Write-Verbose "Testing IP Address $_"
			try {
				[IPAddress]$_
			}
			catch {
				return $false
			}
		}
	}

	End {
		Write-Verbose "Ending $($MyInvocation.MyCommand)"
	}
} # function Test-IPAddress