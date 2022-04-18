*---------------------------------------------------------------------*
*       FORM BQPIM_DIEN_SETZEN                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM BQPIM_DIEN_SETZEN.

  CHECK BAN-PSTYP = '9'.

  IF BAN-BUKRS NE T001-BUKRS.
    SELECT SINGLE * FROM T001 WHERE BUKRS EQ BAN-BUKRS. "#EC CI_DB_OPERATION_OK[2431747] P30K909996
    CHECK SY-SUBRC = 0.
  ENDIF.

  IF NOT ( BAN-WAERS IS INITIAL ).
    BQPIM-WAERS = BAN-WAERS.
  ELSE.
    BQPIM-WAERS = T001-WAERS.
  ENDIF.

ENDFORM.
