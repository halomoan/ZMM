*----------------------------------------------------------------------*
*   INCLUDE FM06PE02                                                   *
*----------------------------------------------------------------------*
FORM entry_neu USING ent_retco ent_screen.

  DATA: l_druvo LIKE t166k-druvo,
        l_nast  LIKE nast,
        l_from_memory,
        l_doc   TYPE meein_purchase_doc_print.

  CLEAR ent_retco.
  IF nast-aende EQ space.
    l_druvo = '1'.
  ELSE.
    l_druvo = '2'.
  ENDIF.

  PERFORM data_selection USING l_retcode ent_retco ent_screen.

  IF l_retcode NE 0 .
    ent_retco = 1.
  ELSE.
    ent_retco = 0.
  ENDIF.

*  check ent_retco eq 0.
*  call function 'ME_PRINT_PO'
*       exporting
*            ix_nast        = l_nast
*            ix_druvo       = l_druvo
*            doc            = l_doc
*            ix_screen      = ent_screen
*            ix_from_memory = l_from_memory
*            ix_toa_dara    = toa_dara
*            ix_arc_params  = arc_params
*            ix_fonam       = tnapr-fonam          "HW 214570
*       importing
*            ex_retco       = ent_retco.


ENDFORM.                    "entry_neu

*eject
*----------------------------------------------------------------------*
* Umlagerungsbestellung,  Hinweis 670912                               *
*----------------------------------------------------------------------*
FORM entry_neu_sto USING ent_retco ent_screen.

  DATA: l_druvo LIKE t166k-druvo,
        l_nast  LIKE nast,
        l_from_memory,
        l_doc   TYPE meein_purchase_doc_print,
        f_sto.                                              "670912


  CLEAR ent_retco.
  IF nast-aende EQ space.
    l_druvo = '1'.
  ELSE.
    l_druvo = '2'.
  ENDIF.

  f_sto = 'X'.                                              "670912

  CALL FUNCTION 'ME_READ_PO_FOR_PRINTING'
    EXPORTING
      ix_nast        = nast
      ix_screen      = ent_screen
    IMPORTING
      ex_retco       = ent_retco
      ex_nast        = l_nast
      doc            = l_doc
    CHANGING
      cx_druvo       = l_druvo
      cx_from_memory = l_from_memory.
  CHECK ent_retco EQ 0.
  CALL FUNCTION 'ME_PRINT_PO'
    EXPORTING
      ix_nast        = l_nast
      ix_druvo       = l_druvo
      doc            = l_doc
      ix_screen      = ent_screen
      ix_from_memory = l_from_memory
      ix_toa_dara    = toa_dara
      ix_arc_params  = arc_params
      ix_fonam       = tnapr-fonam                          "HW 214570
      ix_sto         = f_sto                                "670912
    IMPORTING
      ex_retco       = ent_retco.
ENDFORM.                    "entry_neu_sto

*eject
*----------------------------------------------------------------------*
* Mahnung
*----------------------------------------------------------------------*
FORM entry_mahn USING ent_retco ent_screen.

  DATA: l_druvo LIKE t166k-druvo,
        l_nast  LIKE nast,
        l_from_memory,
        l_doc   TYPE meein_purchase_doc_print.

  CLEAR ent_retco.
  l_druvo = '3'.
  CALL FUNCTION 'ME_READ_PO_FOR_PRINTING'
    EXPORTING
      ix_nast        = nast
      ix_screen      = ent_screen
    IMPORTING
      ex_retco       = ent_retco
      ex_nast        = l_nast
      doc            = l_doc
    CHANGING
      cx_druvo       = l_druvo
      cx_from_memory = l_from_memory.
  CHECK ent_retco EQ 0.
  CALL FUNCTION 'ME_PRINT_PO'
    EXPORTING
      ix_nast        = l_nast
      ix_druvo       = l_druvo
      doc            = l_doc
      ix_screen      = ent_screen
      ix_from_memory = l_from_memory
      ix_toa_dara    = toa_dara
      ix_arc_params  = arc_params
      ix_fonam       = tnapr-fonam                          "HW 214570
    IMPORTING
      ex_retco       = ent_retco.
ENDFORM.                    "entry_mahn

*eject
*----------------------------------------------------------------------*
* Auftragsbestätigungsmahnung
*----------------------------------------------------------------------*
FORM entry_aufb USING ent_retco ent_screen.

  DATA: l_druvo LIKE t166k-druvo,
        l_nast  LIKE nast,
        l_from_memory,
        l_doc   TYPE meein_purchase_doc_print.

  CLEAR ent_retco.
  l_druvo = '7'.
  CALL FUNCTION 'ME_READ_PO_FOR_PRINTING'
    EXPORTING
      ix_nast        = nast
      ix_screen      = ent_screen
    IMPORTING
      ex_retco       = ent_retco
      ex_nast        = l_nast
      doc            = l_doc
    CHANGING
      cx_druvo       = l_druvo
      cx_from_memory = l_from_memory.
  CHECK ent_retco EQ 0.
  CALL FUNCTION 'ME_PRINT_PO'
    EXPORTING
      ix_nast        = l_nast
      ix_druvo       = l_druvo
      doc            = l_doc
      ix_screen      = ent_screen
      ix_from_memory = l_from_memory
      ix_toa_dara    = toa_dara
      ix_arc_params  = arc_params
      ix_fonam       = tnapr-fonam                          "HW 214570
    IMPORTING
      ex_retco       = ent_retco.
