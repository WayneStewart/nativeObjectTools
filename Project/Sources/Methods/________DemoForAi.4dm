//%attributes = {"invisible":true}
CONVERT FROM TEXT:C1011($tJSONValue; "US-ASCII"; $xBlob)
BASE64 DECODE:C896($xBlob)
BLOB TO PICTURE:C682($xBlob; $gValue; $tCodec)