*eject
*----------------------------------------------------------------------*
* Zeile: Bezugsquellenzuordnung                                        *
*----------------------------------------------------------------------*
FORM BAN_ZEILE_004.

  IF NOT EBAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
*... Bei Gesamtfreigabe werden die Positionen nur ausgegeben, wenn dies
*... im Listumfang explizit angegeben wurde ..........................*
    CHECK NOT T16LB-GSPOS IS INITIAL.
  ENDIF.
*- keine Zuordnung: Leerzeile nur bei aktiver Zurodnungsfunktion ------*
  IF BAN-UPDK1 EQ SPACE.
    CHECK SY-PFKEY EQ 'ZUOR' OR
          SY-PFKEY EQ 'BEAR'.
  ENDIF.

  IF BAN-UPDK1 NE ZOLD AND
     BAN-UPDK1 NE SPACE AND
     XT16LD-ZEILE EQ XZLTYP.
    IF COLFLAG = 'X'.
      FORMAT COLOR COL_POSITIVE INTENSIFIED.
    ELSE.
      FORMAT COLOR COL_POSITIVE INTENSIFIED OFF.
    ENDIF.
  ENDIF.

*ENHANCEMENT-SECTION     FM06BFLI_BAN_ZEILE_004_01 SPOTS ES_SAPFM06B.
  WRITE: /  SY-VLINE,
          4 HLINE,
         81 SY-VLINE.
*END-ENHANCEMENT-SECTION.

  IF COLFLAG = 'X'.
    FORMAT COLOR COL_NORMAL INTENSIFIED.
  ELSE.
    FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
  ENDIF.

ENDFORM.
