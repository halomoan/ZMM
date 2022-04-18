*&---------------------------------------------------------------------*
*&  Include           ZMMINT_0002_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_INITIALIZE_VALUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_initialize_value .
  p_bldat = sy-datum.
  p_vdatu = sy-datum.
  "End date should be max 3.5 years interval
  CALL FUNCTION 'CALCULATE_DATE'
    EXPORTING
      months      = '42'
      start_date  = sy-datum
    IMPORTING
      result_date = p_bdatu.

  GET PARAMETER ID 'ZMM_ARIBA_USER' FIELD gv_ariba_sid.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data .
  REFRESH: gt_message.
  CLEAR: gv_contract,
         gv_purchaseorder.

  IF ( cb_contract EQ abap_true  AND cb_po EQ abap_true AND cb_pir EQ abap_true ) OR
     ( cb_contract EQ abap_false AND cb_po EQ abap_false AND cb_pir EQ abap_false ).
    MESSAGE TEXT-e01 TYPE 'E'.
  ENDIF.
  PERFORM: f_display_progress USING TEXT-i02.

  CASE 'X'.
    WHEN cb_contract.
      IF p_evart IS INITIAL.
        MESSAGE TEXT-e04 TYPE 'E'.
      ENDIF.
      IF p_vdatu IS INITIAL OR p_bdatu IS INITIAL.
        MESSAGE TEXT-e05 TYPE 'E'.
      ENDIF.
      IF p_bukrs IS INITIAL.
        MESSAGE TEXT-e12 TYPE 'E'.
      ENDIF.
      READ TABLE gt_item TRANSPORTING NO FIELDS
                         WITH KEY fix = abap_true.
      IF sy-subrc NE 0.
        MESSAGE TEXT-e11 TYPE 'E'.
      ENDIF.
      PERFORM: f_get_date_interval USING p_vdatu
                                         p_bdatu.
      PERFORM: f_create_contract.

    WHEN cb_po.
      READ TABLE gt_item TRANSPORTING NO FIELDS
                         WITH KEY fix = abap_true.
      IF sy-subrc NE 0.
        MESSAGE TEXT-e07 TYPE 'E'.
      ENDIF.
      IF p_werks IS INITIAL.
        MESSAGE TEXT-e09 TYPE 'E'.
      ENDIF.
      IF p_bukrs IS INITIAL.
        MESSAGE TEXT-e12 TYPE 'E'.
      ENDIF.
      PERFORM: f_create_po.

    WHEN cb_pir.
      IF p_vdatu IS INITIAL OR p_bdatu IS INITIAL.
        MESSAGE TEXT-e05 TYPE 'E'.
      ENDIF.
      IF p_ekorg IS INITIAL.
        MESSAGE TEXT-e13 TYPE 'E'.
      ENDIF.
      IF p_ekgrp IS INITIAL.
        MESSAGE TEXT-e14 TYPE 'E'.
      ENDIF.
      LOOP AT gt_item INTO gs_item WHERE mark EQ abap_true.
        PERFORM f_validate_pir USING gs_item-lifnr  "#EC CI_FLDEXT_OK[2215424]
                                     gs_item-matnr
                                     p_ekorg
                                     gs_item-werks
                               CHANGING
                                     gv_infnr
                                     gv_pir_valid.

        IF gv_pir_valid EQ abap_true.
          PERFORM: f_update_pir USING gv_infnr.
*                  f_create_sourcelist.  "--
        ELSE.
          PERFORM: f_create_pir.
*                  f_create_sourcelist.  "--
        ENDIF.
      ENDLOOP.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_MESSAGE_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_display_message_log .
  DATA ls_message TYPE string.
  DELETE ADJACENT DUPLICATES FROM gt_message COMPARING ALL FIELDS.
  IF NOT gt_message[] IS INITIAL.
    LOOP AT gt_message INTO ls_message.
      WRITE / ls_message.
      LEAVE TO LIST-PROCESSING.
    ENDLOOP.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_CONSOLIDATE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_consolidate_data .
  DATA: lt_lfa1 TYPE ty_t_lfa1,
        lt_makt TYPE ty_t_makt,
        lt_eban TYPE TABLE OF eban.

  FIELD-SYMBOLS: <fs_data> TYPE ty_excel,
                 <fs_lfa1> TYPE ty_lfa1,
                 <fs_makt> TYPE ty_makt,
                 <fs_eban> TYPE eban.

* --> Start changed by Allan Taufiq P30K908768 - 18.12.2016
*  DELETE: gr_name1 WHERE low EQ 'PARTICIPANT*',
*          gr_name1 WHERE low EQ 'INITIAL*',
*          gr_name1 WHERE low EQ 'HISTORIC*',
*          gr_name1 WHERE low EQ 'RESERVE*',
*          gr_name1 WHERE low EQ 'LEADING INCUMBENT*',
*          gr_name1 WHERE low EQ 'LEADING*'.
*
*  SORT gr_name1 BY low.
*  DELETE ADJACENT DUPLICATES FROM gr_name1 COMPARING low.
* <-- End changed by Allan Taufiq P30K908768 - 18.12.2016

  DELETE: gt_data WHERE name1 EQ 'INITIAL',
          gt_data WHERE name1 EQ 'HISTORIC',
          gt_data WHERE name1 EQ 'RESERVE',
          gt_data WHERE name1 EQ 'LEADING INCUMBENT',
          gt_data WHERE name1 EQ 'LEADING',
          gt_data WHERE statu NE 'Accepted',
          gt_data WHERE menge IS INITIAL.

  IF NOT gt_data[] IS INITIAL.
    SELECT * INTO TABLE lt_eban
      FROM eban
      WHERE banfn EQ p_banfn.

* --> Start changed by Allan Taufiq P30K908768 - 18.12.2016
*    SELECT lifnr name1 INTO TABLE lt_lfa1
*      FROM lfa1
*      WHERE name1 IN gr_name1.

    SELECT lifnr name1 INTO TABLE lt_lfa1
      FROM lfa1
      FOR ALL ENTRIES IN gt_data
      WHERE lifnr EQ gt_data-lifnr.
* <-- End changed by Allan Taufiq P30K908768 - 18.12.2016

    SELECT matnr maktx INTO TABLE lt_makt
      FROM makt
      FOR ALL ENTRIES IN gt_data
      WHERE matnr EQ gt_data-matnr
        AND spras EQ sy-langu.
  ENDIF.

  LOOP AT gt_data ASSIGNING <fs_data>.
    READ TABLE lt_lfa1 ASSIGNING <fs_lfa1>
* --> Start changed by Allan Taufiq P30K908768 - 18.12.2016
*                       WITH KEY name1 = <fs_data>-name1.
                       WITH KEY lifnr = <fs_data>-lifnr.
* <-- End changed by Allan Taufiq P30K908768 - 18.12.2016
    IF sy-subrc EQ 0.
      gs_item-lifnr = <fs_lfa1>-lifnr.
      gs_item-name1 = <fs_lfa1>-name1.
    ELSE.
      gs_item-lifnr = 'N.A'.
      gs_item-name1 = <fs_data>-name1.
    ENDIF.

    READ TABLE lt_makt ASSIGNING <fs_makt>
                       WITH KEY matnr = <fs_data>-matnr.
    IF sy-subrc EQ 0.
      gs_item-matnr = <fs_data>-matnr.
      gs_item-maktx = <fs_makt>-maktx.
    ELSE.
      gs_item-maktx = <fs_data>-maktx.
      gs_item-txz01 = <fs_data>-maktx.
    ENDIF.

    gs_item-bukrs = <fs_data>-col09(4).
    gs_item-ekorg = <fs_data>-col10(4).
    gs_item-ekgrp = <fs_data>-col11(3).

    REPLACE ALL  OCCURRENCES OF ',' IN <fs_data>-menge WITH space.
    CONDENSE <fs_data>-menge.
    gs_item-menge = <fs_data>-menge.

    gs_item-netpr = <fs_data>-netpr.
    gs_item-waers = <fs_data>-waers.
    gs_item-netwr = gs_item-netpr * gs_item-menge.
    gs_item-werks = <fs_data>-werks.
    gs_item-meins = <fs_data>-meins.

    READ TABLE lt_eban ASSIGNING <fs_eban>
                       WITH KEY banfn = p_banfn.
    IF sy-subrc EQ 0.
      gs_item-banfn = p_banfn.
      gs_item-bnfpo = <fs_eban>-bnfpo.
      gs_item-pstyp = <fs_eban>-pstyp.
      gs_item-knttp = <fs_eban>-knttp.
      CASE gs_item-knttp.
        WHEN 'S'.
          gs_item-kostl = p_kostl.  "'2000301181'.
          gs_item-hkont = p_hkont.  "'0000748041'.
      ENDCASE.

      IF gs_item-werks IS INITIAL.
        gs_item-werks = <fs_eban>-werks.
      ENDIF.
      IF gs_item-meins IS INITIAL.
        gs_item-meins = <fs_eban>-meins.
      ENDIF.
    ENDIF.

    IF gs_item-bukrs IS INITIAL.
      gs_item-bukrs = p_bukrs.
    ENDIF.
    IF gs_item-ekorg IS INITIAL.
      gs_item-ekorg = p_ekorg.
    ENDIF.
    IF gs_item-ekgrp IS INITIAL.
      gs_item-ekgrp = p_ekgrp.
    ENDIF.
