//%attributes = {"invisible":true,"shared":true}
  // ----------------------------------------------------
  // Project Method: Log_FileName {(Log Name)} --> Text

  // Allows you set the current log file name
  // Always returns the current log file name

  // Access: Shared

  // Parameters: 
  //   $1 : TEXT : The log file name (optional)

  // Returns: 
  //   $0 : TEXT : The log file name

  // Created by Wayne Stewart (2018-10-29T13:00:00Z)
  //     wayne@4dsupport.guru
  // ----------------------------------------------------


If (False:C215)
	C_TEXT:C284(Log File Name ;$1;$0)
End if 

C_TEXT:C284($1;$0)

Log_Init 

If (Count parameters:C259=1)
	lg.file:=$1
End if 

If (Length:C16(lg.file)=0)
	lg.file:=Storage:C1525.k.defaultLog  // Reset to default
End if 


$0:=lg.file

