var $OTR_List_ptr : Pointer
var $i; $count_i : Integer

$OTR_List_ptr:=OBJECT Get pointer:C1124(Object named:K67:5; "OTr_ObjectHandles")

$count_i:=Size of array:C274(<>OTR_Objects_ao)

ARRAY LONGINT:C221($OTR_List_ptr->; $count_i)

For ($i; 1; $count_i)
	$OTR_List_ptr->{$i}:=$i
End for 

