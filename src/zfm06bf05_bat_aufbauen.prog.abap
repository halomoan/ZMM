*eject
*----------------------------------------------------------------------*
*   Übergabetabelle fuellen                                            *
*----------------------------------------------------------------------*
FORM bat_aufbauen CHANGING ch_dirty LIKE sy-subrc.

  CLEAR ch_dirty.                                           "489026
  REFRESH BAT.
  CLEAR BAT.
  CLEAR XAUTH.
  S-AKTIND = S-FIRSTIND.
  WHILE S-AKTIND GE S-FIRSTIND AND
        S-AKTIND LE S-MAXIND.
    READ TABLE BAN INDEX S-AKTIND.
    S-AKTIND = S-AKTIND + 1.
    MOVE-CORRESPONDING BAN TO BAT.
    IF BAN-BKUML EQ SPACE AND
       BAN-RESWK NE SPACE.
      CLEAR BAT-FLIEF.
    ENDIF.
*-- Command: Banf-Update ----------------------------------------------*
    IF SY-UCOMM EQ 'ZBUP'.
      IF BAN-UPDK1 EQ ZOLD OR
         BAN-UPDK1 EQ SPACE.
        ZNOUP = ZNOUP + 1.
        CHECK 1 EQ 2.
      ENDIF.
      IF BAN-UPDK1 = AEND OR BAN-UPDK1 = ZNER.
        BAT-UPDKZ = 'X'.
      ELSE.
        CLEAR BAT-UPDKZ.
      ENDIF.
    ENDIF.
    IF NOT ban-qunum IS INITIAL AND
    ( ban-updk1 EQ znew OR
        ban-updk1 EQ zner OR
        ban-updk1 EQ zres OR
        ban-updk1 EQ aend ).
      ch_dirty = 1.
    ENDIF.
    APPEND bat.
  ENDWHILE.
ENDFORM.                    "bat_aufbauen
