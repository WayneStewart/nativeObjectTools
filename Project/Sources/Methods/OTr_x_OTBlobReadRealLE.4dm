//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_x_OTBlobReadRealLE (inBlob; ioOffset) --> Real

// Reads an IEEE-754 binary64 value stored little-endian in a legacy
// ObjectTools BLOB and advances ioOffset by 8 bytes.
//
// Access: Private
//
// Parameters:
//   $inBlob_blob  : Blob    : Legacy ObjectTools object BLOB
//   $ioOffset_ptr : Pointer : Current read offset, advanced by 8 bytes
//
// Returns:
//   $value_r : Real : Decoded IEEE-754 binary64 value
//
// Created by Wayne Stewart / Codex, 2026-04-16
// Wayne Stewart / Codex, 2026-04-16 - Added little-endian real decoder for OT
//   record payloads.
// ----------------------------------------------------

#DECLARE($inBlob_blob : Blob; $ioOffset_ptr : Pointer)->$value_r : Real

OTr_z_AddToCallStack(Current method name:C684)

var $b0_i; $b1_i; $b2_i; $b3_i; $b4_i; $b5_i; $b6_i; $b7_i : Integer
var $sign_r; $mantissa_r; $factor_r : Real
var $exponent_i; $power_i; $i_i : Integer

$value_r:=0

If ($ioOffset_ptr#Null)
	If (($ioOffset_ptr->+7)<BLOB size($inBlob_blob))
		$b0_i:=$inBlob_blob{$ioOffset_ptr->+7}
		$b1_i:=$inBlob_blob{$ioOffset_ptr->+6}
		$b2_i:=$inBlob_blob{$ioOffset_ptr->+5}
		$b3_i:=$inBlob_blob{$ioOffset_ptr->+4}
		$b4_i:=$inBlob_blob{$ioOffset_ptr->+3}
		$b5_i:=$inBlob_blob{$ioOffset_ptr->+2}
		$b6_i:=$inBlob_blob{$ioOffset_ptr->+1}
		$b7_i:=$inBlob_blob{$ioOffset_ptr->}
		
		If ($b0_i>=128)
			$sign_r:=-1
			$b0_i:=$b0_i-128
		Else
			$sign_r:=1
		End if
		
		$exponent_i:=($b0_i*16)+($b1_i\16)
		$mantissa_r:=(($b1_i%16)*281474976710656) \
			+($b2_i*1099511627776) \
			+($b3_i*4294967296) \
			+($b4_i*16777216) \
			+($b5_i*65536) \
			+($b6_i*256) \
			+$b7_i
		
		If ($exponent_i=0)
			$value_r:=0
		Else
			$value_r:=$sign_r*(1+($mantissa_r/4503599627370496))
			$power_i:=$exponent_i-1023
			$factor_r:=1
			If ($power_i>0)
				For ($i_i; 1; $power_i)
					$factor_r:=$factor_r*2
				End for
			Else
				If ($power_i<0)
					For ($i_i; 1; 0-$power_i)
						$factor_r:=$factor_r/2
					End for
				End if
			End if
			$value_r:=$value_r*$factor_r
		End if
		
		$ioOffset_ptr->:=$ioOffset_ptr->+8
	End if
End if

OTr_z_RemoveFromCallStack(Current method name:C684)
