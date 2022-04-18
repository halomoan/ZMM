*eject
*----------------------------------------------------------------------*
*        Ausgabe der Konsiliste                                        *
*----------------------------------------------------------------------*
FORM konsi_liste.

  DATA: flag.
  CLEAR kon.
  REFRESH kon.
*-- Fuellen Materialstammview -----------------------------------------*
  CLEAR mtcom.
  mtcom-kenng = 'MT06K'.
  mtcom-matnr = ban-matnr.
  mtcom-werks = ban-werks.
  PERFORM lesen_material_konsi.
  IF mtcor-rmkop ne space.
    MESSAGE s227.
    EXIT.
  ENDIF.

*-- Lesen Lieferantenstamm - fuellen Name in Konsitabelle -------------*
  LOOP AT kon.
    IF kon-lvorm eq space.
      SELECT SINGLE * FROM lfa1 WHERE lifnr = kon-lifnr.
      IF sy-subrc eq 0.
        kon-name1 = lfa1-name1.
        MODIFY kon INDEX sy-tabix.
      ELSE.
        DELETE kon.
      ENDIF.
    ELSE.
      DELETE kon.
    ENDIF.
  ENDLOOP.

*-- Prüfen, ob überhaupt Eintrag in KON -------------------------------*
  READ TABLE kon INDEX 1.
  IF sy-subrc ne 0.
    MESSAGE s227.
    EXIT.
  ENDIF.

*-- Ausgeben Konsiliste -----------------------------------------------*
  LEAVE TO LIST-PROCESSING.
  DATA: lpfkey LIKE sy-pfkey.          "TODO
  DATA: ltitle LIKE sy-title.          "TODO
  ltitle = '004'.
  CASE sy-pfkey.
    WHEN 'LIST'.
      lpfkey = 'KONA'.
    WHEN OTHERS.
      lpfkey = 'KONS'.
  ENDCASE.
  SET PF-STATUS lpfkey.
  NEW-PAGE LINE-SIZE 70.
* SET TITLEBAR '004' WITH BAN-MATNR.   "TODO
  SET TITLEBAR ltitle WITH ban-matnr.

* Währung ermitteln 1                   "TODO
  DATA: l_bwkey LIKE t001w-bwkey,
        l_bukrs LIKE t001k-bukrs,
        l_waers LIKE t001-waers.
  CLEAR: l_bwkey, l_bukrs, l_waers.

  CLEAR flag.
  LOOP AT kon.

* Währung ermitteln 2                   "TODO
    IF not kon-werks is initial.
      SELECT SINGLE bwkey INTO l_bwkey FROM t001w
                                       WHERE werks = kon-werks.
      IF sy-subrc eq 0.
        SELECT SINGLE bukrs INTO l_bukrs FROM t001k
                                         WHERE bwkey = l_bwkey.
        IF sy-subrc eq 0.
          SELECT SINGLE waers INTO l_waers FROM t001  "#EC CI_DB_OPERATION_OK[2431747] P30K909996
                                           WHERE bukrs = l_bukrs.
        ENDIF.
      ENDIF.
    ENDIF.
    IF l_waers is initial.
      l_waers = sy-waers.
    ENDIF.

    IF flag eq space.
      FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
      flag = 'X'.
    ELSE.
      FORMAT COLOR COL_NORMAL INTENSIFIED.
      CLEAR flag.
    ENDIF.
    WRITE: /  sy-vline,
            2 kon-lifnr,
           12 sy-vline,
           13 kon-name1,
           43 sy-vline,
           44 kon-konpr NO-SIGN NO-ZERO CURRENCY l_waers,
           59 sy-vline,
           60 kon-kopei NO-SIGN,
           66 sy-vline,
           67 ban-meins,
           70 sy-vline.
    hide-koind = sy-tabix.
    HIDE hide-koind.
    CLEAR hide-koind.
  ENDLOOP.
  ULINE.

ENDFORM.
