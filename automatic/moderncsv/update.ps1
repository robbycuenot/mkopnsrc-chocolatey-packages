Import-Module au
$domain = 'https://www.moderncsv.com'
$releases = "$domain/download/"
$ChecksumType = 'SHA256'
function global:au_BeforeUpdate {
    $Latest.Checksum32 = Get-RemoteChecksum $Latest.URL32 -Algorithm $Latest.ChecksumType32
    $Latest.Checksum64 = Get-RemoteChecksum $Latest.URL64 -Algorithm $Latest.ChecksumType64

    #AU function Get-RemoteFiles can download files and save them in the package's tools directory. It does that by using the $Latest.URL32 and/or $Latest.URL64.
    #Get-RemoteFiles -Purge
}
function global:au_GetLatest() {
    $download_page = Invoke-WebRequest $releases -UseBasicParsing
    $url      = ($download_page.links | Where-Object href -match 'Win32-.*.msi$' | Select-Object -First 1 -expand href).Replace('..', $domain)
    $url64    = ($download_page.links | Where-Object href -match 'Win-.*.msi$' | Select-Object -First 1 -expand href).Replace('..', $domain)
    $version  = ($url -split '/' | Select-Object -Last 1 -Skip 0) | Select-String '((?:\d{1,4}\.){2}\d{1,4})' | ForEach-Object { $_.Matches[0].Groups[1].Value }
    $Latest = @{
        URL32     = $url
        URL64     = $url64
        Version   = $version
        ChecksumType32 = $ChecksumType
        ChecksumType64 = $ChecksumType
    }
    return $Latest
}
function global:au_SearchReplace {
    @{
      ".\tools\chocolateyInstall.ps1" = @{
        "(?i)(^\s*url\s*=\s*)('.*')" = "`$1'$($Latest.URL32)'"
        "(?i)(^\s*url64bit\s*=\s*)('.*')" = "`$1'$($Latest.URL64)'"
        "(?i)(^\s*checksum\s*=\s*)('.*')" = "`$1'$($Latest.Checksum32)'"
        "(?i)(^\s*checksumType\s*=\s*)('.*')" = "`$1'$($Latest.ChecksumType32)'"
        "(?i)(^\s*checksum64\s*=\s*)('.*')" = "`$1'$($Latest.Checksum64)'"
        "(?i)(^\s*checksumType64\s*=\s*)('.*')" = "`$1'$($Latest.ChecksumType64)'"
      };

    }
}
update -ChecksumFor none #-NoCheckChocoVersion