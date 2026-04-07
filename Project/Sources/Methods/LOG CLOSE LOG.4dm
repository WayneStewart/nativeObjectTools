//%attributes = {"invisible":true,"shared":true}
  // ----------------------------------------------------
  // Project Method: Log_CloseLog {(Log Label)}

  // Pass the log label to save and close that log
  // If you call this without any parameters all the logs will be closed and saved

  // Access: Shared

  // Parameters: 
  //   $1 : Text : The log label (optional)

  // Created by Wayne Stewart (2018-08-05T14:00:00Z)
  //     wayne@4dsupport.guru
  // ----------------------------------------------------

If (Count parameters:C259=1)
	CALL WORKER:C1389(Log Writer;"LOG CLOSE LOG2";$1)
Else 
	CALL WORKER:C1389(Log Writer;"LOG CLOSE LOG2")
End if 



