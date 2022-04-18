*eject
*----------------------------------------------------------------------*
*   Vormerken für Anfragebearbeitung bei mehreren Lieferanten
*----------------------------------------------------------------------*
FORM BAN_UPDATE_ANFL.

*- Prüfen, ob auch wirklich mind. ein Lieferant zugeordnet wurde ------*
  LOOP AT ALF WHERE BANFN EQ BAN-BANFN
              AND   BNFPO EQ BAN-BNFPO
              AND   SELKZ NE SPACE.
    EXIT.
  ENDLOOP.
  CHECK SY-SUBRC EQ 0.

  BAN-SELKZ = '*'.
*- Bezugsquellenzuordnunge retten -------------------------------------*
  IF BAN-UPDK1 NE AMAN AND
     BAN-UPDK1 NE ALIF AND
     BAN-UPDK1 NE ANFR.
    BAN-UPDK2 = BAN-UPDK1.
  ENDIF.
  BAN-UPDK1 = AMAN.
  MODIFY BAN INDEX INDEX_BAN.
  PERFORM BAN_MODIF_ZEILE USING SPACE.

ENDFORM.
