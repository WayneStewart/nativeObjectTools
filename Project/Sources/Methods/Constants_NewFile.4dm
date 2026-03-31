//%attributes = {"invisible":true,"shared":false}
///*
//Constants methods by Cannon Smith
//https:  //www.synergyfarmsolutions.com
//*/

// Access: Private

#DECLARE($fileName_t : Text)

Compiler_Constants()  // Make certain all variable declared before we start work

If ($fileName_t#"@.xlf")  //Should end in ".xlf"
	ALERT:C41(Current method name:C684+"\nThe file name should end in \".xlf\"")
Else 
	vtCC_Filename:=$fileName_t
	//Create the XML document with the xliff root
	vtCC_XMLTopLevelRef:=DOM Create XML Ref:C861("xliff"; ""; \
		"version"; "1.0"; \
		"xmlns:d4"; "http://www.4d.com/d4-ns")
	
	//Create the file node
	vtCC_XMLFileRef:=DOM Create XML element:C865(vtCC_XMLTopLevelRef; "file"; \
		"datatype"; "x-4DK#"; \
		"original"; "x-undefined"; \
		"source-language"; "x-none"; \
		"target-language"; "x-none")
	
	//Create the body node
	vtCC_XMLBodyRef:=DOM Create XML element:C865(vtCC_XMLFileRef; "body")
	
	//Create the groups labels node
	vtCC_XMLGroupsRef:=DOM Create XML element:C865(vtCC_XMLBodyRef; "group"; \
		"resname"; "themes")
	
	vlCC_CurrentGroupNumber:=0
	vlCC_CurrentConstantNumber:=0
End if 