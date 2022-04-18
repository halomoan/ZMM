***INCLUDE FM06BF05 .
* 70908 11.06.1997 3.1H GT : ME57 Belegsprache für Anfragen = Anmeldespr
* 82801 10.10.1997 3.1I CF : ME57 Anfrage erzeugen: Popup mit Partnern f
* 92105 08.01.1998 4.0B KB : SD-Banfen können teilbestellt werden
* 92334 12.01.1998 4.0B GT : ME58 Vorschlagswerte Beleg anlegen
* 95860 17.02.1998 4.0C SM : Vorschlag Belegart aus T160
*eject
*----------------------------------------------------------------------*
*   Tabelle Ban updaten nach Zuodnung bearbeiten/Banf ändern
*----------------------------------------------------------------------*
FORM ban_update USING bup_kz.

  s-aktind = s-firstind.
  WHILE s-aktind GE s-firstind AND
        s-aktind LE s-maxind.
    READ TABLE ban INDEX s-aktind.
    CASE bup_kz.
*- angefragt ----------------------------------------------------------*
      WHEN 'A'.
        MOVE-CORRESPONDING ban TO bankey.
        READ TABLE batu WITH KEY bankey.
        IF sy-subrc EQ 0.
*- Bearbeitungssstatus löschen ----------------------------------------*
          CLEAR ban-updk1.
          ban-updk3 = buan.
*- Lieferantenzuordnung löschen ---------------------------------------*
          IF ban-updk2 EQ aman.
            PERFORM alf_loeschen_einzel.
            CLEAR ban-slief.
          ELSE.
*- Bezugsquellenzuordnung zurückholen ---------------------------------*
            CLEAR ban-slief.
            IF ban-updk2 NE space.
              ban-updk1 = ban-updk2.
              CLEAR ban-updk2.
              IF ban-bkuml NE space OR
                 ban-reswk EQ space.
                ban-slief = ban-flief.
              ENDIF.
            ENDIF.
          ENDIF.
          MODIFY ban INDEX s-aktind.
          bzaehl = bzaehl + 1.
*- 'Mutter-Banf' updaten, wenn keine Lieferanten mehr übrig -----------*
          LOOP AT alf WHERE banfn EQ bankey-banfn
                        AND bnfpo EQ bankey-bnfpo
                        AND selkz NE space.
            EXIT.
          ENDLOOP.
          IF sy-subrc NE 0.
            LOOP AT ban WHERE banfn EQ bankey-banfn
                          AND bnfpo EQ bankey-bnfpo
                          AND updk3 NE buan.
              CLEAR ban-updk1.
              ban-updk3 = buan.
              MODIFY ban.
            ENDLOOP.
          ENDIF.
        ENDIF.
*- geändert -----------------------------------------------------------*
      WHEN 'B'.
        index_ban = s-aktind.
        PERFORM ban_update_aendern.
        IF sy-subrc EQ 0.
          bzaehl = bzaehl + 1.
        ENDIF.
*- bestellt/eingeteilt ------------------------------------------------*
      WHEN 'E'.
        MOVE-CORRESPONDING ban TO bankey.
        READ TABLE batu WITH KEY bankey.
        IF sy-subrc EQ 0.
*- bestellte Menge fortschreiben --------------------------------------*
          IF ban-bsmng NE batu-bsmng.
            ban-bsmng = batu-bsmng.
            ban-statu = batu-statu.
            IF ban-vrtyp EQ 'L'.
              ban-ebeln = ban-konnr.
            ELSEIF batu-ebeln EQ space.                     "451467
              GET PARAMETER ID 'BES' FIELD ban-ebeln.
            ELSE.
              ban-ebeln = batu-ebeln.
            ENDIF.
            ban-ebelp = batu-ebelp.
            ban-bedat = batu-bedat.
            CASE batu-ebakz.                                "319095
              WHEN '0'. CLEAR ban-ebakz.
              WHEN '1'. ban-ebakz = 'X'.
              WHEN OTHERS. ban-ebakz = batu-ebakz.
            ENDCASE.
            ban-updk3 = bube.
            MODIFY ban INDEX s-aktind.
            bzaehl = bzaehl + 1.
          ENDIF.
        ENDIF.
*- Erfassungsblatt erstellt -------------------------------------------*
      WHEN 'S'.
        MOVE-CORRESPONDING ban TO bankey.
        READ TABLE batu WITH KEY bankey.
        IF sy-subrc EQ 0.
          IF ban-bsmng NE batu-bsmng.
            ban-bsmng = batu-bsmng.
            ban-statu = batu-statu.
            ban-ebeln = batu-ebeln.
            ban-ebelp = batu-ebelp.
            ban-bedat = batu-bedat.
            ban-lblni = batu-lblni.
            ban-updk3 = bube.          "noch offen
            MODIFY ban INDEX s-aktind.
            bzaehl = bzaehl + 1.
          ENDIF.
        ENDIF.
    ENDCASE.
    s-aktind = s-aktind + 1.
  ENDWHILE.

ENDFORM.                    "ban_update
