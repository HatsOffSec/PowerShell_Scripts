## PowerShell_Scripts
Some PS scripts for system interrogation

# CrashedService & Failed Logon
Basic search to see if the eventID is present

# HKU Run Keys
Checks the Run and RunOnce of the NTUser.dat of each user, if the user is logged on it will check it live. Automatically unloads the hives after checking. 

#Startup Folder Checker
Checks the Startup folder in AppData\Roaming for known executable extensions then provides the SHA256 sum of any findings