*   Start Insert for TR P30K909486
    gs_item-lifnr_curr = <fs_data>-lifnr_curr.
    gs_item-price_ext = <fs_data>-price_ext.
    gs_item-saving = <fs_data>-saving.
    gs_item-item_cat_ariba = <fs_data>-item_cat_ariba.
*   Start Insert for TR P30K909486

    APPEND gs_item TO gt_item.
    CLEAR gs_item.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_PROGRESS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TEXT_I01  text
*----------------------------------------------------------------------*
FORM f_display_progress  USING p_text.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text = p_text.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_ARIBA_AWARD_PROXY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_ariba_award_proxy .
  DATA: lv_award_quote  TYPE REF TO zaico_award_download_port_type,
        lv_award_in     TYPE zaiaward_download_request_mes1,
        lv_award_out    TYPE zaiaward_download_reply_messa1,
        lv_oref         TYPE REF TO cx_root,
        lv_text         TYPE string,
        lcl_utility     TYPE REF TO cl_http_utility,
        lv_decoded_b64  TYPE string,
        lo_tab_descr    TYPE REF TO cl_abap_tabledescr,
        lo_struc_descr  TYPE REF TO cl_abap_structdescr,
        ls_comp         TYPE abap_compdescr,
        lt_string       TYPE TABLE OF string WITH HEADER LINE,
        lv_tabfield(20) TYPE c,
        ls_data         TYPE ty_excel,
        lv_tabix        TYPE i,
        lt_header       TYPE TABLE OF alsmex_tabline,
        ls_header       TYPE alsmex_tabline,
        ls_result       TYPE match_result,
        lv_string       TYPE text1000,
        lv_len          TYPE i,
        lv_pos          TYPE i,
        lv_last_pos     TYPE i,
        lv_counter      TYPE i,
        lv_count        TYPE i,
* --> Start added by Allan Taufiq P30K908768 - 18.12.2016
        lv_string01     TYPE text1000,
        lv_string02     TYPE text1000.
* <-- End added by Allan Taufiq P30K908768 - 18.12.2016

  FIELD-SYMBOLS: <fs_tabfield>.
  REFRESH: lt_string, lt_header.
* --> Start changed by Allan Taufiq P30K908768 - 18.12.2016
*           gr_name1.
* <-- End changed by Allan Taufiq P30K908768 - 18.12.2016

  lv_award_in-partition = '?'.
  lv_award_in-variant = '?'.
  lv_award_in-wsaward_export_input_bean_item-item-rfx_internal_id = p_document_id.

  TRY.
      CREATE OBJECT lv_award_quote
        EXPORTING
          logical_port_name = 'ZARBA_DOWNLOAD_AWARD'.

    CATCH cx_ai_system_fault INTO lv_oref.
      lv_text = lv_oref->get_text( ).
      APPEND lv_text TO gt_message.
  ENDTRY.

  TRY.
      CALL METHOD lv_award_quote->award_download_operation
        EXPORTING
          input  = lv_award_in
        IMPORTING
          output = lv_award_out.

    CATCH cx_ai_system_fault INTO lv_oref.
      lv_text = lv_oref->get_text( ).
      APPEND lv_text TO gt_message.
  ENDTRY.

  lv_text = lv_award_out-wsaward_export_output_bean_ite-item-error_message.
  APPEND lv_text TO gt_message.
  lv_text = lv_award_out-wsaward_export_output_bean_ite-item-mime_type.
  APPEND lv_text TO gt_message.
  lv_text = lv_award_out-wsaward_export_output_bean_ite-item-status.
  APPEND lv_text TO gt_message.
  IF lv_award_out-wsaward_export_output_bean_ite-item-award_document IS INITIAL.
    MESSAGE TEXT-e02 TYPE 'W'.
    EXIT.
  ENDIF.

  IF NOT lcl_utility IS BOUND.
    CREATE OBJECT lcl_utility.
  ENDIF.

  CALL METHOD cl_http_utility=>if_http_utility~decode_utf8
    EXPORTING
      encoded           = lv_award_out-wsaward_export_output_bean_ite-item-award_document
    RECEIVING
      unencoded         = lv_decoded_b64
    EXCEPTIONS
      conversion_failed = 1
      OTHERS            = 2.

  SPLIT lv_decoded_b64 AT '","' INTO TABLE lt_string.
  lo_tab_descr ?= cl_abap_tabledescr=>describe_by_data( gt_data ). "#EC CI_FLDEXT_OK[2215424] P30K909986
  CHECK sy-subrc = 0.
  lo_struc_descr ?= lo_tab_descr->get_table_line_type( ).

  LOOP AT lt_string.
    ADD 1 TO lv_tabix.
    ls_header-value = lt_string.
    ls_header-col = lv_tabix.
    APPEND ls_header TO lt_header.
    CLEAR ls_header.
    READ TABLE lt_string INDEX lv_tabix + 1 INTO lv_text.
    IF lv_text CA '"#"'.
      CLEAR lv_tabix.
      EXIT.
    ENDIF.
  ENDLOOP.

  LOOP AT lt_string.
    ADD 1 TO lv_tabix.
    READ TABLE lo_struc_descr->components INTO ls_comp INDEX lv_tabix.
    CONCATENATE 'LS_DATA-' ls_comp-name INTO lv_tabfield.
    CONDENSE lv_tabfield NO-GAPS.
    ASSIGN (lv_tabfield) TO <fs_tabfield>.
    IF sy-subrc NE 0.
      EXIT.
    ENDIF.
    <fs_tabfield> = lt_string.

    READ TABLE lt_header INTO ls_header WITH KEY col = lv_tabix.
    IF sy-subrc EQ 0.
      IF ls_header-value = 'Participant'.
        CLEAR: ls_result,
               lv_string,
               lv_counter,
               lv_count,
               lv_len,
               lv_pos,
               lv_last_pos.

        FIND ALL OCCURRENCES OF '(' IN <fs_tabfield> MATCH COUNT lv_count.
        IF lv_count GT 2.
          lv_string = <fs_tabfield>.
          lv_len = strlen( lv_string ).
          lv_counter = lv_count - 1.
          DO lv_counter TIMES.
            SEARCH lv_string FOR '('.
            IF sy-subrc EQ 0.
              lv_pos = sy-fdpos + 1.
              lv_len =  lv_len - sy-fdpos - 1.
              lv_string = lv_string+lv_pos(lv_len).
              lv_last_pos = lv_last_pos + sy-fdpos + 1.
            ELSE.
              EXIT.
            ENDIF.
          ENDDO.
          lv_last_pos = lv_last_pos - 1.
          ls_data-name1 = <fs_tabfield>(lv_last_pos).
        ELSEIF lv_count LE 2.
          FIND ALL OCCURRENCES OF '(' IN <fs_tabfield> RESULTS ls_result.
          IF sy-subrc EQ 0.
            lv_len = ls_result-offset.
            ls_data-name1 = <fs_tabfield>(lv_len).
          ELSE.
            ls_data-name1 = <fs_tabfield>.
          ENDIF.
        ENDIF.
        TRANSLATE ls_data-name1 TO UPPER CASE.

* --> Start changed by Allan Taufiq P30K908768 - 18.12.2016
*        gr_name1-sign = 'I'.
*        gr_name1-option = 'CP'.
*        gr_name1-low = ls_data-name1 && '*'.
*        APPEND gr_name1.

        SPLIT <fs_tabfield> AT '-' INTO lv_string01 lv_string02.
        ls_data-lifnr = lv_string01.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = ls_data-lifnr
          IMPORTING
            output = ls_data-lifnr.
* <-- End changed by Allan Taufiq P30K908768 - 18.12.2016
      ENDIF.
      IF ls_header-value = 'Material Number'.
        ls_data-matnr = <fs_tabfield>. "#EC CI_FLDEXT_OK[2215424] P30K909986
      ENDIF.
      IF ls_header-value = 'Bid Status'.
        ls_data-statu = <fs_tabfield>.
      ENDIF.
      IF ls_header-value = 'Item Name'.
        ls_data-maktx = <fs_tabfield>.
      ENDIF.
      IF ls_header-value = 'Price'.
        MOVE <fs_tabfield> TO ls_data-netpr.
      ENDIF.
      IF ls_header-value = 'Quantity'.
        ls_data-menge = <fs_tabfield>.
      ENDIF.
      IF ls_header-value = 'Material Group'.
        ls_data-matkl = <fs_tabfield>.
      ENDIF.
      IF ls_header-value = 'Material Type'.
        ls_data-mtart = <fs_tabfield>.
      ENDIF.
      IF ls_header-value = 'Plant'.
        ls_data-werks = <fs_tabfield>.
      ENDIF.
      IF ls_header-value = 'Order Unit'.
        ls_data-meins = <fs_tabfield>.
      ENDIF.
      IF ls_header-value = 'Currency'.
        ls_data-waers = <fs_tabfield>.
      ENDIF.
      IF ls_header-value = 'Company Code'.
        ls_data-bukrs = <fs_tabfield>.
      ENDIF.
      IF ls_header-value = 'Purchasing Organization'.
        ls_data-ekorg = <fs_tabfield>.
      ENDIF.
      IF ls_header-value = 'Purchasing Group'.
        ls_data-ekgrp = <fs_tabfield>.
      ENDIF.
