//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: Fnd_FCS_ParseParameterLine (parameter line) -> Object

// Parses a single parameter comment line into name/type/description.

// Access: Private

// Parameters:
//   $1 : Text : Raw comment line (for example "//   $1 : Text : Name")

// Returns:
//   $result_o : Object : {valid; isDeclareStyle; name; type; description}

// Created by GitHub Copilot on 2026-03-29
// ----------------------------------------------------

#DECLARE($parameterline_t : Text)->$result_o : Object

var $Position_i; $line_i; $lastUnderscore_i : Integer
var $paramName_t; $paramType_t; $paramDesc_t; $firstChar_t : Text

$result_o:=New object:C1471
$result_o.valid:=False:C215
$result_o.isDeclareStyle:=False:C215
$result_o.name:=""
$result_o.type:=""
$result_o.description:=""

$parameterline_t:=Replace string:C233($parameterline_t; "//    $"; "$")
$parameterline_t:=Replace string:C233($parameterline_t; "//   $"; "$")
$parameterline_t:=Replace string:C233($parameterline_t; "//  $"; "$")
$parameterline_t:=Replace string:C233($parameterline_t; "// $"; "$")
$parameterline_t:=Replace string:C233($parameterline_t; " : "; "|")

If ((Length:C16($parameterline_t)>0) & (Substring:C12($parameterline_t; 1; 1)="$"))
	$Position_i:=Position:C15("|"; $parameterline_t)
	If ($Position_i>0)
		$paramName_t:=Substring:C12($parameterline_t; 1; $Position_i-1)
		$paramType_t:=Substring:C12($parameterline_t; $Position_i+1)
		$line_i:=Position:C15("|"; $paramType_t)
		If ($line_i>0)
			$paramDesc_t:=Substring:C12($paramType_t; $line_i+1)
			$paramType_t:=Substring:C12($paramType_t; 1; $line_i-1)
		Else 
			$paramDesc_t:=""
		End if 
		
		If (Length:C16($paramName_t)>1)
			If (Position:C15(Substring:C12($paramName_t; 2; 1); "0123456789")=0)
				$result_o.isDeclareStyle:=True:C214
				$paramName_t:=Substring:C12($paramName_t; 2)
				$lastUnderscore_i:=0
				$line_i:=Position:C15("_"; $paramName_t)
				While ($line_i>0)
					$lastUnderscore_i:=$line_i
					$line_i:=Position:C15("_"; $paramName_t; $line_i+1)
				End while 
				If ($lastUnderscore_i>1)
					$paramName_t:=Substring:C12($paramName_t; 1; $lastUnderscore_i-1)
				End if 
				$firstChar_t:=Substring:C12($paramName_t; 1; 1)
				$line_i:=Position:C15($firstChar_t; "ABCDEFGHIJKLMNOPQRSTUVWXYZ")
				If ($line_i>0)
					$paramName_t:=Substring:C12("abcdefghijklmnopqrstuvwxyz"; $line_i; 1)+Substring:C12($paramName_t; 2)
				End if 
			End if 
		End if 
		
		$result_o.valid:=True:C214
		$result_o.name:=$paramName_t
		$result_o.type:=$paramType_t
		$result_o.description:=$paramDesc_t
	End if 
End if 
