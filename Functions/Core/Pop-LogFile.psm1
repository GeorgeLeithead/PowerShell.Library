#requires -Version 4.0

Function Pop-LogFile {
	<#
	.SYNOPSIS
	Function to reset the LogFile variable to its previous value.

	.DESCRIPTION
	The old value is recalled from a stack previously set using the Push-LogFile command.

	.EXAMPLE
	PS> Pop-LogFile
	.LINK
	Push-LogFile
	.NOTES
	Author	: George Leithead - InternetWideWorld.com
	Created	: 23/09/2020
	.LINK
	Push-LogFile
	Get-CallerPreference
	#>


	[CmdletBinding(DefaultParameterSetName = 'Default', ConfirmImpact = 'Low')]
	Param ()

	Begin {
		Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
		Write-Verbose "Starting $($MyInvocation.MyCommand)"
		Write-Verbose "Using parameter set $($PSCmdLet.ParameterSetName)"
	}

	Process {
		Write-Verbose "Popping the log file"
		if ($Global:LogFileStack -is [Collections.Stack] -AND $Global:LogFileStack.Count -ge 1) { $Global:LogFile = $Global:LogFileStack.Pop() }
	}

	End {
		Write-Verbose "Ending $($MyInvocation.MyCommand)"
	}
} # function Pop-LogFile