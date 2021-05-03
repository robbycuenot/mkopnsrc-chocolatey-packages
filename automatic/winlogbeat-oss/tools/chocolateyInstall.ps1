$ErrorActionPreference = 'Stop'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
. $toolsDir\helpers.ps1

$packageArgs = @{
	packageName   = $env:ChocolateyPackageName
	softwareName  = 'Beats winlogbeat-oss*'
  version       = $env:ChocolateyPackageVersion
	unzipLocation = $toolsDir
	installerType = 'msi'
	url           = 'https://artifacts.elastic.co/downloads/beats/winlogbeat/winlogbeat-oss-7.12.1-windows-x86.msi'
	url64bit      = 'https://artifacts.elastic.co/downloads/beats/winlogbeat/winlogbeat-oss-7.12.1-windows-x86_64.msi'
	checksum      = '8d4dd732b25a86df7007739b975be1f4b918e1926623ed8e0160ee83f5081f61'
	checksumType  = 'SHA256' #default is md5, can also be sha1, sha256 or sha512
	checksum64    = '22d4935ee95002d81ba699cf1b31da09fb3d0cce26eb21675cd4c52991056fff'
	checksumType64= 'SHA256' #default is checksumType
	silentArgs = "/qn /norestart"
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
  ###################### Winlogbeat Configuration ########################
    Winlogbeat Config File Location: 
    
    $env:programdata\Elastic\Beats\winlogbeat\winlogbeat.yml
    
    You can find the full configuration reference here:
    https://www.elastic.co/guide/en/beats/winlogbeat/index.html
  ###################### ######################## ########################
  "
}
