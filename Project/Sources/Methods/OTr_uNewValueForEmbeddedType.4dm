//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTr_uNewValueForEmbeddedType (type) -> Variant

// Creates a "blank" variable of the type requested

// Access: Private

// Parameters: 
//   $theType_i : Integer : The 4D Type

// Returns: 
//   $theValue_v : Variant : A blank value

// Created by Wayne Stewart (2026-04-02)
// ----------------------------------------------------

#DECLARE($theType_i : Integer)->$theValue_v : Variant

Case of 
	: ($theType_i=LongInt array:K8:19) | ($theType_i=Integer array:K8:18) | ($theType_i=Real array:K8:17)\
		 | ($theType_i=Is longint:K8:6) | ($theType_i=Is integer:K8:5) | ($theType_i=Is real:K8:4)
		$theValue_v:=0
		
	: ($theType_i=Boolean array:K8:21) | ($theType_i=Is boolean:K8:9)
		$theValue_v:=False:C215
		
	: ($theType_i=Date array:K8:20) | ($theType_i=Is date:K8:7)
		$theValue_v:="0000-00-00"
		
	: ($theType_i=Time array:K8:29) | ($theType_i=Is time:K8:8)
		$theValue_v:="00:00:00"
		
	Else 
		// Text, String, Pointer, Blob, Picture
		$theValue_v:=""
		
End case 
