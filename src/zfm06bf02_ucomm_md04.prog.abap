*eject
*----------------------------------------------------------------------*
*        Anzeigen Aktuelle Bestands/Bedarfssituation                   *
*----------------------------------------------------------------------*
FORM UCOMM_MD04.

  CHECK LISTE EQ 'G'.
  LEERFLG = 'X'.

*- Suchen einer markierten Position -----------------------------------*
  LOOP AT BAN WHERE SELKZ EQ 'X'.
*- Zeile ohne Material geht nicht - zum nächsten markierten Eintrag ---*
    IF BAN-MATNR EQ SPACE.
      LEERFLG = 'Y'.
      CHECK BAN-MATNR NE SPACE.
    ENDIF.
    CLEAR LEERFLG.
    BAN-SELKZ = '*'.
    MODIFY BAN.
*- Bestands-/Bedarfs-Situation ----------------------------------------*
    SET PARAMETER ID 'MAT' FIELD BAN-MATNR. "#EC CI_FLDEXT_OK[2215424] P30K909996
    SET PARAMETER ID 'WRK' FIELD BAN-WERKS.
    SET PARAMETER ID 'BERID' FIELD SPACE.                   "896768
    CALL TRANSACTION 'MD04' AND SKIP FIRST SCREEN.
*- Selektionskennzeichen modifizieren ---------------------------------*
    PERFORM SEL_KENNZEICHNEN.
*- für eine Position ausgeführt - Schleife verlassen ------------------*
    EXIT.
  ENDLOOP.

  CASE LEERFLG.
*- Keine markierte Zeile gefunden - Prüfen auf Line-Selection ---------*
    WHEN 'X'.
      IF HIDE-INDEX NE 0.
        READ TABLE BAN INDEX HIDE-INDEX.
*- Zeile ohne Material geht nicht - zum nächsten markierten Eintrag ---*
        IF BAN-MATNR EQ SPACE.
          MESSAGE S272.
          CLEAR SY-UCOMM.
          EXIT.
        ENDIF.
*- Bestands-/Bedarfs-Situation ----------------------------------------*
        SET PARAMETER ID 'MAT' FIELD BAN-MATNR. "#EC CI_FLDEXT_OK[2215424] P30K909996
        SET PARAMETER ID 'WRK' FIELD BAN-WERKS.
        SET PARAMETER ID 'BERID' FIELD SPACE.               "896768
        CALL TRANSACTION 'MD04' AND SKIP FIRST SCREEN.
        BAN-SELKZ = '*'.
        MODIFY BAN INDEX HIDE-INDEX.
*- falls auch zusätzlich angekreuzt - Stern setzen --------------------*
        PERFORM SEL_KENNZEICHNEN.
        EXIT.
      ELSE.
*- Funktion konnte für keine Zeile ausgeführt werden - vorher markieren*
        MESSAGE S222.
        EXIT.
      ENDIF.
*- Es wurden nur Zeilen ohne Materialnummer markiert ------------------*
    WHEN 'Y'.
      MESSAGE S272.
      EXIT.
  ENDCASE.

*- alle Banfen kennzeichnen, die dieselbe Matnr haben u. selektiert sind
  LOOP AT BAN WHERE SELKZ EQ 'X' AND
                    MATNR EQ BAN-MATNR.
    BAN-SELKZ = '*'.
    MODIFY BAN.
    PERFORM SEL_KENNZEICHNEN.
  ENDLOOP.

ENDFORM.
