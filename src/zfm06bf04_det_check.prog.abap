*eject
*----------------------------------------------------------------------*
*  Selektionskriterien Banfs zur Zuorddnung prüfen                     *
*----------------------------------------------------------------------*
FORM det_check.

  sy-subrc = 4.
  IF det NE space.
    CHECK ban-bsart EQ det-bsart.
    IF det-updkz EQ 'XX'.
      CHECK ban-updk1 NE alif AND
            ban-updk1 NE anfr.
      CHECK ban-ekorg EQ det-ekorg.
      CHECK ban-slief EQ det-slief.
      CHECK ban-reswk EQ det-reswk.
      CHECK ban-beswk EQ det-beswk.   " CCP
      CHECK ban-konnr EQ det-konnr.
      CHECK ban-fordn EQ det-fordn.
      CHECK ban-bukrs EQ det-bukrs.
    ELSE.
      CHECK det-updkz EQ ban-updk1.
    ENDIF.
    IF det-updkz EQ alif.
      CHECK ban-ekorg EQ det-ekorg.
      CHECK ban-slief EQ det-slief.
      CHECK ban-bukrs EQ det-bukrs.
    ENDIF.
    IF det-updkz EQ anfr.
      CHECK ban-ekorg EQ det-ekorg.
      CHECK ban-bukrs EQ det-bukrs.
    ENDIF.
  ELSE.
    CHECK ban-updk2 NE aman.
  ENDIF.
  CLEAR sy-subrc.

ENDFORM.                    "DET_CHECK
