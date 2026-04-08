//%attributes = {}

/* 

現在のUNIX時間を返す

*/

C_OBJECT:C1216($time)

$time:=current_UnixTime

ALERT:C41(New collection:C1472($time.timestamp; $time.ms).join("."))

/* 

UNIX時間をローカル日付/時間およびUTC日付時間に変換する

*/

$time:=CONVERT_UNIXTIME($time.timestamp)


