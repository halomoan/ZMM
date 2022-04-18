*----------------------------------------------------------------------*
*   INCLUDE FM06PE02                                                   *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*  MODIFICATION LOG
*-----------------------------------------------------------------------
*  DATE       change #    Programmer  Description.
*-----------------------------------------------------------------------
* 02.11.2018   BL01       Belindalee  If com code 1351,2211,2212,2213
*                                     use STCEG-VAT Reg no. frm T001
*-----------------------------------------------------------------------
FORM entry_neu USING ent_retco ent_screen.

  DATA: l_druvo       LIKE t166k-druvo,
        l_nast        LIKE nast,
        l_from_memory,
        l_doc         TYPE meein_purchase_doc_print.

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

  PERFORM data_selection USING ent_retco ent_screen.

ENDFORM.                    "entry_neu

*eject
*----------------------------------------------------------------------*
* Umlagerungsbestellung,  Hinweis 670912                               *
*----------------------------------------------------------------------*
FORM entry_neu_sto USING ent_retco ent_screen.

  DATA: l_druvo       LIKE t166k-druvo,
        l_nast        LIKE nast,
        l_from_memory,
        l_doc         TYPE meein_purchase_doc_print,
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

  DATA: l_druvo       LIKE t166k-druvo,
        l_nast        LIKE nast,
        l_from_memory,
        l_doc         TYPE meein_purchase_doc_print.

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

  DATA: l_druvo       LIKE t166k-druvo,
        l_nast        LIKE nast,
        l_from_memory,
        l_doc         TYPE meein_purchase_doc_print.

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

  DATA: l_druvo       LIKE t166k-druvo,
        l_nast        LIKE nast,
        l_from_memory,
        l_xfz,
        l_doc         TYPE meein_purchase_doc_print.

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

  DATA: l_druvo       LIKE t166k-druvo,
        l_nast        LIKE nast,
        l_from_memory,
        l_doc         TYPE meein_purchase_doc_print.

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

  DATA: l_druvo       LIKE t166k-druvo,
        l_nast        LIKE nast,
        l_from_memory,
        l_xfz,
        l_doc         TYPE meein_purchase_doc_print.

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

  DATA: l_druvo       LIKE t166k-druvo,
        l_nast        LIKE nast,
        l_from_memory,
        l_doc         TYPE meein_purchase_doc_print.

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

  DATA: l_druvo       LIKE t166k-druvo,
        l_nast        LIKE nast,
        l_from_memory,
        l_doc         TYPE meein_purchase_doc_print.

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

  DATA: l_druvo       LIKE t166k-druvo,
        l_nast        LIKE nast,
        l_from_memory,
        l_doc         TYPE meein_purchase_doc_print.

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

  DATA: l_druvo       LIKE t166k-druvo,
        l_nast        LIKE nast,
        l_from_memory,
        l_doc         TYPE meein_purchase_doc_print.

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

  DATA: l_druvo       LIKE t166k-druvo,
        l_nast        LIKE nast,
        l_from_memory,
        l_doc         TYPE meein_purchase_doc_print.

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

  DATA: l_druvo       LIKE t166k-druvo,
        l_nast        LIKE nast,
        l_from_memory,
        l_doc         TYPE meein_purchase_doc_print.

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
*ENHANCEMENT-POINT FM06PE02_02 SPOTS ES_SAPFM06P STATIC .
*&---------------------------------------------------------------------*
*&      Form  DATA_SELECTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM data_selection USING ent_retco ent_screen.

  CLEAR: it_ekpo[],
         it_ekpo,
         it_ekpo_r[],
         it_ekpo_r,
         it_konv[],
         it_konv,
         it_ekpa[],
         it_ekpa,
         ekko,
         wa_vadrc,
         wa_dadrc,
         v_dadrnr,
         v_desc1,
         v_desc2,
         v_desc3,
         v_desc4,
         v_desc5,
         v_remark,
         v_zterm.

* get PO Header
*  CLEAR ekko.
  DATA : werks LIKE ekpo-werks.
  SELECT SINGLE * FROM ekko INTO ekko
  WHERE ebeln = nast-objky.

  IF sy-subrc = 0.

* get company code
    CLEAR: v_adrnr,
           v_paval,
           v_tele,
           v_fax,
           v_paval,
           v_telefto,
           werks.

    SELECT SINGLE land1 INTO land1 FROM t001 WHERE bukrs EQ ekko-bukrs.


    SELECT SINGLE adrnr FROM t001
                        INTO v_adrnr
                        WHERE bukrs EQ ekko-bukrs.

    IF sy-subrc EQ 0.


      IF sy-langu = '1'.
        SELECT SINGLE * FROM adrc
                        INTO wa_adrc
                        WHERE addrnumber EQ v_adrnr
                          AND nation = 'C'.
      ELSE.
        SELECT SINGLE * FROM adrc
                        INTO wa_adrc
                        WHERE addrnumber EQ v_adrnr.
      ENDIF.
      CLEAR : v_adrnr1.
      IF ekko-bukrs = '2402' OR ekko-bukrs = '1304' OR ekko-bukrs = '1305' OR ekko-bukrs = '2701'.
        SELECT SINGLE werks INTO werks FROM ekpo WHERE ebeln = nast-objky
                                                 AND ebelp = '00010'.

        SELECT SINGLE adrnr FROM t001w
                 INTO v_adrnr1
                 WHERE werks = werks.

        SELECT SINGLE name1 name2 name3 FROM adrc
                        INTO (wa_adrc-name1 , wa_adrc-name2 , wa_adrc-name3)
                        WHERE addrnumber EQ v_adrnr1
                          AND nation = 'C'.
      ENDIF.
*get country code
      SELECT SINGLE telefto FROM t005k
                            INTO v_telefto
                            WHERE land1 EQ wa_adrc-country.

      IF sy-subrc EQ 0.
        CONCATENATE '+' v_telefto INTO v_telefto.
      ENDIF.


