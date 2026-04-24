var $item_i; $Size_i : Integer

var $OTR_List_ptr : Pointer

$OTR_List_ptr:=OBJECT Get pointer:C1124(Object named:K67:5; "OTr_ObjectHandles")


$item_i:=$OTR_List_ptr->
$Size_i:=Size of array:C274(<>OTR_InUse_ab)

If ($item_i>0) & ($item_i<=$Size_i)
	Form:C1466.objectPreview:=OT SaveToText($item_i; True:C214)
	
Else 
	Form:C1466.objectPreview:="No object to display"
	
End if 
