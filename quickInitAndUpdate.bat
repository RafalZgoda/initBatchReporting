echo off

echo "********************************************************************************************"
echo "DOWNLOAD REMOTLY THE LAST VERSION OF UPDATED SCRIPT TO INITIALISE SERVER"
(
wget https://raw.githubusercontent.com/ZgodaRafal/initBatchReporting/master/init_vps_first_install.bat -OutFile init_vps_first_install.bat
) > quickInitAndUpdate.ps1
echo "********************************************************************************************"
echo "LAUNCH THE SCRIPT TO INITIALISE SERVER"
Powershell.exe -executionpolicy remotesigned -File quickInitAndUpdate.ps1