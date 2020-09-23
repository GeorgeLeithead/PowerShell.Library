#requires -Version 4.0

Function Get-SCCMCollection {
	<#
	.Synopsis
	Get a SCCM collection
	.DESCRIPTION
	Get a collection or collections from SCCM.
	.PARAMETER SmsProvider
	Name of the SCCM Server.
	.PARAMETER PrimarySccm
	Primary SCCM site code.
	.PARAMETER Name
	Collection name
	.PARAMETER Id
	Collection identifier
	.PARAMETER Credential
	Authentication credentials to the SCCM server
	.EXAMPLE
	Get-SCCMCollection

	This command gets a SCCM collection details.
	.INPUTS
	None
	.OUTPUTS
	HashTable - Collection details.
	.NOTES
	Author	: George Leithead - InternetWideWorld.com
	Created	: 23/09/2020

	Use this script where the SCCM console is NOT installed on the current device.  Otherwise use the standard Configuration Manager cmdlets.
	.LINK
	Get-CallerPreference
	#>

	[CmdletBinding(DefaultParameterSetName = "ByName", ConfirmImpact = "Medium")]
	param(
		[Parameter(Mandatory = $true, HelpMessage = "You must supply the SMS Provider", ParameterSetName = "ByName")]
		[Parameter(Mandatory = $true, HelpMessage = "You must supply the SMS Provider", ParameterSetName = "ById")]
		[ValidateNotNullOrEmpty()]
		[Alias("SCCMServer", "Server")]
		[System.String]$SmsProvider,
		
		[Parameter(Mandatory = $true, HelpMessage = "You must supply the primary SCCM", ParameterSetName = "ByName")]
		[Parameter(Mandatory = $true, HelpMessage = "You must supply the primary SCCM", ParameterSetName = "ById")]
		[ValidateNotNullOrEmpty()]
		[Alias("Site", "SiteCode", "PrimarySiteCode")]
		[System.String]$PrimarySCCM,

		[Parameter(ParameterSetName = "ByName", Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[SupportsWildcards()]
		[System.String]$Name,

		[Parameter(ParameterSetName = "ById", Mandatory = $true)]
		[Alias("CollectionId")]
		[System.String]$Id,

		[Parameter(Mandatory = $false, HelpMessage = "Pleas supply authentication credentials", ParameterSetName = "ByName")]
		[Parameter(Mandatory = $false, HelpMessage = "Pleas supply authentication credentials", ParameterSetName = "ById")]
		[System.Management.Automation.PSCredential]$Credential = $null
	)

	Begin {
		#Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
		Write-Verbose "Starting $($MyInvocation.MyCommand)"
		Write-Verbose "Using parameter set $($PSCmdLet.ParameterSetName)"
		[HashTable]$CollectionParams = @{
			NameSpace    = "root\sms\site_$PrimarySCCM"
			ComputerName = $SmsProvider
		} # HashTable for Get-WmiObject
	}
	
	Process {
		if ($Credential -ne $null) {
			$CollectionParams.Add("Credential", $Credential)
		}

		if ($($PSCmdLet.ParameterSetName) -eq "ByName") {
			$CollectionParams.Add("Query", "Select * from SMS_Collection where SMS_Collection.name like '$Name'")
		}

		if ($($PSCmdLet.ParameterSetName) -eq "ById") {
			$CollectionParams.Add("Query", "Select * from SMS_Collection where SMS_Collection.CollectionId = '$Id'")
		}

		$Collection = Get-WmiObject @CollectionParams # Splat the HashTable for Get-WmiObject
	}

	End {
		Write-Verbose "Ending $($MyInvocation.MyCommand)"
		return $Collection
	}

} # function Get-SCCMCollection