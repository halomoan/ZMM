*eject
*----------------------------------------------------------------------*
*  Ausgeben Zuordnungszeile ohne Rahmenvertrag                         *
*----------------------------------------------------------------------*
FORM zug_summe_ohne.

  FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
  WRITE: /  sy-vline,
          2  zug-ekorg,
             zug-bsart,
             zug-bukrs,
          17 text-121,
        58 S-ZAEHLER,
          85 sy-vline.
  CLEAR s-zaehler.
  PERFORM zug_hide.

ENDFORM.
