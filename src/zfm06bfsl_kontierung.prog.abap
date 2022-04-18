*eject
*----------------------------------------------------------------------*
*        Kontierungsfelder füllen                                      *
*----------------------------------------------------------------------*
FORM KONTIERUNG.

* CHECK COM-BKMKZ NE SPACE.
  CLEAR: BAN-KONT1, BAN-KONT2, BAN-BKMKZ.
  IF COM-BKMKZ EQ SPACE.
    IF NOT EBKN-PS_PSP_PNR IS INITIAL.
      BAN-BKMKZ = '2'.
    ELSEIF NOT EBKN-NPLNR IS INITIAL AND
    NOT EBKN-AUFPL IS INITIAL.                              "602972
      BAN-BKMKZ = '6'.
    ELSEIF NOT EBKN-NPLNR IS INITIAL.
      BAN-BKMKZ = '8'.
    ELSEIF NOT EBKN-AUFNR IS INITIAL.
      BAN-BKMKZ = '3'.
    ELSEIF NOT EBKN-ANLN1 IS INITIAL.
      BAN-BKMKZ = '4'.
    ELSEIF NOT EBKN-VBELN IS INITIAL.
      BAN-BKMKZ = '5'.
    ELSEIF NOT EBKN-KOSTL IS INITIAL.
      BAN-BKMKZ = '1'.
    ELSEIF NOT EBKN-IMKEY IS INITIAL.
      BAN-BKMKZ = '7'.
    ENDIF.
  ELSE.
    IF COM-BKMKZ = '6' AND EBKN-AUFPL IS INITIAL.           "602972
      BAN-BKMKZ = '8'.
    ELSE.
      BAN-BKMKZ = COM-BKMKZ.
    ENDIF.
  ENDIF.
  CHECK NOT BAN-BKMKZ IS INITIAL.

  CASE BAN-BKMKZ.                                        "4.0C
    WHEN '1'.
      BAN-KONT1(10) = EBKN-KOSTL.
    WHEN '2'.
*     BAN-KONT1(8) = EBKN-PS_PSP_PNR.                       "4.0C
      WRITE EBKN-PS_PSP_PNR TO BAN-KONT1.                   "4.0C
    WHEN '3'.
      BAN-KONT1 = EBKN-AUFNR.
    WHEN '4'.
      BAN-KONT1 = EBKN-ANLN1.
      BAN-KONT2(4) = EBKN-ANLN2.
    WHEN '5'.
      BAN-KONT1(10) = EBKN-VBELN.
      BAN-KONT2(6) = EBKN-VBELP.
    WHEN '6'.
      BAN-KONT1(10) = EBKN-AUFPL.
      BAN-KONT2 = EBKN-APLZL.
    WHEN '7'.                                               "4.6A CF
      READ TABLE T_IMKEYS WITH KEY IMKEY = EBKN-IMKEY.
      IF SY-SUBRC EQ 0.
        BAN-KONT1 = T_IMKEYS-OBJNR.
      ENDIF.
    WHEN '8'.                                               "602972
      Write EBKN-NPLNR TO BAN-KONT1.
  ENDCASE.

  IF NOT EBKN-MENGE IS INITIAL.
    BAN-MENGE = EBKN-MENGE.
  ENDIF.

ENDFORM.
