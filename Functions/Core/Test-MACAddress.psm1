#requires -Version 4.0

Function Test-MACAddress {
	<#
	.SYNOPSIS
	Test validity of a MAC Address
	.DESCRIPTION
	Test the validity of a supplied MAC Address
	.PARAMETER MACAddress
	MAC address to validate
	.PARAMETER Delimiter
	Change the delimiter of the MAC address
	.PARAMETER ConvertToUpperCase
	Switch indicating to convert the MAC address to upper case or not
	.EXAMPLE
	PS> Test-MACAddress -MACAddress "a1:b2:c3:d4:e5:f6"

	This command tests if the string "a1:b2:c3:d4:e5:f6" is a valid MAC address and returns any valid MAC address.
	.EXAMPLE
	PS> Test-MACAddress -MACAddress "a1:b2:c3:d4:e5:f6" -Delimiter "-"

	This command tests if the string "a1:b2:c3:d4:e5:f6" is a valid MAC address and returns any valid MAC address object using "-" as a delimiter.
	.EXAMPLE
	PS> Test-MACAddress -MACAddress "a1:b2:c3:d4:e5:f6" -Delimiter $null

	This command tests if the string "a1:b2:c3:d4:e5:f6" is a valid MAC address and returns any valid MAC address object removing all delimiters.
	.EXAMPLE
	PS> Test-MACAddress -MACAddress "a1:b2:c3:d4:e5:f6" -ConvertToUppercase

	This command tests if the string "a1:b2:c3:d4:e5:f6" is a valid MAC address and returns any valid MAC address in upper case.
	.EXAMPLE
	PS> "a1:b2:c3:d4:e5:f6","1a:2b:3c:4d:5e:6f" | Test-MACAddress

	This command tests if the strings "a1:b2:c3:d4:e5:f6" and "1a:2b:3c:4d:5e:6f" are valid MAC addresses and returns any valid MAC addresses.
	.EXAMPLE
	PS> if (Test-MacAddress -MACAddress "a1:b2:c3:d4:e5:X6") {Write-Host "Is Valid"} else {Write-Host "Is Invalid"}

	This command tests if the string "a1:b2:c3:d4:e5:X6" is a valid MAC address and then writes to the host the result of the test.
	.NOTES
	Author		: George Leithead - InternetWideWorld.com
	Last Updated: 23/09/2020
	.INPUTS
	System.String[]. MAC addresses to validate
	.OUTPUTS
	System.String. The valid MAC address; otherwise $false
	.LINK
	Get-CallerPreference
	#>


	[CmdletBinding(DefaultParameterSetName = "Default")]
	[OutputType([System.String])]
	Param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0, HelpMessage = "You must supply a MAC address to validate")]
		[ValidateNotNullOrEmpty()]
		[Alias("MAC")]
		[System.String]$MACAddress,

		[Parameter(Mandatory = $false, Position = 1, HelpMessage = "Provide the character to change the delimiter of the MAC Address")]
		[ValidateSet(":", "-", ".", $null)]
		[System.String]$Delimiter = ":",

		[Parameter(Mandatory = $false, Position = 2, HelpMessage = "Switch to convert any characters to uppercase")]
		[Switch]$ConvertToUppercase = $false
	)

	Begin {
		Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
		Write-Verbose "Starting $($MyInvocation.MyCommand)"
		Write-Verbose "Using parameter set $($PSCmdLet.ParameterSetName)"
		[System.Array]$Patterns = @(
			'^([0-9a-f]{2}:){5}([0-9a-f]{2})$'
			'^([0-9a-f]{2}-){5}([0-9a-f]{2})$'
			'^([0-9a-f]{4}.){2}([0-9a-f]{4})$'
			'^([0-9a-f]{12})$'
		)
	}

	Process {
		$MACAddress | ForEach-Object {
			Write-Verbose "Testing MAC Address $_"
			if ($_ -match ($Patterns -join '|')) {
				Write-Verbose "The MAC address is valid"
				$RawAddress = $_ -replace '\W'
				switch ($Delimiter) {
					{ $_ -match ':|-' } {
						for ($i = 2; $i -le 14; $i += 3) {
							$result = $RawAddress = $RawAddress.Insert($i, $_)
						}

						break
					}

					'.' {
						for ($i = 4; $i -le 9; $i += 5) {
							$result = $RawAddress = $RawAddress.Insert($i, $_)
						}
					}

					default {
						$result = $RawAddress
					}
				}

				if ($ConvertToUppercase) {
					return $result.ToUpper()
				}
				else {
					return $result
				}
			}
			else {
				Write-Verbose "The MAC Address is invalid!"
				return $false
			}
		}
	}

	End {
		Write-Verbose "Ending $($MyInvocation.MyCommand)"
	}
} # function Test-MACAddress