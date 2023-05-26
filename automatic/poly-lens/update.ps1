Import-Module au

# Poly.com API to retrieve download URL for Windows
$PRE_URL = 'https://api.silica-prod01.io.lens.poly.com/graphql'
$HEADERS = @{
  "Content-Type" = "application/json"
  "Apollographql-Client-Name" = "poly.com-website"
}
$query = @{
  query = @"
      query {
          availableProductSoftwareByPid(pid:"lens-desktop-windows") {
              name
              version
              publishDate
              productBuild {
                  archiveUrl
              }
          }
      }
"@
}

$BODY = $query | ConvertTo-Json
$response = Invoke-RestMethod -Uri $PRE_URL -Method Post -Headers $HEADERS -Body $BODY
$json = $response.data.availableProductSoftwareByPid

$polylens = @{}
$polylens.name = $json.name
$polylens.version = $json.version
$polylens.url = $json.productBuild.archiveUrl

$ChecksumType = 'SHA256'

function global:au_BeforeUpdate {
    $Latest.Checksum32 = Get-RemoteChecksum $Latest.URL32 -Algorithm $Latest.ChecksumType32
    #$Latest.Checksum64 = Get-RemoteChecksum $Latest.URL64 -Algorithm $Latest.ChecksumType64

    #AU function Get-RemoteFiles can download files and save them in the package's tools directory. It does that by using the $Latest.URL32 and/or $Latest.URL64.
    #Get-RemoteFiles -Purge
}
function global:au_GetLatest() {
    $url = $polylens.url
    $version = $polylens.version
    $ext = $url.Split('.') |Select-Object -Last 1
    $Latest = @{
        InstallerType = $ext
        URL32     = $url
        #URL64     = $url64
        Version   = $version
        ChecksumType32 = $ChecksumType
        #ChecksumType64 = $ChecksumType
    }
    return $Latest
}
function global:au_SearchReplace {
    @{
      ".\tools\chocolateyInstall.ps1" = @{
        "(?i)(^\s*installerType\s*=\s*)('.*')" = "`$1'$($Latest.InstallerType)'"
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