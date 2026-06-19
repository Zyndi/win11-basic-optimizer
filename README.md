# Zyndi's Windows 11 Basic Optimizer
## Make your Windows 11 system faster after upgrading from Windows 10!

This script is intended to restore performance, improve latency, and make troubleshooting more convenient. This script runs through various tweaks such as disabling security and mitigations some gamers don't actually need, etc.

Run the script as administrator and reboot the system.

> [!CAUTION]
> Segment Heap can cause some games (notably with anti-cheat) to crash or hang when enabled. If you're having this problem after running the script, use the following command to disable it globally or read this [article](https://blog.s-schoener.com/2024-11-05-segment-heap/) on how to disable it per-executable instead.
> 
> `reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Segment Heap" /v "Enabled" /t REG_DWORD /d 0 /f`

In case you experience anymore issues, please open an issue or contact me on Discord: zyndi
