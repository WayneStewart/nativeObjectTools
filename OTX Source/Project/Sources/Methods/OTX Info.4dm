//%attributes = {"invisible":true,"shared":true}

// ----------------------------------------------------
// Project Method: OTX Info (label) --> Text

// Returns requested information.  See the Fnd_Gen_ComponentInfo 
//   method for more information.

// Method Type: Protected

// Parameters: 
//   $1 : Text : Info desired

// Returns: 
//   $0 : Text : Response

// Created by Wayne Stewart (Jun 17, 2007)
//     waynestewart@mac.com
// ----------------------------------------------------

C_TEXT:C284($0; $1; $request_t; $reply_t)

$request_t:=$1

OTX Init

Case of 
	: ($request_t="version")
		$reply_t:="1.0.0"
		
	: ($request_t="name")
		$reply_t:="OTX"
		
	Else 
		$reply_t:="Fnd_LabelNotRecognized"
End case 

$0:=$reply_t

