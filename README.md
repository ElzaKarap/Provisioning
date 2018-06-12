# Connect NAS Staging

## Usage steps (WINDOWS)

### One time setup 
1. Enable powershell script execution `Set-ExecutionPolicy -ExecutionPolicy Unrestricted`
2. Run `install_openssh.ps1`

### Steps
1. Edit values in `config.txt`
2. Add the corresponding qpkg archives of the follow qpkg's to `install_package`
 - HD_Station_3.1.2_x86_64_Intel_20160105.qpkg
 - SpotMonitor_0.0.9_x86_64.qpkg
 - JRE_8.65.0-1103_x86.qpkg
 - SolinkConnect_Full_4.0.16.qpkg
3. Update or remove `install_package/Cameras.json`
4. Update or remove `install_package/Multiview.json`
5. Run `remote_install.ps1`

To run multiple at once create a copy of config.txt and use a new path to sftp_batch.txt. The sftp_batch file is created by the script but if installing different versions of package at the same time this parameter is need to avoid clobbering.
eg: 
`.\remote_install.ps1 -ConfigTextPath "config.txt" -SftpBatchTextPath ".\sftp_batch.txt"`

## Usage steps (OSX/LINUX)

1. Edit values in `config.txt`
2. Add the corresponding qpkg archives of the follow qpkg's to `install_package`
 - HD_Station_3.1.2_x86_64_Intel_20160105.qpkg
 - SpotMonitor_0.0.9_x86_64.qpkg
 - JRE_8.65.0-1103_x86.qpkg
 - SolinkConnect_Full_4.0.16.qpkg
3. Update or remove `install_package/Cameras.json`
4. Update or remove `install_package/Multiview.json`
5. Run `remote_install.sh`

To run multiple at once create a copy of config.txt and specify the path when calling remote install.
eg:
`remote_install.sh "config.txt"`

### Known issues and Caveats

#### Using the Small SolinkConnect qpkg
Using the full package Solink package will result in fewer errors since all the services are ready and started post install instead of having to wait for them to be downloaded then started. Also adding the cameras.json and multiview.json feature will not work when using the small version of SolinkConnect. 

#### Script hangs
The script is known to hang instead of exiting. If you see the line `Done install_functions.sh` in the console output the script is done and it's safe to exit with `ctrl-c`. The script creates subshells to do package installs but they do not always exit cleanly despite return control to main provisioning script. As a percaution rebooting the device will ensure that all services are correcly running since some may not have restarted correctly causing the hanging event. 

#### Script hangs waiting for SolinkConnect to start
The SolinkConnect service start after updating cameras.json or multiview.json might hang. Fix is to manually start or restart SolinkConnect. This can be done 1 of 3 ways:
- ssh and run command `/etc/init.d/SolinkConnect.sh start` 
- Toggle in the QNAP web gui toggle the SolinkConnect QPKG off and on.
- Reboot the QNAP. Starting SolinkConnect is the final command before rebooting in `installfunctions.sh`. 

`Remote_install.ps1` will append your ssh_key to authorized_keys on the nas on each subsequent run. This does not cause any issue so far but it is irksome.
