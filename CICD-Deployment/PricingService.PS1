Add-Type -AssemblyName System.IO.Compression.FileSystem
##==== Extract Folders in Inetpub Structure
$zipPath = 'Q:\PipelineData'
$extrectPath = 'Q:\PipelineData\Inetpub'
$destinationPath ='Q:\Inetpub'
$logPath = "Q:\PipelineData\PricingServiceLog.log"

try {
$data = @(
       [pscustomobject]@{FolderName=$zipPath +'\CQ_ManEx.zip';serviceName ='CQ__US_ManEx' ;ExtractPath= $extrectPath + '\US\ManEx'; }
       [pscustomobject]@{FolderName=$zipPath +'\CQ_ManEx.zip';serviceName ='CQ__EU_ManEx';ExtractPath= $extrectPath + '\EU\ManEx';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_ManEx.zip';serviceName ='CQ__ITAR_ManEx';ExtractPath= $extrectPath + '\ITAR\ManEx';}

       [pscustomobject]@{FolderName=$zipPath +'\CQ_Pricing.zip';serviceName ='CQ__EU_Pricing';ExtractPath= $extrectPath + '\EU\Pricing';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_Pricing.zip';serviceName ='CQ__EU_Pricing_1';ExtractPath= $extrectPath + '\EU\Pricing_1';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_Pricing.zip';serviceName ='CQ__EU_Pricing_2';ExtractPath= $extrectPath + '\EU\Pricing_2';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_Pricing.zip';serviceName ='CQ__EU_Pricing_ISO';ExtractPath= $extrectPath + '\EU\Pricing_ISO';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_Pricing.zip';serviceName ='CQ__EU_Pricing_SaveOnly';ExtractPath= $extrectPath + '\EU\Pricing_SaveOnly';}

       [pscustomobject]@{FolderName=$zipPath +'\CQ_Pricing.zip';serviceName ='CQ__US_Pricing';ExtractPath= $extrectPath + '\US\Pricing';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_Pricing.zip';serviceName ='CQ__US_Pricing_1';ExtractPath= $extrectPath + '\US\Pricing_1';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_Pricing.zip';serviceName ='CQ__US_Pricing_2';ExtractPath= $extrectPath + '\US\Pricing_2';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_Pricing.zip';serviceName ='CQ__US_Pricing_ISO';ExtractPath= $extrectPath + '\US\Pricing_ISO';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_Pricing.zip';serviceName ='CQ__US_Pricing_SaveOnly';ExtractPath= $extrectPath + '\US\Pricing_SaveOnly';}

       [pscustomobject]@{FolderName=$zipPath +'\CQ_Pricing.zip';serviceName ='CQ__ITAR_Pricing';ExtractPath= $extrectPath + '\ITAR\Pricing';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_Pricing.zip';serviceName ='CQ__ITAR_Pricing_1';ExtractPath= $extrectPath + '\ITAR\Pricing_1';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_Pricing.zip';serviceName ='CQ__ITAR_Pricing_2';ExtractPath= $extrectPath + '\ITAR\Pricing_2';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_Pricing.zip';serviceName ='CQ__ITAR_Pricing_ISO';ExtractPath= $extrectPath + '\ITAR\Pricing_ISO';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_Pricing.zip';serviceName ='CQ__ITAR_Pricing_SaveOnly';ExtractPath= $extrectPath + '\ITAR\Pricing_SaveOnly';}

       [pscustomobject]@{FolderName=$zipPath +'\CQ_PricingExpiration.zip';serviceName ='CQ_APP_PricingExpiration';ExtractPath= $extrectPath + '\APP\CQ_PricingExpiration';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_PricingExpiration.zip';serviceName ='CQ_ITAR_PricingExpiration';ExtractPath= $extrectPath + '\ITAR\CQ_PricingExpiration';}

       [pscustomobject]@{FolderName=$zipPath +'\CQ_ShopCQ.zip';serviceName ='CQ__US_ShopCQ';ExtractPath= $extrectPath + '\US\ShopCQ';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_ShopCQ.zip';serviceName ='CQ__EU_ShopCQ';ExtractPath= $extrectPath + '\EU\ShopCQ';}
       [pscustomobject]@{FolderName=$zipPath +'\CQ_ShopCQ.zip';serviceName ='CQ__ITAR_ShopCQ';ExtractPath= $extrectPath + '\ITAR\ShopCQ';}
       
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
	            Stop-Service -Name  $serviceDef.Name -Force
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
 echo "Start Copy Folder"
 robocopy  "$extrectPath" $destinationPath /s /is /it /im
 #Copy-Item -Path "$extrectPath\*" -Destination $destinationPath -Recurse -Force

 echo "End Copy Folder"


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

 ## Again Start Services if Missed

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
   Add-content $logPath "Exception occured : Common Services Failed"
   Add-content $logPath $_
}