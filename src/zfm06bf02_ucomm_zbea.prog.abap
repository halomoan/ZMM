*eject
*----------------------------------------------------------------------*
*    Bearbeiten Zuordnung
*----------------------------------------------------------------------*
FORM UCOMM_ZBEA.

  CHECK SY-PFKEY EQ 'ZALL' OR
        SY-PFKEY EQ 'ZBST'.

  IF S-FIRSTIND EQ 0 OR
     ZUG-UPDKZ EQ ZNIX OR
     ZUG-UPDKZ EQ ZRES.
    MESSAGE S201.
    EXIT.
  ENDIF.

  PERFORM ZUG_BEARBEITEN.
  PERFORM ZUG_CLEAR.

ENDFORM.
