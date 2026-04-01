//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// User name (OS): Wayne Stewart
// Date and time: Dec 8, 2009, 19:47:07
// ----------------------------------------------------
// Method: Dict_InsertArrayElement
// Description
//   
//
// Parameters
C_LONGINT:C283($DictionaryID_i; $1)
C_TEXT:C284($Key_t; $2)
C_LONGINT:C283($inLocation_i; $3)

C_LONGINT:C283($DataStructureLocation_i; $MaxSize_i; $DataType_i)
C_TEXT:C284($ElementKeyLabel_t; $NextTag_t)


// ----------------------------------------------------
$DictionaryID_i:=$1
$Key_t:=$2
$inLocation_i:=$3

Dict_LockInternalState(True:C214)

If (Dict_IsValid($DictionaryID_i))
	$MaxSize_i:=Dict_SizeOfArray($DictionaryID_i; $Key_t)  //        Get the size of the array
	
	If ($MaxSize_i<$inLocation_i)
		$ElementKeyLabel_t:=$Key_t+"."+String:C10($MaxSize_i)
		$DataStructureLocation_i:=Find in array:C230(<>Dict_Keys_at{$DictionaryID_i}; $ElementKeyLabel_t)
		$DataType_i:=<>Dict_DataTypes_ai{$DictionaryID_i}{$DataStructureLocation_i}
		
		INSERT IN ARRAY:C227(<>Dict_Keys_at{$DictionaryID_i}; $DataStructureLocation_i+1)
		INSERT IN ARRAY:C227(<>Dict_Values_at{$DictionaryID_i}; $DataStructureLocation_i+1)
		INSERT IN ARRAY:C227(<>Dict_DataTypes_ai{$DictionaryID_i}; $DataStructureLocation_i+1)
		
		<>Dict_Keys_at{$DictionaryID_i}{$DataStructureLocation_i+1}:=$Key_t+"."+String:C10($MaxSize_i+1)
		<>Dict_DataTypes_ai{$DictionaryID_i}{$DataStructureLocation_i+1}:=$DataType_i
		
		Case of   //                                                                                   Set a default value
			: ($DataType_i=Is boolean:K8:9)
				<>Dict_Values_at{$DictionaryID_i}{$DataStructureLocation_i+1}:="False"
				
			: ($DataType_i=Is real:K8:4) | ($DataType_i=Is longint:K8:6)
				<>Dict_Values_at{$DictionaryID_i}{$DataStructureLocation_i+1}:="0"
				
			: ($DataType_i=Is date:K8:7)
				<>Dict_Values_at{$DictionaryID_i}{$DataStructureLocation_i+1}:="0000-00-00"
				
			: ($DataType_i=Is time:K8:8)
				<>Dict_Values_at{$DictionaryID_i}{$DataStructureLocation_i+1}:="00:00:00"
				
		End case 
		
		Dict_SetLongint($DictionaryID_i; $Key_t+".count"; $MaxSize_i+1)
		
		
		
	Else   //  This version is more complicated as we have to renumber all higher elements
		$ElementKeyLabel_t:=$Key_t+"."+String:C10($inLocation_i)  //                                      Get the name of the element we are going to replace (move up)
		$DataStructureLocation_i:=Find in array:C230(<>Dict_Keys_at{$DictionaryID_i}; $ElementKeyLabel_t)  //  Locate it
		$DataType_i:=<>Dict_DataTypes_ai{$DictionaryID_i}{$DataStructureLocation_i}  //                  Get it's data type  
		
		INSERT IN ARRAY:C227(<>Dict_Keys_at{$DictionaryID_i}; $DataStructureLocation_i)  //                    Make room
		INSERT IN ARRAY:C227(<>Dict_Values_at{$DictionaryID_i}; $DataStructureLocation_i)  //                  Make room
		INSERT IN ARRAY:C227(<>Dict_DataTypes_ai{$DictionaryID_i}; $DataStructureLocation_i)  //               Make room
		
		<>Dict_Keys_at{$DictionaryID_i}{$DataStructureLocation_i}:=$Key_t+"."+String:C10($inLocation_i)  // Name it (we now have duplicate names)
		Case of   //                                                                                   Set a default value
			: ($DataType_i=Is boolean:K8:9)
				<>Dict_Values_at{$DictionaryID_i}{$DataStructureLocation_i}:="False"
				
			: ($DataType_i=Is real:K8:4) | ($DataType_i=Is longint:K8:6)
				<>Dict_Values_at{$DictionaryID_i}{$DataStructureLocation_i}:="0"
				
			: ($DataType_i=Is date:K8:7)
				<>Dict_Values_at{$DictionaryID_i}{$DataStructureLocation_i}:="0000-00-00"
				
			: ($DataType_i=Is time:K8:8)
				<>Dict_Values_at{$DictionaryID_i}{$DataStructureLocation_i}:="00:00:00"
				
		End case 
		<>Dict_DataTypes_ai{$DictionaryID_i}{$DataStructureLocation_i}:=$DataType_i  //                  Set it's data type 
		
		Dict_SetLongint($DictionaryID_i; $Key_t+".count"; $MaxSize_i+1)  //                            Now change the count
		
		
		$DataStructureLocation_i:=$DataStructureLocation_i+1  //                                        Increment the location
		$NextTag_t:=<>Dict_Keys_at{$DictionaryID_i}{$DataStructureLocation_i}  //                        Get the next tag
		While ($NextTag_t=($Key_t+".@"))
			$inLocation_i:=$inLocation_i+1  //                                                            Increment the element count
			<>Dict_Keys_at{$DictionaryID_i}{$DataStructureLocation_i}:=$Key_t+"."+String:C10($inLocation_i)  //  Write the value
			$DataStructureLocation_i:=$DataStructureLocation_i+1  //                                      Increment the location
			If ($DataStructureLocation_i<=Size of array:C274(<>Dict_Keys_at{$DictionaryID_i}))  //              Check the array is that large
				$NextTag_t:=<>Dict_Keys_at{$DictionaryID_i}{$DataStructureLocation_i}
			Else 
				$NextTag_t:=""
			End if 
		End while 
		
		
		
		
		
	End if 
	
	
	
End if 
Dict_LockInternalState(False:C215)