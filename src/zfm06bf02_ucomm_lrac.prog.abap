*eject
*----------------------------------------------------------------------*
*     Anzeigen Rahmenvertraege zur Materialklasse
*----------------------------------------------------------------------*
FORM UCOMM_LRAC.

  CHECK LISTE EQ 'G'.

  LEERFLG = 'X'.
  CLEAR: KLA, INDEX_BAN, EXITFLAG.

*- Suchen einer markierten Position -----------------------------------*
  LOOP AT BAN WHERE SELKZ EQ 'X'.
    CLEAR LEERFLG.
    IF KLA-MATKL NE SPACE.
*- Daten nicht gleich - Meldung ---------------------------------------*
      IF BAN-MATKL NE KLA-MATKL OR
         BAN-BSART NE KLA-BSART OR
         BAN-PSTYP NE KLA-PSTYP OR
         BAN-KNTTP NE KLA-KNTTP OR
         BAN-WERKS NE KLA-WERKS.
        MESSAGE S225.
        EXITFLAG = 'X'.
        EXIT.
      ENDIF.
*- Daten gleich - ok. -------------------------------------------------*
    ELSE.
      MOVE-CORRESPONDING BAN TO KLA.
      INDEX_BAN = SY-TABIX.
    ENDIF.
  ENDLOOP.

*- Verlassen Routine, wenn Fehler aufgetreten -------------------------*
  CHECK EXITFLAG EQ SPACE.

  IF LEERFLG NE SPACE.
*- Keine markierte Zeile gefunden - Prüfen auf Line-Selection ---------*
    IF HIDE-INDEX NE 0.
      READ TABLE BAN INDEX HIDE-INDEX.
      INDEX_BAN = SY-TABIX.
*- Aufruf Report ------------------------------------------------------*
      PERFORM AUFRUF_MATERIALKLASSE.
      CHECK EXITFLAG EQ SPACE.
      PERFORM BAN_UPDATE_RAHM.
      EXIT.
    ELSE.
*- Keine markierte Banf - Meldung: zuerst markieren -------------------*
      MESSAGE S222.
      EXIT.
    ENDIF.
  ENDIF.

*- Aufruf Report für die markierten -----------------------------------*
  READ TABLE BAN INDEX INDEX_BAN.
  PERFORM AUFRUF_MATERIALKLASSE.
  CHECK EXITFLAG EQ SPACE.
*- Modifizieren der Listzeilen mit zugeordnetem Rahmenvertrag ---------*
  LOOP AT BAN WHERE SELKZ EQ 'X'.
    INDEX_BAN = SY-TABIX.
    PERFORM BAN_UPDATE_RAHM.
  ENDLOOP.

  CLEAR HIDE-INDEX.

ENDFORM.
