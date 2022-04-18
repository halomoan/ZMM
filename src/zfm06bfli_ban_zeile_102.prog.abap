*eject
*----------------------------------------------------------------------*
* Zeile: Selektionskennzeichen, Material, Werk, Lagerort               *
*----------------------------------------------------------------------*
FORM BAN_ZEILE_102.
  IF NOT EBAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
*... Bei Gesamtfreigabe werden die Positionen nur ausgegeben, wenn dies
*... im Listumfang explizit angegeben wurde ..........................*
    CHECK NOT T16LB-GSPOS IS INITIAL.
  ENDIF.
  WRITE: /  SY-VLINE,
         4  EBAN-BSART,
            RM06B-EPSTP,
            EBAN-KNTTP,
     14(17) EBAN-MENGE UNIT EBAN-MEINS NO-SIGN,
            EBAN-MEINS,
            RM06B-LPEIN,
            RM06B-EEIND,
            EBAN-WERKS,
            EBAN-LGORT,
            EBAN-RESWK,
            EBAN-DISPO.
  IF XT16LD-ZEILE EQ XZLTYP.
    WRITE: 71 T16LA-UPDT2 COLOR COL_POSITIVE.
  ELSE.
    WRITE: 71 T16LA-UPDT2.
  ENDIF.
*ENHANCEMENT-SECTION     FM06BFLI_BAN_ZEILE_102_01 SPOTS ES_SAPFM06B.
  WRITE: 81 SY-VLINE.
*END-ENHANCEMENT-SECTION.
ENDFORM.
