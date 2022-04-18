*eject
*----------------------------------------------------------------------*
*   Zuordnung rücksetzen
*----------------------------------------------------------------------*
FORM UCOMM_ZRES.

  CHECK SY-PFKEY EQ 'ZUOR' OR
        SY-PFKEY EQ 'BEAR' OR
        SY-PFKEY EQ 'BDET' OR
        SY-PFKEY EQ 'DBDE' OR
        SY-PFKEY EQ 'DBEA' OR
        SY-PFKEY EQ 'DZUO'.
  LEERFLG = 'X'.

*- Suchen markierte Zeilen --------------------------------------------*
  LOOP AT BAN WHERE SELKZ EQ 'X'.
    CLEAR LEERFLG.
    INDEX_BAN = SY-TABIX.
    PERFORM BAN_UPDATE_ZRES.
  ENDLOOP.

  IF LEERFLG NE SPACE.
*- Keine markierte Zeile gefunden - Prüfen auf Line-Selection ---------*
    IF HIDE-INDEX NE 0.
      READ TABLE BAN INDEX HIDE-INDEX.
      INDEX_BAN = SY-TABIX.
      PERFORM BAN_UPDATE_ZRES.
    ELSE.
*- Funktion konnte für keine Zeile ausgeführt werden - vorher markieren*
      MESSAGE S222.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.
