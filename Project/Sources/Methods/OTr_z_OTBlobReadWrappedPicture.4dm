//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_z_OTBlobReadWrappedPicture (inBlob; inOffset; outEndOffset; outPicture) --> Boolean

// Finds a PNG or JPEG stream inside a legacy ObjectTools picture
// payload and converts it into a native 4D picture.

#DECLARE($inBlob_blob : Blob; $inOffset_i : Integer; $outEndOffset_ptr : Pointer; $outPicture_ptr : Pointer)->$result_b : Boolean

var $scan_i; $mediaStart_i; $mediaEnd_i; $mediaSize_i; $blobSize_i : Integer
var $chunkStart_i; $chunkOffset_i; $chunkLen_i; $nextChunk_i : Integer
var $format_t : Text
var $mediaBlob_blob : Blob

$result_b:=False
$mediaStart_i:=-1
$mediaEnd_i:=-1
$format_t:=""
$blobSize_i:=BLOB size($inBlob_blob)

$scan_i:=$inOffset_i
While (($scan_i+7)<$blobSize_i) & ($mediaStart_i<0)
	If (($inBlob_blob{$scan_i}=137) & ($inBlob_blob{$scan_i+1}=80) & ($inBlob_blob{$scan_i+2}=78) & ($inBlob_blob{$scan_i+3}=71) & ($inBlob_blob{$scan_i+4}=13) & ($inBlob_blob{$scan_i+5}=10) & ($inBlob_blob{$scan_i+6}=26) & ($inBlob_blob{$scan_i+7}=10))
		$mediaStart_i:=$scan_i
		$format_t:=".png"
	Else
		If (($inBlob_blob{$scan_i}=255) & ($inBlob_blob{$scan_i+1}=216) & ($inBlob_blob{$scan_i+2}=255))
			$mediaStart_i:=$scan_i
			$format_t:=".jpg"
		Else
			$scan_i:=$scan_i+1
		End if
	End if
End while

Case of
	: ($format_t=".png")
		$chunkStart_i:=$mediaStart_i+8
		While (($chunkStart_i+11)<$blobSize_i) & ($mediaEnd_i<0)
			$chunkOffset_i:=$chunkStart_i
			$chunkLen_i:=OTr_z_OTBlobReadUInt32BE($inBlob_blob; ->$chunkOffset_i)
			$nextChunk_i:=$chunkStart_i+12+$chunkLen_i
			If ($nextChunk_i>$blobSize_i)
				$chunkStart_i:=$blobSize_i
			Else
				If (($inBlob_blob{$chunkOffset_i}=73) & ($inBlob_blob{$chunkOffset_i+1}=69) & ($inBlob_blob{$chunkOffset_i+2}=78) & ($inBlob_blob{$chunkOffset_i+3}=68) & ($chunkLen_i=0))
					$mediaEnd_i:=$nextChunk_i
				Else
					$chunkStart_i:=$nextChunk_i
				End if
			End if
		End while
		
	: ($format_t=".jpg")
		$scan_i:=$mediaStart_i+2
		While (($scan_i+1)<$blobSize_i) & ($mediaEnd_i<0)
			If (($inBlob_blob{$scan_i}=255) & ($inBlob_blob{$scan_i+1}=217))
				$mediaEnd_i:=$scan_i+2
			Else
				$scan_i:=$scan_i+1
			End if
		End while
End case

If (($mediaStart_i>=0) & ($mediaEnd_i>$mediaStart_i))
	$mediaSize_i:=$mediaEnd_i-$mediaStart_i
	SET BLOB SIZE($mediaBlob_blob; $mediaSize_i)
	COPY BLOB($inBlob_blob; $mediaBlob_blob; $mediaStart_i; 0; $mediaSize_i)
	BLOB TO PICTURE:C682($mediaBlob_blob; $outPicture_ptr->; $format_t)
	If (Picture size:C356($outPicture_ptr->)>0)
		$outEndOffset_ptr->:=$mediaEnd_i
		$result_b:=True
	End if
End if
