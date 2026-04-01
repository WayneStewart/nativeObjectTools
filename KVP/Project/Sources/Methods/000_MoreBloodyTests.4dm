//%attributes = {"invisible":true}
//  // 000_MoreBloodyTests
//  // Created by Wayne Stewart (Sep 4, 2012)
//  //  Method is an autostart type
//  //     waynestewart@mac.com
//
//C_LONGINT($1;$ProcessID_i)
//
//If (False)  //  Copy this to your Compiler Method!
//C_LONGINT(000_MoreBloodyTests ;$1)
//End if 
//
//If (Count parameters=1)
//
//HIDE PROCESS(Current process)
//
//  //KVP_New ("Comms")
//  //KVP_Text ("Comms.IP Address";"www.example.com")
//  //KVP_Long ("Comms.Port";8080)
//KVP_Long ("*.ConnectionID";47)
//  //KVP_SetChild ("*";"Comms")
//  //ALERT(String(KVP_Long ("*.Comms.Port")))
//PAUSE PROCESS(Current process)
//
//
//  //Dict_APD_Cleanup (True)
//
//  //TRACE
//
//  //ALERT(KVP_Text ("*."+$Kirsty_t+".Child"))
//
//  //KVP_Release ("*")//  Fail to release the APD
//
//  //KVP_Release ("Comms")
//Else 
//  // This version allows for any number of processes
//   $ProcessID_i:=New Process(Current method name;128*1024;Current method name;0)
//  // This version allows for one unique process
//  //$ProcessID_i:=New process(Current method name;128*1024;Current method name;0;*)
//  //RESUME PROCESS($ProcessID_i)
//  //SHOW PROCESS($ProcessID_i)
//  //BRING TO FRONT($ProcessID_i)
//End if 
//
