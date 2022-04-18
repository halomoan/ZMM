*----------------------------------------------------------------------*
*   INCLUDE FM06BCS3                                                   *
*----------------------------------------------------------------------*
DATA: BEGIN OF COMMON PART FM06BCS3.

*----------------------------------------------------------------------*
*        select-options                                                *
*----------------------------------------------------------------------*
SELECT-OPTIONS:
   S_KOSTL FOR EBKN-KOSTL,
   S_PSEXT FOR PRPS-POSID,
*  s_psint for ebkn-ps_psp_pnr,
   S_AUFNR FOR EBKN-AUFNR MATCHCODE OBJECT ORDE,
   S_ANLN1 FOR EBKN-ANLN1,
   S_ANLN2 FOR EBKN-ANLN2,
   S_NPLNR FOR EBKN-NPLNR,
   S_VORNR FOR RESB-VORNR,
   S_VBELN FOR EBKN-VBELN,
   S_VBELP FOR EBKN-VBELP.

DATA: END OF COMMON PART FM06BCS3.

INCLUDE zIFVIIMSL.
