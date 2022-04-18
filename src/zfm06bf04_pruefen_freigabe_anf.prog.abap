*eject
*----------------------------------------------------------------------*
*        Pruefen, ob Banfs für Anfrage freigegeben                     *
*----------------------------------------------------------------------*
FORM PRUEFEN_FREIGABE_ANF.

*- Ermitteln alten Tabellenindex --------------------------------------*
  DESCRIBE TABLE BAT LINES COUNTA.

*- Bereinigen Übergabetabelle um die nicht freigegebenen Banfs --------*
  LOOP AT BAT.
    IF BAT-FRGKZ NE SPACE.
      SELECT SINGLE * FROM T161S WHERE FRGKZ EQ BAT-FRGKZ.
      IF T161S-FRANG EQ SPACE.
        DELETE BAT.
      ENDIF.
    ENDIF.
  ENDLOOP.

*- Ermitteln neuen Tabellenindex --------------------------------------*
  DESCRIBE TABLE BAT LINES COUNTN.
  IF COUNTN LT COUNTA.
*- kein Eintrag mehr in Übergabetabelle -------------------------------*
    IF COUNTN EQ 0.
      MESSAGE E263.
    ELSE.
*- einige sind rausgeflogen -------------------------------------------*
      MESSAGE S262.
    ENDIF.
  ENDIF.

ENDFORM.
