*eject
*----------------------------------------------------------------------*
* Zeile: Freigabeinformation                                           *
*----------------------------------------------------------------------*
FORM BAN_ZEILE_010.
  IF NOT GS_BANF IS INITIAL.
*... Eigene Listaufbereitung für Gesamtbanfen ........................*
    CHECK EBAN-GSFRG IS INITIAL.
  ENDIF.
  IF BAN-UPDK3 NE SPACE.
    IF COLFLAG = 'X'.
      FORMAT COLOR COL_POSITIVE INTENSIFIED.
    ELSE.
      FORMAT COLOR COL_POSITIVE INTENSIFIED OFF.
    ENDIF.
  ENDIF.

*ENHANCEMENT-SECTION     FM06BFLI_BAN_ZEILE_010_01 SPOTS ES_SAPFM06B.
  WRITE: /  SY-VLINE,
          4 FLINE,
         81 SY-VLINE.
*END-ENHANCEMENT-SECTION.

  IF COLFLAG = 'X'.
    FORMAT COLOR COL_NORMAL INTENSIFIED.
  ELSE.
    FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
  ENDIF.

ENDFORM.
