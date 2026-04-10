//%attributes = {"invisible":true}
#DECLARE($inObject_i : Integer; $inTag_t : Text; $outVarPointer_ptr : Pointer)

$varType_i:=Type:C295($outVarPointer_ptr)  // Returns is pointer
$returnType_i:=Value type:C1509($outVarPointer_ptr->)  // Returns whatever it is pointing to
