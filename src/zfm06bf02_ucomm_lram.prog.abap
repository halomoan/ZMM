*eject
*----------------------------------------------------------------------*
*     Anzeigen Rahmenvertraege zum Material                            *
*----------------------------------------------------------------------*
FORM UCOMM_LRAM.

  CHECK LISTE EQ 'G'.

  LEERFLG = 'X'.
  CLEAR: MAT, INDEX_BAN, EXITFLAG.

*- Suchen einer markierten Position -----------------------------------*
  LOOP AT BAN WHERE SELKZ EQ 'X'.
    CLEAR LEERFLG.
*- Banf hat keine Materialnummer --------------------------------------*
    IF BAN-MATNR EQ SPACE.
      IF MAT-MATNR EQ SPACE.
        LEERFLG = 'Y'.
      ENDIF.
*- Selektionskennzeichen zurücksetzen      ----------------------------*
      BAN-SELKZ = SPACE.
      MODIFY BAN.
      PERFORM SEL_KENNZEICHNEN.
      CHECK BAN-MATNR NE SPACE.
    ENDIF.
    IF MAT-MATNR NE SPACE.
*- Daten nicht gleich - Meldung ---------------------------------------*
      IF BAN-MATNR NE MAT-MATNR OR
         BAN-BSART NE MAT-BSART OR
         BAN-PSTYP NE MAT-PSTYP OR
         BAN-KNTTP NE MAT-KNTTP OR
         BAN-WERKS NE MAT-WERKS.
        MESSAGE S225.
        EXITFLAG = 'X'.
        EXIT.
      ENDIF.
*- Daten gleich - ok. -------------------------------------------------*
    ELSE.
      MOVE-CORRESPONDING BAN TO MAT.
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
        READ TABLE BAN INDEX HIDE-INDEX.
        IF BAN-MATNR EQ SPACE.
          MESSAGE S209.
          CLEAR HIDE-INDEX.
          EXIT.
        ENDIF.
        INDEX_BAN = SY-TABIX.
*- Aufruf Report ------------------------------------------------------*
        PERFORM AUFRUF_MATERIALNUMMER.
        CHECK EXITFLAG EQ SPACE.
        PERFORM BAN_UPDATE_RAHM.
        EXIT.
      ELSE.
*- Keine markierte Banf - Meldung: zuerst markieren -------------------*
        MESSAGE S222.
        EXIT.
      ENDIF.
*- Keine markierte Banf mit Material - Meldung: Pos. mit Material sel.-*
    WHEN 'Y'.
      MESSAGE S209.
      EXIT.
  ENDCASE.

*- Aufruf Report für die markierten -----------------------------------*
  READ TABLE BAN INDEX INDEX_BAN.
  PERFORM AUFRUF_MATERIALNUMMER.
  CHECK EXITFLAG EQ SPACE.
*- Modifizieren der Listzeilen mit zugeordnetem Rahmenvertrag ---------*
  LOOP AT BAN WHERE SELKZ EQ 'X'.
    INDEX_BAN = SY-TABIX.
    PERFORM BAN_UPDATE_RAHM.
  ENDLOOP.

  CLEAR HIDE-INDEX.

ENDFORM.
