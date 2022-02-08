$ErrorActionPreference = 'Stop'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
. $toolsDir\helpers.ps1

$packageArgs = @{
	packageName     = $env:ChocolateyPackageName
	softwareName    = "Beats $($env:ChocolateyPackageName)*"
  version         = $env:ChocolateyPackageVersion
	unzipLocation   = $toolsDir
	installerType   = 'msi'
	url             = 'https://artifacts.elastic.co/downloads/beats/heartbeat/heartbeat-oss-7.17.0-windows-x86.msi'
	url64bit        = 'https://artifacts.elastic.co/downloads/beats/heartbeat/heartbeat-oss-7.17.0-windows-x86_64.msi'
	checksum        = '9708856c5104f3f0002fedd8bbc8c6be7f80d1d202dc16f9a77ac71b1e670e9e'
	checksumType    = 'SHA256'
	checksum64      = '271d25f4cf1aa55c261f08f4904648bbdac674acebfd9086715d899fabeb1dce'
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
  
  Write-Output "
  ###################### Heartbeat Configuration ########################
  Heartbeat Config File Location: 
    
    $env:programdata\Elastic\Beats\heartbeat\heartbeat.yml
    
    You can find the full configuration reference here:
    https://www.elastic.co/guide/en/beats/heartbeat/current/index.html
  ###################### ######################## ########################
  "
}
