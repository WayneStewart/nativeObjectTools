//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: Fnd_FCS_WriteDocumentation {(Method Name or prefix; Write Tooltip; Exclude Private Methods; silent; inline)}

// This method will create documentation comments
//   it is based on the assumption that you format your
//   method header comments in the same manner as Foundation
// The first parameter:
//       (a) "" - All methods (or don't pass any parameters)
//       (b) "Prefix" - Only methods which match a prefix (Eg. Fnd_Art)
//       (c) "Specific method name" - write comments for that method
//  The second parameter - True: generate a tooltip
//  The third parameter - True: Exclude Private methods
//  The fourth parameter - True: Don't show a final "Finished" alert
//  The fifth parameter  - True: Run inline in the calling process (no New process spawn)
//                         Use in headless/CI contexts where process management is undesirable.

// Access: Private

// Parameters:
//   $MethodName_t : Text : Method Name, Prefix of empty (all methods)
//   $ToolTip_b : Boolean : Write in the summary section (for the Tooltip)
//   $excludePrivate_b : Boolean : Exclude Private methods
//   $silent_b : Boolean : Show or Don't show a Finished alert after task complete
//   $inline_b : Boolean : Run inline in calling process rather than spawning a new process

// Created by Wayne Stewart
// Wayne Stewart, 2021-08-11 - Tooltip will now show the parameters
// Wayne Stewart, 2026-03-29 - Swapped method to #DECLARE and added optional silent flag.
// Wayne Stewart, 2026-03-30 - Improved markdown output formatting
//       (paragraph spacing, parameter/return tables, and no-parameter display).
// Wayne Stewart, 2026-04-21 - Added $inline_b parameter for headless/CI use.
// ----------------------------------------------------

#DECLARE($MethodName_t : Text; $ToolTip_b : Boolean; $excludePrivate_b : Boolean; $silent_b : Boolean; $inline_b : Boolean)

var $Attributes_t; $callSyntax_t; $CR; $FirstChars_t; $lastChar_t; $alert_t; $MethodCode_t; \
$nextline_t; $parameterBlock_t; $parameterline_t; \
$processName_t; $Space; $callSyntaxParameters_t; $documentationPath_t; $returnsBlock_t; $displayMethodName_t; $tooltipComment_t; $currentParagraph_t; $line_t; $trimmedLine_t; $digits_t; $paramName_t; $paramType_t; $paramDesc_t; $firstChar_t : Text
var $isNumbered_b; $isDeclareStyle_b; $inCodeBlock_b : Boolean
var $CurrentMethod_i; $line_i; $lineEnd_i; $nextLine_i; $numberofLines_i; $NumberOfMethods_i; \
$parameterBlock_i; $Position_i; $ProcessID_i; $returns_i; $StackSize_i; $commentLineCount_i; $commentLine_i; $lastUnderscore_i : Integer
var $Attributes_o; $lineInfo_o : Object

ARRAY TEXT:C222($MethodCode_at; 0)
ARRAY TEXT:C222($methodLines_at; 0)
ARRAY TEXT:C222($MethodNames_at; 0)
ARRAY TEXT:C222($commentLines_at; 0)
ARRAY TEXT:C222($formattedCommentLines_at; 0)

$processName_t:="$WriteDocumentation"
$StackSize_i:=0

