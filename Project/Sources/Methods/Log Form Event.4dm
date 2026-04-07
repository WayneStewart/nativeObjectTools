//%attributes = {"invisible":true,"shared":true}
  // ----------------------------------------------------
  // Project Method: Log Form Event --> Text

  // Returns Form event Code

  // Access: Shared

  // Returns: 
  //   $0 : Type : Description

  // Created by Wayne Stewart (2020-04-24T14:00:00Z)
  //     wayne@4dsupport.guru
  // ----------------------------------------------------

If (False:C215)
	C_TEXT:C284(Log Form Event ;$0)
	
End if 

C_LONGINT:C283($formEventCode_i)
C_TEXT:C284($0)

$formEventCode_i:=Form event code:C388


Case of 
		
	: ($formEventCode_i=1)
		$0:="On Load"
		
	: ($formEventCode_i=2)
		$0:="On Mouse Up"
		
	: ($formEventCode_i=3)
		$0:="On Validate"
		
	: ($formEventCode_i=4)
		$0:="On Clicked"
		
	: ($formEventCode_i=5)
		$0:="On Header"
		
	: ($formEventCode_i=6)
		$0:="On Printing Break"
		
	: ($formEventCode_i=7)
		$0:="On Printing Footer"
		
	: ($formEventCode_i=8)
		$0:="On Display Detail"
		
	: ($formEventCode_i=9)
		$0:="On VP Ready"
		
	: ($formEventCode_i=10)
		$0:="On Outside Call"
		
	: ($formEventCode_i=11)
		$0:="On Activate"
		
	: ($formEventCode_i=12)
		$0:="On Deactivate"
		
	: ($formEventCode_i=13)
		$0:="On Double Clicked"
		
	: ($formEventCode_i=14)
		$0:="On Losing Focus"
		
	: ($formEventCode_i=15)
		$0:="On Getting Focus"
		
	: ($formEventCode_i=16)
		$0:="On Drop"
		
	: ($formEventCode_i=17)
		$0:="On Before Keystroke"
		
	: ($formEventCode_i=18)
		$0:="On Menu Selected"
		
	: ($formEventCode_i=19)
		$0:="On Plug in Area"
		
	: ($formEventCode_i=21)
		$0:="On Drag Over"
		
	: ($formEventCode_i=22)
		$0:="On Close Box"
		
	: ($formEventCode_i=23)
		$0:="On Printing Detail"
		
	: ($formEventCode_i=24)
		$0:="On Unload"
		
	: ($formEventCode_i=25)
		$0:="On Open Detail"
		
	: ($formEventCode_i=26)
		$0:="On Close Detail"
		
	: ($formEventCode_i=27)
		$0:="On Timer"
		
	: ($formEventCode_i=28)
		$0:="On After Keystroke"
		
	: ($formEventCode_i=29)
		$0:="On Resize"
		
	: ($formEventCode_i=30)
		$0:="On After Sort"
		
	: ($formEventCode_i=31)
		$0:="On Selection Change"
		
	: ($formEventCode_i=32)
		$0:="On Column Moved"
		
	: ($formEventCode_i=33)
		$0:="On Column Resize"
		
	: ($formEventCode_i=34)
		$0:="On Row Moved"
		
	: ($formEventCode_i=35)
		$0:="On Mouse Enter"
		
	: ($formEventCode_i=36)
		$0:="On Mouse Leave"
		
	: ($formEventCode_i=37)
		$0:="On Mouse Move"
		
	: ($formEventCode_i=38)
		$0:="On Alternative Click"
		
	: ($formEventCode_i=39)
		$0:="On Long Click"
		
	: ($formEventCode_i=40)
		$0:="On Load Record"
		
	: ($formEventCode_i=41)
		$0:="On Before Data Entry"
		
	: ($formEventCode_i=42)
		$0:="On Header Click"
		
	: ($formEventCode_i=43)
		$0:="On Expand"
		
	: ($formEventCode_i=44)
		$0:="On Collapse"
		
	: ($formEventCode_i=45)
		$0:="On After Edit"
		
	: ($formEventCode_i=46)
		$0:="On Begin Drag Over"
		
	: ($formEventCode_i=47)
		$0:="On Begin URL Loading"
		
	: ($formEventCode_i=48)
		$0:="On URL Resource Loading"
		
	: ($formEventCode_i=49)
		$0:="On End URL Loading"
		
	: ($formEventCode_i=50)
		$0:="On URL Loading Error"
		
	: ($formEventCode_i=51)
		$0:="On URL Filtering"
		
	: ($formEventCode_i=52)
		$0:="On Open External Link"
		
	: ($formEventCode_i=53)
		$0:="On Window Opening Denied"
		
	: ($formEventCode_i=54)
		$0:="On bound variable change"
		
	: ($formEventCode_i=56)
		$0:="On Page Change"
		
	: ($formEventCode_i=57)
		$0:="On Footer Click"
		
	: ($formEventCode_i=58)
		$0:="On Delete Action"
		
	: ($formEventCode_i=59)
		$0:="On Scroll"
		
	: ($formEventCode_i=60)
		$0:="On Row Resize"
		
	Else 
		
		$0:="Unknown Form Event"
		
End case 