$ErrorActionPreference = 'Stop'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
. $toolsDir\helpers.ps1

$packageArgs = @{
	packageName     = $env:ChocolateyPackageName
	softwareName    = 'Modern CSV'
  version         = $env:ChocolateyPackageVersion
	unzipLocation   = $toolsDir
	installerType   = 'msi'
	url             = 'https://www.moderncsv.com/release/ModernCSV-Win32-v1.3.30.msi'
  url64bit        = 'https://www.moderncsv.com/release/ModernCSV-Win-v1.3.30.msi'
	checksum        = 'ad2d4944794490b2fbed44d3abf641c567a461c8e0cdcc8bdaa69c0d8ac761a1'
	checksumType    = 'SHA256'
  checksum64      = '586db13aaabf124404b2ce134d7acff7bf66a68878b476a8f92a9dce3cd9f1d9'
	checksumType64  = 'SHA256'
	silentArgs      = "/qn /norestart"
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
