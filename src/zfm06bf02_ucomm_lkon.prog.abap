*eject
*----------------------------------------------------------------------*
*     Anzeigen Konsilieferanten
*----------------------------------------------------------------------*
FORM UCOMM_LKON.

  CHECK LISTE EQ 'G'.

  LEERFLG = 'X'.
  CLEAR: KNS, INDEX_BAN, EXITFLAG.

*- Suchen einer markierten Position -----------------------------------*
  LOOP AT BAN WHERE SELKZ EQ 'X'.
    CLEAR LEERFLG.
*- Banf ist keine Konsiposition ---------------------------------------*
    IF BAN-PSTYP NE PSTYP-KONS.
      IF KNS-MATNR EQ SPACE.
        LEERFLG = 'Y'.
      ENDIF.
*- Selektionskennzeichen zurücksetzen ---------------------------------*
      BAN-SELKZ = SPACE.
      MODIFY BAN.
      PERFORM SEL_KENNZEICHNEN.
      CHECK BAN-PSTYP EQ PSTYP-KONS.
    ENDIF.
    IF KNS-MATNR NE SPACE.
*- Daten nicht gleich - Meldung ---------------------------------------*
      IF BAN-MATNR NE KNS-MATNR OR
         BAN-WERKS NE KNS-WERKS.
        MESSAGE S225.
        EXITFLAG = 'X'.
        EXIT.
      ENDIF.
*- Daten gleich - ok. -------------------------------------------------*
    ELSE.
      MOVE-CORRESPONDING BAN TO KNS.
      INDEX_BAN = SY-TABIX.
      CLEAR LEERFLG.
    ENDIF.
  ENDLOOP.

*- Verlassen Routine, wenn Fehler aufgetreten -------------------------*
  CHECK EXITFLAG EQ SPACE.

  CASE LEERFLG.
    WHEN 'X'.
*- Keine markierte Zeile gefunden - Prüfen auf Line-Selection ---------*
      IF HIDE-INDEX NE 0.
        PERFORM VALID_LINE.
        CHECK EXITFLAG EQ SPACE.
        READ TABLE BAN INDEX HIDE-INDEX.
        IF BAN-PSTYP NE PSTYP-KONS.
          MESSAGE S210.
          CLEAR HIDE-INDEX.
          EXIT.
        ENDIF.
        INDEX_BAN = SY-TABIX.
*- Ausgeben Konsiliste ------------------------------------------------*
        PERFORM KONSI_LISTE.
        EXIT.
      ELSE.
*- Keine markierte Banf - Meldung: zuerst markieren -------------------*
        MESSAGE S222.
        EXIT.
      ENDIF.
*- Keine markierte Banf mit Positionstyp 'K' - Meldung ----------------*
    WHEN 'Y'.
      MESSAGE S210.
      EXIT.
  ENDCASE.

*- Ausgabe Konsiliste für die markierten ------------------------------*
  READ TABLE BAN INDEX INDEX_BAN.
  CLEAR INDEX_BAN.
  PERFORM KONSI_LISTE.

  CLEAR HIDE-INDEX.

ENDFORM.
