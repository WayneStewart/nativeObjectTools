var $userParam_t; $action_t; $sentinelDir_t; $variant_t; $4dVersion_t : Text
var $params_c : Collection
var $value_r : Real
var $DTS_t; $logLabel_t : Text

// Check for a CI user-param before doing anything else.
// --user-param format: "action[;params...]"
//   compile: "compile;/path/to/sentinelDir/"
//   build:   "build;OTr;19;/path/to/sentinelDir/"
// If no recognised action arrives, fall through to normal interactive startup.
$value_r:=Get database parameter:C643(User param value:K37:94; $userParam_t)

If ($userParam_t#"")
	$params_c:=Split string:C1554($userParam_t; ";"; sk ignore empty strings:K86:1+sk trim spaces:K86:2)
	$action_t:=$params_c[0]
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

		LOG ADD ENTRY(Current method name:C684; "CI launch"; "action"; $action_t)
		LOG ADD ENTRY(Current method name:C684; "Parameters"; $userParam_t)

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

		LOG ADD ENTRY(Current method name:C684; "Exit CI section")
		LOG CLOSE LOG
		QUIT 4D:C291

	Else

		// Normal interactive launch — no recognised user-param.
		OTr_onStartup

End case
