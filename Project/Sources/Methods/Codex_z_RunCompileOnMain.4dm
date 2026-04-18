//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: Codex_z_RunCompileOnMain (signal)
//
// Runs the non-thread-safe compile/syntax check from the main process,
// then returns a JSON string through the supplied signal.
// ----------------------------------------------------

#DECLARE($signal_o : Object)

var $compile_o; $summary_o : Object
var $resultJSON_t : Text

$compile_o:=util_compileProject
$summary_o:=Codex_z_CompileResultForJSON($compile_o)
$resultJSON_t:=JSON Stringify:C1217($summary_o)

Use ($signal_o)
	$signal_o.resultJSON:=$resultJSON_t
End use

$signal_o.trigger()
