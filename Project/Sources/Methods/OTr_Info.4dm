//%attributes = {"invisible":true,"shared":true}
// Project Method: OTr_Info (label) --> Text

// Returns requested information to the host.

// Access: Shared

// Parameters: 
//   $request_t : Text : Info desired ("version" or "name")

// Returns: 
//   $reply_t : Text : Response

// Created by Wayne Stewart, 2026-04-08
// ----------------------------------------------------

#DECLARE($request_t : Text)->$reply_t : Text

OTr_zAddToCallStack(Current method name:C684)

Case of 
	: (Count parameters:C259=0)
		$reply_t:="Error: No parameter passed."
		
	: ($request_t="version")
		$reply_t:="1.0 Beta 1"
		
	: ($request_t="name")
		$reply_t:="Object Tools Replacement"
		
	Else 
		$reply_t:=" Label Not Recognised"
End case 

OTr_zRemoveFromCallStack(Current method name:C684)
