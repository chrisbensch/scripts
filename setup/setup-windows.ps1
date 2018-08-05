#   Description:
# This script will use Windows package manager to bootstrap Chocolatey and
# install a list of packages. Script will also install Sysinternals Utilities
# into your default drive's root directory.

$packages = @(
    "sublimetext3"
    "googlechrome"
    "adobereader"
    "jre8"
    "firefox"
    "7zip.install"
    "git.install"
    "putty.install"
    "ccleaner"
    "sysinternals"
    "filezilla"
    "keepass.install"
    "python2"
    "conemu"
    "wireshark"
    "python3"
    "poshgit"
    "nmap"
    "tightvnc"
    "tor-browser"
    "mremoteng"
    "dbeaver"
    "visualstudio2017community"
)

echo "Setting up Chocolatey software package manager"
Get-PackageProvider -Name chocolatey -Force

echo "Setting up Full Chocolatey Install"
Install-Package -Name Chocolatey -Force -ProviderName chocolatey
$chocopath = (Get-Package chocolatey | ?{$_.Name -eq "chocolatey"} | Select @{N="Source";E={((($a=($_.Source -split "\\"))[0..($a.length - 2)]) -join "\"),"Tools\chocolateyInstall" -join "\"}} | Select -ExpandProperty Source)
& $chocopath "upgrade all -y"
choco install chocolatey-core.extension --force

echo "Creating daily task to automatically upgrade Chocolatey packages"
# adapted from https://blogs.technet.microsoft.com/heyscriptingguy/2013/11/23/using-scheduled-tasks-and-scheduled-jobs-in-powershell/
$ScheduledJob = @{
    Name = "Chocolatey Daily Upgrade"
    ScriptBlock = {choco upgrade all -y}
    Trigger = New-JobTrigger -Daily -at 2am
    ScheduledJobOption = New-ScheduledJobOption -RunElevated -MultipleInstancePolicy StopExisting -RequireNetwork
}
Register-ScheduledJob @ScheduledJob

echo "Installing Packages"
$packages | %{choco install $_ --force -y}

