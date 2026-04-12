//%attributes = {"shared":false}
// Access: Private

var $build_t; $buildVersion_t; $version_t : Text


$version_t:=Application version:C493
$buildVersion_t:=$version_t[[1]]+$version_t[[2]]+" LTS"  //version number, e.g. 20


$build_t:=OTr_Info("version")
$build_t:=$build_t+" ("+$buildVersion_t+")"

Fnd_FCS_BuildComponent($build_t)

