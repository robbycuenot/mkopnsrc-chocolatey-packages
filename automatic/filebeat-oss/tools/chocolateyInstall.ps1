$ErrorActionPreference = 'Stop'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
. $toolsDir\helpers.ps1

$packageArgs = @{
	packageName     = $env:ChocolateyPackageName
	softwareName    = 'Beats filebeat-oss*'
  version         = $env:ChocolateyPackageVersion
	unzipLocation   = $toolsDir
	installerType   = 'msi'
	url             = 'https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-oss-7.10.0-windows-x86.msi'
	url64bit        = 'https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-oss-7.10.0-windows-x86_64.msi'
	checksum        = '379b79cf88bbe354e12a739aadbee34340dd566f6660d41734ca7fd3c792cc1f'
	checksumType    = 'SHA256'
	checksum64      = '2b9e8827a117c4382f612b6d95fc382dd0180d19c9f0c0257b4e49748f2d1175'
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
  ###################### Filebeat Configuration ########################
    Filebeat Config File Location: 
    
    $env:programdata\Elastic\Beats\filebeat\filebeat.yml
    
    You can find the full configuration reference here:
    https://www.elastic.co/guide/en/beats/filebeat/index.html
  ###################### ######################## ########################
  "
}
