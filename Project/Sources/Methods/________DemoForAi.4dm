//%attributes = {"invisible":true}
//$o:=New object()

//$o.arrayName:=""

var $hObj_i; $size : Integer

ARRAY TEXT:C222($days_at; 7)

$days_at{1}:="Sunday"
$days_at{2}:="Monday"
$days_at{3}:="Tuesday"
$days_at{4}:="Wednesday"
$days_at{5}:="Thursday"
$days_at{6}:="Friday"
$days_at{7}:="Saturday"


$hObj_i:=OTr_New
OTr_PutArray($hObj_i; "All.Days"; ->$days_at)

$size:=OTr_SizeOfArray($hObj_i; "All.Days")

OTr_ResizeArray($hObj_i; "All.Days"; 10)  // Metric days

ARRAY TEXT:C222($metricdays_at; 0)

OTr_SaveToClipboard($hObj_i; True:C214)
OTr_Clear($hObj_i)

