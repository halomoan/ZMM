*eject
*----------------------------------------------------------------------*
*   Vormerken für Anfragebearbeitung
*----------------------------------------------------------------------*
FORM BAN_UPDATE_ANFR.

  BAN-SELKZ = '*'.
*- Bezugsquellenzuordnunge retten -------------------------------------*
  IF BAN-UPDK1 NE AMAN AND
     BAN-UPDK1 NE ALIF AND
     BAN-UPDK1 NE ANFR.
    BAN-UPDK2 = BAN-UPDK1.
  ENDIF.
  BAN-UPDK1 = ANFR.
  CLEAR BAN-SLIEF.
  MODIFY BAN INDEX INDEX_BAN.
  PERFORM BAN_MODIF_ZEILE USING SPACE.
  PERFORM ALF_LOESCHEN.

ENDFORM.
