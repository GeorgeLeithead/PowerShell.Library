#requires -Version 4.0

Function Get-AccessMaskFromPermission {
    <#
	.SYNOPSIS
	Get access mask from permission

	.DESCRIPTION
	Get the access mask from permissions.

	.PARAMETER permissions
	the permissions.

	.NOTES
	Author	: George Leithead - InternetWideWorld.com
	Created	: 23/09/2020
	.LINK
	#>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $permissions
    )


    $WBEM_ENABLE = 1
    $WBEM_METHOD_EXECUTE = 2
    $WBEM_FULL_WRITE_REP = 4
    $WBEM_PARTIAL_WRITE_REP = 8
    $WBEM_WRITE_PROVIDER = 0x10
    $WBEM_REMOTE_ACCESS = 0x20
    #$WBEM_RIGHT_SUBSCRIBE = 0x40
    #$WBEM_RIGHT_PUBLISH = 0x80
    $READ_CONTROL = 0x20000
    $WRITE_DAC = 0x40000
       
    $WBEM_RIGHTS_FLAGS = $WBEM_ENABLE, $WBEM_METHOD_EXECUTE, $WBEM_FULL_WRITE_REP, $WBEM_PARTIAL_WRITE_REP, $WBEM_WRITE_PROVIDER, $WBEM_REMOTE_ACCESS, $READ_CONTROL, $WRITE_DAC
    $WBEM_RIGHTS_STRINGS = "Enable", "MethodExecute", "FullWrite", "PartialWrite", "ProviderWrite", "RemoteAccess", "ReadSecurity", "WriteSecurity"
    $permissionTable = @{}

    for ($i = 0; $i -lt $WBEM_RIGHTS_FLAGS.Length; $i++) {
        $permissionTable.Add($WBEM_RIGHTS_STRINGS[$i].ToLower(), $WBEM_RIGHTS_FLAGS[$i])
    }
       
    $accessMask = 0
    foreach ($permission in $permissions) {
        if (-not $permissionTable.ContainsKey($permission.ToLower())) {
            throw "Unknown permission: $permission`nValid permissions: $($permissionTable.Keys)"
        }
        $accessMask += $permissionTable[$permission.ToLower()]
    }
       
    $accessMask
} # function Get-AccessMaskFromPermission