*     Start Insert for TR P30K909486
      IF ls_header-value = 'Existing Supplier Name'.
        ls_data-lifnr_curr = <fs_tabfield>.
      ENDIF.
      IF ls_header-value = 'Extended Price'.
        ls_data-price_ext = <fs_tabfield>.
      ENDIF.
      IF ls_header-value = 'Savings'.
        ls_data-saving = <fs_tabfield>.
      ENDIF.
      IF ls_header-value = 'Item Category'.
        ls_data-item_cat_ariba = <fs_tabfield>.
      ENDIF.
*     End Insert for TR P30K909486
    ENDIF.

    READ TABLE lt_string INDEX lv_tabix + 1 INTO lv_text.
    IF lv_text CA '"#"'.
      APPEND ls_data TO gt_data.
      CLEAR: ls_data, lv_tabix.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_CREATE_PO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_create_po .
  DATA: ls_poheader   TYPE bapimepoheader,
        ls_poheaderx  TYPE bapimepoheaderx,
        lt_poitem     TYPE TABLE OF bapimepoitem,
        ls_poitem     TYPE bapimepoitem,
        lt_poitemx    TYPE TABLE OF bapimepoitemx,
        ls_poitemx    TYPE bapimepoitemx,
        lt_poaccount  TYPE TABLE OF bapimepoaccount,
        ls_poaccount  TYPE bapimepoaccount,
        lt_poaccountx TYPE TABLE OF bapimepoaccountx,
        ls_poaccountx TYPE bapimepoaccountx,
        lt_return     TYPE TABLE OF bapiret2,
        ls_return     TYPE bapiret2,
        lt_head       TYPE ty_t_item,
        ls_head       TYPE ty_item,
        lv_message    TYPE string,
        lv_item_intvl TYPE pincr VALUE '00010',
        lv_po_item    TYPE ebelp,
        lv_serial_no  TYPE dzekkn VALUE '01',
        lv_tabix      TYPE sy-tabix.

  lt_head[] = gt_item[].
  SORT lt_head BY lifnr.
  DELETE ADJACENT DUPLICATES FROM lt_head COMPARING lifnr.
  DELETE lt_head WHERE fix NE abap_true.

  LOOP AT lt_head INTO ls_head.
    REFRESH: lt_poitem,
             lt_poitemx,
             lt_poaccount,
             lt_poaccountx,
             lt_return.

    CLEAR: ls_poheader,
           ls_poheaderx,
           gv_purchaseorder,
           lv_po_item.

    LOOP AT gt_item INTO gs_item WHERE fix EQ abap_true
                                   AND lifnr EQ ls_head-lifnr.
      lv_tabix = sy-tabix.

      IF ls_poheader IS INITIAL.
        ls_poheader-comp_code = gs_item-bukrs.
        ls_poheader-doc_type = 'NB'.
        ls_poheader-vendor = gs_item-lifnr.
        ls_poheader-item_intvl = lv_item_intvl.
        ls_poheader-purch_org = gs_item-ekorg.
        ls_poheader-pur_group = gs_item-ekgrp.
        ls_poheader-currency = gs_item-waers.
        ls_poheader-currency_iso = gs_item-waers.
        ls_poheader-doc_date = p_bldat.
      ENDIF.

      IF ls_poheaderx IS INITIAL.
        ls_poheaderx-comp_code = abap_true.
        ls_poheaderx-doc_type =  abap_true.
        ls_poheaderx-vendor = abap_true.
        ls_poheaderx-item_intvl = abap_true.
        ls_poheaderx-purch_org = abap_true.
        ls_poheaderx-pur_group = abap_true.
        ls_poheaderx-currency = abap_true.
        ls_poheaderx-currency_iso = abap_true.
        ls_poheaderx-doc_date = abap_true.
      ENDIF.

      ADD 10 TO lv_po_item.
      ls_poitem-po_item = lv_po_item.
      ls_poitem-short_text = gs_item-maktx.
      ls_poitem-material = gs_item-matnr.
*Start of insert brianrabe P30K909986
        ls_poitem-material_long = gs_item-matnr.
*End of insert brianrabe P30K909986
      ls_poitem-plant = p_werks.
      ls_poitem-matl_group = gs_item-matkl.
      ls_poitem-quantity = gs_item-menge.
      ls_poitem-po_unit = gs_item-meins.
      ls_poitem-net_price = gs_item-netpr.
      ls_poitem-item_cat = gs_item-pstyp.
      ls_poitem-acctasscat = gs_item-knttp.
      ls_poitem-preq_no = gs_item-banfn.
      ls_poitem-preq_item = gs_item-bnfpo.
      APPEND ls_poitem TO lt_poitem.
      CLEAR ls_poitem.

      ls_poitemx-po_item = lv_po_item.
      ls_poitemx-po_itemx = abap_true.
      ls_poitemx-short_text = abap_true.
      ls_poitemx-material = abap_true.
*Start of insert brianrabe P30K909986
       ls_poitemx-material_long = abap_true.
*End of insert brianrabe P30K909986
      ls_poitemx-plant = abap_true.
      ls_poitemx-quantity = abap_true.
      ls_poitemx-po_unit = abap_true.
      ls_poitemx-net_price = abap_true.
      ls_poitemx-item_cat = abap_true.
      ls_poitemx-acctasscat = abap_true.
      ls_poitemx-preq_no = abap_true.
      ls_poitemx-preq_item = abap_true.
      APPEND ls_poitemx TO lt_poitemx.
      CLEAR ls_poitemx.

      ls_poaccount-po_item    = lv_po_item.
      ls_poaccount-serial_no  = lv_serial_no.
      ls_poaccount-quantity   = gs_item-menge.
      ls_poaccount-gl_account = gs_item-hkont.
      ls_poaccount-costcenter = gs_item-kostl.
      APPEND ls_poaccount TO lt_poaccount.
      CLEAR ls_poaccount.

      ls_poaccountx-po_item    = lv_po_item.
      ls_poaccountx-serial_no  = lv_serial_no.
      ls_poaccountx-po_itemx   = abap_true.
      ls_poaccountx-serial_nox = abap_true.
      ls_poaccountx-quantity   = abap_true.
      ls_poaccountx-gl_account = abap_true.
      ls_poaccountx-costcenter = abap_true.
      APPEND ls_poaccountx TO lt_poaccountx.
      CLEAR ls_poaccountx.
    ENDLOOP.

    CALL FUNCTION 'BAPI_PO_CREATE1'
      EXPORTING
        poheader         = ls_poheader
        poheaderx        = ls_poheaderx
      IMPORTING
        exppurchaseorder = gv_purchaseorder
      TABLES
        return           = lt_return
        poitem           = lt_poitem
        poitemx          = lt_poitemx
        poaccount        = lt_poaccount
        poaccountx       = lt_poaccountx.

    IF NOT gv_purchaseorder IS INITIAL .
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.

      gs_item-ebeln = gv_purchaseorder.
      MODIFY gt_item FROM gs_item
        INDEX lv_tabix
        TRANSPORTING ebeln.

*     PERFORM f_create_sourcelist.
      MESSAGE TEXT-s02 TYPE 'S'.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    ENDIF.

    LOOP AT lt_return INTO ls_return.
      lv_message = ls_return-message.
      APPEND lv_message TO gt_message.
    ENDLOOP.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_CREATE_PIR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_create_pir .
  DATA: lt_bdcdata  TYPE TABLE OF bdcdata,
        lt_bdcmsg   TYPE TABLE OF bdcmsgcoll,
        ls_bdcmsg   TYPE bdcmsgcoll,
        lv_mode     TYPE ctu_params-dismode VALUE 'N',
        lv_update   TYPE ctu_params-updmode VALUE 'A',
        lv_text     TYPE string,
        lv_netpr    TYPE bkbetr,
        lv_menge    TYPE menge_bi,
        lv_meins    TYPE meins,
        lv_vdatu    TYPE date_bi,
        lv_bdatu    TYPE date_bi,
        lv_uom_flag TYPE flag,
        lv_werks    TYPE werks_d.

  REFRESH: lt_bdcdata, lt_bdcmsg.

  CONCATENATE 'Material:' gs_item-matnr '(' gs_item-maktx ')' '|' 'Vendor:' gs_item-lifnr '(' gs_item-name1 ')'
  INTO lv_text SEPARATED BY space.
  APPEND lv_text TO gt_message.
  CLEAR lv_text.

  PERFORM: f_uom_conversion USING gs_item-meins
                            CHANGING lv_meins
                                     lv_uom_flag.
  IF lv_uom_flag EQ abap_true.
    MESSAGE e010(zmm) WITH gs_item-matnr INTO lv_text.
    APPEND lv_text TO gt_message.
    CLEAR lv_text.
    EXIT.
  ENDIF.

  PERFORM: f_convert_date_ext USING p_vdatu CHANGING lv_vdatu,
           f_convert_date_ext USING p_bdatu CHANGING lv_bdatu.

  WRITE: gs_item-menge UNIT gs_item-meins TO lv_menge,
         gs_item-netpr CURRENCY gs_item-waers TO lv_netpr.
  CONDENSE lv_netpr.

  IF cb_cp EQ abap_true.
    CLEAR lv_werks.
  ELSE.
    lv_werks = gs_item-werks.
  ENDIF.

  PERFORM f_bdc_data TABLES lt_bdcdata USING:
  'X' 'SAPMM06I'                '0100',
  ' ' 'BDC_OKCODE'              '/00',
  ' ' 'EINA-LIFNR'              gs_item-lifnr,
  ' ' 'EINA-MATNR'              gs_item-matnr, "#EC CI_FLDEXT_OK[2215424] P30K909986
  ' ' 'EINE-EKORG'              p_ekorg,
  ' ' 'EINE-WERKS'              lv_werks,
  ' ' 'RM06I-NORMB'             'X'.

  PERFORM f_bdc_data TABLES lt_bdcdata USING:
  'X' 'SAPMM06I'                '0101',
  ' ' 'BDC_OKCODE'              '/00',
