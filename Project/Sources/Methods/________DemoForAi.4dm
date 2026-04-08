//%attributes = {"invisible":true}
//Function calcTimeZoneDiff  //  offset between myTime (or value) and GMT.
C_TIME:C306($mycTimeh)
C_REAL:C285($diff_r)
C_LONGINT:C283($diffInSeconds_i)
$mycTimeh:=Current time:C178


$diff_r:=(($mycTimeh)-((Time:C179(Substring:C12(String:C10(Current date:C33; ISO date GMT:K1:10; $mycTimeh); 12; 19)))))/(60*60)


$diffInSeconds_i:=$diff_r*3600

