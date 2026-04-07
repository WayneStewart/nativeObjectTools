//%attributes = {"invisible":true,"preemptive":"capable"}
// ----------------------------------------------------
// Project Method: Log_Init

// Initializes both the process and interprocess variables used by
// the logging routines.

// Access: Private

// Parameters: None

// Returns: Nothing

// Created by Dave Batton on May 25, 2004
// Mod by Wayne Stewart, 2015-07-27T00:00:00 - Simplified and made more generic
// ----------------------------------------------------

C_TEXT:C284($Log_FileName_t)

C_OBJECT:C1216(lg)

// Run once per launch
If (Storage:C1525.log.initialised=Null:C1517)
	
	If (Storage:C1525.log=Null:C1517)
		Use (Storage:C1525)
			Storage:C1525.log:=New shared object:C1526("initialised"; True:C214)
			
			Storage:C1525.logs:=New shared object:C1526
			
			Storage:C1525.k:=New shared object:C1526(\
				"tab"; Char:C90(Tab:K15:37); \
				"return"; Char:C90(Line feed:K15:40); \
				"logsFolder"; Get 4D folder:C485(Logs folder:K5:19; *); \
				"defaultLog"; Path to object:C1547(Structure file:C489(*)).name+" log.txt")
		End use 
		
	End if 
	
End if 

// Run every process
If (lg.initialised=Null:C1517)
	
	Compiler_Log
	
	lg:=New object:C1471("initialised"; True:C214)
	
	lg.enabled:=False:C215
	lg.file:=Storage:C1525.k.defaultLog
	lg.folder:=Storage:C1525.k.logsFolder
	
End if 

