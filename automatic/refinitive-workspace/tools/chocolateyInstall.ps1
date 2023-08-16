$ErrorActionPreference = 'Stop'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
. $toolsDir\helpers.ps1

$UserTemp = $env:TEMP
$LogPath =  $UserTemp + "\$env:ChocolateyPackageName"
if(-not (Test-Path $LogPath)) { New-Item -ItemType Directory -Name $env:ChocolateyPackageName -Path $UserTemp -Force | Out-Null}

$packageArgs = @{
  PackageName    = $env:ChocolateyPackageName
  SoftwareName   = 'Refinitive Workspace*'
  Version        = $env:ChocolateyPackageVersion
  FileType       = 'exe'
  Url            = 'https://cdn.refinitiv.com/public/packages/Workspace/RefinitivWorkspace-installer_1.22.303.exe'
  #url64bit      = ''
  checksum       = '3aa7c31ae3996541e7030a866355bb36d5c223578ab00a8c89cb8df998c4610c'
  checksumType   = 'SHA256' #default is md5, can also be sha1, sha256 or sha512
  #checksum64    = ''
  #checksumType64= '' #default is checksumType
  SilentArgs     = "--silent --forceInstall --lang=en --machine-autoupdate-no --shortcut-workspace=TRUE --shortcut-excel=FALSE --installerlogpath='$LogPath'"
  #Exit codes for ms http://msdn.microsoft.com/en-us/library/aa368542(VS.85).aspx
  validExitCodes = @(
    0, # success
    3010, # success, restart required
    2147781575, # pending restart required
    2147205120  # pending restart required for setup update
  )
}

$alreadyInstalled = (AlreadyInstalled -AppName $packageArgs['softwareName'] -AppVersion $packageArgs['version'])

if ($alreadyInstalled -and ($env:ChocolateyForce -ne $true)) {
  Write-Output $(
    $packageArgs['softwareName']+" is already installed. " +
    'if you want to re-install, use "--force" option to re-install.'
  )
} else {
	Install-ChocolateyPackage @packageArgs
}
