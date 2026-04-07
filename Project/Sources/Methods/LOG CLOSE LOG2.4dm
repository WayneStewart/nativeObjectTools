//%attributes = {"invisible":true}
  // ----------------------------------------------------
  // Project Method: LOG CLOSE LOG2 {(Log Label)}

  // Pass the log label tosave and close that log
  // If you call this without any parameters all the logs will be closed and saved

  // Access: Private

  // Parameters: 
  //   $1 : Text : The log label (optional)

  // Created by Wayne Stewart (2018-08-05T14:00:00Z)
  //     wayne@4dsupport.guru
  // ----------------------------------------------------

Log_Init 


C_OBJECT:C1216($Temp_o)
C_TEXT:C284($1;$TheLogLabel_t;$PathToLogFile_t)
C_LONGINT:C283($log_i)
C_TIME:C306($DocRef_h)

If (Count parameters:C259=1)
	$TheLogLabel_t:=$1
	If (Length:C16($TheLogLabel_t)>0)
		
		If (Storage:C1525.logs[$TheLogLabel_t]#Null:C1517)
			$Temp_o:=Storage:C1525.logs[$TheLogLabel_t]
			
			$PathToLogFile_t:=$Temp_o.folderPath+$Temp_o.fileName
			
			$log_i:=Find in array:C230(Log_Paths_at;$PathToLogFile_t)
			If ($log_i>0)
				
				$DocRef_h:=Log_DocRefs_ah{$log_i}
				DELETE FROM ARRAY:C228(Log_DocRefs_ah;$log_i)
				DELETE FROM ARRAY:C228(Log_Paths_at;$log_i)
				
				CLOSE DOCUMENT:C267($DocRef_h)
				
			End if 
			
		End if 
	End if 
	
Else 
	For ($log_i;1;Size of array:C274(Log_DocRefs_ah))
		CLOSE DOCUMENT:C267(Log_DocRefs_ah{$log_i})
	End for 
	
	ARRAY TEXT:C222(Log_Paths_at;0)
	ARRAY TIME:C1223(Log_DocRefs_ah;0)
	
	
End if 