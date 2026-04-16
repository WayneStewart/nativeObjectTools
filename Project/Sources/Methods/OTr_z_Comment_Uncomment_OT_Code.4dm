//%attributes = {}
// ----------------------------------------------------
// Project Method: OTr_z_Comment_Uncomment_OT_Code {(suppressAlert)}

// Developer utility. Reads the list of methods in
// Resources/OTr_OTBlockMethods.json, gets each method's source through
// METHOD GET CODE, and comments or uncomments each standardized ObjectTools
// plugin block by adding or removing wrapper lines next to the delimiters.
//
// The target state is selected from OTr_z_PluginShouldWork. If the plugin
// should work, OT blocks are uncommented. If the plugin should not work,
// OT blocks are commented.
//
// Access: Private
//
// Parameters:
//   $suppressAlert_b : Boolean : Optional. True to suppress final ALERT.
//
// Returns: Nothing
//
// Created by Wayne Stewart / Codex, 2026-04-16
// Wayne Stewart / Codex, 2026-04-16 - Added resource-driven Tahoe-safe
//   OT block commenter using METHOD GET CODE / METHOD SET CODE.
// Wayne Stewart / Codex, 2026-04-17 - Made the utility bidirectional,
//   guarded by compiled mode, plugin availability, and user confirmation.
// Wayne Stewart / Codex, 2026-04-17 - Simplified block conversion to only
//   add or remove / * and * / wrapper lines beside the OT block delimiters.
// ----------------------------------------------------

#DECLARE($suppressAlert_b : Boolean)

OTr_z_AddToCallStack(Current method name:C684)

var $hideAlert_b; $canChange_b; $cancelled_b; $compiledMode_b : Boolean
var $pluginShouldWork_b; $commentBlocks_b; $blockChanged_b : Boolean
var $trim_b : Boolean
var $configPath_t; $json_t; $methodName_t; $methodCode_t; $originalCode_t : Text
var $begin_t; $end_t; $CR_t; $LF_t; $TAB_t : Text
var $action_t; $confirm_t; $summary_t; $line_t; $testLine_t : Text
var $beginPos_i; $beginLineEnd_i; $endPos_i; $scanFrom_i : Integer
var $methodIndex_i; $blockCount_i; $changedMethodCount_i; $changedBlockCount_i : Integer
var $methodBlockCount_i; $lineStart_i; $lineEnd_i; $removeEnd_i : Integer
var $nextCR_i; $nextLF_i; $previousLineStart_i; $previousLineEnd_i : Integer
var $config_o : Object
var $methods_c : Collection
ARRAY TEXT:C222($methodNames_at; 0)
ARRAY TEXT:C222($allMethodNames_at; 0)
ARRAY TEXT:C222($methodCode_at; 0)
ARRAY TEXT:C222($changedMethods_at; 0)
ARRAY TEXT:C222($missingMethods_at; 0)

If (Count parameters:C259<1)
	$hideAlert_b:=False:C215
Else 
	$hideAlert_b:=$suppressAlert_b
End if 

$begin_t:="// ==== BEGIN OT BLOCK — comment out on Tahoe 26.4+ ===="
$end_t:="// ==== END OT BLOCK ===="
$CR_t:=Char:C90(Carriage return:K15:38)
$LF_t:=Char:C90(Tab:K15:37)
$TAB_t:=Char:C90(Period:K15:45)
$configPath_t:=Get 4D folder:C485(Current resources folder:K5:16)+"OTr_OTBlockMethods.json"

$canChange_b:=True:C214
$compiledMode_b:=Is compiled mode:C492

If ($compiledMode_b)
	$canChange_b:=False:C215
