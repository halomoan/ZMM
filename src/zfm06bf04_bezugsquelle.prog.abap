*eject
*---------------------------------------------------------------------*
*       Bezugsquellenprüfung für manuell eingegebene Bezugsquelle     *
*---------------------------------------------------------------------*
FORM bezugsquelle.

*- Lieferantenname und Bezeichnung Einkaufsorganisation lesen --------*
  PERFORM bezugsquelle_bezeichn.
*- Prüfen Bezugsquelle -----------------------------------------------*
  CLEAR bueb.

* Begin CCP
  bueb-beswk = eban-beswk.
* authority check
  DATA: ls_eban_old TYPE eban.
  MOVE-CORRESPONDING ban TO ls_eban_old.
  IF NOT eban-beswk IS INITIAL OR
     NOT ban-beswk  IS INITIAL.
    PERFORM authority_beswk USING eban
                                  ls_eban_old.
  ENDIF.
* End CCP

  bueb-flief = eban-flief.
  bueb-ekorg = eban-ekorg.
  bueb-infnr = eban-infnr.
  bueb-konnr = eban-konnr.
  bueb-ktpnr = eban-ktpnr.
  bueb-reswk = eban-reswk.
  bueb-ematn = eban-ematn.
  bueb-mfrnr = eban-mfrnr.
  bueb-mfrpn = eban-mfrpn.
  bueb-emnfr = eban-emnfr.
  PERFORM bezugsquelle_1 USING space.
* no central contracts                               "EhP4 CCM
  IF cl_ops_switch_check=>mm_sfws_p2pse( ) = cl_mmpur_constants=>yes.
    IF NOT bqpex-srm_contract_id IS INITIAL.
      MESSAGE e001(mm_ccm).
    ENDIF.
  ENDIF.
  PERFORM bezugsquelle_2.
  MOVE ban TO eban.
*- Lieferantenname und Bezeichnung Einkaufsorganisation lesen --------*
  PERFORM bezugsquelle_bezeichn.

*- Bildfolge bestimmen -----------------------------------------------*
  IF ok-code EQ 'ORDP'.
    IF ban-updk1 NE aend AND ban-updk1 NE zner.
      ban-updk1 = znew.
    ENDIF.
    MODIFY ban INDEX index_ban.
*- Bild verlassen -----------------------------------------------------*
    SET SCREEN 0.
    LEAVE SCREEN.
  ENDIF.

ENDFORM.                    "BEZUGSQUELLE
