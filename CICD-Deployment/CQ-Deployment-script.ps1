Add-Type -AssemblyName System.IO.Compression.FileSystem
$ServicePath="C:\AutoDeployment\Services"
$Environment= "$env:EnvironmentName"
$IsStaging=$false
$timeout = [TimeSpan]::FromMinutes(10)

if($Environment -eq "Staging" -or $Environment -match "Staging")
{
    $IsStaging=$true
}

#region => (1) Stoping all QuoteStar Windows Services

echo "Publish over $Environment Environment"

if($IsStaging)
{
    $services = @('CQ_Staging_API_CQService', 'CQ_Staging_API_CQService_1', 'CQ_Staging_API_Pricing',
                'CQ_Staging_API_WorkFlow' ,'CQ_Staging_PricingExpiration', 'CQ_Staging_API_QuoteCQService',
                'CQ_Staging_Currency', 'CQ_Staging_Webhook', 'CQ_Staging_Maintenance',
                'CQ_Staging_ArchiveService', 'CQ_Staging_EventWorkerService', 'CQ_Staging_CustomReport', 'CQ_Staging_API_ManEx')
}
else
{
    $services = @('CQ_QuoteCQAPI_CQService', 'CQ_QuoteCQAPI_Pricing',
                'CQ_QuoteCQAPI_Workflow', 'CQ_Pricing_Expr', 'CQ_QuoteCQAPI_QCQService',
                'CQ_Currency', 'CQ_Webhook', 'CQ_MaintenanceService',
                'CQ_ArchiveService', 'CQ_EventWorkerService', 'CQ_CustomReport', 'CQ_QuoteCQAPI_ManEx')
}

# Stop each service without waiting
foreach ($serviceName in $services)
{
    $service = Get-Service -Name $serviceName –ErrorAction SilentlyContinue
    if ($service.Status -eq 'Running')
    {
        Stop-Service -Name $serviceName -Force
        echo "Stoping Service: $serviceName"
    }
}

# Wait for each service to stop
foreach ($serviceName in $services)
{
    $service = Get-Service -Name $serviceName –ErrorAction SilentlyContinue
    if ($service.Status -eq 'Running')
    {
        $service.WaitForStatus('Stopped', $timeout)
    }

    echo "Stopped Service: $serviceName"
}

echo "All Services Stopped Successfully"

#endregion


#region => (2) Unzip all Services folders