* get Telephone
      IF ekko-bukrs = '2402' OR ekko-bukrs = '1304' OR ekko-bukrs = '1305' OR ekko-bukrs = '2701'.
        SELECT SINGLE * FROM adr2
                        INTO wa_adr2
                        WHERE addrnumber = v_adrnr1.

        IF sy-subrc EQ 0.
          CONCATENATE v_telefto wa_adr2-telnr_call
                               INTO v_tele
                               SEPARATED BY space.
        ENDIF.
      ELSE.
        SELECT SINGLE * FROM adr2
                        INTO wa_adr2
                        WHERE addrnumber = v_adrnr.

        IF sy-subrc EQ 0.
          CONCATENATE v_telefto wa_adr2-telnr_call
                               INTO v_tele
                               SEPARATED BY space.
        ENDIF.

      ENDIF.

* get Fax
      IF ekko-bukrs = '2402' OR ekko-bukrs = '1304' OR ekko-bukrs = '1305' OR ekko-bukrs = '2701'.
        SELECT SINGLE * FROM adr3
                        INTO wa_adr3
                        WHERE addrnumber = v_adrnr1.

        IF sy-subrc EQ 0.
          CONCATENATE v_telefto wa_adr3-faxnr_call
                                  INTO v_fax
                                  SEPARATED BY space.
        ENDIF.
      ELSE.
        SELECT SINGLE * FROM adr3
                        INTO wa_adr3
                        WHERE addrnumber = v_adrnr.

        IF sy-subrc EQ 0.
          CONCATENATE v_telefto wa_adr3-faxnr_call
                                  INTO v_fax
                                  SEPARATED BY space.
        ENDIF.
      ENDIF.
    ENDIF.

* get GST reg no
**BEGIN BL01  02.11.2018
*if com code 1351,2211,2212,2213 use STCEG-VAT Reg no. frm T001,
*else use PAVAL-Cash pay ID from t001z.
   IF ekko-bukrs EQ '1351' OR ekko-bukrs EQ '2211' OR
      ekko-bukrs EQ '2212' OR ekko-bukrs EQ '2213'.
    SELECT SINGLE stceg FROM t001
                        INTO v_paval
                        WHERE bukrs = ekko-bukrs.
   ELSE.
    SELECT SINGLE paval FROM t001z
                        INTO v_paval
                        WHERE bukrs = ekko-bukrs
                        AND   party = c_sapf08.
   ENDIF.
**END BL01 02.11.2018


* get date
    PERFORM get_date USING ekko-bedat
                     CHANGING v_date.

* get Vendor Address & details
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

* get vendor address
    CLEAR: v_vtelefto,
           v_vtele,
           v_vfax,
           wa_vadr2,
           wa_vadr3.

    IF sy-langu = '1'.
      SELECT SINGLE * FROM adrc
                      INTO wa_vadrc
                      WHERE addrnumber = wa_lfa1-adrnr
                        AND nation = 'C'.
    ELSE.
      SELECT SINGLE * FROM adrc
                      INTO wa_vadrc
                      WHERE addrnumber = wa_lfa1-adrnr.
    ENDIF.

*get vendorcountry code
    SELECT SINGLE telefto FROM t005k
                          INTO v_vtelefto
                          WHERE land1 EQ wa_vadrc-country.
    IF sy-subrc EQ 0.
      CONCATENATE '+' v_vtelefto INTO v_vtelefto.
    ENDIF.


* get vendor Telephone
    SELECT SINGLE * FROM adr2
                    INTO wa_vadr2
                    WHERE addrnumber = wa_lfa1-adrnr.

    IF sy-subrc EQ 0.
*>>> SUPPORT TICKET XXX - CHANGED BY RAMSES 22.10.2013 - START P30K906044
*    Take printed TEL NO from TEL_NUMBER field

*      CONCATENATE v_vtelefto wa_vadr2-telnr_call
      CONCATENATE v_vtelefto wa_vadr2-tel_number
                                   INTO v_vtele
                                   SEPARATED BY space.
*<<< SUPPORT TICKET XXX - CHANGED BY RAMSES 22.10.2013 - END
    ENDIF.

* get vendor Fax
    SELECT SINGLE * FROM adr3
                    INTO wa_vadr3
                    WHERE addrnumber = wa_lfa1-adrnr.

    IF sy-subrc EQ 0.
*>>> SUPPORT TICKET XXX - CHANGED BY RAMSES 22.10.2013 - START P30K906044
*    Take printed FAX NO from FAX_NUMBER field

*      CONCATENATE v_telefto wa_vadr3-faxnr_call
      CONCATENATE v_telefto wa_vadr3-fax_number
                                  INTO v_vfax
                                  SEPARATED BY space.

*<<< SUPPORT TICKET XXX - CHANGED BY RAMSES 22.10.2013 - END
    ENDIF.

* get payment term.
    SELECT SINGLE ztag1 FROM t052
                        INTO v_zterm
                        WHERE zterm = ekko-zterm.

* get Outlet number. nma 13042012
    SELECT SINGLE eikto FROM lfm1
                        INTO v_eikto
                        WHERE lifnr =  wa_lfa1-lifnr
                          AND ekorg = ekko-ekorg.

* get e-invoice's email address Sun Wu
    SELECT SINGLE SMTP_ADDR FROM ZMM_PO_EMAIL
                            INTO v_email
                            WHERE BUKRS = ekko-bukrs.


* get PO items & delivery date

    SELECT ekpo~ebeln
           ekpo~ebelp
           ekpo~txz01
           ekpo~matnr
           ekpo~ematn
           ekpo~bukrs
           ekpo~werks
           ekpo~idnlf                                       "P30K903197
           ekpo~menge
           ekpo~meins
           ekpo~netpr
           ekpo~adrnr
           ekpo~adrn2
           eket~eindt
           eket~banfn
           ekpo~retpo
           ekpo~netwr
           ekpo~loekz
           ekpo~mwskz
      FROM ekpo
      JOIN eket ON ekpo~ebeln = eket~ebeln AND
                   ekpo~ebelp = eket~ebelp
      INTO TABLE it_ekpo
     WHERE ekpo~ebeln = ekko-ebeln AND
           ekpo~loekz = space.

    IF sy-subrc = 0.

