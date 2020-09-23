# PowerShell.Library
## Overview
A PowerShell module library that is deployed to provide a single, comprehensive library to support and enhance your other PowerShell libraries.
## Usage
This is a PowerShell module that is expected to be deployed on a device to one of the paths defined in `$ENV:PSModulePath` (usually `C:\Program Files\WindowsPowerShell\Modules`).  It is then imported in scripts using `IMPORT-MODULE -Name PowerShell.Library`.

## Functions
### Core
A usefull collection of generic core functions.
#### Add-HostName
Add a host name to the HOSTS file on the current computer.
#### ConvertFrom-EncryptedString
Function to decrypt an obscured string.
#### ConvertTo-EncryptedString
Function to encrypt a string.
#### Get-AccessMaskFromPermission
Get the access mask from permissions.
#### Get-CallerPreference
Script module functions do not automatically inherit their caller's variables, but they can be obtained through the $PSCmdlet variable in Advanced Functions.  This function is a helper function for any script module Advanced Function; by passing in the values of $ExecutionContext.SessionState and $PSCmdlet, Get-CallerPreference will set the caller's preference variables locally.
#### Get-DeviceRam
Get the total physical RAM installed on the device.
#### Invoke-BalloonTip
Display a user-defined message as a balloon pop-up in the system tray.
#### Invoke-LogInAsAnotherUser
Disable automatic log on, and then log off to get the user to the Logon screen.
#### Pop-LogFile
Function to reset the LogFile variable to its previous value.
#### Pop-WindowTitle
Function to reset the window title.
#### Push-LogFile
Set the LogFile variable to a new value, and push the old value in a stack to be recalled later using the Pop-LogFile command.
#### Push-WindowTitle
Set the window title to a new value, and push the old value in a stack to be recalled later using the Pop-WindowTitle command.
#### Request-Ownership
For the current user take ACL ownership of a registry sub key.
#### Set-ForegroundWindow
Bring any process window into the foreground.
#### Set-ServiceStartMode
Sets a named Service to either disabled or automatic.
#### Set-ServiceStart
Start or stop a named Service.
#### Set-TokenPrivilege
Sets a token privilege required for management tasks.  A user account may or may not have the token privilege by default.
#### Set-Window
Sets the window size (height,width) and coordinates (x,y) of a process window.
#### Set-WMINamespaceSecurity
Modify the current security descriptor of a WMI name space. 
#### Test-IPAddress
Test the validity of a supplied IP address.
#### Test-MACAddress
Test the validity of a supplied MAC Address.
#### Watch-Process
Watch for a process to be started.
### SCCM
Generic SCCM functions to deal with devices, collections, policy retrieval, discovery inventory and program update.
#### Add-SCCMDeviceToCollection
Add a device to a SCCM collection.
#### Get-SCCMCollection
Get a collection or collections from SCCM.
#### Get-SCCMDevice
Get from SCCM the unique resource for the device.
#### Get-SCCMDeviceCollections
Get from SCCM the collections that the device is an evaluated member.
#### Get-SCCMSiteCode
Get the SCCM default site code for a provider location.
#### Install-SCCMProgramUpdate
Force install/uninstall of available software in software centre through CIM/WMI.
#### Remove-SCCMDeviceFromCollection
Remove a device from a SCCM collection.
#### Update-SCCMDiscoveryInventory
Trigger an update schedule for the Discovery Inventory.
#### Update-SCCMPolicyRetrieval.psm1
Trigger an update schedule for policy retrieval.

## Version history
### 1.0.0
Initial build.