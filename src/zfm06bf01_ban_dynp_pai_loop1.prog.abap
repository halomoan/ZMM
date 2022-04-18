*eject
*----------------------------------------------------------------------*
*        Dynpro für Banf-Bearbeitung PAI im Loop (vor Feldtransport)  *
*----------------------------------------------------------------------*
FORM BAN_DYNP_PAI_LOOP1.

  B-LESIND = B-AKTIND - B-PAGIND + SY-STEPL.
  IF DET NE SPACE.
    READ TABLE BDT INDEX B-LESIND.
    CHECK SY-SUBRC EQ 0.
    B-LESIND = BDT-INDEX.
  ENDIF.

  READ TABLE BAN INDEX B-LESIND.
  CHECK SY-SUBRC EQ 0.
  MOVE BAN TO EBAN.

ENDFORM.
