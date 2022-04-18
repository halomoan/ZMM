*eject
*----------------------------------------------------------------------*
* Zeile: Wiedervorlage                                                 *
*----------------------------------------------------------------------*
FORM BAN_ZEILE_007.

  IF NOT EBAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
*... Bei Gesamtfreigabe werden die Positionen nur ausgegeben, wenn dies
*... im Listumfang explizit angegeben wurde ..........................*
    CHECK NOT T16LB-GSPOS IS INITIAL.
  ENDIF.
  IF EBAN-BVDAT NE 0.
*ENHANCEMENT-SECTION     FM06BFLI_BAN_ZEILE_007_01 SPOTS ES_SAPFM06B.
    WRITE: /  SY-VLINE,
            4  TEXT-055,
               EBAN-BVDAT DD/MM/YYYY,
            44 TEXT-060,
               EBAN-BVDRK,
            81 SY-VLINE.
*END-ENHANCEMENT-SECTION.
  ENDIF.

ENDFORM.
