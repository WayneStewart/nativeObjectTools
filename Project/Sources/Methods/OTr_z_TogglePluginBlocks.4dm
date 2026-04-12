//%attributes = {"invisible":true,"shared":false}
//// ----------------------------------------------------
//// Project Method: OTr_z_TogglePluginBlocks
////
//// **STATUS: PARTIAL STUB — NON-FUNCTIONAL. DO NOT CALL.**
////
//// The entire method body is commented out pending a rewrite.
//// Known bugs were found in the initial implementation before
//// it was ever used; the method was commented out in place to
//// preserve the design intent for when development resumes.
////
//// **Intended purpose (not yet working):**
////
//// Internal developer utility — NOT part of the public or
//// private OTr API. Intended solely for use by contributors
//// working on the OTr component itself.
////
//// When complete, this method will comment out or uncomment
//// the plugin-dependent code blocks in the side-by-side test
//// methods (_OT and _OTr variants), based on whether the
//// ObjectTools plugin is present in the Plugins folder and
//// whether the public API is in the OTr_ or OT  state.
////
//// Two sentinel block types are managed:
////
////   _OT files  — delimited by:
////     // ==== BEGIN OT BLOCK — comment out on Tahoe 26.4+ ====
////     // ==== END OT BLOCK ====
////     ACTION: comment out when plugin is ABSENT,
////             uncomment when plugin is PRESENT.
////
////   _OTr files — delimited by:
////     // ==== BEGIN OTr BLOCK — comment out when renamed to OT  ====
////     // ==== END OTr BLOCK ====
////     ACTION: comment out when public API is renamed (OT  state),
////             uncomment when public API is in OTr_ state.
////             State is detected by checking whether OTr_New exists
////             as a compiled method.
////
//// Intended process (when complete):
////   1. Check for ObjectTools.bundle in the Plugins folder.
////   2. Detect current OTr_/OT  API state via method existence.
////   3. Scan all _OT and _OTr methods; determine what changes
////      are needed without modifying anything.
////   4. Report findings and ask for confirmation.
////   5. Apply changes if confirmed.
////
//// Parameters: None
//// Returns:    Nothing
////
//// Created by Wayne Stewart, 2026-04-11
//// Wayne Stewart, 2026-04-11 — Commented out entire body: multiple
////   bugs found before first use. Stub retained for design reference.
//// ----------------------------------------------------

//var $methodsFolder_t : Text
//var $pluginsFolder_t : Text
//var $pluginPath_t : Text
//var $pluginPresent_b : Boolean
//var $otrActive_b : Boolean
//var $fileName_t : Text
//var $filePath_t : Text
//var $fileBody_t : Text
//var $originalBody_t : Text
//var $lines_ac : Collection
//var $line_t : Text
//var $trimmed_t : Text
//var $lineEnd_t : Text
//var $cleanedBody_t : Text
//var $inBlock_b : Boolean
//var $isOTFile_b : Boolean
//var $isOTrFile_b : Boolean
//var $commentOut_b : Boolean
//var $slashPos_i : Integer
//var $l_i : Integer
//var $i_i : Integer
//var $j_i : Integer
//var $changeCount_i : Integer
//var $msg_t : Text
//var $report_t : Text
//var $separator_t : Text
//var $blockCurrentlyCommented_b : Boolean
//var $firstCodeLine_t : Text
//var $needsChange_b : Boolean
//var $needsWrite_b : Boolean
//var $beginSentinel_t : Text

//ARRAY TEXT($changedFiles_at; 0)
//ARRAY TEXT($allFiles_at; 0)

//$separator_t:=Folder separator


//// ── 1. Locate folders ─────────────────────────────────────────────────────────

//// Methods folder is in the running database's Project/Sources/Methods/
//$methodsFolder_t:=Get 4D folder(Database folder)+"Project"+$separator_t+"Sources"+$separator_t+"Methods"+$separator_t

//// Plugins folder is a sibling of the Project folder
//$pluginsFolder_t:=Get 4D folder(Database folder)+"Plugins"+$separator_t

//// ── 2. Check plugin presence ──────────────────────────────────────────────────

//$pluginPath_t:=$pluginsFolder_t+"ObjectTools.bundle"
//$pluginPresent_b:=(Test path name($pluginPath_t)=Is a folder)  // .bundle is a macOS package (folder)

//If (Not($pluginPresent_b))
//// Also accept it as a document (Windows DLL variant)
//$pluginPresent_b:=(Test path name($pluginPath_t)=Is a document)
//End if 

