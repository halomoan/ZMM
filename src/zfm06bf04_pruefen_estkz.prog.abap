*eject
*----------------------------------------------------------------------*
*        Pruefen Erstellungskennzeichen      92105   - neu zu 3.1I/4.0C*
*----------------------------------------------------------------------*
FORM PRUEFEN_ESTKZ.

  CLEAR: COUNTA, COUNTN.
*- Ermitteln alten Tabellenindex --------------------------------------*
  DESCRIBE TABLE BAT LINES COUNTA.

*- Bereinigen Übergabetabelle um die nicht teilbestellbaren Banfs -----*
  LOOP AT BAT.
    CHECK BAT-ESTKZ EQ 'V'.
    IF BAT-BSMNG NE 0.
      DELETE BAT.
    ENDIF.
  ENDLOOP.

*- Ermitteln neuen Tabellenindex --------------------------------------*
  DESCRIBE TABLE BAT LINES COUNTN.
  IF COUNTN LT COUNTA.
*- kein Eintrag mehr in Übergabetabelle -------------------------------*
    IF COUNTN EQ 0.
      MESSAGE E580.
    ELSE.
*- einige sind rausgeflogen -------------------------------------------*
      MESSAGE S579.
    ENDIF.
  ENDIF.

ENDFORM.
