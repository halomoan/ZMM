*eject
*----------------------------------------------------------------------*
*  Auswählen Bestellanforderung                                       *
*----------------------------------------------------------------------*
FORM UCOMM_AUSW.

  CHECK SY-PFKEY EQ 'LISA'.
  LEERFLG = 'X'.

*- Suchen einer markierten Position -----------------------------------*
  LOOP AT BAN WHERE SELKZ EQ 'X'.
    CLEAR LEERFLG.
    PERFORM CUEB_FUELLEN.
  ENDLOOP.

  IF LEERFLG NE SPACE.
*- Keine markierte Zeile gefunden - Prüfen auf Line-Selection ---------*
    IF HIDE-INDEX NE 0.
      PERFORM VALID_LINE.
      CHECK EXITFLAG EQ SPACE.
      READ TABLE BAN INDEX HIDE-INDEX.
      PERFORM CUEB_FUELLEN.
    ELSE.
*- Funktion konnte für keine Zeile ausgeführt werden - vorher markieren*
      MESSAGE S222.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.
