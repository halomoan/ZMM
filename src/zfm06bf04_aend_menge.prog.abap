*eject
*----------------------------------------------------------------------*
*        Menge Ändern                                                  *
*----------------------------------------------------------------------*
FORM AEND_MENGE.

  IF EBAN-MENGE NE *EBAN-MENGE.
    IF EBAN-MENGE EQ 0.
      MESSAGE E070(06).
    ENDIF.
    IF *EBAN-ESTKZ EQ 'B' OR *EBAN-ESTKZ EQ 'U'.             "116583
      EBAN-FIXKZ = 'X'.                                      "116583
    ENDIF.                                                   "116583
  ENDIF.

ENDFORM.
