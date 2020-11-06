$ErrorActionPreference = 'Stop'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
. $toolsDir\helpers.ps1

# 32bit installer
$url = 'https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-oss-7.9.3-windows-x86.msi'
# 64bit installer
$url64 = 'https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-oss-7.9.3-windows-x86_64.msi'

$packageArgs = @{
	packageName   = $env:ChocolateyPackageName
	softwareName  = 'Beats filebeat-oss*'
  version       = $env:ChocolateyPackageVersion
	unzipLocation = $toolsDir
	installerType = 'msi'
	url           = $url
	url64bit      = $url64
	checksum      = '15d0995813d0e6d02c0d63470d770577f23c8164da20fe234fde4ad672a4512f809f228678398cfc29a1fc5efc21c9363f69de0d2256269b0838302030cdd1e9'
	checksumType  = 'sha512' #default is md5, can also be sha1, sha256 or sha512
	checksum64    = '822ee916e0d8284a50a836214ee4c26adc04c4edba136a0d810b6461ec474d0b343976f4df72abad90758f6187cadf4e19fd265bb68c5d76e1c075b961ac6086'
	checksumType64= 'sha512' #default is checksumType
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
  ###################### Filebeat Configuration ########################
    Filebeat Config File Location: 
    
    $env:programdata\Elastic\Beats\filebeat\filebeat.yml
    
    You can find the full configuration reference here:
    https://www.elastic.co/guide/en/beats/filebeat/index.html
  ###################### ######################## ########################
  "
}