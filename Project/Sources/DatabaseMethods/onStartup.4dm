var $appInfo_o : Object
var $userParam_t; $stages_t : Text
var $i : Integer

$appInfo_o:=Get application info

If ($appInfo_o.headless)

	// Headless CI launch — dispatch on --user-param, then quit.
	// Bypass normal OTr initialisation; the build methods do not require it.
	Get database parameter(User param value; $userParam_t)

	If (Position("build"; $userParam_t)>0)
		__BuildComponent_Headless
	End if

	// If no recognised param, fall through to QUIT 4D.
	QUIT 4D

Else

	// Normal interactive launch.
	OTr_onStartup

End if
