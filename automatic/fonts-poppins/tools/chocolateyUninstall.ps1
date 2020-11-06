$ErrorActionPreference = 'Stop'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
. $toolsDir\helpers.ps1

$fontsDir = Join-Path $toolsDir 'fonts'

$ListOfFontFileNames = Get-ChildItem $fontsDir -Name

Uninstall-ChocolateyFont $ListOfFontFileNames -multiple