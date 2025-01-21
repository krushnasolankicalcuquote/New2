#region => Deploy DBScript to Database
param($EnvironmentName, $server_address, $sql_login, $sql_password)
$Environment= $EnvironmentName
$servername = $server_address
$serverUsername =$sql_login
$serverPsw = $sql_password

$workingDir ="C:\AutoDeployment\Script"
$Path = $workingDir + "\DBVersion.sql"
$logPath = "C:\AutoDeployment\Script\Error.log"
$Prefix ="CalcuQuote"
$getdbversion="SELECT TOP 5 BuildNumber,[Description],CreatedDateTime FROM DBVERSION ORDER BY 1 DESC"

try	{
    if($Environment -eq "Dev")
	{
		$instanceList = @("devs")
	}
	if($Environment -eq "QA")
	{
		$instanceList = @("QAIdentity","Template_QA","QAPortCQ","qa1","qa3","hj","automationpn","searchcqtest","shopcqperformance","customersuccess","cq4o","sanminaqa")
	}
	if($Environment -eq "Staging")
	{
		$instanceList = @("Regression","stagingsandbox","apiregression","BetaDemo","temporegression","stagingautomation")
	}

    function ExecuteSQLScriptForAllInstance()
    {
	    foreach( $fld in $instanceList) #only folders
        {
            $database = $Prefix + "_" + $fld
            ECHO $database
		    Invoke-Sqlcmd -Database $database -InputFile $Path -Password $serverPsw -ServerInstance $servername -Username $serverUsername -verbose
        }
        Invoke-Sqlcmd -Database $instanceList[0] -Password $serverPsw -ServerInstance $servername -Username $serverUsername -Query $getdbversion |out-string -outvariable output
        ECHO $output
    }
    ExecuteSQLScriptForAllInstance

    #Execute Identity DB
    #$IdentityPath = $workingDir + "\IdentityServerDBVersion.sql"
    #Invoke-Sqlcmd -Database "IdentityDBQA" -InputFile $IdentityPath -Password $serverPsw -ServerInstance $servername -Username $serverUsername
    
    #Execute CQAPI DB
    #$CQAPIPath =  $workingDir + "\CQAPIDBVersion.sql"
    #Invoke-Sqlcmd -Database "CQ_APIAuthenticationQA" -InputFile $CQAPIPath -Password $serverPsw -ServerInstance $servername -Username $serverUsername
    
    ##Execute IdentityV4 DB
    #$CQAuthenticationPath = $workingDir + "\IdentityV4DBVersion.sql"
    #Invoke-Sqlcmd -Database "IdentityDB4_DMT" -InputFile $CQAuthenticationPath -Password $serverPsw -ServerInstance $servername -Username $serverUsername

    Echo "Database Deployment Successfully"
}
catch
{
   Add-content $logPath "Exception occured : DB Deployment Failed"
   Add-content $logPath $_
}
#endregion