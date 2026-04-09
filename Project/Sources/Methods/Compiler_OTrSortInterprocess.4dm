//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: Compiler_OTrSortInterprocess

// Declares interprocess-scope scratch arrays used by
// OT SortArrays (MULTI SORT ARRAY approach).
// One shared copy across all processes.
//
// 7 sort slots x 6 types = 42 arrays + 1 index = 43 total.
//
// Wayne Stewart, 2026-04-02 - Created for memory footprint test.
// ----------------------------------------------------

// --- Slot 1 ---
ARRAY TEXT:C222(<>OTR_Sort1_at; 0)
ARRAY LONGINT:C221(<>OTR_Sort1_ai; 0)
ARRAY REAL:C219(<>OTR_Sort1_ar; 0)
ARRAY DATE:C224(<>OTR_Sort1_ad; 0)
ARRAY TIME:C1223(<>OTR_Sort1_ah; 0)
ARRAY BOOLEAN:C223(<>OTR_Sort1_ab; 0)

// --- Slot 2 ---
ARRAY TEXT:C222(<>OTR_Sort2_at; 0)
ARRAY LONGINT:C221(<>OTR_Sort2_ai; 0)
ARRAY REAL:C219(<>OTR_Sort2_ar; 0)
ARRAY DATE:C224(<>OTR_Sort2_ad; 0)
ARRAY TIME:C1223(<>OTR_Sort2_ah; 0)
ARRAY BOOLEAN:C223(<>OTR_Sort2_ab; 0)

// --- Slot 3 ---
ARRAY TEXT:C222(<>OTR_Sort3_at; 0)
ARRAY LONGINT:C221(<>OTR_Sort3_ai; 0)
ARRAY REAL:C219(<>OTR_Sort3_ar; 0)
ARRAY DATE:C224(<>OTR_Sort3_ad; 0)
ARRAY TIME:C1223(<>OTR_Sort3_ah; 0)
ARRAY BOOLEAN:C223(<>OTR_Sort3_ab; 0)

// --- Slot 4 ---
ARRAY TEXT:C222(<>OTR_Sort4_at; 0)
ARRAY LONGINT:C221(<>OTR_Sort4_ai; 0)
ARRAY REAL:C219(<>OTR_Sort4_ar; 0)
ARRAY DATE:C224(<>OTR_Sort4_ad; 0)
ARRAY TIME:C1223(<>OTR_Sort4_ah; 0)
ARRAY BOOLEAN:C223(<>OTR_Sort4_ab; 0)

// --- Slot 5 ---
ARRAY TEXT:C222(<>OTR_Sort5_at; 0)
ARRAY LONGINT:C221(<>OTR_Sort5_ai; 0)
ARRAY REAL:C219(<>OTR_Sort5_ar; 0)
ARRAY DATE:C224(<>OTR_Sort5_ad; 0)
ARRAY TIME:C1223(<>OTR_Sort5_ah; 0)
ARRAY BOOLEAN:C223(<>OTR_Sort5_ab; 0)

// --- Slot 6 ---
ARRAY TEXT:C222(<>OTR_Sort6_at; 0)
ARRAY LONGINT:C221(<>OTR_Sort6_ai; 0)
ARRAY REAL:C219(<>OTR_Sort6_ar; 0)
ARRAY DATE:C224(<>OTR_Sort6_ad; 0)
ARRAY TIME:C1223(<>OTR_Sort6_ah; 0)
ARRAY BOOLEAN:C223(<>OTR_Sort6_ab; 0)

// --- Slot 7 ---
ARRAY TEXT:C222(<>OTR_Sort7_at; 0)
ARRAY LONGINT:C221(<>OTR_Sort7_ai; 0)
ARRAY REAL:C219(<>OTR_Sort7_ar; 0)
ARRAY DATE:C224(<>OTR_Sort7_ad; 0)
ARRAY TIME:C1223(<>OTR_Sort7_ah; 0)
ARRAY BOOLEAN:C223(<>OTR_Sort7_ab; 0)

// --- Sort index (slave, tracks rearrangement order) ---
ARRAY LONGINT:C221(<>OTR_SortIdx_ai; 0)