//// ── 3. Detect current API state ───────────────────────────────────────────────
//// If OTr_New exists as a compiled method, the API is in the OTr_ state.
//// After a forward rename it becomes OT New and OTr_New no longer exists.

//$otrActive_b:=(Is a method("OTr_New")=True)

//// ── 4. Determine target comment state for each block type ─────────────────────
////
////   OT BLOCK  (in _OT files):  comment out when plugin absent
////   OTr BLOCK (in _OTr files): comment out when API is in OT  state (OTr_ absent)

//// $commentOut_b is set per-file inside the loop below

//// ── 5. Scan files and build change report ─────────────────────────────────────

//$changeCount_i:=0
//$report_t:="ObjectTools plugin : "+Choose($pluginPresent_b; "PRESENT"; "ABSENT")+Char(13)
//$report_t:=$report_t+"Public API state   : "+Choose($otrActive_b; "OTr_ (legacy)"; "OT  (renamed)")+Char(13)
//$report_t:=$report_t+Char(13)

//DOCUMENT LIST($methodsFolder_t; $allFiles_at)

//$i_i:=1
//While ($i_i<=Size of array($allFiles_at))
//$fileName_t:=$allFiles_at{$i_i}

//$isOTFile_b:=(Position("_OT.4dm"; $fileName_t)=(Length($fileName_t)-6))
//$isOTrFile_b:=(Position("_OTr.4dm"; $fileName_t)=(Length($fileName_t)-7))

//If ($isOTFile_b | $isOTrFile_b)
//$filePath_t:=$methodsFolder_t+$fileName_t
//$fileBody_t:=Document to text($filePath_t; "UTF-8")
//$originalBody_t:=$fileBody_t

//// Detect line ending
//If (Position(Char(10); $fileBody_t)>0)
//$lineEnd_t:=Char(10)
//Else 
//$lineEnd_t:=Char(13)
//End if 

//$lines_ac:=Split string($fileBody_t; $lineEnd_t)

//// Determine whether this file's block should be commented out
//If ($isOTFile_b)
//$commentOut_b:=Not($pluginPresent_b)  // comment out when plugin absent
//Else 
//$commentOut_b:=Not($otrActive_b)  // comment out when OTr_ API is gone
//End if 

//// Check current state of the block to determine if a change is needed.
//// We look at the first non-blank code line inside the block.
//// If it starts with "//" the block is currently commented out.
//$blockCurrentlyCommented_b:=False
//$firstCodeLine_t:=""
//$needsChange_b:=False

//$beginSentinel_t:=Choose($isOTFile_b; "BEGIN OT BLOCK"; "BEGIN OTr BLOCK")

//$inBlock_b:=False
//$l_i:=0
//While (($l_i<$lines_ac.length) & ($firstCodeLine_t=""))
//$trimmed_t:=Trim(String($lines_ac[$l_i]))
//If (Position($beginSentinel_t; $trimmed_t)>0)
//$inBlock_b:=True
//Else 
//If ($inBlock_b & (Length($trimmed_t)>0))
//$firstCodeLine_t:=$trimmed_t
//End if 
//End if 
//$i_i:=$i_i+1
//End while 

//If ($firstCodeLine_t#"")
//$blockCurrentlyCommented_b:=(Substring($firstCodeLine_t; 1; 2)="//")
//$needsChange_b:=($blockCurrentlyCommented_b#$commentOut_b)
//End if 

//If ($needsChange_b)
//// Apply the toggle
//$cleanedBody_t:=""
//$inBlock_b:=False

//$l_i:=0
//While ($l_i<$lines_ac.length)
//$line_t:=String($lines_ac[$l_i])
//$trimmed_t:=Trim($line_t)

//If (Position($beginSentinel_t; $trimmed_t)>0)
//$inBlock_b:=True
//End if 
//If (Position("END OT BLOCK"; $trimmed_t)>0)
//$inBlock_b:=False
//End if 

//If ($inBlock_b & (Position($beginSentinel_t; $trimmed_t)=0))
//If ($commentOut_b)
//// Comment out: prefix non-blank, non-already-commented lines
//If ((Length($trimmed_t)>0) & (Substring($trimmed_t; 1; 2)#"//"))
//$line_t:="//"+$line_t
//End if 
//Else 
//// Uncomment: strip leading "//"
//If (Substring($trimmed_t; 1; 2)="//")
//$slashPos_i:=Position("//"; $line_t)
//$line_t:=Substring($line_t; 1; $slashPos_i-1)+Substring($line_t; $slashPos_i+2)
//End if 
//End if 
//End if 

