*----------------------------------------------------------------------*
*  Ausgeben Zeile Rahmenbestellung                                     *
*----------------------------------------------------------------------*
FORM zug_summe_best.

  SELECT SINGLE *
         INTO :*ekko
         FROM ekko
         WHERE ebeln = zug-fordn.
  FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
  WRITE: /   sy-vline,
          2  zug-ekorg,
             zug-bsart,
             zug-bukrs,
          17 zug-fordn, *ekko-bsart,
             *ekko-kdatb DD/MM/YYYY, *ekko-kdate DD/MM/YYYY,
        58 S-ZAEHLER,
          85 sy-vline.
  CLEAR s-zaehler.
  PERFORM zug_hide.

ENDFORM.
