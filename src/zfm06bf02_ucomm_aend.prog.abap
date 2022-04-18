*eject
*----------------------------------------------------------------------*
*        Anzeigen Änderungen                                           *
*----------------------------------------------------------------------*
FORM UCOMM_AEND.

  CHECK LISTE EQ 'G'.
  LEERFLG = 'X'.

*- Suchen einer markierten Position -----------------------------------*
  LOOP AT BAN WHERE SELKZ EQ 'X'.
    CLEAR LEERFLG.
    IF BAN-AENDA EQ SPACE.
      MESSAGE S242.
      EXIT.
    ENDIF.
    IF NOT BAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
      LOOP AT BAN WHERE BANFN EQ BAN-BANFN.
        BAN-SELKZ = '*'.
        MODIFY BAN.
      ENDLOOP.
    ELSE.
      BAN-SELKZ = '*'.
      MODIFY BAN.
    ENDIF.
*- Änderungen anzeigen ------------------------------------------------*
    PERFORM AUFRUF_AENDERUNGEN.
*- Selektionskennzeichen modifizieren ---------------------------------*
    PERFORM SEL_KENNZEICHNEN.
*- für eine Position ausgeführt - Schleife verlassen ------------------*
    EXIT.
  ENDLOOP.

*- Keine markierte Zeile gefunden -------------------------------------*
  IF LEERFLG NE SPACE.
*- Prüfen auf Line-Selection ------------------------------------------*
    IF HIDE-INDEX NE 0.
      READ TABLE BAN INDEX HIDE-INDEX.
      IF BAN-AENDA EQ SPACE.
        MESSAGE S242.
        EXIT.
      ENDIF.
*- Änderungen anzeigen ------------------------------------------------*
      PERFORM AUFRUF_AENDERUNGEN.
      IF NOT BAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
        LOOP AT BAN WHERE BANFN EQ BAN-BANFN.
          BAN-SELKZ = '*'.
          MODIFY BAN.
        ENDLOOP.
      ELSE.
        BAN-SELKZ = '*'.
        MODIFY BAN INDEX HIDE-INDEX.
      ENDIF.
*- falls auch zusätzlich angekreuzt - Stern setzen --------------------*
      PERFORM SEL_KENNZEICHNEN.
    ELSE.
*- Funktion konnte für keine Zeile ausgeführt werden - vorher markieren*
      MESSAGE S222.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.
