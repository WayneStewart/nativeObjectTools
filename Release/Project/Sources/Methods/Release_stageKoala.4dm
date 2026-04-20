//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: Release_stageKoala ($sentinelDir_t) --> Boolean
//
// Stages the Koala release tree by:
//   1. Reading exclusions.json from Resources/
//   2. Building an rsync --exclude argument list from alwaysStrip entries
//   3. rsyncing the Echidna checkout into staging-koala/, honouring excludes
//   4. Applying retainOnly rules (delete everything in a directory except kept files)
//   5. Writing a sentinel file
//
// Parameters:
//   $sentinelDir_t : Text : Absolute path to directory for sentinel files
//
// Returns:
//   $ok_b : Boolean : True if stage passed, False if failed
//
// Sentinel file: <sentinelDir>/stage-koala.txt
// ----------------------------------------------------

#DECLARE($sentinelDir_t : Text)->$ok_b : Boolean

var $sentinelPath_t; $exclusionsPath_t; $json_t : Text
var $rsyncCmd_t; $rsyncArgs_t; $excludeArg_t : Text
var $sourceDir_t; $stagingDir_t; $pattern_t : Text
var $stdout_t; $stderr_t : Text
var $retainRule_o : Object
var $exclusions_o : Object
var $alwaysStrip_c; $retainOnly_c; $keepFiles_c : Collection
var $i_i; $exitCode_i : Integer
var $keepFile_t; $dirPath_t; $filePath_t : Text
var $fileList_at : Text array
var $keepSet_c : Collection

$sentinelPath_t:=$sentinelDir_t+"stage-koala.txt"
$ok_b:=False

// ---------------------------------------------------------------------------
// 1. Read exclusions.json
// ---------------------------------------------------------------------------

$exclusionsPath_t:=Get 4D folder(Current resources folder)+"exclusions.json"

If (Test path name($exclusionsPath_t)#Is a document)
	TEXT TO DOCUMENT($sentinelPath_t; "stageKoala failed"+Char(13)+"exclusions.json not found at: "+$exclusionsPath_t; "UTF-8")
	$ok_b:=False
	return
End if

$json_t:=Document to text($exclusionsPath_t; "UTF-8")
$exclusions_o:=JSON Parse($json_t; Is object)

If ($exclusions_o=Null)
	TEXT TO DOCUMENT($sentinelPath_t; "stageKoala failed"+Char(13)+"exclusions.json could not be parsed"; "UTF-8")
	$ok_b:=False
	return
End if

$alwaysStrip_c:=$exclusions_o["alwaysStrip"]
$retainOnly_c:=$exclusions_o["retainOnly"]

// ---------------------------------------------------------------------------
// 2. Determine source and staging paths
//    The Echidna checkout is the parent of the Database folder
//    (Release/Project/ is two levels inside the repo root)
//    staging-koala/ sits beside the checkout in the runner workspace
// ---------------------------------------------------------------------------

$sourceDir_t:=Get 4D folder(Database folder)  // .../Release/Project/
// Walk up two levels: Project/ -> Release/ -> repo root
$sourceDir_t:=Replace string($sourceDir_t; "Release"+Folder separator+"Project"+Folder separator; "")

// staging-koala sits beside the repo checkout
$stagingDir_t:=Replace string($sourceDir_t; "nativeObjectTools"+Folder separator; "staging-koala"+Folder separator)

// ---------------------------------------------------------------------------
// 3. Build rsync command with --exclude flags
// ---------------------------------------------------------------------------

$rsyncArgs_t:="--archive --delete"

For each ($pattern_t; $alwaysStrip_c)
	// rsync expects patterns without leading path for glob matching
	$rsyncArgs_t:=$rsyncArgs_t+" --exclude="+Char(34)+$pattern_t+Char(34)
End for each

// Always exclude the release project itself from the staging tree
$rsyncArgs_t:=$rsyncArgs_t+" --exclude="+Char(34)+"Release/Project/"+Char(34)

// Exclude .git
$rsyncArgs_t:=$rsyncArgs_t+" --exclude="+Char(34)+".git/"+Char(34)

$rsyncCmd_t:="rsync "+$rsyncArgs_t+" "+Char(34)+$sourceDir_t+Char(34)+" "+Char(34)+$stagingDir_t+Char(34)

LAUNCH EXTERNAL PROCESS($rsyncCmd_t; $stdout_t; $stderr_t)
$exitCode_i:=Process aborted  // 4D sets OK=0 if the process failed

If (OK#1)
	TEXT TO DOCUMENT($sentinelPath_t; \
		"stageKoala failed"+Char(13)+"rsync failed"+Char(13)+$stderr_t; \
		"UTF-8")
	$ok_b:=False
	return
End if

// ---------------------------------------------------------------------------
// 4. Apply retainOnly rules
//    For each rule, delete everything in the directory except listed files
// ---------------------------------------------------------------------------

For each ($retainRule_o; $retainOnly_c)

	$dirPath_t:=$stagingDir_t+$retainRule_o["directory"]
	$keepFiles_c:=$retainRule_o["keep"]

	If (Test path name($dirPath_t)=Is a folder)

		// Build a set of filenames to keep for fast lookup
		$keepSet_c:=New collection

		For each ($keepFile_t; $keepFiles_c)
			$keepSet_c.push(Lowercase($keepFile_t))
		End for each

		// List all files in the directory (non-recursive — retainOnly is shallow)
		DOCUMENT LIST($dirPath_t; $fileList_at)

		For ($i_i; 1; Size of array($fileList_at))
			If ($keepSet_c.indexOf(Lowercase($fileList_at{$i_i}))<0)
				$filePath_t:=$dirPath_t+$fileList_at{$i_i}
				DELETE DOCUMENT($filePath_t)
			End if
		End for

	End if

End for each

// ---------------------------------------------------------------------------
// 5. Write success sentinel
// ---------------------------------------------------------------------------

TEXT TO DOCUMENT($sentinelPath_t; "stageKoala passed"; "UTF-8")
$ok_b:=True
