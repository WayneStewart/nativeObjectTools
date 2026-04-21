//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: __Compile_Headless

// Headless CI compile check.
// Called from On Startup when 4D is launched with --headless --user-param "compile".
// Runs Compile project, writes a sentinel file with pass/fail on line 1
// and compiler error detail on subsequent lines.

// Access: Private

// Parameters:
//   $sentinelDir_t : Text : system path to folder where sentinel file is written

// This method is stripped from Koala/Platypus by the exclusions manifest.
// It must never ship with the component.

// Created by Wayne Stewart, 2026-04-21
// ----------------------------------------------------

#DECLARE($sentinelDir_t : Text)

var $options_o : Object
var $result_o : Object
var $errors_c : Collection
var $error_o : Object
var $sentinel_t; $sentinelPath_t : Text

//MARK: Compile

// $options_o:=New object("targets"; New collection)
$result_o:=Compile project:C1760  // ($options_o)

//MARK: Build sentinel text

If ($result_o.success)
	$sentinel_t:="Syntax check passed"
Else 
	$sentinel_t:="Syntax check failed"
	$errors_c:=$result_o.errors.query("isError == :1"; True:C214)
	For each ($error_o; $errors_c)
		$sentinel_t:=$sentinel_t+Char:C90(Carriage return:K15:38)+\
			"------------------------"+Char:C90(Carriage return:K15:38)+\
			"Method: "+$error_o.code.path+Char:C90(Carriage return:K15:38)+\
			"Line: "+String:C10($error_o.line)+Char:C90(Carriage return:K15:38)+\
			"Message: "+$error_o.message
	End for each 
End if 

//MARK: Write sentinel

$sentinelPath_t:=Convert path POSIX to system($sentinelDir_t)+"compilationResult.txt"
TEXT TO DOCUMENT:C1237($sentinelPath_t; $sentinel_t; "UTF-8"; Document with LF:K24:22)
