Import-Module au

$URL = 'https://www.refinitiv.com/en/products/refinitiv-workspace/download-workspace'

$ChecksumType = 'SHA256'
function global:au_BeforeUpdate {
    $Latest.Checksum32 = Get-RemoteChecksum $Latest.URL32 -Algorithm $Latest.ChecksumType32
    #$Latest.Checksum64 = Get-RemoteChecksum $Latest.URL64 -Algorithm $Latest.ChecksumType64
    
    #AU function Get-RemoteFiles can download files and save them in the package's tools directory. It does that by using the $Latest.URL32 and/or $Latest.URL64.
    #Get-RemoteFiles -Purge
}
function global:au_GetLatest() {
    $download_page = Invoke-WebRequest $URL -UseBasicParsing
    $parsedHtml = $download_page.links | Where-Object href -match '.exe'

    [String]$Installer_URL = ($parsedHtml.href)|Select-String -Pattern '.exe$'
    [Version]$version = ($parsedHtml | Select-String '\d+(?:\.\d+)+').Matches.Value
    $ext = $Installer_URL.Split('.') |Select-Object -Last 1

    $Latest = @{
      InstallerType = $ext
      URL32     = $Installer_URL
      #URL64     = $url64
      Version   = $version.ToString() 
      ChecksumType32 = $ChecksumType
      #ChecksumType64 = $ChecksumType
    }
    return $Latest
}
function global:au_SearchReplace {
    @{
      ".\tools\chocolateyInstall.ps1" = @{
        "(?i)(^\s*FileType\s*=\s*)('.*')" = "`$1'$($Latest.InstallerType)'"
        "(?i)(^\s*Url\s*=\s*)('.*')" = "`$1'$($Latest.URL32)'"
        #"(?i)(^\s*Url64bit\s*=\s*)('.*')" = "`$1'$($Latest.URL64)'"
        "(?i)(^\s*Checksum\s*=\s*)('.*')" = "`$1'$($Latest.Checksum32)'"
        "(?i)(^\s*ChecksumType\s*=\s*)('.*')" = "`$1'$($Latest.ChecksumType32)'"
        #"(?i)(^\s*Checksum64\s*=\s*)('.*')" = "`$1'$($Latest.Checksum64)'"
        #"(?i)(^\s*ChecksumType64\s*=\s*)('.*')" = "`$1'$($Latest.ChecksumType64)'"
      };

     #"$($Latest.PackageName).nuspec" = @{
     #  "(<licenseUrl.*?)(\d+\.\d+)(.*?licenseUrl>)"    = "`${1}$([regex]::match($Latest.Version, "\d+\.\d+").Value)`${3}"
     #  "(<releaseNotes.*?)(\d+\.\d+)(.*?releaseNotes>)"    = "`${1}$([regex]::match($Latest.Version, "\d+\.\d+").Value)`${3}"
     #};
    }
}

if ($MyInvocation.InvocationName -ne '.') { 
  update -ChecksumFor none #-NoCheckChocoVersion
}