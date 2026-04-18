//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: ____Test_Phase_16_OTBlob_Probe

// Saves one generated ObjectTools BLOB, imports it through
// OTr_ImportLegacyBlob, and returns a compact pass/fail diagnostic.
//
// Access: Private
//
// Parameters:
//   $legacyBlob_blob : Blob : Generated legacy ObjectTools object BLOB
//   $caseName_t      : Text : Test case name used in report and raw file name
//
// Returns:
//   $result_t : Text : Pass/fail diagnostic for the generated BLOB
//
// Created by Wayne Stewart / Codex, 2026-04-14
// Wayne Stewart / Codex, 2026-04-14 - Added shared Phase 16 OT BLOB probe.
// Wayne Stewart / Codex, 2026-04-14 - Switched legacy import check to public OTr_ImportLegacyBlob API.
// ----------------------------------------------------

#DECLARE($legacyBlob_blob : Blob; $caseName_t : Text)->$result_t : Text

OTr_z_AddToCallStack(Current method name:C684)

var $safeName_t; $path_t; $marker_t : Text
var $otrH_i; $roundTripH_i : Integer
var $otrBlob_blob : Blob

$safeName_t:=$caseName_t
$safeName_t:=Replace string:C233($safeName_t; " "; "_")
$safeName_t:=Replace string:C233($safeName_t; "/"; "_")
$safeName_t:=Replace string:C233($safeName_t; ":"; "_")
$safeName_t:=Replace string:C233($safeName_t; "."; "_")

$path_t:=Get 4D folder:C485(Logs folder:K5:19; *)+"Phase16-OTBlob-"+$safeName_t+".blob"
BLOB TO DOCUMENT:C526($path_t; $legacyBlob_blob)

$marker_t:="legacy OT BLOB bytes="+String:C10(BLOB size:C605($legacyBlob_blob))
$otrH_i:=OTr_ImportLegacyBlob($legacyBlob_blob)

If (OK=1) & ($otrH_i>0)
	$otrBlob_blob:=OTr_ObjectToNewBLOB($otrH_i)
	If (OK=1) & (BLOB size:C605($otrBlob_blob)>0)
		$roundTripH_i:=OTr_BLOBToObject($otrBlob_blob)
		If (OK=1) & ($roundTripH_i>0)
			$result_t:="Pass: import and OTr round-trip succeeded; "+$marker_t
			OTr_Clear($roundTripH_i)
		Else
			$result_t:="Fail: imported but OTr round-trip reload failed; "+$marker_t
		End if
	Else
		$result_t:="Fail: imported but OTr_ObjectToNewBLOB failed; "+$marker_t
	End if
	OTr_Clear($otrH_i)
Else
	$result_t:="Fail: OTr_ImportLegacyBlob returned 0 or OK=0; "+$marker_t+"; raw="+$path_t
End if

OTr_z_RemoveFromCallStack(Current method name:C684)
