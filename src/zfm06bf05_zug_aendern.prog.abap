*eject
*----------------------------------------------------------------------*
*    Geänderte Zuordnung in Banf fortschreiben
*----------------------------------------------------------------------*
FORM ZUG_AENDERN.

  DATA: lf_dirty LIKE sy-subrc.
  CLEAR: zsich, zenqu, zaend, zbere, znoup.
  PERFORM bat_aufbauen CHANGING lf_dirty.
  PERFORM AENDERN_BANFS.
  PERFORM BAN_UPDATE USING 'B'.
  PERFORM ZUG_MODIF_ZEILE USING TEXT-117.

ENDFORM.                    "ZUG_AENDERN
