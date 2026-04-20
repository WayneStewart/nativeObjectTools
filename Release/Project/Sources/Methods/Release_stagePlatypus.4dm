//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: Release_stagePlatypus ($sentinelDir_t) --> Boolean
//
// Stages the Platypus release tree by:
//   1. Copying staging-koala/ to staging-platypus/ via rsync
//   2. Invoking the Renamer project in forward mode (OTr_ -> OT ) against
//      the staging-platypus/ copy via LAUNCH EXTERNAL PROCESS
//
// Parameters:
//   $sentinelDir_t : Text : Absolute path to directory for sentinel files
//
// Returns:
//   $ok_b : Boolean : True if stage passed, False if failed
//
// Sentinel file: <sentinelDir>/stage-platypus.txt
// ----------------------------------------------------

#DECLARE($sentinelDir_t : Text)->$ok_b : Boolean

var $sentinelPath_t; $koalaDir_t; $platypusDir_t : Text
var $renamerPath_t; $renamerCmd_t : Text
var $stdout_t; $stderr_t : Text

$sentinelPath_t:=$sentinelDir_t+"stage-platypus.txt"
$ok_b:=False

// ---------------------------------------------------------------------------
// 1. Locate staging directories
// ---------------------------------------------------------------------------

$koalaDir_t:=Get 4D folder(Database folder)
$koalaDir_t:=Replace string($koalaDir_t; "Release"+Folder separator+"Project"+Folder separator; "")
$koalaDir_t:=Replace string($koalaDir_t; "nativeObjectTools"+Folder separator; "staging-koala"+Folder separator)

$platypusDir_t:=Replace string($koalaDir_t; "staging-koala"+Folder separator; "staging-platypus"+Folder separator)

// ---------------------------------------------------------------------------
// 2. rsync staging-koala/ -> staging-platypus/
// ---------------------------------------------------------------------------

LAUNCH EXTERNAL PROCESS(\
	"rsync --archive --delete "+Char(34)+$koalaDir_t+Char(34)+" "+Char(34)+$platypusDir_t+Char(34); \
	$stdout_t; $stderr_t)

If (OK#1)
	TEXT TO DOCUMENT($sentinelPath_t; \
		"stagePlatypus failed"+Char(13)+"rsync failed"+Char(13)+$stderr_t; \
		"UTF-8")
	$ok_b:=False
	return
End if

// ---------------------------------------------------------------------------
// 3. Invoke Renamer in forward mode against staging-platypus/
//    The Renamer project lives at Renaming/ in the Echidna checkout.
//    It is invoked headlessly with --user-param "forward:<target-path>"
// ---------------------------------------------------------------------------

$renamerPath_t:=Get 4D folder(Database folder)
$renamerPath_t:=Replace string($renamerPath_t; "Release"+Folder separator+"Project"+Folder separator; "")
$renamerPath_t:=$renamerPath_t+"Renaming"+Folder separator

// NOTE: The exact invocation path and user-param convention for the Renamer
// must be confirmed against the Renamer project's OnStartup method.
// Placeholder invocation — update when Renamer headless API is confirmed.
$renamerCmd_t:="open -W /Applications/4D/20/4D.app --args"
$renamerCmd_t:=$renamerCmd_t+" --project "+Char(34)+$renamerPath_t+Char(34)
$renamerCmd_t:=$renamerCmd_t+" --create-data /tmp/renamer-data.4DD"
$renamerCmd_t:=$renamerCmd_t+" --user-param "+Char(34)+"forward:"+$platypusDir_t+Char(34)
$renamerCmd_t:=$renamerCmd_t+" --headless"

LAUNCH EXTERNAL PROCESS($renamerCmd_t; $stdout_t; $stderr_t)

If (OK#1)
	TEXT TO DOCUMENT($sentinelPath_t; \
		"stagePlatypus failed"+Char(13)+"Renamer invocation failed"+Char(13)+$stderr_t; \
		"UTF-8")
	$ok_b:=False
	return
End if

// ---------------------------------------------------------------------------
// 4. Write success sentinel
// ---------------------------------------------------------------------------

TEXT TO DOCUMENT($sentinelPath_t; "stagePlatypus passed"; "UTF-8")
$ok_b:=True
