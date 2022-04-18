*eject
*----------------------------------------------------------------------*
*        Auswertung Banf-Selektion                                     *
*----------------------------------------------------------------------*
FORM ban_aufbauen.
  DATA: lt_eban_tech TYPE eban_t_tech,
        ls_eban_tech LIKE LINE OF lt_eban_tech.

  IF NOT gs_banf IS INITIAL AND NOT eban-gsfrg IS INITIAL.
    ON CHANGE OF eban-banfn.
*... Anzahl selektierter Positionen pro Banf ermitteln ...............*
      LOOP AT ban WHERE banfn EQ save_banf
                  AND   gsfrg NE space.
        ban-sl_pos = sl_pos.
        MODIFY ban.
      ENDLOOP.
      CLEAR sl_pos.
      save_banf = eban-banfn.
    ENDON.
    sl_pos = sl_pos + 1.
  ENDIF.

  PERFORM aendanz_pruefen.
  CLEAR ban.
  ban-aenda = aendanz.
  ban-selkf = flag_selk.
  MOVE-CORRESPONDING eban TO ban.
  PERFORM bukrs_umlag.
  IF eban-flief NE space.
    IF ban-bkuml NE space OR
       ban-reswk EQ space.
      ban-slief = ban-flief.
    ENDIF.
  ENDIF.
  IF eban-flief NE space OR
     eban-beswk NE space OR " CCP
     eban-reswk NE space.
    ban-updk1 = zold.
  ENDIF.

  ban-arch_date = archive_date.          "TK 4.0B EURO

*- generic reporting: hook for eban -----------------------------------*
  IF NOT gf_factory IS INITIAL.
    gf_tab = gf_factory->lookup( 'EBAN' ).
    MOVE-CORRESPONDING ban TO eban.
    CALL METHOD gf_tab->insert_line( eban ). "#EC CI_FLDEXT_OK[2215424] P30K909996
    IF eban-knttp NE space AND eban-kzvbr NE kzvbr-unbe.
      IF ebkn-banfn EQ eban-banfn AND
         ebkn-bnfpo EQ eban-bnfpo.
        gf_tab = gf_factory->lookup( 'EBKN' ).
        CALL METHOD gf_tab->insert_line( ebkn ).
      ENDIF.
    ENDIF.
  ENDIF.

  PERFORM kontierung.

  IF cl_ops_switch_check=>mm_sfws_p2pse( ) IS NOT INITIAL.

    lt_eban_tech = cl_mmpur_mereq_db_utility=>get_eban_tech( im_banfn = eban-banfn ).

    READ TABLE lt_eban_tech  WITH KEY   bnfpo = eban-bnfpo
                                        banfn = eban-banfn
                                        INTO ls_eban_tech.
    IF ls_eban_tech-ext_proc_status CO '12'.
      RETURN.
    ELSE.
      APPEND ban.
    ENDIF.
  ELSE.
    APPEND ban.
  ENDIF.

*------- no-record-found-Kennzeichen zurücksetzen ---------------------*
  CLEAR not_found.

ENDFORM.                    "BAN_AUFBAUEN
