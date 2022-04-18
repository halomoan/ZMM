*eject
*----------------------------------------------------------------------*
*  Tabelle der Routinen zum Listumfang aufbauen
*----------------------------------------------------------------------*
FORM XT16LL_AUFBAUEN.

*- Definition des Listumfangs -----------------------------------------*
  SELECT SINGLE * FROM T16LB WHERE LSTUB = COM-LSTUB.
  IF SY-SUBRC NE 0.
    MESSAGE E287 WITH COM-LSTUB.
  ENDIF.
*- Default für fehlende Detail-Subscreens setzen ----------------------*
  IF T16LB-SDYN1 EQ 0.
    T16LB-SDYN1 = 400.
  ENDIF.
  IF T16LB-SDYN2 EQ 0.
    T16LB-SDYN2 = 400.
  ENDIF.
  IF T16LB-SDYN3 EQ 0.
    T16LB-SDYN3 = 400.
  ENDIF.
*- Zusätzliche Daten zum Listumfang -----------------------------------*
  REFRESH XT16LI.
  SELECT * FROM T16LI APPENDING TABLE XT16LI
                      WHERE LSTUB EQ T16LB-LSTUB.

*- Zeilenaufbau zum Listumfang ----------------------------------------*
  CLEAR: XZLTYP, XZEILE.
  CLEAR: XSZEIL, XSZTYP.
  REFRESH EXCL.
  IF T16LB-DYNPR EQ 0.
    REFRESH XT16LD.
    SELECT * FROM T16LL WHERE LSTUB = COM-LSTUB.
      SELECT SINGLE * FROM T16LD WHERE LLIST EQ T16LL-LLIST.
      IF SY-SUBRC EQ 0.
        XT16LD = T16LD.
        XT16LD-STATZ = T16LL-STATZ.                         "gt
        APPEND XT16LD.
        IF T16LL-STATZ NE SPACE.
          XZEILE = SY-TABIX - 1.
          IF XZLTYP EQ SPACE.
            XZLTYP = T16LD-ZEILE.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDSELECT.
    IF SY-SUBRC NE 0.
      MESSAGE E287 WITH COM-LSTUB.
    ENDIF.
*- 'Abbrechen Zeile' nur bei Dynpro -----------------------------------*
    EXCL-FUNKTION = 'EXIL'.
    APPEND EXCL.

*- Zeilennummer der Selektions- und Zuorddnungszeile ermitteln --------*
    LOOP AT XT16LD.
      IF XT16LD-SZEIL NE SPACE.
        IF XSZTYP EQ SPACE.
          XSZEIL = SY-TABIX - 1.
          XSZTYP = 'X'.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ELSE.
    XZLTYP = '4'.
  ENDIF.
ENDFORM.
