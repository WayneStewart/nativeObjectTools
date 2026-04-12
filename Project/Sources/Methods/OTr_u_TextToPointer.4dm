//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTr_u_TextToPointer ($pointerAsText_t : Text) --> Pointer

// Deserialises a Pointer from a stored text string.
// Format: "variableName;tableNum;fieldNum"
// 1.  Variable pointer:    "myVar;-1;0"
// 2.  Array element:       "myArr;3;0"
// 3.  Table pointer:       ";2;0"
// 4.  Field pointer:       ";2;5"

// Note: Variable and array-element pointers are
// resolved via Get pointer. This works when the
// caller's process owns the variable. For cross-
// process use a host-side wrapper would be needed.

// Access: Private

// Parameters:
//   $pointerAsText_t : Text : Serialised pointer text

// Returns:
//   $thePointer_ptr : Pointer : Reconstructed pointer,
//                               or Null if unresolvable

// Created by Wayne Stewart, 2026-04-01
// Based on Dict_GetPointer by Rob Laveaux
// ----------------------------------------------------

// Created by Wayne Stewart, 2026-04-01
// Based on Dict_GetPointer by Rob Laveaux
// ----------------------------------------------------

#DECLARE($pointerAsText_t : Text)->$thePointer_ptr : Pointer

var $variableName_t; $remaining_t : Text
var $tableNum_i; $fieldNum_i; $pos_i : Integer

$thePointer_ptr:=Null:C1517

If ($pointerAsText_t#"")
	$pos_i:=Position:C15(";"; $pointerAsText_t)
	$variableName_t:=Substring:C12($pointerAsText_t; 1; $pos_i-1)
	$remaining_t:=Substring:C12($pointerAsText_t; $pos_i+1)
	
	$pos_i:=Position:C15(";"; $remaining_t)
	$tableNum_i:=Num:C11(Substring:C12($remaining_t; 1; $pos_i-1))
	$fieldNum_i:=Num:C11(Substring:C12($remaining_t; $pos_i+1))
	
	Case of 
		: (($variableName_t#"") & ($tableNum_i=-1))  // variable pointer
			If (Storage:C1525.OTr.structureName="nativeObjectTools")
				$thePointer_ptr:=Get pointer:C304($variableName_t)  // This should work during testing
			Else 
				EXECUTE METHOD:C1007("OT Host GetPointer"; $thePointer_ptr; $pointerAsText_t)  // This will execut in th host's namespace
			End if 
			
			
		: (($variableName_t#"") & ($tableNum_i>0))  // array element pointer
			// This will need testing, I'm not sure if we need to call a host method here
			$thePointer_ptr:=Get pointer:C304($variableName_t+"{"+String:C10($tableNum_i)+"}")
			
		: (($tableNum_i>0) & ($fieldNum_i=0))  // table pointer, this will work regardless of host or matrix
			$thePointer_ptr:=Table:C252($tableNum_i)
			
		: (($tableNum_i>0) & ($fieldNum_i>0))  // field pointer, this will work regardless of host or matrix
			$thePointer_ptr:=Field:C253($tableNum_i; $fieldNum_i)
			
	End case 
End if 
