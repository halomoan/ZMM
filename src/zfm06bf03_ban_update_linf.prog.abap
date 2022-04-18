*eject
*----------------------------------------------------------------------*
*  Zugeordnet über Infosatz/Lieferantenbeurteilung.                    *
*----------------------------------------------------------------------*
FORM BAN_UPDATE_LINF.

  BAN-SELKZ = '*'.
  IF BUEB-FLIEF NE SPACE.
    BAN-FLIEF = BUEB-FLIEF.
    BAN-EKORG = BUEB-EKORG.
    BAN-INFNR = BUEB-INFNR.
    IF BAN-RESWK NE BUEB-RESWK.
      BAN-RESWK = BUEB-RESWK.
      PERFORM BUKRS_UMLAG.
      IF BAN-UPDK1 NE AEND.
        BAN-UPDK1 = ZNER.
      ENDIF.
    ENDIF.
    IF BAN-BKUML NE SPACE OR
       BAN-RESWK EQ SPACE.
      BAN-SLIEF = BUEB-FLIEF.
    ENDIF.
    CLEAR BAN-KONNR.
    CLEAR BAN-KTPNR.
    CLEAR BAN-VRTYP.
    IF BAN-UPDK1 NE AEND AND BAN-UPDK1 NE ZNER.
      BAN-UPDK1 = ZNEW.
    ENDIF.
    MODIFY BAN INDEX INDEX_BAN.
    PERFORM BAN_MODIF_ZEILE USING SPACE.
    PERFORM ALF_LOESCHEN.
  ELSE.
    MODIFY BAN INDEX INDEX_BAN.
    PERFORM SEL_KENNZEICHNEN.
  ENDIF.

ENDFORM.
