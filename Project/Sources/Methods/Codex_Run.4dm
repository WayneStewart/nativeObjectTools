//%attributes = {"invisible":true,"preemptive":"capable"}
// ----------------------------------------------------
// Project Method: Codex_Run (methodName; clientIP) --> Object
//
// Loopback-only dispatcher for local Codex testing calls made through
// the 4D web server. Keep this method whitelisted: do not expose
// arbitrary project method execution over HTTP.
// ----------------------------------------------------

#DECLARE($method_t : Text; $clientIP_t : Text)->$response_o : Object

var $result_o; $signal_o : Object
var $signaled_b : Boolean
var $resultJSON_t : Text
var $testMethod_t : Text

$response_o:=New object:C1471
$response_o.ok:=False:C215
$response_o.method:=$method_t
$response_o.clientIP:=$clientIP_t
$response_o.applicationVersion:=Application version:C493

If (Not:C34(Codex_z_IsLocalRequest($clientIP_t)))
	$response_o.error:="Denied: Codex bridge only accepts loopback requests."
Else
	Case of
		: ($method_t="ping")
			$result_o:=New object:C1471
			$result_o.message:="pong"
			$response_o.ok:=True:C214
			$response_o.result:=$result_o

		: ($method_t="util_compileProject")
			$signal_o:=New signal:C1641("Codex util_compileProject")
			CALL WORKER:C1389(1; "Codex_z_RunCompileOnMain"; $signal_o)
			$signaled_b:=$signal_o.wait(120)
			If ($signaled_b)
				$resultJSON_t:=$signal_o.resultJSON
				$result_o:=JSON Parse:C1218($resultJSON_t; Is object:K8:27)
				$response_o.ok:=$result_o.success
				$response_o.result:=$result_o
			Else
				$response_o.error:="Timed out waiting for main process to run util_compileProject."
			End if

		: (($method_t="unitTests") | ($method_t="____Test_OTr_Master"))
			$testMethod_t:="____Test_OTr_Master"
			$signal_o:=New signal:C1641("Codex unit tests")
			Use ($signal_o)
				$signal_o.methodName:=$testMethod_t
			End use
			CALL WORKER:C1389($testMethod_t; "Codex_z_RunUnitTestWorker"; $signal_o)
			$signaled_b:=$signal_o.wait(600)
			If ($signaled_b)
				$resultJSON_t:=$signal_o.resultJSON
				$result_o:=JSON Parse:C1218($resultJSON_t; Is object:K8:27)
				$response_o.ok:=$result_o.ok
				$response_o.result:=$result_o
			Else
				$response_o.error:="Timed out waiting for unit tests to complete."
			End if

		: ($method_t="util_restartProject")
			$result_o:=New object:C1471
			$result_o.message:="Restart requested."
			$result_o.delayTicks:=60
			$response_o.ok:=True:C214
			$response_o.result:=$result_o
			CALL WORKER:C1389("Codex Restart"; "Codex_z_RestartProjectWorker")

		: ($method_t="makePhase16Fixtures")
			$result_o:=New object:C1471
			$result_o.message:="Phase 16 fixture generation requested."
			$response_o.ok:=True:C214
			$response_o.result:=$result_o
			CALL WORKER:C1389(1; "____Make_Phase16_OTBlobFixtures"; True:C214)

		: ($method_t="phase16Diag")
			$signal_o:=New signal:C1641("Codex Phase 16 diag")
			CALL WORKER:C1389(1; "Codex_z_Phase16Diag"; $signal_o)
			$signaled_b:=$signal_o.wait(120)
			If ($signaled_b)
				$resultJSON_t:=$signal_o.resultJSON
				$result_o:=JSON Parse:C1218($resultJSON_t; Is object:K8:27)
				$response_o.ok:=$result_o.ok
				$response_o.result:=$result_o
			Else
				$response_o.error:="Timed out waiting for Phase 16 diagnostics."
			End if

		Else
			$response_o.error:="Method is not whitelisted for Codex bridge calls."
			$response_o.allowed:=New collection:C1472("ping"; "util_compileProject"; "unitTests"; "____Test_OTr_Master"; "util_restartProject"; "makePhase16Fixtures"; "phase16Diag")
	End case
End if
