#requires -Version 4.0

Function Push-LogFile {
	<#
	.SYNOPSIS
	Function to set the LogFile variable to a new value.

	.DESCRIPTION
	Set the LogFile variable to a new value, and push the old value in a stack to be recalled later using the Pop-LogFile command.

	.PARAMETER Path
	The new log file path.

	.EXAMPLE
	PS> Push-LogFile -Path "C:\Logs\NewLog23.log"

	This command set the logFile variable to "C:\Logs\NewLog23.log" and pushed the previous value into the stack to be recalled later using the Pop-LogFile command.
	.NOTES
	Author	: George Leithead - InternetWideWorld.com
	Created	: 23/09/2020
	.LINK
	Pop-LogFile
	Get-CallerPreference
	#>


	[CmdletBinding(DefaultParameterSetName = 'Default', ConfirmImpact = 'Low')]
	Param
	(
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[IO.FileInfo]$Path
	)

	Begin {
		Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
		Write-Verbose "Starting $($MyInvocation.MyCommand)"
		Write-Verbose "Using parameter set $($PSCmdLet.ParameterSetName)"
	}

	Process {
		Write-Verbose "Pushing the log file"
		if ($Global:LogFileStack -isnot [Collections.Stack]) { $Global:LogFileStack = New-Object Collections.Stack }

		# --- Save the current logfile
		$Global:LogFileStack.Push($Global:LogFile)

		# --- Set the new logfile
		$Global:LogFile = $Path.FullName
	}

	End {
		Write-Verbose "Ending $($MyInvocation.MyCommand)"
	}
} # function Push-LogFile