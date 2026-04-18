//%attributes = {"invisible":true,"preemptive":"capable"}
// ----------------------------------------------------
// Project Method: OTr_w_IsLocalRequest (clientIP) --> Boolean
//
// Accepts loopback forms commonly reported by 4D's web server.
// ----------------------------------------------------

#DECLARE($clientIP_t : Text)->$isLocal_b : Boolean

$isLocal_b:=False:C215

Case of
	: ($clientIP_t="127.0.0.1")
		$isLocal_b:=True:C214
	: ($clientIP_t="::1")
		$isLocal_b:=True:C214
	: ($clientIP_t="::ffff:127.0.0.1")
		$isLocal_b:=True:C214
	: ($clientIP_t="0:0:0:0:0:ffff:127.0.0.1")
		$isLocal_b:=True:C214
End case
