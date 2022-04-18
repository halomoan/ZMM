*eject
*----------------------------------------------------------------------*
*    Ändern Bestellanforderungen aus Tabelle BAT
*----------------------------------------------------------------------*
FORM aendern_banfs.

  DATA: ucompl.
  DATA: obatabix LIKE sy-tabix.
  SORT bat BY banfn bnfpo.
  SORT oba BY banfn bnfpo.

  CLEAR xeban.
  CLEAR ucompl.

  LOOP AT bat.
*-- Änderungsberechtigung ---------------------------------------------*
    IF gpfkey NE 'ZUOR' AND
       gpfkey NE 'FREI'.
      PERFORM berechtigungen_banf USING bat-ekorg bat-ekgrp
                                        bat-werks bat-bsart.
      IF sy-subrc NE 0.
        zbere = zbere + 1.
        DELETE bat.
        CHECK 1 EQ 2.
      ENDIF.
    ELSEIF gpfkey EQ 'ZUOR'.
      PERFORM berechtigungen_banf_ekorg USING bat-ekorg.
      IF sy-subrc NE 0.
        zbere = zbere + 1.
        DELETE bat.
        CHECK 1 EQ 2.
      ENDIF.

    ENDIF.
*-- Sperren -----------------------------------------------------------*
    CALL FUNCTION 'ENQUEUE_EMEBANE'
         EXPORTING
              banfn  = bat-banfn
              bnfpo  = bat-bnfpo
         EXCEPTIONS
              OTHERS = 1.
    IF sy-subrc NE 0.
      zenqu = zenqu + 1.
      DELETE bat.
      CHECK 1 EQ 2.
    ENDIF.
*-- Datenbank nachlesen -----------------------------------------------*
    MOVE-CORRESPONDING bat TO bankey.
    READ TABLE oba WITH KEY bankey BINARY SEARCH.
    obatabix = sy-tabix.
    IF sy-subrc NE 0.
      zaend = zaend + 1.
      DELETE bat.
      CHECK 1 EQ 2.
    ENDIF.
    SELECT SINGLE *
           FROM eban
           WHERE banfn = bat-banfn
           AND   bnfpo = bat-bnfpo.
    IF sy-subrc NE 0.
      zaend = zaend + 1.
      DELETE bat.
      CHECK 1 EQ 2.
    ENDIF.
    eban-waers = oba-waers.                                 "153409
*   sbat-flief = oba-flief.
*   sbat-ekorg = oba-ekorg.
*   sbat-vrtyp = oba-vrtyp.
*   sbat-konnr = oba-konnr.
*   sbat-ktpnr = oba-ktpnr.
*   sbat-infnr = oba-infnr.
*   sbat-lifnr = oba-lifnr.
*   sbat-bmein = oba-bmein.
*   sbat-reswk = oba-reswk.
*   if eban ne sbat.
    IF eban NE oba.
      zaend = zaend + 1.
      DELETE bat.
      CHECK 1 EQ 2.
    ENDIF.

*-- Gruppenwechsel Banfnummer -----------------------------------------*
    IF bat-banfn NE xeban-banfn AND
       xeban-banfn NE space.
      PERFORM banf_aendern USING ucompl.
      CLEAR ucompl.
    ENDIF.

*-- Kennz. für Matchcode setzen ---------------------------------------*
    PERFORM setzen_zugba(sapfmmex) "#EC CI_FLDEXT_OK[2215424] P30K909996
            USING bat-zugba bat-flief bat-loekz
                  bat-bsmng bat-menge bat-frgkz
                  bat-ekorg bat-reswk bat-mprof bat-ematn.

    IF bat-reswk NE oba-reswk.
* für Einzelfertigung bei Umlagerung
      CALL FUNCTION 'ME_UMSOK_SETZEN'
           EXPORTING
                i_matnr = bat-matnr
                i_reswk = bat-reswk
                i_sobkz = bat-sobkz
           IMPORTING
                e_umsok = bat-umsok.
    ENDIF.
    zsich = zsich + 1.

*-- Füllen XEBAN - Banf neuer Stand -----------------------------------*
    IF bat-updkz NE space.
      ucompl = 'X'.
    ENDIF.
    MOVE bat TO xeban.
    xeban-kz = 'U'.
    xeban-erdat = sy-datum.
    APPEND xeban.
*-- Füllen YEBAN - Banf alter Stand -----------------------------------*
    MOVE eban TO yeban.
    APPEND yeban.
    MOVE-CORRESPONDING xeban TO oba.
    MODIFY oba INDEX obatabix.
  ENDLOOP.
  PERFORM banf_aendern USING ucompl.
  CLEAR ucompl.

*-- Refresh DCM manager
  CALL FUNCTION 'MEDCMM_REFRESH'.

*-- Nicht alles gesichert -> Message-Pop-UP ---------------------------*
  IF zbere NE 0 OR
     zaend NE 0 OR
     zenqu NE 0 OR
     zfrei NE 0 OR
     znoup NE 0 OR
     zacce NE 0.        "*-- Note 739690

    CALL FUNCTION 'MESSAGES_INITIALIZE'.

    IF zsich NE 0.
      CALL FUNCTION 'MESSAGE_STORE'
           EXPORTING
                arbgb = 'ME'
                msgty = 'I'
                msgv1 = zsich
                txtnr = '146'.
    ENDIF.
    IF zbere NE 0.
      CALL FUNCTION 'MESSAGE_STORE'
           EXPORTING
                arbgb = 'ME'
                msgty = 'I'
                msgv1 = zbere
                txtnr = '147'.
    ENDIF.
    IF zenqu NE 0.
      CALL FUNCTION 'MESSAGE_STORE'
           EXPORTING
                arbgb = 'ME'
                msgty = 'I'
                msgv1 = zenqu
                txtnr = '148'.
    ENDIF.
    IF zaend NE 0.
      CALL FUNCTION 'MESSAGE_STORE'
           EXPORTING
                arbgb = 'ME'
                msgty = 'I'
                msgv1 = zaend
                txtnr = '149'.
    ENDIF.
    IF znoup NE 0.
      CALL FUNCTION 'MESSAGE_STORE'
           EXPORTING
                arbgb = 'ME'
                msgty = 'I'
                msgv1 = znoup
                txtnr = '150'.
    ENDIF.
    IF zfrei NE 0.
      CALL FUNCTION 'MESSAGE_STORE'
           EXPORTING
                arbgb = 'ME'
                msgty = 'I'
                msgv1 = zfrei
                txtnr = '153'.
    ENDIF.
*-- Note 739690
    IF zacce NE 0.
      CALL FUNCTION 'MESSAGE_STORE'
        EXPORTING
          arbgb = 'ME'
          msgty = 'I'
          msgv1 = zacce
          txtnr = '677'.
    ENDIF.
*-- Note 739690

    CALL FUNCTION 'MESSAGES_SHOW'
         EXPORTING
              object     = text-006
              show_linno = space.

  ELSE.
    IF zsich NE 0.
      MESSAGE s203.
    ENDIF.
  ENDIF.

ENDFORM.                    "aendern_banfs
