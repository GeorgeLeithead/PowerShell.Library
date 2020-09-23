#requires -Version 4.0

Function Remove-SCCMDeviceFromCollection {
	<#
	.SYNOPSIS
	Remove device from a collection
	.DESCRIPTION
	Remove a device from a SCCM collection.
	.PARAMETER SmsProvider
	Name of the SCCM Server.
	.PARAMETER PrimarySccm
	Primary SCCm site code.
	.PARAMETER CollectionId
	Specifies the SCCM collection identifier to add the resource to.
	.PARAMETER ResourceId
	Specifies the SCCM resource identifier for a device.
	.PARAMETER Credential
	Authentication credentials to the SCCM server
	.EXAMPLE
	Remove-DeviceFromCollection -SmsProvider sccmserver01.internetwideworld.com -PrimarySccm IWW01 -ResourceId 123456 -CollectionId 1234

	This command removes the device with the resource identifier 123456 from the collection with identifier 1234, from the SCCM server "sccmserver01.internetwideworld.com" and the site code "IWW01".
	.INPUTS
	None
	.OUTPUTS
	None.
	.NOTES
	Author	: George Leithead - InternetWideWorld.com
	Created	: 23/09/2020
	.LINK
	Get-CallerPreference
	Get-SCCMResourceId
#>
 
	[CmdletBinding(DefaultParameterSetName = 'Default', ConfirmImpact = 'Low')]
	Param(
		[Parameter(Mandatory = $true, HelpMessage = "You must supply the SMS Provider")]
		[ValidateNotNullOrEmpty()]
		[Alias("SCCMServer", "Server")]
		[System.String]$SmsProvider,
		
		[Parameter(Mandatory = $true, HelpMessage = "You must supply the primary SCCM")]
		[ValidateNotNullOrEmpty()]
		[Alias("Site", "SiteCode", "PrimarySiteCode")]
		[System.String]$PrimarySCCM,

		[Parameter(Mandatory = $true, HelpMessage = "You must supply a SCCM collection object")]
		[System.Management.ManagementBaseObject]$Collection,

		[Parameter(Mandatory = $true, HelpMessage = "You must supply a device name")]
		[Alias("ComputerName", "Device", "Computer")]
		[System.String]$Device,

		[Parameter(Mandatory = $false, HelpMessage = "Pleas supply authentication credentials")]
		[Parameter(ParameterSetName = "SearchByComputerName")]
		[System.Management.Automation.PSCredential]$Credential = $null
	)

	Begin {
		Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
		Write-Verbose "Starting $($MyInvocation.MyCommand)"
		Write-Verbose "Using parameter set $($PSCmdLet.ParameterSetName)"
		[HashTable]$RuleParams = @{
			ComputerName = $SmsProvider
			NameSpace    = "root\sms\site_$($PrimarySCCM)"
			Class        = "SMS_CollectionRuleDirect"
		} # HashTable for SMS_CollectionRuleDirect
		[HashTable]$DeviceParams = @{
			SmsProvider = $SmsProvider
			PrimarySCCM = $PrimarySCCM
			Device    = $Device
		} # HashTable for Get-SCCMDevice
	}

	Process {
		if ($null -eq $Credential) {
			$RuleParams.Add("Credential", $Credential)
			$DeviceParams.Add("Credential", $Credential)
		}

		$RuleClass = Get-WmiObject -list @RuleParams # Splat the HashTable for SMS_CollectionRuleDirect
		$ResourceId = (Get-SCCMDevice @DeviceParams).ResourceID # Splat the HashTable for Get-SCCMDevice
		$NewRule = $RuleClass.CreateInstance()
		$NewRule.RuleName = $Device
		$NewRule.ResourceClassName = "SMS_R_SYSTEM"
		$NewRule.ResourceID = [System.String]$ResourceId
		$Null = $Collection.DeleteMembershipRule($NewRule)
	}
	
	End {
		Write-Verbose "Ending $($MyInvocation.MyCommand)"
	}
} #function Remove-SCCMDeviceFromCollection