* get Delivery Address
      READ TABLE it_ekpo WITH KEY loekz = space.
      IF sy-subrc <> 0.
        IF sy-langu = '1'.
          SELECT SINGLE * FROM adrc
                          INTO wa_dadrc
                          WHERE addrnumber = it_ekpo-adrnr
                            AND nation = 'C'.
        ELSE.
          SELECT SINGLE * FROM adrc
                          INTO wa_dadrc
                          WHERE addrnumber = it_ekpo-adrnr.

        ENDIF.
      ELSE.
        SELECT SINGLE adrnr FROM t001w
                    INTO v_dadrnr
                    WHERE werks = it_ekpo-werks.
        IF sy-langu = '1'.
          SELECT SINGLE * FROM adrc
                          INTO wa_dadrc
                          WHERE addrnumber = v_dadrnr
                            AND nation = 'C'.
        ELSE.
          SELECT SINGLE * FROM adrc
                  INTO wa_dadrc
                  WHERE addrnumber = v_dadrnr.
        ENDIF.


      ENDIF.

      SELECT SINGLE remark FROM adrct
                           INTO v_remark
                           WHERE addrnumber = wa_dadrc-addrnumber.

* get discount per item
      CLEAR it_konv[].
*Start of replace brianrabe P30K909982
*      SELECT knumv
*             kposn
*             kschl
*             kawrt
*             kbetr
*             kherk
*             kntyp
*             kwert
*             waers
*             kpein
*             kumza
*             kmein
*      INTO TABLE it_konv
*      FROM konv
*      WHERE knumv = ekko-knumv.
**      AND   kschl IN ('PBXX','RA00' , 'RA01' , 'RB00').
TRY.
 cl_prc_result_factory=>get_instance( )->get_prc_result( )->get_price_element_db_by_key(
  EXPORTING
    iv_knumv                      = ekko-knumv
  IMPORTING
    et_prc_element_classic_format = it_konv[] ).
 CATCH cx_prc_result ##NO_HANDLER. "implement suitable error handling
ENDTRY.
*End of replace brianrabe P30K909982
*_read PO Header remarks( SPECIAL INSTRUCTIONS / REMARKS:)
      CLEAR: l_name,
             it_lines[],
             l_tdisc ,
             l_totalamt.

      l_name = it_ekpo-ebeln.
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          id                      = 'F01'
          language                = ekko-spras
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
          v_desc1 =  it_lines-tdline.
        ENDIF.
        READ TABLE it_lines INDEX 2.
        IF sy-subrc = 0.
          v_desc2 =  it_lines-tdline.
        ENDIF.
        READ TABLE it_lines INDEX 3.
        IF sy-subrc = 0.
          v_desc3 =  it_lines-tdline.
        ENDIF.
        READ TABLE it_lines INDEX 4.
        IF sy-subrc = 0.
          v_desc4 =  it_lines-tdline.
        ENDIF.
        READ TABLE it_lines INDEX 5.
        IF sy-subrc = 0.
          v_desc5 =  it_lines-tdline.
        ENDIF.
      ENDIF.


      PERFORM get_range.

      DATA : kbetr_t(6) TYPE p DECIMALS 3,
             amount(13) TYPE p DECIMALS 2.
*_ fill other table entries
      LOOP AT it_ekpo.
        CLEAR: kbetr_t,amount.
* Unit Price KONV-KBETR where KONV-KNTYP = H
        READ TABLE it_konv WITH KEY kposn = it_ekpo-ebelp
                                    kntyp = 'H'.
        IF sy-subrc = 0.
*        it_ekpo-kbetr = it_konv-kbetr.
          l_waers = it_konv-waers.

* get condition unit desc
          CLEAR v_mseh3.
          SELECT SINGLE mseh3
                 FROM t006a
                 INTO v_mseh3
                 WHERE msehi = it_konv-kmein
                 AND   spras = sy-langu.

*Commented & added on 15th Feb
*          it_ekpo-kbetr_t = ( it_konv-kbetr / it_konv-kpein ) / it_konv-kumza.
          kbetr_t = ( it_konv-kbetr / it_konv-kpein ) / it_konv-kumza.
        ENDIF.

*>>> SUPPORT TICKET TXXX - CHANGED BY RAMSES 12.11.2013 - START P30K906089
*    PO Output with Currency MMK
        IF l_waers = 'VND' OR l_waers = 'MMK'.
*<<< SUPPORT TICKET TXXX - CHANGED BY RAMSES 12.11.2013 - END
          kbetr_t = kbetr_t / 10.
          WRITE kbetr_t TO it_ekpo-kbetr_t CURRENCY l_waers.
        ELSE.
*>>> SUPPORT TICKET TXXX - CHANGED BY RAMSES 13.05.2015 - START P30K907441
*          it_ekpo-kbetr_t = kbetr_t.
          WRITE kbetr_t TO it_ekpo-kbetr_t DECIMALS 3.
*<<< SUPPORT TICKET TXXX - CHANGED BY RAMSES 13.05.2015 - END
        ENDIF.
        CONDENSE it_ekpo-kbetr_t.
*end 15th Feb

* get discount KONV-KWERT where condition type = HB01,RA00,RA01 and RB00
* get total disc based on each item.

        LOOP AT it_konv WHERE kposn = it_ekpo-ebelp
                        AND   kschl IN it_condtype.

*          it_ekpo-disc = it_ekpo-disc + it_konv-kwert.
          l_disc  = l_disc  + it_konv-kwert.
        ENDLOOP.

        IF l_disc < 0.
          l_disc = l_disc * -1.
          it_ekpo-disc = l_disc.
        ELSE.
          it_ekpo-disc = l_disc.
        ENDIF.

        WRITE l_disc TO it_ekpo-disc CURRENCY l_waers.
        CONDENSE it_ekpo-disc.

* wrap text
        IF ekko-spras = '1'.
          CALL FUNCTION 'RKD_WORD_WRAP'
            EXPORTING
              textline  = it_ekpo-txz01
              delimiter = ' '
              outputlen = '20'
            IMPORTING
              out_line1 = it_ekpo-txt1ch
              out_line2 = it_ekpo-txt2ch.
          MODIFY it_ekpo TRANSPORTING  disc kbetr_t txt1ch txt2ch.
        ELSE.
          CALL FUNCTION 'RKD_WORD_WRAP'
            EXPORTING
              textline  = it_ekpo-txz01
              delimiter = ' '
              outputlen = '30'
            IMPORTING
              out_line1 = it_ekpo-txt1
              out_line2 = it_ekpo-txt2.
          MODIFY it_ekpo TRANSPORTING  disc kbetr_t txt1 txt2.

        ENDIF.
        MODIFY it_ekpo TRANSPORTING  disc kbetr_t txt1 txt2.

