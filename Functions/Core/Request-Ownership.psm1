#requires -Version 4.0

Function Request-Ownership {
	<#
	.SYNOPSIS
	Request taking ACL ownership of a registry key
	.DESCRIPTION
	For the current user take ACL ownership of a registry sub key.
	.EXAMPLE
	PS> Request-Ownership -SubKey "SYSTEM\CurrentControlSet\Enum\usbcam"

	This command grants ownership of the registry key "SYSTEM\CurrentControlSet\Enum\usbcam" to the current user.
	.OUTPUTS
	None
	.NOTES
	Author	: George Leithead - InternetWideWorld.com
	Created	: 23/09/2020
	.LINK
	Get-CallerPreference
	Set-TokenPrivilege
	#>


	[CmdletBinding(DefaultParameterSetName = 'Default', ConfirmImpact = 'Low')]
	Param (
		[Parameter(Mandatory = $true, HelpMessage = "You must provide a sub key path.")]
		[ValidateNotNullOrEmpty()]
		[System.String]$Subkey
	)

	Begin {
		Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
		Write-Verbose "Starting $($MyInvocation.MyCommand)"
		Write-Verbose "Using parameter set $($PSCmdLet.ParameterSetName)"
		$LocalSystemId = [System.Security.Principal.WellKnownSidType]::LocalSystemSid # Local system user
		$LocalSystem = New-Object System.Security.Principal.SecurityIdentifier($LocalSystemId, $null)
		$AdministratorsId = [System.Security.Principal.WellKnownSidType]::BuiltinAdministratorsSid # Local Administrators group
		$Administrators = New-Object System.Security.Principal.SecurityIdentifier($AdministratorsId, $null)
		Write-Verbose "Opening key $SubKey"
		$Key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($SubKey, [Microsoft.Win32.RegistryKeypermissionCheck]::ReadWriteSubTree, [System.Security.AccessControl.RegistryRights]::ChangePermissions)
		Set-TokenPrivilege SeTakeOwnershipPrivilege | Out-Null
	}

	Process {
		# Take ownership of registry key
		Write-Verbose "Taking ownership of key: $SubKey"
		$acl = $Key.GetAccessControl([System.Security.AccessControl.AccessControlSections]::None)
		Write-Verbose "Set owner to Local System"
		$acl.SetOwner($LocalSystem)
		Write-Verbose "Committing access control"
		$Key.SetAccessControl($acl)

		# Set registry key permissions
		Write-Verbose "Getting access control"
		$acl = $Key.GetAccessControl()
		$IsProtected = $true
		$PreserveInheritance = $false
		Write-Verbose "Setting access rule protection to Protected: $IsProtected, PreserveInheritance:$PreserveInheritance"
		$acl.SetAccessRuleProtection($IsProtected, $PreserveInheritance)
		Write-Verbose "Setting access rule for Local System to allow FullControl"
		$Rule = New-Object System.Security.AccessControl.RegistryAccessRule($LocalSystem, "FullControl", "Allow")
		$acl.SetAccessRule($rule)
		Write-Verbose "Setting access rule for Administrators Group to allow FullControl"
		$Rule = New-Object System.Security.AccessControl.RegistryAccessRule($Administrators, "FullControl", "Allow")
		$acl.SetAccessRule($rule)
		Write-Verbose "Committing access control"
		$Key.SetAccessControl($acl)
	}

	End {
		Write-Verbose "Ending $($MyInvocation.MyCommand)"
		Write-Verbose "Closing key"
		$Key.Close()
	}
} # function Request-Ownership