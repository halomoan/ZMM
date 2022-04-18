*eject
*----------------------------------------------------------------------*
*        Gruppenwechsel Kontierung                                     *
*----------------------------------------------------------------------*
FORM BAN_KONT_WECHSEL.

  DATA: L_OBJNR LIKE VIREKEY-OBJNR,
        L_TEXT  LIKE SY-MSGV1.

  COM-BKMKZ = BAN-BKMKZ.                               "4.0C
  CHECK COM-BKMKZ NE SPACE.
  CHECK COM-SRTKZ EQ '8'.

  IF BAN-KONT1 NE HKONT1 OR
     BAN-KONT2 NE HKONT2.
    IF HKONT1 NE SPACE.
      ULINE.
*ENHANCEMENT-SECTION     FM06BF01_BAN_KONT_WECHSEL_01 SPOTS ES_SAPFM06B.
      NEW-PAGE LINE-SIZE 81.
*END-ENHANCEMENT-SECTION.
    ENDIF.
    HKONT1 = BAN-KONT1.
    HKONT2 = BAN-KONT2.
*- Aufbereiten kontierungsüberschrift ---------------------------------*
    CLEAR UEBKNT2.
    CASE COM-BKMKZ.
      WHEN '1' OR '2' OR '3'.
        WRITE BAN-KONT1 TO UEBKNT2.
      WHEN '4'.
        WRITE BAN-KONT1 TO UEBKNT2.
        WRITE BAN-KONT2 TO UEBKNT2+30.
      WHEN '5'.
        WRITE BAN-KONT1 TO UEBKNT2.
        WRITE BAN-KONT2 TO UEBKNT2+30.
      WHEN '6'.
        MOVE BAN-KONT1(10) TO EBKN-AUFPL.
        MOVE BAN-KONT2 TO EBKN-APLZL.
        CALL FUNCTION 'READ_NETWORK_NPLNR_VORNR'
             EXPORTING
                  APLZL     = EBKN-APLZL
                  AUFPL     = EBKN-AUFPL
             IMPORTING
                  NPLNR     = HNPLNR
                  VORNR     = HVORNR
             EXCEPTIONS
                  NOT_FOUND = 01.
        WRITE HNPLNR TO UEBKNT2.
        WRITE HVORNR TO UEBKNT2+30.
      WHEN '7'.
        L_OBJNR = BAN-KONT1.
        CALL FUNCTION 'REMD_GET_TEXT_FOR_OBJECT'
             EXPORTING
                  I_OBJNR     = L_OBJNR
                  TEXT_WANTED = 'X'
             IMPORTING
                  E_TEXT      = L_TEXT.
        MOVE L_TEXT TO UEBKNT2.
      WHEN '8'.                                             "602972
        MOVE BAN-KONT1(12) TO UEBKNT2.
    ENDCASE.
    CONDENSE UEBKNT2.
  ENDIF.
ENDFORM.
