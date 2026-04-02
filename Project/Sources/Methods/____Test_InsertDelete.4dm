//%attributes = {"invisible":false,"shared":false}
// ----------------------------------------------------
// Project Method: ____Test_InsertDelete
//
// Compares two approaches for element insert/delete on
// object-based arrays using only native 4D commands
// (no OTr API). Arrays mirror OTr storage: keys "0"
// through "numElements" (element 0 = pre-selection
// slot, always empty).
//
// Approach A1: Direct key-shifting within the object.
// Approach A2: Extract to ARRAY TEXT, use native
//   INSERT IN ARRAY / DELETE FROM ARRAY, rebuild.
//
// Each result shows two lines:
//   Logical: iterated 1..numElements  (always correct)
//   JSON:    JSON Stringify            (reveals key order)
//
// Tests:
//   T1. Delete Wednesday  (days,   pos 3)
//   T2. Delete July       (months, pos 7)
//   T3. Insert "Koala"  before Wednesday  (days,   pos 3)
//   T4. Insert "Wombat" before September  (months, pos 9)
//
// Created by Wayne Stewart, 2026-04-02
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

var $src_days_o; $src_mon_o : Object
var $a1_o; $a2_o : Object
var $i_i; $n_i; $pos_i : Integer
var $logical_t; $results_t : Text

ARRAY TEXT:C222($work_at; 0)

// ------------------------------------------------
// Build source data (keys "0".."numElements")
// ------------------------------------------------

$src_days_o:=New object:C1471
$src_days_o.numElements:=7
$src_days_o["0"]:=""
$src_days_o["1"]:="Monday"
$src_days_o["2"]:="Tuesday"
$src_days_o["3"]:="Wednesday"
$src_days_o["4"]:="Thursday"
$src_days_o["5"]:="Friday"
$src_days_o["6"]:="Saturday"
$src_days_o["7"]:="Sunday"


$src_mon_o:=New object:C1471
$src_mon_o.numElements:=12
$src_mon_o["0"]:=""
$src_mon_o["1"]:="January"
$src_mon_o["2"]:="February"
$src_mon_o["3"]:="March"
$src_mon_o["4"]:="April"
$src_mon_o["5"]:="May"
$src_mon_o["6"]:="June"
$src_mon_o["7"]:="July"
$src_mon_o["8"]:="August"
$src_mon_o["9"]:="September"
$src_mon_o["10"]:="October"
$src_mon_o["11"]:="November"
$src_mon_o["12"]:="December"


// ------------------------------------------------
// TEST 1: Delete Wednesday (pos 3, days)
// ------------------------------------------------

$results_t:=$results_t+"=== T1: Delete Wednesday (pos 3) ==="+Char:C90(13)

// A1 — shift keys down in place
$a1_o:=OB Copy:C1225($src_days_o)
$n_i:=$a1_o.numElements
$pos_i:=3
For ($i_i; $pos_i; $n_i-1)
	$a1_o[String:C10($i_i)]:=OB Get:C1224($a1_o; String:C10($i_i+1); Is text:K8:3)
End for 
OB REMOVE:C1226($a1_o; String:C10($n_i))
$a1_o.numElements:=$n_i-1

$logical_t:="A1 logical: "
For ($i_i; 1; $a1_o.numElements)
	$logical_t:=$logical_t+OB Get:C1224($a1_o; String:C10($i_i); Is text:K8:3)
	If ($i_i<$a1_o.numElements)
		$logical_t:=$logical_t+", "
	End if 
End for 
$results_t:=$results_t+$logical_t+Char:C90(13)
$results_t:=$results_t+"A1 JSON:    "+JSON Stringify:C1217($a1_o; *)+Char:C90(13)

// A2 — extract, DELETE FROM ARRAY, rebuild
$a2_o:=OB Copy:C1225($src_days_o)
$n_i:=$a2_o.numElements
ARRAY TEXT:C222($work_at; $n_i)
For ($i_i; 1; $n_i)
	$work_at{$i_i}:=OB Get:C1224($a2_o; String:C10($i_i); Is text:K8:3)
