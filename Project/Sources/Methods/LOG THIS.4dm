//%attributes = {"invisible":true,"preemptive":"capable"}
C_TEXT:C284($logEntry_t;$1)
C_TEXT:C284($PathToLogFolder_t;$2)
C_TEXT:C284($PathToLogFile_t;$3;$ErrorHandler_t)
C_TIME:C306($docRef_h)
C_LONGINT:C283($Position_i)

$logEntry_t:=$1
$PathToLogFolder_t:=$2
$PathToLogFile_t:=$3

Log_Init 


If (False:C215)
	C_TEXT:C284(LOG THIS ;$1;$2;$3)
End if 

$ErrorHandler_t:=Method called on error:C704

ON ERR CALL:C155("Log_SilentError")
$PathToLogFile_t:=$PathToLogFolder_t+$PathToLogFile_t

$Position_i:=Find in array:C230(Log_Paths_at;$PathToLogFile_t)
If ($Position_i>0)
	$docRef_h:=Log_DocRefs_ah{$Position_i}
	
Else 
	
	If (Test path name:C476($PathToLogFile_t)=Is a document:K24:1)
		$docRef_h:=Append document:C265($PathToLogFile_t)
	Else 
		If (Test path name:C476($PathToLogFolder_t)#Is a folder:K24:2)
			CREATE FOLDER:C475($PathToLogFolder_t;*)
		End if 
		$docRef_h:=Create document:C266($PathToLogFile_t;"TEXT")
		
	End if 
	
	APPEND TO ARRAY:C911(Log_Paths_at;$PathToLogFile_t)
	APPEND TO ARRAY:C911(Log_DocRefs_ah;$docRef_h)
	
End if 

If (OK=1)
	SEND PACKET:C103($docRef_h;$logEntry_t)
	  //CLOSE DOCUMENT($docRef_h)
End if 


ON ERR CALL:C155($ErrorHandler_t)