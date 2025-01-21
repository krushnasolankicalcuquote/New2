Add-Type -AssemblyName System.IO.Compression.FileSystem
##==== Extract Folders in Inetpub Structure
$zipPath = 'Q:\PipelineData\US\CommonServices'
$extrectPath = 'Q:\PipelineData\Inetpub\US\CommonServices'
$destinationPath ='Q:\Inetpub\US'
$logPath = "Q:\PipelineData\US\CommonServiceLog.log"

try{
$data = @(
       [pscustomobject]@{FolderName=$zipPath +'\CQ_Currency.zip';serviceName ='CQ__US_Currency';ExtractPath= $extrectPath + '\CQ_Currency';}
       
       [pscustomobject]@{FolderName=$zipPath +'\CQ_MaintenanceService.zip';serviceName ='CQ__US_Maintenance';ExtractPath= $extrectPath + '\CQ_Maintenance';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_MaintenanceService.zip';serviceName ='CQ__US_Maintenance1';ExtractPath= $extrectPath + '\CQ_Maintenance1';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_MaintenanceService.zip';serviceName ='CQ__US_Maintenance2';ExtractPath= $extrectPath + '\CQ_Maintenance2';}

       [pscustomobject]@{FolderName=$zipPath +'\CQ_QuoteCQService.zip';serviceName ='CQ__US_QuoteCQService';ExtractPath= $extrectPath + '\QuoteCQService';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_QuoteCQService.zip';serviceName ='CQ__US_QuoteCQService_1';ExtractPath= $extrectPath + '\QuoteCQService_1';}

       [pscustomobject]@{FolderName=$zipPath +'\CQ_Service.zip';serviceName ='CQ__US_CQService';ExtractPath= $extrectPath + '\CQService';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_Service.zip';serviceName ='CQ__US_CQService_1';ExtractPath= $extrectPath + '\CQService_1';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_Service.zip';serviceName ='CQ__US_CQService_2';ExtractPath= $extrectPath + '\CQService_2';}

       [pscustomobject]@{FolderName=$zipPath +'\CQ_Webhook.zip';serviceName ='CQ__US_Webhook';ExtractPath= $extrectPath + '\CQ_Webhook';}

       [pscustomobject]@{FolderName=$zipPath +'\CQ_WorkFlow.zip';serviceName ='CQ__US_WorkFlow';ExtractPath= $extrectPath + '\WorkFlow';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_WorkFlow.zip';serviceName ='CQ__US_WorkFlow_1';ExtractPath= $extrectPath + '\WorkFlow_1';}
   )


function Unzip
{
  param([string]$zipfile, [string]$outpath)
  try {
        [IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
        echo "Extract files succesfully: $zipfile" 
        $true
  } 
  catch {
        echo "Can't unzip the file: $zipfile" + $Error
        $false
  }
}

  ## Stop Services 

$data | ForEach-Object -pa {
  if(Test-Path -Path $_.FolderName)
    {
        $serviceDef = Get-Service -Name $_.serviceName

        if($serviceDef.Status -eq "Running")
            {
                Stop-Service -Name $serviceDef.Name
                Echo "Stoping Service: " + $serviceDef.Name
            }
    }
} 


  #Remove Existing Folder
if(Test-Path -Path $extrectPath)
{
        Write-Host 'Folder Deleted'
        Remove-Item -Path $extrectPath -Recurse -Force
}

 ##  UnZip Folders 
Foreach($fol in $data)
{
    if(Test-Path -Path $fol.FolderName)
    {
        Unzip $fol.FolderName $fol.ExtractPath;
    }
}


 ## Replce Folder
 Echo "Copy Start"

robocopy  "$extrectPath" $destinationPath /s /is /it /im
#Copy-Item -Path "$extrectPath\*" -Destination $destinationPath -Recurse -Force

Echo "Copy End"


 ## Start Services 
$data | ForEach-Object -pa {
    if(Test-Path -Path $_.FolderName)
    {
        $serviceDef = Get-Service -Name $_.serviceName -ErrorAction SilentlyContinue

        if($serviceDef.Status -eq "Stopped")
            {
                Start-Service -Name $serviceDef.Name -ErrorAction SilentlyContinue
                Echo "Start Service: " + $serviceDef.Name
            }
    }
}

## Again Start Services if Failed

Foreach($fol in $data)
{
    if(Test-Path -Path $fol.FolderName)
    {
        $serviceDef = Get-Service -Name $fol.serviceName -ErrorAction SilentlyContinue

        if($serviceDef.Status -eq "Stopped")
            {
                Start-Service -Name $serviceDef.Name -ErrorAction SilentlyContinue
                Echo "Start Service: " + $serviceDef.Name
            }
    }
}

 echo "Process Completed"
 exit 0
}
catch
{
   Add-content $logPath "Exception occured : Common Servic Failed"
   Add-content $logPath $_
}