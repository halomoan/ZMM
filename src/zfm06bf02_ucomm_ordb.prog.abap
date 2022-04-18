*eject
*----------------------------------------------------------------------*
*        Zuordnen nach Orderbuch                                       *
*----------------------------------------------------------------------*
FORM UCOMM_ORDB.

  DATA: MSG_FLAG.

  CHECK SY-PFKEY EQ 'BEAR' OR
        SY-PFKEY EQ 'ZUOR' OR
        SY-PFKEY EQ 'DBEA' OR
        SY-PFKEY EQ 'DZUO'.

  LEERFLG = 'X'.

*- Suchen einer markierten Position -----------------------------------*
  LOOP AT BAN WHERE SELKZ EQ 'X'.
    CLEAR LEERFLG.
    INDEX_BAN = SY-TABIX.
*- Suchen einer gültigen Bezugsquelle ---------------------------------*
    PERFORM BEZUGSQUELLE_3.
    IF MSG_FLAG EQ SPACE AND BAN-RESWK EQ SPACE AND BAN-FLIEF EQ SPACE
       AND BAN-BESWK EQ SPACE " CCP
       AND BAN-KONNR EQ SPACE.
      MESSAGE S577(06).                "nicht zu allen was gefunden
      MSG_FLAG = 'X'.
    ENDIF.
    PERFORM BAN_UPDATE_ORDR.
  ENDLOOP.

  IF LEERFLG NE SPACE.
*- Keine markierte Zeile gefunden - Prüfen auf Line-Selection ---------*
    IF HIDE-INDEX NE 0.
      READ TABLE BAN INDEX HIDE-INDEX.
      INDEX_BAN = SY-TABIX.
*- Suchen einer gültigen Bezugsquelle ---------------------------------*
      PERFORM BEZUGSQUELLE_3.
      PERFORM BAN_UPDATE_ORDR.
      IF NOT_ALL_ORDB NE SPACE.
        MESSAGE S553(06).
      ENDIF.
    ELSE.
*- Funktion konnte für keine Zeile ausgeführt werden - vorher markieren*
      MESSAGE S222.
      EXIT.
    ENDIF.
  ELSE.
    IF NOT_ALL_ORDB NE SPACE.
      MESSAGE S551(06).
    ENDIF.
  ENDIF.

  CLEAR NOT_ALL_ORDB.

ENDFORM.
