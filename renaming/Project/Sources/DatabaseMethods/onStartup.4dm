var $userParam_t; $action_t; $sentinelDir_t; $sentinelPath_t; $sentinel_t : Text
var $params_c : Collection
var $repoRoot_t; $methodsFolder_t; $foldersJSON_t; $derivedData_t; $reportText_t : Text
var $value_r : Real

$value_r:=Get database parameter(User param value; $userParam_t)

If ($userParam_t#"")

	// CI launch — user param present.
	// --user-param format: "action;/path/to/sentinelDir/"
	//   forward: "forward;/path/to/sentinelDir/"
	$params_c:=Split string($userParam_t; ";"; sk ignore empty strings+sk trim spaces)

	If ($params_c.length>=2)
		$action_t:=$params_c[0]
		$sentinelDir_t:=$params_c[1]
	End if

	// Derive target project paths from the repo root.
	// Renaming project sits at <repoRoot>/Renaming/, so Database folder is <repoRoot>/Renaming/
	$repoRoot_t:=Get 4D folder(Database folder)  // …/Renaming/
	$repoRoot_t:=Substring($repoRoot_t; 1; Length($repoRoot_t)-Length("Renaming"+Folder separator))
	
	$methodsFolder_t:=$repoRoot_t+"Project"+Folder separator+"Sources"+Folder separator+"Methods"+Folder separator
	$foldersJSON_t:=$repoRoot_t+"Project"+Folder separator+"Sources"+Folder separator+"folders.json"
	$derivedData_t:=$repoRoot_t+"Project"+Folder separator+"DerivedData"+Folder separator
	
	Case of 
		: ($action_t="forward")
			$reportText_t:=Renamer_Forward($methodsFolder_t; $foldersJSON_t; $derivedData_t; True)
			
			$sentinelPath_t:=Convert path POSIX to system($sentinelDir_t)+"rename-forward.txt"
			If (OK=1)
				$sentinel_t:="rename-forward passed"
			Else 
				$sentinel_t:="rename-forward failed"
				$sentinel_t:=$sentinel_t+Char(13)+$reportText_t
			End if 
			TEXT TO DOCUMENT($sentinelPath_t; $sentinel_t; "UTF-8"; Document with LF)
			
	End case 
	
	QUIT 4D
	
End if 
// Non-headless: no On Startup action — Renamer is a pure tool, not an application.