If (Current process name:C1392=$processName_t) | ($inline_b)
	
	$CR:=Char:C90(Carriage return:K15:38)
	$Space:=" "
	
	METHOD GET PATHS:C1163(Path project method:K72:1; $MethodNames_at)
	
	
	
	If (Length:C16($MethodName_t)>0)  //  A method name or prefix has been specified
		
		$NumberOfMethods_i:=Count in array:C907($MethodNames_at; $MethodName_t)
		
		If ($NumberOfMethods_i=1)  // exactly one match (use this specific method)
			ARRAY TEXT:C222($MethodNames_at; 0)  // Empty the array
			APPEND TO ARRAY:C911($MethodNames_at; $MethodName_t)
		Else 
			
			$NumberOfMethods_i:=Size of array:C274($MethodNames_at)
			For ($CurrentMethod_i; $NumberOfMethods_i; 1; -1)  // Go Backwards
				If ($MethodNames_at{$CurrentMethod_i}=($MethodName_t+"@"))
				Else 
					DELETE FROM ARRAY:C228($MethodNames_at; $CurrentMethod_i)
				End if 
				
			End for 
			
		End if 
		
	End if 
	
	$NumberOfMethods_i:=Size of array:C274($MethodNames_at)
	
	METHOD GET CODE:C1190($MethodNames_at; $MethodCode_at)
	
	ARRAY TEXT:C222($MethodComments_at; $NumberOfMethods_i)
	
	For ($CurrentMethod_i; 1; $NumberOfMethods_i)
		
		$MethodName_t:=$MethodNames_at{$CurrentMethod_i}
		
		$MethodCode_t:=$MethodCode_at{$CurrentMethod_i}
		
		TEXT TO ARRAY:C1149($MethodCode_t; $methodLines_at; MAXTEXTLENBEFOREV11:K35:3; "Courier"; 9)
		
		// Delete the first line of code
		DELETE FROM ARRAY:C228($methodLines_at; 1; 1)  // attributes line
		// Remove the attributes line from the text as well
		$Position_i:=Position:C15($CR; $MethodCode_t)
		If ($Position_i>0)
			$MethodCode_t:=Substring:C12($MethodCode_t; $Position_i+1)
		End if 
		
		// Delete the actual code.
		// Search for "// Created by" anchored to a line start (preceded by CR) to
		// avoid false matches on prose containing "created by" mid-sentence
		// (e.g. "previously created by OTr_ObjectToBLOB").
		$Position_i:=Position:C15($CR+"// Created by"; $MethodCode_t)
		If ($Position_i>0)
			// Match includes the leading CR; keep everything before that CR.
			$MethodCode_t:=Substring:C12($MethodCode_t; 1; $Position_i-1)
		Else 
			// No CR-anchored match — try from position 1 (header starts immediately)
			$Position_i:=Position:C15("// Created by"; $MethodCode_t)
			If ($Position_i>0)
				$MethodCode_t:=Substring:C12($MethodCode_t; 1; $Position_i-1)
			End if 
			// If still 0, no "Created by" line exists — leave $MethodCode_t intact
		End if 
		// Find the "// Created by" line anchored to line start (not mid-sentence)
		$line_i:=Find in array:C230($methodLines_at; "// Created by@")
		If ($line_i<1)
			$line_i:=Find in array:C230($methodLines_at; "//  Created by@")  // two-space variant
		End if 
		If ($line_i>0)
			DELETE FROM ARRAY:C228($methodLines_at; $line_i; MAXTEXTLENBEFOREV11:K35:3)  // Get rid of the code section
		End if 
		
		// Delete block lines
		$MethodCode_t:=Replace string:C233($MethodCode_t; "  // ----------------------------------------------------\r"; "")
		$MethodCode_t:=Replace string:C233($MethodCode_t; "// ----------------------------------------------------\r"; "")
		
		// Check for Parameter Block
		$parameterBlock_i:=Position:C15("Parameters:"; $MethodCode_t)
		If ($parameterBlock_i>0)
			If (Position:C15("Parameters: None"; $MethodCode_t)>0)
				$parameterBlock_i:=0
			End if 
		End if 
		
		// Check for Returns
		$returns_i:=Position:C15("Returns:"; $MethodCode_t)
		If ($returns_i>0)
			If (Position:C15("Returns: Nothing"; $MethodCode_t)>0)
				$returns_i:=0
			End if 
		End if 
		
		$parameterBlock_t:="| Parameter | Type |  | Description |"+$CR+"| --- | --- | --- | --- |"+$CR
		$returnsBlock_t:=""
		$isDeclareStyle_b:=False:C215
		
		$numberofLines_i:=Size of array:C274($methodLines_at)
		If ($parameterBlock_i>0)
			// Anchor to line start — avoid matching "Parameters:" mid-sentence
			$parameterBlock_i:=Find in array:C230($methodLines_at; "// Parameters:@")+1
			If ($parameterBlock_i<2)
				$parameterBlock_i:=Find in array:C230($methodLines_at; "// Parameters:@"; 1)+1
			End if 
			$parameterline_t:=$methodLines_at{$parameterBlock_i}
			
			Repeat 
				$lineInfo_o:=Fnd_FCS_ParseParameterLine($parameterline_t)
				If ($lineInfo_o.valid)
					If ($lineInfo_o.isDeclareStyle)
						$isDeclareStyle_b:=True:C214
					End if 
					// Determine direction arrow from parameter name prefix
					var $arrow_t : Text
					Case of 
						: (Substring:C12($lineInfo_o.name; 1; 2)="io")
							$arrow_t:="↔️"
						: (Substring:C12($lineInfo_o.name; 1; 3)="out")
							$arrow_t:="⬅️"
						Else 
							$arrow_t:="➡️"
					End case 
					$parameterBlock_t:=$parameterBlock_t+"|"+$lineInfo_o.name+"|"+$lineInfo_o.type+"|"+$arrow_t+"|"+$lineInfo_o.description+"|"+$CR
				End if 
				$parameterBlock_i:=$parameterBlock_i+1
				
				// This has a more complicated end condition because we may get an out of range error
				If ($parameterBlock_i<=$numberofLines_i)
					$parameterline_t:=$methodLines_at{$parameterBlock_i}
				Else 
					$parameterline_t:=""
				End if 
				
				$nextLine_i:=$parameterBlock_i+1
				If ($nextLine_i<=$numberofLines_i)
					$nextline_t:=$methodLines_at{$nextLine_i}
				Else 
					$nextline_t:=""
				End if 
				
				// Exit loop if
				//1. Run out of lines
				//2. Two blank lines in a row
				//3. Found returns section (when present)
				
				
			Until ($parameterBlock_i>$numberofLines_i)\
				 | (($parameterline_t="") & ($nextline_t=""))\
				 | (($returns_i>0) & ($parameterline_t="@Returns@"))
		Else 
			If ($returns_i=0)
				$parameterBlock_t:="| Parameters |"+$CR+"| --- |"+$CR+"| Does not require any parameters |"+$CR
			End if 
		End if 
		
		$parameterBlock_t:=Replace string:C233($parameterBlock_t; $CR+$CR; $CR)
		
		If ($returns_i>0)
			// Anchor to line start — avoid matching "// Returns the..." or "//// Returns:"
			$parameterBlock_i:=Find in array:C230($methodLines_at; "// Returns:@"; $parameterBlock_i)
			If ($parameterBlock_i<1)
				$parameterBlock_i:=Find in array:C230($methodLines_at; "// Returns:@")
			End if 
			// Reject matches on double-commented lines (//// Returns:)
			If ($parameterBlock_i>0)
				If (Substring:C12($methodLines_at{$parameterBlock_i}; 1; 4)="////")
					$parameterBlock_i:=-1
				End if 
			End if 
			If ($parameterBlock_i<1)
				$returns_i:=0
			End if 
			
			If ($returns_i>0)
				$parameterline_t:=$methodLines_at{$parameterBlock_i}
				$returnsBlock_t:=""
				$paramName_t:="Result"
				$paramType_t:=""
				
				Repeat 
					$parameterline_t:=Replace string:C233($parameterline_t; "// Returns: "; "")
					$parameterline_t:=Replace string:C233($parameterline_t; "// Returns:"; "")
					$parameterline_t:=Replace string:C233($parameterline_t; "//    $"; "$")
					$parameterline_t:=Replace string:C233($parameterline_t; "//   $"; "$")
					$parameterline_t:=Replace string:C233($parameterline_t; "//  $"; "$")
					$parameterline_t:=Replace string:C233($parameterline_t; "// $"; "$")
					$parameterline_t:=Replace string:C233($parameterline_t; "// "; "")
					
					If (Length:C16($parameterline_t)>0)
						// Detect declare-style return variable even when no Parameters block was present
						If ((Substring:C12($parameterline_t; 1; 1)="$") & (Position:C15(Substring:C12($parameterline_t; 2; 1); "0123456789")=0))
							$isDeclareStyle_b:=True:C214
						End if 
						If ($isDeclareStyle_b)
							$Position_i:=Position:C15(" : "; $parameterline_t)
							If (($Position_i>1) & (Substring:C12($parameterline_t; 1; 1)="$"))
								$line_i:=Position:C15(" : "; $parameterline_t; $Position_i+3)
								If ($line_i>0)
									$paramType_t:=Substring:C12($parameterline_t; $Position_i+3; $line_i-($Position_i+3))
									$parameterline_t:=Substring:C12($parameterline_t; $line_i+3)
								End if 
								If (Length:C16($returnsBlock_t)>0)
									$returnsBlock_t:=$returnsBlock_t+" "+$parameterline_t
								Else 
									$returnsBlock_t:=$parameterline_t
								End if 
							Else 
								If (Length:C16($returnsBlock_t)>0)
									$returnsBlock_t:=$returnsBlock_t+" "+$parameterline_t
								Else 
									$returnsBlock_t:=$parameterline_t
								End if 
							End if 
						Else 
							If (Substring:C12($parameterline_t; 1; 2)="$0")
								$Position_i:=Position:C15(" : "; $parameterline_t)
								If ($Position_i>1)
									$line_i:=Position:C15(" : "; $parameterline_t; $Position_i+3)
									If ($line_i>0)
										$paramName_t:=Substring:C12($parameterline_t; 1; $Position_i-1)
										$paramType_t:=Substring:C12($parameterline_t; $Position_i+3; $line_i-($Position_i+3))
										$parameterline_t:=Substring:C12($parameterline_t; $line_i+3)
									End if 
								End if 
							End if 
							If (Length:C16($returnsBlock_t)>0)
								$returnsBlock_t:=$returnsBlock_t+" "+$parameterline_t
							Else 
								$returnsBlock_t:=$parameterline_t
							End if 
						End if 
					End if 
					$parameterBlock_i:=$parameterBlock_i+1
					
					// This has a more complicated end condition because we may get an out of range error
					If ($parameterBlock_i<=$numberofLines_i)
						$parameterline_t:=$methodLines_at{$parameterBlock_i}
					Else 
						$parameterline_t:=""
					End if 
					
					$nextLine_i:=$parameterBlock_i+1
					If ($nextLine_i<=$numberofLines_i)
						$nextline_t:=$methodLines_at{$nextLine_i}
					Else 
						$nextline_t:=""
					End if 
					
					// Exit loop if
					//1. Run out of lines
					//2. Two blank lines in a row
					//3. Hmmm…
					
				Until ($parameterBlock_i>$numberofLines_i)\
					 | (($parameterline_t="") & ($nextline_t=""))
				
			End if   // inner If ($returns_i>0)
			
		End if   // outer If ($returns_i>0)
		
		If (Length:C16($returnsBlock_t)>0)
			$parameterline_t:="|"+$paramName_t+"|"
			If (Length:C16($paramType_t)>0)
				$parameterline_t:=$parameterline_t+$paramType_t
			End if 
			$parameterline_t:=$parameterline_t+"|⬅️|"+$returnsBlock_t+"|"
			$parameterBlock_t:=$parameterBlock_t+$parameterline_t+$CR
		End if 
		
		$parameterBlock_t:=Replace string:C233($parameterBlock_t; $CR+$CR; $CR)  // Get rid of any blank lines
		
		// Now remove everything below the Parameter Block
		$parameterBlock_i:=Position:C15("// Parameters:"; $MethodCode_t)
		$returns_i:=Position:C15("// Returns:"; $MethodCode_t)
		
		If ($parameterBlock_i>0)
			$MethodCode_t:=Substring:C12($MethodCode_t; 1; $parameterBlock_i-1)
		Else 
			If ($returns_i>0)
				$MethodCode_t:=Substring:C12($MethodCode_t; 1; $returns_i-1)
			End if 
		End if 
		
		//  Threadsafe?
		METHOD GET ATTRIBUTES:C1334($MethodName_t; $Attributes_o)
		
		$Attributes_t:="Attributes: "
		
		If ($Attributes_o.shared=True:C214)
			$Attributes_t:=$Attributes_t+"Shared, "
		Else 
			$Attributes_t:=$Attributes_t+"Private, "
		End if 
		
		If ($Attributes_o.executedOnServer)
			$Attributes_t:=$Attributes_t+"Server, "
		End if 
		
		If ($Attributes_o.invisible)
			$Attributes_t:=$Attributes_t+"Invisible, "
		End if 
		
		//Compatibility note: The published4DMobile property is deprecated as for 4D v18.
		//If ($Attributes_o.published4DMobile#Null)
		//$Attributes_t:=$Attributes_t+"4D Mobile, "
		//End if
		
		
		Case of 
			: ($Attributes_o.preemptive="capable")
				$Attributes_t:=$Attributes_t+"Preemptive capable, "
				
			: ($Attributes_o.preemptive="incapable")
				$Attributes_t:=$Attributes_t+"Preemptive incapable, "
				
			: ($Attributes_o.preemptive="indifferent")
				$Attributes_t:=$Attributes_t+"Preemptive indifferent, "
				
		End case 
		
		If ($Attributes_o.publishedSoap)
			$Attributes_t:=$Attributes_t+"Soap, "
		End if 
		
		If ($Attributes_o.publishedSql)
			$Attributes_t:=$Attributes_t+"SQL, "
		End if 
		
		If ($Attributes_o.publishedWeb)
			$Attributes_t:=$Attributes_t+"Web, "
		End if 
		
		If ($Attributes_o.publishedWsdl)
			$Attributes_t:=$Attributes_t+"WSDL, "
		End if 
		
		If (Length:C16($Attributes_t)>1)
			$Attributes_t:=Substring:C12($Attributes_t; 1; Length:C16($Attributes_t)-2)+$CR+$CR
		End if 
		
		$Position_i:=Position:C15("Project Method: "; $MethodCode_t)
		$Position_i:=$Position_i+15  // length("Project Method:")
		$LineEnd_i:=Position:C15($CR; $MethodCode_t; $Position_i)
		
		$callSyntax_t:=Substring:C12($MethodCode_t; $Position_i; $LineEnd_i-$Position_i)
		
		While (Substring:C12($callSyntax_t; 1; 1)=$Space)  //  Get rid of a variable number of spaces
			$callSyntax_t:=Substring:C12($callSyntax_t; 2)
		End while 
		
		$callSyntax_t:=Replace string:C233($callSyntax_t; "-->"; "->")  // --> is a symbol used in MD
		
		$callSyntaxParameters_t:=$parameterBlock_t
		
		$callSyntaxParameters_t:=Replace string:C233($callSyntaxParameters_t; "| Parameter | Type |  | Description |"+$CR; "")
		$callSyntaxParameters_t:=Replace string:C233($callSyntaxParameters_t; "| --- | --- | --- | --- |"+$CR; "")
		$callSyntaxParameters_t:=Replace string:C233($callSyntaxParameters_t; "| Parameters |"+$CR; "")
		$callSyntaxParameters_t:=Replace string:C233($callSyntaxParameters_t; "| --- |"+$CR; "")
		$callSyntaxParameters_t:=Replace string:C233($callSyntaxParameters_t; "|"+$CR; $CR)
		$callSyntaxParameters_t:=Replace string:C233($callSyntaxParameters_t; $CR+"|"; $CR)
		If (Substring:C12($callSyntaxParameters_t; 1; 1)="|")
			$callSyntaxParameters_t:=Substring:C12($callSyntaxParameters_t; 2)
		End if 
		$callSyntaxParameters_t:=Replace string:C233($callSyntaxParameters_t; "|"; " : ")
		$callSyntaxParameters_t:=Replace string:C233($callSyntaxParameters_t; $CR+$CR; $CR)
		//$callSyntaxParameters_t:=Replace string($callSyntaxParameters_t;"\r";$CR)
		
		$tooltipComment_t:=""
		If ($ToolTip_b)
			$tooltipComment_t:="<!--"+$callSyntax_t
			If (Length:C16($callSyntaxParameters_t)>0)
				$tooltipComment_t:=$tooltipComment_t+$CR+$callSyntaxParameters_t
			End if 
			$tooltipComment_t:=$tooltipComment_t+"-->"+$CR
		End if 
		
		$FirstChars_t:=Substring:C12($callSyntax_t; 1; 1)
		While ($FirstChars_t=" ")
			$callSyntax_t:=Substring:C12($callSyntax_t; 2)
			$FirstChars_t:=Substring:C12($callSyntax_t; 1; 1)
		End while 
		
		$displayMethodName_t:=Replace string:C233($MethodName_t; "_"; "\\_")
		
		$MethodCode_t:=Replace string:C233($MethodCode_t; "\r// Access: Shared\r"; $CR+$Attributes_t)
		$MethodCode_t:=Replace string:C233($MethodCode_t; "\r// Access: Private\r"; $CR+$Attributes_t)
		
		//  End Threadsafe section
		
		$MethodCode_t:=Replace string:C233($MethodCode_t; "  // Project Method: "; "")
		$MethodCode_t:=Replace string:C233($MethodCode_t; "// Project Method: "; "")
		
		$MethodCode_t:=Replace string:C233($MethodCode_t; "  // "; "")
		$MethodCode_t:=Replace string:C233($MethodCode_t; "// "; "")
		
		// Format comment lines into readable Markdown paragraphs.
		// Rules:
		// 1) Blank line => paragraph break
		// 2) Indented following line => continuation of same paragraph
		// 3) Prior line ending with . : ? => start a new paragraph
		// 4) Lines beginning with N. are treated as standalone numbered lines
		TEXT TO ARRAY:C1149($MethodCode_t; $commentLines_at; MAXTEXTLENBEFOREV11:K35:3; "Courier"; 9)
		ARRAY TEXT:C222($formattedCommentLines_at; 0)
		$currentParagraph_t:=""
		$inCodeBlock_b:=False:C215
		$commentLineCount_i:=Size of array:C274($commentLines_at)
		For ($commentLine_i; 1; $commentLineCount_i)
			$line_t:=$commentLines_at{$commentLine_i}
			$trimmedLine_t:=$line_t
			
			While (Substring:C12($trimmedLine_t; 1; 1)=$Space)
				$trimmedLine_t:=Substring:C12($trimmedLine_t; 2)
			End while 
			
			If ($trimmedLine_t="```")
				// Code fence token — toggle code-block mode
				If ($inCodeBlock_b)
					// Closing fence
					APPEND TO ARRAY:C911($formattedCommentLines_at; "```")
					$inCodeBlock_b:=False:C215
				Else 
					// Opening fence — flush any pending paragraph first
					If (Length:C16($currentParagraph_t)>0)
						APPEND TO ARRAY:C911($formattedCommentLines_at; $currentParagraph_t)
						$currentParagraph_t:=""
					End if 
					If (Size of array:C274($formattedCommentLines_at)>0)
						If ($formattedCommentLines_at{Size of array:C274($formattedCommentLines_at)}#"")
							APPEND TO ARRAY:C911($formattedCommentLines_at; "")
						End if 
					End if 
					APPEND TO ARRAY:C911($formattedCommentLines_at; "```")
					$inCodeBlock_b:=True:C214
				End if 
			Else 
				If ($inCodeBlock_b)
					// Inside a code block: preserve line verbatim, no underscore escaping, no merging
					APPEND TO ARRAY:C911($formattedCommentLines_at; $trimmedLine_t)
				Else 
					// Normal prose processing
					// Escape underscores for Markdown here (per-line, outside code blocks)
					$trimmedLine_t:=Replace string:C233($trimmedLine_t; "_"; "\\_")
					
					If (Length:C16($trimmedLine_t)=0)
						If (Length:C16($currentParagraph_t)>0)
							APPEND TO ARRAY:C911($formattedCommentLines_at; $currentParagraph_t)
							$currentParagraph_t:=""
						End if 
						If ((Size of array:C274($formattedCommentLines_at)=0))
						Else 
							If ($formattedCommentLines_at{Size of array:C274($formattedCommentLines_at)}#"")
								APPEND TO ARRAY:C911($formattedCommentLines_at; "")
							End if 
						End if 
					Else 
						$digits_t:="0123456789"
						$Position_i:=Position:C15("."; $trimmedLine_t)
						$isNumbered_b:=False:C215
						If ($Position_i>1)
							$nextline_t:=Substring:C12($trimmedLine_t; 1; $Position_i-1)
							$isNumbered_b:=True:C214
							For ($line_i; 1; Length:C16($nextline_t))
								If (Position:C15(Substring:C12($nextline_t; $line_i; 1); $digits_t)=0)
									$isNumbered_b:=False:C215
								End if 
							End for 
							If ($isNumbered_b)
								If (Length:C16($trimmedLine_t)>$Position_i)
									If (Substring:C12($trimmedLine_t; $Position_i+1; 1)#$Space)
										$isNumbered_b:=False:C215
									End if 
								Else 
									$isNumbered_b:=False:C215
								End if 
							End if 
						End if 
						
						If ($isNumbered_b | (Substring:C12($trimmedLine_t; 1; 2)="- "))  // Numbered or bullet line: keep as standalone
							If (Length:C16($currentParagraph_t)>0)
								APPEND TO ARRAY:C911($formattedCommentLines_at; $currentParagraph_t)
								// Only add blank line before bullet if previous line was not also a bullet
								If ($formattedCommentLines_at{Size of array:C274($formattedCommentLines_at)}#"")
									If (Substring:C12($formattedCommentLines_at{Size of array:C274($formattedCommentLines_at)}; 1; 2)#"- ")
										APPEND TO ARRAY:C911($formattedCommentLines_at; "")
									End if 
								End if 
								$currentParagraph_t:=""
							Else 
								// No pending paragraph — only add blank line if previous output was not a bullet
								If (Size of array:C274($formattedCommentLines_at)>0)
									If ($formattedCommentLines_at{Size of array:C274($formattedCommentLines_at)}="")
										// Previous was blank — check the one before that
										If (Size of array:C274($formattedCommentLines_at)>1)
											If (Substring:C12($formattedCommentLines_at{Size of array:C274($formattedCommentLines_at)-1}; 1; 2)="- ")
												// Previous non-blank was a bullet — remove the blank line to keep list tight
												DELETE FROM ARRAY:C228($formattedCommentLines_at; Size of array:C274($formattedCommentLines_at); 1)
											End if 
										End if 
									End if 
								End if 
							End if 
							APPEND TO ARRAY:C911($formattedCommentLines_at; $trimmedLine_t)
						Else 
							If (Length:C16($currentParagraph_t)=0)
								$currentParagraph_t:=$trimmedLine_t
							Else 
								If (Substring:C12($line_t; 1; 1)=$Space)  // Indented continuation
									$currentParagraph_t:=$currentParagraph_t+" "+$trimmedLine_t
								Else 
									$lastChar_t:=Substring:C12($currentParagraph_t; Length:C16($currentParagraph_t); 1)
									If (Position:C15($lastChar_t; ".:?")>0)
										APPEND TO ARRAY:C911($formattedCommentLines_at; $currentParagraph_t)
										If ($formattedCommentLines_at{Size of array:C274($formattedCommentLines_at)}#"")
											APPEND TO ARRAY:C911($formattedCommentLines_at; "")
										End if 
										$currentParagraph_t:=$trimmedLine_t
									Else 
										$currentParagraph_t:=$currentParagraph_t+" "+$trimmedLine_t
									End if 
								End if 
							End if 
						End if 
					End if 
				End if 
			End if 
		End for 
		
		If (Length:C16($currentParagraph_t)>0)
			APPEND TO ARRAY:C911($formattedCommentLines_at; $currentParagraph_t)
		End if 
		If ($inCodeBlock_b)  // Unclosed code fence — force-close
			APPEND TO ARRAY:C911($formattedCommentLines_at; "```")
			$inCodeBlock_b:=False:C215
		End if 
		
		$MethodCode_t:=""
		$commentLineCount_i:=Size of array:C274($formattedCommentLines_at)
		For ($commentLine_i; 1; $commentLineCount_i)
			If ($commentLine_i>1)
				$MethodCode_t:=$MethodCode_t+$CR
			End if 
			$MethodCode_t:=$MethodCode_t+$formattedCommentLines_at{$commentLine_i}
		End for 
		
		
		If (Length:C16($parameterBlock_t)>0)
			$MethodCode_t:=$MethodCode_t+$CR+$CR+$parameterBlock_t
		End if 
		
		$FirstChars_t:=Substring:C12($MethodCode_t; 1; 2)
		While ($FirstChars_t="\r\r")
			$MethodCode_t:=Substring:C12($MethodCode_t; 2)
			$FirstChars_t:=Substring:C12($MethodCode_t; 1; 2)
		End while 
		
		$lastChar_t:=Substring:C12($MethodCode_t; Length:C16($MethodCode_t); 1)
		While ($lastChar_t=$CR)\
			 | ($lastChar_t=$Space)
			$MethodCode_t:=Substring:C12($MethodCode_t; 1; Length:C16($MethodCode_t)-1)
			$lastChar_t:=Substring:C12($MethodCode_t; Length:C16($MethodCode_t); 1)
		End while 
		
		$MethodCode_t:=$tooltipComment_t+"## "+$displayMethodName_t+$CR+$CR+$MethodCode_t
		
		$MethodCode_t:=Replace string:C233($MethodCode_t; $CR+"//"; $CR)
		
		If ($excludePrivate_b)
			If ($Attributes_o.shared#True:C214)  // not shared — treat as private
				$MethodCode_t:=""  // Clear all that work we just did!
			End if 
		End if 
		
		If (Length:C16($MethodCode_t)=0)
		Else 
			$MethodComments_at{$CurrentMethod_i}:=$MethodCode_t
		End if 
		
	End for 
	
	$NumberOfMethods_i:=Size of array:C274($MethodComments_at)
	For ($CurrentMethod_i; $NumberOfMethods_i; 1; -1)  // Go Backwards
		If (Length:C16($MethodComments_at{$CurrentMethod_i})>0)
		Else 
			DELETE FROM ARRAY:C228($MethodNames_at; $CurrentMethod_i)
			DELETE FROM ARRAY:C228($MethodComments_at; $CurrentMethod_i)
		End if 
		
	End for 
	
	METHOD SET COMMENTS:C1193($MethodNames_at; $MethodComments_at)
	
	If ($silent_b)
	Else 
		$NumberOfMethods_i:=Size of array:C274($MethodNames_at)
		$alert_t:="Finished: "+String:C10($NumberOfMethods_i; "###,##0")+" .md files."
		If ($excludePrivate_b)
			$alert_t:=$alert_t+$CR+"Excluding Private Methods."
		Else 
			$alert_t:=$alert_t+$CR+"Including Private Methods."
		End if 
		ALERT:C41($alert_t; "Great")
	End if 
	
Else 
	
	var $launchMethodName_t : Text
	var $launchToolTip_b; $launchExcludePrivate_b; $launchSilent_b : Boolean
	
	If (Count parameters:C259<1)
		$launchMethodName_t:=""
	Else 
		$launchMethodName_t:=$MethodName_t
	End if 
	If (Count parameters:C259<2)
		$launchToolTip_b:=True:C214
	Else 
		$launchToolTip_b:=$ToolTip_b
	End if 
	If (Count parameters:C259<3)
		$launchExcludePrivate_b:=True:C214
	Else 
		$launchExcludePrivate_b:=$excludePrivate_b
	End if 
	If (Count parameters:C259<4)
		$launchSilent_b:=True:C214
	Else
		$launchSilent_b:=$silent_b
	End if

	var $launchInline_b : Boolean
	If (Count parameters:C259<5)
		$launchInline_b:=False:C215
	Else
		$launchInline_b:=$inline_b
	End if

	If ($launchExcludePrivate_b)  // Delete the existing documentation folder
		$documentationPath_t:=Get 4D folder:C485(Database folder:K5:14)+"Documentation"+Folder separator:K24:12+"Methods"+Folder separator:K24:12
		If (Test path name:C476($documentationPath_t)=Is a folder:K24:2)
			DELETE FOLDER:C693($documentationPath_t; Delete with contents:K24:24)
		End if
		CREATE FOLDER:C475($documentationPath_t)
	End if

	If ($launchInline_b)
		// Run inline — re-enter the method in the work branch directly.
		Fnd_FCS_WriteDocumentation($launchMethodName_t; $launchToolTip_b; $launchExcludePrivate_b; $launchSilent_b; True:C214)
	Else
		// This version allows for any number of processes
		// $ProcessID_i:=New Process(Current method name;$StackSize_i;Current method name;0)

		// On the other hand, this version allows for one unique process
		$ProcessID_i:=New process:C317(Current method name:C684; $StackSize_i; $processName_t; $launchMethodName_t; $launchToolTip_b; $launchExcludePrivate_b; $launchSilent_b; *)

		RESUME PROCESS:C320($ProcessID_i)
		SHOW PROCESS:C325($ProcessID_i)
		BRING TO FRONT:C326($ProcessID_i)
	End if
End if 