*eject
*----------------------------------------------------------------------*
*        Pruefen Selektionsparameter                                   *
*----------------------------------------------------------------------*
FORM CHECK_PARA1.

  REJECT = 'X'.
*------- Check Select-Options -----------------------------------------*
  CHECK S_BSART.
  check s_werks.                          "INSERT TK 4.6B
  CHECK EBAN-PSTYP IN R_PSTYP.
  CHECK S_KNTTP.
  CHECK S_LFDAT.
  CHECK S_FRGDT.
  CHECK S_DISPO.
  CHECK S_STATU.
  CHECK S_FLIEF.

*------- Pruefen Kurztext ---------------------------------------------*
  IF P_TXZ01 NE SPACE.
    IF EBAN-TXZ01 NP P_TXZ01.
      EXIT.
    ENDIF.
  ENDIF.

*------- Pruefen Anforderer -------------------------------------------*
  IF P_AFNAM NE SPACE.
    IF EBAN-AFNAM NP P_AFNAM.
      EXIT.
    ENDIF.
  ENDIF.
  CLEAR REJECT.

ENDFORM.
