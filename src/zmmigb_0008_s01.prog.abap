*&---------------------------------------------------------------------*
*&  Include           ZMMIGB_0008_S01
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* SELECTION-SCREEN                                                     *
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK BLK1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: P_EKORG TYPE EKKO-EKORG OBLIGATORY.
  select-OPTIONS: s_ebeln FOR ekko-ebeln.
  SELECT-OPTIONS: s_submi FOR ekko-submi.
  SELECT-OPTIONS: s_lifnr FOR lfa1-lifnr.
SELECTION-SCREEN END OF BLOCK BLK1.

SELECTION-SCREEN BEGIN OF BLOCK BLK2 WITH FRAME TITLE TEXT-002.
* Download into one file
  SELECTION-SCREEN BEGIN OF LINE.
  PARAMETERS P_BTCUR1 RADIOBUTTON GROUP GRP1 USER-COMMAND RB_PROC.
  SELECTION-SCREEN COMMENT 8(25) G_CMT01 for FIELD P_BTCUR1.
  SELECTION-SCREEN END OF LINE.

* Download split by vendor
  SELECTION-SCREEN BEGIN OF LINE.
  PARAMETERS P_BTCUR2 RADIOBUTTON GROUP GRP1.
  SELECTION-SCREEN COMMENT 3(25) G_CMT02 for FIELD P_BTCUR2.
  SELECTION-SCREEN END OF LINE.

* Upload quotation
  SELECTION-SCREEN BEGIN OF LINE.
  PARAMETERS P_BTCUR3 RADIOBUTTON GROUP GRP1.
  SELECTION-SCREEN COMMENT 3(25) G_CMT03 for FIELD P_BTCUR3.
  SELECTION-SCREEN END OF LINE.

  PARAMETERS : p_file LIKE file_table-filename.
SELECTION-SCREEN END OF BLOCK BLK2.
selection-screen comment 1(65) text-m01.