Else 
	$pluginShouldWork_b:=OTr_z_PluginShouldWork
	$commentBlocks_b:=Not:C34($pluginShouldWork_b)
	
	If ($commentBlocks_b)
		$action_t:="Comment the OT Comands"
		$confirm_t:="ObjectTools does not appear to be available on this system."+$CR_t+$CR_t+"Do you want to comment out the ObjectTools plugin code blocks?"
	Else 
		$action_t:="Uncomment the OT Comands"
		$confirm_t:="ObjectTools appears to be available on this system."+$CR_t+$CR_t+"Do you want to uncomment the ObjectTools plugin code blocks?"
	End if 
	
	CONFIRM:C162($confirm_t; $action_t; "Cancel")
	If (OK#1)
		$canChange_b:=False:C215
		$cancelled_b:=True:C214
	End if 
End if 

If ($canChange_b)
	If (Test path name:C476($configPath_t)#Is a document:K24:1)
		OTr_z_Error("OT block method list not found: "+$configPath_t; Current method name:C684)
		OTr_z_SetOK(0)
	Else 
		$json_t:=Document to text:C1236($configPath_t; "UTF-8")
		$config_o:=JSON Parse:C1218($json_t; Is object:K8:27)
		
		If ($config_o=Null:C1517)
			OTr_z_Error("OT block method list is not valid JSON"; Current method name:C684)
			OTr_z_SetOK(0)
		Else 
			If (OB Is defined:C1231($config_o; "beginDelimiter"))
				$begin_t:=OB Get:C1224($config_o; "beginDelimiter"; Is text:K8:3)
			End if 
			If (OB Is defined:C1231($config_o; "endDelimiter"))
				$end_t:=OB Get:C1224($config_o; "endDelimiter"; Is text:K8:3)
			End if 
			
			$methods_c:=OB Get:C1224($config_o; "methods"; Is collection:K8:32)
			If ($methods_c=Null:C1517)
				OTr_z_Error("OT block method list has no methods collection"; Current method name:C684)
				OTr_z_SetOK(0)
			Else 
				METHOD GET NAMES:C1166($allMethodNames_at; *)
				
				For each ($methodName_t; $methods_c)
					If (Find in array:C230($allMethodNames_at; $methodName_t)>0)
						APPEND TO ARRAY:C911($methodNames_at; $methodName_t)
					Else 
						APPEND TO ARRAY:C911($missingMethods_at; $methodName_t)
					End if 
				End for each 
				
				If (Size of array:C274($methodNames_at)>0)
					METHOD GET CODE:C1190($methodNames_at; $methodCode_at)
					
					For ($methodIndex_i; 1; Size of array:C274($methodNames_at))
						$methodName_t:=$methodNames_at{$methodIndex_i}
						$methodCode_t:=$methodCode_at{$methodIndex_i}
						$originalCode_t:=$methodCode_t
						$scanFrom_i:=1
						$methodBlockCount_i:=0
						
						While ($scanFrom_i>0)
							$beginPos_i:=Position:C15($begin_t; $methodCode_t; $scanFrom_i)
							If ($beginPos_i=0)
								$scanFrom_i:=0
							Else 
								$beginLineEnd_i:=Position:C15($CR_t; $methodCode_t; $beginPos_i)
								If ($beginLineEnd_i=0)
									$beginLineEnd_i:=Position:C15($LF_t; $methodCode_t; $beginPos_i)
								End if 
								
								If ($beginLineEnd_i=0)
									$scanFrom_i:=0
								Else 
									$endPos_i:=Position:C15($end_t; $methodCode_t; $beginLineEnd_i+1)
									If ($endPos_i=0)
										$scanFrom_i:=0
									Else 
										$blockCount_i:=$blockCount_i+1
										$blockChanged_b:=False:C215
										
										// Line immediately after the opening delimiter.
										$lineStart_i:=$beginLineEnd_i+1
										If (($lineStart_i<=Length:C16($methodCode_t)) & (Substring:C12($methodCode_t; $lineStart_i; 1)=$LF_t))
											$lineStart_i:=$lineStart_i+1
										End if 
										$nextCR_i:=Position:C15($CR_t; $methodCode_t; $lineStart_i)
										$nextLF_i:=Position:C15($LF_t; $methodCode_t; $lineStart_i)
										If (($nextCR_i>0) & (($nextCR_i<$nextLF_i) | ($nextLF_i=0)))
											$lineEnd_i:=$nextCR_i
										Else 
											If ($nextLF_i>0)
												$lineEnd_i:=$nextLF_i
											Else 
												$lineEnd_i:=Length:C16($methodCode_t)+1
											End if 
										End if 
										$line_t:=Substring:C12($methodCode_t; $lineStart_i; $lineEnd_i-$lineStart_i)
										$testLine_t:=$line_t
										
										$trim_b:=True:C214
										While (($trim_b) & (Length:C16($testLine_t)>0))
											If ((Substring:C12($testLine_t; 1; 1)=" ") | (Substring:C12($testLine_t; 1; 1)=$TAB_t))
												$testLine_t:=Substring:C12($testLine_t; 2)
											Else 
												$trim_b:=False:C215
											End if 
										End while 
										$trim_b:=True:C214
										While (($trim_b) & (Length:C16($testLine_t)>0))
											If ((Substring:C12($testLine_t; Length:C16($testLine_t); 1)=" ") | (Substring:C12($testLine_t; Length:C16($testLine_t); 1)=$TAB_t))
												$testLine_t:=Substring:C12($testLine_t; 1; Length:C16($testLine_t)-1)
											Else 
												$trim_b:=False:C215
											End if 
										End while 
										
										If ($commentBlocks_b)
											If ($testLine_t#"/*")
												$methodCode_t:=Substring:C12($methodCode_t; 1; $lineStart_i-1)+"/*"+$CR_t+Substring:C12($methodCode_t; $lineStart_i)
												$blockChanged_b:=True:C214
											End if 
										Else 
											If ($testLine_t="/*")
												$removeEnd_i:=$lineEnd_i
												If ($lineEnd_i<=Length:C16($methodCode_t))
													$removeEnd_i:=$lineEnd_i+1
													If (($removeEnd_i<=Length:C16($methodCode_t)) & (Substring:C12($methodCode_t; $lineEnd_i; 1)=$CR_t) & (Substring:C12($methodCode_t; $removeEnd_i; 1)=$LF_t))
														$removeEnd_i:=$removeEnd_i+1
													End if 
												End if 
												$methodCode_t:=Substring:C12($methodCode_t; 1; $lineStart_i-1)+Substring:C12($methodCode_t; $removeEnd_i)
												$blockChanged_b:=True:C214
											End if 
										End if 
										
										$endPos_i:=Position:C15($end_t; $methodCode_t; $beginLineEnd_i+1)
										
										// Line immediately before the closing delimiter.
										$lineStart_i:=1
										$previousLineStart_i:=0
										$previousLineEnd_i:=0
										While (($lineStart_i>0) & ($lineStart_i<$endPos_i))
											$nextCR_i:=Position:C15($CR_t; $methodCode_t; $lineStart_i)
											$nextLF_i:=Position:C15($LF_t; $methodCode_t; $lineStart_i)
											If (($nextCR_i>0) & (($nextCR_i<$nextLF_i) | ($nextLF_i=0)))
												$lineEnd_i:=$nextCR_i
											Else 
												If ($nextLF_i>0)
													$lineEnd_i:=$nextLF_i
												Else 
													$lineEnd_i:=0
												End if 
											End if 
											
											If (($lineEnd_i=0) | ($lineEnd_i>=$endPos_i))
												$lineStart_i:=0
											Else 
												$previousLineStart_i:=$lineStart_i
												$previousLineEnd_i:=$lineEnd_i
												$lineStart_i:=$lineEnd_i+1
												If (($lineStart_i<=Length:C16($methodCode_t)) & (Substring:C12($methodCode_t; $lineEnd_i; 1)=$CR_t) & (Substring:C12($methodCode_t; $lineStart_i; 1)=$LF_t))
													$lineStart_i:=$lineStart_i+1
												End if 
											End if 
										End while 
										
										If ($previousLineStart_i>0)
											$line_t:=Substring:C12($methodCode_t; $previousLineStart_i; $previousLineEnd_i-$previousLineStart_i)
											$testLine_t:=$line_t
											
											$trim_b:=True:C214
											While (($trim_b) & (Length:C16($testLine_t)>0))
												If ((Substring:C12($testLine_t; 1; 1)=" ") | (Substring:C12($testLine_t; 1; 1)=$TAB_t))
													$testLine_t:=Substring:C12($testLine_t; 2)
												Else 
													$trim_b:=False:C215
												End if 
											End while 
											$trim_b:=True:C214
											While (($trim_b) & (Length:C16($testLine_t)>0))
												If ((Substring:C12($testLine_t; Length:C16($testLine_t); 1)=" ") | (Substring:C12($testLine_t; Length:C16($testLine_t); 1)=$TAB_t))
													$testLine_t:=Substring:C12($testLine_t; 1; Length:C16($testLine_t)-1)
												Else 
													$trim_b:=False:C215
												End if 
											End while 
											
											If ($commentBlocks_b)
												If ($testLine_t#"*/")
													$methodCode_t:=Substring:C12($methodCode_t; 1; $endPos_i-1)+"*/"+$CR_t+Substring:C12($methodCode_t; $endPos_i)
													$blockChanged_b:=True:C214
												End if 
											Else 
												If ($testLine_t="*/")
													$removeEnd_i:=$previousLineEnd_i
													If ($previousLineEnd_i<=Length:C16($methodCode_t))
														$removeEnd_i:=$previousLineEnd_i+1
														If (($removeEnd_i<=Length:C16($methodCode_t)) & (Substring:C12($methodCode_t; $previousLineEnd_i; 1)=$CR_t) & (Substring:C12($methodCode_t; $removeEnd_i; 1)=$LF_t))
															$removeEnd_i:=$removeEnd_i+1
														End if 
													End if 
													$methodCode_t:=Substring:C12($methodCode_t; 1; $previousLineStart_i-1)+Substring:C12($methodCode_t; $removeEnd_i)
													$blockChanged_b:=True:C214
												End if 
											End if 
										End if 
										
										If ($blockChanged_b)
											$changedBlockCount_i:=$changedBlockCount_i+1
											$methodBlockCount_i:=$methodBlockCount_i+1
										End if 
										
										$scanFrom_i:=Position:C15($end_t; $methodCode_t; $beginLineEnd_i+1)+Length:C16($end_t)
									End if 
								End if 
							End if 
						End while 
						
						If ($methodCode_t#$originalCode_t)
							$methodCode_t:=Replace string:C233($methodCode_t; ",\"folder\":\"OT Testing\""; "")
							$methodCode_t:=Replace string:C233($methodCode_t; ",\"lang\":\"en\""; "")
							METHOD SET CODE:C1194($methodName_t; $methodCode_t; *)
							$changedMethodCount_i:=$changedMethodCount_i+1
							APPEND TO ARRAY:C911($changedMethods_at; $methodName_t+" ("+String:C10($methodBlockCount_i)+" block"+Choose:C955($methodBlockCount_i=1; ""; "s")+")")
						End if 
					End for 
				End if 
			End if 
		End if 
	End if 
End if 

If ($compiledMode_b)
	$summary_t:="OT block conversion was not run."+$CR_t+"Method source cannot be changed in compiled mode."
Else 
	If ($cancelled_b)
		$summary_t:="OT block conversion cancelled."
	Else 
		$summary_t:="OT block "+$action_t+"ing complete."+$CR_t
		$summary_t:=$summary_t+"Methods listed: "+String:C10(Size of array:C274($methodNames_at)+Size of array:C274($missingMethods_at))+$CR_t
		$summary_t:=$summary_t+"Methods found: "+String:C10(Size of array:C274($methodNames_at))+$CR_t
		$summary_t:=$summary_t+"Blocks found: "+String:C10($blockCount_i)+$CR_t
		$summary_t:=$summary_t+"Blocks changed: "+String:C10($changedBlockCount_i)+$CR_t
		$summary_t:=$summary_t+"Methods changed: "+String:C10($changedMethodCount_i)
		
		If (Size of array:C274($changedMethods_at)>0)
			$summary_t:=$summary_t+$CR_t+$CR_t+"Changed methods:"
			For ($methodIndex_i; 1; Size of array:C274($changedMethods_at))
				$summary_t:=$summary_t+$CR_t+"- "+$changedMethods_at{$methodIndex_i}
			End for 
		End if 
		
		If (Size of array:C274($missingMethods_at)>0)
			$summary_t:=$summary_t+$CR_t+$CR_t+"Missing methods:"
			For ($methodIndex_i; 1; Size of array:C274($missingMethods_at))
				$summary_t:=$summary_t+$CR_t+"- "+$missingMethods_at{$methodIndex_i}
			End for 
		End if 
	End if 
End if 

If (Not:C34($hideAlert_b))
	ALERT:C41($summary_t)
End if 

OTr_z_RemoveFromCallStack(Current method name:C684)