ENDFORM.                    "entry_aufb
*eject
*----------------------------------------------------------------------*
* Lieferabrufdruck für Formular MEDRUCK mit Fortschrittszahlen
*----------------------------------------------------------------------*
FORM entry_lphe USING ent_retco ent_screen.

  DATA: l_druvo LIKE t166k-druvo,
        l_nast  LIKE nast,
        l_from_memory,
        l_xfz,
        l_doc   TYPE meein_purchase_doc_print.

  CLEAR ent_retco.
  l_druvo = '9'.
  l_xfz = 'X'.
  CALL FUNCTION 'ME_READ_PO_FOR_PRINTING'
    EXPORTING
      ix_nast        = nast
      ix_screen      = ent_screen
    IMPORTING
      ex_retco       = ent_retco
      ex_nast        = l_nast
      doc            = l_doc
    CHANGING
      cx_druvo       = l_druvo
      cx_from_memory = l_from_memory.
  CHECK ent_retco EQ 0.
  CALL FUNCTION 'ME_PRINT_PO'
    EXPORTING
      ix_nast        = l_nast
      ix_druvo       = l_druvo
      doc            = l_doc
      ix_xfz         = l_xfz
      ix_screen      = ent_screen
      ix_from_memory = l_from_memory
      ix_toa_dara    = toa_dara
      ix_arc_params  = arc_params
      ix_fonam       = tnapr-fonam                          "HW 214570
    IMPORTING
      ex_retco       = ent_retco.
ENDFORM.                    "entry_lphe
*eject
*----------------------------------------------------------------------*
* Lieferabrufdruck für Formular MEDRUCK ohne Fortschrittszahlen
*----------------------------------------------------------------------*
FORM entry_lphe_cd USING ent_retco ent_screen.

  DATA: l_druvo LIKE t166k-druvo,
        l_nast  LIKE nast,
        l_from_memory,
        l_doc   TYPE meein_purchase_doc_print.

  CLEAR ent_retco.
  l_druvo = '9'.
  CALL FUNCTION 'ME_READ_PO_FOR_PRINTING'
    EXPORTING
      ix_nast        = nast
      ix_screen      = ent_screen
    IMPORTING
      ex_retco       = ent_retco
      ex_nast        = l_nast
      doc            = l_doc
    CHANGING
      cx_druvo       = l_druvo
      cx_from_memory = l_from_memory.
  CHECK ent_retco EQ 0.
  CALL FUNCTION 'ME_PRINT_PO'
    EXPORTING
      ix_nast        = l_nast
      ix_druvo       = l_druvo
      doc            = l_doc
      ix_screen      = ent_screen
      ix_from_memory = l_from_memory
      ix_toa_dara    = toa_dara
      ix_arc_params  = arc_params
      ix_fonam       = tnapr-fonam                          "HW 214570
    IMPORTING
      ex_retco       = ent_retco.
ENDFORM.                    "entry_lphe_cd
*eject
*----------------------------------------------------------------------*
* Feinabrufdruck für Formular MEDRUCK mit Fortschrittszahlen
*----------------------------------------------------------------------*
FORM entry_lpje USING ent_retco ent_screen.

  DATA: l_druvo LIKE t166k-druvo,
        l_nast  LIKE nast,
        l_from_memory,
        l_xfz,
        l_doc   TYPE meein_purchase_doc_print.

  CLEAR ent_retco.
  l_druvo = 'A'.
  l_xfz = 'X'.
  CALL FUNCTION 'ME_READ_PO_FOR_PRINTING'
    EXPORTING
      ix_nast        = nast
      ix_screen      = ent_screen
    IMPORTING
      ex_retco       = ent_retco
      ex_nast        = l_nast
      doc            = l_doc
    CHANGING
      cx_druvo       = l_druvo
      cx_from_memory = l_from_memory.
  CHECK ent_retco EQ 0.
  CALL FUNCTION 'ME_PRINT_PO'
    EXPORTING
      ix_nast        = l_nast
      ix_druvo       = l_druvo
      doc            = l_doc
      ix_xfz         = l_xfz
      ix_screen      = ent_screen
      ix_from_memory = l_from_memory
      ix_toa_dara    = toa_dara
      ix_arc_params  = arc_params
      ix_fonam       = tnapr-fonam                          "HW 214570
    IMPORTING
      ex_retco       = ent_retco.
