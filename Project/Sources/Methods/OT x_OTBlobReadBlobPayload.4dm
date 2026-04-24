//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OT x_OTBlobReadBlobPayload (inBlob; ioOffset; outBlob) --> Boolean

// Reads a legacy ObjectTools BLOB payload after marker 158.
// Proven layout:
// - one pad byte, UInt32BE length, payload
//
// Access: Private
//
// Parameters:
//   $inBlob_blob   : Blob    : Legacy ObjectTools object BLOB
//   $ioOffset_ptr  : Pointer : Current read offset after marker 158
//   $outBlob_ptr   : Pointer : Receives extracted BLOB payload
//
// Returns:
//   $result_b : Boolean : True when a complete BLOB payload was read
//
// Created by Wayne Stewart / Codex, 2026-04-14
// Wayne Stewart / Codex, 2026-04-14 - Added marker 158 BLOB payload reader.
// ----------------------------------------------------

#DECLARE($inBlob_blob : Blob; $ioOffset_ptr : Pointer; $outBlob_ptr : Pointer)->$result_b : Boolean

OTr_z_AddToCallStack(Current method name:C684)

var $count_i : Integer

$result_b:=False:C215

If ($ioOffset_ptr#Null)
	If (($ioOffset_ptr->+5)<=BLOB size($inBlob_blob))
		$ioOffset_ptr->:=$ioOffset_ptr->+1
		$count_i:=OT x_OTBlobReadUInt32BE($inBlob_blob; $ioOffset_ptr)
		
		If (($count_i>=0) & (($ioOffset_ptr->+$count_i)<=BLOB size($inBlob_blob)))
			SET BLOB SIZE($outBlob_ptr->; $count_i)
			If ($count_i>0)
				COPY BLOB($inBlob_blob; $outBlob_ptr->; $ioOffset_ptr->; 0; $count_i)
			End if
			$ioOffset_ptr->:=$ioOffset_ptr->+$count_i
			$result_b:=True:C214
		End if
	End if
End if

OTr_z_RemoveFromCallStack(Current method name:C684)