*  ' ' 'EINA-URZLA'              'SG',
  ' ' 'EINA-UMREZ'              '1',
  ' ' 'EINA-UMREN'              '1',
  ' ' 'EINA-VABME'              '1'.

  PERFORM f_bdc_data TABLES lt_bdcdata USING:
  'X' 'SAPMM06I'                '0102',
  ' ' 'BDC_OKCODE'              '=KO',
  ' ' 'EINE-APLFZ'              '1',
  ' ' 'EINE-EKGRP'              p_ekgrp,
  ' ' 'EINE-UEBTO'              '5',
  ' ' 'EINE-NORBM'              lv_menge,
  ' ' 'EINE-NETPR'              lv_netpr,
  ' ' 'EINE-WAERS'              gs_item-waers.

  PERFORM f_bdc_data TABLES lt_bdcdata USING:
  'X' 'SAPMV13A'                '0201',
  ' ' 'BDC_OKCODE'              '=SICH',
  ' ' 'RV13A-DATAB'             lv_vdatu,
  ' ' 'RV13A-DATBI'             lv_bdatu.

  CALL TRANSACTION 'ME11' USING lt_bdcdata
                          MODE lv_mode
                          UPDATE lv_update
                          MESSAGES INTO lt_bdcmsg.

  READ TABLE lt_bdcmsg INTO ls_bdcmsg WITH KEY msgtyp = 'S'.
  IF sy-subrc EQ 0.
    CALL FUNCTION 'MESSAGE_TEXT_BUILD'
      EXPORTING
        msgid               = ls_bdcmsg-msgid
        msgnr               = ls_bdcmsg-msgnr
        msgv1               = ls_bdcmsg-msgv1
        msgv2               = ls_bdcmsg-msgv2
        msgv3               = ls_bdcmsg-msgv3
        msgv4               = ls_bdcmsg-msgv4
      IMPORTING
        message_text_output = lv_text.
    APPEND lv_text TO gt_message.

*   Start insert of TR P30K909486
*   Update the uploaded data into the system
    PERFORM log_pir_ariba USING ls_bdcmsg-msgv1
                                lv_text.
*   End insert of TR P30K909486

    CLEAR lv_text.
  ELSE.
    LOOP AT lt_bdcmsg INTO ls_bdcmsg.
      CALL FUNCTION 'MESSAGE_TEXT_BUILD'
        EXPORTING
          msgid               = ls_bdcmsg-msgid
          msgnr               = ls_bdcmsg-msgnr
          msgv1               = ls_bdcmsg-msgv1
          msgv2               = ls_bdcmsg-msgv2
          msgv3               = ls_bdcmsg-msgv3
          msgv4               = ls_bdcmsg-msgv4
        IMPORTING
          message_text_output = lv_text.
      APPEND lv_text TO gt_message.
      CLEAR lv_text.
    ENDLOOP.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_BDC_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_bdc_data  TABLES lt_bdcdata STRUCTURE bdcdata
                 USING  p_types
                        p_field
                        p_value.

  FIELD-SYMBOLS <lf_value>.
  CLEAR lt_bdcdata.
  MOVE p_types TO lt_bdcdata-dynbegin.
  IF p_types EQ 'X'.
    MOVE p_field TO lt_bdcdata-program.
    MOVE p_value TO lt_bdcdata-dynpro. "#EC CI_FLDEXT_OK[2215424]
  ELSE.
    ASSIGN p_value TO <lf_value>. "#EC CI_FLDEXT_OK[2215424]
    MOVE p_field TO lt_bdcdata-fnam.
    MOVE <lf_value> TO lt_bdcdata-fval. "#EC CI_FLDEXT_OK[2215424]
  ENDIF.
  APPEND lt_bdcdata.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_CREATE_SOURCELIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_create_sourcelist .
  DATA:
    lv_new_entry TYPE flag,
    lv_text      TYPE string.

  "Logic doesnt apply for Service
  CHECK NOT gs_item-matnr IS INITIAL.

  PERFORM f_validate_pir USING gs_item-lifnr "#EC CI_FLDEXT_OK[2215424] P30K909986
                               gs_item-matnr
                               gs_item-ekorg
                               gs_item-werks
                         CHANGING
                               gv_infnr
                               gv_pir_valid.

  IF gv_pir_valid EQ abap_true.
    PERFORM: f_update_pir USING gv_infnr.
  ELSE.
    PERFORM: f_create_pir.
  ENDIF.

  PERFORM update_source_list USING gs_item-ebeln
                                   gs_item-lifnr
                                   gs_item-matnr
                                   gs_item-werks
                             CHANGING
                                   lv_new_entry.

  IF lv_new_entry EQ abap_true.
    PERFORM f_create_source_list.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_SOURCE_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_source_list USING    p_ebeln TYPE ebeln
                                 p_lifnr TYPE lifnr
                                 p_matnr TYPE matnr
                                 p_werks TYPE werks_d
                        CHANGING p_new_entry.
  DATA:
    lt_eordu TYPE TABLE OF eordu,
    lt_eord  TYPE TABLE OF eord,
    lt_tupel TYPE TABLE OF metup,
    lv_text  TYPE string.

  FIELD-SYMBOLS:
    <fs_eordu>     TYPE eordu,
    <fs_eordu_new> TYPE eordu,
    <fs_eord>      TYPE eord,
    <fs_tupel>     TYPE metup.

  CLEAR p_new_entry.
  SELECT * INTO TABLE lt_eordu
    FROM eord
    WHERE matnr = p_matnr
      AND werks = p_werks.

* Make sure there's at least one source list's line item
  IF lt_eordu[] IS INITIAL.
    p_new_entry = abap_true.
    EXIT.
  ENDIF.

  SORT lt_eordu BY vdatu bdatu.
  LOOP AT lt_eordu ASSIGNING <fs_eordu>.
    APPEND INITIAL LINE TO lt_eord ASSIGNING <fs_eord>.
    MOVE-CORRESPONDING <fs_eordu> TO <fs_eord>.

* Item which is valid at beginning of the new source list entry will be updated
* It can be only one line
    IF <fs_eordu>-vdatu < p_vdatu AND
       <fs_eordu>-bdatu >= p_vdatu.
* Update the item so it's validity ends before validity of the new entry
      <fs_eordu>-bdatu = p_vdatu - 1.
      <fs_eordu>-kz = 'U'.
      CLEAR <fs_eordu>-flifn.
    ELSE.
