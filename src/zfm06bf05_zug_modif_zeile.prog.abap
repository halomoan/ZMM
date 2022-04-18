*eject
*----------------------------------------------------------------------*
*   Zeile in Zuordnungsüberssicht modifizieren
*----------------------------------------------------------------------*
FORM zug_modif_zeile USING zmz_text.

  IF bzaehl GT 99999.
    WRITE '99999' TO b-zaehler NO-SIGN.
  ELSE.
    WRITE bzaehl TO b-zaehler NO-SIGN.
  ENDIF.
  CLEAR bzaehl.

  READ LINE hide-zeile OF PAGE hide-page INDEX lsind.
  WRITE zmz_text TO sy-lisel+64(11).
  WRITE b-zaehler TO sy-lisel+76(5).
  MODIFY LINE hide-zeile OF PAGE hide-page INDEX lsind.
  CLEAR b-zaehler.

ENDFORM.
