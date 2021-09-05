$ErrorActionPreference = 'Stop'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
. $toolsDir\helpers.ps1

$packageArgs = @{
	packageName   = $env:ChocolateyPackageName
	softwareName  = 'Beats winlogbeat-oss*'
  version       = $env:ChocolateyPackageVersion
	unzipLocation = $toolsDir
	installerType = 'msi'
	url           = 'https://artifacts.elastic.co/downloads/beats/winlogbeat/winlogbeat-oss-7.14.1-windows-x86.msi'
	url64bit      = 'https://artifacts.elastic.co/downloads/beats/winlogbeat/winlogbeat-oss-7.14.1-windows-x86_64.msi'
	checksum      = '4542128fd4518abd0f1eec69a45d12f6db50418c02bf11d78deb1a74290ea054'
	checksumType  = 'SHA256' #default is md5, can also be sha1, sha256 or sha512
	checksum64    = '3d3513d632886675004e3c7b599c5f60bb0ea2abf4652fc4647063ef1e5ca5ad'
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
