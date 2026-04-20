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

var $sentinelPath_t : Text
var $koalaDir_t : Text
var $platypusDir_t : Text
var $renamerPath_t : Text
var $renamerCmd_t : Text
var $stdout_t : Text
var $stderr_t : Text

$sentinelPath_t:=$sentinelDir_t+"stage-platypus.txt"
$ok_b:=False

// ---------------------------------------------------------------------------
// 1. Locate staging directories
//    Database folder = .../Release/OTr_Release/
//    Repo root = two levels up
// ---------------------------------------------------------------------------

$koalaDir_t:=Get 4D folder:C485(Database folder:K5:14)
$koalaDir_t:=Replace string:C233($koalaDir_t; \
	"Release"+Folder separator:K24:12+"OTr_Release"+Folder separator:K24:12; "")
$koalaDir_t:=Replace string:C233($koalaDir_t; \
	"nativeObjectTools"+Folder separator:K24:12; \
	"staging-koala"+Folder separator:K24:12)

$platypusDir_t:=Replace string:C233($koalaDir_t; \
	"staging-koala"+Folder separator:K24:12; \
	"staging-platypus"+Folder separator:K24:12)

// ---------------------------------------------------------------------------
// 2. rsync staging-koala/ -> staging-platypus/
// ---------------------------------------------------------------------------

LAUNCH EXTERNAL PROCESS:C811(\
	"rsync --archive --delete "+Char:C90(34)+$koalaDir_t+Char:C90(34)+" "+Char:C90(34)+$platypusDir_t+Char:C90(34); \
	$stdout_t; $stderr_t)

If (OK:C265#1)
	TEXT TO DOCUMENT:C1237($sentinelPath_t; \
		"stagePlatypus failed"+Char:C90(13)+"rsync failed"+Char:C90(13)+$stderr_t; \
		"UTF-8")
	$ok_b:=False
	return
End if

// ---------------------------------------------------------------------------
// 3. Invoke Renamer in forward mode against staging-platypus/
//    The Renamer project lives at Renaming/ in the repo root.
//    It is invoked headlessly with --user-param "forward:<target-path>"
//
// NOTE: The exact invocation path and user-param convention for the Renamer
// must be confirmed against the Renamer project's OnStartup method.
// Placeholder invocation — update when Renamer headless API is confirmed.
// ---------------------------------------------------------------------------

$renamerPath_t:=Get 4D folder:C485(Database folder:K5:14)
$renamerPath_t:=Replace string:C233($renamerPath_t; \
	"Release"+Folder separator:K24:12+"OTr_Release"+Folder separator:K24:12; "")
$renamerPath_t:=$renamerPath_t+"Renaming"+Folder separator:K24:12

$renamerCmd_t:="open -W /Applications/4D/19/4D.app --args"
$renamerCmd_t:=$renamerCmd_t+" --project "+Char:C90(34)+$renamerPath_t+Char:C90(34)
$renamerCmd_t:=$renamerCmd_t+" --create-data /tmp/renamer-data.4DD"
$renamerCmd_t:=$renamerCmd_t+" --user-param "+Char:C90(34)+"forward:"+$platypusDir_t+Char:C90(34)
$renamerCmd_t:=$renamerCmd_t+" --headless"

LAUNCH EXTERNAL PROCESS:C811($renamerCmd_t; $stdout_t; $stderr_t)

If (OK:C265#1)
	TEXT TO DOCUMENT:C1237($sentinelPath_t; \
		"stagePlatypus failed"+Char:C90(13)+"Renamer invocation failed"+Char:C90(13)+$stderr_t; \
		"UTF-8")
	$ok_b:=False
	return
End if

// ---------------------------------------------------------------------------
// 4. Write success sentinel
// ---------------------------------------------------------------------------

TEXT TO DOCUMENT:C1237($sentinelPath_t; "stagePlatypus passed"; "UTF-8")
$ok_b:=True
