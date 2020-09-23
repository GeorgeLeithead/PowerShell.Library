#requires -Version 4.0

Function Set-Window {
	<#
	.SYNOPSIS
	Sets the window size
	.DESCRIPTION
	Sets the window size (height,width) and coordinates (x,y) of a process window.
	.PARAMETER X
	Set the position of the window in pixels from the top.
	.PARAMETER Y
	Set the position of the window in pixels from the left.
	.PARAMETER Width
	Set the width of the window.
	.PARAMETER Height
	Set the height of the window.
	.PARAMETER Passthru
	Display the output object of the window.
	.OUTPUT
	System.Automation.WindowInfo
	.EXAMPLE
	Set-Window -X 2040 -Y 142 -Passthru

	This command sets the coordinates on the window to TopLeft 2040,142; without setting the width or height.
	.EXAMPLE
	Set-Window -X 2040 -Y 142 -Width 1262 -Height 642 -Passthru

	This command sets the coordinates on the window to TopLeft 2040,142 and the size to 1262,642.
	.NOTES
	Author	: George Leithead - InternetWideWorld.com
	Created	: 23/09/2020
	.LINK
	Get-CallerPreference
#>

 
	[CmdletBinding(DefaultParameterSetName = 'Default', ConfirmImpact = 'Low')]
	[OutputType('System.Automation.WindowInfo')]
	Param (
		[Parameter(Mandatory = $false, HelpMessage = "Set the position of the window in pixels from the top.")]
		[System.Int32]$X,

		[Parameter(Mandatory = $false, HelpMessage = "Set the position of the window in pixels from the left.")]
		[System.Int32]$Y,

		[Parameter(Mandatory = $false, HelpMessage = "Set the width of the window in pixels.")]
		[System.Int32]$Width,

		[Parameter(Mandatory = $false, HelpMessage = "Set the height of the window in pixels.")]
		[System.Int32]$Height,

		[Parameter(Mandatory = $false, HelpMessage = "Returns an object representing the window.  By default, this cmdlet does not generate any output.")]
		[switch]$Passthru
	)

	Begin {
		Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
		Write-Verbose "Starting $($MyInvocation.MyCommand)"
		Write-Verbose "Using parameter set $($PSCmdLet.ParameterSetName)"
		Try {
			[void][Window]
		}
		Catch {
			Add-Type @"
			  using System;
			  using System.Runtime.InteropServices;
			  public class Window {
				[DllImport("user32.dll")]
				[return: MarshalAs(UnmanagedType.Bool)]
				public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

				[DllImport("User32.dll")]
				public extern static bool MoveWindow(IntPtr handle, int x, int y, int width, int height, bool redraw);
			  }
			  public struct RECT
			  {
				public int Left;        // x position of upper-left corner
				public int Top;         // y position of upper-left corner
				public int Right;       // x position of lower-right corner
				public int Bottom;      // y position of lower-right corner
			  }
"@
		}
	}

	Process {
		Write-Verbose "Setting window location and size"
		$Rectangle = New-Object RECT
		$ProcessName = Get-Process -Id $PID
		$Handle = (Get-Process -Id $PID).MainWindowHandle
		$Return = [Window]::GetWindowRect($Handle, [ref]$Rectangle)
		If (-NOT $PSBoundParameters.ContainsKey('Width')) {            
			$Width = $Rectangle.Right - $Rectangle.Left            
		}
		If (-NOT $PSBoundParameters.ContainsKey('Height')) {
			$Height = $Rectangle.Bottom - $Rectangle.Top
		}
		If ($Return) {
			$Return = [Window]::MoveWindow($Handle, $x, $y, $Width, $Height, $True)
		}
		If ($PSBoundParameters.ContainsKey('Passthru')) {
			$Rectangle = New-Object RECT
			$Return = [Window]::GetWindowRect($Handle, [ref]$Rectangle)
			If ($Return) {
				$Height = $Rectangle.Bottom - $Rectangle.Top
				$Width = $Rectangle.Right - $Rectangle.Left
				$Size = New-Object System.Management.Automation.Host.Size -ArgumentList $Width, $Height
				$TopLeft = New-Object System.Management.Automation.Host.Coordinates -ArgumentList $Rectangle.Left, $Rectangle.Top
				$BottomRight = New-Object System.Management.Automation.Host.Coordinates -ArgumentList $Rectangle.Right, $Rectangle.Bottom
				If ($Rectangle.Top -lt 0 -AND $Rectangle.LEft -lt 0) {
					Write-Warning "Window is minimized! Coordinates will not be accurate."
				}
				$Object = [pscustomobject]@{
					ProcessName = $ProcessName
					Size        = $Size
					TopLeft     = $TopLeft
					BottomRight = $BottomRight
				}
				$Object.PSTypeNames.insert(0, 'System.Automation.WindowInfo')
				$Object            
			}
		}
	}

	End {
		Write-Verbose "Ending $($MyInvocation.MyCommand)"
	}

} # Function Set-Window