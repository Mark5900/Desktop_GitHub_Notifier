Import-Module PoshTaskbarItem
<#
    .NOTES
    ===========================================================================
    Created with:	Visual Studio Code
    Created on:		01-08-2023
    Created by:		Mark5900
    Organization:	
    Filename:		Setup.ps1
    ===========================================================================
    .DESCRIPTION
        TODO: A description of the file.
#>
##################
### PARAMETERS ###
##################
# Change as needed
$InstallPath = 'C:\PowerShell'
$SolutionName = 'GitHub_Notifier'

#################
### FUNCTIONS ###
#################
function CreatePath {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )
    if (!(Test-Path $Path)) {
        New-Item -Path $Path -ItemType Directory -Force
    }
}

##############
### SCRIPT ###
##############
# Create the install path
$FullDestinationPath = Join-Path $InstallPath $SolutionName

CreatePath -Path $InstallPath
CreatePath -Path $FullDestinationPath

# Copy the files
$ScriptPath = Join-Path $PSScriptRoot 'Desktop_GitHub_Notifier.ps1'
$ScriptDestinationPath = Join-Path $FullDestinationPath 'Desktop_GitHub_Notifier.ps1'
Copy-Item -Path $ScriptPath -Destination $ScriptDestinationPath -Force

$PngPath = Join-Path $PSScriptRoot 'github-icon.png'
$PngDestinationPath = Join-Path $FullDestinationPath 'github-icon.png'
Copy-Item -Path $PngPath -Destination $PngDestinationPath -Force

# Create token file
$TokenPath = Join-Path $FullDestinationPath 'github_token.txt'
if (!(Test-Path $TokenPath)) {
    New-Item -Path $TokenPath -ItemType File -Force
}
Read-Host -Prompt 'Enter your GitHub token and press enter.' | Out-File -FilePath $TokenPath

# Create the shortcut
$params = @{
    Path             = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\GitHub Notifier.lnk"
    IconResourcePath = $PngDestinationPath
    TargetPath       = 'pwsh.exe'
    Arguments        = '-ExecutionPolicy Bypass -WindowStyle Hidden -NoProfile -File "{0}"' -f $ScriptDestinationPath
    WindowStyle      = 'Minimized'
}
New-TaskbarItemShortcut @params

$params.Path = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\startup\GitHub Notifier.lnk"
New-TaskbarItemShortcut @params