***INCLUDE FM06BFDA.
*eject
*----------------------------------------------------------------------*
* Daten für Banfliste dazulesen
*----------------------------------------------------------------------*
FORM ban_daten_pre.

*- Prüfen ob überhaupt Zusatzdaten gelesen werden müssen --------------*
  LOOP AT xt16li WHERE xpref NE space.
    EXIT.
  ENDLOOP.
  CHECK sy-subrc EQ 0.

*- Liste der Schlüssel aufbauen aus jeder Banf ------------------------*
  REFRESH xpre01.
  CLEAR hroutn.
  hroutn(14) = 'BAN_DATEN_PR1_'.
  LOOP AT ban.
    LOOP AT xt16li WHERE xpref NE space.
      hroutn+14(3) = xt16li-ldate.
*      PERFORM (HROUTN) IN PROGRAM SAPFM06B." ellen
      PERFORM (hroutn) IN PROGRAM zmm_sapfm06b.
    ENDLOOP.
  ENDLOOP.
*- Pre-Fetch mit Liste der Schlüssel ----------------------------------*
  CLEAR hroutn.
  hroutn(14) = 'BAN_DATEN_PR2_'.
  LOOP AT xt16li WHERE xpref NE space.
    hroutn+14(3) = xt16li-ldate.
*    PERFORM (hroutn) IN PROGRAM sapfm06b.
    PERFORM (hroutn) IN PROGRAM zmm_sapfm06b.
  ENDLOOP.

ENDFORM.                    "BAN_DATEN_PRE
