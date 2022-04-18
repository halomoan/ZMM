*eject
*----------------------------------------------------------------------*
* Zeile: div. Kennzeichen, Bestellte Menge, Freigabedatum ect.         *
*----------------------------------------------------------------------*
FORM BAN_ZEILE_003.

  IF NOT EBAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
*... Bei Gesamtfreigabe werden die Positionen nur ausgegeben, wenn dies
*... im Listumfang explizit angegeben wurde ..........................*
    CHECK NOT T16LB-GSPOS IS INITIAL.
  ENDIF.
  WRITE: /  SY-VLINE,
          4  EBAN-STATU,
             EBAN-ESTKZ,
             EBAN-FRGKZ,
             EBAN-BSART,
             RM06B-EPSTP,
             EBAN-KNTTP.
  IF EBAN-BSMNG NE 0.
    WRITE: 22(18) EBAN-BSMNG UNIT EBAN-MEINS,
           40 EBAN-MEINS.
  ENDIF.
*ENHANCEMENT-SECTION     FM06BFLI_BAN_ZEILE_003_01 SPOTS ES_SAPFM06B.
  WRITE:  46 EBAN-FRGDT DD/MM/YYYY,
             EBAN-BEDNR,
          71 EBAN-RESWK,
             EBAN-DISPO,
          81 SY-VLINE.
  HIDE EBAN-PACKNO.
*END-ENHANCEMENT-SECTION.
ENDFORM.
