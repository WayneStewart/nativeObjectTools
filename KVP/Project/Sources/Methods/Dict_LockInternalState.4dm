//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: Dict_LockInternalState (lock?)

// Locks the internal state for the dictionary module.

// Access: Private

// Parameters: 
//   $1 : Boolean : True to Lock, False to Unlock

// Returns: Nothing

// Created by Rob Laveaux
// Modified by Dave Batton on Sep 21, 2007
//   Replaced the Assert_IsTrue command with a Fnd_Gen_BugAlert call.
// ----------------------------------------------------

C_BOOLEAN:C305($1; $lock_b)


$lock_b:=$1

Dict_Init

If ($lock_b)
	If (<>Dict_LockCount_ai=0)
		While (Semaphore:C143(<>Dict_SemaphoreName_t; 10))
			IDLE:C311
		End while 
	End if 
	
	<>Dict_LockCount_ai:=<>Dict_LockCount_ai+1
Else 
	
	<>Dict_LockCount_ai:=<>Dict_LockCount_ai-1
	If (<>Dict_LockCount_ai=0)
		CLEAR SEMAPHORE:C144(<>Dict_SemaphoreName_t)
	End if 
	
End if 

If (<>Dict_LockCount_ai<0)
	Dict_BugAlert(Current method name:C684; "Calls to this method are out of balance")
End if 