ENDFORM.                    "entry_lpje
*eject
*----------------------------------------------------------------------*
* Feinabrufdruck für Formular MEDRUCK ohne Fortschrittszahlen
*----------------------------------------------------------------------*
FORM entry_lpje_cd USING ent_retco ent_screen.

  DATA: l_druvo LIKE t166k-druvo,
        l_nast  LIKE nast,
        l_from_memory,
        l_doc   TYPE meein_purchase_doc_print.

  CLEAR ent_retco.
  l_druvo = 'A'.
  CALL FUNCTION 'ME_READ_PO_FOR_PRINTING'
    EXPORTING
      ix_nast        = nast
      ix_screen      = ent_screen
    IMPORTING
      ex_retco       = ent_retco
      ex_nast        = l_nast
      doc            = l_doc
    CHANGING
      cx_druvo       = l_druvo
      cx_from_memory = l_from_memory.
  CHECK ent_retco EQ 0.
  CALL FUNCTION 'ME_PRINT_PO'
    EXPORTING
      ix_nast        = l_nast
      ix_druvo       = l_druvo
      doc            = l_doc
      ix_screen      = ent_screen
      ix_from_memory = l_from_memory
      ix_toa_dara    = toa_dara
      ix_arc_params  = arc_params
      ix_fonam       = tnapr-fonam                          "HW 214570
    IMPORTING
      ex_retco       = ent_retco.
ENDFORM.                    "entry_lpje_cd
*eject
*----------------------------------------------------------------------*
*   INCLUDE FM06PE02                                                   *
*----------------------------------------------------------------------*
FORM entry_neu_matrix USING ent_retco ent_screen.

  DATA: l_druvo LIKE t166k-druvo,
        l_nast  LIKE nast,
        l_from_memory,
        l_doc   TYPE meein_purchase_doc_print.

  CLEAR ent_retco.
  IF nast-aende EQ space.
    l_druvo = '1'.
  ELSE.
    l_druvo = '2'.
  ENDIF.

  CALL FUNCTION 'ME_READ_PO_FOR_PRINTING'
    EXPORTING
      ix_nast        = nast
      ix_screen      = ent_screen
    IMPORTING
      ex_retco       = ent_retco
      ex_nast        = l_nast
      doc            = l_doc
    CHANGING
      cx_druvo       = l_druvo
      cx_from_memory = l_from_memory.
  CHECK ent_retco EQ 0.
  CALL FUNCTION 'ME_PRINT_PO'
    EXPORTING
      ix_nast        = l_nast
      ix_druvo       = l_druvo
      doc            = l_doc
      ix_screen      = ent_screen
      ix_from_memory = l_from_memory
      ix_mflag       = 'X'
      ix_toa_dara    = toa_dara
      ix_arc_params  = arc_params
      ix_fonam       = tnapr-fonam                          "HW 214570
    IMPORTING
      ex_retco       = ent_retco.
ENDFORM.                    "entry_neu_matrix
*eject
*----------------------------------------------------------------------*
* Angebotsabsage
*----------------------------------------------------------------------*
FORM entry_absa USING ent_retco ent_screen.

  DATA: l_druvo LIKE t166k-druvo,
        l_nast  LIKE nast,
        l_from_memory,
        l_doc   TYPE meein_purchase_doc_print.

  l_druvo = '4'.
  CLEAR ent_retco.
  CALL FUNCTION 'ME_READ_PO_FOR_PRINTING'
    EXPORTING
      ix_nast        = nast
      ix_screen      = ent_screen
    IMPORTING
      ex_retco       = ent_retco
      ex_nast        = l_nast
      doc            = l_doc
    CHANGING
      cx_druvo       = l_druvo
      cx_from_memory = l_from_memory.
  CHECK ent_retco EQ 0.
  CALL FUNCTION 'ME_PRINT_PO'
    EXPORTING
      ix_nast        = l_nast
      ix_druvo       = l_druvo
      doc            = l_doc
      ix_screen      = ent_screen
      ix_from_memory = l_from_memory
      ix_toa_dara    = toa_dara
      ix_arc_params  = arc_params
      ix_fonam       = tnapr-fonam                          "HW 214570
    IMPORTING
      ex_retco       = ent_retco.
ENDFORM.                    "entry_absa
*eject
*----------------------------------------------------------------------*
* Lieferplaneinteilung
*----------------------------------------------------------------------*
FORM entry_lpet USING ent_retco ent_screen.

  DATA: l_druvo LIKE t166k-druvo,
        l_nast  LIKE nast,
        l_from_memory,
        l_doc   TYPE meein_purchase_doc_print.

  CLEAR ent_retco.
  IF nast-aende EQ space.
    l_druvo = '5'.
  ELSE.
    l_druvo = '8'.
  ENDIF.

  CALL FUNCTION 'ME_READ_PO_FOR_PRINTING'
    EXPORTING
      ix_nast        = nast
      ix_screen      = ent_screen
    IMPORTING
      ex_retco       = ent_retco
      ex_nast        = l_nast
      doc            = l_doc
    CHANGING
      cx_druvo       = l_druvo
      cx_from_memory = l_from_memory.
  CHECK ent_retco EQ 0.
  CALL FUNCTION 'ME_PRINT_PO'
    EXPORTING
      ix_nast        = l_nast
      ix_druvo       = l_druvo
      doc            = l_doc
      ix_screen      = ent_screen
      ix_from_memory = l_from_memory
      ix_toa_dara    = toa_dara
      ix_arc_params  = arc_params
      ix_fonam       = tnapr-fonam                          "HW 214570
    IMPORTING
      ex_retco       = ent_retco.
