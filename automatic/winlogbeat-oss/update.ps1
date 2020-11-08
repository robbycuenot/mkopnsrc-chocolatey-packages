Import-Module au

$releases = 'https://www.elastic.co/downloads/beats/winlogbeat-oss'
$ChecksumType = 'SHA256'
function global:au_BeforeUpdate {
    $Latest.Checksum32 = Get-RemoteChecksum $Latest.URL32 -Algorithm $Latest.ChecksumType32
    $Latest.Checksum64 = Get-RemoteChecksum $Latest.URL64 -Algorithm $Latest.ChecksumType64
}
function global:au_GetLatest() {
    $download_page = Invoke-WebRequest $releases -UseBasicParsing
    $url     = $download_page.links | ? href -match '\windows-x86.msi$' | select -First 1 -expand href
    $url64     = $download_page.links | ? href -match '\windows-x86_64.msi$' | select -First 1 -expand href
    $version = $url -split '-' | select -Last 1 -Skip 2
    $releaseNotesUrl = $download_page.links | ? href -match 'release-notes.*.html$' | select -First 1 -expand href
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
      }
    }
}

if ($MyInvocation.InvocationName -ne '.') { 
  update -ChecksumFor none #-NoCheckChocoVersion 
}