End for 
DELETE FROM ARRAY:C228($work_at; 3)
$n_i:=Size of array:C274($work_at)
$a2_o:=New object:C1471
$a2_o["0"]:=""
For ($i_i; 1; $n_i)
	$a2_o[String:C10($i_i)]:=$work_at{$i_i}
End for 
$a2_o.numElements:=$n_i

$logical_t:="A2 logical: "
For ($i_i; 1; $a2_o.numElements)
	$logical_t:=$logical_t+OB Get:C1224($a2_o; String:C10($i_i); Is text:K8:3)
	If ($i_i<$a2_o.numElements)
		$logical_t:=$logical_t+", "
	End if 
End for 
$results_t:=$results_t+$logical_t+Char:C90(13)
$results_t:=$results_t+"A2 JSON:    "+JSON Stringify:C1217($a2_o; *)+Char:C90(13)+Char:C90(13)

// ------------------------------------------------
// TEST 2: Delete July (pos 7, months)
// ------------------------------------------------

$results_t:=$results_t+"=== T2: Delete July (pos 7) ==="+Char:C90(13)

// A1
$a1_o:=OB Copy:C1225($src_mon_o)
$n_i:=$a1_o.numElements
$pos_i:=7
For ($i_i; $pos_i; $n_i-1)
	$a1_o[String:C10($i_i)]:=OB Get:C1224($a1_o; String:C10($i_i+1); Is text:K8:3)
End for 
OB REMOVE:C1226($a1_o; String:C10($n_i))
$a1_o.numElements:=$n_i-1

$logical_t:="A1 logical: "
For ($i_i; 1; $a1_o.numElements)
	$logical_t:=$logical_t+OB Get:C1224($a1_o; String:C10($i_i); Is text:K8:3)
	If ($i_i<$a1_o.numElements)
		$logical_t:=$logical_t+", "
	End if 
End for 
$results_t:=$results_t+$logical_t+Char:C90(13)
$results_t:=$results_t+"A1 JSON:    "+JSON Stringify:C1217($a1_o; *)+Char:C90(13)

// A2
$a2_o:=OB Copy:C1225($src_mon_o)
$n_i:=$a2_o.numElements
ARRAY TEXT:C222($work_at; $n_i)
For ($i_i; 1; $n_i)
	$work_at{$i_i}:=OB Get:C1224($a2_o; String:C10($i_i); Is text:K8:3)
End for 
DELETE FROM ARRAY:C228($work_at; 7)
$n_i:=Size of array:C274($work_at)
$a2_o:=New object:C1471
$a2_o["0"]:=""
For ($i_i; 1; $n_i)
	$a2_o[String:C10($i_i)]:=$work_at{$i_i}
End for 
$a2_o.numElements:=$n_i

$logical_t:="A2 logical: "
For ($i_i; 1; $a2_o.numElements)
	$logical_t:=$logical_t+OB Get:C1224($a2_o; String:C10($i_i); Is text:K8:3)
	If ($i_i<$a2_o.numElements)
		$logical_t:=$logical_t+", "
	End if 
End for 
$results_t:=$results_t+$logical_t+Char:C90(13)
$results_t:=$results_t+"A2 JSON:    "+JSON Stringify:C1217($a2_o; *)+Char:C90(13)+Char:C90(13)

// ------------------------------------------------
// TEST 3: Insert "Koala" before Wednesday (pos 3, days)
// ------------------------------------------------

$results_t:=$results_t+"=== T3: Insert Koala before Wednesday (pos 3) ==="+Char:C90(13)

// A1 — shift keys up from end, place new value at pos
$a1_o:=OB Copy:C1225($src_days_o)
$n_i:=$a1_o.numElements
$pos_i:=3
For ($i_i; $n_i; $pos_i; -1)
	$a1_o[String:C10($i_i+1)]:=OB Get:C1224($a1_o; String:C10($i_i); Is text:K8:3)
End for 
$a1_o[String:C10($pos_i)]:="Koala"
$a1_o.numElements:=$n_i+1

$logical_t:="A1 logical: "
For ($i_i; 1; $a1_o.numElements)
	$logical_t:=$logical_t+OB Get:C1224($a1_o; String:C10($i_i); Is text:K8:3)
	If ($i_i<$a1_o.numElements)
		$logical_t:=$logical_t+", "
	End if 
