//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTr_w_RestartProjectWorker
//
// Gives the HTTP bridge a moment to send its JSON response, then asks
// the main process to restart 4D.
// ----------------------------------------------------

DELAY PROCESS:C323(Current process:C322; 60)
CALL WORKER:C1389(1; "util_restartProject")
