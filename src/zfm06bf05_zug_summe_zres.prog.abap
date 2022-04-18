*eject
*----------------------------------------------------------------------*
*  Ausgeben Zurückgesetzt-Zeile                                        *
*----------------------------------------------------------------------*
FORM zug_summe_zres.

  FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
  WRITE: /   sy-vline,
          2  zug-ekorg,
             zug-bsart,
             zug-bukrs,
          17 text-115,
        58 S-ZAEHLER,
          85 sy-vline.
  CLEAR s-zaehler.
  PERFORM zug_hide.

ENDFORM.
