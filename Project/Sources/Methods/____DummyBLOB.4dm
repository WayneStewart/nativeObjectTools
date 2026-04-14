//%attributes = {}

//var $i : Integer
//var $theBlob : Blob
//var $path_t; $ts_t; $json_t : Text

//$ts_t:=OTr_z_timestampLocal()
//$ts_t:=Replace string($ts_t; ":"; "-")
//$ts_t:=Replace string($ts_t; "/"; "-")
//$ts_t:=Substring($ts_t; 1; 19)

//$i:=OT New
//OT PutText($i; "Name"; "Wayne")

//OT PutDate($i; "birthday"; !1863-06-22!)

//ARRAY TEXT($children_at; 0)

//APPEND TO ARRAY($children_at; "Kirsty")
//APPEND TO ARRAY($children_at; "Andrew")
//APPEND TO ARRAY($children_at; "Penny")
//APPEND TO ARRAY($children_at; "Alice")

//OT PutArray($i; "Children"; $children_at)

//$theBlob:=OT ObjectToNewBLOB($i)

//$path_t:=Get 4D folder(Database folder)
//$path_t:=$path_t+"Examples"+Folder separator+"Blobs"+Folder separator
//$path_t:=$path_t+"OT "+$ts_t+".blob"

//BLOB TO DOCUMENT($path_t; $theBlob)
////

//OT Clear($i)

//$i:=OTr_New
//OTr_PutText($i; "Name"; "Wayne")

//OTr_PutDate($i; "birthday"; !1863-06-22!)

//ARRAY TEXT($children_at; 0)

//APPEND TO ARRAY($children_at; "Kirsty")
//APPEND TO ARRAY($children_at; "Andrew")
//APPEND TO ARRAY($children_at; "Penny")
//APPEND TO ARRAY($children_at; "Alice")

//OTr_PutArray($i; "Children"; ->$children_at)

//$theBlob:=OTr_ObjectToNewBLOB($i)

//$path_t:=Get 4D folder(Database folder)
//$path_t:=$path_t+"Examples"+Folder separator+"Blobs"+Folder separator
//$path_t:=$path_t+"OTr_"+$ts_t+".blob"

//BLOB TO DOCUMENT($path_t; $theBlob)
//$json_t:=Replace string($path_t; ".blob"; ".json")

//OTr_SaveToFile($i; $json_t)
//SHOW ON DISK($path_t)

//OTr_Clear($i)