**read PO Item remarks
*        CLEAR: l_name, it_lines[], l_menge, l_totaldisc.
        CLEAR: l_menge, l_totaldisc.

        l_kawrt = it_ekpo-kawrt.
        l_kbetr = it_ekpo-kbetr.
        AT LAST.
          l_end = 'X'.
        ENDAT.
        IF l_end = 'X'.
*          it_ekpo-totalamt = l_totalamt.
          WRITE l_totalamt TO it_ekpo-totalamt CURRENCY l_waers.
          CONDENSE it_ekpo-totalamt.
          it_ekpo-kawrt    = l_kawrt.
          it_ekpo-kbetr    = l_kbetr.
        ENDIF.

* get order by
*Start of changes by Venkatesh<VEGOPALARATH> on 26-Jan-2011
*Fetching new field ABLAD for 'Order by' on PO layout
*        SELECT SINGLE wempf
*               FROM ekkn
*               INTO it_ekpo-wempf
*               WHERE ebeln = it_ekpo-ebeln
*               AND   ebelp = it_ekpo-ebelp.
        SELECT SINGLE ablad
               FROM ekkn
               INTO it_ekpo-ablad
               WHERE ebeln = it_ekpo-ebeln
               AND   ebelp = it_ekpo-ebelp.
*End of changes by Venkatesh<VEGOPALARATH> on 26-Jan-2011
* get UOM desc
        SELECT SINGLE mseh3
               FROM t006a
               INTO it_ekpo-msehl
               WHERE msehi = it_ekpo-meins
               AND   spras = sy-langu.

        IF v_kbetr < 0.
          v_kbetr = v_kbetr * -1.
        ENDIF.

*        it_ekpo-netwr = ( it_ekpo-qty * v_kbetr ) - l_disc.

*Commented & added on 15th Feb
*        it_ekpo-amount = it_ekpo-netwr + l_disc.
        amount = it_ekpo-netwr + l_disc.
        WRITE amount TO it_ekpo-amount CURRENCY l_waers.
        CONDENSE it_ekpo-amount.
*End on 15th Feb

        IF it_ekpo-netwr <> 0.
          WRITE it_ekpo-netwr TO it_ekpo-netwr_t CURRENCY l_waers.
          CONDENSE it_ekpo-netwr_t.
        ELSE.
          it_ekpo-netwr_t = '0.00'.
        ENDIF.
        MODIFY it_ekpo TRANSPORTING amount netwr_t.

        l_totalamt = l_totalamt + it_ekpo-netwr.
        l_tdisc = l_tdisc + l_disc.

        MODIFY it_ekpo.
        CLEAR:  l_disc,
                v_kbetr.
      ENDLOOP.

      CLEAR l_totaldisc.
      IF l_tdisc <> 0.
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

    PERFORM print_po USING ent_retco ent_screen.

  ENDIF.
ENDFORM.                    " DATA_SELECTION
*&---------------------------------------------------------------------*
*&      Form  GET_RANGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_range .

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


ENDFORM.                    " GET_RANGE
*&---------------------------------------------------------------------*
*&      Form  PRINT_PO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM print_po USING ent_retco p_screen.
  DATA: xdevice(10),
        xprogramm   TYPE  tdprogram,
        xdialog.

  SET LANGUAGE ekko-spras.
  SET COUNTRY wa_lfa1-land1.

  CLEAR: xdialog, xdevice, itcpo.
  MOVE-CORRESPONDING nast TO itcpo.
  itcpo-tdtitle = nast-tdcovtitle.
  itcpo-tdfaxuser = nast-usnam.

*- Ausgabemedium festlegen --------------------------------------------*
  CASE nast-nacha.
    WHEN '2'.
      xdevice = 'TELEFAX'.
      IF nast-telfx EQ space.
        xdialog = 'X'.
      ELSE.
        itcpo-tdtelenum  = nast-telfx.
        IF nast-tland IS INITIAL.
          itcpo-tdteleland = lfa1-land1.
        ELSE.
          itcpo-tdteleland = nast-tland.
        ENDIF.
      ENDIF.

      IF p_screen NE space.
        itcpo-tdnoprint = 'X'.
        itcpo-tdpreview = 'X'.
      ELSE.
        itcpo-tdnoprint = 'X'.
      ENDIF.

    WHEN '3'.
      xdevice = 'TELETEX'.
      IF nast-teltx EQ space.
        xdialog = 'X'.
      ELSE.
        itcpo-tdtelenum  = nast-teltx.
        itcpo-tdteleland = lfa1-land1.
      ENDIF.

      IF p_screen NE space.
        itcpo-tdnoprint = 'X'.
        itcpo-tdpreview = 'X'.
      ELSE.
        itcpo-tdnoprint = 'X'.
      ENDIF.

    WHEN '4'.
      xdevice = 'TELEX'.
      IF nast-telx1 EQ space.
        xdialog = 'X'.
      ELSE.
        itcpo-tdtelenum  = nast-telx1.
        itcpo-tdteleland = lfa1-land1.
      ENDIF.

      IF p_screen NE space.
        itcpo-tdnoprint = 'X'.
        itcpo-tdpreview = 'X'.
      ELSE.
        itcpo-tdnoprint = 'X'.
      ENDIF.

    WHEN '5'.
      DATA:  lvs_comm_type   TYPE   ad_comm,
             lvs_comm_values TYPE   szadr_comm_values.

      IF p_screen NE space.
        itcpo-tdnoprint = 'X'.
        itcpo-tdpreview = 'X'.
      ELSE.
        itcpo-tdnoprint = 'X'.
      ENDIF.

      CALL FUNCTION 'ADDR_GET_NEXT_COMM_TYPE'
        EXPORTING
          strategy           = nast-tcode
          address_number     = wa_lfa1-adrnr
        IMPORTING
          comm_type          = lvs_comm_type
          comm_values        = lvs_comm_values
        EXCEPTIONS
          address_not_exist  = 1
          person_not_exist   = 2
          no_comm_type_found = 3
          internal_error     = 4
          parameter_error    = 5
          OTHERS             = 6.

      IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