ENDFORM.                    "entry_lpet
*eject
*----------------------------------------------------------------------*
* Lieferplaneinteilung
*----------------------------------------------------------------------*
FORM entry_lpfz USING ent_retco ent_screen.

  DATA: l_druvo LIKE t166k-druvo,
        l_nast  LIKE nast,
        l_from_memory,
        l_doc   TYPE meein_purchase_doc_print.

  CLEAR ent_retco.
  IF nast-aende EQ space.
    l_druvo = '5'.
  ELSE.
    l_druvo = '8'.
  ENDIF.

  CALL FUNCTION 'ME_READ_PO_FOR_PRINTING'
    EXPORTING
      ix_nast        = nast
      ix_screen      = ent_screen
    IMPORTING
      ex_retco       = ent_retco
      ex_nast        = l_nast
      doc            = l_doc
    CHANGING
      cx_druvo       = l_druvo
      cx_from_memory = l_from_memory.
  CHECK ent_retco EQ 0.
  CALL FUNCTION 'ME_PRINT_PO'
    EXPORTING
      ix_nast        = l_nast
      ix_druvo       = l_druvo
      doc            = l_doc
      ix_screen      = ent_screen
      ix_from_memory = l_from_memory
      ix_xfz         = 'X'
      ix_toa_dara    = toa_dara
      ix_arc_params  = arc_params
      ix_fonam       = tnapr-fonam                          "HW 214570
    IMPORTING
      ex_retco       = ent_retco.
ENDFORM.                    "entry_lpfz
*eject
*----------------------------------------------------------------------*
* Mahnung
*----------------------------------------------------------------------*
FORM entry_lpma USING ent_retco ent_screen.

  DATA: l_druvo LIKE t166k-druvo,
        l_nast  LIKE nast,
        l_from_memory,
        l_doc   TYPE meein_purchase_doc_print.

  CLEAR ent_retco.
  l_druvo = '6'.
  CALL FUNCTION 'ME_READ_PO_FOR_PRINTING'
    EXPORTING
      ix_nast        = nast
      ix_screen      = ent_screen
    IMPORTING
      ex_retco       = ent_retco
      ex_nast        = l_nast
      doc            = l_doc
    CHANGING
      cx_druvo       = l_druvo
      cx_from_memory = l_from_memory.
  CHECK ent_retco EQ 0.
  CALL FUNCTION 'ME_PRINT_PO'
    EXPORTING
      ix_nast        = l_nast
      ix_druvo       = l_druvo
      doc            = l_doc
      ix_screen      = ent_screen
      ix_from_memory = l_from_memory
      ix_toa_dara    = toa_dara
      ix_arc_params  = arc_params
      ix_fonam       = tnapr-fonam                          "HW 214570
    IMPORTING
      ex_retco       = ent_retco.
ENDFORM.                    "entry_lpma
ENHANCEMENT-POINT fm06pe02_02 SPOTS es_sapfm06p STATIC .
*&---------------------------------------------------------------------*
*&      Form  DATA_SELECTION
*&---------------------------------------------------------------------*
FORM data_selection  USING    p_l_retcode ent_retco ent_screen.

