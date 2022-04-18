*eject
*----------------------------------------------------------------------*
*        Lesen Material-Konsipreissegment                              *
*----------------------------------------------------------------------*
FORM LESEN_MATERIAL_KONSI.

  CALL FUNCTION 'MATERIAL_LESEN' "#EC CI_FLDEXT_OK[2215424] P30K909996
       EXPORTING
            SCHLUESSEL = MTCOM
       IMPORTING
            MATDATEN   = MT06K
            RETURN     = MTCOR
       TABLES
            SEQMAT01   = KON.

ENDFORM.
