#requires -Version 4.0

Function Set-WMINamespaceSecurity {
	<#
	.SYNOPSIS
	Set security descriptor of WMI name space.
	.DESCRIPTION
	Modify the current security descriptor of a WMI name space. 
	.PARAMETER UserName
	User name to set the WMI name-space security for.
	.PARAMETER UserDomain
	Users domain
	.EXAMPLE
	PS> Set-WMINamespaceSecurity -UserDomain stbc2.jstest2.net

	This command sets the WMI name space security to the local computer everyone.
	.OUTPUTS
	None.
	.NOTES
	Author	: George Leithead - InternetWideWorld.com
	Created	: 23/09/2020
	.LINK
	Get-CallerPreference
	#>
	[CmdletBinding(DefaultParameterSetName = "Default")]
	Param(
		[Parameter(Mandatory = $false, HelpMessage = "Provide a domain to set the WMI name-space security for.")]
		[System.String]$UserDomain = $ENV:USERDOMAIN
	)

	Begin {
		Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
		Write-Verbose "Starting $($MyInvocation.MyCommand)"
		Write-Verbose "Using parameter set $($PSCmdLet.ParameterSetName)"
		$CONTAINER_INHERIT_ACE_FLAG = 0x2
		$ACCESS_ALLOWED_ACE_TYPE = 0x0
		#$ACCESS_DENIED_ACE_TYPE = 0x1
		$Permissions = "Enable"
		$namespace = "root\ccm\Policy\Machine"
	}

	Process {
		$RemoteParams = @{ComputerName = $($ENV:COMPUTERNAME) }
		$InvokeParams = @{Namespace = $namespace; Path = "__systemsecurity=@" } + $RemoteParams
		Write-Verbose "Calling GetSecurityDescriptor"
		$output = Invoke-WmiMethod @InvokeParams -Name GetSecurityDescriptor
		$acl = $output.Descriptor
		$getparams = @{Class = "Win32_Account"; Filter = "Domain='$UserDomain' and Name='Everyone'" }
		Write-Verbose "Calling Win32_Account"
		$win32account = Get-WmiObject @getparams
		$accessMask = Get-AccessMaskFromPermission($permissions)
		Write-Verbose "Creating trustee"
		$trustee = (New-Object System.Management.ManagementClass("win32_Trustee")).CreateInstance()
		$trustee.SidString = $win32account.Sid
		Write-Verbose "Creating ACE"
		$ace = (New-Object System.Management.ManagementClass("win32_Ace")).CreateInstance()
		$ace.AccessMask = $accessMask
		$ace.AceFlags = $CONTAINER_INHERIT_ACE_FLAG
		$ace.Trustee = $trustee
		$ace.AceType = $ACCESS_ALLOWED_ACE_TYPE
		$acl.DACL += $ace.psobject.immediateBaseObject
		$SetParams = @{Name = "SetSecurityDescriptor"; ArgumentList = $acl.psobject.immediateBaseObject } + $InvokeParams
		Write-Verbose "*** Setting  SetSecurityDescriptor ***"
		$output = Invoke-WmiMethod @SetParams
	}

	End {
		Write-Verbose "Ending $($MyInvocation.MyCommand)"
	}
} # function Set-WMINamespaceSecurity