//If (Length($cleanedBody_t)>0)
//$cleanedBody_t:=$cleanedBody_t+$lineEnd_t
//End if 
//$cleanedBody_t:=$cleanedBody_t+$line_t

//$i_i:=$i_i+1
//End while 

//$fileBody_t:=$cleanedBody_t
//End if 

//If ($fileBody_t#$originalBody_t)
//APPEND TO ARRAY($changedFiles_at; $fileName_t)
//$changeCount_i:=$changeCount_i+1
//End if 
//End if 

//$i_i:=$i_i+1
//End while 

//// ── 6. Report and confirm ─────────────────────────────────────────────────────

//If ($changeCount_i=0)
//$report_t:=$report_t+"All blocks are already in the correct state. No changes needed."
//ALERT($report_t)
//return
//End if 

//$report_t:=$report_t+String($changeCount_i)+" file(s) need updating:"+Char(13)
//$i_i:=1
//While ($i_i<=Size of array($changedFiles_at))
//$report_t:=$report_t+"  "+$changedFiles_at{$i_i}+Char(13)
//$i_i:=$i_i+1
//End while 
//$report_t:=$report_t+Char(13)+"Proceed?"

//CONFIRM($report_t)
//If (OK#1)
//ALERT("Cancelled. No changes made.")
//return
//End if 

//// ── 7. Write the changes ──────────────────────────────────────────────────────
//// Re-run the same logic and write this time.
//// Simpler and safer to re-scan than to cache the modified bodies.

//$i_i:=1
//While ($i_i<=Size of array($allFiles_at))
//$fileName_t:=$allFiles_at{$i_i}

//$isOTFile_b:=(Position("_OT.4dm"; $fileName_t)=(Length($fileName_t)-6))
//$isOTrFile_b:=(Position("_OTr.4dm"; $fileName_t)=(Length($fileName_t)-7))

//If ($isOTFile_b | $isOTrFile_b)
//// Only write files that were flagged as needing a change
//$needsWrite_b:=False
//$j_i:=1
//While ($j_i<=Size of array($changedFiles_at))
//If ($changedFiles_at{$j_i}=$fileName_t)
//$needsWrite_b:=True
//End if 
//$j_i+=1
//End while 

//If ($needsWrite_b)
//$filePath_t:=$methodsFolder_t+$fileName_t
//$fileBody_t:=Document to text($filePath_t; "UTF-8")

//If (Position(Char(10); $fileBody_t)>0)
//$lineEnd_t:=Char(10)
//Else 
//$lineEnd_t:=Char(13)
//End if 

//$lines_ac:=Split string($fileBody_t; $lineEnd_t)

//If ($isOTFile_b)
//$commentOut_b:=Not($pluginPresent_b)
//$beginSentinel_t:="BEGIN OT BLOCK"
//Else 
//$commentOut_b:=Not($otrActive_b)
//$beginSentinel_t:="BEGIN OTr BLOCK"
//End if 

//$cleanedBody_t:=""
//$inBlock_b:=False

//$l_i:=0
//While ($l_i<$lines_ac.length)
//$line_t:=String($lines_ac[$l_i])
//$trimmed_t:=Trim($line_t)

//If (Position($beginSentinel_t; $trimmed_t)>0)
//$inBlock_b:=True
//End if 
//If (Position("END OT BLOCK"; $trimmed_t)>0)
//$inBlock_b:=False
//End if 

//If ($inBlock_b & (Position($beginSentinel_t; $trimmed_t)=0))
//If ($commentOut_b)
//If ((Length($trimmed_t)>0) & (Substring($trimmed_t; 1; 2)#"//"))
//$line_t:="//"+$line_t
//End if 
//Else 
//If (Substring($trimmed_t; 1; 2)="//")
//$slashPos_i:=Position("//"; $line_t)
//$line_t:=Substring($line_t; 1; $slashPos_i-1)+Substring($line_t; $slashPos_i+2)
//End if 
//End if 
//End if 

//If (Length($cleanedBody_t)>0)
//$cleanedBody_t:=$cleanedBody_t+$lineEnd_t
//End if 
//$cleanedBody_t:=$cleanedBody_t+$line_t

//$i_i:=$i_i+1
//End while 

//TEXT TO DOCUMENT($filePath_t; $cleanedBody_t; "UTF-8")
//End if 
//End if 

//$i_i:=$i_i+1
//End while 

//ALERT("Done. "+String($changeCount_i)+" file(s) updated.")
