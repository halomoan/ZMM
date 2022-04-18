*eject
*----------------------------------------------------------------------*
*     Verzweigen in die Einzelfreigabe der Bestellanforderung
*----------------------------------------------------------------------*
FORM UCOMM_ME54.

  CHECK SY-PFKEY EQ 'FREI'.
  LEERFLG = 'X'.

*- Suchen einer markierten Position -----------------------------------*
  LOOP AT BAN WHERE SELKZ EQ 'X'.
    CLEAR LEERFLG.
    PERFORM AUFRUF_EINZELFREIGABE.
*- für eine Position ausgeführt - Schleife verlassen ------------------*
    EXIT.
  ENDLOOP.

  IF LEERFLG NE SPACE.
*- Keine markierte Zeile gefunden - Prüfen auf Line-Selection ---------*
    IF HIDE-INDEX NE 0.
      READ TABLE BAN INDEX HIDE-INDEX.
      PERFORM AUFRUF_EINZELFREIGABE.
    ELSE.
*- Funktion konnte für keine Zeile ausgeführt werden - vorher markieren*
      MESSAGE S222.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.
