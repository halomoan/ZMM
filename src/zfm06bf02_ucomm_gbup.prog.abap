*eject
*----------------------------------------------------------------------*
*    Ändern Banfs aus Grundliste
*----------------------------------------------------------------------*
FORM UCOMM_GBUP.

  CHECK LISTE EQ 'G'.
  CHECK SY-PFKEY EQ 'ZUOR' OR
        SY-PFKEY EQ 'BEAR'.
  PERFORM BAN_AENDERN.

ENDFORM.
