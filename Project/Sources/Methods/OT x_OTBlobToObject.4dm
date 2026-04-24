//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OT x_OTBlobToObject (inBlob) --> Object

// Converts a source-defined ObjectTools v3 object BLOB into native OTr
// object storage shape.
//
// Access: Private
//
// Parameters:
//   $inBlob_blob : Blob : Legacy ObjectTools object BLOB
//
// Returns:
//   $result_o : Object : Native OTr object storage shape, or Null on failure
//
// Created by Wayne Stewart / Codex, 2026-04-19
// ----------------------------------------------------

#DECLARE($inBlob_blob : Blob)->$result_o : Object

OTr_z_AddToCallStack(Current method name:C684)

var $offset_i; $version_i; $rootType_i; $itemCount_i; $item_i : Integer
var $keyLen_i; $typeByte_i; $textLen_i; $count_i; $index_i : Integer
var $descriptorStart_i; $payloadStart_i; $payloadOffset_i; $elementLen_i : Integer
var $key_t; $value_t : Text
var $array_o : Object
var $ok_b; $compact_b : Boolean

$result_o:=Null:C1517
$ok_b:=False:C215

If (BLOB size:C605($inBlob_blob)>=21)
	If (($inBlob_blob{0}=255) & ($inBlob_blob{1}=255) \
		 & ($inBlob_blob{4}=79) & ($inBlob_blob{5}=98) & ($inBlob_blob{6}=106) & ($inBlob_blob{7}=101) \
		 & ($inBlob_blob{8}=99) & ($inBlob_blob{9}=116) & ($inBlob_blob{10}=115) & ($inBlob_blob{11}=33))
		
		$compact_b:=($inBlob_blob{14}=7) & ($inBlob_blob{15}=1)
		
		If ($compact_b)
			$offset_i:=14
			OT x_OTBlobReadUInt16LE($inBlob_blob; ->$offset_i)
			$rootType_i:=OT x_OTBlobReadUInt32LE($inBlob_blob; ->$offset_i)
			$itemCount_i:=OT x_OTBlobReadUInt32LE($inBlob_blob; ->$offset_i)
			
			If (($rootType_i=OT Is Object) & ($itemCount_i>=0))
				$result_o:=New object:C1471
				$ok_b:=True:C214
				$item_i:=1
				
				While (($item_i<=$itemCount_i) & ($ok_b))
					If ($offset_i>=BLOB size:C605($inBlob_blob))
						$ok_b:=False:C215
					Else 
						$keyLen_i:=$inBlob_blob{$offset_i}
						$offset_i:=$offset_i+1
						$key_t:=""
						If (($keyLen_i<=0) | (($offset_i+$keyLen_i)>BLOB size:C605($inBlob_blob)))
							$ok_b:=False:C215
						Else 
							For ($index_i; 1; $keyLen_i)
								$key_t:=$key_t+Char:C90($inBlob_blob{$offset_i})
								$offset_i:=$offset_i+1
							End for 
						End if 
					End if 
					
					If ($ok_b)
						$typeByte_i:=$inBlob_blob{$offset_i}
						$offset_i:=$offset_i+1
						
						Case of 
							: ($typeByte_i=2)
								If (($offset_i+2)<BLOB size:C605($inBlob_blob))
									$offset_i:=$offset_i+2
									$textLen_i:=$inBlob_blob{$offset_i}
									$offset_i:=$offset_i+1
									If (($offset_i+$textLen_i)<=BLOB size:C605($inBlob_blob))
										$value_t:=""
										For ($index_i; 1; $textLen_i)
											$value_t:=$value_t+Char:C90($inBlob_blob{$offset_i})
											$offset_i:=$offset_i+1
										End for 
										OB SET:C1220($result_o; $key_t; $value_t)
										OB SET:C1220($result_o; OTr_z_ShadowKey($key_t); OT Is Character)
									Else 
										$ok_b:=False:C215
									End if 
								Else 
									$ok_b:=False:C215
								End if 
								
							: ($typeByte_i=18)
								If (($offset_i+5)<BLOB size:C605($inBlob_blob))
									$offset_i:=$offset_i+4
									$count_i:=$inBlob_blob{$offset_i}
									$offset_i:=$offset_i+1
									$descriptorStart_i:=$offset_i+17
									$payloadStart_i:=$descriptorStart_i+($count_i*6)-1
									$payloadOffset_i:=$payloadStart_i
									
									If (($descriptorStart_i>=0) & ($payloadStart_i<=BLOB size:C605($inBlob_blob)))
										$array_o:=New object:C1471("arrayType"; Text array:K8:16; "numElements"; $count_i; "currentItem"; 0; "0"; "")
										For ($index_i; 1; $count_i)
											If (($descriptorStart_i+(($index_i-1)*6))<BLOB size:C605($inBlob_blob))
												$elementLen_i:=$inBlob_blob{$descriptorStart_i+(($index_i-1)*6)}
												If (($payloadOffset_i+$elementLen_i)<=BLOB size:C605($inBlob_blob))
													$value_t:=""
													While ($elementLen_i>0)
														$value_t:=$value_t+Char:C90($inBlob_blob{$payloadOffset_i})
														$payloadOffset_i:=$payloadOffset_i+1
														$elementLen_i:=$elementLen_i-1
													End while 
													OB SET:C1220($array_o; String:C10($index_i); $value_t)
												Else 
													$ok_b:=False:C215
												End if 
											Else 
												$ok_b:=False:C215
											End if 
										End for 
										
										If ($ok_b)
											OB SET:C1220($result_o; $key_t; $array_o)
											$offset_i:=$payloadOffset_i
										End if 
									Else 
										$ok_b:=False:C215
									End if 
								Else 
									$ok_b:=False:C215
								End if 
								
							Else 
								$ok_b:=False:C215
						End case 
						
						If (($ok_b) & ($item_i<$itemCount_i))
							While (($offset_i<BLOB size:C605($inBlob_blob)) & ($inBlob_blob{$offset_i}=0))
								$offset_i:=$offset_i+1
							End while 
						End if 
					End if 
					
					$item_i:=$item_i+1
				End while 
			End if 
			
		Else 
			$offset_i:=12
			$version_i:=OT x_OTBlobReadUInt32BE($inBlob_blob; ->$offset_i)
			
			If ($version_i=4352)  // 0x1100
				$rootType_i:=$inBlob_blob{$offset_i}
				$offset_i:=$offset_i+1
				
				If ($rootType_i=OT Is Object)
					$itemCount_i:=OT x_OTBlobReadUInt32BE($inBlob_blob; ->$offset_i)
					If ($itemCount_i>=0)
						$result_o:=OT x_OTBlobReadObjectItems($inBlob_blob; ->$offset_i; $itemCount_i)
						$ok_b:=($result_o#Null:C1517)
					End if 
				End if 
			End if 
		End if 
	End if 
End if 

If (Not:C34($ok_b))
	$result_o:=Null:C1517
End if 

OTr_z_RemoveFromCallStack(Current method name:C684)
