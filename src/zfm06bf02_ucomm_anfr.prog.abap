*eject
*----------------------------------------------------------------------*
*     Anfragezuordnung
*----------------------------------------------------------------------*
FORM UCOMM_ANFR.

  CHECK SY-PFKEY EQ 'BEAR' OR
        SY-PFKEY EQ 'DBEA'.
  LEERFLG = 'X'.
  CLEAR INDEX_BAN.
  CLEAR REJECT.                                             "49610

*- Suchen einer markierten Position -----------------------------------*
  LOOP AT BAN WHERE SELKZ EQ 'X'.
    PERFORM DET_CHECK.
    CHECK SY-SUBRC EQ 0.
    PERFORM WARNING_UPDK3.
    CLEAR LEERFLG.
*- Wunschlieferant/fester Lieferant vorhanden - Flag setzen -----------*
    IF BAN-FLIEF NE SPACE OR
       BAN-LIFNR NE SPACE.
      LEERFLG = 'Y'.
      EXIT.
    ENDIF.
  ENDLOOP.

  CASE LEERFLG.
*- mind. 1 Banf hat festen Lieferanten oder Wunschlieferanten - POP-UP *
    WHEN 'Y'.
      CLEAR: REJECT, ANSWER.
      CALL SCREEN 102 STARTING AT 10 6
                      ENDING   AT 51 16.
*- Keine markierte Zeile gefunden -------------------------------------*
    WHEN 'X'.
*- Prüfen auf Line-Selection ------------------------------------------*
      IF HIDE-INDEX NE 0.
        READ TABLE BAN INDEX HIDE-INDEX.
        PERFORM WARNING_UPDK3.
        INDEX_BAN = SY-TABIX.
*- Wunschlieferant in Bestellanforderung vorhanden - f.Zuordn. vorschlg*
        IF BAN-FLIEF NE SPACE OR
           BAN-LIFNR NE SPACE.
          CLEAR: REJECT, ANSWER.
          CALL SCREEN 102 STARTING AT 10 6
                          ENDING   AT 51 16.
          IF REJECT NE SPACE.
            EXIT.
          ENDIF.
          CASE ANSWER.
*- mit Lieferanten vormerken für Anfragebearbeitung -------------------*
            WHEN 'Y'.
              PERFORM BAN_UPDATE_ALIF.
*- ohne Lieferanten vormerken für Anfragebearbeitung ------------------*
            WHEN 'N'.
              PERFORM BAN_UPDATE_ANFR.
          ENDCASE.
*- Kein Wunschlieferant in Bestellanforderung - Vormerken f. Anfrage --*
        ELSE.
          PERFORM BAN_UPDATE_ANFR.
        ENDIF.
        EXIT.
      ELSE.
*- Funktion konnte für keine Zeile ausgeführt werden - vorher markieren*
        MESSAGE S222.
        EXIT.
      ENDIF.
  ENDCASE.

*- Markierte Banfs vormerken für Anfrage (mit oder ohne Lieferant) ----*
  LOOP AT BAN WHERE SELKZ = 'X'.
    PERFORM DET_CHECK.
    CHECK SY-SUBRC EQ 0.
    INDEX_BAN = SY-TABIX.
*- Window wurde abgebrochen - nicht vormerken, nächste Banf -----------*
    IF REJECT NE SPACE.
      CHECK REJECT EQ SPACE.
    ENDIF.
    IF BAN-FLIEF NE SPACE OR
       BAN-LIFNR NE SPACE.
*- Banf enthält Lieferanten -------------------------------------------*
      CASE ANSWER.
*- mit Lieferanten vormerken für Anfragebearbeitung -------------------*
        WHEN 'Y'.
          PERFORM BAN_UPDATE_ALIF.
*- ohne Lieferanten vormerken für Anfragebearbeitung ------------------*
        WHEN 'N'.
          PERFORM BAN_UPDATE_ANFR.
      ENDCASE.
*- Banf enthält keinen Lieferanten ------------------------------------*
    ELSE.
      PERFORM BAN_UPDATE_ANFR.
    ENDIF.
  ENDLOOP.

ENDFORM.
