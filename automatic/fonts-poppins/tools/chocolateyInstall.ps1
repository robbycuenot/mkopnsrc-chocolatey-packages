$ErrorActionPreference = 'Stop'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$url = 'https://fonts.google.com/download?family=Poppins'

$file = Join-Path $toolsDir 'Poppins.zip'

$packageArgs = @{
	packageName   = $env:ChocolateyPackageName
  version       = $env:ChocolateyPackageVersion
  FileFullPath  = $file
	Destination   = "$toolsDir\fonts"
	url           = $url
	checksum      = 'c0d3ef025721949a994d616007d6c59d3f3294005db959f6d36ffbd678a8121cb5fc44ba38bcf955823b6a0cee12965bc762441fdca7c6eb152f668d9ab45935'
	checksumType  = 'sha512'
}

#Download zip file from url
Get-ChocolateyWebFile @packageArgs
#Unzip zip file to tools\fonts dir
Get-ChocolateyUnzip @packageArgs
#Move OFL.txt License file from fonts dir to tools
Move-Item -Path "$($packageArgs.Destination)\OFL.txt" -Destination "$toolsDir" -Force | Out-Null

Install-ChocolateyFont $packageArgs.Destination -multiple