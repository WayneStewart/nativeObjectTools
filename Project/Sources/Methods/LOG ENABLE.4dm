//%attributes = {"invisible":true,"shared":true}
  // ----------------------------------------------------
  // Project Method: Log_Enable({enable})-->Boolean

  // Allows the developer to turn the logger on or off.  Also returns True
  // if logging is currently enabled.

  // Access: Shared

  // Parameters:
  // $1 : Boolean : Turn on logging (optional)

  // Returns:
  // $0 : Boolean : True if logging

  // Created by Dave Batton on Dec 27, 2004
  // ----------------------------------------------------

C_BOOLEAN:C305($0;$1)

Log_Init 

If (Count parameters:C259>=1)
	lg.enabled:=$1
End if 

$0:=lg.enabled