*&---------------------------------------------------------------------*
*& Report  ZMMRGB_0007B
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZMMRGB_0007B.

SELECTION-SCREEN BEGIN OF SCREEN 9100  TITLE text_100.
PARAMETERS : p_banfn LIKE eban-banfn.
PARAMETERS : p_bnfpo LIKE eban-bnfpo.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT (32) text_102.
PARAMETERS : p_matnr LIKE eban-matnr.
PARAMETERS : p_txz01 LIKE eban-txz01.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT (60) text_101.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN SKIP 1.
PARAMETERS : p_kostl LIKE cobl-kostl.
PARAMETERS : p_ablad LIKE meacct1100-ablad.
PARAMETERS : p_ekgrp LIKE eban-ekgrp.
PARAMETERS : p_wempf LIKE meacct1100-wempf.
PARAMETERS : p_afnam LIKE eban-afnam.
SELECTION-SCREEN END OF SCREEN 9100.

INITIALIZATION.
  text_100 = 'Process Selected PR for Purchasing'.
  text_101 = 'Enter Values for Purchasing Requisition Items'.
  text_102 = 'Material'.

  set pf-status '9100'.
call screen 100.
START-OF-SELECTION.
*          CALL SELECTION-SCREEN 9100 STARTING AT 40 8.