* added by sjswee on 8 Nov 2010; TR: P30K900638
* create range (HB01' , 'RA00' , 'RA01' , 'RB00')
  wa_condtype-sign   = 'I'.
  wa_condtype-option = 'EQ'.
  wa_condtype-low    = 'HB01'.
  APPEND wa_condtype TO it_condtype.

  wa_condtype-sign   = 'I'.
  wa_condtype-option = 'EQ'.
  wa_condtype-low    = 'RA00'.
  APPEND wa_condtype TO it_condtype.

  wa_condtype-sign   = 'I'.
  wa_condtype-option = 'EQ'.
  wa_condtype-low    = 'RA01'.
  APPEND wa_condtype TO it_condtype.

  wa_condtype-sign   = 'I'.
  wa_condtype-option = 'EQ'.
  wa_condtype-low    = 'RB00'.
  APPEND wa_condtype TO it_condtype.
* ended by sjswee on 8 Nov 2010.


*___A. get po details
*_ge PO header
  CLEAR ekko.
  SELECT SINGLE * FROM ekko INTO ekko
  WHERE ebeln = nast-objky.

  IF sy-subrc = 0.
*_get vendor details
*commented by sjswee 5 Dec
*    CLEAR lfa1.
*    SELECT SINGLE * FROM lfa1 INTO lfa1
*      WHERE lifnr = ekko-lifnr.
*uncommented by sjswee 5 Dec

* get date
    PERFORM get_date USING ekko-bedat
                     CHANGING v_date.


* get_vendor detail
    SELECT *  FROM ekpa
              INTO TABLE it_ekpa
              WHERE ebeln = ekko-ebeln.

    READ TABLE it_ekpa WITH KEY parvw = 'BA'.
    IF sy-subrc = 0.
      SELECT SINGLE * FROM lfa1
                      INTO wa_lfa1
                      WHERE lifnr = it_ekpa-lifn2.
    ELSE.
      READ TABLE it_ekpa WITH KEY parvw = 'LF'.
      IF sy-subrc = 0.
        SELECT SINGLE * FROM lfa1
                        INTO wa_lfa1
                        WHERE lifnr = it_ekpa-lifn2.
      ENDIF.
    ENDIF.

    SELECT SINGLE * FROM adrc
                    INTO wa_vadrc
                    WHERE addrnumber = wa_lfa1-adrnr.



*_ get po delivery address
*    CLEAR: it_deladdr[], l_landx.
*    CALL FUNCTION 'BAPI_PO_GETDETAIL1'
*      EXPORTING
*        purchaseorder    = ekko-ebeln
*        delivery_address = 'X'
*      TABLES
*        poaddrdelivery   = it_deladdr[].
*    IF NOT it_deladdr[] IS INITIAL.
*      READ TABLE it_deladdr INDEX 1.
*      IF sy-subrc = 0.
*        SELECT SINGLE landx INTO l_landx
*          FROM t005t
*          WHERE spras = it_deladdr-langu
*          AND   land1 = it_deladdr-country.
*      ENDIF.
*    ENDIF.
*_get PO items & delivery date
    CLEAR it_ekpo[].
    SELECT a~ebeln a~ebelp a~txz01 a~matnr
           a~ematn a~bukrs a~werks a~menge
           a~meins a~netpr
           a~adrnr a~adrn2
           b~eindt b~banfn
* added by sjswee on 8 Nov 2010; TR: P30K900638
           a~retpo a~netwr a~loekz
* ended by sjswee on 8 Nov 2010.
    FROM ekpo AS a INNER JOIN eket AS b
              ON  a~ebeln = b~ebeln
              AND a~ebelp = b~ebelp
    INTO TABLE it_ekpo
    WHERE a~ebeln = ekko-ebeln
    AND   a~loekz = space.

    IF sy-subrc = 0.
      CLEAR: v_vadrnr,
             wa_vadrc.

      READ TABLE it_ekpo WITH KEY loekz = space.
      IF sy-subrc <> 0.
        SELECT SINGLE * FROM adrc
                        INTO wa_vadrc
                        WHERE addrnumber = it_ekpo-adrnr.
      ELSE.
        SELECT SINGLE adrnr FROM t001w
                            INTO v_vadrnr
                            WHERE werks = it_ekpo-werks.

        SELECT SINGLE * FROM adrc
                        INTO wa_vadrc
                        WHERE addrnumber = v_vadrnr.

      ENDIF.

      SELECT SINGLE remark FROM adrct
                           INTO v_remark
                           WHERE addrnumber = wa_vadrc-addrnumber.



**_get plant name (business name-header)
*      CLEAR t001w.
*      READ TABLE it_ekpo INDEX 1.
*      SELECT SINGLE * FROM t001w
*        WHERE werks = it_ekpo-werks.
**_ get delivry address
*      READ TABLE it_ekpo INDEX 1.
*      CLEAR it_deladdr[].
*      IF sy-subrc = 0 AND it_ekpo-adrn2 <> space.
*        SELECT name1 city1 post_code1 street country langu
*          INTO TABLE it_deladdr
*          FROM adrc
*          WHERE addrnumber = it_ekpo-adrn2.
*      ELSEIF sy-subrc = 0 AND it_ekpo-adrnr <> space.
*        SELECT name1 city1 post_code1 street country langu
*                  INTO TABLE it_deladdr
*                  FROM adrc
*                  WHERE addrnumber = it_ekpo-adrnr.
*      ELSEIF it_ekpo-adrn2 = space AND it_ekpo-adrnr = space.
*        it_deladdr-name1      = t001w-name1.
*        it_deladdr-city1      = t001w-ort01.
*        it_deladdr-post_code1 = t001w-pstlz.
*        it_deladdr-street     = t001w-stras.
*        it_deladdr-country    = t001w-land1.
*        it_deladdr-langu      = t001w-spras.
*        APPEND it_deladdr.
*      ENDIF.

*      IF NOT it_deladdr[] IS INITIAL.
*        READ TABLE it_deladdr INDEX 1.
*        IF sy-subrc = 0.
*          SELECT SINGLE landx INTO l_landx
*            FROM t005t
*            WHERE spras = it_deladdr-langu
*            AND   land1 = it_deladdr-country.
*        ENDIF.
*      ENDIF.
*_get discount per item
      CLEAR it_konv[].
*Start of replace brianrabe P30K909976
*      SELECT knumv kposn kschl kawrt kbetr kherk kntyp kwert waers kpein kumza kmein
*      INTO TABLE it_konv
*      FROM konv
*      WHERE knumv = ekko-knumv.
**      AND   kschl IN ('PBXX','RA00' , 'RA01' , 'RB00').
*End of replace brianrabe P30K909976
TRY.
 cl_prc_result_factory=>get_instance( )->get_prc_result( )->get_price_element_db_by_key(
  EXPORTING
    iv_knumv                      = ekko-knumv
  IMPORTING
    et_prc_element_classic_format = it_konv[] ).
 CATCH cx_prc_result ##NO_HANDLER. "implement suitable error handling
ENDTRY.
*_read PO Header remarks( SPECIAL INSTRUCTIONS / REMARKS:)
      CLEAR: l_name, it_lines[], l_tdisc , l_totalamt.
      l_name = it_ekpo-ebeln.
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          id                      = 'F01'
          language                = sy-langu
          name                    = l_name
          object                  = 'EKKO'
        TABLES
          lines                   = it_lines
        EXCEPTIONS
          id                      = 1
          language                = 2
          name                    = 3
          not_found               = 4
          object                  = 5
          reference_check         = 6
          wrong_access_to_archive = 7
          OTHERS                  = 8.
      CLEAR ekko-description.
      IF sy-subrc = 0.
        READ TABLE it_lines INDEX 1.
        IF sy-subrc = 0.
          CONCATENATE ekko-description it_lines-tdline
          INTO ekko-description SEPARATED BY space.
        ENDIF.
        READ TABLE it_lines INDEX 2.
        IF sy-subrc = 0.
          CONCATENATE ekko-description it_lines-tdline
          INTO ekko-description SEPARATED BY space.
        ENDIF.
      ENDIF.

*_ fill other table entries
      LOOP AT it_ekpo.

* added by sjswee on 8 Nov 2010; TR: P30K900638
* get unit price from KONV-KBETR where KHERK = A & KNTYP = H
        READ TABLE it_konv WITH KEY kposn = it_ekpo-ebelp
                                    kntyp = 'H'.

*        it_ekpo-kbetr = it_konv-kbetr.
        l_waers = it_konv-waers.

* get condition unit desc
        CLEAR v_mseh3.
        SELECT SINGLE mseh3
               FROM t006a
               INTO v_mseh3
               WHERE msehi = it_konv-kmein
               AND   spras = sy-langu.

* get unit price
        v_kbetr = it_konv-kbetr.
*               v_kbetr =  ( it_konv-kbetr / it_konv-kpein ) / it_konv-kumza.
        WRITE it_konv-kbetr TO it_ekpo-kbetr_t CURRENCY it_konv-waers.
        CONDENSE it_ekpo-kbetr_t.
        CONCATENATE it_ekpo-kbetr_t '/' v_mseh3 INTO it_ekpo-kbetr_t.


* get discount KONV-KWERT where condition type = HB01,RA00,RA01 and RB00
        LOOP AT it_konv WHERE kposn = it_ekpo-ebelp
                        AND   kschl IN it_condtype.

*          it_ekpo-disc = it_ekpo-disc + it_konv-kwert.
          l_disc = l_disc + it_konv-kwert.
          l_tdisc = l_tdisc + l_disc.
        ENDLOOP.

* wrap text
        CALL FUNCTION 'RKD_WORD_WRAP'
          EXPORTING
            textline  = it_ekpo-txz01
            delimiter = ' '
            outputlen = '30'
          IMPORTING
            out_line1 = it_ekpo-txt1
            out_line2 = it_ekpo-txt2.

        MODIFY it_ekpo TRANSPORTING kbetr_t txt1 txt2.


* ended by sjswee on 8 Nov 2010.

** fill unit price and net price before discount
*        READ TABLE it_konv WITH KEY kposn = it_ekpo-ebelp
*                                    kschl = 'PBXX'.
*        IF sy-subrc = 0.
*          it_ekpo-kawrt = it_konv-kawrt.
*          it_ekpo-kbetr = it_konv-kbetr.
*          DELETE it_konv INDEX sy-tabix.
*        ENDIF.
** fill discount value
*        READ TABLE it_konv WITH KEY kposn = it_ekpo-ebelp."discount
*        IF sy-subrc = 0.
*          l_disc = ( it_konv-kbetr / 10 ).
*          IF l_disc < 0.
*            l_disc = l_disc * -1.
*            it_ekpo-disc = l_disc. CONDENSE it_ekpo-disc.
*          ENDIF.
*        ENDIF.
*read PO Item remarks
        CLEAR: l_name, it_lines[], l_menge, l_totaldisc.
        CONCATENATE it_ekpo-ebeln it_ekpo-ebelp INTO l_name.
        CALL FUNCTION 'READ_TEXT'
          EXPORTING
            id                      = 'F01'
            language                = sy-langu
            name                    = l_name
            object                  = 'EKPO'
          TABLES
            lines                   = it_lines
          EXCEPTIONS
            id                      = 1
            language                = 2
            name                    = 3
            not_found               = 4
            object                  = 5
            reference_check         = 6
            wrong_access_to_archive = 7
            OTHERS                  = 8.
        IF sy-subrc = 0.
          READ TABLE it_lines INDEX 1.
          IF sy-subrc = 0.
            CONCATENATE 'Remarks:' it_ekpo-remarks it_lines-tdline
            INTO it_ekpo-remarks SEPARATED BY space.
* added by sjswee on 8 Nov 2010; TR: P30K900638
            CALL FUNCTION 'RKD_WORD_WRAP'
              EXPORTING
                textline  = it_ekpo-remarks
                delimiter = ' '
                outputlen = '30'
              IMPORTING
                out_line1 = v_out_line1
                out_line2 = v_out_line2
                out_line3 = v_out_line3.

            MOVE-CORRESPONDING it_ekpo TO it_ekpo_r.
            it_ekpo_r-out_line1 = v_out_line1.
            it_ekpo_r-out_line2 = v_out_line2.
            it_ekpo_r-out_line3 = v_out_line3.
            APPEND it_ekpo_r.
* ended by sjswee on 8 Nov 2010.
          ENDIF.
          READ TABLE it_lines INDEX 2.
          IF sy-subrc = 0.
            CONCATENATE it_ekpo-remarks it_lines-tdline
            INTO it_ekpo-remarks SEPARATED BY space.
* added by sjswee on 8 Nov 2010; TR: P30K900638
            CALL FUNCTION 'RKD_WORD_WRAP'
              EXPORTING
                textline  = it_ekpo-remarks
                delimiter = ' '
                outputlen = '30'
              IMPORTING
                out_line1 = v_out_line1
                out_line2 = v_out_line2
                out_line3 = v_out_line3.

            MOVE-CORRESPONDING it_ekpo TO it_ekpo_r.
            it_ekpo_r-out_line1 = v_out_line1.
            it_ekpo_r-out_line2 = v_out_line2.
            it_ekpo_r-out_line3 = v_out_line3.
            APPEND it_ekpo_r.
* ended by sjswee on 8 Nov 2010.
          ENDIF.
        ENDIF.

        l_kawrt = it_ekpo-kawrt.
        l_kbetr = it_ekpo-kbetr.
        AT LAST.
          l_end = 'X'.
        ENDAT.
        IF l_end = 'X'.
          it_ekpo-totalamt = l_totalamt.
          it_ekpo-kawrt    = l_kawrt.
          it_ekpo-kbetr    = l_kbetr.
        ENDIF.

* added by sjswee on 8 Nov 2010; TR: P30K900638
* get order by
        SELECT SINGLE ablad
               FROM ekkn
               INTO it_ekpo-ablad
               WHERE ebeln = it_ekpo-ebeln
               AND   ebelp = it_ekpo-ebelp.
* get UOM desc
        SELECT SINGLE msehl
               FROM t006a
               INTO it_ekpo-msehl
               WHERE msehi = it_ekpo-meins
               AND   spras = sy-langu.
* ended by sjswee on 8 Nov 2010.

        l_menge = it_ekpo-menge.
        SPLIT l_menge AT '.' INTO it_ekpo-qty l_tmp.
        CONDENSE it_ekpo-qty.
*        CONCATENATE l_menge it_ekpo-meins INTO it_ekpo-qty_uom.

        IF l_disc < 0.
          l_disc = l_disc * -1.
          it_ekpo-disc = l_disc.
          CONDENSE it_ekpo-disc.
          WRITE l_disc TO it_ekpo-disc CURRENCY l_waers.
          MODIFY it_ekpo TRANSPORTING disc.
        ENDIF.

        IF v_kbetr < 0.
          v_kbetr = v_kbetr * -1.
        ENDIF.

*        it_ekpo-netwr = ( it_ekpo-qty * v_kbetr ) - l_disc.
        WRITE it_ekpo-netwr TO it_ekpo-netwr_t CURRENCY l_waers.
        CONDENSE it_ekpo-netwr_t.

        l_totalamt = l_totalamt + it_ekpo-netwr.
*        l_tdisc2 = l_tdisc2 + l_tdisc.

        MODIFY it_ekpo.
        CLEAR:  l_disc,
                v_kbetr.
      ENDLOOP.


      IF l_tdisc < 0.
        l_tdisc = l_tdisc * -1.
        WRITE l_tdisc TO l_totaldisc CURRENCY l_waers.
        CONDENSE l_totaldisc.
      ENDIF.
    ENDIF.

*)_get purchasing grp name
    CLEAR t024.
    SELECT SINGLE * FROM t024
     WHERE ekgrp = ekko-ekgrp.

