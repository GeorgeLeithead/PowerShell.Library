#requires -Version 4.0

Function Get-SCCMDeviceCollections
{
<#
	.SYNOPSIS
	Get device SCCM collections
	.DESCRIPTION
	Get from SCCM the collections that the device is an evaluated member.
	.PARAMETER SmsProvider
	Name of the SCCM Server.
	.PARAMETER PrimarySccm
	Primary SCCM site code.
	.PARAMETER ComputerName
	Specifies a name of the device
	.PARAMETER ResourceId
	SCCM resource identifier for the device
	.EXAMPLE
	Get-SCCMDeviceCollections -SmsProvider sccmserver01.internetwideworld.com -PrimarySccm IWW01 -ComputerName "IWWLAPTOP001"

	This command gets the SCCM collections for the evaluated device with the name of "IWWLAPTOP001", from the server "sccmserver01.internetwideworld.com" and the site code "IWW01".
	.EXAMPLE
	Get-SCCMDeviceCollections -SmsProvider sccmserver01.internetwideworld.com -PrimarySccm IWW01 -ResourceId 1234567

	This command gets the SCCM collections for the evaluated device with the resource identifier 1234567, from the server "sccmserver01.internetwideworld.com" and the site code "IWW01".
	.EXAMPLE
	Get-SCCMDeviceCollections -SmsProvider sccmserver01.internetwideworld.com -PrimarySccm IWW01 -ResourceId 1234567

	This command gets the SCCM collections for the evaluated device with the resource identifier 1234567, from the server "sccmserver01.internetwideworld.com" and the site code "IWW01" using the supplied credentials.
	.INPUTS
	None
	.OUTPUTS
	System.Array - An array of SCCM collection objects.
	.NOTES
	Author	: George Leithead - InternetWideWorld.com
	Created	: 23/09/2020
	.LINK
	Get-CallerPreference
#>
 
	[CmdletBinding(DefaultParameterSetName = 'SearchByResourceId', ConfirmImpact = 'Low')]
	[OutputType([System.Array])]
	Param(
		[Parameter(Mandatory=$true, Position=0, ValueFromPipeLine=$true, HelpMessage="You must supply the SMS Provider", ParameterSetName="SearchByResourceId")]
		[Parameter(ParameterSetName="SearchByComputerName")]
		[ValidateNotNullOrEmpty()]
		[Alias("SCCMServer","Server")]
		[System.String]$SmsProvider,
		
		[Parameter(Mandatory=$true, Position=1, ValueFromPipeLine=$true, HelpMessage="You must supply the primary SCCM", ParameterSetName="SearchByResourceId")]
		[Parameter(ParameterSetName="SearchByComputerName")]
		[ValidateNotNullOrEmpty()]
		[Alias("Site","SiteCode", "PrimarySiteCode")]
		[System.String]$PrimarySCCM,

		[Parameter(Mandatory=$true, Position=2, ValueFromPipeLine=$true, HelpMessage="Please supply a Resource ID of a SCCM device", ParameterSetName="SearchByResourceId")]
		[System.Int32]$ResourceId,

		[Parameter(Mandatory=$true, Position=2, ValueFromPipeLine=$true, HelpMessage="You must supply the name of a SCCM device", ParameterSetName="SearchByComputerName")]
		[Alias("ComputerName","Device","Computer","Resource")]
		[System.String]$Device,

		[Parameter(Mandatory=$false, Position=3, HelpMessage="Pleas supply authentication credentials", ParameterSetName="SearchByResourceId")]
		[Parameter(ParameterSetName="SearchByComputerName")]
		[System.Management.Automation.PSCredential]$Credential = $null
	)

	Begin {
		Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
		Write-Verbose "Starting $($MyInvocation.MyCommand)"
		Write-Verbose "Using parameter set $($PSCmdLet.ParameterSetName)"
		[HashTable]$CollectionParams = @{
			NameSpace = "root\sms\site_$PrimarySCCM"
			ComputerName = $SmsProvider
		} # HashTable for Get-WmiObject
	}

	Process {
		if ($Credential -ne $null) {
			$CollectionParams.Add("Credential", $Credential)
		}

		if ($($PSCmdLet.ParameterSetName) -eq "SearchByResourceId") {
			$CollectionParams.Add("Query", "Select SMS_Collection.* From SMS_FullCollectionMembership, SMS_Collection WHERE SMS_FullcollectionMembership.CollectionID = SMS_Collection.CollectionID AND SMS_FullcollectionMembership.ResourceID = $ResourceId")
		}

		if ($($PSCmdLet.ParameterSetName) -eq "SearchByComputerName") {
			$CollectionParams.Add("Query", "Select SMS_Collection.* From SMS_FullCollectionMembership, SMS_Collection WHERE SMS_FullcollectionMembership.CollectionID = SMS_Collection.CollectionID AND SMS_FullcollectionMembership.Name = '$Device'")
		}

		$Collections = Get-WmiObject @CollectionParams # Splat the HashTable for Get-WmiObject
	}

	End {
		Write-Verbose "Ending $($MyInvocation.MyCommand)"
		return $Collections
	}
} #function Get-SCCMDeviceCollections