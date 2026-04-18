//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTr_w_RunUnitTestWorker (signal)
//
// Runs whitelisted unit tests in a cooperative worker and signals the
// JSON-safe result back to OTr_w_Run.
// ----------------------------------------------------

#DECLARE($signal_o : Object)

var $result_o : Object
var $method_t : Text

Use ($signal_o)
	$method_t:=$signal_o.methodName
End use

If ($method_t="____Test_OTr_Master")
	$result_o:=____Test_OTr_Master(True:C214)
Else 
	$result_o:=New object:C1471("ok"; False:C215; "method"; $method_t; "error"; "Unit test method is not whitelisted.")
End if 

Use ($signal_o)
	$signal_o.resultJSON:=JSON Stringify:C1217($result_o)
End use 

$signal_o.trigger()
