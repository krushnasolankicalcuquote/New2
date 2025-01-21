Add-Type -AssemblyName System.IO.Compression.FileSystem
##==== Extract Folders in Inetpub Structure
$zipPath = 'Q:\PipelineData'
$extrectPath = 'Q:\PipelineData\Inetpub'
$destinationPath ='Q:\Inetpub'
$logPath = "Q:\PipelineData\CommonServiceLog.log"

try{
$data = @(
       [pscustomobject]@{FolderName=$zipPath +'\CQ_Currency.zip';serviceName ='CQ_APP_Currency' ;ExtractPath= $extrectPath + '\APP\CQ_Currency'; }
       [pscustomobject]@{FolderName=$zipPath +'\CQ_Currency.zip';serviceName ='CQ_ITAR_Currency';ExtractPath= $extrectPath + '\ITAR\CQ_Currency';}

       [pscustomobject]@{FolderName=$zipPath +'\CQ_CustomReport.zip';serviceName ='CQ_Common_CustomReport';ExtractPath= $extrectPath + '\CommonServices\CQ_CustomReport';}
       
       [pscustomobject]@{FolderName=$zipPath +'\CQ_MaintenanceService.zip';serviceName ='CQ_APP_Maintenance';ExtractPath= $extrectPath + '\APP\CQ_Maintenance';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_MaintenanceService.zip';serviceName ='CQ_APP_Maintenance_1';ExtractPath= $extrectPath + '\APP\CQ_Maintenance_1';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_MaintenanceService.zip';serviceName ='CQ_APP_Maintenance_2';ExtractPath= $extrectPath + '\APP\CQ_Maintenance_2';}

       [pscustomobject]@{FolderName=$zipPath +'\CQ_MaintenanceService.zip';serviceName ='CQ_ITAR_Maintenance';ExtractPath= $extrectPath + '\ITAR\CQ_Maintenance';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_MaintenanceService.zip';serviceName ='CQ_ITAR_Maintenance1';ExtractPath= $extrectPath + '\ITAR\CQ_Maintenance1';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_MaintenanceService.zip';serviceName ='CQ_ITAR_Maintenance2';ExtractPath= $extrectPath + '\ITAR\CQ_Maintenance2';}

       [pscustomobject]@{FolderName=$zipPath +'\CQ_QuoteCQService.zip';serviceName ='CQ__EU_QuoteCQService';ExtractPath= $extrectPath + '\EU\QuoteCQService';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_QuoteCQService.zip';serviceName ='CQ__EU_QuoteCQService_1';ExtractPath= $extrectPath + '\EU\QuoteCQService_1';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_QuoteCQService.zip';serviceName ='CQ__US_QuoteCQService';ExtractPath= $extrectPath + '\US\QuoteCQService';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_QuoteCQService.zip';serviceName ='CQ__US_QuoteCQService_1';ExtractPath= $extrectPath + '\US\QuoteCQService_1';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_QuoteCQService.zip';serviceName ='CQ__ITAR_QuoteCQService';ExtractPath= $extrectPath + '\ITAR\QuoteCQService';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_QuoteCQService.zip';serviceName ='CQ__ITAR_QuoteCQService_1';ExtractPath= $extrectPath + '\ITAR\QuoteCQService_1';}

       [pscustomobject]@{FolderName=$zipPath +'\CQ_Service.zip';serviceName ='CQ__EU_CQService';ExtractPath= $extrectPath + '\EU\CQService';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_Service.zip';serviceName ='CQ__EU_CQService_1';ExtractPath= $extrectPath + '\EU\CQService_1';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_Service.zip';serviceName ='CQ__EU_CQService_2';ExtractPath= $extrectPath + '\EU\CQService_2';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_Service.zip';serviceName ='CQ__US_CQService';ExtractPath= $extrectPath + '\US\CQService';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_Service.zip';serviceName ='CQ__US_CQService_1';ExtractPath= $extrectPath + '\US\CQService_1';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_Service.zip';serviceName ='CQ__US_CQService_2';ExtractPath= $extrectPath + '\US\CQService_2';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_Service.zip';serviceName ='CQ__ITAR_CQService';ExtractPath= $extrectPath + '\ITAR\CQService';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_Service.zip';serviceName ='CQ__ITAR_CQService_1';ExtractPath= $extrectPath + '\ITAR\CQService_1';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_Service.zip';serviceName ='CQ__ITAR_CQService_2';ExtractPath= $extrectPath + '\ITAR\CQService_2';}

       [pscustomobject]@{FolderName=$zipPath +'\CQ_Webhook.zip';serviceName ='CQ_APP_Webhook';ExtractPath= $extrectPath + '\APP\CQ_Webhook';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_Webhook.zip';serviceName ='CQ_ITAR_Webhook';ExtractPath= $extrectPath + '\ITAR\CQ_Webhook';}

       [pscustomobject]@{FolderName=$zipPath +'\CQ_WorkFlow.zip';serviceName ='CQ__EU_WorkFlow';ExtractPath= $extrectPath + '\EU\WorkFlow';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_WorkFlow.zip';serviceName ='CQ__EU_WorkFlow_1';ExtractPath= $extrectPath + '\EU\WorkFlow_1';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_WorkFlow.zip';serviceName ='CQ__US_WorkFlow';ExtractPath= $extrectPath + '\US\WorkFlow';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_WorkFlow.zip';serviceName ='CQ__US_WorkFlow_1';ExtractPath= $extrectPath + '\US\WorkFlow_1';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_WorkFlow.zip';serviceName ='CQ__ITAR_WorkFlow';ExtractPath= $extrectPath + '\ITAR\WorkFlow';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_WorkFlow.zip';serviceName ='CQ__ITAR_WorkFlow_1';ExtractPath= $extrectPath + '\ITAR\WorkFlow_1';}
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