*_ get logo per company code
    READ TABLE it_ekpo INDEX 1.
    CLEAR zbcgb_logo.

    SELECT SINGLE * FROM zbcgb_logo
      WHERE bukrs = it_ekpo-bukrs
        AND werks = it_ekpo-werks.
*_ get PO version
    CLEAR erev.
    SELECT MAX( revno ) FROM erev
      INTO erev-revno
      WHERE edokn = ekko-ebeln.
* commented by sjswee on 8 Nov 2010; TR: P30K900638
*    IF ( sy-subrc = 0  AND erev-revno = 00000000 ) OR
*       sy-subrc <> 0.
*      erev-revno = 1.
*    ENDIF.
* ended by sjswee on 8 Nov 2010.


    PERFORM po_printing USING ent_retco ent_screen.

  ENDIF.
ENDFORM.                    " DATA_SELECTION
*&---------------------------------------------------------------------*
*&      Form  PO_PRINTING
*&---------------------------------------------------------------------*
FORM po_printing USING ent_retco ent_screen.
*___B. Print Form (call script)
  CLEAR usr01.
  SELECT SINGLE * FROM usr01 WHERE bname = sy-uname.
*  break sjswee.
*
*  it_itcpo-tddest    = 'LOCL'.  "Output device (printer)
**  it_itcpo-tdimmed   = 'X'.     "Print immediately
*  it_itcpo-tdpreview = 'X'.
*  it_itcpo-tddelete  = 'X'.      "Delete after printing
*  it_itcpo-tdprogram = sy-repid. "Program Name

  CLEAR itcpo.
  MOVE-CORRESPONDING nast TO itcpo.
  itcpo-tdcover   = nast-tdocover.
  itcpo-tddest    = nast-ldest.
  itcpo-tddataset = nast-dsnam.
  itcpo-tdsuffix1 = nast-dsuf1.
  itcpo-tdsuffix2 = nast-dsuf2.
  itcpo-tdimmed   = nast-dimme.
  itcpo-tddelete  = nast-delet.
  itcpo-tdcopies  = nast-anzal.
  itcpo-tdprogram = sy-repid.
  itcpo-tdpreview = 'X'.


  CALL FUNCTION 'OPEN_FORM'
    EXPORTING
      application = 'TX'
      device      = 'PRINTER'
      dialog      = ' '
      form        = c_formname
      language    = sy-langu                              "#EC WRITE_OK
