*eject
*---------------------------------------------------------------------*
*       Bezugsquelle suchen über Quotierung und Orderbuch             *
*---------------------------------------------------------------------*
FORM bezugsquelle_3.

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
  bqpim-liste = 'X'.
  bqpim-msgno = 'X'.
  bqpim-cdelt = t160v-cdelt.
  PERFORM bqpim_dien_setzen.

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
* check authority for assigning sources in procuring plant
    CALL FUNCTION 'ME_CPP_AUTH_CHECK_BESWK'
      EXPORTING
        if_plant    = bqpim-beswk
        if_activity = '22'
      IMPORTING
        ef_auth     = lf_auth.
    IF NOT lf_auth IS INITIAL.
      MESSAGE e207(mepo) WITH bqpim-beswk.
    ENDIF.

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
        is_comim     = bqpim
        if_preq_no   = ban-banfn
        if_preq_pos  = ban-bnfpo
      IMPORTING
        es_comex     = bqpex
      EXCEPTIONS
        no_authority = 1
        OTHERS       = 2.
    IF sy-subrc EQ 1.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.
* End CCP


*- Bezugsquelle gefunden - Banftabelle modifizieren -------------------*
  IF sy-subrc EQ 0.
    IF bqpex-flief NE ban-flief OR bqpex-bewrk NE ban-reswk OR
       bqpex-konnr NE ban-konnr OR bqpex-ktpnr NE ban-ktpnr OR
       bqpex-ekorg NE ban-ekorg OR bqpex-infnr NE ban-infnr OR
       bqpex-reslo NE ban-reslo OR            "SSLOC
       bqpex-beswk NE ban-beswk OR " CCP
       bqpex-meins NE ban-bmein.
*-- nur, wenn Abweichung von vorhandener Bezugsquelle ---------------
      IF ban-updk1 NE aend.
        IF bqpex-bewrk NE ban-reswk OR
           bqpex-reslo NE ban-reslo.     " SSLOC
*           Lieferwerk hat sich geändert --> muß über normalen
*                                            Verbucher gehen
          ban-reswk = bqpex-bewrk.
          ban-reslo = bqpex-reslo.       " SSLOC
          ban-flief = bqpex-flief.
          PERFORM bukrs_umlag.
          ban-updk1 = zner.
        ELSE.
          ban-updk1 = znew.
        ENDIF.
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
    IF ban-attyp EQ attyp-var AND                           " 509521
       ban-ematn EQ ban-satnr AND                           " 509521
       bqpex-mprof IS INITIAL AND                           " 509521
       bqpex-mfrpn IS INITIAL.                              " 509521
      CLEAR: ban-ematn.                                     " 509521
    ENDIF.                                                  " 509521

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
  ENDIF.

ENDFORM.                    "bezugsquelle_3
