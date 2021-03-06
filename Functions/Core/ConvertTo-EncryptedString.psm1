#requires -Version 4.0

Function ConvertTo-EncryptedString {
	<#
	.SYNOPSIS
	Encrypt a string.

	.DESCRIPTION
	Function to encrypt a string.

	.PARAMETER String
	System.String. To convert to an encrypted string.

	.EXAMPLE
	PS> ConvertTo-EncryptedString -String 'MyS3cretPa55wod'

	This command encrypts a string.
	.NOTES
	Author	: George Leithead - InternetWideWorld.com
	Created	: 23/09/2020
	.LINK
	Get-CallerPreference
	ConvertFrom-EncryptedString
	#>
	[CmdletBinding()]
	Param
	(
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[String]$String
	)

	Begin {
		Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
		Write-Verbose "Starting $($MyInvocation.MyCommand)"
		Write-Verbose "Using parameter set $($PSCmdLet.ParameterSetName)"
	}

	Process {
		Write-Verbose "Encrypting a string"
		try {
			# --- Set the key
			$Key = (71, 101, 111, 114, 103, 101, 32, 76, 101, 105, 116, 101, 97, 100, 73, 110, 116, 101, 114, 110, 101, 116, 87, 105, 100, 101, 87, 111, 114, 108, 100, 46)

			# --- Create the secure string
			$SecureString = ConvertTo-SecureString -String $String -AsPlainText -Force 
			$EncryptedString = ConvertFrom-SecureString $SecureString -Key $Key 

			# --- Return the data
			return $EncryptedString
		}
		catch {
			throw "Failed to Convert to Encrypted String - $_"
		}
	}

	End {
		Write-Verbose "Ending $($MyInvocation.MyCommand)"
	}
} # function ConvertTo-EncryptedString