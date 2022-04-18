*eject
*----------------------------------------------------------------------*
*        Alle Markierungen löschen                                     *
*----------------------------------------------------------------------*
FORM UCOMM_MDEL.

  CHECK LISTE EQ 'G'.

  LOOP AT BAN WHERE SELKZ NE SPACE.
    PERFORM DET_CHECK.
    CHECK SY-SUBRC EQ 0.
    BAN-SELKZ = SPACE.
    MODIFY BAN INDEX SY-TABIX.
  ENDLOOP.

  SY-LSIND = 0.
  IF T16LB-DYNPR EQ 0.
    PERFORM BAN_ZEILEN.
  ENDIF.

ENDFORM.
