//%attributes = {"invisible":true,"shared":true}
  // ----------------------------------------------------
  // Project Method: Log_AddEntry(text1{;text2..textN})

  // Call this method to add a new entry to the "current" log file.
  // Safe to call even if we're not currently logging activity.

  // Access: Shared

  // Parameters:
  // $1 : Text : Any text
  // $2..N : Text : Any text(optional)

  // Returns: None

  // Created by Dave Batton on May 25, 2004
  // ----------------------------------------------------

C_TEXT:C284(${1};$logEntry_t;$logItem_t;$ErrorHandler_t)
C_LONGINT:C283($parameter_i)


Log_Init 


If (lg.enabled)
	
	  //$PathToLog_t:=lg.folder+lg.file
	
	$logEntry_t:=$1
	$logEntry_t:=Replace string:C233($logEntry_t;Storage:C1525.k.tab;"\t")
	$logEntry_t:=Replace string:C233($logEntry_t;Storage:C1525.k.return;"\r")
	For ($parameter_i;2;Count parameters:C259)
		$logItem_t:=${$parameter_i}
		$logItem_t:=Replace string:C233($logItem_t;Storage:C1525.k.tab;"\t")
		$logItem_t:=Replace string:C233($logItem_t;Storage:C1525.k.return;"\r")
		$logEntry_t:=$logEntry_t+Storage:C1525.k.tab+$logItem_t
	End for 
	
	  // Add the current date and time to the log entry.
	$logEntry_t:=Timestamp:C1445+Storage:C1525.k.tab+$logEntry_t+Storage:C1525.k.return
	
	
	
	CALL WORKER:C1389(Log Writer;"LOG THIS";$logEntry_t;lg.folder;lg.file)
	
	
	
End if 