*>>>> CR #16 Send PO email to Vendor's address based on Purchasing Organization note
*     Created by RAMSES 09.06.2014  -     START     P30K906641
      IF NOT ekko-ekorg IS INITIAL.

        DATA: lt_email      TYPE szadr_addr1_complete,
              lt_adsmtp_tab TYPE TABLE OF szadr_adsmtp_line,
              wa_adsmtp_tab TYPE szadr_adsmtp_line,
              po_ekorg(7)   TYPE c.

        CONCATENATE 'PO_' ekko-ekorg INTO po_ekorg.

        "Get complete address
        CALL FUNCTION 'ADDR_GET_COMPLETE'
          EXPORTING
            addrnumber              = wa_lfa1-adrnr
          IMPORTING
            addr1_complete          = lt_email
          EXCEPTIONS
            parameter_error         = 1
            address_not_exist       = 2
            internal_error          = 3
            wrong_access_to_archive = 4
            OTHERS                  = 5.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ELSE.

          IF NOT lt_email IS INITIAL.
            lt_adsmtp_tab[] = lt_email-adsmtp_tab[].         "Copy adsmtp table
            IF NOT lt_adsmtp_tab[] IS INITIAL.

              READ TABLE lt_adsmtp_tab INTO wa_adsmtp_tab WITH KEY adsmtp-remark = po_ekorg.     "Get adsmtp address that matches with Purchasing Org
              IF sy-subrc = 0.
                MOVE-CORRESPONDING wa_adsmtp_tab-adsmtp TO lvs_comm_values-adsmtp.                 "Overwrite address taken by standard program
              ELSE.
                READ TABLE lt_adsmtp_tab INTO wa_adsmtp_tab WITH KEY adsmtp-remark = space.        "Get default email address
                IF sy-subrc = 0.
                  MOVE-CORRESPONDING wa_adsmtp_tab-adsmtp TO lvs_comm_values-adsmtp.
                ENDIF.
              ENDIF.

            ENDIF.
          ENDIF.

        ENDIF.

      ENDIF.

*<<<< CR #16 Send PO email to Vendor's address based on Purchasing Organization note
*     Created by RAMSES 09.06.2014  -     END


* convert communication data
      MOVE-CORRESPONDING nast TO intnast.
      MOVE sy-repid           TO xprogramm.
      CALL FUNCTION 'CONVERT_COMM_TYPE_DATA'
        EXPORTING
          pi_comm_type              = lvs_comm_type
          pi_comm_values            = lvs_comm_values
          pi_country                = wa_lfa1-land1
          pi_repid                  = xprogramm
          pi_snast                  = intnast
          pi_mail_sender            = 'ZDONOTREPLY'   "P30K909314
*          pi_mail_sender            = sy-uname
        IMPORTING
          pe_itcpo                  = itcpo
          pe_device                 = xdevice
          pe_mail_recipient         = lvs_recipient
          pe_mail_sender            = lvs_sender
        EXCEPTIONS
          comm_type_not_supported   = 1
          recipient_creation_failed = 2
          sender_creation_failed    = 3
          OTHERS                    = 4.
      IF sy-subrc <> 0.
*       Avoids cancellation with message TD421
*        p_retco = '1'.                                           "831984
        PERFORM protocol_update USING '740' space space space space.
*       dummy message to make the message appear in the where-used list
        IF 1 = 2.
          MESSAGE s740(me).
        ENDIF.
        EXIT.
      ENDIF.

      IF xdevice = 'MAIL'.                                  "885787
*Check if Email is flagged for "Do not Use" then terminate email process and update processing log.
        IF lvs_comm_values-adsmtp-flg_nouse = 'X'.
          PERFORM protocol_update USING '740' space space space space.
          MESSAGE s000(zmm) WITH 'Vendor:' wa_lfa1-lifnr 'Email is marked for no use.' 'Please check'.
          EXIT.
        ELSE.

*     Check validity of email address to avoid cancellation with TD463
          CALL FUNCTION 'SX_ADDRESS_TO_DEVTYPE'             "831984
            EXPORTING
              recipient_id      = lvs_recipient
              sender_id         = lvs_sender
            EXCEPTIONS
              err_invalid_route = 1
              err_system        = 2
              OTHERS            = 3.
          IF sy-subrc <> 0.
*          p_retco = '1'.
            PERFORM protocol_update USING '740' space space space space.
*        dummy message to make the message appear in the where-used list
            IF 1 = 2.
              MESSAGE s740(me).
            ENDIF.
            EXIT.
          ENDIF.
        ENDIF.
      ENDIF.

      IF p_screen NE space.
        itcpo-tdnoprint = 'X'.
        itcpo-tdpreview = 'X'.
      ELSE.
        itcpo-tdnoprint = 'X'.
      ENDIF.

    WHEN OTHERS.
      xdevice = 'PRINTER'.

      IF nast-ldest EQ space.
        xdialog = 'X'.
      ELSE.
        itcpo-tddest   = nast-ldest.
      ENDIF.

      IF p_screen NE space.
        itcpo-tdnoprint = 'X'.
        itcpo-tdpreview = 'X'.
*      ELSE.
*        itcpo-tdpreview = 'X'.
*        itcpo-tdnoprint = ' '.
      ENDIF.

  ENDCASE.
*- Testausgabe auf Bildschirm -----------------------------------------*
*  IF p_screen NE space.
*    itcpo-tdpreview = 'X'.
*  ENDIF.

* Bei Probedruck, wenn das Medium keine Drucker ist.
  IF nast-sndex EQ 'X' AND nast-nacha NE '1'.
    xdevice = 'PRINTER'.
    IF nast-ldest EQ space.
      xdialog = 'X'.
    ELSE.
      itcpo-tddest   = nast-ldest.
    ENDIF.
  ENDIF.

