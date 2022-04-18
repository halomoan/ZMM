*eject
*---------------------------------------------------------------------*
*  Durchführen der Zuordnung für Batch                                *
*---------------------------------------------------------------------*
FORM ZUORDNEN.

  PERFORM INIT_EFUBE.
  IF com-srtkz EQ '0'.                  "823004
    SORT BAN BY MATNR WERKS ASCENDING.
  ELSE.                                 "823004
    PERFORM ban_sort.                   "823004
  ENDIF.                                "823004
  LOOP AT BAN.
    INDEX_BAN = SY-TABIX.
    PERFORM BEZUGSQUELLE_4.
  ENDLOOP.
  PERFORM BAN_AENDERN.

ENDFORM.
