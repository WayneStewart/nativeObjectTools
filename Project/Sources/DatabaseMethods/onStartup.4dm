var $appInfo_o : Object
var $userParam_t; $action_t; $sentinelDir_t; $variant_t; $4dVersion_t : Text
var $params_c : Collection
var $value_r : Real

$appInfo_o:=Get application info:C1599

If ($appInfo_o.headless)
	
	// Headless CI launch.
	// --user-param format: "action[;params...]"
	//   compile: "compile;/path/to/sentinelDir/"
	//   build:   "build;OTr;19;/path/to/sentinelDir/"
	$value_r:=Get database parameter:C643(User param value:K37:94; $userParam_t)
	$params_c:=Split string:C1554($userParam_t; ";"; sk ignore empty strings:K86:1+sk trim spaces:K86:2)
	
	$action_t:=$params_c[0]
	$sentinelDir_t:=$params_c[1]
	
	Case of 
		: ($action_t="compile")
			OTr_y_testCompilation($sentinelDir_t)
			
		: ($action_t="build")
			$variant_t:=$params_c[1]
			$4dVersion_t:=$params_c[2]
			$sentinelDir_t:=$params_c[3]
			OTr_y_buildComponent($variant_t; $4dVersion_t; $sentinelDir_t)
			
	End case 
	
	QUIT 4D:C291
	
Else 
	
	// Normal interactive launch.
	OTr_onStartup
	
End if 
