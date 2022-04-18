*eject
*---------------------------------------------------------------------*
*       Bezugsquellenprüfung Teil 1                                   *
*---------------------------------------------------------------------*
FORM bezugsquelle_1 USING bq1_kz.

  CLEAR bqpim.
  CLEAR bqpex.

  DATA: l_eban_new LIKE eban,
        l_eban_old LIKE eban.

  DATA l_lfa1 type lfa1.           "657617

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
  bqpim-flief = bueb-flief.            "BAN-FLIEF.
  IF NOT bqpim-lifnr IS INITIAL.                            "380323
       CALL FUNCTION 'WY_LFA1_SINGLE_READ'                  "657617
       EXPORTING
            pi_lifnr            = bqpim-lifnr
*           PI_BYPASSING_BUFFER =
*           PI_REFRESH_BUFFER   =
       IMPORTING
            po_lfa1             = l_lfa1
       EXCEPTIONS
            no_records_found    = 1
            OTHERS              = 2.

      if l_lfa1-loevm ne space or l_lfa1-sperm ne space.
       clear bqpim-lifnr.
      endif.                                                "657617

  ENDIF.                                                    "380323
  bqpim-bewrk = bueb-reswk.            "BAN-RESWK.
  bqpim-ekorg = bueb-ekorg.            "BAN-EKORG.
  bqpim-infnr = bueb-infnr.            "BAN-INFNR.
  bqpim-konnr = bueb-konnr.            "BAN-KONNR.
  bqpim-ktpnr = bueb-ktpnr.            "BAN-KTPNR.
  bqpim-beswk = bueb-beswk. " CCP
*-Mengen/Terminänderung berücksichtigen ------------------------------*
  IF bq1_kz NE space.
    bqpim-oldat = *eban-lfdat.
    bqpim-olmng = *eban-menge.
  ENDIF.

*  CALL FUNCTION 'ME_CHECK_SOURCE_OF_SUPPLY_1' " CCP
  CALL FUNCTION 'ME_CHECK_SOURCE_OF_SUPPLY_1_EX' " CCP
    EXPORTING
      is_comim = bqpim
    IMPORTING
      es_comex = bqpex.
  IF sy-subrc EQ 0.
    bqpim-plifz = bqpex-plifz.
    bueb-ematn = bqpex-ematn.
    bueb-mfrnr = bqpex-mfrnr.
    bueb-mfrpn = bqpex-mfrpn.
    bueb-emnfr = bqpex-emnfr.
    IF bueb-konnr NE space.
* Aus dem Vertrag abzuleitende Daten müssen hier doch übergeben werden,
* da sie in der Prüfung Teil 2 nicht mehr neu gesetzt werden
      bueb-flief = bqpex-flief.
      bueb-ekorg = bqpex-ekorg.
      bqpim-flief = bqpex-flief.
      bqpim-ekorg = bqpex-ekorg.
    ENDIF.
    IF bueb-infnr NE space.
* Aus dem Infosatz abzuleitende Daten müssen hier doch übergeben werden,
* da sie in der Prüfung Teil 2 nicht mehr neu gesetzt werden
      bueb-flief = bqpex-flief.
      bqpim-flief = bqpex-flief.
      IF bueb-ekorg EQ space AND bqpex-ekorg NE space.      "385298
        bueb-ekorg = bqpex-ekorg.                           "385298
        bqpim-ekorg = bqpex-ekorg.                          "385298
      ENDIF.                                                "385298
    ENDIF.
    IF bueb-flief NE space.
* Aus dem Infosatz abzuleitende Daten müssen hier doch übergeben werden,
* da sie in der Prüfung Teil 2 nicht mehr neu gesetzt werden
      bueb-infnr = bqpex-infnr.
      bqpim-infnr = bqpex-infnr.
      IF bueb-ekorg EQ space AND bqpex-ekorg NE space.      "385298
        bueb-ekorg = bqpex-ekorg.                           "385298
        bqpim-ekorg = bqpex-ekorg.                          "385298
      ENDIF.                                                "385298
    ENDIF.
  ENDIF.

ENDFORM.                    "bezugsquelle_1
