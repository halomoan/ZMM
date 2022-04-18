*eject
*----------------------------------------------------------------------*
* Lieferanten in interne Tabelle füllen                                *
*----------------------------------------------------------------------*
FORM ALF_FUELLEN.

  PERFORM EKORG_CHECK(SAPFMMEX) USING LFM1-EKORG
                                CHANGING T024E.
*ERFORM LFM1_LESEN(SAPFMMEX) USING LFM1-LIFNR LFM1-EKORG.

  DATA: LS_LFM1 LIKE LFM1.                                  "161761
  DATA: LS_LFA1 LIKE LFA1.                                  "181072

  CALL FUNCTION 'VENDOR_MASTER_DATA_SELECT_00'
       EXPORTING
            I_LFA1_LIFNR     = LFM1-LIFNR
            I_LFM1_EKORG     = LFM1-EKORG
            I_DATA           = 'X'
       IMPORTING                                            "161761
            A_LFM1           = LS_LFM1                      "161761
            A_LFA1           = LS_LFA1                      "181072
       EXCEPTIONS
            VENDOR_NOT_FOUND = 01.

  IF SY-SUBRC NE 0.
    MESSAGE E321(06) WITH LFM1-LIFNR LFM1-EKORG.
  ENDIF.

  IF LFM1-LIFNR NE LS_LFM1-LIFNR.                           "161761
    MESSAGE E027(06) WITH LFM1-LIFNR LFM1-EKORG.            "181072
  ENDIF.                                                    "181072

*- Prüfen ob Lieferant gesperrt ist                         "181072
  PERFORM LFA1-STATUS-NEU(SAPFMMEX) USING 'X' LS_LFA1.      "181072
  PERFORM LFM1-STATUS-NEU(SAPFMMEX) USING LS_LFM1.          "181072
  CLEAR: LS_LFA1, LS_LFM1.                                  "181072

  CLEAR ALF.
*- Lesen Tabelle - feststellen, ob Lieferant bereits vorhanden --------*
  ALFKEY-BANFN = BAN-BANFN.
  ALFKEY-BNFPO = BAN-BNFPO.
  ALFKEY-LIFNR = LFM1-LIFNR.
  ALFKEY-EKORG = LFM1-EKORG.
  READ TABLE ALF WITH KEY ALFKEY BINARY SEARCH.

  CASE SY-SUBRC.
*- Lieferant bereits in Tabelle - Selektionskennzeichen setzen --------*
    WHEN 00.
      ALF-VSELK = RM06B-SELKZ.
      MODIFY ALF INDEX SY-TABIX.
*- Lieferant noch nicht zugeordnet - Einfügen -------------------------*
    WHEN 04.
      MOVE-CORRESPONDING ALFKEY TO ALF.
      ALF-VSELK = 'X'.
      INSERT ALF INDEX SY-TABIX.
      A-MAXIND = A-MAXIND + 1.
      A-AKTIND = A-AKTIND + 1.
      A-PAGIND = A-PAGIND + 1.
*- Lieferant noch nicht zugeordnet - Anhängen -------------------------*
    WHEN 08.
      MOVE-CORRESPONDING ALFKEY TO ALF.
      ALF-VSELK = 'X'.
      APPEND ALF.
      A-MAXIND = A-MAXIND + 1.
      A-AKTIND = A-AKTIND + 1.
      A-PAGIND = A-PAGIND + 1.
  ENDCASE.

ENDFORM.
