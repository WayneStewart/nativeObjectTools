//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTr_w_CompileResultForJSON (compileResult) --> Object
//
// Produces a JSON-safe summary of Compile project results. The native
// compiler result can include objects such as 4D.File that are not useful
// to expose directly through a lightweight HTTP bridge.
// ----------------------------------------------------

#DECLARE($compile_o : Object)->$summary_o : Object

var $issue_o; $message_o; $code_o : Object

$summary_o:=New object:C1471
$summary_o.success:=False:C215
$summary_o.errorCount:=0
$summary_o.warningCount:=0
$summary_o.messages:=New collection:C1472

If (OB Is defined:C1231($compile_o; "success"))
	$summary_o.success:=$compile_o.success
End if

If (OB Is defined:C1231($compile_o; "errors"))
	For each ($issue_o; $compile_o.errors)
		$message_o:=New object:C1471

		If (OB Is defined:C1231($issue_o; "isError"))
			$message_o.isError:=$issue_o.isError
			If ($issue_o.isError)
				$summary_o.errorCount:=$summary_o.errorCount+1
			Else
				$summary_o.warningCount:=$summary_o.warningCount+1
			End if
		End if

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
	End for each
End if
