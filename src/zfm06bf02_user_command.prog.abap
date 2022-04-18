*eject
*----------------------------------------------------------------------*
*   User-Commands auswerten
*----------------------------------------------------------------------*
FORM user_command.

*- tatsächliche Liststufe merken, da auch bei 'AT USER-COMMAND' eins --*
*- hochgezählt wird ---------------------------------------------------*
  lsind = sy-lsind - 1.
  IF lsind LT 0.
    lsind = 0.
  ENDIF.
*- Eingabe Selektionskennzeichen --------------------------------------*
  PERFORM selkz_input.

*- Liste sortieren ----------------------------------------------------*
  PERFORM ucomm_sort.

  CASE sy-ucomm.
*- Nochmal markieren --------------------------------------------------*
    WHEN 'MAKT'.
      PERFORM ucomm_makt.
*- Alle markieren -----------------------------------------------------*
    WHEN 'MALL'.
      PERFORM ucomm_mall.
*- Einzelzeile markieren ----------------------------------------------*
    WHEN 'MARK'.
      PERFORM ucomm_mark.
*- Alle Markierungen löschen ------------------------------------------*
    WHEN 'MDEL'.
      PERFORM ucomm_mdel.
*- Markieren Intervall ------------------------------------------------*
    WHEN 'MINT'.
      PERFORM ucomm_mint.
*- Anzeigen Änderungen ------------------------------------------------*
    WHEN 'AEND'.
      PERFORM ucomm_aend.
*- Anzeigen Bestellungen ----------------------------------------------*
    WHEN 'BEST'.
      PERFORM ucomm_best.
*- Anzeigen Freigabestrategie -----------------------------------------*
    WHEN 'FRST'.
      PERFORM ucomm_frst.
*- Auswählen Bestellanforderung ---------------------------------------*
    WHEN 'AUSW'.
      PERFORM ucomm_ausw.
*- Anzeigen Material --------------------------------------------------*
    WHEN 'MATN'.
      PERFORM ucomm_matn.
*- Anzeigen Beleg -----------------------------------------------------*
    WHEN 'HICK'.
      PERFORM ucomm_hick.
*- Auswählen Konsilieferant -------------------------------------------*
    WHEN 'KICK'.
      PERFORM ucomm_kick.
*- springen in Dienstleistungspaket
    WHEN 'DIEN'.
      leerflg = 'X'.
      LOOP AT ban WHERE selkz EQ 'X'.
        CLEAR leerflg.
        ban-selkz = '*'.
        MODIFY ban.
        PERFORM read_services(sapfm06l) USING ban-packno ban-banfn
                                              ban-bnfpo.
        PERFORM sel_kennzeichnen.
        EXIT.
      ENDLOOP.
      IF leerflg EQ 'X'.
        IF hide-index NE 0.
          READ TABLE ban INDEX hide-index.
          PERFORM read_services(sapfm06l) USING ban-packno
                                                ban-banfn ban-bnfpo.
          PERFORM sel_kennzeichnen.
          EXIT.
        ENDIF.
      ENDIF.
*- Zurück -------------------------------------------------------------*
    WHEN 'ZURU'.
      PERFORM ucomm_zuru.
*- Beenden ------------------------------------------------------------*
    WHEN 'EN  '.
      PERFORM ucomm_ende.
*- Abbrechen ----------------------------------------------------------*
    WHEN 'XIT '.
      PERFORM ucomm_zuru.
*- Vormerken für Anfragebearbeitung einfach ---------------------------*
    WHEN 'ANFR'.
      PERFORM ucomm_anfr.
*- Vormerken für Anfragebearbeitung mehrfach --------------------------*
    WHEN 'ANFL'.
      PERFORM ucomm_anfl.
*- Buchen Freigabe ----------------------------------------------------*
    WHEN 'BU  '.
      PERFORM ucomm_bufr.
*- In Einzelfreigabe verzweigen ---------------------------------------*
    WHEN 'ME54'.
      PERFORM ucomm_me54.
*- Eine Zeile zuordnen über Orderbuch ---------------------------------*
    WHEN 'ORDB'.
      PERFORM ucomm_ordb.
*- Eine Zeile manuell zuordnen  ---------------------------------------*
    WHEN 'ORDM'.
      PERFORM ucomm_ordm.
    WHEN 'ZICK'.  "auto assign lowest source list price
      PERFORM ucomm_zick.
*- Übersicht Zuordnungen ansteuern ------------------------------------*
    WHEN 'ZANZ'.
      PERFORM ucomm_zanz.
*- Zuordnung zurücknehmen ---------------------------------------------*
    WHEN 'ZRES'.
      PERFORM ucomm_zres.
*- Zugeordnete bearbeiten ---------------------------------------------*
    WHEN 'ZBEA'.
      PERFORM ucomm_zbea.
*- Banfs ändern -------------------------------------------------------*
    WHEN 'ZBUP'.
      PERFORM ucomm_zbup.
*- Anzeigen Infosätze zum Material ------------------------------------*
    WHEN 'LINF'.
      PERFORM ucomm_linf.
*- Anzeigen Konsilieferanten ------------------------------------------*
    WHEN 'LKON'.
      PERFORM ucomm_lkon.
*- Anzeigen Rahmenverträge zur Materialklasse -------------------------*
    WHEN 'LRAC'.
      PERFORM ucomm_lrac.
*- Anzeigen Rahmenverträge zum Material -------------------------------*
    WHEN 'LRAM'.
      PERFORM ucomm_lram.
*- Anzeigen Lieferantenbeurteilungen ----------------------------------*
    WHEN 'LIBE'.
      PERFORM ucomm_libe.
*- Banfs zur Zuordnungszeile ------------------------------------------*
    WHEN 'ZLIS'.
      PERFORM ucomm_zlis.
*- Gesamtliste Banfs --------------------------------------------------*
    WHEN 'GLIS'.
      PERFORM ucomm_glis.
*- Ändern Listumfang --------------------------------------------------*
    WHEN 'LUAE'.
      PERFORM ucomm_luae.
*- Arbeitsvorrat aktualisieren ----------------------------------------*
    WHEN 'AAKT'.
      PERFORM ucomm_aakt.
*- Sichern Banf aus Grundliste ----------------------------------------*
    WHEN 'GBUP'.
      PERFORM ucomm_gbup.
*- Detail zur Banf ----------------------------------------------------*
    WHEN 'DETA'.
      PERFORM ucomm_deta.
*- Bestandsübersicht --------------------------------------------------*
    WHEN 'MMBE'.
      PERFORM ucomm_mmbe.
*- Bestands-/Bedarfs-Situation-----------------------------------------*
    WHEN 'MD04'.
      PERFORM ucomm_md04.
*-- Note 739690
*- Accounting Errors - Log
    WHEN 'LOG1'.
      PERFORM ucomm_log1.
*-- Note 739690
  ENDCASE.
  CLEAR hide-index.
ENDFORM.                    "USER_COMMAND
