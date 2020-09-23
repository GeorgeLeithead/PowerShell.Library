#requires -Version 4.0

Function Invoke-LogInAsAnotherUser {
	<#
	.SYNOPSIS
	Log on as another user
	.DESCRIPTION
	Disable automatic log on, and then log off to get the user to the Logon screen.
	.EXAMPLE
	PS> Invoke-LogInAsAnotherUser -Any

	This command disabled the automatic logon of the set automatic logon user and logs off the current user, thus allowing another user to logon.
	.EXAMPLE
	PS> Invoke-LogInAsAnotherUser

	This command enables the automatic logon of the set automatic logon user and logs off the current user, thus logging on as the set automatic logon user.
	.NOTES
	Author	: George Leithead - InternetWideWorld.com
	Created	: 23/09/2020
	.LINK
	Get-CallerPreference
#>

 
	[CmdletBinding(DefaultParameterSetName = 'Default', SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
	Param(
		[Switch]$Any
	)

	Begin {
		Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
		Write-Verbose "Starting $($MyInvocation.MyCommand)"
		Write-Verbose "Using parameter set $($PSCmdLet.ParameterSetName)"
	}

	Process {
		if ($Any) {
			Write-Verbose "Disable auto logon for user"
			New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon" -Value 0 -PropertyType DWORD -Force | Out-Null
		}
		else {
			Write-Verbose "Enabling auto logon for user"
			New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon" -Value 1 -PropertyType DWORD -Force | Out-Null
		}
		Write-Verbose "Logging Off"
		LogOff
	}

	End {
		Write-Verbose "Ending $($MyInvocation.MyCommand)"
	}
} # function Invoke-LogInAsAnotherUser