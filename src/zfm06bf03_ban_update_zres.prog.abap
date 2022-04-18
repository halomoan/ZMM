*eject
*----------------------------------------------------------------------*
*  Zuordnung zurückgesetzt                                             *
*----------------------------------------------------------------------*
FORM BAN_UPDATE_ZRES.

  BAN-SELKZ = '*'.
  IF BAN-UPDK1 EQ ZNEW OR
     BAN-UPDK1 EQ ZOLD OR
     BAN-UPDK1 EQ ZNER OR
     BAN-UPDK1 EQ AEND.
    PERFORM BEZUGSQUELLE_6.
    CLEAR BAN-FLIEF.
    CLEAR BAN-SLIEF.
    CLEAR BAN-EKORG.
    CLEAR BAN-KONNR.
    CLEAR BAN-KTPNR.
    CLEAR BAN-VRTYP.      .
    CLEAR BAN-INFNR.
    IF BAN-UPDK1 NE AEND.
      IF BAN-RESWK NE SPACE.
        BAN-UPDK1 = ZOLD.
      ELSE.
        BAN-UPDK1 = ZRES.
      ENDIF.
    ENDIF.
    MODIFY BAN INDEX INDEX_BAN.
    PERFORM BAN_MODIF_ZEILE USING SPACE.
  ELSEIF BAN-UPDK1 EQ ANFR OR
         BAN-UPDK1 EQ ALIF OR
         BAN-UPDK1 EQ AMAN.
*- Mehrfachvormerkung zur Anfrage löschen -----------------------------*
    IF BAN-UPDK1 EQ ALIF AND
       BAN-UPDK2 EQ AMAN.
      PERFORM ALF_LOESCHEN_EINZEL.
      BAN-UPDK1 = ZRES.
    ELSE.
      PERFORM ALF_LOESCHEN.
*- Bezugsquellenzuordnung zurückholen ---------------------------------*
      IF BAN-UPDK2 <> SPACE.
        BAN-UPDK1 = BAN-UPDK2.
        CLEAR BAN-UPDK2.
      ELSE.
        BAN-UPDK1 = ZRES.
      ENDIF.
      CLEAR BAN-SLIEF.
      IF BAN-FLIEF NE SPACE.
        IF BAN-BKUML NE SPACE OR
           BAN-RESWK EQ SPACE.
          BAN-SLIEF = BUEB-FLIEF.
        ENDIF.
      ENDIF.
    ENDIF.

    MODIFY BAN INDEX INDEX_BAN.
    PERFORM BAN_MODIF_ZEILE USING SPACE.
  ELSE.
    MODIFY BAN INDEX INDEX_BAN.
    PERFORM SEL_KENNZEICHNEN.
  ENDIF.

ENDFORM.