function Unzip
{
  param([string]$zipfile, [string]$outpath)
  try {
        [IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
        echo "Extract files succesfully: $zipfile" 
        $true
  } 
  catch {
        echo "Can't unzip the file: $zipfile"
        $false
  }
 }

$flag = $true

while($flag)
{
     #Get all .zip file list
     $zipDirectory = Get-ChildItem -Path $ServicePath -Recurse | Where-Object {$_.Name -like "*.zip"}
 
     if($zipDirectory.count -eq 0)
     {
        $flag = $false
     }
     elseif($zipDirectory.count -gt 0)
     {
        foreach($zipFile in $zipDirectory)
        {
            #Create the new directory without .zip
            $newPathName = $zipFile.FullName.Replace(".zip", "")
            if(Unzip $zipFile.FullName $newPathName)
            {
                Remove-Item $zipFile.FullName   
            }
        }
     }
     Clear-Variable zipDirectory 
}

#endregion


#region => (3) Copy all ServiceFolder to Service Directory

$PricingServiceSrc="C:\AutoDeployment\Services\CQ_Pricing"
$PricingExpServiceSrc="C:\AutoDeployment\Services\CQ_PricingExpiration"
$CurrencyServiceSrc="C:\AutoDeployment\Services\CQ_Currency"
$WorkFlowServiceSrc="C:\AutoDeployment\Services\CQ_WorkFlow"
$ShopCQServiceSrc="C:\AutoDeployment\Services\CQ_ShopCQ"
$CQServiceSrc="C:\AutoDeployment\Services\CQ_Service"
$QCQServiceSrc="C:\AutoDeployment\Services\CQ_QuoteCQService"
$ManExServiceSrc="C:\AutoDeployment\Services\CQ_ManEx"
$CustomReportServiceSrc="C:\AutoDeployment\Services\CQ_CustomReport"
$WebHookServiceSrc="C:\AutoDeployment\Services\CQ_Webhook"
$MaintenanceServiceSrc="C:\AutoDeployment\Services\CQ_MaintenanceService"
$ArchiveServiceSrc="C:\AutoDeployment\Services\CQ_ArchiveService"
$EventWorkerServiceSrc="C:\AutoDeployment\Services\CQ_EventWorkerService"

if($IsStaging)
{
    $PricingServiceDst="Q:\Inetpub\Staging\QuoteCQAPI_CQ_Pricing"
    $PricingExpServiceDst="Q:\Inetpub\Staging\CQ_PricingExpiration"
    $CurrencyServiceDst="Q:\Inetpub\Staging\CQ_Currency"
    $WorkFlowServiceDst="Q:\Inetpub\Staging\QuoteCQAPI_CQ_WorkFlow"
    $ShopCQServiceDst="Q:\Inetpub\Staging\QuoteCQAPI_CQ_ShopCQ"
    $CQServiceDst="Q:\Inetpub\Staging\QuoteCQAPI_CQ_Service"
    $CQServiceDst1="Q:\Inetpub\Staging\QuoteCQAPI_CQ_Service_1"
    $QCQServiceDst="Q:\Inetpub\Staging\QuoteCQAPI_CQ_QuoteCQService"
    $ManExServiceDst="Q:\Inetpub\Staging\QuoteCQAPI_CQ_ManEx"
    $CustomReportServiceDst="Q:\Inetpub\Staging\CQ_CustomReport"
    $WebHookServiceDst="Q:\Inetpub\Staging\CQ_Webhook"
    $MaintenanceServiceDst="Q:\Inetpub\Staging\CQ_Maintenance"
    $ArchiveServiceDst="Q:\Inetpub\Staging\CQ_ArchiveService"
    $EventWorkerServiceDst="Q:\Inetpub\Staging\CQ_EventWorkerService"
}
else
{
    $PricingServiceDst="C:\inetpub\QuoteCQAPI_Services\QuoteCQAPI_Pricing"
    $PricingExpServiceDst="C:\inetpub\QuoteCQAPI_Services\QuoteCQ.PricingExprService"
    $CurrencyServiceDst="C:\inetpub\QuoteCQAPI_Services\QuoteCQ.CurrencyService"
    $WorkFlowServiceDst="C:\inetpub\QuoteCQAPI_Services\QuoteCQAPI_Workflow"
    $ShopCQServiceDst="C:\inetpub\QuoteCQAPI_Services\QuoteCQAPI_ShopCQ"
    $CQServiceDst="C:\inetpub\QuoteCQAPI_Services\QuoteCQAPI_CQService"
    $QCQServiceDst="C:\inetpub\QuoteCQAPI_Services\QuoteCQAPI_QCQService"
    $ManExServiceDst="C:\inetpub\QuoteCQAPI_Services\QuoteCQAPI_ManEx"
    $CustomReportServiceDst="C:\inetpub\QuoteCQAPI_Services\QuoteCQ.CustomReport"
    $WebHookServiceDst="C:\inetpub\QuoteCQAPI_Services\QuoteCQ.WebhookService"
    $MaintenanceServiceDst="C:\inetpub\MaintenanceService"
    $ArchiveServiceDst="C:\inetpub\QuoteCQAPI_Services\ArchiveService"
    $EventWorkerServiceDst="C:\inetpub\QuoteCQAPI_Services\EventWorkerService"
}

if(Test-Path -Path $PricingServiceSrc)
{
    Copy-Item "$PricingServiceSrc\*" -Destination "$PricingServiceDst" -Recurse -force
    echo "Copied : FROM=>  [$PricingServiceSrc]  TO=>  [$PricingServiceDst]"
}

if(Test-Path -Path $PricingExpServiceSrc)
{
    Copy-Item "$PricingExpServiceSrc\*" -Destination "$PricingExpServiceDst" -Recurse -force
    echo "Copied : FROM=>  [$PricingExpServiceSrc]  TO=>  [$PricingExpServiceDst]"
}
if(Test-Path -Path $CurrencyServiceSrc)
{
    Copy-Item "$CurrencyServiceSrc\*" -Destination "$CurrencyServiceDst" -Recurse -force
    echo "Copied : FROM=>  [$CurrencyServiceSrc]  TO=>  [$CurrencyServiceDst]"
}

if(Test-Path -Path $WorkFlowServiceSrc)
{
    Copy-Item "$WorkFlowServiceSrc\*" -Destination "$WorkFlowServiceDst" -Recurse -force
    echo "Copied : FROM=>  [$WorkFlowServiceSrc]  TO=>  [$WorkFlowServiceDst]"
}

if(Test-Path -Path $ShopCQServiceSrc)
{
    Copy-Item "$ShopCQServiceSrc\*" -Destination "$ShopCQServiceDst" -Recurse -force
    echo "Copied : FROM=>  [$ShopCQServiceSrc]  TO=>  [$ShopCQServiceDst]"
}

if(Test-Path -Path $CQServiceSrc)
{
    Copy-Item "$CQServiceSrc\*" -Destination "$CQServiceDst" -Recurse -force
    echo "Copied : FROM=>  [$CQServiceSrc]  TO=>  [$CQServiceDst]"

    if($IsStaging)
    {
        Copy-Item "$CQServiceSrc\*" -Destination "$CQServiceDst1" -Recurse -force
        echo "Copied : FROM=>  [$CQServiceSrc]  TO=>  [$CQServiceDst1]"
    }
}

if(Test-Path -Path $QCQServiceSrc)
{
    Copy-Item "$QCQServiceSrc\*" -Destination "$QCQServiceDst" -Recurse -force
    echo "Copied : FROM=>  [$QCQServiceSrc]  TO=>  [$QCQServiceDst]"
}

if(Test-Path -Path $ManExServiceSrc)
{
    Copy-Item "$ManExServiceSrc\*" -Destination "$ManExServiceDst" -Recurse -force
    echo "Copied : FROM=>  [$ManExServiceSrc]  TO=>  [$ManExServiceDst]"
}

if(Test-Path -Path $WebHookServiceSrc)
{
    Copy-Item "$WebHookServiceSrc\*" -Destination "$WebHookServiceDst" -Recurse -force
    echo "Copied : FROM=>  [$WebHookServiceSrc]  TO=>  [$WebHookServiceDst]"
}

if(Test-Path -Path $MaintenanceServiceSrc)
{
    Copy-Item "$MaintenanceServiceSrc\*" -Destination "$MaintenanceServiceDst" -Recurse -force
    echo "Copied : FROM=>  [$MaintenanceServiceSrc]  TO=>  [$MaintenanceServiceDst]"
}

if(Test-Path -Path $ArchiveServiceSrc)
{
    Copy-Item "$ArchiveServiceSrc\*" -Destination "$ArchiveServiceDst" -Recurse -force
    echo "Copied : FROM=>  [$ArchiveServiceSrc]  TO=>  [$ArchiveServiceDst]"
}

if(Test-Path -Path $EventWorkerServiceSrc)
{
    Copy-Item "$EventWorkerServiceSrc\*" -Destination "$EventWorkerServiceDst" -Recurse -force
    echo "Copied : FROM=>  [$EventWorkerServiceSrc]  TO=>  [$EventWorkerServiceDst]"
}

if(Test-Path -Path $CustomReportServiceSrc)
{
    Copy-Item "$CustomReportServiceSrc\*" -Destination "$CustomReportServiceDst" -Recurse -force
    echo "Copied : FROM=>  [$CustomReportServiceSrc]  TO=>  [$CustomReportServiceDst]"
}

echo "All Services Published Successfully"

#endregion


#region => (4) Starting all QuoteStar Windows Services

foreach($serviceName in $services)
{
    $serviceDef = Get-Service –Name $serviceName –ErrorAction SilentlyContinue

    if($serviceDef.Status -eq "Stopped")
    {
        Start-Service –Name $serviceName
        echo "Starting Service: $serviceName"
        Start-Sleep -Seconds 60
    }
}

echo "All Services Started Successfully"

#endregion

#region => (5) QuoteStar Windows Services output status

echo ""    
echo "--------- Current Status of Services ---------" 
echo "" 

foreach($serviceName in $services)
{
    $serviceDef = Get-Service –Name $serviceName –ErrorAction SilentlyContinue
    $serviceStatus = $serviceDef.Status
    echo "$serviceName  :  $serviceStatus"
}

#endregion