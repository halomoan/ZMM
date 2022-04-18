*---------------------------------------------------------------------*
*       Bezugsquelle prüfen mit Quotierung und Orderbuch              *
*---------------------------------------------------------------------*
FORM bezugsquelle_2.

  IF ban-matnr NE space AND ban-werks NE space.
*-- nur in dem Fall auch der Clear BQPEX, da noch nicht in BAN übertrage
    CLEAR bqpex.
    CALL FUNCTION 'ME_CHECK_SOURCE_OF_SUPPLY_2'
      EXPORTING
        comim = bqpim
      IMPORTING
        comex = bqpex.
  ENDIF.
  IF sy-subrc EQ 0.
    ban-qunum = bqpex-qunum.
    ban-qupos = bqpex-qupos.
    ban-vrtyp = bqpex-vrtyp.
    ban-konnr = bqpex-konnr.
    ban-ktpnr = bqpex-ktpnr.
    ban-ekorg = bqpex-ekorg.
    ban-infnr = bqpex-infnr.
    ban-ematn = bqpex-ematn.
    ban-mfrnr = bqpex-mfrnr.
    ban-mfrpn = bqpex-mfrpn.
    ban-emnfr = bqpex-emnfr.
    ban-plifz = bqpex-plifz.

* BQPEX-EMATN may also be filled when generic articles are involved,
* but in this case the EBAN-EMATN must not be filled
    IF ban-attyp EQ attyp-var AND                           " 509521
       ban-ematn EQ ban-satnr AND                           " 509521
       bqpex-mprof IS INITIAL AND                           " 509521
       bqpex-mfrpn IS INITIAL.                              " 509521
      CLEAR: ban-ematn.                                     " 509521
    ENDIF.                                                  " 509521

    ban-beswk = bqpex-beswk. " CCP
    IF ban-updk1 NE aend.
* Enter auf Dynpro 0104 -> IF-Zweig wird durchlaufen, BAN-UPDK1 gleich
* ZNER gesetzt; 'Bez.quelle zuordnen' auf Dynpro 0104 -> IF-Zweig
* erneut durchlaufen, Wert ZNER muß für BAN-UPDK1 erhalten bleiben
*     IF BQPEX-BEWRK NE BAN-RESWK.                          "161369
      IF bqpex-bewrk NE ban-reswk OR ban-updk1 EQ zner.     "161369
*           Lieferwerk hat sich geändert --> muß über normalen
*                                            Verbucher gehen
        ban-reswk = bqpex-bewrk.
        ban-flief = bqpex-flief.
        PERFORM bukrs_umlag.
        ban-updk1 = zner.
      ELSE.
        ban-updk1 = znew.
      ENDIF.
    ENDIF.
    ban-flief = bqpex-flief.
    IF ban-bkuml NE space OR
       ban-reswk EQ space.
      ban-slief = bqpex-flief.
    ENDIF.
  ENDIF.

ENDFORM.                    "BEZUGSQUELLE_2
