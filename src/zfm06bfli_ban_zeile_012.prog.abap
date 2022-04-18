*eject
*----------------------------------------------------------------------*
* Zeile: Infosatz/Rahmenvertragsdaten                                  *
*----------------------------------------------------------------------*
FORM BAN_ZEILE_012.
  IF NOT EBAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
*... Bei Gesamtfreigabe werden die Positionen nur ausgegeben, wenn dies
*... im Listumfang explizit angegeben wurde ..........................*
    CHECK NOT T16LB-GSPOS IS INITIAL.
  ENDIF.
  IF EBAN-INFNR NE SPACE.
    CLEAR APREIS.
    WRITE EINE-NETPR TO APREIS-NETPR CURRENCY EINE-WAERS NO-SIGN.
    WRITE EINE-BPRME TO APREIS-BPRME.
    IF EINE-PEINH NE 1.
      WRITE EINE-PEINH TO APREIS-PEINH.
    ENDIF.
    APREIS-STRICH = '/'.
    APREIS-WAERS  = EINE-WAERS.
    CONDENSE APREIS.
    WRITE: /  SY-VLINE,
            4  TEXT-065,
               APREIS.
    IF EINE-MINBM NE 0.
      WRITE: 45 TEXT-066,
                EINE-MINBM UNIT EINA-MEINS NO-SIGN,
                EINA-MEINS.
    ENDIF.
*ENHANCEMENT-POINT FM06BFLI_BAN_ZEILE_012_01 SPOTS ES_SAPFM06B.
    WRITE 81 SY-VLINE.
  ELSE.
    IF EBAN-KONNR NE SPACE.
      CLEAR APREIS.
      WRITE EKPO-NETPR TO APREIS-NETPR CURRENCY EKKO-WAERS NO-SIGN.
      WRITE EKPO-BPRME TO APREIS-BPRME.
      IF EKPO-PEINH NE 1.
        WRITE EKPO-PEINH TO APREIS-PEINH.
      ENDIF.
      APREIS-STRICH = '/'.
      APREIS-WAERS  = EKKO-WAERS.
      CONDENSE APREIS.
*ENHANCEMENT-SECTION     FM06BFLI_BAN_ZEILE_012_02 SPOTS ES_SAPFM06B.
      WRITE: /  SY-VLINE,
              4  TEXT-065,
                 APREIS.
      WRITE 81 SY-VLINE.
*END-ENHANCEMENT-SECTION.
    ENDIF.
  ENDIF.
ENDFORM.
