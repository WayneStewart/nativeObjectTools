//%attributes = {"invisible":true,"folder":"Util","lang":"en"}
If (Storage.sched=Null)
Else 
	Use (Storage.sched)
		Storage.sched.quitNow:=True
	End use 
End if 