*eject
*---------------------------------------------------------------------*
*       Bezugsquelle suchen über Quotierung und Orderbuch für Batch   *
*---------------------------------------------------------------------*
FORM bezugsquelle_4.

*- Übergabestruktur füllen --------------------------------------------*
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
  bqpim-liste = 'X'.                                        "642448
  bqpim-msgno = 'X'.
  bqpim-calcpr = 'X'.                                       "553618
  bqpim-noaus = 'X'.                   "keine Auswahl
  bqpim-nomei = 'X'.                   "keine Mengeneinheiten    4.0
  bqpim-cdelt = t160v-cdelt.

* Begin CCP
  DATA: lf_ccp_active TYPE c.
  CALL FUNCTION 'ME_CCP_ACTIVE_CHECK'
    IMPORTING
      ef_ccp_active = lf_ccp_active.

  IF NOT bqpim-beswk IS INITIAL AND
     NOT lf_ccp_active IS INITIAL.

    DATA: l_eban_sim    TYPE eban,
          l_transtime   LIKE bqpex-plifz,
          lf_auth       LIKE sy-subrc.

    CALL FUNCTION 'ME_CPP_AUTH_CHECK_BESWK'
      EXPORTING
        if_plant    = bqpim-beswk
        if_activity = '22'
      IMPORTING
        ef_auth     = lf_auth.
    CHECK lf_auth IS INITIAL.
*    authority-check object 'M_BANF_BWK'
*            id 'ACTVT' field '22'
*            id 'WERKS' field bqpim-beswk.

*    check sy-subrc eq 0.
*   message i107(meccp) with bqpim-beswk


    MOVE-CORRESPONDING ban TO l_eban_sim.
    CLEAR: l_eban_sim-beswk, l_eban_sim-lifnr, l_eban_sim-flief,
           l_eban_sim-reswk, l_eban_sim-ekorg, l_eban_sim-infnr,
           l_eban_sim-konnr, l_eban_sim-ktpnr, l_eban_sim-lgort.
    l_eban_sim-werks = bqpim-beswk.

    MOVE-CORRESPONDING l_eban_sim TO l_eban_new.
    MOVE-CORRESPONDING l_eban_sim TO l_eban_old.

    CALL FUNCTION 'ME_FILL_BQPIM_FROM_EBAN'
      EXPORTING
        i_eban_new = l_eban_new
        i_eban_old = l_eban_old
        i_t160d    = t160d
      CHANGING
        c_bqpim    = bqpim.

* todo adjust delivery date.
    PERFORM calculate_transport_time IN PROGRAM saplmeqr
            USING    ban-werks
                     l_eban_sim-werks
                     l_eban_sim-matnr
                     l_eban_sim-banfn
                     l_eban_sim-bnfpo
            CHANGING l_transtime.

    bqpim-nedat = bqpim-nedat - l_transtime.
    IF bqpim-nedat LT sy-datlo.
      bqpim-nedat = sy-datlo.
    ENDIF.
* End CCP

*- Aufruf Funktionsbaustein zum Feststellen Bezugsquelle --------------*
    CALL FUNCTION 'ME_SEARCH_SOURCE_OF_SUPPLY'
      EXPORTING
        comim        = bqpim
        banfnummer   = ban-banfn
        banfposition = ban-bnfpo
      IMPORTING
        comex        = bqpex.
* Begin CCP
    IF NOT bqpex IS INITIAL.
      bqpex-beswk =  ban-beswk.
    ENDIF.
  ELSE.
    CALL FUNCTION 'ME_SEARCH_SOURCE_OF_SUPPLY_EXP'
      EXPORTING
        is_comim    = bqpim
        if_preq_no  = ban-banfn
        if_preq_pos = ban-bnfpo
      IMPORTING
        es_comex    = bqpex.
  ENDIF.
* End CCP

*- Bezugsquelle gefunden - Banftabelle modifizieren -------------------*
  IF sy-subrc EQ 0.
    IF bqpex-flief NE ban-flief OR bqpex-bewrk NE ban-reswk OR
       bqpex-konnr NE ban-konnr OR bqpex-ktpnr NE ban-ktpnr OR
       bqpex-ekorg NE ban-ekorg OR bqpex-infnr NE ban-infnr OR
       bqpex-reslo NE ban-reslo OR     " SSLOC
       bqpex-beswk NE ban-beswk OR " CCP
       bqpex-meins NE ban-bmein.
*-- nur, wenn Abweichung von vorhandener Bezugsquelle ---------------
      MOVE ban TO oba.
      APPEND oba.
      IF ban-updk1 NE aend.
        IF bqpex-bewrk NE ban-reswk OR
           bqpex-reslo NE ban-reslo.   " SSLOC
*           Lieferwerk hat sich geändert --> muß über normalen
*                                            Verbucher gehen
          ban-reswk = bqpex-bewrk.
          ban-reslo = bqpex-reslo.    " SSLOC
          ban-flief = bqpex-flief.
          PERFORM bukrs_umlag.
          ban-updk1 = zner.
        ELSE.
          ban-updk1 = znew.
        ENDIF.
      ENDIF.
      ban-qunum = bqpex-qunum.
      ban-qupos = bqpex-qupos.
      ban-vrtyp = bqpex-vrtyp.
      ban-konnr = bqpex-konnr.
      ban-ktpnr = bqpex-ktpnr.
      ban-ekorg = bqpex-ekorg.
      ban-infnr = bqpex-infnr.
      ban-flief = bqpex-flief.
      ban-ematn = bqpex-ematn.
      ban-mfrnr = bqpex-mfrnr.
      ban-mfrpn = bqpex-mfrpn.
      ban-emnfr = bqpex-emnfr.
      ban-plifz = bqpex-plifz.

* BQPEX-EMATN may also be filled when generic articles are involved,
* but in this case the EBAN-EMATN must not be filled
      IF ban-attyp EQ attyp-var AND                         " 509521
         ban-ematn EQ ban-satnr AND                         " 509521
         bqpex-mprof IS INITIAL AND                         " 509521
         bqpex-mfrpn IS INITIAL.                            " 509521
        CLEAR: ban-ematn.                                   " 509521
      ENDIF.                                                " 509521

      ban-beswk = bqpex-beswk. " CCP
      IF ban-bkuml NE space OR
         ban-reswk EQ space.
        ban-slief = bqpex-flief.
      ENDIF.
      ban-lifnr = bqpex-lifnr.
      ban-bmein = bqpex-meins.
      IF bqpex-retco EQ '1'.
        not_all_ordb = 'X'.
      ENDIF.
      MOVE ban TO bat.
      APPEND bat.
      MODIFY ban INDEX index_ban.
    ENDIF.
  ENDIF.

ENDFORM.                    "bezugsquelle_4
