$ErrorActionPreference = 'Stop'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
. $toolsDir\helpers.ps1

$packageArgs = @{
	packageName     = $env:ChocolateyPackageName
	softwareName    = 'Beats packetbeat-oss*'
  version         = $env:ChocolateyPackageVersion
	unzipLocation   = $toolsDir
	installerType   = 'msi'
	url             = 'https://artifacts.elastic.co/downloads/beats/packetbeat/packetbeat-oss-7.13.4-windows-x86.msi'
	url64bit        = 'https://artifacts.elastic.co/downloads/beats/packetbeat/packetbeat-oss-7.13.4-windows-x86_64.msi'
	checksum        = 'ff9144d1b08b52528955e5a77135b3574f59a58db4d687579c4abfaa37cdeac1'
	checksumType    = 'SHA256'
	checksum64      = 'f5a6e36707fbca13f9244da38a2de3efb95c18fa25d57dd21ef17a703c5a909d'
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
  ###################### Packetbeat Configuration ########################
    Packetbeat Config File Location: 
    
    $env:programdata\Elastic\Beats\packetbeat\packetbeat.yml
    
    You can find the full configuration reference here:
    https://www.elastic.co/guide/en/beats/packetbeat/current/index.html
  ###################### ######################## ########################
  "
}
