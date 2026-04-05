//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
//Author: Wayne Stewart <waynestewart@mac.com>
// Date and time: 17/06/07, 16:45:09
// ----------------------------------------------------
// Method: OTX New
// Description
//   Creates a new pseudo Object Tools object
//
// Parameters
C_LONGINT:C283($0; $ObjectID_i)

// Local Vars
C_LONGINT:C283($ArrayPos_i)
C_POINTER:C301($Object_ptr)


// ----------------------------------------------------

OTX Init

Repeat 
	$ObjectID_i:=Milliseconds:C459
	$ArrayPos_i:=Find in array:C230(<>OTX_ListOfObjects_ai; $ObjectID_i)
	
Until ($ArrayPos_i=-1)

APPEND TO ARRAY:C911(<>OTX_ListOfObjects_ai; $ObjectID_i)

$Object_ptr:=rVar_GetVariableByType(Pointer array:K8:23)
APPEND TO ARRAY:C911(<>OTX_Objects_aptr; $Object_ptr)
ARRAY POINTER:C280($Object_ptr->; 3)
$Object_ptr->{<>OTX_ItemNames_i}:=rVar_GetVariableByType(Text array:K8:16)
$Object_ptr->{<>OTX_ItemVariables_i}:=rVar_GetVariableByType(Pointer array:K8:23)
$Object_ptr->{<>OTX_ItemTypes_i}:=rVar_GetVariableByType(LongInt array:K8:19)

$0:=$ObjectID_i