* Source list's items which are NOT valid at beginning of the new source list's entry will be deleted
      <fs_eordu>-kz = 'D'.
    ENDIF.
  ENDLOOP.

  READ TABLE lt_eordu ASSIGNING <fs_eordu> INDEX 1.
  APPEND INITIAL LINE TO lt_eordu ASSIGNING <fs_eordu_new>.
  <fs_eordu_new> = <fs_eordu>.

  CLEAR <fs_eordu_new>-zeord.
  <fs_eordu_new>-kz = 'I'.
  <fs_eordu_new>-vdatu = p_vdatu.
  <fs_eordu_new>-bdatu = p_bdatu.
  IF cb_po EQ abap_true.
    <fs_eordu_new>-flifn = abap_true.
  ENDIF.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = p_lifnr
    IMPORTING
      output = <fs_eordu_new>-lifnr.

  CALL FUNCTION 'ME_INITIALIZE_SOURCE_LIST'.

  CALL FUNCTION 'ME_DIRECT_INPUT_SOURCE_LIST'
    EXPORTING
      i_matnr          = p_matnr
      i_werks          = p_werks
      i_vorga          = 'B'
    TABLES
      t_eord           = lt_eordu
    EXCEPTIONS
      plant_missing    = 1
      material_missing = 2
      OTHERS           = 3.

  IF sy-subrc = 0.
    APPEND INITIAL LINE TO lt_tupel ASSIGNING <fs_tupel>.
    <fs_tupel>-matnr = p_matnr.
    <fs_tupel>-werks = p_werks.

    CALL FUNCTION 'ME_POST_SOURCE_LIST_NEW'.

    CALL FUNCTION 'ME_WRITE_DISP_RECORD_SOS' IN UPDATE TASK
      TABLES
        eord_alt = lt_eord
        eord_neu = lt_eordu
        tupel    = lt_tupel.

    COMMIT WORK AND WAIT.
    MESSAGE s007(zmm) WITH p_matnr p_werks INTO lv_text.
    APPEND lv_text TO gt_message.
    CLEAR lv_text.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_INIT_ITAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_itab .
  REFRESH: gt_data,
           gt_item.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_CREATE_CONTRACT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_create_contract .
  DATA: ls_header     TYPE bapimeoutheader,
        ls_headerx    TYPE bapimeoutheaderx,
        lt_item       TYPE TABLE OF bapimeoutitem,
        ls_item       TYPE bapimeoutitem,
        lt_itemx      TYPE TABLE OF bapimeoutitemx,
        ls_itemx      TYPE bapimeoutitemx,
        lt_account    TYPE TABLE OF bapimeoutaccount,
        ls_account    TYPE bapimeoutaccount,
        lt_accountx   TYPE TABLE OF bapimeoutaccountx,
        ls_accountx   TYPE bapimeoutaccountx,
        lt_return     TYPE TABLE OF bapiret2,
        ls_return     TYPE bapiret2,
        lt_head       TYPE ty_t_item,
        ls_head       TYPE ty_item,
        lv_message    TYPE string,
        lv_item_intvl TYPE pincr VALUE 00001,
        lv_item_no    TYPE ebelp,
        lv_serial_no  TYPE dzekkn VALUE 01.

  lt_head[] = gt_item[].
  SORT lt_head BY lifnr.
  DELETE ADJACENT DUPLICATES FROM lt_head COMPARING lifnr.
  DELETE lt_head WHERE fix NE abap_true.

  LOOP AT lt_head INTO ls_head.
    REFRESH: lt_item,
             lt_itemx,
             lt_account,
             lt_accountx,
             lt_return.

    CLEAR: ls_header,
           ls_headerx,
           gv_contract,
           lv_item_no.

    LOOP AT gt_item INTO gs_item WHERE fix EQ abap_true
                                   AND lifnr EQ ls_head-lifnr.
      IF ls_header IS INITIAL.
        ls_header-comp_code     = gs_item-bukrs.
        ls_header-doc_type      = p_evart.
        ls_header-creat_date    = sy-datum.
        ls_header-item_intvl    = lv_item_intvl.
        ls_header-vendor        = gs_item-lifnr.
        ls_header-purch_org     = gs_item-ekorg.
        ls_header-pur_group     = gs_item-ekgrp.
        ls_header-currency      = gs_item-waers.
        ls_header-currency_iso  = gs_item-waers.
        ls_header-doc_date      = p_bldat.
        ls_header-vper_start    = p_vdatu.
        ls_header-vper_end      = p_bdatu.
        ls_header-acum_value    = gs_item-netwr.
        ls_header-subitemint    = lv_item_intvl.
      ENDIF.

      IF ls_headerx IS INITIAL.
        ls_headerx-comp_code     = abap_true.
        ls_headerx-doc_type      = abap_true.
        ls_headerx-creat_date    = abap_true.
        ls_headerx-item_intvl    = abap_true.
        ls_headerx-vendor        = abap_true.
        ls_headerx-purch_org     = abap_true.
        ls_headerx-pur_group     = abap_true.
        ls_headerx-currency      = abap_true.
        ls_headerx-currency_iso  = abap_true.
        ls_headerx-doc_date      = abap_true.
        ls_headerx-vper_start    = abap_true.
        ls_headerx-vper_end      = abap_true.
        ls_headerx-acum_value    = abap_true.
        ls_headerx-subitemint    = abap_true.
      ENDIF.

      ADD 10 TO lv_item_no.
      ls_item-item_no    = lv_item_no.
      ls_item-short_text = gs_item-maktx.

      ls_item-material   = gs_item-matnr.
*Start of insert brianrabe P30K909986
      ls_item-material_long   = gs_item-matnr.
*End of insert brianrabe P30K909986
      ls_item-plant      = gs_item-werks.
      ls_item-matl_group = gs_item-matkl.
      ls_item-target_qty = gs_item-menge.
      ls_item-relord_qty = gs_item-menge.
      ls_item-po_unit    = gs_item-meins.
      ls_item-orderpr_un = gs_item-meins.
      ls_item-net_price  = gs_item-netpr.
      ls_item-item_cat   = gs_item-pstyp.
      ls_item-acctasscat = gs_item-knttp.
      ls_item-preq_no    = gs_item-banfn.
      ls_item-preq_item  = gs_item-bnfpo.
      APPEND ls_item TO lt_item.

      ls_itemx-item_no    = lv_item_no.
      ls_itemx-item_nox   = abap_true.
      ls_itemx-short_text = abap_true.
      ls_itemx-plant      = abap_true.
      ls_itemx-matl_group = abap_true.
      ls_itemx-target_qty = abap_true.
      ls_itemx-relord_qty = abap_true.
      ls_itemx-po_unit    = abap_true.
      ls_itemx-orderpr_un = abap_true.
      ls_itemx-net_price  = abap_true.
      ls_itemx-item_cat   = abap_true.
      ls_itemx-acctasscat = abap_true.
      ls_itemx-preq_no    = abap_true.
      ls_itemx-preq_item  = abap_true.
      APPEND ls_itemx TO lt_itemx.

      ls_account-item_no    = lv_item_no.
      ls_account-serial_no  = lv_serial_no.
      ls_account-quantity   = gs_item-menge.
      ls_account-gl_account = gs_item-hkont.
      ls_account-costcenter = gs_item-kostl.
      APPEND ls_account TO lt_account.

      ls_accountx-item_no    = lv_item_no.
      ls_accountx-serial_no  = lv_serial_no.
      ls_accountx-item_nox   = abap_true.
      ls_accountx-serial_nox = abap_true.
      ls_accountx-quantity   = abap_true.
      ls_accountx-gl_account = abap_true.
      ls_accountx-costcenter = abap_true.
      APPEND ls_accountx TO lt_accountx.
    ENDLOOP.

    CALL FUNCTION 'BAPI_CONTRACT_CREATE'
      EXPORTING
        header             = ls_header
        headerx            = ls_headerx
      IMPORTING
        purchasingdocument = gv_contract
      TABLES
        return             = lt_return
        item               = lt_item
        itemx              = lt_itemx
        account            = lt_account
        accountx           = lt_accountx.

    READ TABLE lt_return TRANSPORTING NO FIELDS WITH KEY type = 'E'.
    IF sy-subrc NE 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.

      MESSAGE TEXT-s01 TYPE 'S'.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    ENDIF.

    LOOP AT lt_return INTO ls_return.
      lv_message = ls_return-message.
      APPEND lv_message TO gt_message.
    ENDLOOP.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_SELECT_ALL_LINES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_select_all_lines .
  CHECK NOT gt_item[] IS INITIAL.
  gs_item-mark = abap_true.
  MODIFY gt_item FROM gs_item
    TRANSPORTING mark
    WHERE lifnr NE space.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_DESELECT_ALL_LINES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_deselect_all_lines .
  CHECK NOT gt_item[] IS INITIAL.
  CLEAR gs_item-mark.
  MODIFY gt_item FROM gs_item
    TRANSPORTING mark
    WHERE lifnr NE space.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_SORT_ASCENDING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_sort_ascending .
  DATA: ls_cols LIKE LINE OF tc9100-cols.
  READ TABLE tc9100-cols INTO ls_cols
                         WITH KEY selected = abap_true.
  IF sy-subrc EQ 0.
    SORT gt_item STABLE BY (ls_cols-screen-name+8) ASCENDING.
    CLEAR ls_cols-selected.
    MODIFY tc9100-cols
      FROM ls_cols
      INDEX sy-tabix.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_SORT_DESCENDING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_sort_descending .
  DATA: ls_cols LIKE LINE OF tc9100-cols.
  READ TABLE tc9100-cols INTO ls_cols
                         WITH KEY selected = abap_true.
  IF sy-subrc EQ 0.
    SORT gt_item STABLE BY (ls_cols-screen-name+8) DESCENDING.
    CLEAR ls_cols-selected.
    MODIFY tc9100-cols
      FROM ls_cols
      INDEX sy-tabix.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data .
  IF ( p_document_id IS NOT INITIAL AND p_filename IS NOT INITIAL ) OR
     ( p_document_id IS INITIAL AND p_filename IS INITIAL ).
    MESSAGE TEXT-e03 TYPE 'E'.
  ENDIF.
  IF p_banfn IS INITIAL.
    IF cb_po EQ abap_false AND cb_contract EQ abap_false AND cb_pir EQ abap_true.
      IF p_ekorg IS INITIAL.
        MESSAGE TEXT-e13 TYPE 'E'.
      ENDIF.
      IF p_ekgrp IS INITIAL.
        MESSAGE TEXT-e14 TYPE 'E'.
      ENDIF.
    ELSE.
      MESSAGE TEXT-e06 TYPE 'E'.
    ENDIF.
  ENDIF.

  PERFORM: f_display_progress USING TEXT-i01,
           f_init_itab.
  "Process based on selection
  IF p_document_id IS NOT INITIAL.
    PERFORM: f_ariba_award_proxy,
             f_consolidate_data.
  ELSEIF p_filename IS NOT INITIAL.
    PERFORM: f_upload_file,
             f_consolidate_file.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_upload_file .
  DATA: lt_excel     TYPE TABLE OF alsmex_tabline,
        ls_excel     TYPE alsmex_tabline,
        lt_header    TYPE TABLE OF alsmex_tabline,
        ls_header    TYPE alsmex_tabline,
        ls_excel_col TYPE alsmex_tabline,
        ls_excel_row TYPE alsmex_tabline,
        lv_colc      TYPE kcd_ex_col_n,
        lv_colt      TYPE kcd_ex_col_n,
        ls_data      TYPE ty_excel,
        ls_result    TYPE match_result,
        lv_string    TYPE text1000,
        lv_len       TYPE i,
        lv_pos       TYPE i,
        lv_last_pos  TYPE i,
        lv_counter   TYPE i,
        lv_count     TYPE i,
