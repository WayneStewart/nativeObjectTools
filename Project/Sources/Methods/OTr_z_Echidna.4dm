//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTr_z_echidna --> Picture

// Returns a picture of a echidna

// Access: Private

// Returns: 
//   $echidna_pic : Picture : A small picture of a young echidna


// Created by Wayne Stewart (2026-04-05)
// ----------------------------------------------------

#DECLARE()->$echidna_pic : Picture

READ PICTURE FILE:C678(Get 4D folder:C485(Current resources folder:K5:16)+"images"+Folder separator:K24:12+"Echidna.jpg"; $echidna_pic)