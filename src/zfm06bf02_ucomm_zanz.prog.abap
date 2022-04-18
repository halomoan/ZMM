*eject
*----------------------------------------------------------------------*
*    Anzeigen Zuordnung
*----------------------------------------------------------------------*
FORM UCOMM_ZANZ.

  CHECK LISTE EQ 'G'.

*-- Listyp suchen, aktuellen Listtyp merken ---------------------------*
  PERFORM LISTE_MERKEN USING 'Z'.
*-- Liste aufbauen ----------------------------------------------------*
  LISTE = 'Z'.
  COM-SRTKZ = '9'.
  CLEAR DET.
  SET PF-STATUS ZPFKEY.
  SET TITLEBAR ZFMKEY.
  SY-LSIND = 0.
  PERFORM ZUG_ZEILEN.

ENDFORM.
