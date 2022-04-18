*eject
*----------------------------------------------------------------------*
*     Anfragezuordnung zu mehreren Lieferanten
*----------------------------------------------------------------------*
FORM UCOMM_ANFL.

  CHECK SY-PFKEY EQ 'BEAR' OR
        SY-PFKEY EQ 'DBEA'.
  LEERFLG = 'X'.
  CLEAR INDEX_BAN.

*- Suchen einer markierten Position -----------------------------------*
  LOOP AT BAN WHERE SELKZ EQ 'X'.
    PERFORM WARNING_UPDK3.
    CLEAR LEERFLG.
    BAN-SELKZ = '*'.
    MODIFY BAN.
    INDEX_BAN = SY-TABIX.
*- POP-UP für Lieferanteneingabe senden -------------------------------*
    PERFORM ALF_INIT.
    CALL SCREEN 103 STARTING AT 5 6
                    ENDING   AT 60 14.
*- Zeile Zugeordnet ... aufbauen --------------------------------------*
    PERFORM BAN_UPDATE_ANFL.
*- für eine Position ausgeführt - Schleife verlassen ------------------*
    EXIT.
  ENDLOOP.

*- Keine markierte Zeile gefunden -------------------------------------*
  IF LEERFLG NE SPACE.
*- Prüfen auf Line-Selection ------------------------------------------*
    IF HIDE-INDEX NE 0.
      READ TABLE BAN INDEX HIDE-INDEX.
      PERFORM WARNING_UPDK3.
      INDEX_BAN = SY-TABIX.
*- POP-UP für Lieferanteneingabe senden -------------------------------*
      PERFORM ALF_INIT.
      CALL SCREEN 103 STARTING AT 5 6
                      ENDING   AT 60 14.
*- Zeile Zugeordnet ... aufbauen --------------------------------------*
      PERFORM BAN_UPDATE_ANFL.
    ELSE.
*- Funktion konnte für keine Zeile ausgeführt werden - vorher markieren*
      MESSAGE S222.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.
