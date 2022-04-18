*eject
*----------------------------------------------------------------------*
*  Prüfen buchungskreisübergreifende Umlagerung                        *
*----------------------------------------------------------------------*
FORM BUKRS_UMLAG.

  DATA: HBUKRS LIKE T001K-BUKRS.
  CLEAR BAN-BKUML.

  IF BAN-WERKS NE T001W-WERKS.
    SELECT SINGLE * FROM T001W WHERE WERKS EQ BAN-WERKS.
  ENDIF.
  IF T001K-BWKEY NE T001W-BWKEY.
    SELECT SINGLE * FROM T001K WHERE BWKEY EQ T001W-BWKEY.
  ENDIF.
  HBUKRS = T001K-BUKRS.
  BAN-BUKRS = HBUKRS.

  CHECK BAN-RESWK NE SPACE.
  CHECK BAN-FLIEF NE SPACE.
  CHECK BAN-WERKS NE BAN-RESWK.
  IF BAN-RESWK NE T001W-WERKS.
    SELECT SINGLE * FROM T001W WHERE WERKS EQ BAN-RESWK.
  ENDIF.
  IF T001K-BWKEY NE T001W-BWKEY.
    SELECT SINGLE * FROM T001K WHERE BWKEY EQ T001W-BWKEY.
  ENDIF.
  IF T001K-BUKRS NE HBUKRS.
    BAN-BKUML = 'X'.
  ENDIF.

ENDFORM.