* --> Start added by Allan Taufiq P30K908768 - 18.12.2016
        lv_string01  TYPE text1000,
        lv_string02  TYPE text1000.
* <-- End added by Allan Taufiq P30K908768 - 18.12.2016

  FIELD-SYMBOLS: <fs_value> TYPE any.
  REFRESH: lt_excel, lt_header.
* --> Start changed by Allan Taufiq P30K908768 - 18.12.2016
*           gr_name1.
* <-- End changed by Allan Taufiq P30K908768 - 18.12.2016

  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = p_filename
      i_begin_col             = 1
      i_begin_row             = 1 "2
      i_end_col               = 23
      i_end_row               = 5000
    TABLES
      intern                  = lt_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.

  IF sy-subrc <> 0.
    MESSAGE TEXT-e08 TYPE 'E'.
  ELSE.
    LOOP AT lt_excel INTO ls_excel WHERE row = '0001'.
      ls_header-value = ls_excel-value.
      ls_header-col = ls_excel-col.
      APPEND ls_header TO lt_header.
      CLEAR ls_header.
    ENDLOOP.

    LOOP AT lt_excel INTO ls_excel_row WHERE col EQ '0001'
                                         AND row NE '0000'.
      LOOP AT lt_excel INTO ls_excel_col WHERE row EQ ls_excel_row-row.
        lv_colc = ls_excel_col-col.
        lv_colt = lv_colc.
        ASSIGN COMPONENT lv_colt OF STRUCTURE ls_data TO <fs_value>. "#EC CI_FLDEXT_OK[2215424] P30K909986
        IF sy-subrc NE 0.
          EXIT.
        ENDIF.
        <fs_value> = ls_excel_col-value.

        READ TABLE lt_header INTO ls_header WITH KEY col = ls_excel_col-col.
        IF sy-subrc = 0.
          IF ls_header-value = 'Participant'.
            CLEAR: ls_result,
                   lv_string,
                   lv_counter,
                   lv_count,
                   lv_len,
                   lv_pos,
                   lv_last_pos.

            FIND ALL OCCURRENCES OF '(' IN <fs_value> MATCH COUNT lv_count.
            IF lv_count GT 2.
              lv_string = <fs_value>.
              lv_len = strlen( lv_string ).
              lv_counter = lv_count - 1.
              DO lv_counter TIMES.
                SEARCH lv_string FOR '('.
                IF sy-subrc EQ 0.
                  lv_pos = sy-fdpos + 1.
                  lv_len =  lv_len - sy-fdpos - 1.
                  lv_string = lv_string+lv_pos(lv_len).
                  lv_last_pos = lv_last_pos + sy-fdpos + 1.
                ELSE.
                  EXIT.
                ENDIF.
              ENDDO.
              lv_last_pos = lv_last_pos - 1.
              ls_data-name1 = <fs_value>(lv_last_pos).
            ELSEIF lv_count LE 2.
              FIND ALL OCCURRENCES OF '(' IN <fs_value> RESULTS ls_result.
              IF sy-subrc EQ 0.
                lv_len = ls_result-offset.
                ls_data-name1 = <fs_value>(lv_len).
              ELSE.
                ls_data-name1 = <fs_value>.
              ENDIF.
            ENDIF.
            TRANSLATE ls_data-name1 TO UPPER CASE.

* --> Start changed by Allan Taufiq P30K908768 - 18.12.2016
*            gr_name1-sign = 'I'.
*            gr_name1-option = 'CP'.
*            gr_name1-low = ls_data-name1 && '*'.
*            APPEND gr_name1.

            SPLIT <fs_value> AT '-' INTO lv_string01 lv_string02.
            ls_data-lifnr = lv_string01.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = ls_data-lifnr
              IMPORTING
                output = ls_data-lifnr.
* <-- End changed by Allan Taufiq P30K908768 - 18.12.2016
          ENDIF.
          IF ls_header-value = 'Material Number'.
            ls_data-matnr = <fs_value>. "#EC CI_FLDEXT_OK[2215424] P30K909986
          ENDIF.
          IF ls_header-value = 'Bid Status'.
            ls_data-statu = <fs_value>.
          ENDIF.
          IF ls_header-value = 'Name'.
            ls_data-maktx = <fs_value>.
          ENDIF.
          IF ls_header-value = 'Price'.
            MOVE <fs_value> TO ls_data-netpr.
          ENDIF.
          IF ls_header-value = 'Quantity'.
            ls_data-menge = <fs_value>.
          ENDIF.
          IF ls_header-value = 'Material Group'.
            ls_data-matkl = <fs_value>.
          ENDIF.
          IF ls_header-value = 'Material Type'.
            ls_data-mtart = <fs_value>.
          ENDIF.
          IF ls_header-value = 'Plant'.
            ls_data-werks = <fs_value>.
          ENDIF.
          IF ls_header-value = 'Order Unit'.
            ls_data-meins = <fs_value>.
          ENDIF.
*     Start Insert for TR P30K909486
          IF ls_header-value = 'Existing Supplier Name'.
            ls_data-lifnr_curr = <fs_value>.
          ENDIF.
          IF ls_header-value = 'Extended Price'.
            ls_data-price_ext = <fs_value>.
          ENDIF.
          IF ls_header-value = 'Savings'.
            ls_data-saving = <fs_value>.
          ENDIF.
          IF ls_header-value = 'Item Category'.
            ls_data-item_cat_ariba = <fs_value>.
          ENDIF.
*     End Insert for TR P30K909486
        ENDIF.
      ENDLOOP.
      APPEND ls_data TO gt_data.
      CLEAR ls_data.
    ENDLOOP.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_CONSOLIDATE_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_consolidate_file .
  DATA: lt_lfa1  TYPE ty_t_lfa1,
        lt_makt  TYPE ty_t_makt,
        lt_eban  TYPE TABLE OF eban,
        lv_var01 TYPE string,
        lv_var02 TYPE string.

  FIELD-SYMBOLS: <fs_data> TYPE ty_excel,
                 <fs_lfa1> TYPE ty_lfa1,
                 <fs_makt> TYPE ty_makt,
                 <fs_eban> TYPE eban.

* --> Start changed by Allan Taufiq P30K908768 - 18.12.2016
*  DELETE: gr_name1 WHERE low EQ 'PARTICIPANT*',
*          gr_name1 WHERE low EQ 'INITIAL*',
*          gr_name1 WHERE low EQ 'HISTORIC*',
*          gr_name1 WHERE low EQ 'LEADING*'.
*
*  SORT gr_name1 BY low.
*  DELETE ADJACENT DUPLICATES FROM gr_name1 COMPARING low.
* <-- End changed by Allan Taufiq P30K908768 - 18.12.2016

  DELETE: gt_data WHERE name1 EQ 'INITIAL',
          gt_data WHERE name1 EQ 'HISTORIC',
          gt_data WHERE name1 EQ 'LEADING',
          gt_data WHERE statu NE 'Accepted',
          gt_data WHERE menge IS INITIAL.

  IF NOT gt_data[] IS INITIAL.
    SELECT * INTO TABLE lt_eban
      FROM eban
      WHERE banfn EQ p_banfn.

* --> Start changed by Allan Taufiq P30K908768 - 18.12.2016
*    SELECT lifnr name1 INTO TABLE lt_lfa1
*      FROM lfa1
*      WHERE name1 IN gr_name1.

    SELECT lifnr name1 INTO TABLE lt_lfa1
      FROM lfa1
      FOR ALL ENTRIES IN gt_data
      WHERE lifnr EQ gt_data-lifnr.
* <-- End changed by Allan Taufiq P30K908768 - 18.12.2016

    SELECT matnr maktx INTO TABLE lt_makt
      FROM makt
      FOR ALL ENTRIES IN gt_data
      WHERE matnr EQ gt_data-matnr
        AND spras EQ sy-langu.
  ENDIF.

  LOOP AT gt_data ASSIGNING <fs_data>.
    gs_item-mark = abap_true.

    READ TABLE lt_lfa1 ASSIGNING <fs_lfa1>
* --> Start changed by Allan Taufiq P30K908768 - 18.12.2016
*                       WITH KEY name1 = <fs_data>-name1.
                       WITH KEY lifnr = <fs_data>-lifnr.
