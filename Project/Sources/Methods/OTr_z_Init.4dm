//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTr_z_Init

// Initialises the OTr registry arrays and default module state.

// Access: Private

// Returns: Nothing

// Created by Wayne Stewart, 2026-03-31
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Wayne Stewart, 2026-04-05 - Added OTr_z_CheckHostMethods call for host propagation setup.
// Wayne Stewart, 2026-04-11 - Added includeShadowKeys flag (default True) to
//   Storage.OTr so OTr_IncludeShadowKey and the XML/JSON export methods can
//   read it from any process or preemptive worker.
// Wayne Stewart, 2026-04-11 - NOTE: An earlier revision added a global nativeDateInObject
//   probe to Storage.OTr. This has been removed. The "Dates inside objects" setting
//   (SET DATABASE PARAMETER) is per-process scope; a global flag stored in Storage
//   would reflect the main process's state at startup and would be wrong for any
//   process that has overridden the default. Date/Time storage now uses a per-call
//   probe via OTr_u_NativeDateInObject. See OTr_u_NativeDateInObject and Phase 2 spec.
// Wayne Stewart / Codex, 2026-04-15 - Ensure logging initialises on the
//   first API call, even when host startup events are not enabled.
// ----------------------------------------------------


If (Storage:C1525.OTr=Null:C1517)
	
	var $fullpath_o : Object
	var $name; $fullpath_t; $registrationCode_t : Text
	var $ApplicationVersion_i : Integer
	
	If (Application type:C494#4D Remote mode:K5:5)
		$fullpath_o:=Path to object:C1547(Structure file:C489(*))
		$name:=$fullpath_o.name
	End if 
	
	
	$fullpath_t:=Get 4D folder:C485(Current resources folder:K5:16)+"Secret Key.txt"
	If (Test path name:C476($fullpath_t)=Is a document:K24:1)
		$registrationCode_t:=Document to text:C1236($fullpath_t)
	Else 
		$registrationCode_t:="No code available"
	End if 
	
	$ApplicationVersion_i:=Num:C11(Application version:C493)
	
	Use (Storage:C1525)
		Storage:C1525.OTr:=New shared object:C1526("structureName"; $name; \
			"nativeBlobInObject"; ($ApplicationVersion_i>=1920); \
			"mechanism"; OTR IP Arrays; \
			"includeShadowKeys"; True:C214; \
			"loggingInitialising"; False:C215; \
			"registrationCode"; $registrationCode_t; \
			"level"; "off")
	End use 
	OTr_z_CheckHostMethods
	
End if 



C_BOOLEAN:C305(<>OTR_Initialised_b; OTR_Initialised_b)

Compiler_ObjectToolsReplacement


If (Not:C34(<>OTR_Initialised_b))
	
	
	<>OTR_Options_i:=4  // AutoCreateObjects on by default.
	<>OTR_ErrorHandler_t:=""
	
	<>OTR_Semaphore_t:="$OTr_Registry"
	
	<>OTR_Initialised_b:=True:C214
End if 

If (Not:C34(OTR_Initialised_b))
	ARRAY TEXT:C222(OTR_callStack_at; 0)
	
	OTR_LockCount_i:=0
	
	OTR_Initialised_b:=True:C214
	
End if 

If (Storage:C1525.OT_Logging=Null:C1517)
	If (Storage:C1525.OTr.loggingInitialising#True:C214)
		Use (Storage:C1525.OTr)
			Storage:C1525.OTr.loggingInitialising:=True:C214
		End use 
		
		OTr_z_LogInit  // Check logging is ready and write the startup message.
		
		Use (Storage:C1525.OTr)
			Storage:C1525.OTr.loggingInitialising:=False:C215
		End use 
	End if 
End if 
