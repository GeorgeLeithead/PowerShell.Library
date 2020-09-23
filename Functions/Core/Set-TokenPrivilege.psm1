#requires -Version 4.0

Function Set-TokenPrivilege {
	<#
	.SYNOPSIS
	Sets a token privilege on a process

	.DESCRIPTION
	Sets a token privilege required for management tasks.  A user account may or may not have the token privilege by default.  

	.PARAMETER Privilege
	The privilege to adjust.
	.PARAMETER ProcessId
	The process on which to adjust the privilege. Defaults to the current process.
	.PARAMETER Disable
	Switch to disable the privilege, rather than enable it.
	.EXAMPLE
	PS> Set-TokenPrivilege -Privilege "SeShutdownPrivilege" -ProcessId $pid -Disable

	This command disables for the default process the users privilege to be able to shut down the current computer.
	.EXAMPLE
	PS> Set-TokenPrivilege -Privilege "SeShutdownPrivilege" -ProcessId $pid

	This command enables for the default process the users privilege to be able to shut down the current computer.
	.OUTPUTS
	None
	.NOTES
	Author	: George Leithead - InternetWideWorld.com
	Created	: 23/09/2020
	.LINK
	 http://msdn.microsoft.com/en-us/library/bb530716(VS.85).aspx
	Get-CallerPreference
	Get-Process
	#>


	[CmdletBinding(DefaultParameterSetName="Default")]
	Param(
		[Parameter(Mandatory = $true, HelpMessage="The privilege to adjust.")]
		[ValidateSet(
			"SeAssignPrimaryTokenPrivilege", "SeAuditPrivilege", "SeBackupPrivilege",
			"SeChangeNotifyPrivilege", "SeCreateGlobalPrivilege", "SeCreatePagefilePrivilege",
			"SeCreatePermanentPrivilege", "SeCreateSymbolicLinkPrivilege", "SeCreateTokenPrivilege",
			"SeDebugPrivilege", "SeEnableDelegationPrivilege", "SeImpersonatePrivilege", "SeIncreaseBasePriorityPrivilege",
			"SeIncreaseQuotaPrivilege", "SeIncreaseWorkingSetPrivilege", "SeLoadDriverPrivilege",
			"SeLockMemoryPrivilege", "SeMachineAccountPrivilege", "SeManageVolumePrivilege",
			"SeProfileSingleProcessPrivilege", "SeRelabelPrivilege", "SeRemoteShutdownPrivilege",
			"SeRestorePrivilege", "SeSecurityPrivilege", "SeShutdownPrivilege", "SeSyncAgentPrivilege",
			"SeSystemEnvironmentPrivilege", "SeSystemProfilePrivilege", "SeSystemtimePrivilege",
			"SeTakeOwnershipPrivilege", "SeTcbPrivilege", "SeTimeZonePrivilege", "SeTrustedCredManAccessPrivilege",
			"SeUndockPrivilege", "SeUnsolicitedInputPrivilege")]
		$Privilege,
		[Parameter(Mandatory = $false, HelpMessage="The process on which to adjust the privilege. Defaults to the current process.")]
		[System.ValueType]$ProcessId = $pid,
		[Parameter(Mandatory = $false, HelpMessage="Switch to disable the privilege, rather than enable it.")]
		[Switch]$Disable
	)
 
	Begin
	{
		Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
		Write-Verbose "Starting $($MyInvocation.MyCommand)"
		Write-Verbose "Using parameter set $($PSCmdLet.ParameterSetName)"
		# Taken from P/Invoke.NET with minor adjustments.
		$definition = @'
		using System;
		using System.Runtime.InteropServices;
  
		 public class AdjPriv
		{
		  [DllImport("advapi32.dll",  ExactSpelling = true, SetLastError = true)]
		  internal static extern bool AdjustTokenPrivileges(IntPtr htok, bool disall,
		   ref TokPriv1Luid newst, int  len, IntPtr prev,  IntPtr relen);
  
		  [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
		  internal static extern bool OpenProcessToken(IntPtr h, int acc, ref IntPtr  phtok);
		  [DllImport("advapi32.dll",  SetLastError = true)]
		  internal static extern bool LookupPrivilegeValue(string host, string name, ref long pluid);
		  [StructLayout(LayoutKind.Sequential, Pack = 1)]
		  internal struct TokPriv1Luid
		  {
		   public int Count;
		   public long Luid;
		   public int Attr;
		  }
  
		  internal const int SE_PRIVILEGE_ENABLED = 0x00000002;
		  internal const int SE_PRIVILEGE_DISABLED = 0x00000000;
		  internal const int TOKEN_QUERY = 0x00000008;
		  internal const int TOKEN_ADJUST_PRIVILEGES = 0x00000020;
		  public static bool EnablePrivilege(long  processHandle, string privilege, bool disable)
		  {
		   bool retVal;
		   TokPriv1Luid tp;
		   IntPtr hproc = new IntPtr(processHandle);
		   IntPtr htok =  IntPtr.Zero;
		   retVal = OpenProcessToken(hproc, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, ref htok);
		   tp.Count = 1;
		   tp.Luid = 0;
		   if(disable)
		   {
			tp.Attr = SE_PRIVILEGE_DISABLED;
		   }
		   else
		   {
			tp.Attr = SE_PRIVILEGE_ENABLED;
		   }
		   retVal = LookupPrivilegeValue(null, privilege, ref tp.Luid);
		   retVal = AdjustTokenPrivileges(htok, false, ref tp, 0, IntPtr.Zero,  IntPtr.Zero);
		   return retVal;
		  }
		}
'@
	}

	Process
	{
		$processHandle = (Get-Process -id $ProcessId).Handle
		$type = Add-Type $definition -PassThru
		$type[0]::EnablePrivilege($processHandle, $Privilege, $Disable)
	}

	End
	{
		Write-Verbose "Ending $($MyInvocation.MyCommand)"
	}
} # function Set-TokenPrivilege