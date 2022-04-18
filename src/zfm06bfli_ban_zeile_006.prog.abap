*eject
*----------------------------------------------------------------------*
* Zeile: Unterdeckungsmenge                                            *
*----------------------------------------------------------------------*
FORM BAN_ZEILE_006.

  IF NOT EBAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
*... Bei Gesamtfreigabe werden die Positionen nur ausgegeben, wenn dies
*... im Listumfang explizit angegeben wurde ..........................*
    CHECK NOT T16LB-GSPOS IS INITIAL.
  ENDIF.
  IF EBAN-BUMNG NE 0.
*ENHANCEMENT-SECTION     FM06BFLI_BAN_ZEILE_006_01 SPOTS ES_SAPFM06B.
    WRITE: /  SY-VLINE,
            4 TEXT-054,
       22(18) EBAN-BUMNG UNIT EBAN-MEINS NO-SIGN,
           40 EBAN-MEINS,
           81 SY-VLINE.
*END-ENHANCEMENT-SECTION.
    HIDE EBAN-PACKNO.
  ENDIF.

ENDFORM.
