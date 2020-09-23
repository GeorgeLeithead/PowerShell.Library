#requires -Version 4.0

Function Get-SCCMDevice {
	<#
	.SYNOPSIS
	Get device SCCM resource
	.DESCRIPTION
	Get from SCCM the unique resource for the device.
	.PARAMETER SmsProvider
	Name of the SCCM Server.
	.PARAMETER PrimarySccm
	Primary SCCm site code.
	.PARAMETER ComputerName
	Specifies a name of the Device
	.PARAMETER MacAddress
	Specifies the MAC address of the Device
	.PARAMETER Credential
	Authentication credentials to the SCCM server
	.EXAMPLE
	Get-SCCMDevice -SmsProvider sccmserver01.internetwideworld.com -PrimarySccm IWW01 -MACAddress "aa:bb:cc:dd:ee:ff"

	This command gets the SCCM resource for the device with the MAC address of "aa:bb:cc:dd:ee:ff", from the server "sccmserver01.internetwideworld.com" and the site code "IWW01".
	.EXAMPLE
	Get-SCCMDevice -SmsProvider sccmserver01.internetwideworld.com -PrimarySccm IWW01 -Device "IWWLAPTOP001"

	This command gets the SCCM resource for the device with the machine name of "IWWLAPTOP001", from the server "sccmserver01.internetwideworld.com" and the site code "IWW01".
	.EXAMPLE
	Get-SCCMDevice -SmsProvider sccmserver01.internetwideworld.com -PrimarySccm IWW01 -Device "IWWLAPTOP001" -Credential (Get-Credential)

	This command gets the SCCM resource for the device with the machine name of "IWWLAPTOP001", from the server "sccmserver01.internetwideworld.com" and the site code "IWW01" using the supplied credentials.
	.INPUTS
	None
	.OUTPUTS
	System.Management.ManagementBaseObject - SCCM resource object for Device
	.NOTES
	Author	: George Leithead - InternetWideWorld.com
	Created	: 23/09/2020
	.LINK
	Get-CallerPreference
	Test-MACAddress
#>
 
	[CmdletBinding(DefaultParameterSetName = 'SearchByMACAddress', ConfirmImpact = 'Low')]
	Param(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeLine = $true, HelpMessage = "You must supply the SMS Provider", ParameterSetName = "SearchByMACAddress")]
		[Parameter(ParameterSetName = "SearchByComputerName")]
		[ValidateNotNullOrEmpty()]
		[Alias("SCCMServer", "Server")]
		[System.String]$SmsProvider,
		
		[Parameter(Mandatory = $true, Position = 1, ValueFromPipeLine = $true, HelpMessage = "You must supply the primary SCCM", ParameterSetName = "SearchByMACAddress")]
		[Parameter(ParameterSetName = "SearchByComputerName")]
		[ValidateNotNullOrEmpty()]
		[Alias("Site", "SiteCode", "PrimarySiteCode")]
		[System.String]$PrimarySCCM,

		[Parameter(Mandatory = $true, Position = 2, ValueFromPipeLine = $true, HelpMessage = "Please supply a MAC address of a SCCM Device", ParameterSetName = "SearchByMACAddress")]
		[ValidateScript( { Test-MACAddress -MACAddress $_ })]
		[System.String]$MACAddress,

		[Parameter(Mandatory = $true, Position = 2, ValueFromPipeLine = $true, HelpMessage = "You must supply the name of a SCCM Device", ParameterSetName = "SearchByComputerName")]
		[Alias("ComputerName", "Device", "Computer", "Resource")]
		[System.String]$Device,

		[Parameter(Mandatory = $false, Position = 3, HelpMessage = "Pleas supply authentication credentials", ParameterSetName = "SearchByMACAddress")]
		[Parameter(ParameterSetName = "SearchByComputerName")]
		[System.Management.Automation.PSCredential]$Credential = $null
	)

	Begin {
		Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
		Write-Verbose "Starting $($MyInvocation.MyCommand)"
		Write-Verbose "Using parameter set $($PSCmdLet.ParameterSetName)"
		[HashTable]$SccmResource = @{
			NameSpace    = "root\sms\site_$($PrimarySCCM)"
			ComputerName = $SmsProvider
			Class        = "SMS_R_SYSTEM"
		} # HashTable for Get-WmiObject

	}

	Process {
		if ($null -eq $Credential) {
			$SccmResource.Add("Credential", $Credential)
		}

		if ($($PSCmdLet.ParameterSetName) -eq "SearchByMACAddress") {
			$MacAddress = Test-MacAddress -MacAddress $MACAddress
			$SccmResource.Add("Filter", "MacAddresses='$MacAddress'")
		}

		if ($($PSCmdLet.ParameterSetName) -eq "SearchByComputerName") {
			$SccmResource.Add("Filter", "Name = '$Device'")
		}

		Write-Verbose ($SccmResource | Out-String)
		$Resource = Get-WmiObject @SccmResource

		if ($null -eq $Resource) {
			throw "Unable to get valid SCCM Device"
		}
	}

	End {
		Write-Verbose "Ending $($MyInvocation.MyCommand)"
		return $Resource
	}
} #function Get-SCCMDevice