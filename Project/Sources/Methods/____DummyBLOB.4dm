//%attributes = {}

var $i : Integer
var $theBlob : Blob
var $path_t; $ts_t; $json_t : Text

$ts_t:=OTr_z_timestampLocal()
$ts_t:=Replace string:C233($ts_t; ":"; "-")
$ts_t:=Replace string:C233($ts_t; "/"; "-")
$ts_t:=Substring:C12($ts_t; 1; 19)

$i:=OT New
OT PutText($i; "Name"; "Wayne")

OT PutDate($i; "birthday"; !1863-06-22!)

ARRAY TEXT:C222($children_at; 0)

APPEND TO ARRAY:C911($children_at; "Kirsty")
APPEND TO ARRAY:C911($children_at; "Andrew")
APPEND TO ARRAY:C911($children_at; "Penny")
APPEND TO ARRAY:C911($children_at; "Alice")

OT PutArray($i; "Children"; $children_at)

$theBlob:=OT ObjectToNewBLOB($i)

$path_t:=Get 4D folder:C485(Database folder:K5:14)
$path_t:=$path_t+"Examples"+Folder separator:K24:12+"Blobs"+Folder separator:K24:12
$path_t:=$path_t+"OT "+$ts_t+".blob"

BLOB TO DOCUMENT:C526($path_t; $theBlob)
//

OT Clear($i)

$i:=OTr_New
OTr_PutText($i; "Name"; "Wayne")

OTr_PutDate($i; "birthday"; !1863-06-22!)

ARRAY TEXT:C222($children_at; 0)

APPEND TO ARRAY:C911($children_at; "Kirsty")
APPEND TO ARRAY:C911($children_at; "Andrew")
APPEND TO ARRAY:C911($children_at; "Penny")
APPEND TO ARRAY:C911($children_at; "Alice")

OTr_PutArray($i; "Children"; ->$children_at)

$theBlob:=OTr_ObjectToNewBLOB($i)

$path_t:=Get 4D folder:C485(Database folder:K5:14)
$path_t:=$path_t+"Examples"+Folder separator:K24:12+"Blobs"+Folder separator:K24:12
$path_t:=$path_t+"OTr_"+$ts_t+".blob"

BLOB TO DOCUMENT:C526($path_t; $theBlob)
$json_t:=Replace string:C233($path_t; ".blob"; ".json")

OTr_SaveToFile($i; $json_t)
SHOW ON DISK:C922($path_t)

OTr_Clear($i)