End for 
$results_t:=$results_t+$logical_t+Char:C90(13)
$results_t:=$results_t+"A1 JSON:    "+JSON Stringify:C1217($a1_o; *)+Char:C90(13)

// A2
$a2_o:=OB Copy:C1225($src_days_o)
$n_i:=$a2_o.numElements
ARRAY TEXT:C222($work_at; $n_i)
For ($i_i; 1; $n_i)
	$work_at{$i_i}:=OB Get:C1224($a2_o; String:C10($i_i); Is text:K8:3)
End for 
INSERT IN ARRAY:C227($work_at; 3)
$work_at{3}:="Koala"
$n_i:=Size of array:C274($work_at)
$a2_o:=New object:C1471
$a2_o["0"]:=""
For ($i_i; 1; $n_i)
	$a2_o[String:C10($i_i)]:=$work_at{$i_i}
End for 
$a2_o.numElements:=$n_i

$logical_t:="A2 logical: "
For ($i_i; 1; $a2_o.numElements)
	$logical_t:=$logical_t+OB Get:C1224($a2_o; String:C10($i_i); Is text:K8:3)
	If ($i_i<$a2_o.numElements)
		$logical_t:=$logical_t+", "
	End if 
End for 
$results_t:=$results_t+$logical_t+Char:C90(13)
$results_t:=$results_t+"A2 JSON:    "+JSON Stringify:C1217($a2_o; *)+Char:C90(13)+Char:C90(13)

// ------------------------------------------------
// TEST 4: Insert "Wombat" before September (pos 9, months)
// ------------------------------------------------

$results_t:=$results_t+"=== T4: Insert Wombat before September (pos 9) ==="+Char:C90(13)

// A1
$a1_o:=OB Copy:C1225($src_mon_o)
$n_i:=$a1_o.numElements
$pos_i:=9
For ($i_i; $n_i; $pos_i; -1)
	$a1_o[String:C10($i_i+1)]:=OB Get:C1224($a1_o; String:C10($i_i); Is text:K8:3)
End for 
$a1_o[String:C10($pos_i)]:="Wombat"
$a1_o.numElements:=$n_i+1

$logical_t:="A1 logical: "
For ($i_i; 1; $a1_o.numElements)
	$logical_t:=$logical_t+OB Get:C1224($a1_o; String:C10($i_i); Is text:K8:3)
	If ($i_i<$a1_o.numElements)
		$logical_t:=$logical_t+", "
	End if 
End for 
$results_t:=$results_t+$logical_t+Char:C90(13)
$results_t:=$results_t+"A1 JSON:    "+JSON Stringify:C1217($a1_o; *)+Char:C90(13)

// A2
$a2_o:=OB Copy:C1225($src_mon_o)
$n_i:=$a2_o.numElements
ARRAY TEXT:C222($work_at; $n_i)
For ($i_i; 1; $n_i)
	$work_at{$i_i}:=OB Get:C1224($a2_o; String:C10($i_i); Is text:K8:3)
End for 
INSERT IN ARRAY:C227($work_at; 9)
$work_at{9}:="Wombat"
$n_i:=Size of array:C274($work_at)
$a2_o:=New object:C1471
$a2_o["0"]:=""
For ($i_i; 1; $n_i)
	$a2_o[String:C10($i_i)]:=$work_at{$i_i}
End for 
$a2_o.numElements:=$n_i

$logical_t:="A2 logical: "
For ($i_i; 1; $a2_o.numElements)
	$logical_t:=$logical_t+OB Get:C1224($a2_o; String:C10($i_i); Is text:K8:3)
	If ($i_i<$a2_o.numElements)
		$logical_t:=$logical_t+", "
	End if 
End for 
$results_t:=$results_t+$logical_t+Char:C90(13)
$results_t:=$results_t+"A2 JSON:    "+JSON Stringify:C1217($a2_o; *)+Char:C90(13)

// ------------------------------------------------
// Output
// ------------------------------------------------

ALERT:C41("Done, the results are in the clipboard")
SET TEXT TO PASTEBOARD:C523($results_t)