Import-Module au

$releases = 'https://fonts.google.com/download?family=Poppins'
$version_url = 'https://community.chocolatey.org/packages/fonts-poppins/'
$ChecksumType = 'SHA256'
function global:au_BeforeUpdate {
    $Latest.Checksum32 = Get-RemoteChecksum $Latest.URL32 -Algorithm $Latest.ChecksumType32
    #$Latest.Checksum64 = Get-RemoteChecksum $Latest.URL64 -Algorithm $Latest.ChecksumType64

    #AU function Get-RemoteFiles can download files and save them in the package's tools directory. It does that by using the $Latest.URL32 and/or $Latest.URL64.
    #Get-RemoteFiles -Purge
}
function global:au_GetLatest() { 
    $url = $releases
    #$ext = $url.Split('.') |Select-Object -Last 1
    
    $version_page = Invoke-WebRequest $version_url -UseBasicParsing
    $version_list = (($version_page.links | Where-Object href -match '/packages.*\d+(?:\.\d)$').href |Select-String '\d+(?:\.\d+)+').Matches.Value
    if ($version_list.GetType().IsArray) {
      $cur_ver = [version]$version_list[0]
      $new_ver = [version]::new($cur_ver.Major, $cur_ver.Minor + 2)
    } else {
      $cur_ver = [version]$version_list
      $new_ver = [version]::new($cur_ver.Major, $cur_ver.Minor + 2)
    }
    
    $Latest = @{
        InstallerType = $ext
        URL32     = $url
        #URL64     = $url64
        Version   = $new_ver
        ChecksumType32 = $ChecksumType
        #ChecksumType64 = $ChecksumType
    }
    return $Latest
}
function global:au_SearchReplace {
    @{
      ".\tools\chocolateyInstall.ps1" = @{
        #"(?i)(^\s*installerType\s*=\s*)('.*')" = "`$1'$($Latest.InstallerType)'"
        "(?i)(^\s*url\s*=\s*)('.*')" = "`$1'$($Latest.URL32)'"
        #"(?i)(^\s*url64bit\s*=\s*)('.*')" = "`$1'$($Latest.URL64)'"
        "(?i)(^\s*checksum\s*=\s*)('.*')" = "`$1'$($Latest.Checksum32)'"
        "(?i)(^\s*checksumType\s*=\s*)('.*')" = "`$1'$($Latest.ChecksumType32)'"
        #"(?i)(^\s*checksum64\s*=\s*)('.*')" = "`$1'$($Latest.Checksum64)'"
        #"(?i)(^\s*checksumType64\s*=\s*)('.*')" = "`$1'$($Latest.ChecksumType64)'"
      };

    }
}
update -ChecksumFor none #-NoCheckChocoVersion