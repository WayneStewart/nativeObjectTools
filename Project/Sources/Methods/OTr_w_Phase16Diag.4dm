//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTr_w_Phase16Diag (signal)
//
// Imports the Phase 16 deep fixture and reports each master-suite
// predicate separately.
// ----------------------------------------------------

#DECLARE($signal_o : Object)

var $result_o; $checks_o : Object
var $fixturePath_t; $docPath_t : Text
var $legacy_blob; $doc_blob; $gotDoc_blob; $round_blob : Blob
var $pic_pic; $gotPic_pic : Picture
var $h_i; $roundH_i : Integer
var $real_r : Real

ARRAY LONGINT:C221($numbers_ai; 0)

$result_o:=New object:C1471("ok"; False:C215; "method"; "OTr_w_Phase16Diag")
$checks_o:=New object:C1471
$result_o.checks:=$checks_o

$fixturePath_t:=Get 4D folder:C485(Current resources folder:K5:16)+"blobs"+Folder separator:K24:12+"Phase16-master-deep-mixed-docx.blob"
$docPath_t:=Get 4D folder:C485(Database folder:K5:14)+"Examples"+Folder separator:K24:12+"1 Corinthians 1.docx"

DOCUMENT TO BLOB:C525($fixturePath_t; $legacy_blob)
DOCUMENT TO BLOB:C525($docPath_t; $doc_blob)
$pic_pic:=OTr_z_Echidna

$result_o.fixtureBytes:=BLOB size:C605($legacy_blob)
$result_o.docBytes:=BLOB size:C605($doc_blob)

OTr_z_SetOK(1)
$h_i:=OTr_ImportLegacyBlob($legacy_blob)
$result_o.importHandle:=$h_i
$result_o.importOK:=OK

If ($h_i>0)
	OTr_GetArray($h_i; "AnObject.bObject.cObject.numbers"; ->$numbers_ai)
	$gotDoc_blob:=OTr_GetNewBLOB($h_i; "AnObject.bObject.cObject.document")
	$gotPic_pic:=OTr_GetPicture($h_i; "AnObject.bObject.cObject.photo")
	$real_r:=OTr_GetReal($h_i; "AnObject.bObject.cObject.amount")
	
	$result_o.gotDocBytes:=BLOB size:C605($gotDoc_blob)
	$result_o.arraySize:=Size of array:C274($numbers_ai)
	If (Size of array:C274($numbers_ai)>=3)
		$result_o.number1:=$numbers_ai{1}
		$result_o.number2:=$numbers_ai{2}
		$result_o.number3:=$numbers_ai{3}
	End if
	$result_o.level1Text:=OTr_GetText($h_i; "AnObject.level1Text")
	$result_o.level2Long:=OTr_GetLong($h_i; "AnObject.bObject.level2Long")
	$result_o.cItem:=OTr_GetText($h_i; "AnObject.bObject.cObject.Citem")
	$result_o.amount:=$real_r
	
	$checks_o.anObjectEmbedded:=(OTr_IsEmbedded($h_i; "AnObject")=1)
	$checks_o.cObjectEmbedded:=(OTr_IsEmbedded($h_i; "AnObject.bObject.cObject")=1)
	$checks_o.level1Text:=($result_o.level1Text="level1")
	$checks_o.level2Long:=($result_o.level2Long=-12345)
	$checks_o.cItem:=($result_o.cItem="deep text")
	$checks_o.amount:=(Abs:C99($real_r-123.456)<0.00001)
	$checks_o.arraySize:=(Size of array:C274($numbers_ai)=3)
	If (Size of array:C274($numbers_ai)>=3)
		$checks_o.arrayValues:=(($numbers_ai{1}=10) & ($numbers_ai{2}=-20) & ($numbers_ai{3}=3000))
	Else
		$checks_o.arrayValues:=False:C215
	End if
	$checks_o.docBytes:=(BLOB size:C605($gotDoc_blob)=BLOB size:C605($doc_blob))
	$checks_o.docEqual:=OTr_u_EqualBLOBs($doc_blob; $gotDoc_blob)
	$checks_o.pictureEqual:=OTr_u_EqualPictures($pic_pic; $gotPic_pic)
	
	$round_blob:=OTr_ObjectToNewBLOB($h_i)
	$roundH_i:=OTr_BLOBToObject($round_blob)
	$result_o.roundHandle:=$roundH_i
	$result_o.roundOK:=OK
	If ($roundH_i>0)
		$checks_o.roundCItem:=(OTr_GetText($roundH_i; "AnObject.bObject.cObject.Citem")="deep text")
		$checks_o.roundNumber2:=(OTr_GetArrayLong($roundH_i; "AnObject.bObject.cObject.numbers"; 2)=-20)
		$checks_o.roundDocEqual:=OTr_u_EqualBLOBs($doc_blob; OTr_GetNewBLOB($roundH_i; "AnObject.bObject.cObject.document"))
		OTr_Clear($roundH_i)
	End if
	
	OTr_Clear($h_i)
End if

$result_o.ok:=($checks_o.anObjectEmbedded & $checks_o.cObjectEmbedded & $checks_o.level1Text & $checks_o.level2Long & $checks_o.cItem & $checks_o.amount & $checks_o.arraySize & $checks_o.arrayValues & $checks_o.docBytes & $checks_o.docEqual & $checks_o.pictureEqual & $checks_o.roundCItem & $checks_o.roundNumber2 & $checks_o.roundDocEqual)

Use ($signal_o)
	$signal_o.resultJSON:=JSON Stringify:C1217($result_o)
End use

$signal_o.trigger()
