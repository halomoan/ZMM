*eject
*----------------------------------------------------------------------*
* Zeile: Selektionskennzeichen, Material, Warengruppe                  *
*----------------------------------------------------------------------*
FORM BAN_ZEILE_001.

  IF NOT EBAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
*ENHANCEMENT-POINT FM06BFLI_BAN_ZEILE_001_01 SPOTS ES_SAPFM06B STATIC.
*... Bei Gesamtfreigabe werden die Positionen nur ausgegeben, wenn dies
*... im Listumfang explizit angegeben wurde ..........................*
    CHECK NOT T16LB-GSPOS IS INITIAL.
  ENDIF.
  WRITE: /  SY-VLINE.
  IF EBAN-GSFRG IS INITIAL OR GS_BANF IS INITIAL.
*... Die Zeile soll nur dann selektierbar sein, wenn es sich nicht um *
*... Banf-Positionen handelt, die der Gesamtfreigabe unterliegen, ....*
*... denn dann gibr es eine eigene 'Kopfzeile'. ......................*
    IF T16LH-XMKEX NE SPACE.
      WRITE 2 BAN-SELKZ AS CHECKBOX.
    ELSE.
      WRITE 2 BAN-SELKZ AS CHECKBOX INPUT OFF.
    ENDIF.
  ENDIF.
*ENHANCEMENT-SECTION     FM06BFLI_BAN_ZEILE_001_02 SPOTS ES_SAPFM06B.
  WRITE:  4 EBAN-MATNR, "#EC CI_FLDEXT_OK[2215424] P30K909996
            EBAN-TXZ01,
            EBAN-EKGRP,
         71 EBAN-MATKL,
         81 SY-VLINE.
*END-ENHANCEMENT-SECTION.
  HIDE EBAN-PACKNO.

ENDFORM.
*ENHANCEMENT-POINT FM06BFLI_BAN_ZEILE_001_03 SPOTS ES_SAPFM06B STATIC.
