
Set-ExecutionPolicy unrestricted

$logfile='c:\powershell\audacity.log'

echo "Installing Audacity"
#echo "Installing Audacity" > $logfile

#[-RedirectStandardError <String> ] [-RedirectStandardInput <String> ] [-RedirectStandardOutput <String> ] 

#These WORK!!! HOLY SHIT!!
Start-Process -FilePath 'c:\powershell\audacity-win-2.1.2.exe' -ArgumentList '/VERYSILENT'  -RedirectStandardError 'c:\powershell\audacity-install.log'
#Start-Process -FilePath 'c:\powershell\audacity-win-2.1.2.exe' -ArgumentList '/VERYSILENT'  -RedirectStandardOutput 'c:\powershell\audacity-install.log'
#& c:\powershell\audacity-win-2.1.2.exe /VERYSILENT /log=c:\powershell\audacity-install.log

#Powershell is such a POS.
#These don't work:
#Start-Process -FilePath 'c:\powershell\audacity-win-2.1.2.exe' -ArgumentList '/VERYSILENT'  -Debug
#Start-Process -FilePath 'c:\powershell\audacity-win-2.1.2.exe' -ArgumentList '/VERYSILENT'
#$balls = Start-Process -FilePath 'c:\powershell\audacity-win-2.1.2.exe' -ArgumentList '/VERYSILENT' -Wait -PassThru
#$balls = Start-Process -FilePath 'c:\powershell\audacity-win-2.1.2.exe' -ArgumentList '/VERYSILENT' -PassThru
#Start-Process -FilePath 'c:\powershell\audacity-win-2.1.2.exe' -ArgumentList '/VERYSILENT /log=c:\powershell\audacity-install.log'


