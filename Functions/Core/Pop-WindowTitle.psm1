#requires -Version 4.0

Function Pop-WindowTitle {
	<#
	.SYNOPSIS
	Function to reset the window title.

	.DESCRIPTION
	The old window title is recalled from a stack previously set using the Push-WindowTitle command.

	.EXAMPLE
	PS> Pop-WindowTitle
	.NOTES
	Author	: George Leithead - InternetWideWorld.com
	Created	: 23/09/2020
	.LINK
	Push-WindowTitle
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
		Write-Verbose "Popping the window title"
		if ($Global:WindowTitleStack -is [Collections.Stack] -AND $Global:WindowTitleStack.Count -ge 1) {
			$Host.UI.RawUI.WindowTitle = $Global:WindowTitleStack.Pop()
		}
	}

	End {
		Write-Verbose "Ending $($MyInvocation.MyCommand)"
	}
} # function Pop-WindowTitle