*      OPTIONS     = it_itcpo
      options     = itcpo
    IMPORTING
      language    = sy-langu
    EXCEPTIONS
      OTHERS      = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'LOGO'
      window  = 'LOGO'
    EXCEPTIONS
      OTHERS  = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'PO_NO'
      window  = 'PO_NO'
    EXCEPTIONS
      OTHERS  = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'BUS_HDR'
      window  = 'BUS_HDR'
    EXCEPTIONS
      OTHERS  = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'VERSION'
      window  = 'VERSION'
    EXCEPTIONS
      OTHERS  = 1.

*  CALL FUNCTION 'WRITE_FORM'
*    EXPORTING
*      element = 'PO_TITLE'
*      window  = 'PO_TITLE'
*    EXCEPTIONS
*      OTHERS  = 1.

*_vendor name and address
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'ADDRESS'
      window  = 'ADDRESS'
    EXCEPTIONS
      OTHERS  = 1.

*_delivery address
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'CONSGNEE'
      window  = 'CONSGNEE'
    EXCEPTIONS
      OTHERS  = 1.


  IF NOT it_ekpo[] IS INITIAL.
    READ TABLE it_ekpo INDEX 1.

    v_banfn = it_ekpo-banfn.
    v_ablad = it_ekpo-ablad.
    v_date  = v_date.
  ENDIF.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'INFO'
      window  = 'INFO'
    EXCEPTIONS
      OTHERS  = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'ITEM_HD'
      window  = 'ITEM_HD'
    EXCEPTIONS
      element = 1.

  LOOP AT it_ekpo.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'PO_TITLE'
        window  = 'PO_TITLE'
      EXCEPTIONS
        OTHERS  = 1.

    READ TABLE it_ekpo_r WITH KEY ebeln = it_ekpo-ebeln
                                  ebelp = it_ekpo-ebelp.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'ITEM_DATA'
        window  = 'MAIN'
      EXCEPTIONS
        OTHERS  = 1.

