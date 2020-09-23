###########################################################################
#
#  This script holds variables used in script operations
#  It is executed in the users session during the import of the module
#
#  This script should also hold the definitions of any functions that need to be run within
#  the session scope 0 and cannot therefore be included within a child .psm1 file
#
#  For example, the $error variable is only available from the top level scope 0
#  Therefore, any functions that references the $error variable cannot live in a .psm1 file
#
###########################################################################

# ---------------------------------------------------------------------------------

# --- Define global functions
Function Global:Clear-Errors
{
	<#
		.SYNOPSIS
		Function to clear the $Error variable.
	#>
	$Error.Clear()
}

Function Global:Confirm-PSSnapin
{
	<#
		.SYNOPSIS
		Function to wrap the Add-PSSnapin command and load a PSSnapin.

		.DESCRIPTION
		If the snapin is already loaded, no action is taken.

		.PARAMETER PSSnapin
		Name of the PSSnapin

		.INPUTS
		None. You cannot pipe objects to Confirm-PSSnapin.

		.OUTPUTS
		None.

		.EXAMPLE
		PS> Confirm-PSSnapin -PSSnapin VMware.VimAutomation.Core

		.NOTES
	#>
	[CmdletBinding()]
	Param
	(
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[String]$PSSnapin
	)
	$ErrorActionPreference = 'Stop'
	Write-Debug $MyInvocation.MyCommand.Name
	
	try
	{
		Write-Verbose "Confirming PSSnapin '$PSSnapin'"
		$AllPSSnapins = @(Get-PSSnapin -Registered | Select-Object -ExpandProperty Name)
		$LoadedPSSnapins = @(Get-PSSnapin | Select-Object -ExpandProperty Name)

		if ($AllPSSnapins -NotContains $PSSnapin) {throw "The PSSnapin is not registered on this machine"}
		if ($LoadedPSSnapins -NotContains $PSSnapin)
		{
			Write-Host "Loading PSSnapin '$PSSnapin'..."
			Add-PSSnapin -Name $PSSnapin -WarningAction 0
		}
		else
		{
			Write-Verbose "PSSnapin '$PSSnapin' is already loaded"
		}
	}
	catch
	{
		throw "Failed to Add PSSnapin '$PSSnapin'"
	}
}

Function Global:Exit-Error
{
	<#
		.SYNOPSIS
		Function to exit a failed script run.

		.DESCRIPTION
		Logs a message and exits with an exit code 1.

		.PARAMETER ExitMessage
		The text of the information to log.

		.EXAMPLE
		PS> Exit-Error "This script failed because ..."
	#>
	Param
	(
		[Parameter()]
		[String]$ExitMessage = "Script Failed: $(Get-Date)"
	)
	Write-Error $ExitMessage -EA 0
	Write-Host "`n**************************************************`n"
	Write-Host -F White -B Red "Process Errors:"
	Show-Errors
	Write-Host "`n**************************************************`n"
	Pop-Location
	#Exit 1
	[System.Environment]::Exit(1)
}

Function Global:Exit-Success
{
	<#
		.SYNOPSIS
		Function to exit a successful script run.

		.DESCRIPTION
		Logs a message and exits with an exit code 0.

		.PARAMETER ExitMessage
		The text of the information to log.

		.EXAMPLE
		PS> Exit-Success "Everything was OK"
	#>
	Param
	(
		[Parameter(Mandatory=$false)]
		[String]$ExitMessage = "Script Completed OK: $(Get-Date)"
	)
	Write-Host `n$ExitMessage
	Pop-Location
	#Exit 0
	[System.Environment]::Exit(0)
}

Function Global:Show-Errors
{
	<#
		.SYNOPSIS
		Function to display a list of errors in the $Error variable.

		.DESCRIPTION
		Function to display a list of errors in the $Error variable.

		.EXAMPLE
		PS> Show-Errors
	#>
	Param
	(
		[Parameter()]
		[Switch]$ReturnObject
	)
	$ErrorStrings = @($Error | ForEach-Object {[String]$_})
	if ($ReturnObject) {return $ErrorStrings} else {$ErrorStrings | Out-Host}
}

# --- Defined global variables
Set-Variable -Name LogPath -Value 'C:\Post_Install\Logs' -Option ReadOnly,AllScope -Scope Global -Force
Set-Variable -Name AttemptsMax -Value 30 -Option ReadOnly,AllScope -Scope Global -Force
Set-Variable -Name Delay -Value 30 -Option ReadOnly,AllScope -Scope Global -Force