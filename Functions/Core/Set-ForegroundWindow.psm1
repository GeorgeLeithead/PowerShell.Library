#requires -Version 4.0

Function Set-ForegroundWindow {
	<#
	.SYNOPSIS
	Set foreground window
	.DESCRIPTION
	Bring any process window into the foreground.
	.PARAMETER Process
	An active windows process.
	.PARAMETER Maximise
	A switch to maximise the process window; otherwise leave as is.
	.EXAMPLE
	Set-ForegroundWindow -Process $proc

	This command brings the process $proc into the foreground.
	.EXAMPLE
	Set-ForegroundWindow -Process $proc -Maximise

	This command brings the process $proc into the foreground and maximises the process window.
	.OUTPUTS
	None
	.NOTES
	Author	: George Leithead - InternetWideWorld.com
	Created	: 23/09/2020
	.LINK
	Get-CallerPreference
#>
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory = $true, HelpMessage = "You must provide a running windows process.")]
		[ValidateNotNullOrEmpty()]
		[System.ComponentModel.Component]$Process,

		[Parameter()]
		[Switch]$Maximise
	)

	Begin {
		Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
		Write-Verbose "Starting $($MyInvocation.MyCommand)"
		Write-Verbose "Using parameter set $($PSCmdLet.ParameterSetName)"
		$Sig = '
			[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
			[DllImport("user32.dll")] public static extern int SetForegroundWindow(IntPtr hWnd);
		'
		[System.Int16]$Mode = 4
	}

	Process {
		Write-Verbose "Setting foreground window to $Process"
		if ($Maximise) {
			$Mode = 3
		}

		$Type = Add-Type -MemberDefinition $Sig -Name WindowApi -PassThru
		$hWnd = $Process.MainWindowHandle
		$null = $Type::ShowWindowAsync($hWnd, $Mode)
		$null = $Type::SetForegroundWindow($hWnd)
	}

	End {
		Write-Verbose "Ending $($MyInvocation.MyCommand)"
	}

} # function Set-ForegroundWindow