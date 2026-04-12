//%attributes = {"invisible":true,"shared":false,"preemptive":"capable","lang":"en"}
// ----------------------------------------------------
// Project Method: OTr_u_EqualObjects ($First_o : Object; $Second_o : Object) --> $IsEqual_b : Boolean

// Compares two objects for deep equality. Returns True if both objects
// contain exactly the same properties, types, and values (including
// nested objects and object arrays). Property order is not significant.

// Access: Private

// Parameters:
//   $First_o  : Object : First object to compare
//   $Second_o : Object : Second object to compare

// Returns:
//   $IsEqual_b : Boolean : True if the objects are identical in structure and value

// Based on work by himself, Rob Laveaux, and Cannon Smith.
// Thanks to Vincent de Lachaux for the original code.

// ----------------------------------------------------

#DECLARE($First_o : Object; $Second_o : Object)->$IsEqual_b : Boolean


$IsEqual_b:=False:C215  //Default to false

C_LONGINT:C283($x; $y; $FirstItemCount_i; $SecondItemCount_i; $FirstPropertyCount_i; $SecondPropertyCount_i)
ARRAY LONGINT:C221($FirstType_ai; 0)
ARRAY TEXT:C222($FirstProperty_at; 0)
ARRAY LONGINT:C221($SecondType_ai; 0)
ARRAY TEXT:C222($SecondProperty_at; 0)

OB GET PROPERTY NAMES:C1232($First_o; $FirstProperty_at; $FirstType_ai)
OB GET PROPERTY NAMES:C1232($Second_o; $SecondProperty_at; $SecondType_ai)
$FirstPropertyCount_i:=Size of array:C274($FirstProperty_at)
$SecondPropertyCount_i:=Size of array:C274($SecondProperty_at)

If ($FirstPropertyCount_i=$SecondPropertyCount_i)  //They won't be equal if they have different property counts
	If ($FirstPropertyCount_i>0)
		//Sort arrays because the properties could be in a different order
		SORT ARRAY:C229($FirstProperty_at; $FirstType_ai)
		SORT ARRAY:C229($SecondProperty_at; $SecondType_ai)
		
		//Now compare each property
		For ($x; 1; $FirstPropertyCount_i)
			
			Case of 
				: (Length:C16($FirstProperty_at{$x})#Length:C16($SecondProperty_at{$x}))  //If the property names aren't the same length
					$IsEqual_b:=False:C215
					
				: (Position:C15($FirstProperty_at{$x}; $SecondProperty_at{$x}; *)#1)  //Check property name (case sensitive)
					$IsEqual_b:=False:C215
					
				: ($FirstType_ai{$x}#$SecondType_ai{$x})  //Check property type
					$IsEqual_b:=False:C215
					
				: ($FirstType_ai{$x}=Is object:K8:27)
					//compare the two objects
					$IsEqual_b:=OTr_u_EqualObjects(\
						OB Get:C1224($First_o; $FirstProperty_at{$x}; Is object:K8:27); \
						OB Get:C1224($Second_o; $FirstProperty_at{$x}; Is object:K8:27))
					
				: ($FirstType_ai{$x}=Object array:K8:28)
					//In an object array we can massage all the array types back into text except object themselves.
					//So we get two sets of arrays, one text and the other objects. Then we can deal with either kind
					//as we walk through each element.
					
					ARRAY OBJECT:C1221($First_ao; 0)  //Reset arrays
					ARRAY TEXT:C222($First_at; 0)
					ARRAY OBJECT:C1221($Second_ao; 0)
					ARRAY TEXT:C222($Second_at; 0)
					OB GET ARRAY:C1229($First_o; $FirstProperty_at{$x}; $First_ao)  //Get text and object types
					OB GET ARRAY:C1229($First_o; $FirstProperty_at{$x}; $First_at)
					OB GET ARRAY:C1229($Second_o; $FirstProperty_at{$x}; $Second_ao)
					OB GET ARRAY:C1229($Second_o; $FirstProperty_at{$x}; $Second_at)
					
					$FirstItemCount_i:=Size of array:C274($First_ao)
					$SecondItemCount_i:=Size of array:C274($Second_ao)
					If ($FirstItemCount_i=$SecondItemCount_i)
						For ($y; 1; $FirstItemCount_i; 1)
							If ((OB Is defined:C1231($First_ao{$y})) & (OB Is defined:C1231($Second_ao{$y})))  //If they are both objects
								$IsEqual_b:=OTr_u_EqualObjects($First_ao{$y}; $Second_ao{$y})
							Else   //Compare text
								$IsEqual_b:=($First_at{$y}=$Second_at{$y})
							End if 
							If ($IsEqual_b=False:C215)
								$y:=$FirstItemCount_i+1  //Abort loop
							End if 
						End for 
					Else 
						$IsEqual_b:=False:C215
					End if 
					
				Else   //For any other object type, we simply compare the values
					$IsEqual_b:=(OB Get:C1224($First_o; $FirstProperty_at{$x})=OB Get:C1224($Second_o; $FirstProperty_at{$x}))
					
			End case 
			
			If ($IsEqual_b=False:C215)
				$x:=$FirstPropertyCount_i+1  //Abort loop
			End if 
			
		End for 
		
	Else   //If there are not elements in either one, they are both equal
		$IsEqual_b:=True:C214
	End if 
End if 

