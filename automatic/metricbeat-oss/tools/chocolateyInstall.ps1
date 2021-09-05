$ErrorActionPreference = 'Stop'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
. $toolsDir\helpers.ps1

$packageArgs = @{
	packageName     = $env:ChocolateyPackageName
	softwareName    = "Beats $($env:ChocolateyPackageName)*"
  version         = $env:ChocolateyPackageVersion
	unzipLocation   = $toolsDir
	installerType   = 'msi'
	url             = 'https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-oss-7.14.1-windows-x86.msi'
	url64bit        = 'https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-oss-7.14.1-windows-x86_64.msi'
	checksum        = '909d213723ff43ad1a1c85ecb35dd905d965777ab3241e8e7f769ad9c9dc8824'
	checksumType    = 'SHA256'
	checksum64      = '078010d1d76f2cfd088ae2f3fe98c97156ac10d7e1a679256098c035389c43c6'
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
  ###################### Metricbeat Configuration ########################
  Metricbeat Config File Location: 
    
    $env:programdata\Elastic\Beats\metricbeat\metricbeat.yml
    
    You can find the full configuration reference here:
    https://www.elastic.co/guide/en/beats/metricbeat/current/index.html
  ###################### ######################## ########################
  "
}
