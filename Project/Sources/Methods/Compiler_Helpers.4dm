//%attributes = {"invisible":true}
// Access: Private
///*
//Constants methods by Cannon Smith
//https:  //www.synergyfarmsolutions.com
//*/

C_TEXT:C284(vtCC_Filename)
C_TEXT:C284(vtCC_XMLTopLevelRef)
C_TEXT:C284(vtCC_XMLFileRef)
C_TEXT:C284(vtCC_XMLBodyRef)
C_TEXT:C284(vtCC_XMLGroupsRef)
C_TEXT:C284(vtCC_XMLCurrentGroupRef)
C_LONGINT:C283(vlCC_CurrentGroupNumber)
C_LONGINT:C283(vlCC_CurrentConstantNumber)

ARRAY TEXT:C222(otPropNames_at; 0)
ARRAY LONGINT:C221(otLongArr_ai; 0)


If (False:C215)
	C_TEXT:C284(Constants_NewFile; $1)
	
	C_TEXT:C284(Constants_NewGroup; $1)
	
	C_TEXT:C284(Constants_AddLong; $1)
	C_LONGINT:C283(Constants_AddLong; $2)
	
	C_TEXT:C284(Constants_AddReal; $1)
	C_REAL:C285(Constants_AddReal; $2)
	
	C_TEXT:C284(Constants_AddString; $1)
	C_TEXT:C284(Constants_AddString; $2)
	
	
	C_TEXT:C284(Fnd_FCS_ParseParameterLine; $1)
	C_OBJECT:C1216(Fnd_FCS_ParseParameterLine; $0)
	
	C_TEXT:C284(Fnd_FCS_WriteDocumentation; $1)
	C_BOOLEAN:C305(Fnd_FCS_WriteDocumentation; ${2})
	
	C_TEXT:C284(Fnd_FCS_BuildComponent; $1)
	
	
	
End if 
