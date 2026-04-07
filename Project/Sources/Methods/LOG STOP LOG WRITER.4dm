//%attributes = {"invisible":true,"shared":true}
  // ----------------------------------------------------
  // Project Method: LOG STOP LOG WRITER

  // Call this method to stop the Log Writer worker
  // The worker will restart if needed automatically

  // Access: Shared

  // Created by Wayne Stewart (2018-08-05T14:00:00Z)
  //     wayne@4dsupport.guru
  // ----------------------------------------------------
C_LONGINT:C283($1)

If (Count parameters:C259=1)
	CALL WORKER:C1389(Log Writer;"TimetoDie")
	
Else 
	CALL WORKER:C1389(Log Writer;"LOG STOP LOG WRITER";0)
End if 