*  itcpo-tdnoprint  = 'X'.
  itcpo-tdcover    = nast-tdocover.
  itcpo-tdcopies   = nast-anzal.
*  IF sy-ucomm EQ 'DRPR' OR
*     nast-sndex EQ 'X'.
*    itcpo-tdnoprint  = ' '.
*    itcpo-tdnoprev   = 'X'.
*    itcpo-tdcopies = 1.
*  ENDIF.
  itcpo-tddataset  = nast-dsnam.
  itcpo-tdsuffix1  = nast-dsuf1.
  itcpo-tdsuffix2  = nast-dsuf2.
  itcpo-tdimmed    = nast-dimme.
  itcpo-tddelete   = nast-delet.
  itcpo-tdsenddate = nast-vsdat.
  itcpo-tdsendtime = nast-vsura.
  itcpo-tdprogram  = sy-repid.
  itcpo-bcs_reqst  = nast-forfb.
  itcpo-bcs_status = nast-prifb.

  IF nast-sort1 = 'SWP'.
    itcpo-tdgetotf = 'X'.
  ENDIF.

  itcpo-tdnewid    = 'X'.

  BREAK mmirasol.

* Begin of P30K903197
  IF tnapr-kschl = 'ZNEV'.

    itcpo-tddest = 'LOC4'.

  ENDIF.
* End   of P30K903197

  CALL FUNCTION 'OPEN_FORM'
    EXPORTING
      form           = tnapr-fonam
      language       = ekko-spras
*     language       = '1'
      options        = itcpo
*     archive_index  = p_toa_dara
*     archive_params = p_arc_params
      device         = xdevice
      dialog         = xdialog
      mail_sender    = lvs_sender
      mail_recipient = lvs_recipient
    EXCEPTIONS
      canceled       = 01
      device         = 02
      OTHERS         = 03.
  IF sy-subrc NE 0.
*    p_retco = '1'.
    PERFORM protocol_update USING '142' ekko-ebeln space space space.
    EXIT.
  ENDIF.

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

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'COADDR'
      window  = 'COADDR'
    EXCEPTIONS
      OTHERS  = 1.

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
    CLEAR: v_banfn,
           v_wempf,
           v_ablad.

    READ TABLE it_ekpo INDEX 1.

    v_banfn = it_ekpo-banfn.
    v_wempf = it_ekpo-wempf.
*Start of changes by Venkatesh<VEGOPALARATH> on 26-Jan-2011
*Fetching new field ABLAD for 'Order by' on PO layout
    v_ablad = it_ekpo-ablad.
*End of changes by Venkatesh<VEGOPALARATH> on 26-Jan-2011
  ENDIF.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'INFO'
      window  = 'INFO'
    EXCEPTIONS
      OTHERS  = 1.

*{{ BEGIN OF INSERTION - Ticket T015524.........................................
*   Add by Denny Ivan 26/04/2016
*   TR# P30K908226 ZDEVAMS T015524 MM PO add tax columns v01
*   For Company Codes: 1304 (Hua Ye Xiamen Hotel Limit)
*                      1305 (Pan Pacific Tianjin)
*                      2402 (Suzhou Wugong Hotel Co.,)
  CLEAR: v_totalamt, v_totaltxt.
  IF ekko-bukrs = '1304' OR
     ekko-bukrs = '1305' OR
     ekko-bukrs = '2402' OR
     ekko-bukrs = '2701'.
*    BREAK zdevams.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'ITEM_HDTAX'
        window  = 'ITEM_HD'
      EXCEPTIONS
        element = 1.
  ELSE.
*}} END OF INSERTION - Ticket T015524...........................................

    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'ITEM_HD'
        window  = 'ITEM_HD'
      EXCEPTIONS
        element = 1.

  ENDIF.     "Ticket T015524 - P30K908226 - 26/04/2016

  LOOP AT it_ekpo.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'PO_TITLE'
        window  = 'PO_TITLE'
      EXCEPTIONS
        OTHERS  = 1.

*   Begin of P30K903197
*   Get Vietnamese Material Description
    BREAK mmirasol.

    CLEAR: v_maktx.

    SELECT SINGLE maktx
             FROM makt
             INTO v_maktx
            WHERE matnr = it_ekpo-matnr AND
                  spras = '쁩'.
*   End   of P30K903197

    READ TABLE it_ekpo_r WITH KEY ebeln = it_ekpo-ebeln
                                  ebelp = it_ekpo-ebelp.

*{{ BEGIN OF INSERTION - Ticket T015524.........................................
*   Add by Denny Ivan 26/04/2016
*   TR# P30K908226 ZDEVAMS T015524 MM PO add tax columns v01
*   For Company Codes: 1304 (Hua Ye Xiamen Hotel Limit)
*                      1305 (Pan Pacific Tianjin)
*                      2402 (Suzhou Wugong Hotel Co.,)
    IF ekko-bukrs = '1304' OR
       ekko-bukrs = '1305' OR
       ekko-bukrs = '2402' OR
       ekko-bukrs = '2701'.
*      break zdevams.
      PERFORM f_item_tax USING ekko it_ekpo
                         CHANGING w_itemtax v_totalamt.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'ITEM_TAX'
          window  = 'MAIN'
        EXCEPTIONS
          OTHERS  = 1.
    ELSE.
*}} END OF INSERTION - Ticket T015524...........................................

      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'ITEM_DATA'
          window  = 'MAIN'
        EXCEPTIONS
          OTHERS  = 1.

    ENDIF.     "Ticket T015524 - P30K908226 - 26/04/2016


*>>> Ticket T006217 * Deddy Rifky * 27.01.2012 >>>*
    CLEAR wa_ltext.
    IF sy-langu = '1'.
*      CONCATENATE '备注:' it_ekpo-remarks INTO it_ekpo-remarks.
      wa_ltext = '备注:'.
    ELSE.
