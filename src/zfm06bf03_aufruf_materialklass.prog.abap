*eject
*----------------------------------------------------------------------*
*        Aufruf Anzeigen Rahmenverträge zur Materialklasse             *
*----------------------------------------------------------------------*
FORM AUFRUF_MATERIALKLASSE.

*- Füllen gültige Vertragsarten und Positionstypen in Selektionstabelle*
  PERFORM FUELLEN_SELOPT.
  CHECK EXITFLAG EQ SPACE.
  CLEAR EXITFLAG.

*- Export Calkz nur bei Zuordnungsfunktion ----------------------------*
  CLEAR BUEB.
  BUEB-NRCFD = 'X'.
  IF ( SY-PFKEY EQ 'ZUOR' OR
       SY-PFKEY EQ 'BEAR' ) AND
     T160D-EBZKA NE SPACE.
    BUEB-CALKZ = 'X'.
    IF BAN-MATNR EQ SPACE AND
       T160D-EBZOM EQ SPACE.
      CLEAR BUEB-CALKZ.
    ENDIF.
    IF BAN-MATNR NE SPACE AND
       T160D-EBZKM EQ SPACE AND
       T160D-EBZKW EQ SPACE.
      CLEAR BUEB-CALKZ.
    ENDIF.
  ENDIF.
  SET PARAMETER ID 'EKO' FIELD SPACE.
  EXPORT BUEB TO MEMORY ID 'BUEB'. "#EC CI_FLDEXT_OK[2215424] P30K909996

*- Aufruf Report: Anzeigen Rahmenverträge zur Materialklasse ----------*
  SUBMIT RM06EC00 AND RETURN
         WITH EC_MATKL EQ BAN-MATKL
         WITH S_BSART IN SEL_BSART
         WITH S_PSTYP IN SEL_PSTYP
         WITH S_KNTTP IN SEL_KNTTP
         WITH S_WERKS IN SEL_WERKS.

*- Holen Übergabestruktur aus Memory ----------------------------------*
  IMPORT BUEB FROM MEMORY ID 'BUEB'. "#EC CI_FLDEXT_OK[2215424] P30K909996
*- Kein Rahmenvertrag gefunden ----------------------------------------*
  IF BUEB-NRCFD NE SPACE.
    MESSAGE S226.
    EXITFLAG = 'X'.
    EXIT.
  ELSE.
    IF BUEB-KONNR NE SPACE.
*- Festen Lieferanten überprüfen --------------------------------------
      CLEAR SY-UCOMM.                  "nützt leider nichts
      PERFORM BEZUGSQUELLE_1 USING SPACE.
      PERFORM BEZUGSQUELLE_2.
    ENDIF.
  ENDIF.

ENDFORM.
