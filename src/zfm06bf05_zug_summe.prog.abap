*eject
*----------------------------------------------------------------------*
*  Ausgeben Zeile Zuordnungssumme                                      *
*----------------------------------------------------------------------*
FORM zug_summe.

  IF izaehl GT 99999.
    WRITE '99999' TO s-zaehler NO-SIGN.
  ELSE.
    WRITE izaehl TO s-zaehler NO-SIGN.
  ENDIF.
  CLEAR izaehl.

  CASE zug-updkz.
*- Zugeordnete Banfs --------------------------------------------------*
    WHEN zold.
      IF zug-konnr NE space.                 "Kontrakt
        IF lzeile EQ space.
          PERFORM zug_summe_lief.
        ENDIF.
        PERFORM zug_summe_rahm.
      ELSEIF zug-fordn NE space.             "Rahmenbestellung
        IF lzeile EQ space.
          PERFORM zug_summe_lief.
        ENDIF.
        PERFORM zug_summe_best.
      ELSE.                                  "Fester Lieferant
        IF lzeile EQ space.
          PERFORM zug_summe_lief.
        ENDIF.
        PERFORM zug_summe_ohne.
      ENDIF.

*- Zur Anfragebearbeitung vorgemerkte Banfs ---------------------------*
    WHEN anfr.
      IF lzeile EQ space.
        PERFORM zug_summe_lief.
      ENDIF.
      PERFORM zug_summe_anfr.

*- Zuordnungen zurückgenommen -----------------------------------------*
    WHEN zres.
      IF lzeile EQ space.
        PERFORM zug_summe_lief.
      ENDIF.
      PERFORM zug_summe_zres.

*- Zur Anfrage vorgemerkte - Zu mehreren Lieferanten ------------------*
    WHEN alif.
      IF lzeile EQ space.
        PERFORM zug_summe_lief.
      ENDIF.
      PERFORM zug_summe_anfr.

*- Keine Zuordnung ----------------------------------------------------*
    WHEN znix.
      IF lzeile EQ space.
        PERFORM zug_summe_lief.
      ENDIF.
      PERFORM zug_summe_znix.

  ENDCASE.

ENDFORM.                    "zug_summe
