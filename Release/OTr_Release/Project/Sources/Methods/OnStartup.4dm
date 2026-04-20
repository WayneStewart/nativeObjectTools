//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OnStartup
//
// Entry point for headless release pipeline execution.
// Reads --user-param, splits on ";" into stage names,
// and dispatches each in sequence. On any failure writes
// a sentinel file and calls QUIT 4D.
//
// Sentinel contract:
//   Line 1: "<stage> passed" or "<stage> failed"
//   Remaining lines: diagnostic detail
//
// Usage (from workflow):
//   open -W /Applications/4D/19/4D.app --args \
//     --project ".../OTr_Release.4DProject" \
//     --create-data "/tmp/otr-release-data.4DD" \
//     --user-param "stageKoala" \
//     --headless
// ----------------------------------------------------

var $userParam_t : Text
var $stage_t : Text
var $sentinelDir_t : Text
var $stages_c : Collection
var $ok_b : Boolean

// Read the stage list from --user-param
// Get database parameter returns the numeric value; string value is in 2nd param
Get database parameter(User param value; $userParam_t)

If ($userParam_t="")
	QUIT 4D
End if

// Sentinel files land in the Resources folder — workflow reads them from there.
$sentinelDir_t:=Get 4D folder(Current resources folder)

// Split on ";" to support batched stages e.g. "compile;build"
$stages_c:=Split string($userParam_t; ";")

$ok_b:=True

For each ($stage_t; $stages_c) While ($ok_b)

	// Trim leading/trailing spaces and tabs
	$stage_t:=Replace string(Replace string($stage_t; " "; ""); Char(9); "")

	If ($stage_t#"")

		Case of
			: ($stage_t="stageKoala")
				$ok_b:=Release_stageKoala($sentinelDir_t)

			: ($stage_t="stagePlatypus")
				$ok_b:=Release_stagePlatypus($sentinelDir_t)

			: ($stage_t="compile")
				$ok_b:=Release_compile($sentinelDir_t)

			: ($stage_t="build")
				$ok_b:=Release_build($sentinelDir_t)

			Else
				TEXT TO DOCUMENT($sentinelDir_t+"unknown-stage.txt"; \
					$stage_t+" failed"+Char(13)+"Unknown stage: "+$stage_t; "UTF-8")
				$ok_b:=False

		End case

	End if

End for each

QUIT 4D
