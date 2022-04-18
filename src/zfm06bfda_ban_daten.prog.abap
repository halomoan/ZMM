*eject
*----------------------------------------------------------------------*
* Daten für Banfliste bereitstellen
*----------------------------------------------------------------------*
FORM BAN_DATEN USING BDA_LFLAG.

CLEAR HROUTN.
HROUTN(10) = 'BAN_DATEN_'.
LOOP AT XT16LI.
   CASE BDA_LFLAG.
      WHEN 'G'. CHECK XT16LI-XGRLI NE SPACE.
      WHEN 'D'. CHECK XT16LI-XDELI NE SPACE.
   ENDCASE.
   HROUTN+10(3) = XT16LI-LDATE.
   PERFORM (HROUTN) IN PROGRAM SAPFM06B.
ENDLOOP.
*- Für MDSTA-Mengenfelder ---------------------------------------------*
MARA-MEINS = EBAN-MEINS.

ENDFORM.
