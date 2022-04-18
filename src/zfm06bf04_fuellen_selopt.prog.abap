*eject
*----------------------------------------------------------------------*
*        Select-Options für Rahmenverträge füllen                      *
*----------------------------------------------------------------------*
FORM FUELLEN_SELOPT.

*- Gültige Belegarten und Positionstypen ermitteln --------------------*
  REFRESH: SEL_BSART, SEL_PSTYP.
  CLEAR  : SEL_BSART, SEL_PSTYP.
  SEL_BSART-SIGN = 'I'.
  SEL_BSART-OPTION = 'EQ'.
  SEL_PSTYP-SIGN = 'I'.
  SEL_PSTYP-OPTION = 'EQ'.

* SELECT * FROM T161A WHERE BANBS EQ BAN-BSART
*                     AND   BANPT EQ BAN-PSTYP
*                     AND   LFPET NE SPACE.
  SELECT * FROM T161A WHERE BANBS EQ BAN-BSART
                      AND   BANPT EQ BAN-PSTYP.
    IF BAN-KNTTP NE SPACE.
      CHECK T161A-KONTI EQ SPACE.
    ENDIF.
    SEL_BSART-LOW = T161A-BSTBS.
    COLLECT SEL_BSART.
    SEL_PSTYP-LOW = T161A-BSTPT.
    COLLECT SEL_PSTYP.
  ENDSELECT.

*- Anz. RV zur Materialklasse und Materialnummer nicht initial
*- nur RVs mit Positionstyp 'M' oder 'W'
  IF SY-UCOMM EQ 'LRAC' AND
     BAN-MATNR NE SPACE.
    REFRESH SEL_PSTYP.
    CLEAR   SEL_PSTYP.
    SEL_PSTYP-SIGN = 'I'.
    SEL_PSTYP-OPTION = 'EQ'.
    SEL_PSTYP-LOW = '4'. COLLECT SEL_PSTYP.
    SEL_PSTYP-LOW = '8'. COLLECT SEL_PSTYP.
  ENDIF.
*- Einschränken M/W nach Funktionsberechtigung ------------------------*
  IF T160D-EBZKA NE SPACE.
    IF BAN-MATNR NE SPACE AND
       T160D-EBZKM EQ SPACE AND
       T160D-EBZKW EQ SPACE.
    ELSE.
      IF T160D-EBZKM EQ SPACE.
        LOOP AT SEL_PSTYP WHERE LOW EQ '4'.
          DELETE SEL_PSTYP.
        ENDLOOP.
      ENDIF.
      IF T160D-EBZKW EQ SPACE.
        LOOP AT SEL_PSTYP WHERE LOW EQ '8'.
          DELETE SEL_PSTYP.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.

*- Prüfen, ob Selektionstabelle wenigstens einen Eintrag hat ----------*
  CLEAR EXITFLAG.
  READ TABLE SEL_BSART INDEX 1.
  IF SY-SUBRC EQ 0.
    READ TABLE SEL_PSTYP INDEX 1.
  ENDIF.
  IF SY-SUBRC NE 0.
    MESSAGE S208 WITH BAN-BSART BAN-PSTYP.
    EXITFLAG = 'X'.
    EXIT.
  ENDIF.

*- Selopt für Positionstyp ins externe Format bringen -----------------*
  CALL FUNCTION 'ME_ITEM_CATEGORY_SELOPT_OUTPUT'
       TABLES
            SEL_PSTYP = SEL_PSTYP.

*- Füllen gültige Werke in Selektionstabelle --------------------------*
  REFRESH SEL_WERKS.
  SEL_WERKS-SIGN = 'I'.
  SEL_WERKS-OPTION = 'EQ'.
  SEL_WERKS-LOW = SPACE.
  APPEND SEL_WERKS.
  SEL_WERKS-LOW = BAN-WERKS.
  APPEND SEL_WERKS.

*- Füllen gültige Kontierungstypen in Selektionstabelle ---------------*
  REFRESH SEL_KNTTP.
  SEL_KNTTP-SIGN = 'I'.
  SEL_KNTTP-OPTION = 'EQ'.
  IF BAN-KZVBR NE 'U'.
    SEL_KNTTP-LOW = SPACE.
    APPEND SEL_KNTTP.
    IF BAN-KNTTP NE SPACE.
      SEL_KNTTP-LOW = BAN-KNTTP.
      APPEND SEL_KNTTP.
      SEL_KNTTP-LOW = 'U'.
      APPEND SEL_KNTTP.
    ENDIF.
  ENDIF.

ENDFORM.