* <-- End changed by Allan Taufiq P30K908768 - 18.12.2016
    IF sy-subrc EQ 0.
      gs_item-lifnr = <fs_lfa1>-lifnr.
      gs_item-name1 = <fs_lfa1>-name1.
    ELSE.
      gs_item-lifnr = 'N.A'.
      gs_item-name1 = <fs_data>-name1.
    ENDIF.

    READ TABLE lt_makt ASSIGNING <fs_makt>
                       WITH KEY matnr = <fs_data>-matnr.
    IF sy-subrc EQ 0.
      gs_item-matnr = <fs_makt>-matnr.
      gs_item-maktx = <fs_data>-maktx.
    ELSE.
      gs_item-matnr = <fs_data>-matnr.
      gs_item-maktx = <fs_data>-maktx.
    ENDIF.

    gs_item-menge = <fs_data>-menge.
    gs_item-netpr = <fs_data>-netpr.
    gs_item-netwr = gs_item-netpr * gs_item-menge.
    gs_item-werks = <fs_data>-werks.
    gs_item-matkl = <fs_data>-matkl.
    gs_item-mtart = <fs_data>-mtart.
    gs_item-meins = <fs_data>-meins.

    READ TABLE lt_eban ASSIGNING <fs_eban>
                       WITH KEY banfn = p_banfn
                                matnr = <fs_data>-matnr.
    IF sy-subrc EQ 0.
      gs_item-banfn = p_banfn.
      gs_item-bnfpo = <fs_eban>-bnfpo.
      gs_item-ekorg = <fs_eban>-ekorg.
      gs_item-ekgrp = <fs_eban>-ekgrp.
      gs_item-meins = <fs_eban>-meins.
      gs_item-waers = <fs_eban>-waers.
      gs_item-pstyp = <fs_eban>-pstyp.
      gs_item-knttp = <fs_eban>-knttp.
      CASE gs_item-knttp.
        WHEN 'K'.
          gs_item-kostl = p_kostl.  "'2000301181'.
          gs_item-hkont = p_hkont.  "'0000748041'.
      ENDCASE.
    ENDIF.

    gs_item-bukrs = p_bukrs.

    IF cb_pir EQ abap_true.
      gs_item-ekorg = p_ekorg.
      gs_item-ekgrp = p_ekgrp.

      SELECT SINGLE waers INTO gs_item-waers
        FROM lfm1
        WHERE lifnr EQ gs_item-lifnr
          AND ekorg EQ p_ekorg.
      IF sy-subrc NE 0.
        SELECT SINGLE waers INTO gs_item-waers
          FROM lfm1
          WHERE lifnr EQ gs_item-lifnr.
      ENDIF.
    ENDIF.

*   Start Insert for TR P30K909486
    gs_item-lifnr_curr = <fs_data>-lifnr_curr.
    gs_item-price_ext = <fs_data>-price_ext.
    gs_item-saving = <fs_data>-saving.
    gs_item-item_cat_ariba = <fs_data>-item_cat_ariba.
*   End Insert for TR P30K909486

    APPEND gs_item TO gt_item.
    CLEAR gs_item.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_UOM_CONVERSION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_ITEM_MEINS  text
*      <--P_LV_MEINS  text
*----------------------------------------------------------------------*
FORM f_uom_conversion  USING    p_input
                       CHANGING p_output
                                p_uom_flag .
  DATA: ls_marm TYPE marm.
  CLEAR p_uom_flag.

  CALL FUNCTION 'UNIT_OF_MEASURE_ISO_TO_SAP'
    EXPORTING
      iso_code  = p_input
    IMPORTING
      sap_code  = p_output
    EXCEPTIONS
      not_found = 1
      OTHERS    = 2.

  SELECT SINGLE * INTO ls_marm
    FROM marm
    WHERE matnr EQ gs_item-matnr
      AND meinh EQ p_output.

  IF sy-subrc NE 0.
    CLEAR p_output.
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        input          = p_input
        language       = sy-langu
      IMPORTING
        output         = p_output
      EXCEPTIONS
        unit_not_found = 1
        OTHERS         = 2.
    IF p_output IS INITIAL.
      p_output = p_input.
    ENDIF.

    SELECT SINGLE * INTO ls_marm
      FROM marm
      WHERE matnr EQ gs_item-matnr
        AND meinh EQ p_output.
    IF sy-subrc NE 0.
      p_uom_flag = abap_true.
    ENDIF.

  ELSEIF sy-subrc EQ 0.
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
      EXPORTING
        input          = p_output
        language       = sy-langu
      IMPORTING
        output         = p_output
      EXCEPTIONS
        unit_not_found = 1
        OTHERS         = 2.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_CONVERT_DATE_EXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_VDATU  text
*      <--P_LV_VDATU  text
*----------------------------------------------------------------------*
FORM f_convert_date_ext  USING    p_date_int
                         CHANGING p_date_ext.

  CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
    EXPORTING
      date_internal            = p_date_int
    IMPORTING
      date_external            = p_date_ext
    EXCEPTIONS
      date_internal_is_invalid = 1
      OTHERS                   = 2.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_CREATE_SOURCE_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_create_source_list .
  DATA: lt_bdcdata TYPE TABLE OF bdcdata,
        lt_bdcmsg  TYPE TABLE OF bdcmsgcoll,
        ls_bdcmsg  TYPE bdcmsgcoll,
        lv_mode    TYPE ctu_params-dismode VALUE 'N',
        lv_update  TYPE ctu_params-updmode VALUE 'A',
        lv_text    TYPE string,
        lv_vdatu   TYPE date_bi,
        lv_bdatu   TYPE date_bi.

  REFRESH: lt_bdcdata, lt_bdcmsg.

  PERFORM: f_convert_date_ext USING p_vdatu
                              CHANGING lv_vdatu,
           f_convert_date_ext USING p_bdatu
                              CHANGING lv_bdatu.

  PERFORM f_bdc_data TABLES lt_bdcdata USING:
  'X' 'SAPLMEOR'                '0200',
  ' ' 'BDC_OKCODE'              '/00',
  ' ' 'EORD-MATNR'              gs_item-matnr, "#EC CI_FLDEXT_OK[2215424] P30K909986
  ' ' 'EORD-WERKS'              gs_item-werks.

  PERFORM f_bdc_data TABLES lt_bdcdata USING:
  'X' 'SAPLMEOR'                '0205',
  ' ' 'BDC_OKCODE'              '=BU',
  ' ' 'EORD-VDATU(01)'          lv_vdatu,
  ' ' 'EORD-BDATU(01)'          lv_bdatu,
  ' ' 'EORD-LIFNR(01)'          gs_item-lifnr,
  ' ' 'EORD-EKORG(01)'          gs_item-ekorg,
  ' ' 'RM06W-FESKZ(01)'         'X'.

  CALL TRANSACTION 'ME01' USING lt_bdcdata
                          MODE lv_mode
                          UPDATE lv_update
                          MESSAGES INTO lt_bdcmsg.

  LOOP AT lt_bdcmsg INTO ls_bdcmsg.
    CALL FUNCTION 'MESSAGE_TEXT_BUILD'
      EXPORTING
        msgid               = ls_bdcmsg-msgid
        msgnr               = ls_bdcmsg-msgnr
        msgv1               = ls_bdcmsg-msgv1
        msgv2               = ls_bdcmsg-msgv2
        msgv3               = ls_bdcmsg-msgv3
        msgv4               = ls_bdcmsg-msgv4
      IMPORTING
        message_text_output = lv_text.

    APPEND lv_text TO gt_message.
    CLEAR lv_text.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_PIR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_update_pir  USING p_infnr.
  DATA: lt_bdcdata  TYPE TABLE OF bdcdata,
        lt_bdcmsg   TYPE TABLE OF bdcmsgcoll,
        ls_bdcmsg   TYPE bdcmsgcoll,
        lv_mode     TYPE ctu_params-dismode VALUE 'N',
        lv_update   TYPE ctu_params-updmode VALUE 'A',
        lv_text     TYPE string,
        lv_netpr    TYPE bkbetr,
        lv_meins    TYPE meins,
        lv_vdatu    TYPE date_bi,
        lv_bdatu    TYPE date_bi,
        lv_uom_flag TYPE flag,
        lv_werks    TYPE werks_d.

  REFRESH: lt_bdcdata, lt_bdcmsg.

  CONCATENATE 'Material:' gs_item-matnr '(' gs_item-maktx ')' '|' 'Vendor:' gs_item-lifnr '(' gs_item-name1 ')'
  INTO lv_text SEPARATED BY space.
  APPEND lv_text TO gt_message.
  CLEAR lv_text.

  PERFORM: f_uom_conversion USING gs_item-meins
                            CHANGING lv_meins
                                     lv_uom_flag.
  IF lv_uom_flag EQ abap_true.
    MESSAGE e010(zmm) WITH gs_item-matnr INTO lv_text.
    APPEND lv_text TO gt_message.
    CLEAR lv_text.
    EXIT.
  ENDIF.

  PERFORM: f_convert_date_ext USING p_vdatu CHANGING lv_vdatu,
           f_convert_date_ext USING p_bdatu CHANGING lv_bdatu.

  WRITE gs_item-netpr CURRENCY gs_item-waers TO lv_netpr.
  CONDENSE lv_netpr.

  IF cb_cp EQ abap_true.
    CLEAR lv_werks.
  ELSE.
    lv_werks = gs_item-werks.
  ENDIF.

  PERFORM f_bdc_data TABLES lt_bdcdata USING:
  'X' 'SAPMM06I'                '0100',
  ' ' 'BDC_OKCODE'              '/00',
  ' ' 'EINA-LIFNR'              gs_item-lifnr,
  ' ' 'EINA-MATNR'              gs_item-matnr, "#EC CI_FLDEXT_OK[2215424] P30K909986
  ' ' 'EINE-EKORG'              p_ekorg,
  ' ' 'EINE-WERKS'              lv_werks,
  ' ' 'EINA-INFNR'              p_infnr,
  ' ' 'RM06I-NORMB'             'X'.

  PERFORM f_bdc_data TABLES lt_bdcdata USING:
  'X' 'SAPMM06I'                '0101',
  ' ' 'BDC_OKCODE'              '/00',
  ' ' 'EINA-VABME'              '1'.

  PERFORM f_bdc_data TABLES lt_bdcdata USING:
  'X' 'SAPMM06I'                '0102',
  ' ' 'BDC_OKCODE'              '/00',
  ' ' 'EINE-APLFZ'              '1',
  ' ' 'EINE-UEBTO'              '5'.

  PERFORM f_bdc_data TABLES lt_bdcdata USING:
  'X' 'SAPMM06I'                '0105',
  ' ' 'BDC_OKCODE'              '=KO'.

  PERFORM f_bdc_data TABLES lt_bdcdata USING:
  'X' 'SAPLV14A'                '0102',
  ' ' 'BDC_OKCODE'              '=NEWD'.

  PERFORM f_bdc_data TABLES lt_bdcdata USING:
  'X' 'SAPMV13A'                '0201',
  ' ' 'BDC_OKCODE'              '=SICH',
  ' ' 'RV13A-DATAB'             lv_vdatu,
  ' ' 'RV13A-DATBI'             lv_bdatu,
  ' ' 'KONP-KBETR(01)'          lv_netpr,
 ' ' 'KONP-KMEIN(01)'          lv_meins.
