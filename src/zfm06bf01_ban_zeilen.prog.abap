*eject
*----------------------------------------------------------------------*
*        Ausgabe der selektierten Bestellanforderungen                 *
*----------------------------------------------------------------------*
FORM ban_zeilen.

  DATA: l_banfn LIKE eban-banfn.

*-Test Test------------------------------------------------------------*
*-- bei Auswählfunktion Banf -    no-record-found-Kennzeichen resetten *
  CLEAR cueb-nrcfd.
  CLEAR: hkont1, hkont2.

  colflag = 'X'.
  LEAVE TO LIST-PROCESSING.
*ENHANCEMENT-SECTION     BAN_ZEILEN_01 SPOTS ES_SAPFM06B.
  NEW-PAGE LINE-SIZE 81.
*END-ENHANCEMENT-SECTION.
  CLEAR l_banfn.
  LOOP AT ban.
    IF NOT gs_banf IS INITIAL.
*... Eigene Listaufbereitung für Gesamtbanfen ........................*
      ON CHANGE OF ban-gsfrg.
*... Neue Überschriften wenn es mit den Gesamtbanfen los geht ........*
        NEW-PAGE.
      ENDON.
    ENDIF.
*- Prüfen Kriterien für Banfs zur Zuordnungsszeile -------------------*
    PERFORM det_check.
    CHECK sy-subrc EQ 0.

    MOVE ban TO eban.
    hide-index = sy-tabix.
    PERFORM ban_kont_wechsel.
    PERFORM ban_ausgabe_vorbereiten USING 'G'.

    IF NOT gs_banf IS INITIAL.
*... Eigene Listaufbereitung für Gesamtbanfen ........................*
      IF eban-banfn NE l_banfn.
        l_banfn = eban-banfn.
*... 'Kopfzeile' für Banfen zur Gesamtfreigabe ausgeben ..............*
        IF NOT eban-gsfrg IS INITIAL.
*... Zeilennummer bei Gesamtfreigabe merken ..........................*
          WRITE: / ' '.
          ban-szeil = gs_szeil = sy-linno.
          ban-zeile = gs_zeile = sy-linno + 1.   "xzeile
          ban-page  = sy-pagno.
          MODIFY ban.
          FORMAT COLOR COL_GROUP INTENSIFIED.
          CLEAR hroutn.
          hroutn(14) = 'BAN_GSFRG_001'.
*          PERFORM (HROUTN) IN PROGRAM SAPFM06B.
          PERFORM (hroutn) IN PROGRAM zmm_sapfm06b.
          FORMAT COLOR COL_GROUP INTENSIFIED OFF.
        ENDIF.
      ENDIF.

      IF NOT eban-gsfrg IS INITIAL.
        IF NOT gs_szeil IS INITIAL.
*... erste Zeile der Gesamtbanf merken ...............................*
          ban-szeil = gs_szeil.
          ban-zeile = gs_zeile.
          ban-page  = sy-pagno.
          MODIFY ban.
        ENDIF.
      ELSE.
*- Zeilennummer merken ------------------------------------------------*
        WRITE: / ' '.
        ban-szeil = sy-linno + xszeil.
        ban-zeile = sy-linno + xzeile.
        ban-page  = sy-pagno.
        MODIFY ban.
      ENDIF.
    ELSE.
*- Zeilennummer merken ------------------------------------------------*
      WRITE: / ' '.
      ban-szeil = sy-linno + xszeil.
      ban-zeile = sy-linno + xzeile.
      ban-page  = sy-pagno.
      MODIFY ban.
    ENDIF.

*- Zeilen ausgeben ----------------------------------------------------*
    IF colflag = 'X'.
      FORMAT COLOR COL_NORMAL INTENSIFIED.
    ELSE.
      FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
    ENDIF.

    CLEAR hroutn.
    hroutn(10) = 'BAN_ZEILE_'.
    LOOP AT xt16ld.
      hroutn+10(3) = xt16ld-llist.
*      PERFORM (hroutn) IN PROGRAM sapfm06b.
      PERFORM (hroutn) IN PROGRAM zmm_sapfm06b.

* Hide darf nicht ausgeführt werden in ME55, falls t16lb-gspos initial
* bei Banfen mit Gesamtfreigabe
      IF gs_banf EQ space OR t16lb-gspos NE space OR
         eban-gsfrg EQ space.
        CLEAR hide-gsfrg.
        HIDE: hide-index, hide-gsfrg.
      ENDIF.

      IF gs_banf IS INITIAL AND xt16ld-statz NE space.
        ban-zeile = sy-linno.
        MODIFY ban.
      ENDIF.
    ENDLOOP.

    IF colflag = 'X'.
      colflag = ' '.
    ELSE.
      colflag = 'X'.
    ENDIF.
    CLEAR: hide-index.
  ENDLOOP.
*ENHANCEMENT-SECTION     BAN_ZEILEN_02 SPOTS ES_SAPFM06B.
  ULINE.
*END-ENHANCEMENT-SECTION.
ENDFORM.                    "BAN_ZEILEN
