//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTr_u_EqualBLOBs ($blobOne_blob : Blob; \
//   $blobTwo_blob : Blob) --> $isEqual_b : Boolean

// Compares two BLOB values for equality.
// Empty BLOBs are considered equal. Different sizes are not equal.
// For equal non-zero sizes, MD5 digests are compared.

// Access: Private

// Parameters:
//   $blobOne_blob : Blob : First BLOB to compare
//   $blobTwo_blob : Blob : Second BLOB to compare

// Returns:
//   $isEqual_b : Boolean : True if BLOBs are equal, otherwise False

// Created by Wayne Stewart, 2026-04-01

// ----------------------------------------------------

#DECLARE($blobOne_blob : Blob; $blobTwo_blob : Blob)->$isEqual_b : Boolean

var $sizeOfBlobOne_i; $sizeOfBlobTwo_i : Integer

$isEqual_b:=False:C215

$sizeOfBlobOne_i:=BLOB size:C605($blobOne_blob)
$sizeOfBlobTwo_i:=BLOB size:C605($blobTwo_blob)

Case of 
	: ($sizeOfBlobOne_i=0) & ($sizeOfBlobTwo_i=0)  // Both empty Blobs
		$isEqual_b:=True:C214
		
	: ($sizeOfBlobOne_i#$sizeOfBlobTwo_i)  // Different Size Blobs
		
	Else 
		// Save the most time consuming test until last
		$isEqual_b:=(Generate digest:C1147($blobOne_blob; MD5 digest:K66:1)=Generate digest:C1147($blobTwo_blob; MD5 digest:K66:1))
		
End case 