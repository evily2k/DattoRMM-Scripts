# Auto-Lock your workstation after Idle-Timeout with PowerShell
# Credit: https://gist.github.com/wendelb
#
# This background job automatically locks your Workstation after a specified amount of
# time. It will come in handy if you cannot access the screensaver settings due to policy
# restriction but want to lock your screen after a idle timeout. Or you could just
# press [Win]+[L] everytime you leave your desk ;) .
#
# start with
# 	powershell.exe -windowstyle hidden -executionpolicy Unrestricted P:\ATH\TO\logoff.ps1
#
# `-windowstyle hidden` will make your PowerShell disappear/run in background
# `-executionpolicy Unrestricted` will enable this PowerShell process to allow non-signed scripts
#

# This is the only setting: How long before locking?
# Alternative Options:
# * -Seconds 10 ( = 10 Seconds)
# * -Minutes 10 ( = 10 Minutes)
# * -Hours 10 ( = 10 Hours)

$idle_timeout = New-TimeSpan -Minutes 20

# DO NOT CHANGE ANYTHING BELOW THIS LINE
####################################################################################################################################################################

# This snippet is from http://stackoverflow.com/a/15846912
Add-Type @'
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;

namespace PInvoke.Win32 {

    public static class UserInput {

        [DllImport("user32.dll", SetLastError=false)]
        private static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);

        [StructLayout(LayoutKind.Sequential)]
        private struct LASTINPUTINFO {
            public uint cbSize;
            public int dwTime;
        }

        public static DateTime LastInput {
            get {
                DateTime bootTime = DateTime.UtcNow.AddMilliseconds(-Environment.TickCount);
                DateTime lastInput = bootTime.AddMilliseconds(LastInputTicks);
                return lastInput;
            }
        }

        public static TimeSpan IdleTime {
            get {
                return DateTime.UtcNow.Subtract(LastInput);
            }
        }

        public static int LastInputTicks {
            get {
                LASTINPUTINFO lii = new LASTINPUTINFO();
                lii.cbSize = (uint)Marshal.SizeOf(typeof(LASTINPUTINFO));
                GetLastInputInfo(ref lii);
                return lii.dwTime;
            }
        }
    }
}
'@
#End snippet

# Helper: Is currently locked?
$locked = 0;

do {
	# 1st: How long is your computer currently idle?
	$idle_time = [PInvoke.Win32.UserInput]::IdleTime;
    #Write-Host ("Idle for " + $idle_time);


	# Your computer is not locked, but idle time is longer than allowed? -> Lock it!
	if (($locked -eq 0) -And ($idle_time -gt $idle_timeout)) {
		# Lock it
		rundll32.exe user32.dll,LockWorkStation

		# Setting $locked to 1 will prevent it from relocking every 10 seconds
		$locked = 1;
		#Write-Host ("Locking");
	}

	# Your computer is idle for less than the allowed time -> in most cases this means it is unlocked and
	# therefore ready to be locked again!
	if ($idle_time -lt $idle_timeout) {
		$locked = 0;
	}

	# Save the environment. Don't use 100% of a single CPU just for idle checking :)
    Start-Sleep -Seconds 10
}
while (1 -eq 1)