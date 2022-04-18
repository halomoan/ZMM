*&---------------------------------------------------------------------*
*&      Form  ANZAHL_POS_BAN
*&---------------------------------------------------------------------*
FORM anzahl_pos_ban.
  IF NOT gs_banf IS INITIAL AND NOT eban-gsfrg IS INITIAL.
*... Anzahl selektierter Positionen pro Banf ermitteln ...............*
    LOOP AT ban WHERE banfn EQ save_banf
                AND   gsfrg NE space.

      ban-sl_pos = sl_pos.
      MODIFY ban.
    ENDLOOP.
    CLEAR sl_pos.
  ENDIF.

*- Anzahl Positionen pro Gesamtbanf ermitteln -------------------------*
  DATA: count TYPE i.

  LOOP AT ban.
    IF ban-gsfrg NE space.
      AT NEW banfn.
        SELECT COUNT( * ) INTO count FROM eban
               WHERE banfn = ban-banfn.
      ENDAT.
      ban-az_pos = count.
      IF ban-az_pos NE ban-sl_pos AND gf_factory IS INITIAL.
        CLEAR ban-selkf.
      ENDIF.
      MODIFY ban.
    ENDIF.
* generic reporting: hook for frgadd
    IF NOT gf_factory IS INITIAL.
      DATA: ls_frgadd TYPE merep_frgadd.
      CLEAR ls_frgadd-blocked.                              "668940
      gf_tab = gf_factory->lookup( 'FRGADD' ).
      ls_frgadd-ebeln = ban-banfn.
      ls_frgadd-ebelp = ban-bnfpo.
      ls_frgadd-frgpo = ban-selkf.
      IF ban-gsfrg NE space AND
         ban-az_pos NE ban-sl_pos.
        ls_frgadd-blocked = 'X'.
      ENDIF.
      CALL METHOD gf_tab->insert_line( ls_frgadd ).
    ENDIF.
  ENDLOOP.
ENDFORM.                               " ANZAHL_POS_BAN
