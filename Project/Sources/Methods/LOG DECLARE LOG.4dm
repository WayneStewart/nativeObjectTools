//%attributes = {"invisible":true,"shared":true}
  // ----------------------------------------------------
  // Project Method: Log_DeclareLog (Label {; File Name {; Folder Path }})

  // Allows the declaration of a different log

  // Access: Shared

  // Parameters: 
  //   $1 : Text : Log Label
  //   $2 : text : Log Name
  //   $3 : text : Log fileName - optional

  // Created by Wayne Stewart (2018-08-04T14:00:00Z)
  //     wayne@4dsupport.guru
  // ----------------------------------------------------

If (False:C215)
	C_TEXT:C284(LOG DECLARE LOG ;$1;$2;$3)
End if 


Log_Init 

C_TEXT:C284($Label_t;$1)
C_TEXT:C284($fileName_t;$2)
C_TEXT:C284($folderPath_t;$3)

C_OBJECT:C1216($Log_o)
C_LONGINT:C283($Parameters_i)

$Parameters_i:=Count parameters:C259

Case of 
	: ($Parameters_i=1)
		$Label_t:=$1
		$fileName_t:=$Label_t+".txt"
		$folderPath_t:=Storage:C1525.k.logsFolder
		
	: ($Parameters_i=2)
		$Label_t:=$1
		$fileName_t:=$2
		$folderPath_t:=Storage:C1525.k.logsFolder
		
	Else 
		$Label_t:=$1
		$fileName_t:=$2
		$folderPath_t:=$3
		
End case 

If (Storage:C1525.logs[$Label_t]=Null:C1517)  // This has not yet been declared
	$Log_o:=New shared object:C1526("folderPath";$folderPath_t;"fileName";$fileName_t)
	
	Use (Storage:C1525.logs)
		Storage:C1525.logs[$Label_t]:=$Log_o
		  //OB SET(Storage.logs;$Label_t;$Log_o)
	End use 
	
	
	
End if 