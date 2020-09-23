#requires -Version 4.0

Function Invoke-BalloonTip {
	<#
	.SYNOPSIS
		Display a balloon tip
	.DESCRIPTION
		Display a user-defined message as a balloon pop-up in the system tray.
	.PARAMETER Message
		A short message text to display within the balloon.
	.PARAMETER Title
		The title of the balloon.
	.PARAMETER MessageType
		The type of message.  It indicates the type of icon to display in the balloon.  Values are "Info" (default), "Error", "Warning", "None".
	.PARAMETER SysTrayIcon
		Path to a file to use as the system tray.  Default is the PowerShell ISE icon.
	.PARAMETER Duration
		Number of milliseconds to display the balloon.  Default is 1000.
	.EXAMPLE
		PS> Invoke-BalloonTip
	.INPUTS
		None
	.OUTPUTS
		None
	.NOTES
		Author		: George Leithead - InternetWideWorld.com
		Last Updated: 23/09/2020
	.LINK
	Get-CallerPreference
	Register-ObjectEvent
	UnRegister-Event
	Remove-Job
	Get-Process
	#>
	[CmdletBinding(DefaultParameterSetName = "Default")]
	Param(
		[Parameter(Mandatory = $true, Position = 0, HelpMessage = "You must supply a message to display within the balloon.")]
		[ValidateNotNullOrEmpty()]
		[System.String]$Message,

		[Parameter(Mandatory = $false, Position = 1, HelpMessage = "Please supply a title for the balloon.")]
		[System.String]$Title = "Attention $ENV:USERNAME",

		[Parameter(Mandatory = $false, Position = 2, HelpMessage = "Please supply a message type. Values are 'Info','Error','Warning','None'")]
		[System.Windows.Forms.ToolTipIcon]$MessageType = "Info",

		[Parameter(Mandatory = $false, Position = 3, HelpMessage = "Please provide a path to a file to use as the system tray.")]
		[ValidateScript( { Test-Path $_ -PathType Leaf })]
		[System.String]$SysTrayIconPath = "C:\Windows\System32\WindowsPowerShell\V1.0\PowerShell.exe",

		[Parameter(Mandatory = $false, Position = 4, HelpMessage = "Please provide a duration (in milliseconds) to display the balloon.")]
		[System.Int32]$Duration = 1000

	)

	Begin {
		Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
		Write-Verbose "Starting $($MyInvocation.MyCommand)"
		Write-Verbose "Using parameter set $($PSCmdLet.ParameterSetName)"
		Add-Type -AssemblyName System.Windows.Forms
	}

	Process {
		Write-Verbose "Processing Balloon"
		if (-not $Global:Balloon) {
			$Global:Balloon = New-Object System.Windows.Forms.NotifyIcon
			[Void](Register-ObjectEvent -InputObject $Global:Balloon -EventName MouseDoubleClick -SourceIdentifier IconClicked -Action {
					Write-Verbose "Disposing of balloon"
					$Global:Balloon.Dispose()
					UnRegister-Event -SourceIdentifier IconClicked
					Remove-Job -Name IconClicked
					Remove-Variable -Name Balloon -Scope Global
				})
		}

		$Global:Balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($SysTrayIconPath)
		$Global:Balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]$MessageType
		$Global:Balloon.BalloonTipText = $Message
		$Global:Balloon.BalloonTipTitle = $Title
		$Global:Balloon.Visible = $true
		$Global:Balloon.ShowBalloonTip($Duration)
	}

	End {
		Write-Verbose "Ending $($MyInvocation.MyCommand)"
	}
} # function Invoke-BalloonTip