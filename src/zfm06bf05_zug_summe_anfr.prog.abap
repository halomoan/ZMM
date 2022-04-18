*eject
*----------------------------------------------------------------------*
*  Ausgeben Anfragezeile                                               *
*----------------------------------------------------------------------*
FORM zug_summe_anfr.

  FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
  WRITE: /   sy-vline,
          2  zug-ekorg,
             zug-bsart,
             zug-bukrs,
          17 text-120,
        58 S-ZAEHLER,
          85 sy-vline.
  CLEAR s-zaehler.
  PERFORM zug_hide.

ENDFORM.
