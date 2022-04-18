*&---------------------------------------------------------------------*
*&  Include           ZMMRGB_0008_S01
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* SELECTION-SCREEN                                                     *
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK BLK1 WITH FRAME TITLE TEXT-001.

  SELECT-OPTIONS: S_BUKRS      FOR gs_input-bukrs,
                  S_WERKS      FOR gs_input-werks,
                  S_EKORG      FOR gs_input-ekorg,
                  S_matkl      FOR gs_input-matkl,
                  S_LIFNR      FOR gs_input-lifnr,
                  S_DATE       FOR gs_input-date NO-EXTENSION.

  SELECTION-SCREEN skip.

  SELECTION-SCREEN BEGIN OF LINE.
   PARAMETER: R1 RADIOBUTTON GROUP rb USER-COMMAND rad.
   SELECTION-SCREEN COMMENT 4(70) text-rb1.
  SELECTION-SCREEN END OF LINE.

  SELECTION-SCREEN BEGIN OF LINE.
   PARAMETER: R2 RADIOBUTTON GROUP rb MODIF ID RW.
   SELECTION-SCREEN COMMENT 4(70) text-rb2.
  SELECTION-SCREEN END OF LINE.

  SELECTION-SCREEN BEGIN OF LINE.
   PARAMETER: R3 RADIOBUTTON GROUP rb MODIF ID RW.
   SELECTION-SCREEN COMMENT 4(70) text-rb3.
  SELECTION-SCREEN END OF LINE.

  PARAMETER: p_item TYPE ZTBMAXSEL DEFAULT 200.

  SELECTION-SCREEN ULINE .

  SELECTION-SCREEN BEGIN OF LINE.
   PARAMETER: R4 RADIOBUTTON GROUP rb MODIF ID RW.
   SELECTION-SCREEN COMMENT 4(70) text-rb4.
  SELECTION-SCREEN END OF LINE.

  SELECTION-SCREEN BEGIN OF LINE.
   PARAMETER: R5 RADIOBUTTON GROUP rb MODIF ID RW.
   SELECTION-SCREEN COMMENT 4(70) text-rb5.
  SELECTION-SCREEN END OF LINE.

  PARAMETER: p_vendor TYPE ZTBMAXSEL DEFAULT 200.

SELECTION-SCREEN END OF BLOCK BLK1.
