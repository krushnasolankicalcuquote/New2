Add-Type -AssemblyName System.IO.Compression.FileSystem

##==== Extract Folders in Inetpub Structure
$zipPath = 'E:\PipelineData\UK\PricingServices'
$extrectPath = 'E:\PipelineData\Inetpub\UK\PricingServices'
$destinationPath = 'E:\Inetpub\UK\PricingServices'
$timeout = [TimeSpan]::FromMinutes(10)

$data = @(
       
    [pscustomobject]@{FolderName = $zipPath + '\CQ_ManEx.zip'; serviceName = 'CQ_UK_ManEx'; ExtractPath = $extrectPath + '\ManEx'; }

    [pscustomobject]@{FolderName = $zipPath + '\CQ_Pricing.zip'; serviceName = 'CQ_UK_Pricing'; ExtractPath = $extrectPath + '\Pricing'; }
    [pscustomobject]@{FolderName = $zipPath + '\CQ_Pricing.zip'; serviceName = 'CQ_UK_Pricing_1'; ExtractPath = $extrectPath + '\Pricing_1'; }
    [pscustomobject]@{FolderName = $zipPath + '\CQ_Pricing.zip'; serviceName = 'CQ_UK_Pricing_2'; ExtractPath = $extrectPath + '\Pricing_2'; }
    [pscustomobject]@{FolderName = $zipPath + '\CQ_Pricing.zip'; serviceName = 'CQ_UK_Pricing_ISO'; ExtractPath = $extrectPath + '\Pricing_ISO'; }
    [pscustomobject]@{FolderName = $zipPath + '\CQ_Pricing.zip'; serviceName = 'CQ_UK_Pricing_SaveOnly'; ExtractPath = $extrectPath + '\Pricing_SaveOnly'; }

    [pscustomobject]@{FolderName = $zipPath + '\CQ_PricingExpiration.zip'; serviceName = 'CQ_UK_PricingExpiration'; ExtractPath = $extrectPath + '\CQ_PricingExpiration'; }
      
    [pscustomobject]@{FolderName = $zipPath + '\CQ_ArchiveService.zip'; serviceName = 'CQ_UK_ArchiveService'; ExtractPath = $extrectPath + '\CQ_ArchiveService'; }

    [pscustomobject]@{FolderName = $zipPath + '\CQ_EventWorkerService.zip'; serviceName = 'CQ_UK_EventWorkerService'; ExtractPath = $extrectPath + '\CQ_EventWorkerService'; }
)


function Unzip {
    param([string]$zipfile, [string]$outpath)

    [IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
    echo "Extract files succesfully: $zipfile"
    $true
}


## Stop Services
    
$data | ForEach-Object -pa {

    if (Test-Path -Path $_.FolderName) { 
        $serviceDef = Get-Service -Name $_.serviceName
        if ($serviceDef.Status -eq "Running") {
            Stop-Service -Name  $serviceDef.Name -Force
            echo "Stopping Service: " + $serviceDef.Name
        }
    }
}


# Wait for each service to stop
$data | ForEach-Object -pa {
        
    if (Test-Path -Path $_.FolderName) {
        $serviceDef = Get-Service -Name $_.serviceName -ErrorAction SilentlyContinue
        if ($serviceDef.Status -eq 'Running') {
            $serviceDef.WaitForStatus('Stopped', $timeout)
        }
    
        echo "Stopped Service: $serviceName"
    }
}


#Remove Existing Pipeline Data Folder
if (Test-Path -Path $extrectPath) {
    Write-Host 'Folder Deleted'
    Remove-Item -Path $extrectPath -Recurse -Force
}


##  UnZip Folders 
Foreach ($fol in $data) {
    if (Test-Path -Path $fol.FolderName) {
        Unzip $fol.FolderName $fol.ExtractPath;
    }
}


## Replce Folder
echo "Start Copy Folder"
robocopy  "$extrectPath" $destinationPath /s /is /it /im
#Copy-Item -Path "$extrectPath\*" -Destination $destinationPath -Recurse -Force

echo "End Copy Folder"
 
echo "Start replacing appettings data"
 
$pathToJson = "E:\Inetpub\UK\PricingServices\Pricing\appsettings.json"
$a = Get-Content $pathToJson | ConvertFrom-Json
$a.CanRegisterQuartzService = $true
$a | ConvertTo-Json | set-content $pathToJson

$pathToJson = "E:\Inetpub\UK\PricingServices\Pricing_ISO\appsettings.json"
$a = Get-Content $pathToJson | ConvertFrom-Json
$a.RabbitMQConfiguration.Pricing_RabbitMQHost = "rabbitmq://10.1.0.7:5672/CQ_UK_Pricing_ISO"
$a.CanRegisterQuartzService = $true
$a.SchedulerName = "QuoteCQAPI_Pricing_UK_ISO"
$a | ConvertTo-Json | set-content $pathToJson

$pathToJson = "E:\Inetpub\UK\PricingServices\Pricing_SaveOnly\appsettings.json"
$a = Get-Content $pathToJson | ConvertFrom-Json
$a.SavePricingMessageOnly = "1"
$a | ConvertTo-Json | set-content $pathToJson
 
echo "End replacing appettings data"


## Start Services 

$data | ForEach-Object -pa {
    if (Test-Path -Path $_.FolderName) {
        $serviceDef = Get-Service -Name $_.serviceName -ErrorAction SilentlyContinue

        if ($serviceDef.Status -eq "Stopped") {
            Start-Service -Name $serviceDef.Name -ErrorAction SilentlyContinue
            Echo "Start Service: " + $serviceDef.Name
        }
    }
}

## Again Start Services if Missed

Foreach ($fol in $data) {
    
    if (Test-Path -Path $fol.FolderName) {
        $serviceDef = Get-Service -Name $fol.serviceName -ErrorAction SilentlyContinue

        if ($serviceDef.Status -eq "Stopped") {
            Start-Service -Name $serviceDef.Name -ErrorAction SilentlyContinue
            Echo "Start Service: " + $serviceDef.Name
        }
    }
}

echo "Process Completed"
exit 0