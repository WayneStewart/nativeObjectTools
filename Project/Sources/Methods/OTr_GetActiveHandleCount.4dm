//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_GetActiveHandleCount () -> outCount

// Returns the number of currently active OTr handles.

// **NOTE:** there is no equivalent Object Tools command

// Access: Shared

// Returns:
//   $outCount_i : Integer : Number of active handles

// Created by Wayne Stewart, 2026-04-10
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE->$outCount_i : Integer

ARRAY LONGINT:C221($handles_ai; 0)
OTr_GetHandleList(->$handles_ai)
$outCount_i:=Size of array:C274($handles_ai)
