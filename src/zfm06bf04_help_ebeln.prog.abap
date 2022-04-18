*EJECT
*----------------------------------------------------------------------*
*        F4-Hilfe bei externer Belegnummer                             *
*----------------------------------------------------------------------*
FORM HELP_EBELN USING HEE_FELD.

  MESSAGE S246(06).
  SET CURSOR FIELD HEE_FELD.

ENDFORM.