* ' ' 'KONP-KMEIN(01)'          gs_item-meins.


  CALL TRANSACTION 'ME12' USING lt_bdcdata
                          MODE lv_mode
                          UPDATE lv_update
                          MESSAGES INTO lt_bdcmsg.

  READ TABLE lt_bdcmsg TRANSPORTING NO FIELDS
                       WITH KEY msgtyp = 'S'.
  IF sy-subrc EQ 0.
    MESSAGE s009(zmm) WITH p_infnr
                           gs_item-matnr
                           INTO lv_text.
    APPEND lv_text TO gt_message.

*   Start insert of TR P30K909486
*   Update the uploaded data into the system
    PERFORM log_pir_ariba USING p_infnr
                                lv_text.
*   End insert of TR P30K909486

    CLEAR lv_text.
  ELSE.
    LOOP AT lt_bdcmsg INTO ls_bdcmsg.
      CALL FUNCTION 'MESSAGE_TEXT_BUILD'
        EXPORTING
          msgid               = ls_bdcmsg-msgid
          msgnr               = ls_bdcmsg-msgnr
          msgv1               = ls_bdcmsg-msgv1
          msgv2               = ls_bdcmsg-msgv2
          msgv3               = ls_bdcmsg-msgv3
          msgv4               = ls_bdcmsg-msgv4
        IMPORTING
          message_text_output = lv_text.
      APPEND lv_text TO gt_message.
      CLEAR lv_text.
    ENDLOOP.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_DATE_INTERVAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_VDATU  text
*      -->P_P_BDATU  text
*----------------------------------------------------------------------*
FORM f_get_date_interval  USING p_vdatu p_bdatu.
  DATA: lv_days   TYPE vtbbewe-atage,
        lv_months TYPE vtbbewe-atage,
        lv_years  TYPE vtbbewe-atage.

  CALL FUNCTION 'FIMA_DAYS_AND_MONTHS_AND_YEARS'
    EXPORTING
      i_date_from    = p_vdatu
      i_date_to      = p_bdatu
      i_flg_separate = ' '
    IMPORTING
      e_days         = lv_days
      e_months       = lv_months
      e_years        = lv_years.

  IF lv_months GT 42. "No longer than 3.5 years
    MESSAGE TEXT-e10 TYPE 'E'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_LOG_TRANSACTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_log_transaction .
  DATA: ls_ariba_log TYPE zbcgb_ariba_log.
  CLEAR ls_ariba_log.

  SELECT SINGLE * INTO ls_ariba_log
    FROM zbcgb_ariba_log
    WHERE zadoc EQ p_document_id.

  ls_ariba_log-ztype   = 'OUT'.
  ls_ariba_log-zadoc   = p_document_id.
  ls_ariba_log-po_no   = gv_purchaseorder.
  ls_ariba_log-oa_no   = gv_contract.
  ls_ariba_log-pir_ind = cb_pir.
  ls_ariba_log-vdatu   = p_vdatu.
  ls_ariba_log-bdatu   = p_bdatu.
  ls_ariba_log-uname   = sy-uname.
  ls_ariba_log-erdat   = sy-datum.
  ls_ariba_log-uzeit   = sy-uzeit.
  MODIFY zbcgb_ariba_log FROM ls_ariba_log.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_PIR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_ITEM_LIFNR  text
*      -->P_GS_ITEM_MATNR  text
*      -->P_GS_ITEM_EKORG  text
*      -->P_GS_ITEM_WERKS  text
*      <--P_GV_PIR_VALID  text
*----------------------------------------------------------------------*
FORM f_validate_pir  USING    p_lifnr
                              p_matnr
                              p_ekorg
                              p_werks
                     CHANGING p_infnr
                              p_pir_valid.

  DATA: ls_eina TYPE eina,
        lt_a017 TYPE TABLE OF a017,
        lt_a018 TYPE TABLE OF a018.

  REFRESH: lt_a017, lt_a018.
  CLEAR: ls_eina, p_infnr, p_pir_valid.

  SELECT SINGLE * INTO ls_eina
    FROM eina
    WHERE lifnr EQ p_lifnr
      AND matnr EQ p_matnr.

  IF sy-subrc EQ 0.
    SELECT * INTO TABLE lt_a017
      FROM a017
      UP TO 5 ROWS
      WHERE kappl EQ 'M'
        AND kschl EQ 'PB00'
        AND lifnr EQ p_lifnr
        AND matnr EQ p_matnr
        AND ekorg EQ p_ekorg
        AND werks EQ p_werks.

    IF sy-subrc NE 0.
      SELECT * INTO TABLE lt_a018
        FROM a018
        UP TO 5 ROWS
        WHERE kappl EQ 'M'
          AND kschl EQ 'PB00'
          AND lifnr EQ p_lifnr
          AND matnr EQ p_matnr
          AND ekorg EQ p_ekorg.
    ENDIF.
  ENDIF.

  p_infnr = ls_eina-infnr.
  IF lt_a017[] IS NOT INITIAL OR lt_a018[] IS NOT INITIAL.
    p_pir_valid = abap_true.
  ENDIF.
ENDFORM.
*--------------------------------------------------------------------*
* FORM log_pir_ariba
*--------------------------------------------------------------------*
*      -->P_INFNR  text
*      -->P_TEXT   text
*--------------------------------------------------------------------*
FORM log_pir_ariba USING p_infnr
                         p_text.

  DATA: ls_zmm_pir_ariba TYPE zmm_pir_ariba,
        lv_netpr         TYPE bkbetr,
        lv_menge         TYPE menge_bi,
        lv_uom_flag      TYPE flag.

  ls_zmm_pir_ariba-infnr = p_infnr.

  IF ls_zmm_pir_ariba-infnr IS NOT INITIAL.
    ls_zmm_pir_ariba-lifnr = gs_item-lifnr.
    ls_zmm_pir_ariba-lifnr_curr = gs_item-lifnr_curr.
    ls_zmm_pir_ariba-datab = p_vdatu.
    ls_zmm_pir_ariba-datbi = p_bdatu.
    ls_zmm_pir_ariba-matnr = gs_item-matnr.
    ls_zmm_pir_ariba-matkl = gs_item-matkl.
    ls_zmm_pir_ariba-mtart = gs_item-mtart.
    ls_zmm_pir_ariba-werks = gs_item-werks.
    PERFORM: f_uom_conversion USING gs_item-meins
                            CHANGING ls_zmm_pir_ariba-meins
                                     lv_uom_flag.

    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        input          = ls_zmm_pir_ariba-meins
      IMPORTING
        output         = ls_zmm_pir_ariba-meins
      EXCEPTIONS
        unit_not_found = 1
        OTHERS         = 2.

    ls_zmm_pir_ariba-waers = gs_item-waers.

    WRITE: gs_item-menge UNIT gs_item-meins TO lv_menge,
           gs_item-netpr CURRENCY gs_item-waers TO lv_netpr.
    CONDENSE: lv_menge, lv_netpr.
    ls_zmm_pir_ariba-menge = lv_menge.
    ls_zmm_pir_ariba-price = lv_netpr.
    ls_zmm_pir_ariba-menge_sap = gs_item-menge.
    ls_zmm_pir_ariba-price_sap = gs_item-netpr.

    WRITE: gs_item-price_ext CURRENCY gs_item-waers TO lv_netpr.
    CONDENSE: lv_netpr.
    ls_zmm_pir_ariba-price_ext = gs_item-price_ext.

    WRITE: gs_item-saving CURRENCY gs_item-waers TO lv_netpr.
    CONDENSE: lv_netpr.
    ls_zmm_pir_ariba-saving = gs_item-saving.

    ls_zmm_pir_ariba-item_cat_ariba = gs_item-item_cat_ariba.
    ls_zmm_pir_ariba-message_log = p_text.

    ls_zmm_pir_ariba-erdat = sy-datum.
    ls_zmm_pir_ariba-erzet = sy-uzeit.
    ls_zmm_pir_ariba-ernam = sy-uname.
    MODIFY zmm_pir_ariba FROM ls_zmm_pir_ariba.
  ENDIF.
ENDFORM.
