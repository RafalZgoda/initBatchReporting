echo off

echo "********************************************************************************************"
echo "1 : INIT OF THE NEW VPS"
(
echo $URL_SERVER = "https://server.lutily.fr:8443"
echo write-host "THE MONITORING SERVER IS ON URL: $URL_SERVER" 
echo $IP_SERVER = "http://whatismyip.akamai.com/"
echo $MY_IP = Invoke-WebRequest -Uri $IP_SERVER -Method GET 
echo write-host "YOUR IP IS : $MY_IP" 
echo $USERNAME = read-host "Enter your unique username in monitoring server -> telegram first name?"
echo write-host "Your username is : $USERNAME"  
echo write-host "REGISTER NEW IP SERVER IN MONITORING TOOL"
echo $URL_SET_SERVER = $URL_SERVER + "/users/server/" + $USERNAME  
echo $postParams = @{ip = $MY_IP }  
echo $STORE_RESULT = Invoke-WebRequest -Uri $URL_SET_SERVER -Method POST -Body $postParams  
echo write-host "Request result : $STORE_RESULT" 
) > registerNewServer.ps1

Powershell.exe -executionpolicy remotesigned -File registerNewServer.ps1

echo "***********************************************************************"
echo "INSTALL CHROME SILENTLY"
echo $Path = $env:TEMP; $Installer = "chrome_installer.exe"; Invoke-WebRequest "http://dl.google.com/chrome/install/375.126/chrome_installer.exe" -OutFile $Path\$Installer; Start-Process -FilePath $Path\$Installer -Args "/silent /install" -Verb RunAs -Wait; Remove-Item $Path\$Installer > chromeInstaller.ps1
if not exist "C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe" (
    Powershell.exe -executionpolicy remotesigned -File  chromeInstaller.ps1
) else (
    echo "CHROME ALREADY INSTALLED"
)
timeout 5 > NUL

echo "********************************************************************************************"
echo "CREATE A SCRIPT THAT BOOT MUSIC STREAMING PLATFORM ON CHROME"
echo start chrome -new-window https://open.spotify.com/ https://greasyfork.org/en/scripts/390641-monitoring-streaming-platform  > launchStreamingPlatforms.bat
echo start chrome -new-window https://www.deezer.com/fr/ >> launchStreamingPlatforms.bat
echo start chrome -new-window https://listen.tidal.com >> launchStreamingPlatforms.bat
timeout 5 > NUL
echo "ADD THIS SCRIPT IN STARTUP DIR (WHEN THE VPS WILL BOOT, IT WILL LAUNCH THE SCRIPT"
powershell "$s=(New-Object -COM WScript.Shell).CreateShortcut('C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\launchStreamingPlatforms.lnk');$s.TargetPath='launchStreamingPlatforms.bat';$s.Save()"
timeout 5 > NUL

echo "********************************************************************************************"
echo "CREATE A SCRIPT THAT ENABLE SOUND, DISABLE WINDOWS UPDATE AND SCHEDULE A REBOOT"
echo "THIS SCRIPT WILL ALSO REBOOT CHOME EVERY X HOURS "
echo "AND ADD IT IN START UP VPS"
(
    echo echo off
    echo cd %UserProfile%\Desktop 
    echo echo "ACTIVATE SOUND"
    echo net start audiosrv
    echo net start AudioEndpointBuilder
    echo timeout 5 > NUL

    echo echo "DISABLE UPDATE WINDOWS"
    echo sc config wuauserv start= disabled
    echo net stop wuauserv
    echo reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v AUOptions /t REG_DWORD /d 1 /f
    echo timeout 5 > NUL

    echo echo "REBOOT THE VPS EVERY 7 DAYS "
    echo shutdown /r /t 604800 /c "Arreter de l'ordinateur dans 259200 secondes" 

    echo echo "REBOOT CHROME EVERY X HOURS "
    echo timeout 600
    echo :start
    echo taskkill /F /IM chrome.exe /T
    echo CALL launchStreamingPlatforms.bat
    echo timeout 3600
    echo goto start

    echo pause 
) > initAndScheduleReboot.bat

echo "ADD THIS SCRIPT IN STARTUP DIR (WHEN THE VPS WILL BOOT, IT WILL LAUNCH THE SCRIPT"
xcopy /y initAndScheduleReboot.bat "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\"
echo "LAUNCH THIS SCRIPT IN A NEW WINDOW"
start "" "initAndScheduleReboot.bat"
timeout 5 > NUL

echo "********************************************************************************************"
echo "LAUNCH CHROME WITH TAMPERMONKEY AND SIGNUP ON STREAMING PLATFORMS"
start chrome "https://chrome.google.com/webstore/detail/tampermonkey/dhdgffkkebhmkfjojejmpbldmpobfkfo" "https://www.spotify.com/fr/signup/" "https://www.deezer.com/fr/register" "https://tidal.com/" "https://greasyfork.org/en/scripts/390641-monitoring-streaming-platform"
timeout 5 > NUL

echo "CONTENT OF STARTUP DIR :"
cd C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\ 
dir /s /b 

echo "END OF INIT VPS"
pause
