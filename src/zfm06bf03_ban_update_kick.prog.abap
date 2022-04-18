*eject
*----------------------------------------------------------------------*
*  Zugeordnet über Konsi-Liste                                         *
*----------------------------------------------------------------------*
FORM BAN_UPDATE_KICK.

  BAN-FLIEF = KON-LIFNR.
  BAN-SLIEF = KON-LIFNR.
  CLEAR BAN-KONNR.
  CLEAR BAN-KTPNR.
  CLEAR BAN-VRTYP.
  CLEAR BAN-INFNR.
  IF BAN-RESWK NE SPACE.
    IF BAN-UPDK1 NE AEND.
      BAN-UPDK1 = ZNER.
    ENDIF.
  ENDIF.
  CLEAR BAN-RESWK.
  IF BAN-UPDK1 NE AEND AND BAN-UPDK1 NE ZNER.
    BAN-UPDK1 = ZNEW.
  ENDIF.
  MODIFY BAN INDEX INDEX_BAN.
  PERFORM BAN_MODIF_ZEILE USING SPACE.
  PERFORM ALF_LOESCHEN.

ENDFORM.
