//%attributes = {"invisible":true}
////Function calcTimeZoneDiff  //  offset between myTime (or value) and GMT.
//C_TIME($mycTimeh)
//C_REAL($diff_r)
//C_LONGINT($diffInSeconds_i)
//$mycTimeh:=Current time


//$diff_r:=(($mycTimeh)-((Time(Substring(String(Current date; ISO date GMT; $mycTimeh); 12; 19)))))/(60*60)


//$diffInSeconds_i:=$diff_r*3600

$time_GMT_t:=Timestamp:C1445
$ms:=Substring:C12($time_GMT_t)
C_OBJECT:C1216($time_o)

$time_o:=current_UnixTime($time_GMT_t)

$time_o:=CONVERT_UNIXTIME($time_o.timestamp)

$time_Local_t:=$time_o.LOCAL.datetime
