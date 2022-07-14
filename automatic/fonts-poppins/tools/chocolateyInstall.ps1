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
	checksum      = '2376d3a1dd5c9e54a9ab34882a46f409dd91132977e7ca33711e484566c1125c'
	checksumType  = 'sha256'
}

#Download zip file from url
Get-ChocolateyWebFile @packageArgs
#Unzip zip file to tools\fonts dir
Get-ChocolateyUnzip @packageArgs
#Move OFL.txt License file from fonts dir to tools
Move-Item -Path "$($packageArgs.Destination)\OFL.txt" -Destination "$toolsDir" -Force | Out-Null

Install-ChocolateyFont $packageArgs.Destination -multiple