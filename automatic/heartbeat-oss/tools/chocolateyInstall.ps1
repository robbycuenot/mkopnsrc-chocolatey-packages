$ErrorActionPreference = 'Stop'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
. $toolsDir\helpers.ps1

$packageArgs = @{
	packageName     = $env:ChocolateyPackageName
	softwareName    = "Beats $($env:ChocolateyPackageName)*"
  version         = $env:ChocolateyPackageVersion
	unzipLocation   = $toolsDir
	installerType   = 'msi'
	url             = 'https://artifacts.elastic.co/downloads/beats/heartbeat/heartbeat-oss-7.14.1-windows-x86.msi'
	url64bit        = 'https://artifacts.elastic.co/downloads/beats/heartbeat/heartbeat-oss-7.14.1-windows-x86_64.msi'
	checksum        = 'a10519d3a7198ea8b65675538e0d40fa1e12779fac3f470d4288c398df21543c'
	checksumType    = 'SHA256'
	checksum64      = 'd44e9173a132b7b2bf7bad9e75b8c3f981bc0a51c25a6fd77b4adf4c45b76e91'
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
