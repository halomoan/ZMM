*eject
*----------------------------------------------------------------------*
*     Anzeigen Bestellungen zur Banf
*----------------------------------------------------------------------*
FORM UCOMM_BEST.

  CHECK LISTE EQ 'G'.
  LEERFLG = 'X'.

*- Suchen einer markierten Position -----------------------------------*
  LOOP AT BAN WHERE SELKZ EQ 'X'.
    CLEAR LEERFLG.
    IF NOT BAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
      LOOP AT BAN WHERE BANFN EQ BAN-BANFN.
        BAN-SELKZ = '*'.
        MODIFY BAN.
      ENDLOOP.
    ELSE.
      BAN-SELKZ = '*'.
      MODIFY BAN.
    ENDIF.
*- Bestellungen anzeigen ----------------------------------------------*
    PERFORM AUFRUF_BESTELLUNGEN.
    IF EXITFLAG NE SPACE.
      EXIT.
    ENDIF.
*- Selektionskennzeichen modifizieren ---------------------------------*
    PERFORM SEL_KENNZEICHNEN.
*- für eine Position ausgeführt - Schleife verlassen ------------------*
    EXIT.
  ENDLOOP.

  IF LEERFLG NE SPACE.
*- Line-Selektion -----------------------------------------------------*
    IF HIDE-INDEX NE 0.
      READ TABLE BAN INDEX HIDE-INDEX.
*- Bestellungen anzeigen ----------------------------------------------*
      PERFORM AUFRUF_BESTELLUNGEN.
      CHECK EXITFLAG EQ SPACE.
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
