//%attributes = {"invisible":true,"shared":true}
C_TEXT:C284($1)
C_POINTER:C301($2)

C_TEXT:C284($KeyIdentifier_t; $DictionaryName_t; $Key_t)
C_LONGINT:C283($Dictionary_i; $Position_i)

$KeyIdentifier_t:=$1
$Position_i:=Position:C15("."; $KeyIdentifier_t)
$DictionaryName_t:=Substring:C12($KeyIdentifier_t; 1; $Position_i-1)
$Key_t:=Substring:C12($KeyIdentifier_t; $Position_i+1; MAXTEXTLENBEFOREV11:K35:3)

$Dictionary_i:=Dict_Named($DictionaryName_t)

If (Count parameters:C259=2)
	Dict_SetArray($Dictionary_i; $Key_t; $2)
End if 