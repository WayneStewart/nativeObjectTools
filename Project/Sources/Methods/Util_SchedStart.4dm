//%attributes = {"invisible":true,"preemptive":"capable"}
// Util_SchedStart
// Created by capng (2026-07-12T14:00:00Z)
//  Method is an autostart type
//     waynestewart@mac.com
// ----------------------------------------------------

var $ProcessID_i; $compiler_i; $StackSize_i : Integer
var $syntaxCheckRequest_t; $DesiredProcessName_t; $compilerMethod_t; $syntaxCheckResults_t : Text



// ----------------------------------------------------

$StackSize_i:=0
$DesiredProcessName_t:="$"+Current method name


If (Current process name=$DesiredProcessName_t)
	$ProcessID_i:=Current process
	
	$syntaxCheckRequest_t:=Get 4D folder(Current resources folder)+"compilerCheck.json"
	$syntaxCheckResults_t:=Get 4D folder(Current resources folder)+"compilerResults.json"
	$compilerMethod_t:="_____________v4_CompilerCheck"
	
	If (Storage.sched=Null)
		Use (Storage)
			Storage.sched:=New shared object("quitNow"; False)
		End use 
	End if 
	
	Repeat 
		
		If (Test path name($syntaxCheckRequest_t)=Is a document)  // A syntax check request
			
			If (Test path name($syntaxCheckResults_t)=Is a document)  // Are the prvious still there?
				DELETE DOCUMENT($syntaxCheckResults_t)  // Delete them
			End if 
			
			DELETE DOCUMENT($syntaxCheckRequest_t)  // Delete the syntax check request before starting
			
			$compiler_i:=New process($compilerMethod_t; $StackSize_i; $compilerMethod_t; True; *)
			
		End if 
		
		DELAY PROCESS($ProcessID_i; 300)  // Delay for 5 seconds
		
		
	Until (Process aborted) | (Storage.sched.quitNow)
	
	Use (Storage)
		OB REMOVE(Storage; "sched")
	End use 
	
Else 
	// This version allows for any number of processes
	// $ProcessID_i:=New Process(Current method name;$StackSize_i;$DesiredProcessName_t)
	
	// On the other hand, this version allows for one unique process
	If (Is compiled mode())
		// Do nothing
	Else 
		$ProcessID_i:=New process(Current method name; $StackSize_i; $DesiredProcessName_t; *)
	End if 
	
End if 

