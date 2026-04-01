//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: Dict_Info (label) --> Text

// Returns requested information. See the Fnd_Gen_ComponentInfo 
//   method for more information.

// Access: Shared

// Parameters: 
//   $1 : Text : Info desired ("version" or "name")

// Returns: 
//   $0 : Text : Response

// Created by Dave Batton on Sep 23, 2007
// Modified by Gary Boudreaux on Dec 22, 2008
//   Enhanced parameter description in header
// ----------------------------------------------------

C_TEXT:C284($0; $1; $request_t; $reply_t)

$request_t:=$1

Case of 
	: ($request_t="version")
		$reply_t:="19.0.1"
		
	: ($request_t="name")
		$reply_t:="Dictionary"
		
	Else 
		$reply_t:="Fnd_LabelNotRecognized"
End case 

$0:=$reply_t
