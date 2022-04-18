*eject
*---------------------------------------------------------------------*
*       fortschreiben quotierung bei rücksetzen Zuordnung             *
*---------------------------------------------------------------------*
FORM bezugsquelle_6.

  CHECK ban-matnr NE space AND ban-werks NE space.
  CLEAR bqpim.
  CLEAR bqpex.
  DATA: l_eban_new LIKE eban,
        l_eban_old LIKE eban.

  MOVE-CORRESPONDING ban TO l_eban_new.
  MOVE-CORRESPONDING ban TO l_eban_old.

  CALL FUNCTION 'ME_FILL_BQPIM_FROM_EBAN'
    EXPORTING
      i_eban_new = l_eban_new
      i_eban_old = l_eban_old
      i_t160d    = t160d
    CHANGING
      c_bqpim    = bqpim.
  bqpim-vorga = 'BZ'.
  bqpim-usequ = '?'.
  bqpim-noquu = 'X'.                                        "361414
  bqpim-flief = space.
  bqpim-ekorg = space.
  bqpim-infnr = space.
  bqpim-konnr = space.
  bqpim-ktpnr = space.
  CALL FUNCTION 'ME_CHECK_SOURCE_OF_SUPPLY_2'
    EXPORTING
      comim = bqpim
    IMPORTING
      comex = bqpex.
  IF sy-subrc EQ 0.
    ban-qunum = bqpex-qunum.
    ban-qupos = bqpex-qupos.
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
  ENDIF.

ENDFORM.                    "bezugsquelle_6
