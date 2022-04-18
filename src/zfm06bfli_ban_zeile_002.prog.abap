*eject
*----------------------------------------------------------------------*
* Zeile: Banf, Menge, Lieferdatum                                      *
*----------------------------------------------------------------------*
FORM BAN_ZEILE_002.

  IF NOT EBAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
*... Bei Gesamtfreigabe werden die Positionen nur ausgegeben, wenn dies
*... im Listumfang explizit angegeben wurde ..........................*
    CHECK NOT T16LB-GSPOS IS INITIAL.
  ENDIF.
  WRITE: /  SY-VLINE.
  IF EBAN-GSFRG IS INITIAL OR GS_BANF IS INITIAL.
    WRITE:  4 EBAN-BANFN.
  ENDIF.
*ENHANCEMENT-SECTION     FM06BFLI_BAN_ZEILE_002_01 SPOTS ES_SAPFM06B.
  WRITE: 15 EBAN-BNFPO,
     22(18) EBAN-MENGE UNIT EBAN-MEINS,
         40 EBAN-MEINS,
         44 RM06B-LPEIN,
            RM06B-EEIND,
            EBAN-AFNAM,
         71 EBAN-WERKS,
            EBAN-LGORT,
         81 SY-VLINE.
  HIDE EBAN-PACKNO.
*END-ENHANCEMENT-SECTION.

ENDFORM.
