#requires -Version 4.0

Function Set-ServiceStart
{
    <#
    .SYNOPSIS
    Start or stop a named Service on a named Server
    .DESCRIPTION
    Start or stop a named Service
    .EXAMPLE
    Set-ServiceStart -Server <server IP/FQDN> -Service <name of service> -StartService <true|false> -Credential <PSCredential Object>
    .PARAMETER Server
    The server to set the service start mode
    .PARAMETER Service
    The name of the service.
    .PARAMETER StartService
    true if to start the service; otherwise stop the service
    .PARAMETER Credential
    A credential object based on a user name and password.
	.NOTES
	Author	: George Leithead - InternetWideWorld.com
	Created	: 23/09/2020
	.LINK
	Get-CallerPreference
    #>
    [CmdletBinding(ConfirmImpact='Low')]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, HelpMessage='What server would you like to target?')]
        [Alias('computername')]
        [ValidateLength(3,254)]
        [ValidateNotNull()]
        [string[]]$Server,

        [Parameter(Mandatory=$True, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, HelpMessage='What service would you like to set?')]
        [ValidateNotNull()]
        [System.String]$Service,        

        [Parameter(Mandatory=$True, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, HelpMessage='What would you like to start or stop the service?')]
        [bool]$StartService,

        [Parameter(Mandatory=$True, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [ValidateNotNull()]
        [System.Management.Automation.Credential()]
        [System.Management.Automation.PSCredential]$Credential
    )

    Begin {
        Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Write-Verbose "Using parameter set $($PSCmdLet.ParameterSetName)"
    }

    Process {
        if ($startService)
        {
            $result = (gwmi win32_service -computername $Server -filter "name='$service'" -Credential $Credential).startservice()
        }
        else
        {
            $result = (gwmi win32_service -computername $Server -filter "name='$service'" -Credential $Credential).stopservice()
        }
        If ($result.ReturnValue -ne "0") 
        {
            return $result.ReturnValue
        }

        return 0
    }

    End {
        Write-Verbose "Ending $($MyInvocation.MyCommand)"
    }
} # function Set-ServiceStart