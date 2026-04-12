//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTr_z_Koala --> Picture

// Returns a picture of a Koala

// Access: Private

// Returns: 
//   $Koala_pic : Picture : A small picture of a young Koala


// Created by Wayne Stewart (2026-04-05)
// ----------------------------------------------------

#DECLARE()->$Koala_pic : Picture

READ PICTURE FILE:C678(Get 4D folder:C485(Current resources folder:K5:16)+"images"+Folder separator:K24:12+"Koala.png"; $Koala_pic)