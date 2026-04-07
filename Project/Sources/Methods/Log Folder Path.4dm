//%attributes = {"invisible":true,"shared":true}
  // ----------------------------------------------------
  // Project Method: Log_FolderPath {(The folder the log file is saved in)} --> Text

  // This method retrieves the folder the log file is saved in
  // You can also use this method to set the folder path

  // Access: Shared

  // Parameters: 
  //   $1 : Text : Folder Path (optional)

  // Returns: 
  //   $0 : Text : Folder Path

  // Created by Wayne Stewart (2018-10-29T13:00:00Z)
  //     wayne@4dsupport.guru
  // ----------------------------------------------------

If (False:C215)
	C_TEXT:C284(Log Folder Path ;$1;$0)
End if 

C_TEXT:C284($1;$0)

Log_Init 

If (Count parameters:C259=1)
	lg.folder:=$1
End if 

If (Length:C16(lg.folder)=0)
	lg.folder:=Storage:C1525.k.logsFolder  // Reset to default
End if 

$0:=lg.folder

