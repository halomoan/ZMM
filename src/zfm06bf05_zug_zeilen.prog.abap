*eject
*----------------------------------------------------------------------*
*  Liste der Zuordnungen aufbauen                                      *
*----------------------------------------------------------------------*
FORM zug_zeilen.

  LEAVE TO LIST-PROCESSING.
  NEW-PAGE LINE-SIZE 85.

*- Tabelle erweitern um mehrfach zur Anfrage vorgemerkte Banfs --------*
  LOOP AT ban WHERE updk1 EQ aman.
    LOOP AT alf WHERE banfn EQ ban-banfn
                  AND bnfpo EQ ban-bnfpo
                  AND selkz NE space.
      LOOP AT ban WHERE banfn = alf-banfn
                    AND bnfpo = alf-bnfpo
                    AND slief = alf-lifnr
                    AND ekorg = alf-ekorg
                    AND updk1 = alif
                    AND updk2 = aman.
        EXIT.
      ENDLOOP.
      IF sy-subrc NE 0.
        ban-slief = alf-lifnr.
        ban-ekorg = alf-ekorg.
        ban-updk1 = alif.
        ban-updk2 = aman.
        APPEND ban.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

* Begin CCP
*SORT BAN BY RESWK SLIEF EKORG BSART KONNR FORDN
*            BUKRS UPDK1 BANFN BNFPO.
  SORT ban BY reswk slief beswk ekorg bsart konnr fordn
              bukrs updk1 banfn bnfpo.
* End CCP

  CLEAR: zug, lzeile.
  DATA: hupdkz LIKE t16la-updkz.
  LOOP AT ban.
*- 'Mutter-Banf' der Mehrfachzuordnung rauslassen ---------------------*
    CHECK ban-updk1 NE aman.
    hupdkz = ban-updk1.
    IF hupdkz EQ aend.
      IF ban-flief NE space OR
         ban-reswk NE space.
        hupdkz = zold.
      ELSE.
        hupdkz = znix.
      ENDIF.
    ENDIF.
    IF hupdkz = znew OR hupdkz = zner.
      hupdkz = zold.
    ENDIF.
    IF hupdkz EQ space OR
       hupdkz EQ zres.
      hupdkz = znix.
    ENDIF.
    IF zug-flief NE ban-slief OR
       zug-reswk NE ban-reswk OR
       zug-konnr NE ban-konnr OR
       zug-fordn NE ban-fordn OR
       zug-ekorg NE ban-ekorg OR
       zug-beswk NE ban-beswk OR " CCP
       zug-bsart NE ban-bsart OR
       zug-bukrs NE ban-bukrs OR
       zug-updkz NE hupdkz.
      IF zug NE space.
        PERFORM zug_summe.
      ENDIF.
      s-firstind = sy-tabix.
      IF zug-reswk EQ space AND
         ban-reswk NE space.
        CLEAR lzeile.
        ULINE.
        NEW-PAGE LINE-SIZE 85.
      ENDIF.
    ENDIF.
    MOVE-CORRESPONDING ban TO zug.
    zug-flief = ban-slief.
    zug-updkz = hupdkz.
    izaehl = izaehl + 1.
    s-maxind = sy-tabix.
* Begin CCP
*    ON CHANGE OF zug-flief OR zug-reswk.
    ON CHANGE OF zug-flief OR zug-reswk OR zug-beswk.
* End CCP
      IF lzeile NE space.
        ULINE.
      ENDIF.
      CLEAR lzeile.
    ENDON.
  ENDLOOP.

  PERFORM zug_summe.
  CLEAR: s-firstind, s-maxind, b-zaehler, zug-updkz,
         s-zaehler, hide-zeile, hide-page, bzaehl.
  ULINE.
ENDFORM.                    "ZUG_ZEILEN
