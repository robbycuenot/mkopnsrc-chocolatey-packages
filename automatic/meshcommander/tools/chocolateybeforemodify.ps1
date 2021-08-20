$WinPackageName = 'MeshCommander*'
$processName = 'nw'
$Proc = @("$processName")
$ProcActive = Get-Process -Name $Proc -ErrorAction SilentlyContinue

## Stop MeshCommander application if it is running during upgrade or uninstall
if($ProcActive){
	Write-Warning "Application $processName is currently running, the service will be stopped now."
	Get-Process -Name $processName | Stop-Process -Force
}