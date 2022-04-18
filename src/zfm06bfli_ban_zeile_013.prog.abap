*eject
*----------------------------------------------------------------------*
* Zeile: Lieferantenstammdaten                                         *
*----------------------------------------------------------------------*
FORM BAN_ZEILE_013.
  IF NOT EBAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
*... Bei Gesamtfreigabe werden die Positionen nur ausgegeben, wenn dies
*... im Listumfang explizit angegeben wurde ..........................*
    CHECK NOT T16LB-GSPOS IS INITIAL.
  ENDIF.
  CHECK EBAN-FLIEF NE SPACE.
  CHECK LFM1-INCO1 NE SPACE OR
        LFM1-MINBW NE 0.
  WRITE /  SY-VLINE.
  IF LFM1-INCO1 NE SPACE.
    WRITE: 4  TEXT-068,
           15 LFM1-INCO1,
              LFM1-INCO2.
  ENDIF.
  IF LFM1-MINBW NE 0.
    WRITE: 45 TEXT-067,
              LFM1-MINBW CURRENCY LFM1-WAERS NO-SIGN,
              LFM1-WAERS.
  ENDIF.
*ENHANCEMENT-SECTION     FM06BFLI_BAN_ZEILE_013_01 SPOTS ES_SAPFM06B.
  WRITE 81 SY-VLINE.
*END-ENHANCEMENT-SECTION.
ENDFORM.
