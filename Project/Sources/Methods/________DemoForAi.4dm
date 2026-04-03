//%attributes = {"invisible":true}
Use (Storage:C1525)
	Storage:C1525.OTXController:=New shared object:C1526("ObjectTable"; New shared collection:C1527)
	Storage:C1525.OTX_Group_1:=New shared object:C1526("OTX_01"; New shared object:C1526(); "OTX_11"; New shared object:C1526())  // OTX_n1 series object will be added here
	Storage:C1525.OTX_Group_2:=New shared object:C1526("OTX_02"; New shared object:C1526(); "OTX_12"; New shared object:C1526())  // OTX_n2 series object will be added here
	Storage:C1525.OTX_Group_3:=New shared object:C1526("OTX_03"; New shared object:C1526(); "OTX_13"; New shared object:C1526())  // OTX_n3 series object will be added here
	// Skip a few
	Storage:C1525.OTX_Group_0:=New shared object:C1526("OTX_10"; New shared object:C1526(); "OTX_20"; New shared object:C1526())  // OTX_n0 series object will be added here
	
End use 
var $json : Text
$json:=JSON Stringify:C1217(Storage:C1525; *)
SET TEXT TO PASTEBOARD:C523($json)
