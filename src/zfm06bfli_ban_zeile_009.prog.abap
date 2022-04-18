*eject
*----------------------------------------------------------------------*
* Zeile: Dispodaten aus Materialstamm                                  *
*----------------------------------------------------------------------*
FORM BAN_ZEILE_009.

  IF NOT EBAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
*... Bei Gesamtfreigabe werden die Positionen nur ausgegeben, wenn dies
*... im Listumfang explizit angegeben wurde ..........................*
    CHECK NOT T16LB-GSPOS IS INITIAL.
  ENDIF.
  CHECK EBAN-MATNR EQ MT61D-MATNR.
  CHECK EBAN-WERKS EQ MT61D-WERKS.
*ENHANCEMENT-SECTION     FM06BFLI_BAN_ZEILE_009_01 SPOTS ES_SAPFM06B.
  WRITE: /  SY-VLINE,
          4 MT61D-DISMM,
          8 MT61D-DISLS,
         11 MT61D-BESKZ,
     14(17) MT61D-MINBE UNIT EBAN-MEINS NO-SIGN,
            EBAN-MEINS,
     36(17) MT61D-EISBE UNIT EBAN-MEINS NO-SIGN,
            EBAN-MEINS,
         59 MT61D-SOBSL,
         64 MT61D-PLIFZ,
         81 SY-VLINE.
*END-ENHANCEMENT-SECTION.

ENDFORM.
