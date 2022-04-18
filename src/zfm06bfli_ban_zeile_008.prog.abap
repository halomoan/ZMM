*eject
*----------------------------------------------------------------------*
* Zeile: Letzte Bestellung                                             *
*----------------------------------------------------------------------*
FORM BAN_ZEILE_008.

  IF NOT EBAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
*... Bei Gesamtfreigabe werden die Positionen nur ausgegeben, wenn dies
*... im Listumfang explizit angegeben wurde ..........................*
    CHECK NOT T16LB-GSPOS IS INITIAL.
  ENDIF.

* IF EBAN-EBELN NE SPACE.                                  "88389/KB
*   CHECK EBAN-STATU NE 'K'.                               "88389/KB
  CHECK NOT EBAN-EBELN IS INITIAL.     "88389/KB
*  IF EBAN-BSAKZ EQ SPACE.              "88389/KB         "DEL 328411
  IF EBAN-BSAKZ EQ SPACE OR EBAN-BSAKZ EQ 'T'.            "INS 328411
*ENHANCEMENT-SECTION     FM06BFLI_BAN_ZEILE_008_01 SPOTS ES_SAPFM06B.
    WRITE: /  SY-VLINE,
            4 TEXT-056,
           23 EBAN-EBELN,
              EBAN-EBELP,
           42 TEXT-057,
           46 EBAN-BEDAT DD/MM/YYYY NO-ZERO,
           81 SY-VLINE.
*END-ENHANCEMENT-SECTION.
    HIDE EBAN-PACKNO.
  ELSE.                                "88389/KB
*ENHANCEMENT-SECTION     FM06BFLI_BAN_ZEILE_008_02 SPOTS ES_SAPFM06B.
    WRITE: /  SY-VLINE,                "88389/KB
            4 TEXT-069,                "88389/KB
           23 EBAN-EBELN,              "88389/KB
              EBAN-EBELP,              "88389/KB
           42 TEXT-057,                "88389/KB
           46 EBAN-BEDAT DD/MM/YYYY NO-ZERO,                 "88389/KB
           81 SY-VLINE.                "88389/KB
*END-ENHANCEMENT-SECTION.
    HIDE EBAN-PACKNO.                  "88389/KB
  ENDIF.

ENDFORM.
