//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_w_GuyBlobExport (signal)

// Imports every legacy ObjectTools BLOB in Examples/Blobs/Guy and
// exports the imported OTr object beside it as pretty-printed JSON.
// Results are returned through the supplied signal for the Codex bridge.
//
// Access: Private
//
// Parameters:
//   $signal_o : Object : Receives resultJSON and is triggered on completion
//
// Returns: Nothing
//
// Created by Wayne Stewart / Codex, 2026-04-19
// ----------------------------------------------------

#DECLARE($signal_o : Object)

OTr_z_AddToCallStack(Current method name:C684)

var $result_o; $file_o : Object
var $folderPath_t; $file_t; $lowerName_t; $baseName_t : Text
var $blobPath_t; $jsonPath_t; $summary_t; $resultJSON_t : Text
var $file_i; $blobCount_i; $exportedCount_i; $failCount_i : Integer
var $handle_i; $jsonBytes_i : Integer
var $legacyBlob_blob; $jsonBlob_blob : Blob
ARRAY TEXT:C222($files_at; 0)

$result_o:=New object:C1471
$result_o.ok:=False:C215
$result_o.method:="OTr_w_GuyBlobExport"
$result_o.files:=New collection:C1472

$folderPath_t:=Get 4D folder:C485(Database folder:K5:14)+"Examples"+Folder separator:K24:12+"Blobs"+Folder separator:K24:12+"Guy"+Folder separator:K24:12
$result_o.folderPath:=$folderPath_t

$blobCount_i:=0
$exportedCount_i:=0
$failCount_i:=0

If (Test path name:C476($folderPath_t)#Is a folder:K24:2)
	$result_o.error:="Folder not found: "+$folderPath_t
Else 
	DOCUMENT LIST:C474($folderPath_t; $files_at)
	
	For ($file_i; 1; Size of array:C274($files_at))
		$file_t:=$files_at{$file_i}
		$lowerName_t:=Lowercase:C14($file_t)
		
		If ((Length:C16($lowerName_t)>=5) & (Substring:C12($lowerName_t; Length:C16($lowerName_t)-4)=".blob"))
			$blobCount_i:=$blobCount_i+1
			$baseName_t:=Substring:C12($file_t; 1; Length:C16($file_t)-5)
			$blobPath_t:=$folderPath_t+$file_t
			$jsonPath_t:=$folderPath_t+$baseName_t+".json"
			
			$file_o:=New object:C1471
			$file_o.blobFile:=$file_t
			$file_o.blobPath:=$blobPath_t
			$file_o.jsonFile:=$baseName_t+".json"
			$file_o.jsonPath:=$jsonPath_t
			$file_o.ok:=False:C215
			
			If (Test path name:C476($blobPath_t)#Is a document:K24:1)
				$file_o.error:="BLOB file not found."
				$failCount_i:=$failCount_i+1
			Else 
				DOCUMENT TO BLOB:C525($blobPath_t; $legacyBlob_blob)
				$file_o.blobBytes:=BLOB size:C605($legacyBlob_blob)
				
				OTr_z_SetOK(1)
				$handle_i:=OTr_ImportLegacyBlob($legacyBlob_blob)
				$file_o.importHandle:=$handle_i
				$file_o.importOK:=OK
				
				If ($handle_i<=0)
					$file_o.error:="Import returned no OTr handle."
					$failCount_i:=$failCount_i+1
				Else 
					OTr_SaveToFile($handle_i; $jsonPath_t; True:C214)
					
					If (Test path name:C476($jsonPath_t)=Is a document:K24:1)
						DOCUMENT TO BLOB:C525($jsonPath_t; $jsonBlob_blob)
						$jsonBytes_i:=BLOB size:C605($jsonBlob_blob)
						$file_o.jsonBytes:=$jsonBytes_i
						$file_o.ok:=($jsonBytes_i>0)
					Else 
						$file_o.error:="JSON file was not written."
					End if 
					
					If ($file_o.ok)
						$exportedCount_i:=$exportedCount_i+1
					Else 
						If (Not:C34(OB Is defined:C1231($file_o; "error")))
							$file_o.error:="JSON file was empty."
						End if 
						$failCount_i:=$failCount_i+1
					End if 
					
					OTr_Clear($handle_i)
				End if 
			End if 
			
			$result_o.files.push($file_o)
		End if 
	End for 
	
	$result_o.totalFiles:=$blobCount_i
	$result_o.exportedCount:=$exportedCount_i
	$result_o.failCount:=$failCount_i
	$result_o.ok:=(($blobCount_i>0) & ($failCount_i=0))
	
	$summary_t:="Guy BLOB export total: "+String:C10($blobCount_i)+"  Exported: "+String:C10($exportedCount_i)+"  Fail: "+String:C10($failCount_i)
	$result_o.summary:=$summary_t
End if 

$resultJSON_t:=JSON Stringify:C1217($result_o)

Use ($signal_o)
	$signal_o.resultJSON:=$resultJSON_t
End use

$signal_o.trigger()

OTr_z_RemoveFromCallStack(Current method name:C684)
