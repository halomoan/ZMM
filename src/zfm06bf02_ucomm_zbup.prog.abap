*eject
*----------------------------------------------------------------------*
*    Ändern Bestellanforderungen
*----------------------------------------------------------------------*
FORM UCOMM_ZBUP.

  CHECK SY-PFKEY EQ 'ZALL' OR
        SY-PFKEY EQ 'ZBUB'.
  IF S-FIRSTIND EQ 0 OR
     ZUG-UPDKZ EQ ANFR OR
     ZUG-UPDKZ EQ ALIF.
    MESSAGE S201.
    EXIT.
  ENDIF.

  PERFORM ZUG_AENDERN.
  PERFORM ZUG_CLEAR.

ENDFORM.
