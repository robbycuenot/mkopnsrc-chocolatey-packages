$ErrorActionPreference = 'Stop'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$fontsDir = Join-Path $toolsDir 'fonts'

$ListOfFontFileNames = Get-ChildItem $fontsDir -Name

Uninstall-ChocolateyFont $ListOfFontFileNames -multiple