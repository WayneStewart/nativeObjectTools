//%attributes = {"folder":"Util","lang":"en"}
// _____________v4_CompilerCheck
// Created by Wayne Stewart (7/7/2026)
//  Method is an autostart type
//     waynestewart@mac.com
// ----------------------------------------------------


#DECLARE($inline_b : Boolean)

var $ProcessID_i; $StackSize_i : Integer
var $Form_t; $DesiredProcessName_t; $syntaxCheckResults_t : Text

// ----------------------------------------------------

$StackSize_i:=0
$Form_t:=""
$DesiredProcessName_t:=Current method name:C684

If (Count parameters:C259=0)
	$inline_b:=False:C215
End if 


If (Current process name:C1392=$DesiredProcessName_t)
	
	var $options_o; $result_o; $summary_o : Object
	var $issue_o; $message_o; $code_o : Object
	var $resultJSON_t : Text
	var $startMilli_i : Integer
	
	RELOAD PROJECT:C1739
	DELAY PROCESS:C323(Current process:C322; 30)
	
	$syntaxCheckResults_t:=Get 4D folder:C485(Current resources folder:K5:16)+"compilerResults.json"
	
	$startMilli_i:=Milliseconds:C459
	
	$options_o:=New object:C1471
	$options_o.targets:=New collection:C1472  //("x86_64_generic"; "arm64_macOS_lib")  //Empty collection for syntax checking
	
	$result_o:=Compile project:C1760($options_o)
	
	$summary_o:=New object:C1471
	$summary_o.project:=File:C1566(Convert path system to POSIX:C1106(Structure file:C489)).name
	$summary_o.success:=False:C215
	$summary_o.errorCount:=0
	$summary_o.warningCount:=0
	$summary_o.timeInMilliSeconds:=0
	$summary_o.v4D:=Application version:C493
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
	
	$summary_o.timeInMilliSeconds:=Milliseconds:C459-$startMilli_i
	
	var $conciseJSON_t; $report_t : Text
	$conciseJSON_t:=JSON Stringify:C1217($summary_o)
	$resultJSON_t:=JSON Stringify:C1217($summary_o; *)
	
	If (Macintosh option down:C545)
		$report_t:=$conciseJSON_t
	Else 
		$report_t:=$resultJSON_t
	End if 
	
	If ($inline_b)
		TEXT TO DOCUMENT:C1237($syntaxCheckResults_t; $conciseJSON_t)
	Else 
		SET TEXT TO PASTEBOARD:C523($report_t)
		ALERT:C41("Done"+Char:C90(13)+$conciseJSON_t)
	End if 
	
Else 
	// This version allows for any number of processes
	// $ProcessID_i:=New Process(Current method name;$StackSize_i;$DesiredProcessName_t)
	
	// On the other hand, this version allows for one unique process
	$ProcessID_i:=New process:C317(Current method name:C684; $StackSize_i; $DesiredProcessName_t; $inline_b; *)
	
	RESUME PROCESS:C320($ProcessID_i)
	SHOW PROCESS:C325($ProcessID_i)
	BRING TO FRONT:C326($ProcessID_i)
End if 



