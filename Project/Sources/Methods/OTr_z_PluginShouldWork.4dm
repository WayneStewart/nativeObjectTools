//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTr_z_PluginShouldWork --> Boolean

// Determines if the plugin should work based on plugin presence, OS, and
// ObjectTools plugin version compatibility.

// Access: Private

// Returns:
//   $pluginShouldWork_b : Boolean : Returns true if the plugin is a) present and b) the OS supports it
//     or the installed plugin version is known to support the current OS.

// Created by Wayne Stewart 2026-04-17
// Wayne Stewart / Codex, 2026-04-18 - Allow ObjectTools v5.1r2+ on Tahoe.
// ----------------------------------------------------

#DECLARE()->$pluginShouldWork_b : Boolean

var $pluginPresent_b; $operatingSystemIsOK_b; $pluginVersionIsTahoeOK_b : Boolean
var $readingNumber_b : Boolean
var $pluginPath_t; $pluginInfoPath_t; $pluginInfo_t; $OS_t; $version_t : Text
var $digits_t; $char_t : Text
var $versionKeyPos_i; $versionStringStart_i; $versionValueStart_i; $versionStringEnd_i : Integer
var $scanPos_i; $partStart_i; $rPos_i : Integer
var $major_i; $minor_i; $revision_i : Integer
var $systemInfo_o : Object

$pluginPath_t:=Get 4D folder:C485(Database folder:K5:14)+"Plugins"+Folder separator:K24:12+"ObjectTools.bundle"+Folder separator:K24:12
$pluginInfoPath_t:=$pluginPath_t+"Contents"+Folder separator:K24:12+"Info.plist"
$pluginPresent_b:=(Test path name:C476($pluginPath_t)=Is a folder:K24:2)
$pluginVersionIsTahoeOK_b:=False:C215

If ($pluginPresent_b)
	If (Test path name:C476($pluginInfoPath_t)=Is a document:K24:1)
		$pluginInfo_t:=Document to text:C1236($pluginInfoPath_t; "UTF-8")
		$versionKeyPos_i:=Position:C15("<key>CFBundleShortVersionString</key>"; $pluginInfo_t)
		If ($versionKeyPos_i>0)
			$versionStringStart_i:=Position:C15("<string>"; $pluginInfo_t; $versionKeyPos_i)
			If ($versionStringStart_i>0)
				$versionValueStart_i:=$versionStringStart_i+Length:C16("<string>")
				$versionStringEnd_i:=Position:C15("</string>"; $pluginInfo_t; $versionValueStart_i)
				If ($versionStringEnd_i>$versionValueStart_i)
					$version_t:=Lowercase:C14(Substring:C12($pluginInfo_t; $versionValueStart_i; ($versionStringEnd_i-$versionValueStart_i)))
					$digits_t:="0123456789"
					$major_i:=-1
					$minor_i:=0
					$revision_i:=0
					$scanPos_i:=1
					$partStart_i:=0

					While ($scanPos_i<=Length:C16($version_t))
						$char_t:=Substring:C12($version_t; $scanPos_i; 1)
						If (Position:C15($char_t; $digits_t)>0)
							$partStart_i:=$scanPos_i
							$scanPos_i:=(Length:C16($version_t)+1)
						Else
							$scanPos_i:=$scanPos_i+1
						End if
					End while

					If ($partStart_i>0)
						$scanPos_i:=$partStart_i
						$readingNumber_b:=True:C214
						While (($readingNumber_b) & ($scanPos_i<=Length:C16($version_t)))
							$char_t:=Substring:C12($version_t; $scanPos_i; 1)
							If (Position:C15($char_t; $digits_t)>0)
								$scanPos_i:=$scanPos_i+1
							Else
								$readingNumber_b:=False:C215
							End if
						End while
						$major_i:=Num:C11(Substring:C12($version_t; $partStart_i; ($scanPos_i-$partStart_i)))

						If ($scanPos_i<=Length:C16($version_t))
							If (Substring:C12($version_t; $scanPos_i; 1)=".")
								$scanPos_i:=$scanPos_i+1
								$partStart_i:=$scanPos_i
								$readingNumber_b:=True:C214
								While (($readingNumber_b) & ($scanPos_i<=Length:C16($version_t)))
									$char_t:=Substring:C12($version_t; $scanPos_i; 1)
									If (Position:C15($char_t; $digits_t)>0)
										$scanPos_i:=$scanPos_i+1
									Else
										$readingNumber_b:=False:C215
									End if
								End while
								If ($scanPos_i>$partStart_i)
									$minor_i:=Num:C11(Substring:C12($version_t; $partStart_i; ($scanPos_i-$partStart_i)))
								End if
							End if
						End if

						$rPos_i:=Position:C15("r"; $version_t; $scanPos_i)
						If ($rPos_i>0)
							$scanPos_i:=$rPos_i+1
							$partStart_i:=$scanPos_i
							$readingNumber_b:=True:C214
							While (($readingNumber_b) & ($scanPos_i<=Length:C16($version_t)))
								$char_t:=Substring:C12($version_t; $scanPos_i; 1)
								If (Position:C15($char_t; $digits_t)>0)
									$scanPos_i:=$scanPos_i+1
								Else
									$readingNumber_b:=False:C215
								End if
							End while
							If ($scanPos_i>$partStart_i)
								$revision_i:=Num:C11(Substring:C12($version_t; $partStart_i; ($scanPos_i-$partStart_i)))
							End if
						End if

						$pluginVersionIsTahoeOK_b:=($major_i>5)
						If (Not:C34($pluginVersionIsTahoeOK_b))
							If ($major_i=5)
								If ($minor_i>1)
									$pluginVersionIsTahoeOK_b:=True:C214
								Else
									If (($minor_i=1) & ($revision_i>=2))
										$pluginVersionIsTahoeOK_b:=True:C214
									End if
								End if
							End if
						End if
					End if
				End if
			End if
		End if
	End if
End if


$systemInfo_o:=Get system info:C1571
If ($systemInfo_o#Null:C1517)
	$OS_t:=Replace string:C233($systemInfo_o.osVersion; "MacOS "; "")
End if

$operatingSystemIsOK_b:=Not:C34($OS_t="26.4@")

$pluginShouldWork_b:=($pluginPresent_b & ($operatingSystemIsOK_b | $pluginVersionIsTahoeOK_b))


