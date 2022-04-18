*eject
*----------------------------------------------------------------------*
*     Anzeigen Infosätze zum Material
*----------------------------------------------------------------------*
FORM UCOMM_LINF.

  CHECK LISTE EQ 'G'.

  LEERFLG = 'X'.
  CLEAR: INF, INDEX_BAN, EXITFLAG.

*- Suchen einer markierten Position -----------------------------------*
  LOOP AT BAN WHERE SELKZ EQ 'X'.
    PERFORM WARNING_UPDK3.
    CLEAR LEERFLG.
    IF INF-MATNR NE SPACE.
*- Daten nicht gleich - Meldung ---------------------------------------*
      IF BAN-MATNR NE INF-MATNR OR
         BAN-WERKS NE INF-WERKS.
        MESSAGE S225.
        EXITFLAG = 'X'.
        EXIT.
      ENDIF.
    ELSE.
      IF INF-MATKL NE SPACE.
        IF BAN-MATKL NE INF-MATKL OR
           BAN-WERKS NE INF-WERKS.
          MESSAGE S225.
          EXITFLAG = 'X'.
          EXIT.
        ENDIF.
      ENDIF.
    ENDIF.
*- Daten gleich - ok. -------------------------------------------------*
    MOVE-CORRESPONDING BAN TO INF.
    INDEX_BAN = SY-TABIX.
  ENDLOOP.

*- Verlassen Routine, wenn Fehler aufgetreten -------------------------*
  CHECK EXITFLAG EQ SPACE.

  IF LEERFLG NE SPACE.
*- Keine markierten Zeilen gefunden - Prüfen auf Line-Selection -------*
    IF HIDE-INDEX NE 0.
      PERFORM VALID_LINE.
      CHECK EXITFLAG EQ SPACE.
      READ TABLE BAN INDEX HIDE-INDEX.
      PERFORM WARNING_UPDK3.
      INDEX_BAN = SY-TABIX.
*- Aufruf Report ------------------------------------------------------*
      PERFORM AUFRUF_INFOSAETZE.
      CHECK EXITFLAG EQ SPACE.
*- Modifizieren Banf-Tabelle mit Zuordnungsdaten ----------------------*
      PERFORM BAN_UPDATE_LINF.
      EXIT.
*- Keine markierten Zeilen gefunden - bitte zuerst markieren ----------*
    ELSE.
      MESSAGE S222.
      EXIT.
    ENDIF.
  ENDIF.

*- Aufruf Report ------------------------------------------------------*
  READ TABLE BAN INDEX INDEX_BAN.
  PERFORM AUFRUF_INFOSAETZE.
  CHECK EXITFLAG EQ SPACE.
*- Modifizieren der Listzeilen mit zugeordnetem Rahmenvertrag ---------*
  LOOP AT BAN WHERE SELKZ EQ 'X'.
    INDEX_BAN = SY-TABIX.
*- Sonderzeile in Liste aufbauen --------------------------------------*
    PERFORM BAN_UPDATE_LINF.
  ENDLOOP.

  CLEAR HIDE-INDEX.

ENDFORM.
