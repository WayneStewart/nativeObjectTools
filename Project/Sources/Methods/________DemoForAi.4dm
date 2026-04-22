//%attributes = {"invisible":true}
var $repoRoot_t; $compiledCodePath_t : Text
var $options_o; $result_o : Object

$compiledCodePath_t:=Get 4D folder:C485(Database folder:K5:14)+"Project"+Folder separator:K24:12+"DerivedData"+Folder separator:K24:12+"CompiledCode"+Folder separator:K24:12
If (Test path name:C476($compiledCodePath_t)=Is a folder:K24:2)
	LOG Build Log(Current method name:C684; "CompiledCode folder exists")
	DELETE FOLDER:C693($compiledCodePath_t; Delete with contents:K24:24)
	LOG Build Log(Current method name:C684; "CompiledCode cleared"; "OK = "+String:C10(OK); "Error = "+String:C10(Error))
End if 


$options_o:=New object:C1471
$options_o.targets:=New collection:C1472("arm64_macOS_lib"; "x86_64_generic")
LOG Build Log(Current method name:C684; "Compile start")
$result_o:=Compile project:C1760($options_o)
LOG Build Log(Current method name:C684; "Compile done"; "success"; String:C10(Num:C11($result_o.success)))

//MARK: Clear compiled code between passes
