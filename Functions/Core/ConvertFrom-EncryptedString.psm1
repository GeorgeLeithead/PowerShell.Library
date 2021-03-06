#requires -Version 4.0

Function ConvertFrom-EncryptedString {
	<#
	.SYNOPSIS
	Decrypt an obscured string.

	.DESCRIPTION
	Function to decrypt an obscured string.

	.PARAMETER EncryptedString
	The Encrypted string to decrypt.

	.EXAMPLE
	PS> ConvertFrom-EncryptedString -EncryptedString '76492d1116743f04...'

	This command decrypts an encrypted string.
	.NOTES
	Author	: George Leithead - InternetWideWorld.com
	Created	: 23/09/2020
	.LINK
	Get-CallerPreference
	ConvertTo-EncryptedString
	#>


	[CmdletBinding(DefaultParameterSetName = "Default")]
	[OutputType([System.String])]
	Param
	(
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[String]$EncryptedString
	)

	Begin {
		Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
		Write-Verbose "Starting $($MyInvocation.MyCommand)"
		Write-Verbose "Using parameter set $($PSCmdLet.ParameterSetName)"
	}

	Process {
		Write-Verbose "Decrypting an encrypted string"
		try {
			# --- Set the key
			$Key = (71, 101, 111, 114, 103, 101, 32, 76, 101, 105, 116, 101, 97, 100, 73, 110, 116, 101, 114, 110, 101, 116, 87, 105, 100, 101, 87, 111, 114, 108, 100, 46)

			# --- Create the secure string
			$SecureString = $EncryptedString | ConvertTo-SecureString -Key $Key
			$TmpCredential = New-Object Management.Automation.PSCredential 'Anything', $SecureString
			$String = $TmpCredential.GetNetworkCredential().Password

			# --- Return the data
			return $String
		}
		catch {
			throw "Failed to Convert from Encrypted String - $_"
		}
	}

	End {
		Write-Verbose "Ending $($MyInvocation.MyCommand)"
	}
} # function ConvertFrom-EncryptedString
