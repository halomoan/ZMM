*eject
*----------------------------------------------------------------------*
*  Ausgeben Zeile ohne Zuordnung                                       *
*----------------------------------------------------------------------*
FORM zug_summe_znix.

  FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
  WRITE: /  sy-vline,
          2  zug-ekorg,
             zug-bsart,
             zug-bukrs,
          17 text-122,
        58 S-ZAEHLER,
          85 sy-vline.
  CLEAR s-zaehler.
  PERFORM zug_hide.

ENDFORM.
