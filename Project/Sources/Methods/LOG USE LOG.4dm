//%attributes = {"invisible":true,"shared":true}
  // ----------------------------------------------------
  // Project Method: LOG USE LOG {(Log Label)}

  // Pass the log label to use,
  // if you call this without a parameter, then the default log will be used

  // Access: Shared

  // Parameters: 
  //   $1 : Text : The Log to use or nothing to return to default


  // Created by Wayne Stewart (2018-08-04T14:00:00Z)
  //     wayne@4dsupport.guru
  // ----------------------------------------------------

If (False:C215)
	C_TEXT:C284(LOG USE LOG ;$1)
End if 

C_TEXT:C284($1)
C_OBJECT:C1216($Temp_o)


If (Count parameters:C259=1)
	LOG DECLARE LOG ($1)  // This will do no harm if the log has already been declared
	
	$Temp_o:=Storage:C1525.logs[$1]
	lg.file:=$Temp_o.fileName
	lg.folder:=$Temp_o.folderPath
	
	
	
Else 
	lg.file:=Storage:C1525.k.defaultLog
	lg.folder:=Storage:C1525.k.logsFolder
	
End if 