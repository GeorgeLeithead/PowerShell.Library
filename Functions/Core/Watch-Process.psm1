#requires -Version 4.0

Function Watch-Process {
	<#
	.SYNOPSIS
	Watch a process
	.DESCRIPTION
	Watch for a process to be started
	.PARAMETER ProcessName
	The string name of the process to watch.
	.PARAMETER AttemptsMax
	Specifies the maximum number of attempts to make.
	.PARAMETER Delay
	Specifies the delay in seconds between attempts.
	.EXAMPLE
	Watch-Process -ProcessName "LiLo.Lite.UWP" -MaxAttempts 10 -Delay 60

	This command watches for the process named "LiLo.Lite.UWP" to start, and makes 10 attempts with a delay of 60 seconds between attempts.
	.OUTPUTS
	Boolean. Value indicating whether a process has started.
	.NOTES
	Author	: George Leithead - InternetWideWorld.com
	Created	: 23/09/2020
	.LINK
	Get-CallerPreference
	#>


	[CmdletBinding(DefaultParameterSetName = 'Default', ConfirmImpact = 'Low')]
	[OutputType([System.Boolean])]
	Param(
		[Parameter(Mandatory = $true, HelpMessage = "You must provide a process name.")]
		[ValidateNotNullOrEmpty()]
		[System.String]$ProcessName,

		[Parameter(Mandatory = $false, HelpMessage = "Please supply the maximum number of attempts.")]
		[System.Int32]$AttemptsMax = $Global:AttemptsMax,

		[Parameter(Mandatory = $false, Helpmessage = "Please supply the delay (in seconds) between attempts")]
		[System.Int32]$Delay = $Global:Delay
	)

	Begin {
		Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
		Write-Verbose "Starting $($MyInvocation.MyCommand)"
		Write-Verbose "Using parameter set $($PSCmdLet.ParameterSetName)"
		[System.Int32]$AttemptsMade = 0
		[System.Boolean]$Started = $false
	}

	Process {
		Do {
			$Status = Get-Process $ProcessName -ErrorAction SilentlyContinue
			if (!($Status)) {
				Write-Host "$(Get-Date -f s): Waiting for process $ProcessName"
				Start-Sleep -Seconds 5
				$AttemptsMade++
			}
			else {
				Write-Host "$(Get-Date -f s): Process started $ProcessName"
				$Started = $true
			}
		} until ($Started -or $AttemptsMade -gt $AttemptsMax)
	}

	End {
		Write-Verbose "Ending $($MyInvocation.MyCommand)"
		if ($AttemptsMade -ge $AttemptsMax) {
			throw "$ProcessName has not started within the expected period."
		}

		return $Started
	}

} # function Watch-Process