//%attributes = {"invisible":true}
var $blob_blob : Blob
var $diag_t : Text

DOCUMENT TO BLOB:C525("D:\\4D\\Projects\\nativeObjectTools\\Examples\\Blobs\\Guy\\EX6\\SubRec.blob"; $blob_blob)
$diag_t:=OTr_z_OTBlobDescribeFirstItem($blob_blob)
SET TEXT TO PASTEBOARD:C523($diag_t)
ALERT:C41($diag_t)