var $appInfo_o : Object
var $userParam_t; $action_t; $sentinelDir_t; $variant_t; $4dVersion_t : Text
var $params_c : Collection
var $value_r : Real
var $log_FileName_t; $logLabel_t; $log_Path_t : Text
$appInfo_o:=Get application info:C1599

If ($appInfo_o.headless)
	$log_Path_t:=Get 4D folder:C485(Logs folder:K5:19)
	$log_FileName_t:=OTr_z_timestampLocal
	$log_FileName_t:=Replace string:C233($log_FileName_t; ":"; "-")
	$log_FileName_t:=Replace string:C233($log_FileName_t; "/"; "-")
	$log_FileName_t:=Replace string:C233($log_FileName_t; "."; "-")
	$log_FileName_t:=$log_FileName_t+".txt"
	$logLabel_t:="Build Logging"
	LOG DECLARE LOG($logLabel_t; $log_Path_t; $log_FileName_t)
	LOG USE LOG($logLabel_t)
	LOG ENABLE(True:C214)
	LOG ADD ENTRY(Current method name:C684; "Headless Mode")
	// Headless CI launch.
	// --user-param format: "action[;params...]"
	//   compile: "compile;/path/to/sentinelDir/"
	//   build:   "build;OTr;19;/path/to/sentinelDir/"
	$value_r:=Get database parameter:C643(User param value:K37:94; $userParam_t)
	
	LOG ADD ENTRY(Current method name:C684; "Parameters"; $userParam_t)
	$params_c:=Split string:C1554($userParam_t; ";"; sk ignore empty strings:K86:1+sk trim spaces:K86:2)
	
	$action_t:=$params_c[0]
	$sentinelDir_t:=$params_c[1]
	
	LOG ADD ENTRY(Current method name:C684; "Action"; $action_t; "sentinelDir"; $sentinelDir_t)
	
	Case of 
		: ($action_t="compile")
			OTr_y_testCompilation($sentinelDir_t)
			
		: ($action_t="build")
			$variant_t:=$params_c[1]
			$4dVersion_t:=$params_c[2]
			$sentinelDir_t:=$params_c[3]
			OTr_y_buildComponent($variant_t; $4dVersion_t; $sentinelDir_t)
			
	End case 
	
	LOG ADD ENTRY(Current method name:C684; "Exit Action Section")
	
	LOG CLOSE LOG2  // Inline call
	//LOG CLOSE LOG
	
	QUIT 4D:C291
	
Else 
	
	// Normal interactive launch.
	OTr_onStartup
	
End if 
