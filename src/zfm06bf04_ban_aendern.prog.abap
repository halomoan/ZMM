*eject
*----------------------------------------------------------------------*
*        Ändern Bestellanforderungen aus Grundliste
*----------------------------------------------------------------------*
FORM BAN_AENDERN.

  REFRESH BAT.
  CLEAR BAT.

*- Prüfen Berechtigung für die Bestellanforderungen -------------------
  LOOP AT BAN WHERE UPDK1 EQ ZNEW OR
                    UPDK1 EQ ZNER OR
                    UPDK1 EQ ZRES OR
                    UPDK1 EQ AEND.
    MOVE BAN TO BAT.
    IF BAN-UPDK1 = AEND OR BAN-UPDK1 = ZNER.
      BAT-UPDKZ = 'X'.
    ELSE.
      CLEAR BAT-UPDKZ.
    ENDIF.

    APPEND BAT.
  ENDLOOP.
  CLEAR: ZSICH, ZENQU, ZAEND, ZBERE, ZNOUP.
  PERFORM AENDERN_BANFS.
  LOOP AT BAN WHERE UPDK1 EQ ZNEW OR
                    UPDK1 EQ ZNER OR
                    UPDK1 EQ ZRES OR
                    UPDK1 EQ AEND.
    INDEX_BAN = SY-TABIX.
    PERFORM BAN_UPDATE_AENDERN.
  ENDLOOP.

ENDFORM.
