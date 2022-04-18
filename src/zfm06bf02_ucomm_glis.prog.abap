*eject
*----------------------------------------------------------------------*
*    Gesamt-Banfliste aus Zuordnungen
*----------------------------------------------------------------------*
FORM UCOMM_GLIS.

  CHECK LISTE EQ 'Z'.

  PERFORM LISTE_MERKEN USING 'G'.
  LISTE = 'G'.
  COM-SRTKZ = '1'.
  SET PF-STATUS GPFKEY EXCLUDING EXCL.
  SET TITLEBAR  GFMKEY.
  CLEAR DET.
  SY-LSIND = 0.
  PERFORM ZUG_CLEAR.
  PERFORM BAN_SORT.
  IF T16LB-DYNPR EQ 0.
    PERFORM BAN_ZEILEN.
  ELSE.
    PERFORM BAN_DYNP_CALL.
  ENDIF.

ENDFORM.
