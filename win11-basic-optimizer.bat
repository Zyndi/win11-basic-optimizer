@echo off
setlocal enabledelayedexpansion
cls
title Windows 11 Basic Optimizer by Zyndi
echo.
echo Automatic optimizer for a faster Windows 11 experience after upgrading from Windows 10
echo.
echo If you haven't done so already, make SURE you run this script as administrator before proceeding
echo Press any key to continue...
pause > nul

powershell "Set-ExecutionPolicy -ExecutionPolicy Unrestricted"

REM Disabling security and mitigations
powershell "Remove-Item -Path \"HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\*\" -Recurse -ErrorAction SilentlyContinue"
reg add "HKEY_CURRENT_USER\Software\Microsoft\Edge\SmartScreenEnabled" /ve /t REG_DWORD /d 0 /f
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "SmartScreenEnabled" /t REG_SZ /d Off /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\BitLocker" /v "PreventDeviceEncryption" /t REG_DWORD /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CI\Config" /v "VulnerableDriverBlocklistEnable" /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CI\Policy" /v "VerifiedAndReputablePolicyState" /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v "EnableVirtualizationBasedSecurity" /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Enabled" /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" /v "RunAsPPL" /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "MitigationOptions" /t REG_BINARY /d 222002000002000000020000000000000000000000000000 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettings" /t REG_DWORD /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverride" /t REG_DWORD /d 3 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverrideMask" /t REG_DWORD /d 3 /f
schtasks /change /tn "\Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance" /disable
schtasks /change /tn "\Microsoft\Windows\Windows Defender\Windows Defender Cleanup" /disable
schtasks /change /tn "\Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan" /disable
schtasks /change /tn "\Microsoft\Windows\Windows Defender\Windows Defender Verification" /disable

REM Applying changes to BCD
REM Setting the bootmenupolicy to Legacy can help troubleshoot boot issues since the bootloader will not load windows before showing the boot menu
bcdedit /set bootmenupolicy Legacy
REM Setting nocrashautoreboot can help troubleshoot BSODs by preventing automatic reboots to properly check error codes
bcdedit /set nocrashautoreboot Yes
bcdedit /set nx OptOut
bcdedit /set recoveryenabled No

REM Enabling hardware-accelerated GPU scheduling
REM Ignored on AMD GPUs 6000 series and older since it causes problems
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d 2 /f

REM Using the weak host model (same as Linux)
powershell "Get-NetAdapter -IncludeHidden | Set-NetIPInterface -WeakHostSend Enabled -WeakHostReceive Enabled -ErrorAction SilentlyContinue"

REM Disabling hibernation
powercfg -h off

REM Applying changes to memory management
powershell "Disable-MMAgent -mc"
powershell "Enable-MMAgent -pc"
powershell "Set-MMAgent -moaf 8192"

REM Disabling FTH
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\FTH" /v "Enabled" /t REG_DWORD /d 0 /f
Rundll32 fthsvc.dll,FthSysprepSpecialize

REM Disabling random creation of memory reports
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\RADAR" /f

REM Disabling UAC
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableLUA" /t REG_DWORD /d 0 /f

REM Enabling detailed verbose messages
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "VerboseStatus" /t REG_DWORD /d 1 /f

REM Enabling segment heap
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Segment Heap" /v "Enabled" /t REG_DWORD /d 1 /f

REM Enabling native NVMe
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Policies\Microsoft\FeatureManagement\Overrides" /v "156965516" /t REG_DWORD /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Policies\Microsoft\FeatureManagement\Overrides" /v "1853569164" /t REG_DWORD /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Policies\Microsoft\FeatureManagement\Overrides" /v "3244671118" /t REG_DWORD /d 1 /f

REM Reducing keyboard and mouse ring buffer
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" /v "KeyboardDataQueueSize" /t REG_DWORD /d 16 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v "MouseDataQueueSize" /t REG_DWORD /d 16 /f

REM Compressing OS files
compact /compactos:always

echo.
echo Done, make sure to reboot your system
echo Run this script every time you install a new build
echo.
pause
endlocal
