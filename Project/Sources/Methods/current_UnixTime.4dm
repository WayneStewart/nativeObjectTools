//%attributes = {}
C_OBJECT:C1216($0; $timeObj)

$timestamp:=Timestamp:C1445

ARRAY LONGINT:C221($pos; 0)
ARRAY LONGINT:C221($len; 0)

If (Match regex:C1019("((\\d{4})-(\\d{2})-(\\d{2}))T(\\d{2}:\\d{2}:\\d{2})\\.(\\d{3})Z"; $timestamp; 1; $pos; $len))
	
	C_DATE:C307($date)
	$date:=Date:C102(Substring:C12($timestamp; $pos{1}; $len{1}))
	
	C_LONGINT:C283($yyyy; $mm; $dd)
	$yyyy:=Num:C11(Substring:C12($timestamp; $pos{2}; $len{2}))
	$mm:=Num:C11(Substring:C12($timestamp; $pos{3}; $len{3}))
	$dd:=Num:C11(Substring:C12($timestamp; $pos{4}; $len{4}))
	
	$daysInFeb:=Day of:C23(Add to date:C393(Add to date:C393(!00-00-00!; $yyyy; 3; 1); 0; 0; -1))
	
	Case of 
		: ($mm=1)
			
		: ($mm=2)
			$dd:=$dd+31  //daysInJan
		: ($mm=3)
			$dd:=$dd+31+$daysInFeb
		: ($mm=4)
			$dd:=$dd+62+$daysInFeb  //daysInMar
		: ($mm=5)
			$dd:=$dd+92+$daysInFeb  //daysInApr
		: ($mm=6)
			$dd:=$dd+123+$daysInFeb  //daysInMay
		: ($mm=7)
			$dd:=$dd+153+$daysInFeb  //daysInJun
		: ($mm=8)
			$dd:=$dd+184+$daysInFeb  //daysInJul
		: ($mm=9)
			$dd:=$dd+215+$daysInFeb  //daysInAug
		: ($mm=10)
			$dd:=$dd+245+$daysInFeb  //daysInSep
		: ($mm=11)
			$dd:=$dd+276+$daysInFeb  //daysInOct
		: ($mm=12)
			$dd:=$dd+306+$daysInFeb  //daysInNov
	End case 
	
	$time:=(0+Time:C179(Substring:C12($timestamp; $pos{5}; $len{5})))
	$time:=$time+(($dd-1)*86400)  //days until yesterday + seconds today
	$time:=$time+(($yyyy-1970)*31536000)  //years until last year
	$time:=$time+((($yyyy-1968)\4)*86400)  //number of february 29ths until last year
	
	$timeObj:=New object:C1471("timestamp"; $time; "ms"; Num:C11(Substring:C12($timestamp; $pos{6}; $len{6})))
	
End if 

$0:=$timeObj