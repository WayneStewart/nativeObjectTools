//%attributes = {"invisible":true}



#DECLARE($method_t : Text)->$exists_b : Boolean

ARRAY TEXT:C222($wombat_at; 0)
METHOD GET NAMES:C1166($wombat_at; $method_t)

$exists_b:=(Size of array:C274($wombat_at)=1)