*      CONCATENATE 'Remarks:' it_ekpo-remarks INTO it_ekpo-remarks.
      wa_ltext = 'Remarks:'.
    ENDIF.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'LTEXT'
        window  = 'MAIN'
      EXCEPTIONS
        OTHERS  = 1.

    CLEAR: l_name, it_lines,it_ekpo-remarks.
    REFRESH : it_lines,it_ltext.
    CONCATENATE it_ekpo-ebeln it_ekpo-ebelp INTO l_name.
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = 'F03'
        language                = ekko-spras
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

    LOOP AT it_lines.
      CONCATENATE it_ekpo-remarks it_lines-tdline
             INTO it_ekpo-remarks SEPARATED BY space.
    ENDLOOP.
    CONDENSE it_ekpo-remarks.

    CALL FUNCTION 'RKD_WORD_WRAP'
      EXPORTING
        textline  = it_ekpo-remarks
        delimiter = ' '
        outputlen = '30'
      TABLES
        out_lines = it_ltext.

    CLEAR wa_ltext.
    LOOP AT it_ltext INTO wa_ltext.
      CHECK wa_ltext IS NOT INITIAL.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'LTEXT'
          window  = 'MAIN'
        EXCEPTIONS
          OTHERS  = 1.
    ENDLOOP.

*Start of changes by Venkatesh <VEGOPALARATH> on 25-Jan-2011
*Unlimited long text change
    CLEAR: l_name, it_lines,it_ekpo-remarks.
    REFRESH : it_lines, it_ltext.
    CONCATENATE it_ekpo-ebeln it_ekpo-ebelp INTO l_name.
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = 'F01'
        language                = ekko-spras
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

*        IF sy-subrc = 0.

*>>> SUPPORT TICKET XXX : CHANGED BY RAMSES 25.10.2013 - START P30K906048
*    WRAP EACH LINE OF TEXTS INTO 30 CHARACTERS LONG

*    LOOP AT it_lines.
*      CONCATENATE it_ekpo-remarks it_lines-tdline
*             INTO it_ekpo-remarks SEPARATED BY space.
*    ENDLOOP.
*    CONDENSE it_ekpo-remarks.
*
*    CALL FUNCTION 'RKD_WORD_WRAP'
*      EXPORTING
*        textline  = it_ekpo-remarks
*        delimiter = ' '
*        outputlen = '30'
*      TABLES
*        out_lines = it_ltext.

    DATA: ltb_ltext TYPE STANDARD TABLE OF ty_ltext,
          lwa_ltext TYPE ty_ltext.

    LOOP AT it_lines.
      CLEAR wa_ltext.

      IF strlen( it_lines-tdline ) > 30.

        REFRESH: ltb_ltext[].

        CALL FUNCTION 'RKD_WORD_WRAP'
          EXPORTING
            textline  = it_lines-tdline
            delimiter = ' '
            outputlen = '30'
          TABLES
            out_lines = ltb_ltext.

        LOOP AT ltb_ltext INTO lwa_ltext.
          CLEAR wa_ltext.
          wa_ltext = lwa_ltext-text.
          APPEND wa_ltext TO it_ltext.
        ENDLOOP.

      ELSE.

        wa_ltext = it_lines-tdline.
        APPEND wa_ltext TO it_ltext.

      ENDIF.

    ENDLOOP.

*>>> SUPPORT TICKET XXX : CHANGED BY RAMSES 25.10.2013 - END

*End of changes by Venkatesh <VEGOPALARATH> on 25-Jan-2011
*Start of changes by Venkatesh<VEGOPALARATH> on 25-Jan-2011
    CLEAR wa_ltext.
    LOOP AT it_ltext INTO wa_ltext.
      CHECK wa_ltext IS NOT INITIAL.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'LTEXT'
          window  = 'MAIN'
        EXCEPTIONS
          OTHERS  = 1.
    ENDLOOP.
*<<< Ticket T006217 * Deddy Rifky * 27.01.2012 <<<*
*End of changes by Venkatesh<VEGOPALARATH> on 25-Jan-2011
    AT LAST.
      it_ekpo-totaldisc = l_totaldisc.

*Commented & added on 15th Feb
*      it_ekpo-totalamt = l_totalamt.
      WRITE l_totalamt TO  it_ekpo-totalamt CURRENCY l_waers.
      CONDENSE it_ekpo-totalamt.
*End 15th Feb

*{{ BEGIN OF INSERTION - Ticket T015524.........................................
*   Add by Denny Ivan 26/04/2016
*   TR# P30K908226 ZDEVAMS T015524 MM PO add tax columns v01
*   For Company Codes: 1304 (Hua Ye Xiamen Hotel Limit)
*                      1305 (Pan Pacific Tianjin)
*                      2402 (Suzhou Wugong Hotel Co.,)
      IF ekko-bukrs = '1304' OR
         ekko-bukrs = '1305' OR
         ekko-bukrs = '2402' OR
         ekko-bukrs = '2701'.
        WRITE v_totalamt CURRENCY ekko-waers TO v_totaltxt.
        CONDENSE v_totaltxt.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'ITEM_TOTAL_TAX'
            window  = 'MAIN'
          EXCEPTIONS
            OTHERS  = 1.
      ELSE.
*}} END OF INSERTION - Ticket T015524...........................................

        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'ITEM_TOTAL'
            window  = 'MAIN'
          EXCEPTIONS
            OTHERS  = 1.

      ENDIF.                   "Ticket T015524 - P30K908226 - 26/04/2016

      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'SPECIAL_INSTRUCTIONS'
          window  = 'MAIN'
        EXCEPTIONS
          OTHERS  = 1.
    ENDAT.

*    AT LAST. "P30K903197
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'FOOTER'
        window  = 'FOOTER'
      EXCEPTIONS
        OTHERS  = 1.

    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'FOOTER2'
        window  = 'FOOTER2'
      EXCEPTIONS
        OTHERS  = 1.
*    ENDAT. "P30K903197

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
    PERFORM protocol_update USING '000' ekko-ebeln 'Printed' space space.
  ENDIF.
ENDFORM.                    " PRINT_PO
*&---------------------------------------------------------------------*
*&      Form  GET_DATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_EKKO_BEDAT  text
*      <--P_V_DATE  text
*----------------------------------------------------------------------*
FORM get_date  USING    p_ekko_bedat
               CHANGING p_v_date.


  DATA: v_month(10) TYPE c.


  CASE p_ekko_bedat+4(2).

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

  CONCATENATE p_ekko_bedat+6(2) v_month p_ekko_bedat(4) INTO p_v_date SEPARATED BY space.

