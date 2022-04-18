*eject
*----------------------------------------------------------------------*
*   Tabelle Ban updaten nach Banf ändern
*----------------------------------------------------------------------*
FORM BAN_UPDATE_AENDERN.

MOVE-CORRESPONDING BAN TO BANKEY.
READ TABLE BAT WITH KEY BANKEY BINARY SEARCH.
CHECK SY-SUBRC EQ 0.
IF BAN-UPDK1 NE ZOLD.
   IF BAN-FLIEF EQ SPACE AND
      BAN-BESWK EQ SPACE AND " CCP
      BAN-RESWK EQ SPACE.
      BAN-UPDK1 = SPACE.
   ELSE.
      BAN-UPDK1 = ZOLD.
   ENDIF.
   BAN-UPDK3 = BUBA.
   MODIFY BAN INDEX INDEX_BAN.
ELSE.
   SY-SUBRC = 1.
ENDIF.

ENDFORM.
