Add-Type -AssemblyName System.IO.Compression.FileSystem
##==== Extract Folders in Inetpub Structure
$zipPath = 'Q:\PipelineData\EU\PricingServices'
$extrectPath = 'Q:\PipelineData\Inetpub\EU\PricingServices'
$destinationPath = 'Q:\Inetpub\EU'
$timeout = [TimeSpan]::FromMinutes(10)

$data = @(
       
    [pscustomobject]@{FolderName = $zipPath + '\CQ_ManEx.zip'; serviceName = 'CQ__EU_ManEx'; ExtractPath = $extrectPath + '\ManEx'; }

    [pscustomobject]@{FolderName = $zipPath + '\CQ_Pricing.zip'; serviceName = 'CQ__EU_Pricing'; ExtractPath = $extrectPath + '\Pricing'; }
    [pscustomobject]@{FolderName = $zipPath + '\CQ_Pricing.zip'; serviceName = 'CQ__EU_Pricing_SaveOnly'; ExtractPath = $extrectPath + '\Pricing_SaveOnly'; }

    [pscustomobject]@{FolderName = $zipPath + '\CQ_PricingExpiration.zip'; serviceName = 'CQ__EU_PricingExpiration'; ExtractPath = $extrectPath + '\CQ_PricingExpiration'; }

    [pscustomobject]@{FolderName = $zipPath + '\CQ_ArchiveService.zip'; serviceName = 'CQ__EU_ArchiveService'; ExtractPath = $extrectPath + '\CQ_ArchiveService'; }

    [pscustomobject]@{FolderName = $zipPath + '\CQ_EventWorkerService.zip'; serviceName = 'CQ__EU_EventWorkerService'; ExtractPath = $extrectPath + '\CQ_EventWorkerService'; }
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
 
$pathToJson = "Q:\Inetpub\EU\Pricing\appsettings.json"
$a = Get-Content $pathToJson | ConvertFrom-Json
$a.CanRegisterQuartzService = $true
$a | ConvertTo-Json | set-content $pathToJson
 
echo "End replacing appettings data"

echo "Process Completed"
exit 0