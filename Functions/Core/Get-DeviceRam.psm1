#requires -Version 4.0

Function Get-DeviceRam {
	<#
	.SYNOPSIS
		Get device RAM
	.DESCRIPTION
		Get the total physical RAM installed on the device.
	.EXAMPLE
		PS> Get-DeviceRam

	This command gets the total physical RAM installed on the device.
	.OUTPUTS
		System.String.  The amount of RAM in GB installed in the device
	.NOTES
	Author	: George Leithead - InternetWideWorld.com
	Created	: 23/09/2020
	.LINK
	Get-CallerPreference
	#>


	[CmdletBinding(DefaultParameterSetName = 'Default', ConfirmImpact = 'Low')]
	Param()

	Begin {
		Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
		Write-Verbose "Starting $($MyInvocation.MyCommand)"
		Write-Verbose "Using parameter set $($PSCmdLet.ParameterSetName)"
		[System.UInt64]$TotalRam = 0
	}

	Process {
		try {
			$RamObject = Get-WmiObject Win32_PhysicalMemory -ErrorAction Stop
			if ($null -eq $RamObject) {
				return [System.String]::Empty
			}

			[System.UInt64]$TotalRam = 0
			ForEach ($PhysicalMemory in $RamObject) {
				$TotalRam = $TotalRam + $PhysicalMemory.Capacity
			}

			return $TotalRam / 1GB
		}
		catch {
			throw $_
		}

		return [System.String]::Empty
	}

	End {
		Write-Verbose "Ending $($MyInvocation.MyCommand)"
	}
} # function Get-DeviceRam