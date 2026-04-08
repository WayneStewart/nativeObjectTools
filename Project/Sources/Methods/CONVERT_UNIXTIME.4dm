//%attributes = {}
C_LONGINT:C283($1; $UNIXTIME)
C_OBJECT:C1216($0; $timeObj)

$UNIXTIME:=$1

C_DATE:C307($date)
C_TIME:C306($time)

$date:=Add to date:C393(!1970-01-01!; 0; 0; $UNIXTIME\86400)
$time:=Time:C179($UNIXTIME%86400)

$datetime:=String:C10($date; ISO date:K1:8; $time)+"Z"

$UTC:=New object:C1471("date"; $date; "time"; $time; "datetime"; $datetime)

$date:=Date:C102($datetime)
$time:=Time:C179($datetime)

$datetime:=String:C10($date; ISO date:K1:8; $time)

$date:=Date:C102($datetime)
$time:=Time:C179($datetime)

$LOCAL:=New object:C1471("date"; $date; "time"; $time; "datetime"; $datetime)

$timeObj:=New object:C1471("UTC"; $UTC; "LOCAL"; $LOCAL)

$0:=$timeObj