*---------------------------------------------------------------------*
*       FORM BEENDEN                                                  *
*---------------------------------------------------------------------*
*       Rücksprung in aufrufendes Programm                            *
*---------------------------------------------------------------------*
FORM BEENDEN.                 "#EC CALLED

  IF SY-CALLD IS INITIAL.
    IF SY-TCODE = SE38.
      SET SCREEN 0.
      LEAVE SCREEN.
    ELSE.
      LEAVE TO TRANSACTION TRX0.
    ENDIF.
  ELSE.
    LEAVE.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM ANFORDERUNGSBILD                                         *
*---------------------------------------------------------------------*
*       Rücksprung zum Anforderungsbild                               *
*---------------------------------------------------------------------*
FORM ANFORDERUNGSBILD.

  IF NOT SY-CALLD IS INITIAL.
    LEAVE.
  ELSE.
    LEAVE TO TRANSACTION SY-TCODE.
  ENDIF.

ENDFORM.
