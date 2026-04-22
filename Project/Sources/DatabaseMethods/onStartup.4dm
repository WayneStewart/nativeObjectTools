var $userParam_t; $action_t; $sentinelDir_t; $variant_t; $4dVersion_t : Text
var $params_c : Collection
var $value_r : Real
var $DTS_t; $logLabel_t; $logPath_t : Text

// Check for a CI user-param before doing anything else.
// --user-param format: "action[;params...]"
//   compile: "compile;/path/to/sentinelDir/"
//   build:   "build;OTr;19;/path/to/sentinelDir/"
// If no recognised action arrives, fall through to normal interactive startup.
$value_r:=Get database parameter:C643(User param value:K37:94; $userParam_t)

If ($userParam_t#"")
	$params_c:=Split string:C1554($userParam_t; ";"; sk ignore empty strings:K86:1+sk trim spaces:K86:2)
	$action_t:=$params_c[0]
	
	var OTr_DummyVariableForTests_t : Text  // Use this here for accumulating results
	
End if 

Case of 
	: ($action_t="compile") | ($action_t="build")
		
		$DTS_t:=OTr_z_timestampLocal
		$DTS_t:=Replace string:C233($DTS_t; ":"; "-")
		$DTS_t:=Replace string:C233($DTS_t; "/"; "-")
		$DTS_t:=Replace string:C233($DTS_t; "."; "-")
		
		$logLabel_t:=$DTS_t+" Build Logging"
		LOG DECLARE LOG($logLabel_t)
		LOG USE LOG($logLabel_t)
		LOG ENABLE(True:C214)
		
		LOG Build Log(Current method name:C684; "CI launch"; "action"; $action_t)
		LOG Build Log(Current method name:C684; "Parameters"; $userParam_t)
		
		Case of 
			: ($action_t="compile")
				$sentinelDir_t:=$params_c[1]
				OTr_y_testCompilation($sentinelDir_t)
				
			: ($action_t="build")
				$variant_t:=$params_c[1]
				$4dVersion_t:=$params_c[2]
				$sentinelDir_t:=$params_c[3]
				OTr_y_buildComponent($variant_t; $4dVersion_t; $sentinelDir_t)
				
		End case 
		
		LOG Build Log(Current method name:C684; "Exit CI section")
		$logPath_t:=Get 4D folder:C485(Logs folder:K5:19)+$logLabel_t+".txt"
		TEXT TO DOCUMENT:C1237($logPath_t; OTr_DummyVariableForTests_t)
		
		QUIT 4D:C291
		
	Else 
		
		// Normal interactive launch — no recognised user-param.
		OTr_onStartup
		
End case 
