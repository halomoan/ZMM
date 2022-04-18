*eject
*---------------------------------------------------------------------*
*  T160D-Parameter setzen für Bezugsquellen                           *
*---------------------------------------------------------------------*
FORM BQPIM_T160D_SETZEN.

  IF T160D-EBZKA EQ SPACE.             "Kontrakte zuordnen nicht erlaubt
    BQPIM-EBZKA = 'X'.
  ENDIF.
  IF T160D-EBZKM EQ SPACE.  "Kontrakte Postyp M zuordnen nicht erlaubt
    BQPIM-EBZKM = 'X'.
  ENDIF.
  IF T160D-EBZKW EQ SPACE.  "Kontrakte Postyp W zuordnen nicht erlaubt
    BQPIM-EBZKW = 'X'.
  ENDIF.
  IF T160D-EBZIN EQ SPACE.             "Infosätze zuordnen nicht erlaubt
    BQPIM-EBZIN = 'X'.
  ENDIF.
 IF T160D-EBZOM EQ SPACE.  "Pos ohne Material --> zuordnen nicht erlaubt
    BQPIM-EBZOM = 'X'.
  ENDIF.

ENDFORM.
