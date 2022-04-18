*eject
*----------------------------------------------------------------------*
* Zeile: Sel., Material, Menge, Lieferdatum, Zuordnung                 *
*----------------------------------------------------------------------*
FORM BAN_ZEILE_201.


*ENHANCEMENT-POINT FM06BFLI_BAN_ZEILE_201_02 SPOTS ES_SAPFM06B STATIC.

*ENHANCEMENT-SECTION     FM06BFLI_BAN_ZEILE_201_01 SPOTS ES_SAPFM06B.
  IF NOT EBAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
*... Bei Gesamtfreigabe werden die Positionen nur ausgegeben, wenn dies
*... im Listumfang explizit angegeben wurde ..........................*
    CHECK NOT T16LB-GSPOS IS INITIAL.
  ENDIF.
  WRITE: /  SY-VLINE,
          2 EBAN-MATNR, "#EC CI_FLDEXT_OK[2215424] P30K909996
         20 SY-VLINE,
     21(20) EBAN-TXZ01,
         41 SY-VLINE,
     42(17) EBAN-MENGE UNIT EBAN-MEINS NO-SIGN,
         59 SY-VLINE,
         60 EBAN-MEINS,
         63 SY-VLINE,
         64 RM06B-LPEIN,
         66 RM06B-EEIND,
         76 SY-VLINE.

  IF XT16LD-ZEILE EQ XZLTYP.
    WRITE: 77 T16LA-UPDT1 COLOR COL_POSITIVE.
  ELSE.
    WRITE: 77 T16LA-UPDT1.
  ENDIF.
  WRITE: 81 SY-VLINE.
*END-ENHANCEMENT-SECTION.




ENDFORM.
