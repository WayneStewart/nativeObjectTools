If (Records in table:C83([Demo:1])=0)
	CREATE RECORD:C68([Demo:1])
	[Demo:1]demoField:2:=String:C10(Timestamp:C1445)
	SAVE RECORD:C53([Demo:1])
	UNLOAD RECORD:C212([Demo:1])
End if 