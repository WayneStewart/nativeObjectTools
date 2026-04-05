//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTr_z_Wombat --> Picture

// Returns a picture of a Wombat

// Access: Private

// Returns: 
//   $wombat_pic : Picture : A small picture of a young wombat


// Created by Wayne Stewart (2026-04-05)
// ----------------------------------------------------

#DECLARE()->$wombat_pic : Picture

READ PICTURE FILE:C678(Get 4D folder:C485(Current resources folder:K5:16)+"images"+Folder separator:K24:12+"Wombat.png"; $wombat_pic)