*    l_totalamt = it_ekpo-totalamt.
*    l_totaldisc = it_ekpo-totaldisc.
    AT LAST.
      it_ekpo-totaldisc = l_totaldisc.
      it_ekpo-totalamt = l_totalamt.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'ITEM_TOTAL'
          window  = 'MAIN'
        EXCEPTIONS
          OTHERS  = 1.

      IF ekko-description <> space.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'SPECIAL_INSTRUCTIONS'
            window  = 'MAIN'
          EXCEPTIONS
            OTHERS  = 1.
      ENDIF.
    ENDAT.

    AT LAST.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'FOOTER'
          window  = 'FOOTER'
        EXCEPTIONS
          OTHERS  = 1.
    ENDAT.

    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'PAGE'
        window  = 'PAGE'
      EXCEPTIONS
        OTHERS  = 1.
  ENDLOOP.

  CALL FUNCTION 'CLOSE_FORM'
    EXCEPTIONS
      unopened = 1
      OTHERS   = 2.

  IF sy-subrc = 0.
*    PERFORM protocol_update.
  ENDIF.
ENDFORM.                    " PO_PRINTING
*&---------------------------------------------------------------------*
*&      Form  GET_DATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_EKKO_BEDATE  text
*      <--P_V_DATE  text
*----------------------------------------------------------------------*
FORM get_date  USING    p_ekko_bedate
               CHANGING p_v_date.


  DATA: v_month(10) TYPE c.
  CLEAR p_ekko_bedate.

  CASE p_ekko_bedate+4(2).

    WHEN '01'.
      v_month = 'January'.
    WHEN '02'.
      v_month = 'February'.
    WHEN '03'.
      v_month = 'March'.
    WHEN '04'.
      v_month = 'April'.
    WHEN '05'.
      v_month = 'May'.
    WHEN '06'.
      v_month = 'June'.
    WHEN '07'.
      v_month = 'July'.
    WHEN '08'.
      v_month = 'August'.
    WHEN '09'.
      v_month = 'September'.
    WHEN '10'.
      v_month = 'October'.
    WHEN '11'.
      v_month = 'November'.
    WHEN '12'.
      v_month = 'December'.
    WHEN OTHERS.

  ENDCASE.

  CONCATENATE p_ekko_bedate+3(2) v_month p_ekko_bedate(4) INTO p_v_date SEPARATED BY space.



ENDFORM.                    " GET_DATE
