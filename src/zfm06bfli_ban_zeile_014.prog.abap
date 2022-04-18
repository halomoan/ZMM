*eject
*----------------------------------------------------------------------*
* Zeile: Bestands-/Bedarfssituation                                    *
*----------------------------------------------------------------------*
FORM BAN_ZEILE_014.

  IF NOT EBAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
*... Bei Gesamtfreigabe werden die Positionen nur ausgegeben, wenn dies
*... im Listumfang explizit angegeben wurde ..........................*
    CHECK NOT T16LB-GSPOS IS INITIAL.
  ENDIF.
  CHECK EBAN-MATNR NE SPACE.
  CHECK EBAN-WERKS NE SPACE.
  WRITE: /  SY-VLINE.
  IF MDKP-DSDAT NE 0.
    WRITE 4  MDKP-DSDAT DD/MM/YY.
  ENDIF.
  WRITE:
     14(17) MDSTA-SUM01 UNIT EBAN-MEINS NO-SIGN,
            EBAN-MEINS.
  IF MDKP-DSDAT NE 0.
    WRITE:
    36(17) MDSTA-SUM02 UNIT EBAN-MEINS NO-SIGN,
           EBAN-MEINS,
    58(17) MDSTA-SUM04 UNIT EBAN-MEINS NO-SIGN,
           EBAN-MEINS.
  ENDIF.
*ENHANCEMENT-SECTION     FM06BFLI_BAN_ZEILE_014_01 SPOTS ES_SAPFM06B.
  WRITE 81 SY-VLINE.
*END-ENHANCEMENT-SECTION.

ENDFORM.
