*eject
*----------------------------------------------------------------------*
*        Auswählen Konsilieferant                                     *
*----------------------------------------------------------------------*
FORM UCOMM_KICK.

  CHECK SY-PFKEY EQ 'KONS'.
  PERFORM VALID_LINE.
  CHECK EXITFLAG EQ SPACE.
  READ TABLE KON INDEX HIDE-KOIND.

  IF INDEX_BAN EQ 0.
*- Mehrfachauswahl: Modifizieren Listzeilen mit Konsilieferanten ------*
    LOOP AT BAN WHERE SELKZ EQ 'X'.
      PERFORM BEZUGSQUELLE_5.          "zugelassen?
      BAN-SELKZ = '*'.
      INDEX_BAN = SY-TABIX.
      LSIND = 0.
      PERFORM BAN_UPDATE_KICK.
    ENDLOOP.

*- Line-Selektion -----------------------------------------------------*
  ELSE.
    PERFORM BEZUGSQUELLE_5.            "zugelassen?
*- Modifizieren Banf-Tabelle mit Zuordnungsdaten ----------------------*
    BAN-SELKZ = '*'.
    LSIND = 0.
    PERFORM BAN_UPDATE_KICK.
  ENDIF.

  SY-LSIND = 0.

ENDFORM.
