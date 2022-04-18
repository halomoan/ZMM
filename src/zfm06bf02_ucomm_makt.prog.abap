*eject
*----------------------------------------------------------------------*
*        Nochmal markieren                                             *
*----------------------------------------------------------------------*
FORM UCOMM_MAKT.

  CHECK LISTE EQ 'G'.

  LOOP AT BAN WHERE SELKZ EQ '*'.
*- Bei Sammelfreigabe nur die markieren, die Voraussetzung erfüllen ---*
    IF SY-PFKEY EQ 'FREI'.
      IF BAN-SELKF NE 0.
        BAN-SELKZ = 'X'.
        MODIFY BAN INDEX SY-TABIX.
      ENDIF.
    ELSE.
*- Nicht Sammelfreigabe - alle gesternten markieren -------------------*
      PERFORM DET_CHECK.
      CHECK SY-SUBRC EQ 0.
      BAN-SELKZ = 'X'.
      MODIFY BAN INDEX SY-TABIX.
    ENDIF.
  ENDLOOP.
  SY-LSIND = 0.
  IF T16LB-DYNPR EQ 0.
    PERFORM BAN_ZEILEN.
  ENDIF.

ENDFORM.
