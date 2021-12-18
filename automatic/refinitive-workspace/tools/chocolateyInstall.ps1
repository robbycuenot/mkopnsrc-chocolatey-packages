$ErrorActionPreference = 'Stop'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
. $toolsDir\helpers.ps1

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  softwareName   = 'Refinitive Workspace*'
  version        = $env:ChocolateyPackageVersion
  unzipLocation  = $toolsDir
  installerType  = 'exe'
  url            = 'https://cdn.refinitiv.com/public/packages/Workspace/RefinitivWorkspace-installer_1.16.389.exe'
  #url64bit      = ''
  checksum       = '64ec0bab8eb8778fdd706e833c39ecc2a0e2733bb3a695b9a8285f306f91fe11'
  checksumType   = 'SHA256' #default is md5, can also be sha1, sha256 or sha512
  #checksum64    = ''
  #checksumType64= '' #default is checksumType
  silentArgs     = "--silent --forceInstall --lang=en --machine-autoupdate-no"
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
