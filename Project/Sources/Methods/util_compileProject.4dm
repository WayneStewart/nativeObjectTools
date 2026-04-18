//%attributes = {"invisible":true}
#DECLARE()->$result_o : Object

C_OBJECT:C1216($options_o)

$options_o:=New object:C1471
$options_o.targets:=New collection:C1472  //Empty collection for syntax checking

$result_o:=Compile project:C1760($options_o)
