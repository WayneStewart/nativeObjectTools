//%attributes = {"invisible":true}
var $appInfo_o : Object
var $userParam_t; $action_t; $sentinelDir_t; $variant_t; $4dVersion_t : Text
var $params_c : Collection
var $value_r : Real
var $log_FileName_t; $logLabel_t; $log_Path_t : Text
$appInfo_o:=Get application info:C1599


$log_Path_t:=Get 4D folder:C485(Logs folder:K5:19)
$log_FileName_t:=OTr_z_timestampLocal
$log_FileName_t:=Replace string:C233($log_FileName_t; ":"; "-")
$log_FileName_t:=Replace string:C233($log_FileName_t; "/"; "-")
$log_FileName_t:=Replace string:C233($log_FileName_t; "."; "-")
$log_FileName_t:=$log_FileName_t+".txt"

$logLabel_t:="Build Logging"

LOG DECLARE LOG($logLabel_t)  //; $log_Path_t; $log_FileName_t)
LOG USE LOG($logLabel_t)
LOG ENABLE(True:C214)

LOG ADD ENTRY(Current method name:C684; "Headless Mode")



LOG ADD ENTRY(Current method name:C684; "Exit Action Section")

LOG CLOSE LOG  // Inline call
//LOG CLOSE LOG
