//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_Startup

// Initialises the OTr system and writes the opening log entry
//    this is not strictly necessary at startup except we are trying to
//    emulate as closely as possible Object Tools behaviour.

// If logging was not required, I would start the system on the first call 
//    an OTr method.

// Access: Private

// Returns: Nothing

// Created by Wayne Stewart, 2026-04-07
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

OTr_z_Init  // Initialise the system
OTr_z_LogInit  // Initialise the logging