ENDFORM.                    " GET_DATE


*&---------------------------------------------------------------------*
*&      Form  protocol_update
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PRU_MSGNO  text
*      -->PRU_MSGV1  text
*      -->PRU_MSGV2  text
*      -->PRU_MSGV3  text
*      -->PRU_MSGV4  text
*----------------------------------------------------------------------*
FORM protocol_update USING  pru_msgno pru_msgv1 pru_msgv2
                                      pru_msgv3 pru_msgv4.

  syst-msgid = 'ME'.
  syst-msgno = pru_msgno.
  syst-msgty = 'W'.
  syst-msgv1 = pru_msgv1.
  syst-msgv2 = pru_msgv2.
  syst-msgv3 = pru_msgv3.
  syst-msgv4 = pru_msgv4.
  CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
    EXPORTING
      msg_arbgb = syst-msgid
      msg_nr    = syst-msgno
      msg_ty    = syst-msgty
      msg_v1    = syst-msgv1
      msg_v2    = syst-msgv2
      msg_v3    = syst-msgv3
      msg_v4    = syst-msgv4
    EXCEPTIONS
      OTHERS    = 1.

ENDFORM.                    "protocol_update

*&---------------------------------------------------------------------*
*&      Form  F_ITEM_TAX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_EKPO  text
*      <--P_LW_ITEM_TAX  text
*----------------------------------------------------------------------*
FORM f_item_tax  USING    p_ekko  LIKE ekko
                          p_ekpo  LIKE it_ekpo
                 CHANGING p_itax  LIKE it_itemtax
                          p_total TYPE netwr.

  DATA lw_a003      LIKE a003.
  DATA lv_kbetr     LIKE konp-kbetr.
  DATA lv_taxamount LIKE ekpo-netwr.
  DATA lv_netwr     LIKE ekpo-netwr.

 IF EKKO-BUKRS = '1304' OR EKKO-BUKRS = '1305' OR EKKO-BUKRS = '2402'.
  MOVE-CORRESPONDING p_ekpo TO p_itax.
  WRITE p_itax-menge UNIT p_itax-meins TO p_itax-menge_t.
  SELECT SINGLE *
    FROM a003 INTO lw_a003
    WHERE kschl = 'MWVS'
      AND aland = 'CN'
      AND mwskz = p_ekpo-mwskz.
  IF sy-subrc = 0.
    SELECT SINGLE kbetr
      FROM konp INTO lv_kbetr
      WHERE knumh = lw_a003-knumh
        AND kschl = lw_a003-kschl.
    IF sy-subrc = 0.
      lv_kbetr = lv_kbetr / 10.
      MOVE lv_kbetr TO p_itax-taxrate.
      CONDENSE p_itax-taxrate.
      REPLACE '.00' IN  p_itax-taxrate WITH space.
      lv_taxamount = p_ekpo-netwr * lv_kbetr / 100.
      WRITE lv_taxamount CURRENCY ekko-waers TO p_itax-taxamount.
      CONDENSE p_itax-taxamount.
      lv_netwr = p_ekpo-netwr + lv_taxamount.
      p_total  = p_total + lv_netwr.
      WRITE lv_netwr CURRENCY ekko-waers TO p_itax-netwr_t.
      CONDENSE p_itax-netwr_t.
    ELSE.
      CLEAR: p_itax-taxrate, p_itax-taxamount.
      lv_netwr = p_ekpo-netwr.
      p_total  = p_total + lv_netwr.
      WRITE lv_netwr CURRENCY ekko-waers TO p_itax-netwr_t.
    ENDIF.
  ELSE.
    CLEAR: p_itax-taxrate, p_itax-taxamount.
    lv_netwr = p_ekpo-netwr.
    p_total  = p_total + lv_netwr.
    WRITE lv_netwr CURRENCY ekko-waers TO p_itax-netwr_t.
  ENDIF.

  CONDENSE: p_itax-txt1,
            p_itax-menge_t,
            p_itax-kbetr_t,
            p_itax-amount,
            p_itax-disc.
  ELSE.
    MOVE-CORRESPONDING p_ekpo TO p_itax.
  WRITE p_itax-menge UNIT p_itax-meins TO p_itax-menge_t.
  SELECT SINGLE *
    FROM a003 INTO lw_a003
    WHERE kschl = 'MWVS'
      AND aland = 'GB'
      AND mwskz = p_ekpo-mwskz.
  IF sy-subrc = 0.
    SELECT SINGLE kbetr
      FROM konp INTO lv_kbetr
      WHERE knumh = lw_a003-knumh
        AND kschl = lw_a003-kschl.
    IF sy-subrc = 0.
      lv_kbetr = lv_kbetr / 10.
      MOVE lv_kbetr TO p_itax-taxrate.
      CONDENSE p_itax-taxrate.
      REPLACE '.00' IN  p_itax-taxrate WITH space.
      lv_taxamount = p_ekpo-netwr * lv_kbetr / 100.
      WRITE lv_taxamount CURRENCY ekko-waers TO p_itax-taxamount.
      CONDENSE p_itax-taxamount.
      lv_netwr = p_ekpo-netwr + lv_taxamount.
      p_total  = p_total + lv_netwr.
      WRITE lv_netwr CURRENCY ekko-waers TO p_itax-netwr_t.
      CONDENSE p_itax-netwr_t.
    ELSE.
      CLEAR: p_itax-taxrate, p_itax-taxamount.
      lv_netwr = p_ekpo-netwr.
      p_total  = p_total + lv_netwr.
      WRITE lv_netwr CURRENCY ekko-waers TO p_itax-netwr_t.
    ENDIF.
  ELSE.
    CLEAR: p_itax-taxrate, p_itax-taxamount.
    lv_netwr = p_ekpo-netwr.
    p_total  = p_total + lv_netwr.
    WRITE lv_netwr CURRENCY ekko-waers TO p_itax-netwr_t.
  ENDIF.

  CONDENSE: p_itax-txt1,
            p_itax-menge_t,
            p_itax-kbetr_t,
            p_itax-amount,
            p_itax-disc.
  ENDIF.
ENDFORM.
