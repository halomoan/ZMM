*eject
*----------------------------------------------------------------------*
*   Check gültige Zeile
*----------------------------------------------------------------------*
FORM VALID_LINE.

  CLEAR EXITFLAG.
  IF HIDE-INDEX EQ 0.
    MESSAGE S201.
    EXITFLAG = 'X'.
    CLEAR SY-UCOMM.
  ENDIF.

ENDFORM.
