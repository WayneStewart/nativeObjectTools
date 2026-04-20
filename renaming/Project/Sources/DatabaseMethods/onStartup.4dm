var $appInfo_o : Object
var $userParam_t : Text
var $methodsFolder_t; $foldersJSON_t; $derivedData_t : Text
var $projectPath_t : Text
var $sentinelDir_t; $sentinelPath_t; $sentinel_t : Text
var $stderr_t : Text

$appInfo_o := Get application info

If ($appInfo_o.headless)

	Get database parameter(User param value; $userParam_t)

	If (Position("forward"; $userParam_t) > 0)

		// Derive target project paths — same logic as Renamer_Run.
		// Database folder is …/Renaming/, so strip "Renaming" and append "Project/".
		$projectPath_t := Replace string(Get 4D folder(Database folder); "Renaming"; "Project")
		$methodsFolder_t := $projectPath_t + "Sources" + Folder separator + "Methods" + Folder separator
		$foldersJSON_t   := $projectPath_t + "Sources" + Folder separator + "folders.json"
		$derivedData_t   := $projectPath_t + "DerivedData" + Folder separator

		// Sentinel directory is passed via environment variable.
		LAUNCH EXTERNAL PROCESS("printenv SENTINEL_DIR"; $sentinelDir_t; $stderr_t)
		$sentinelDir_t := Replace string($sentinelDir_t; Char(10); "")
		If (Length($sentinelDir_t) = 0)
			$sentinelDir_t := Get 4D folder(Database folder)  // fallback for manual testing
		End if

		$sentinelPath_t := $sentinelDir_t + "stage-platypus.txt"

		Renamer_Forward($methodsFolder_t; $foldersJSON_t; $derivedData_t; True)

		If (OK = 1)
			$sentinel_t := "stage-platypus passed" + Char(10)
		Else
			$sentinel_t := "stage-platypus failed" + Char(10)
		End if

		TEXT TO DOCUMENT($sentinelPath_t; $sentinel_t; "UTF-8"; Document with LF)

	End if

	QUIT 4D

End if
// Non-headless: no On Startup action — Renamer is a pure tool, not an application.
