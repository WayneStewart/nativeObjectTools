//%attributes = {"invisible":true,"shared":false}

// Entire method commented out to allow for compiling when plugin is not present.

/*
// ----------------------------------------------------
// Project Method: ____Test_Phase_10a

// Broad, mostly-correct side-by-side sweep of legacy
// ObjectTools commands against their OTr equivalents.
//
// This method is intended to exercise a wide spread of
// the command families listed in the ObjectTools 5
// reference manual while avoiding deliberate misuse.
// Its primary value for Phase 10 is that it generates
// a realistic "normal" log profile.
//
// Output: TAB-delimited results table written to the
// Logs folder with a timestamped filename, then shown
// on disk.
//
// PLATFORM REQUIREMENT: ObjectTools 5.0 must be installed
// as a plugin. The method aborts with an ALERT if OT New
// returns 0.
//
// Access: Private
//
// Returns: Nothing (results written to logs folder)
//
// Created by Wayne Stewart / Codex, 2026-04-06
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------
var $ProcessID_i; $StackSize_i : Integer
var $DesiredProcessName_t : Text

$StackSize_i:=0
$DesiredProcessName_t:=Current method name:C684

If (Current process name:C1392=$DesiredProcessName_t)

	var $ready_b : Boolean
	var $otMain_i; $otrMain_i : Integer
	var $testOtH_i; $testOtrH_i : Integer
	var $h2_i : Integer
	var $reg_i : Integer
	var $total_i; $pass_i; $fail_i : Integer
	var $testName_t : Text
	var $otCmd_t; $otrCmd_t : Text
	var $otResult_t; $otrResult_t : Text
	var $gotten_t : Text
	var $gotLong_i : Integer
	var $gotReal_r : Real
	var $gotBool_i : Integer
	var $gotDate_d : Date
	var $gotTime_h : Time
	var $gotBlob_blob : Blob
	var $gotPic_pic : Picture
	var $ptrTarget_t : Text
	var $ptrOut_ptr : Pointer
	var $version_t : Text
	var $opts_i : Integer
	var $compiled_i : Integer
	var $itemType_i : Integer
	var $itemCount_i : Integer
	var $arraySize_i : Integer
	var $compare_i : Integer
	var $blob_blob : Blob
	var $roundBlob_blob : Blob
	var $testDate_d : Date
	var $testTime_h : Time
	var $wombat_pic : Picture
	var $summaryLine_t : Text
	var $tableText_t : Text
	var $folderPath_t : Text
	var $fileName_t : Text
	var $filePath_t : Text
	var $dateStr_t : Text
	var $timeStr_t : Text
	var $y_i; $mo_i; $d_i : Integer
	var $i_i : Integer
	var $TAB; $LF : Text
	var $allNames_ptr : Pointer
	var $varLong_i : Integer

	ARRAY TEXT:C222($rows_at; 0)
	ARRAY TEXT:C222($names_at; 0)
	ARRAY LONGINT:C221($types_ai; 0)
	ARRAY LONGINT:C221($itemSizes_ai; 0)
	ARRAY LONGINT:C221($dataSizes_ai; 0)
	ARRAY LONGINT:C221($longArr_ai; 0)
	ARRAY LONGINT:C221($longArrOut_ai; 0)

	$TAB:=Char:C90(Tab:K15:37)
	$LF:=Char:C90(Line feed:K15:40)
	$ready_b:=True:C214

	$reg_i:=OT Register("20C9-EMQv-BJBl-D20M")
	$testOtH_i:=OT New

	If ($testOtH_i=0)
		ALERT:C41("ObjectTools 5.0 is not available or not registered. "+Char:C90(Carriage return:K15:38)+"Ensure the plugin is installed and this method runs on a compatible platform. Test aborted.")
		$ready_b:=False:C215
	End if

	If ($ready_b)

		OT Clear($testOtH_i)
		OTr_ClearAll

		$total_i:=0
		$pass_i:=0
		$fail_i:=0

		$otMain_i:=OT New
		$otrMain_i:=OTr_New

		$testDate_d:=!2026-04-06!
		$testTime_h:=?10:30:45?
		$ptrTarget_t:="phase10a"
		$wombat_pic:=OTr_z_Wombat
		TEXT TO BLOB:C554("phase10a-blob"; $blob_blob)

		APPEND TO ARRAY:C911($rows_at; "Test Name"+$TAB+"OT Test"+$TAB+"OT Result"+$TAB+"OTr Test"+$TAB+"OTr Result"+$LF)

		// ====================================================
		// 1. Register / version / compiled / options
		// ====================================================
		$testName_t:="Register / version / compiled / options"
		$otCmd_t:="OT Register / OT GetVersion / OT CompiledApplication / OT GetOptions"
		$otrCmd_t:="OTr_Register / OTr_GetVersion / OTr_CompiledApplication / OTr_GetOptions"

		$version_t:=OT GetVersion
		$compiled_i:=OT CompiledApplication
		$opts_i:=OT GetOptions
		$otResult_t:="version="+$version_t+" compiled="+String:C10($compiled_i)+" options="+String:C10($opts_i)

		$version_t:=OTr_GetVersion
		$compiled_i:=OTr_CompiledApplication
		$opts_i:=OTr_GetOptions
		$otrResult_t:="version="+$version_t+" compiled="+String:C10($compiled_i)+" options="+String:C10($opts_i)

		$total_i:=$total_i+1
		$pass_i:=$pass_i+1
		APPEND TO ARRAY:C911($rows_at; $testName_t+$TAB+$otCmd_t+$TAB+$otResult_t+$TAB+$otrCmd_t+$TAB+$otrResult_t+$LF)

		// ====================================================
		// 2. Scalar put/get group
		// ====================================================
		OT PutString($otMain_i; "str"; "hello")
		OT PutLong($otMain_i; "num"; 42)
		OT PutReal($otMain_i; "real"; 3.5)
		OT PutBoolean($otMain_i; "bool"; 1)
		OT PutDate($otMain_i; "date"; $testDate_d)
		OT PutTime($otMain_i; "time"; $testTime_h)

		OTr_PutString($otrMain_i; "str"; "hello")
		OTr_PutLong($otrMain_i; "num"; 42)
		OTr_PutReal($otrMain_i; "real"; 3.5)
		OTr_PutBoolean($otrMain_i; "bool"; True:C214)
		OTr_PutDate($otrMain_i; "date"; $testDate_d)
		OTr_PutTime($otrMain_i; "time"; $testTime_h)

		$testName_t:="Scalar put/get"
		$otCmd_t:="OT Put/Get String Long Real Boolean Date Time"
		$otrCmd_t:="OTr Put/Get String Long Real Boolean Date Time"
		$otResult_t:=OT GetString($otMain_i; "str")+" / "+String:C10(OT GetLong($otMain_i; "num"))+" / "+String:C10(OT GetReal($otMain_i; "real"))+" / "+String:C10(OT GetBoolean($otMain_i; "bool"))
		$otrResult_t:=OTr_GetString($otrMain_i; "str")+" / "+String:C10(OTr_GetLong($otrMain_i; "num"))+" / "+String:C10(OTr_GetReal($otrMain_i; "real"))+" / "+String:C10(OTr_GetBoolean($otrMain_i; "bool"))
		$total_i:=$total_i+1
		$pass_i:=$pass_i+1
		APPEND TO ARRAY:C911($rows_at; $testName_t+$TAB+$otCmd_t+$TAB+$otResult_t+$TAB+$otrCmd_t+$TAB+$otrResult_t+$LF)

		// ====================================================
		// 3. Pointer / BLOB / Picture
		// ====================================================
		OT PutPointer($otMain_i; "ptr"; ->$ptrTarget_t)
		OT PutBLOB($otMain_i; "blob"; $blob_blob)
		OT PutPicture($otMain_i; "pic"; $wombat_pic)

		OTr_PutPointer($otrMain_i; "ptr"; ->$ptrTarget_t)
		OTr_PutBLOB($otrMain_i; "blob"; $blob_blob)
		OTr_PutPicture($otrMain_i; "pic"; $wombat_pic)

		$ptrOut_ptr:=Null:C1517
		OT GetPointer($otMain_i; "ptr"; $ptrOut_ptr)
		$roundBlob_blob:=OT GetNewBLOB($otMain_i; "blob")
		$gotPic_pic:=OT GetPicture($otMain_i; "pic")
		$otResult_t:="ptrOK="+String:C10(OK)+" blobSize="+String:C10(BLOB size:C605($roundBlob_blob))+" pic="+Choose:C955($gotPic_pic#Null:C1517; "yes"; "no")

		$ptrOut_ptr:=Null:C1517
		OTr_GetPointer($otrMain_i; "ptr"; ->$ptrOut_ptr)
		$roundBlob_blob:=OTr_GetNewBLOB($otrMain_i; "blob")
		$gotPic_pic:=OTr_GetPicture($otrMain_i; "pic")
		$otrResult_t:="ptrOK="+String:C10(OK)+" blobSize="+String:C10(BLOB size:C605($roundBlob_blob))+" pic="+Choose:C955($gotPic_pic#Null:C1517; "yes"; "no")

		$testName_t:="Pointer / BLOB / Picture"
		$otCmd_t:="OT Put/GetPointer GetNewBLOB Put/GetPicture"
		$otrCmd_t:="OTr Put/GetPointer GetNewBLOB Put/GetPicture"
		$total_i:=$total_i+1
		$pass_i:=$pass_i+1
		APPEND TO ARRAY:C911($rows_at; $testName_t+$TAB+$otCmd_t+$TAB+$otResult_t+$TAB+$otrCmd_t+$TAB+$otrResult_t+$LF)

		// ====================================================
		// 4. Object copy and embedded object
		// ====================================================
		$testOtH_i:=OT New
		OT PutString($testOtH_i; "childName"; "kid")
		OT PutObject($otMain_i; "child"; $testOtH_i)
		$h2_i:=OT GetObject($otMain_i; "child")
		$otResult_t:="childHandle="+String:C10($h2_i)+" childName="+OT GetString($h2_i; "childName")

		$testOtrH_i:=OTr_New
		OTr_PutString($testOtrH_i; "childName"; "kid")
		OTr_PutObject($otrMain_i; "child"; $testOtrH_i)
		$h2_i:=OTr_GetObject($otrMain_i; "child")
		$otrResult_t:="childHandle="+String:C10($h2_i)+" childName="+OTr_GetString($h2_i; "childName")

		$testName_t:="Embedded object"
		$otCmd_t:="OT PutObject / OT GetObject"
		$otrCmd_t:="OTr PutObject / OTr GetObject"
		$total_i:=$total_i+1
		$pass_i:=$pass_i+1
		APPEND TO ARRAY:C911($rows_at; $testName_t+$TAB+$otCmd_t+$TAB+$otResult_t+$TAB+$otrCmd_t+$TAB+$otrResult_t+$LF)
		OT Clear($testOtH_i)
		OT Clear($h2_i)
		OTr_Clear($testOtrH_i)
		OTr_Clear($h2_i)

		// ====================================================
		// 5. Variable
		// ====================================================
		$varLong_i:=1234
		OT PutVariable($otMain_i; "varLong"; ->$varLong_i)
		$varLong_i:=0
		OT GetVariable($otMain_i; "varLong"; ->$varLong_i)
		$otResult_t:="varLong="+String:C10($varLong_i)+" OK="+String:C10(OK)

		$varLong_i:=1234
		OTr_PutVariable($otrMain_i; "varLong"; ->$varLong_i)
		$varLong_i:=0
		OTr_GetVariable($otrMain_i; "varLong"; ->$varLong_i)
		$otrResult_t:="varLong="+String:C10($varLong_i)+" OK="+String:C10(OK)

		$testName_t:="Variable round-trip"
		$otCmd_t:="OT PutVariable / OT GetVariable"
		$otrCmd_t:="OTr PutVariable / OTr GetVariable"
		$total_i:=$total_i+1
		$pass_i:=$pass_i+1
		APPEND TO ARRAY:C911($rows_at; $testName_t+$TAB+$otCmd_t+$TAB+$otResult_t+$TAB+$otrCmd_t+$TAB+$otrResult_t+$LF)

		// ====================================================
		// 6. Bulk array + element operations
		// ====================================================
		ARRAY LONGINT:C221($longArr_ai; 3)
		$longArr_ai{1}:=10
		$longArr_ai{2}:=20
		$longArr_ai{3}:=30
		OT PutArray($otMain_i; "arr"; ->$longArr_ai)
		OT PutArrayLong($otMain_i; "arr"; 2; 99)
		OT InsertElement($otMain_i; "arr"; 2)
		OT PutArrayLong($otMain_i; "arr"; 2; 77)
		OT DeleteElement($otMain_i; "arr"; 4)
		$arraySize_i:=OT SizeOfArray($otMain_i; "arr")
		$gotLong_i:=OT GetArrayLong($otMain_i; "arr"; 2)
		$otResult_t:="size="+String:C10($arraySize_i)+" elem2="+String:C10($gotLong_i)

		ARRAY LONGINT:C221($longArr_ai; 3)
		$longArr_ai{1}:=10
		$longArr_ai{2}:=20
		$longArr_ai{3}:=30
		OTr_PutArray($otrMain_i; "arr"; ->$longArr_ai)
		OTr_PutArrayLong($otrMain_i; "arr"; 2; 99)
		OTr_InsertElement($otrMain_i; "arr"; 2)
		OTr_PutArrayLong($otrMain_i; "arr"; 2; 77)
		OTr_DeleteElement($otrMain_i; "arr"; 4)
		$arraySize_i:=OTr_SizeOfArray($otrMain_i; "arr")
		$gotLong_i:=OTr_GetArrayLong($otrMain_i; "arr"; 2)
		$otrResult_t:="size="+String:C10($arraySize_i)+" elem2="+String:C10($gotLong_i)

		$testName_t:="Array bulk + element ops"
		$otCmd_t:="OT PutArray / PutArrayLong / InsertElement / DeleteElement / SizeOfArray / GetArrayLong"
		$otrCmd_t:="OTr equivalents"
		$total_i:=$total_i+1
		$pass_i:=$pass_i+1
		APPEND TO ARRAY:C911($rows_at; $testName_t+$TAB+$otCmd_t+$TAB+$otResult_t+$TAB+$otrCmd_t+$TAB+$otrResult_t+$LF)

		// ====================================================
		// 7. GetArray / ResizeArray / FindInArray
		// ====================================================
		ARRAY LONGINT:C221($longArrOut_ai; 0)
		OT ResizeArray($otMain_i; "arr"; 5)
		OT PutArrayLong($otMain_i; "arr"; 5; 555)
		OT GetArray($otMain_i; "arr"; ->$longArrOut_ai)
		$otResult_t:="size="+String:C10(Size of array:C274($longArrOut_ai))+" find555="+String:C10(OT FindInArray($otMain_i; "arr"; 555))

		ARRAY LONGINT:C221($longArrOut_ai; 0)
		OTr_ResizeArray($otrMain_i; "arr"; 5)
		OTr_PutArrayLong($otrMain_i; "arr"; 5; 555)
		OTr_GetArray($otrMain_i; "arr"; ->$longArrOut_ai)
		$otrResult_t:="size="+String:C10(Size of array:C274($longArrOut_ai))+" find555="+String:C10(OTr_FindInArray($otrMain_i; "arr"; 555))

		$testName_t:="Resize / GetArray / FindInArray"
		$otCmd_t:="OT ResizeArray / GetArray / FindInArray"
		$otrCmd_t:="OTr equivalents"
		$total_i:=$total_i+1
		$pass_i:=$pass_i+1
		APPEND TO ARRAY:C911($rows_at; $testName_t+$TAB+$otCmd_t+$TAB+$otResult_t+$TAB+$otrCmd_t+$TAB+$otrResult_t+$LF)

		// ====================================================
		// 8. Object and item info
		// ====================================================
		$itemCount_i:=OT ItemCount($otMain_i)
		$itemType_i:=OT ItemType($otMain_i; "str")
		$otResult_t:="isObject="+String:C10(OT IsObject($otMain_i))+" itemCount="+String:C10($itemCount_i)+" itemType(str)="+String:C10($itemType_i)+" size="+String:C10(OT ObjectSize($otMain_i))

		$itemCount_i:=OTr_ItemCount($otrMain_i)
		$itemType_i:=OTr_ItemType($otrMain_i; "str")
		$otrResult_t:="isObject="+String:C10(OTr_IsObject($otrMain_i))+" itemCount="+String:C10($itemCount_i)+" itemType(str)="+String:C10($itemType_i)+" size="+String:C10(OTr_ObjectSize($otrMain_i))

		$testName_t:="Object / item info"
		$otCmd_t:="OT IsObject / ItemCount / ItemType / ObjectSize"
		$otrCmd_t:="OTr equivalents"
		$total_i:=$total_i+1
		$pass_i:=$pass_i+1
		APPEND TO ARRAY:C911($rows_at; $testName_t+$TAB+$otCmd_t+$TAB+$otResult_t+$TAB+$otrCmd_t+$TAB+$otrResult_t+$LF)

		// ====================================================
		// 9. Property queries
		// ====================================================
		ARRAY TEXT:C222($names_at; 0)
		ARRAY LONGINT:C221($types_ai; 0)
		ARRAY LONGINT:C221($itemSizes_ai; 0)
		ARRAY LONGINT:C221($dataSizes_ai; 0)
		OT GetAllProperties($otMain_i; ->$names_at; ->$types_ai; ->$itemSizes_ai; ->$dataSizes_ai)
		$otResult_t:="allProps="+String:C10(Size of array:C274($names_at))+" exists(str)="+String:C10(OT ItemExists($otMain_i; "str"))+" embedded(child)="+String:C10(OT IsEmbedded($otMain_i; "child"))

		ARRAY TEXT:C222($names_at; 0)
		ARRAY LONGINT:C221($types_ai; 0)
		ARRAY LONGINT:C221($itemSizes_ai; 0)
		ARRAY LONGINT:C221($dataSizes_ai; 0)
		OTr_GetAllProperties($otrMain_i; ->$names_at; ->$types_ai; ->$itemSizes_ai; ->$dataSizes_ai)
		$otrResult_t:="allProps="+String:C10(Size of array:C274($names_at))+" exists(str)="+String:C10(OTr_ItemExists($otrMain_i; "str"))+" embedded(child)="+String:C10(OTr_IsEmbedded($otrMain_i; "child"))

		$testName_t:="Property queries"
		$otCmd_t:="OT GetAllProperties / ItemExists / IsEmbedded"
		$otrCmd_t:="OTr equivalents"
		$total_i:=$total_i+1
		$pass_i:=$pass_i+1
		APPEND TO ARRAY:C911($rows_at; $testName_t+$TAB+$otCmd_t+$TAB+$otResult_t+$TAB+$otrCmd_t+$TAB+$otrResult_t+$LF)

		// ====================================================
		// 10. Item utility routines
		// ====================================================
		OT CopyItem($otMain_i; "str"; $otMain_i; "strCopy")
		$compare_i:=OT CompareItems($otMain_i; "str"; $otMain_i; "strCopy")
		OT RenameItem($otMain_i; "strCopy"; "strRenamed")
		OT DeleteItem($otMain_i; "strRenamed")
		$otResult_t:="compare="+String:C10($compare_i)+" existsAfterDelete="+String:C10(OT ItemExists($otMain_i; "strRenamed"))

		OTr_CopyItem($otrMain_i; "str"; $otrMain_i; "strCopy")
		$compare_i:=OTr_CompareItems($otrMain_i; "str"; $otrMain_i; "strCopy")
		OTr_RenameItem($otrMain_i; "strCopy"; "strRenamed")
		OTr_DeleteItem($otrMain_i; "strRenamed")
		$otrResult_t:="compare="+String:C10($compare_i)+" existsAfterDelete="+String:C10(OTr_ItemExists($otrMain_i; "strRenamed"))

		$testName_t:="Item utility routines"
		$otCmd_t:="OT CopyItem / CompareItems / RenameItem / DeleteItem"
		$otrCmd_t:="OTr equivalents"
		$total_i:=$total_i+1
		$pass_i:=$pass_i+1
		APPEND TO ARRAY:C911($rows_at; $testName_t+$TAB+$otCmd_t+$TAB+$otResult_t+$TAB+$otrCmd_t+$TAB+$otrResult_t+$LF)

		// ====================================================
		// 11. Serialisation
		// ====================================================
		OT ObjectToBLOB($otMain_i; $gotBlob_blob)
		$testOtH_i:=OT BLOBToObject($gotBlob_blob)
		$otResult_t:="blobSize="+String:C10(BLOB size:C605($gotBlob_blob))+" newHandle="+String:C10($testOtH_i)+" getStr="+OT GetString($testOtH_i; "str")

		$gotBlob_blob:=OTr_ObjectToNewBLOB($otrMain_i)
		$testOtrH_i:=OTr_BLOBToObject($gotBlob_blob)
		$otrResult_t:="blobSize="+String:C10(BLOB size:C605($gotBlob_blob))+" newHandle="+String:C10($testOtrH_i)+" getStr="+OTr_GetString($testOtrH_i; "str")

		$testName_t:="Object serialisation"
		$otCmd_t:="OT ObjectToBLOB / BLOBToObject"
		$otrCmd_t:="OTr ObjectToNewBLOB / BLOBToObject"
		$total_i:=$total_i+1
		$pass_i:=$pass_i+1
		APPEND TO ARRAY:C911($rows_at; $testName_t+$TAB+$otCmd_t+$TAB+$otResult_t+$TAB+$otrCmd_t+$TAB+$otrResult_t+$LF)

		// ====================================================
		// 12. Handle list
		// ====================================================
		ARRAY LONGINT:C221($longArrOut_ai; 0)
		OT GetHandleList(->$longArrOut_ai)
		$otResult_t:="handles="+String:C10(Size of array:C274($longArrOut_ai))

		ARRAY LONGINT:C221($longArrOut_ai; 0)
		OTr_GetHandleList(->$longArrOut_ai)
		$otrResult_t:="handles="+String:C10(Size of array:C274($longArrOut_ai))

		$testName_t:="Handle list"
		$otCmd_t:="OT GetHandleList"
		$otrCmd_t:="OTr_GetHandleList"
		$total_i:=$total_i+1
		$pass_i:=$pass_i+1
		APPEND TO ARRAY:C911($rows_at; $testName_t+$TAB+$otCmd_t+$TAB+$otResult_t+$TAB+$otrCmd_t+$TAB+$otrResult_t+$LF)

		// ====================================================
		// TEARDOWN
		// ====================================================
		If ($testOtH_i#0)
			OT Clear($testOtH_i)
		End if
		If ($testOtrH_i#0)
			OTr_Clear($testOtrH_i)
		End if
		OT Clear($otMain_i)
		OTr_ClearAll

		$summaryLine_t:="Total scenarios: "+String:C10($total_i)+"  Rows written: "+String:C10($pass_i)+"  Fail count reserved: "+String:C10($fail_i)
		APPEND TO ARRAY:C911($rows_at; "")
		APPEND TO ARRAY:C911($rows_at; $summaryLine_t)

		$tableText_t:=""
		For ($i_i; 1; Size of array:C274($rows_at))
			$tableText_t:=$tableText_t+$rows_at{$i_i}
		End for

		$y_i:=Year of:C25(Current date:C33)
		$mo_i:=Month of:C24(Current date:C33)
		$d_i:=Day of:C23(Current date:C33)
		$dateStr_t:=String:C10($y_i; "0000")+"-"+String:C10($mo_i; "00")+"-"+String:C10($d_i; "00")
		$timeStr_t:=String:C10(Current time:C178; HH MM SS:K7:1)
		$timeStr_t:=Replace string:C233($timeStr_t; ":"; "-")
		$fileName_t:="____Test_Phase_10a-"+$dateStr_t+"-"+$timeStr_t+".txt"

		$folderPath_t:=Get 4D folder:C485(Logs folder:K5:19)
		$filePath_t:=$folderPath_t+$fileName_t

		TEXT TO DOCUMENT:C1237($filePath_t; $tableText_t; "UTF-8")
		SHOW ON DISK:C922($filePath_t)
		ALERT:C41($summaryLine_t+Char:C90(Carriage return:K15:38)+"Results written to: "+$fileName_t)
		SET TEXT TO PASTEBOARD:C523($tableText_t)

	End if

Else
	$ProcessID_i:=New process:C317(Current method name:C684; $StackSize_i; $DesiredProcessName_t; *)
	RESUME PROCESS:C320($ProcessID_i)
	SHOW PROCESS:C325($ProcessID_i)
	BRING TO FRONT:C326($ProcessID_i)
End if
*/
