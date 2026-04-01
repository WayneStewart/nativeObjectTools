//%attributes = {"invisible":true}
//  //Hi Wayne,
//  //You might find this little method interesting. It loops through all of the
//  //methods in your database and moves any comments in the method to the
//  //Comment pane. This includes any bracketed by the if(False)Begin SQL
//  //method for writing long comment blocks. Finally it deletes the << escapes
//  //at the beginning of comment lines. The result looks nicer.
//  //
//  //Obviously you don't want to run this if you have spent time creating
//  //Comments in the Comment Pane which differ from anything you put in your
//  //code. I never do that. I am getting into the habit of putting more notes in
//  //the SQL bracket area though.
//  //
//  //Here's a benefit/bug about doing this: the comments in the Comment Pane, if
//  //they exist, are what appear when you hover the mouse over a method in the
//  //method editor. And they do this in their entirety. So this allows you much
//  //longer tips in the method editor. The disadvantage is if you change
//  //anything it doesn't reflect until you change the comments.
//  //
//  //You can run it any time and it updates open methods.
//
//  //  DEV_WRITE_COMMENTS
//  // Written (OS): Kirk Brooks  Created: 02/21/13, 15:18:40
//  // ------------------
//  // Method: DEV_WRITE_COMMENTS (text)
//  // $1 is a path to a method
//  // Purpose: get the method code, read from the top and
//  // assume any commented line is a comment.
//
//C_TEXT($1)
//C_TEXT($2)
//
//C_BOOLEAN($OK)
//C_DATE($modDate)
//C_LONGINT($i;$n;$prog_id)
//C_TIME($modTime)
//C_TEXT($code;$comments;$group1;$line;$path;$pattern)
//
//ARRAY LONGINT($aLength;0)
//ARRAY LONGINT($aPos;0)
//ARRAY TEXT($arPaths;0)
//ARRAY TEXT($aTxt;0)
//
//Case of 
//: (Is compiled mode)
//ALERT("You may only run this method uncompiled.")
//
//: (Count parameters=0)  // do all methods
//Dev_Write_Comments ("all_methods")
//
//: ($1="write")  // $2 is the method to update
//
//$path:=$2
//
//METHOD GET CODE($path;$code)  // code of a single method
//
//  // --------------------------------------------------------
//  // ... is there a long comment in SQL brackets? ..........
//  // --------------------------------------------------------
//$pattern:="(?sm)/\\*(.*)\\*/(?-sm)"
//
//If (Match regex($pattern;$code;1;$aPos;$aLength))
//$group1:=Substring($code;$aPos{1};$aLength{1})
//
//End if 
//
//$OK:=True
//  // read through the code until we hit a line of actual code
//
//While (Length($code)>10) & ($ok)
//$line:=STR_Chomp(->$code;"\r")  // get the next line
//
//Case of 
//: ($line="//@")  // line starts with //
//APPEND TO ARRAY($aTxt;Replace string($line;"//";""))  // strip the //
//
//: (Position("\r";$code)=0)
//$ok:=False
//
//: ($line="\r") | ($line="")  // empty line
//  // nothing
//Else 
//$ok:=False
//End case 
//
//End while 
//
//If (Size of array($aTxt)>0) | ($group1#"")
//  // is the first line the reserved comment?
//If ($aTxt{1}="%@")
//DELETE FROM ARRAY($aTxt;1)
//End if 
//
//  // set the text to the comments
//For ($i;1;Size of array($aTxt))
//
//  // we expect every line to start with a space
//Case of 
//: (Length($aTxt{$i})=0)
//
//: ($aTxt{$i}[[1]]#" ")
//$aTxt{$i}:=" "+$aTxt{$i}
//End case 
//
//Case of 
//: (Length($aTxt{$i})<2)
//
//: ($aTxt{$i}[[2]]="$")  // line start with $ - this is probably a parameter
//$comments:=$comments+"  "+$aTxt{$i}+"\r"
//
//Else   // just add it to the text
//$comments:=$comments+$aTxt{$i}+"\r"
//End case 
//
//End for 
//
//  // now add any long comments
//If ($group1#"")
//$comments:=$comments+"\r"+$group1
//End if 
//
//  // and add the mod info
//METHOD GET MODIFICATION DATE($path;$modDate;$modTime)
//$comments:=$comments+"\rModified: "+String($modDate;System date short)+""+String($modTime;HH MM AM PM)
//
//METHOD SET COMMENTS($path;$comments)
//
//End if 
//
//  // SET TEXT TO PASTEBOARD($comments)
//Else   // $1 is a filter for some methods
//  // --------------------------------------------------------
//  // .......... get list of methods ..........
//  // --------------------------------------------------------
//METHOD GET PATHS(Path All objects;$arPaths)
//$pattern:="(?i)"+$1+"(?-i)"
//
//  // --------------------------------------------------------
//  // .......... run through the methods ..........
//  // --------------------------------------------------------
//$prog_id:=Progress New 
//
//$n:=Size of array($arPaths)
//
//
//For ($i;1;$n)
//Progress SET TITLE ($prog_id;"Updating comments...";$i/$n;$arPaths{$i})
//If ($1="all_methods") | (Match regex($pattern;$arPaths{$i};1))
//
//Dev_Write_Comments ("write";$arPaths{$i})
//
//End if 
//End for 
//
//Progress QUIT ($prog_id)
//End case 
//
//  //[End DEV_WRITE_COMMENTS ]