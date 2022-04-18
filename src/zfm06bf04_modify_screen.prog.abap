*eject
*----------------------------------------------------------------------*
*        Modifizieren Loop-Zeilen in Lieferanten-POP-UP                *
*----------------------------------------------------------------------*
FORM modify_screen.

  DATA: lf_ccp_active TYPE c. " CCP

  LOOP AT SCREEN.
*- Keine Eingabe bei Anzeigetransaktion  ------------------------------*
    IF screen-group1 NE 'SEL'.
      IF gpfkey NE 'BEAR' AND
         gpfkey NE 'ZUOR'.
        screen-input = 0.
      ENDIF.
    ENDIF.
    CASE screen-group4.
*- Selektionskennzeichen bei mehreren Lieferanten - hier Lieferant eing.
      WHEN '001'.
        IF lfm1-lifnr EQ space.
          screen-input = 0.
        ENDIF.
*- Lieferant usw. nicht überschreibbar, wenn bereits vorhanden --------*
      WHEN '002'.
        IF lfm1-lifnr NE space.
          screen-input = 0.
        ENDIF.
*- Fester Lieferant und Ekorg bei Umlagerung nicht eingabebereit ------*
*     WHEN '003'.                     "ab 3.0 nicht mehr
*        IF BAN-PSTYP EQ '7'.
*           SCREEN-INPUT = 0.
*           SCREEN-INVISIBLE = 1.
*        ENDIF.
*- Lieferwerk nur bei Pstyp Umlagerung eingabebereit ------------------*
*     WHEN '004'.                       "ab 3.0 nicht mehr
*        IF BAN-PSTYP NE '7'.
*           SCREEN-INPUT = 0.
*           SCREEN-INVISIBLE = 1.
*        ENDIF.
*------- Funktionsberechtigung: kein Infosatz -------------------------*
      WHEN '003'.                                           "395590
        IF t160d-ebzin EQ space.
          screen-input = '0'.
        ELSE.
          IF t160d-ebzom EQ space AND
             ban-matnr EQ space.
            screen-input = '0'.
          ENDIF.
        ENDIF.
*------- Funktionsberechtigung: kein Vertrag --------------------------*
      WHEN '005'.                                           "395590
        IF t160d-ebzka EQ space.
          screen-input = '0'.
        ELSE.
          IF t160d-ebzom EQ space AND
             ban-matnr EQ space.
            screen-input = '0'.
          ENDIF.
        ENDIF.

    ENDCASE.

* Begin CCP
    IF sy-dynnr EQ '0104' AND
       screen-name EQ 'EBAN-BESWK'.
      CALL FUNCTION 'ME_CCP_ACTIVE_CHECK'
        IMPORTING
          ef_ccp_active = lf_ccp_active.
      IF lf_ccp_active IS INITIAL.
        screen-input = '0'.
        screen-invisible = '1'.
      ENDIF.
    ENDIF.
* End CCP

    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.                    "MODIFY_SCREEN
