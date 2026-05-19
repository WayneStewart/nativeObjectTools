//%attributes = {}
var $options_o; $result_o; $summary_o : Object
var $issue_o; $message_o; $code_o : Object
var $resultJSON_t : Text

$options_o:=New object:C1471
$options_o.targets:=New collection:C1472("x86_64_generic"; "arm64_macOS_lib")  //Empty collection for syntax checking

$result_o:=Compile project:C1760($options_o)

$summary_o:=New object:C1471
$summary_o.success:=False:C215
$summary_o.errorCount:=0
$summary_o.warningCount:=0
$summary_o.messages:=New collection:C1472

If (OB Is defined:C1231($result_o; "success"))
	$summary_o.success:=$result_o.success
End if 

If (OB Is defined:C1231($result_o; "errors"))
	For each ($issue_o; $result_o.errors)
		$message_o:=New object:C1471
		
		If (OB Is defined:C1231($issue_o; "isError"))
			$message_o.isError:=$issue_o.isError
			If ($issue_o.isError)
				$summary_o.errorCount:=$summary_o.errorCount+1
			Else 
				$summary_o.warningCount:=$summary_o.warningCount+1
			End if 
		End if 
		
		If ($issue_o.isError)  // Only accumulate the errors
			If (OB Is defined:C1231($issue_o; "message"))
				$message_o.message:=$issue_o.message
			End if 
			If (OB Is defined:C1231($issue_o; "line"))
				$message_o.line:=$issue_o.line
			End if 
			If (OB Is defined:C1231($issue_o; "lineInFile"))
				$message_o.lineInFile:=$issue_o.lineInFile
			End if 
			
			If (OB Is defined:C1231($issue_o; "code"))
				$code_o:=New object:C1471
				If (OB Is defined:C1231($issue_o.code; "type"))
					$code_o.type:=$issue_o.code.type
				End if 
				If (OB Is defined:C1231($issue_o.code; "path"))
					$code_o.path:=$issue_o.code.path
				End if 
				If (OB Is defined:C1231($issue_o.code; "methodName"))
					$code_o.methodName:=$issue_o.code.methodName
				End if 
				If (OB Is defined:C1231($issue_o.code; "databaseMethod"))
					$code_o.databaseMethod:=$issue_o.code.databaseMethod
				End if 
				If (OB Is defined:C1231($issue_o.code; "className"))
					$code_o.className:=$issue_o.code.className
				End if 
				If (OB Is defined:C1231($issue_o.code; "functionName"))
					$code_o.functionName:=$issue_o.code.functionName
				End if 
				If (OB Is defined:C1231($issue_o.code; "formName"))
					$code_o.formName:=$issue_o.code.formName
				End if 
				If (OB Is defined:C1231($issue_o.code; "objectName"))
					$code_o.objectName:=$issue_o.code.objectName
				End if 
				$message_o.code:=$code_o
			End if 
			
			$summary_o.messages.push($message_o)
			
		End if   // Only accumulate the errors
		
	End for each   // ($issue_o; $result_o.errors)
End if 

var $conciseJSON_t; $report_t : Text
$conciseJSON_t:=JSON Stringify:C1217($summary_o)
$resultJSON_t:=JSON Stringify:C1217($summary_o; *)

If (Macintosh option down:C545)
	$report_t:=$conciseJSON_t
Else 
	$report_t:=$resultJSON_t
End if 

CALL WORKER:C1389(1; "_v4_CompileAnnounce"; "Done"+Char:C90(13)+$conciseJSON_t; $report_t)
