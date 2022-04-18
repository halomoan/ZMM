*eject
*----------------------------------------------------------------------*
*   Hide fuer Liste Zuordnungen
*----------------------------------------------------------------------*
FORM ZUG_HIDE.

HIDE-ZEILE = SY-LINNO.
HIDE-PAGE  = SY-PAGNO.
HIDE: S-FIRSTIND, S-MAXIND, ZUG-UPDKZ,
      HIDE-ZEILE, HIDE-PAGE.
CLEAR: HIDE-ZEILE, HIDE-PAGE.

ENDFORM.
