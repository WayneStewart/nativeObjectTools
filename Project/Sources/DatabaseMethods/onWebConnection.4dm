#DECLARE($url_t : Text; $http_t : Text; $ipBrowser_t : Text; $ipServer_t : Text; $user_t : Text; $pw_t : Text)

var $path_t; $method_t; $json_t : Text
var $queryPos_i : Integer
var $response_o : Object

$path_t:=$url_t
$queryPos_i:=Position:C15("?"; $path_t)
If ($queryPos_i>0)
	$path_t:=Substring:C12($path_t; 1; $queryPos_i-1)
End if 

Case of 
	: ($path_t="/codex/ping")
		$response_o:=OTr_w_Run("ping"; $ipBrowser_t)
		
	: (Substring:C12($path_t; 1; 11)="/codex/run/")
		$method_t:=Substring:C12($path_t; 12)
		$response_o:=OTr_w_Run($method_t; $ipBrowser_t)
		
	Else 
		$response_o:=New object:C1471
		$response_o.ok:=False:C215
		$response_o.error:="Not found"
		$response_o.path:=$path_t
		$response_o.routes:=New collection:C1472("/codex/ping"; "/codex/run/OTr_w_compileProject")
End case 

$response_o.path:=$path_t

ARRAY TEXT:C222($headerNames_at; 0)
ARRAY TEXT:C222($headerValues_at; 0)
APPEND TO ARRAY:C911($headerNames_at; "Content-Type")
APPEND TO ARRAY:C911($headerValues_at; "application/json; charset=utf-8")
APPEND TO ARRAY:C911($headerNames_at; "Cache-Control")
APPEND TO ARRAY:C911($headerValues_at; "no-store")
WEB SET HTTP HEADER:C660($headerNames_at; $headerValues_at)

$json_t:=JSON Stringify:C1217($response_o; *)
WEB SEND TEXT:C677($json_t; "application/json")
