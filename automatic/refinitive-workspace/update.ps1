Import-Module au

# Selenium Driver directory
$selenium_driver = ".\selenium\"

# Import selenium webdriver dll module
Import-Module "$($selenium_driver)\WebDriver.dll"

$DriverOptions = New-Object OpenQA.Selenium.Edge.EdgeOptions
#$DriverOptions.DebuggerAddress='localhost:9222'
#$DriverOptions.UseChromium=$true

# Create a new ChromeDriver Object instance.
$Driver = New-Object OpenQA.Selenium.Edge.EdgeDriver($DriverOptions)
#$Driver = New-Object OpenQA.Selenium.Chrome.ChromeDriver($DriverOptions)

# Launch a browser and go to URL
$Driver.Navigate().GoToUrl('https://workspace.refinitiv.com/Apps/MessengerProductPage/1.0.16/')

#$XPathURL = $Driver.FindElementByName("html/body/iframe").getAttribute("src")
#$Driver.Navigate().GoToURL($XPathURL)
# Download for Windows Link XPath: //*[@id="externalContainer"]/div[1]/div[3]/div/div[1]/a[1]
$RefinitiveExeLink = $Driver.FindElement([OpenQA.Selenium.By]::XPath('//*[@id="externalContainer"]/div[1]/div[3]/div/div[1]/a[1]')).GetAttribute('href')

# Cleanup
$Driver.Close()
$Driver.Quit()

$ChecksumType = 'SHA256'
function global:au_BeforeUpdate {
    $Latest.Checksum32 = Get-RemoteChecksum $Latest.URL32 -Algorithm $Latest.ChecksumType32
    #$Latest.Checksum64 = Get-RemoteChecksum $Latest.URL64 -Algorithm $Latest.ChecksumType64
    
    #AU function Get-RemoteFiles can download files and save them in the package's tools directory. It does that by using the $Latest.URL32 and/or $Latest.URL64.
    #Get-RemoteFiles -Purge
}
function global:au_GetLatest() {
    $url     = $RefinitiveExeLink
    $version = ($RefinitiveExeLink | Select-String '\d+(?:\.\d+)+').Matches.Value
    #$releaseNotesUrl = $download_page.links | ? href -match 'release-notes.*.html$' | select -First 1 -expand href
    $ext = $RefinitiveExeLink.Split('.') |Select-Object -Last 1

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

     #"$($Latest.PackageName).nuspec" = @{
     #  "(<licenseUrl.*?)(\d+\.\d+)(.*?licenseUrl>)"    = "`${1}$([regex]::match($Latest.Version, "\d+\.\d+").Value)`${3}"
     #  "(<releaseNotes.*?)(\d+\.\d+)(.*?releaseNotes>)"    = "`${1}$([regex]::match($Latest.Version, "\d+\.\d+").Value)`${3}"
     #};
    }
}

if ($MyInvocation.InvocationName -ne '.') { 
  update -ChecksumFor none -NoCheckChocoVersion
}