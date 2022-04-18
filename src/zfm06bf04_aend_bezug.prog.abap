*eject
*----------------------------------------------------------------------*
*        Bezugsquelle Ändern                                           *
*----------------------------------------------------------------------*
FORM AEND_BEZUG.

  CLEAR BUEB.
  BUEB-FLIEF = EBAN-FLIEF.
  BUEB-EKORG = EBAN-EKORG.
  BUEB-INFNR = EBAN-INFNR.
  BUEB-KONNR = EBAN-KONNR.
  BUEB-KTPNR = EBAN-KTPNR.
  BUEB-RESWK = EBAN-RESWK.
  BUEB-BESWK = EBAN-BESWK. " CCP
  BUEB-EMATN = EBAN-EMATN.
  BUEB-MFRNR = EBAN-MFRNR.
  BUEB-MFRPN = EBAN-MFRPN.
  BUEB-EMNFR = EBAN-EMNFR.
  MERK = BAN-UPDK1.
  MOVE-CORRESPONDING EBAN TO BAN.
  PERFORM BEZUGSQUELLE_1 USING 'X'.
  PERFORM BEZUGSQUELLE_2.
  MOVE BAN TO EBAN.
  read table bde index 1 transporting no fields.
  IF EBAN NE *EBAN AND HIDE-INDEX > 0 AND sy-subrc = 0.
    IF MERK EQ AEND.
      BAN-UPDK1 = AEND.
    ENDIF.
    MODIFY BAN INDEX HIDE-INDEX.
  ENDIF.

ENDFORM.
