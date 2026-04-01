C_LONGINT:C283($Dict_i)
C_POINTER:C301($Obj_ptr)
C_PICTURE:C286($Original_Pic; $NewPicture_pic)


$Obj_ptr:=OBJECT Get pointer:C1124(Object named:K67:5; "Picture_One")

$Original_Pic:=$Obj_ptr->

$Dict_i:=Dict_New("Test Dictionary")

Dict_SetPicture($Dict_i; "My Picture"; $Original_Pic)


$NewPicture_pic:=Dict_GetPicture($Dict_i; "My Picture")

$Obj_ptr:=OBJECT Get pointer:C1124(Object named:K67:5; "Picture_Two")

$Obj_ptr->:=$NewPicture_pic

