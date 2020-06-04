
#############################################################################
#
# Use at your own risk!
#
# This script creates and deletes a local admin account and vpn conneciton
#
#############################################################################


If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
  # Relaunch as an elevated process:
  Start-Process powershell.exe "-File",('"{0}"' -f $MyInvocation.MyCommand.Path) -Verb RunAs
  exit
}

$sharedKey = ""
$vpnName = "CEPlus"
$serverAddress = ""
$tunnelType = 'L2tp'
$authMethod = @('MSChapv2')
$rememberCredential = $true
$splitTunnel = $true

$userName = "CEPlus"
$userPass = ""

Write-Host "================================================================================" -ForegroundColor Green
Write-Host "Welcome to the remote CEPlus setup script" -ForegroundColor Green
Write-Host ""
Write-Host "This script will create a new VPN and new local admin account called 'CEPlus'" -ForegroundColor Green
Write-Host "================================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Press 1 to setup this PC to perform the CE Plus scan"
Write-Host "Press 2 to remove the settings from step 1"
Write-Host ""

$option = Read-Host -Prompt 'Enter your choice and press enter'

if($option -eq 1)
{
    Write-Host ""
    Write-Host "You pressed option 1"
    Write-Host "This script will now setup the PC ready to perform the CE Plus scan"
    Write-Host ""
        
    #Create VPN Connections
    Write-Host "Adding VPN 'CEPlus'"
    Add-VpnConnection -Name $vpnName -ServerAddress $serverAddress -TunnelType $tunnelType -AllUserConnection -AuthenticationMethod $authMethod -EncryptionLevel Optional -L2tpPsk $sharedKey -Force
    Start-Sleep -Milliseconds 100

    #Set Additional Settings
    Set-VpnConnection -AllUserConnection -Name $vpnName -SplitTunneling $splitTunnel -RememberCredential $rememberCredential 
    Write-Host "Done"

    #Setup Local Admin
    Write-Host "Creating local admin 'CEPlus'"
    $password = ConvertTo-SecureString $userPass -AsPlainText -Force
    $result = New-LocalUser $username -Password $password -FullName "CEPlus" -Description "Used to perform a vulnerability scan"
    Add-LocalGroupMember -Group "Administrators" -Member "CEPlus"
    Write-Host "Done" 

    Write-Host ""
    Write-Host "Please proceed to step 2 in the guide." -ForegroundColor Green
    Write-Host ""
}
elseif($option -eq 2)
{
    Write-Host ""
    Write-Host "You pressed option 2"
    Write-Host ""
    Write-Host "This script will now remove the settings added from option 1"
    Write-Host ""

    #Remove VPN
    Write-Host "Removing VPN"
    Remove-VpnConnection -Name $vpnName -AllUserConnection -Force
    Write-Host "Done"
    
    #Remove Local Admin
    Write-Host "Removing Local Admin"
    Remove-LocalUser "CEPlus"
    Write-Host "Done"
    
    Write-Host ""
    Write-Host "Please proceed to step 5 in the guide." -ForegroundColor Green
    Write-Host ""
}

Pause





