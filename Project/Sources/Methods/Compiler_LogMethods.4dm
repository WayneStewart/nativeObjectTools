//%attributes = {"invisible":true}
  // ----------------------------------------------------
  // Project Method: Compiler_LogMethods

  // Just the methods

  // Access: Private

  // Created by Wayne Stewart (2018-09-03T14:00:00Z)
  //     wayne@4dsupport.guru
  // ----------------------------------------------------


  // Parameters
If (False:C215)  // So we never run this as code.
	C_TEXT:C284(LOG ADD ENTRY ;${1})
	C_TEXT:C284(LOG CLOSE LOG ;$1)
	C_TEXT:C284(LOG CLOSE LOG2 ;$1)
	C_TEXT:C284(LOG DECLARE LOG ;$1;$2;$3)
	C_BOOLEAN:C305(LOG ENABLE ;$0;$1)
	C_TEXT:C284(Log File Name ;$0;$1)
	C_TEXT:C284(Log Folder Path ;$1;$0)
	C_TEXT:C284(Log Form Event ;$0)
	C_LONGINT:C283(LOG STOP LOG WRITER ;$1)
	C_TEXT:C284(LOG THIS ;$1;$2;$3)
	C_TEXT:C284(LOG USE LOG ;$1)
	C_TEXT:C284(STRESS TEST ;$1)
	
	
End if 