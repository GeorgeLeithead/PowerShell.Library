#requires -Version 4.0

Function Push-WindowTitle {
	<#
	.SYNOPSIS
	Function to set the window title.

	.DESCRIPTION
	Set the window title to a new value, and push the old value in a stack to be recalled later using the Pop-WindowTitle command.

	.PARAMETER Title
	The new window title.

	.EXAMPLE
	PS> Push-WindowTitle -Title "Running Copy Files"

	This command sets with window title to "Running Copy Files", and pushes the previous window title into a stack to be recalled later using the Pop-WindowTitle command.
	.NOTES
	Author	: George Leithead - InternetWideWorld.com
	Created	: 23/09/2020
	.LINK
	Pop-WindowTitle
	Get-CallerPreference
	#>


	[CmdletBinding(DefaultParameterSetName = 'Default', ConfirmImpact = 'Low')]
	Param
	(
		[Parameter(Mandatory = $true, HelpMessage = "Pleas supply the window title")]
		[ValidateNotNullOrEmpty()]
		[String]$Title
	)

	Begin {
		Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
		Write-Verbose "Starting $($MyInvocation.MyCommand)"
		Write-Verbose "Using parameter set $($PSCmdLet.ParameterSetName)"
	}

	Process {
		Write-Verbose "Pushing the window title"
		# --- Create a new stack if this is the first run
		if ($Global:WindowTitleStack -isnot [Collections.Stack]) {
			$Global:WindowTitleStack = New-Object Collections.Stack
		}

		# --- Save the current title
		$Global:WindowTitleStack.Push($Host.UI.RawUI.WindowTitle)

		# --- Set the new title
		$Host.UI.RawUI.WindowTitle = $Title
	}

	End {
		Write-Verbose "Ending $($MyInvocation.MyCommand)"
	}
} # function Push-WindowTitle