//%attributes = {"invisible":true,"shared":false}
///*
//Constants methods by Cannon Smith
//https:  //www.synergyfarmsolutions.com
//*/

// Access: Private

// Mod by Wayne Stewart, (2022-04-19) - If only one parameter used that becomes the constant

C_TEXT:C284($1; $tConstantName)
C_TEXT:C284($2; $tConstantValue)

$tConstantName:=$1
If (Count parameters:C259=1)
	$tConstantValue:=$1
Else 
	$tConstantValue:=$2
End if 

C_TEXT:C284($tConstantXMLRef; $tConstantNameXMLRef)

//Increment the constant number
vlCC_CurrentConstantNumber:=vlCC_CurrentConstantNumber+1

//Add constant to list of constants within current group
$tConstantXMLRef:=DOM Create XML element:C865(vtCC_XMLCurrentGroupRef; "trans-unit"; \
"d4:value"; $tConstantValue+":S"; \
"id"; "k_"+String:C10(vlCC_CurrentConstantNumber))

//Add constant name
$tConstantNameXMLRef:=DOM Create XML element:C865($tConstantXMLRef; "source")
DOM SET XML ELEMENT VALUE:C868($tConstantNameXMLRef; $tConstantName)
