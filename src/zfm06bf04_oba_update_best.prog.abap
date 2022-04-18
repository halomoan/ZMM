*----------------------------------------------------------------------*
* Fortschreiben des gelesenen Standes OBA nach Anlegen einer Bestellung*
* oder Lieferplaneinteilung um folgende Felder:                        *
* STATU, BVDAT, BVDRK, EBELN, EBELP, BEDAT und BSMNG                   *
*----------------------------------------------------------------------*
FORM oba_update_best.

  LOOP AT batu.
    MOVE-CORRESPONDING batu TO bankey.
    READ TABLE oba WITH KEY bankey.
    IF sy-subrc IS INITIAL.
      oba-statu = batu-statu.
      oba-bvdat = batu-bvdat.
      oba-bvdrk = batu-bvdrk.
      IF batu-vrtyp EQ 'L'.
        oba-ebeln = batu-konnr.
      ELSE.
        GET PARAMETER ID 'BES' FIELD oba-ebeln.
      ENDIF.
      oba-ebelp = batu-ebelp.
      oba-bedat = batu-bedat.
      oba-bsmng = batu-bsmng.
      CASE batu-ebakz.                                      "319095
        WHEN '0'. CLEAR oba-ebakz.
        WHEN '1'. oba-ebakz = 'X'.
        WHEN OTHERS. oba-ebakz = batu-ebakz.
      ENDCASE.
      MODIFY oba INDEX sy-tabix.
    ENDIF.
  ENDLOOP.
ENDFORM.
