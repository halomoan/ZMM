*eject
*----------------------------------------------------------------------*
*   Vormerken für Anfragebearbeitung mit Lieferanten
*----------------------------------------------------------------------*
FORM BAN_UPDATE_ALIF.

  BAN-SELKZ = '*'.
*- Bezugsquellenzuordnunge retten -------------------------------------*
  IF BAN-UPDK1 NE AMAN AND
     BAN-UPDK1 NE ALIF AND
     BAN-UPDK1 NE ANFR.
    BAN-UPDK2 = BAN-UPDK1.
  ENDIF.
  BAN-UPDK1 = ALIF.
  IF BAN-FLIEF NE SPACE.
    BAN-SLIEF = BAN-FLIEF.
  ELSE.
    BAN-SLIEF = BAN-LIFNR.
  ENDIF.
  MODIFY BAN INDEX INDEX_BAN.
  PERFORM BAN_MODIF_ZEILE USING SPACE.
  PERFORM ALF_LOESCHEN.

ENDFORM.
