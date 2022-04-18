*----------------------------------------------------------------------*
***INCLUDE YMMCGB_0001_OPEN_FILE_DIALOF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  OPEN_FILE_DIALOG
*&---------------------------------------------------------------------*
FORM open_file_dialog .
  DATA:
    it_file_table TYPE STANDARD TABLE OF file_table,
    wa_file_table TYPE file_table,
    l_subrc TYPE sy-subrc.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      multiselection          = space
    CHANGING
      file_table              = it_file_table
      rc                      = l_subrc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.

  IF sy-subrc <> 0 OR l_subrc NE 1.
    IF sy-msgty IS NOT INITIAL.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
    READ TABLE it_file_table INDEX 1 INTO wa_file_table.
    IF sy-subrc = '0'.
      p_fname = wa_file_table-filename.
    ENDIF.
  ENDIF.


ENDFORM.                    " OPEN_FILE_DIALOG
*&---------------------------------------------------------------------*
*&      Form  UPLOAD_DATA
*&---------------------------------------------------------------------*
FORM upload_data .

  TYPE-POOLS: truxs.
  DATA : it_rawdata   TYPE truxs_t_text_data,
         l_fname      TYPE localfile.
  CONSTANTS: c_header VALUE 'X'.
  l_fname = p_fname.
  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
      i_line_header        = c_header
      i_tab_raw_data       = it_rawdata
      i_filename           = l_fname
    TABLES
      i_tab_converted_data = it_upload[]
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  IF it_upload[] IS INITIAL.
    MESSAGE  'File Error: No data was uploaded' TYPE 'E'.
    STOP.
  ENDIF.
ENDFORM.                    " UPLOAD_DATA
*&---------------------------------------------------------------------*
*&      Form  VALIDATE_DATA
*&---------------------------------------------------------------------*
FORM validate_data .
  DATA: BEGIN OF it_lfb1 OCCURS 0,
         lifnr TYPE lifnr,
         altkn TYPE altkn,
        END OF it_lfb1,
        BEGIN OF it_t161 OCCURS 0,
         bsart TYPE bsart,
        END OF it_t161,
        BEGIN OF it_t024e OCCURS 0,
          ekorg TYPE ekorg,
       END OF it_t024e,
         BEGIN OF it_t024 OCCURS 0,
           ekgrp TYPE ekgrp,
           END OF it_t024,
        BEGIN OF it_tcurc OCCURS 0,
          waers TYPE waers,
        END OF it_tcurc,
        BEGIN OF it_mara OCCURS 0,
           matnr TYPE matnr,
           bismt TYPE bismt,
           maktx TYPE maktx,
        END OF it_mara,
        BEGIN OF it_t006 OCCURS 0,
           msehi TYPE msehi,
        END OF it_t006,
        BEGIN OF it_t023 OCCURS 0,
           matkl TYPE matkl,
        END OF it_t023,
        BEGIN OF it_t001w OCCURS 0,
           werks TYPE werks,
        END OF it_t001w,
        l_error_ind,
        l_lineno(10),
        it_upload_tmp LIKE it_upload OCCURS 0 WITH HEADER LINE,
        it_upload_matnr LIKE it_upload OCCURS 0 WITH HEADER LINE,
        l_bedat,
        l_kdatb,
        l_kdate.


  CLEAR: it_t161[], it_t024e[],
         it_t024[], it_tcurc[], it_mara[],
         it_t006[], it_t023[], it_t001w[],
         it_upload_tmp[], it_lfb1[], it_upload_matnr[].

  IF NOT it_upload[] IS INITIAL.
    it_upload_tmp[] = it_upload[].
*_data selection per table
    SORT:  it_upload_tmp BY bednr lifnr bsart ekorg ekgrp waers  matnr
           meins matkl werks.
*_vendor list using old vendor
    SELECT lifnr altkn INTO TABLE it_lfb1
    FROM lfb1
    FOR ALL ENTRIES IN it_upload
    WHERE altkn = it_upload-lifnr.
*_document type
    SELECT bsart INTO TABLE it_t161
     FROM t161
     FOR ALL ENTRIES IN it_upload
     WHERE bsart = it_upload-bsart.
*_purchasing org
    SELECT ekorg INTO TABLE it_t024e
     FROM t024e
     FOR ALL ENTRIES IN it_upload
     WHERE ekorg = it_upload-ekorg.
*_purchasing grp
    SELECT ekgrp INTO TABLE it_t024
    FROM t024
    FOR ALL ENTRIES IN it_upload
    WHERE ekgrp = it_upload-ekgrp.
*_currency
    SELECT waers INTO TABLE it_tcurc
    FROM   tcurc
    FOR ALL ENTRIES IN it_upload
    WHERE waers = it_upload-waers.
*_material
    it_upload_matnr[] = it_upload[].
    SORT it_upload_matnr BY matnr.
    DELETE it_upload_matnr WHERE matnr = space.
    SELECT a~matnr a~bismt b~maktx INTO TABLE it_mara
    FROM mara AS a INNER JOIN makt AS b
    ON a~matnr = b~matnr
    FOR ALL ENTRIES IN it_upload_matnr
    WHERE a~bismt = it_upload_matnr-matnr.
*_material group
    SELECT matkl INTO TABLE it_t023
    FROM t023
    FOR ALL ENTRIES IN it_upload
    WHERE matkl = it_upload-matkl.
*_plant
    SELECT werks INTO TABLE it_t001w
    FROM t001w
    FOR ALL ENTRIES IN it_upload
    WHERE werks = it_upload-werks.

*_B. validate entries per line, check for mandatory
    CLEAR: it_error[], it_process[], l_lineno.
    LOOP AT it_upload.
      CLEAR l_error_ind.
      l_lineno = l_lineno + 1.
*_contract number
      IF it_upload-bednr IS INITIAL.
        it_error-line = l_lineno.
        it_error-bednr = it_upload-bednr.
        it_error-text = text-001 .
        APPEND it_error. CLEAR it_error.
        l_error_ind = c_valuex.
      ENDIF.
*_vendor
      IF it_upload-lifnr IS INITIAL.
        it_error-line = l_lineno.
        it_error-bednr = it_upload-bednr.
        it_error-text = text-002 .
        APPEND it_error. CLEAR it_error.
        l_error_ind = c_valuex.
      ELSE.
        READ TABLE it_lfb1 WITH KEY altkn = it_upload-lifnr.
        IF sy-subrc = 0.
          it_upload-lifnr = it_lfb1-lifnr.
        ELSE.
          it_error-line = l_lineno.
          it_error-bednr = it_upload-bednr.
          it_error-text = text-016 .
          APPEND it_error. CLEAR it_error.
          l_error_ind = c_valuex.
        ENDIF.
      ENDIF.
*_Agreement Type
      IF it_upload-bsart IS INITIAL.
        it_error-line = l_lineno.
        it_error-bednr = it_upload-bednr.
        it_error-text = text-003 .
        APPEND it_error. CLEAR it_error.
        l_error_ind = c_valuex.
      ELSE.
        READ TABLE it_t161 WITH KEY bsart = it_upload-bsart.
        IF sy-subrc <> 0.
          it_error-line = l_lineno.
          it_error-bednr = it_upload-bednr.
          it_error-text = text-017 .
          APPEND it_error. CLEAR it_error.
          l_error_ind = c_valuex.
        ENDIF.
      ENDIF.
*_Agreement Date
      IF it_upload-bedat IS INITIAL.
        it_error-line = l_lineno.
        it_error-bednr = it_upload-bednr.
        it_error-text = text-004 .
        APPEND it_error. CLEAR it_error.
        l_error_ind = c_valuex.
      ENDIF.
*_Purchasing Org
      IF it_upload-ekorg IS INITIAL.
        it_error-line = l_lineno.
        it_error-bednr = it_upload-bednr.
        it_error-text = text-005 .
        APPEND it_error. CLEAR it_error.
        l_error_ind = c_valuex.
      ELSE.
        READ TABLE it_t024e WITH KEY ekorg = it_upload-ekorg.
        IF sy-subrc <> 0.
          it_error-line = l_lineno.
          it_error-bednr = it_upload-bednr.
          it_error-text = text-018 .
          APPEND it_error. CLEAR it_error.
          l_error_ind = c_valuex.
        ENDIF.
      ENDIF.
*_Purch Grp
      IF it_upload-ekgrp IS INITIAL.
        it_error-line = l_lineno.
        it_error-bednr = it_upload-bednr.
        it_error-text = text-006 .
        APPEND it_error. CLEAR it_error.
        l_error_ind = c_valuex.
      ELSE.
        READ TABLE it_t024 WITH KEY ekgrp = it_upload-ekgrp.
        IF sy-subrc <> 0.
          it_error-line = l_lineno.
          it_error-bednr = it_upload-bednr.
          it_error-text = text-019 .
          APPEND it_error. CLEAR it_error.
          l_error_ind = c_valuex.
        ENDIF.
      ENDIF.
*_Exchange Rate
      IF it_upload-wkurs IS INITIAL.
        it_error-line = l_lineno.
        it_error-bednr = it_upload-bednr.
        it_error-text = text-007 .
        APPEND it_error. CLEAR it_error.
        l_error_ind = c_valuex.
      ENDIF.
*_Validity Start
      IF it_upload-kdatb IS INITIAL.
        it_error-line = l_lineno.
        it_error-bednr = it_upload-bednr.
        it_error-text = text-008 .
        APPEND it_error. CLEAR it_error.
        l_error_ind = c_valuex.
      ENDIF.
*_Validity End
      IF it_upload-kdate IS INITIAL.
        it_error-line = l_lineno.
        it_error-bednr = it_upload-bednr.
        it_error-text = text-009 .
        APPEND it_error. CLEAR it_error.
        l_error_ind = c_valuex.
      ENDIF.
*_Currency
      IF it_upload-waers IS INITIAL.
        it_error-line = l_lineno.
        it_error-bednr = it_upload-bednr.
        it_error-text = text-010 .
        APPEND it_error. CLEAR it_error.
        l_error_ind = c_valuex.
      ELSE.
        READ TABLE it_tcurc WITH KEY waers = it_upload-waers.
        IF sy-subrc <> 0.
          it_error-line = l_lineno.
          it_error-bednr = it_upload-bednr.
          it_error-text = text-020 .
          APPEND it_error. CLEAR it_error.
          l_error_ind = c_valuex.
        ENDIF.
      ENDIF.
*_Material No
      IF it_upload-matnr IS INITIAL AND it_upload-txz01 IS INITIAL.
        it_error-line = l_lineno.
        it_error-bednr = it_upload-bednr.
        it_error-text = text-011 .
        APPEND it_error. CLEAR it_error.
        l_error_ind = c_valuex.
      ELSEIF NOT it_upload-matnr IS INITIAL.
        READ TABLE it_mara WITH KEY bismt  = it_upload-matnr.
        IF sy-subrc <> 0.
          it_error-line = l_lineno.
          it_error-bednr = it_upload-bednr.
          it_error-text = text-021 .
          APPEND it_error. CLEAR it_error.
          l_error_ind = c_valuex.
        ELSE.
          it_upload-matnr = it_mara-matnr.
        ENDIF.
      ENDIF.
*_Unit of Measure
      IF it_upload-meins IS INITIAL.
        it_error-line = l_lineno.
        it_error-bednr = it_upload-bednr.
        it_error-text = text-012 .
        APPEND it_error. CLEAR it_error.
        l_error_ind = c_valuex.
*_ convert unit of measure
      ELSE.
        CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
          EXPORTING
            input          = it_upload-meins
            language       = sy-langu
          IMPORTING
            output         = it_upload-meins
          EXCEPTIONS
            unit_not_found = 1
            OTHERS         = 2.
      ENDIF.
*_Unit Price /Activity Charges
      IF it_upload-netpr IS INITIAL.
        it_error-bednr = it_upload-bednr.
        it_error-line = l_lineno.
        it_error-text = text-013 .
        APPEND it_error. CLEAR it_error.
        l_error_ind = c_valuex.
      ENDIF.
*_Price unit
      IF it_upload-peinh IS INITIAL.
        it_error-line = l_lineno.
        it_error-bednr = it_upload-bednr.
        it_error-text = text-014 .
        APPEND it_error. CLEAR it_error.
        l_error_ind = c_valuex.
      ENDIF.
*_Plant
      IF it_upload-werks IS INITIAL.
        it_error-line = l_lineno.
        it_error-bednr = it_upload-bednr.
        it_error-text = text-015 .
        APPEND it_error. CLEAR it_error.
        l_error_ind = c_valuex.
      ELSE.
        READ TABLE it_t001w WITH KEY werks = it_upload-werks.
        IF sy-subrc <> 0.
          it_error-line = l_lineno.
          it_error-bednr = it_upload-bednr.
          it_error-text = text-023 .
          APPEND it_error. CLEAR it_error.
          l_error_ind = c_valuex.
        ENDIF.
      ENDIF.
*_Acct assign category
      IF p_srv = c_valuex.  "default acct assign cat for service
        it_upload-knttp = 'U'.
*      ELSEIF p_nonsv = c_valuex.
*        it_upload-knttp = space.
      ENDIF.
*      ELSE.                 "must provide value if material is empty
      IF ( it_upload-matnr IS INITIAL     AND
           NOT it_upload-txz01 IS INITIAL AND
           it_upload-knttp IS INITIAL ).
        it_error-line = l_lineno.
        it_error-bednr = it_upload-bednr.
        it_error-text = text-027 .
        APPEND it_error. CLEAR it_error.
        l_error_ind = c_valuex.
      ENDIF.

*_ convert dates
      l_bedat = STRLEN( it_upload-bedat ).
      l_kdatb = STRLEN( it_upload-kdatb ).
      l_kdate = STRLEN( it_upload-kdate ).
      IF NOT l_bedat IS INITIAL.
        IF l_bedat = 5.
          CONCATENATE '20' it_upload-bedat+3(2)  it_upload-bedat+1(2)  '0' it_upload-bedat(1)
        INTO  it_upload-bedat.
        ELSEIF l_bedat = 6.
          CONCATENATE '20' it_upload-bedat+4(2)  it_upload-bedat+2(2)  it_upload-bedat(2)
          INTO  it_upload-bedat.
        ELSE.
          it_error-line = l_lineno.
          it_error-bednr = it_upload-bednr.
          it_error-text = text-028 .
          APPEND it_error. CLEAR it_error.
          l_error_ind = c_valuex.
        ENDIF.
      ENDIF.

      IF NOT l_kdatb IS INITIAL.
        IF l_kdatb = 5.
          CONCATENATE '20' it_upload-kdatb+3(2)  it_upload-kdatb+1(2)  '0' it_upload-kdatb(1)
        INTO  it_upload-kdatb .
        ELSEIF l_kdatb = 6.
          CONCATENATE '20' it_upload-kdatb+4(2)  it_upload-kdatb+2(2)  it_upload-kdatb(2)
          INTO  it_upload-kdatb.
        ELSE.
          it_error-line = l_lineno.
          it_error-bednr = it_upload-bednr.
          it_error-text = text-029 .
          APPEND it_error. CLEAR it_error.
          l_error_ind = c_valuex.
        ENDIF.
      ENDIF.

      IF NOT l_kdate IS INITIAL.
        IF l_kdate = 5.
          CONCATENATE '20' it_upload-kdate+3(2)  it_upload-kdate+1(2)  '0' it_upload-kdate(1)
        INTO  it_upload-kdate.
        ELSEIF l_kdate = 6.
          CONCATENATE '20' it_upload-kdate+4(2)  it_upload-kdate+2(2)  it_upload-kdate(2)
          INTO  it_upload-kdate.
        ELSE.
          it_error-line = l_lineno.
          it_error-bednr = it_upload-bednr.
          it_error-text = text-030 .
          APPEND it_error. CLEAR it_error.
          l_error_ind = c_valuex.
        ENDIF.
      ENDIF.

*_append only correct entries for processing
      IF l_error_ind NE c_valuex.
*_ populate incoterm if upload file is empty
        IF it_upload-inco1 = space.
          SELECT SINGLE inco1 INTO it_upload-inco1
            FROM lfm1
            WHERE lifnr = it_upload-lifnr
            AND   ekorg = it_upload-ekorg.
        ENDIF.

        MOVE it_upload TO it_process.
        it_process-line_no = l_lineno.
        APPEND it_process. CLEAR it_process.
      ENDIF.
    ENDLOOP.

  ENDIF.
ENDFORM.                    " VALIDATE_DATA
*&---------------------------------------------------------------------*
*&      Form  CREATE_CONTRACT
*&---------------------------------------------------------------------*
FORM create_contract .

  DATA:  l_bednr    TYPE bednr,
         l_tabix    LIKE sy-tabix.

  IF NOT it_process[] IS INITIAL.
    CLEAR: l_bednr.
*    SORT it_process BY bednr.
    LOOP AT it_process.
      READ TABLE it_error WITH KEY bednr = it_process-bednr.
      IF sy-subrc <> 0.
        IF it_process-bednr <> l_bednr.
          CLEAR: it_header, it_headerx, it_vendor,
                 it_item[], it_itemx[], it_account[].
          PERFORM fill_contract_header.
          PERFORM fill_icontract_items.
        ELSEIF it_process-bednr = l_bednr.
          PERFORM fill_icontract_items.
        ENDIF.
        l_bednr = it_process-bednr.
        l_tabix  = it_process-line_no.
        CLEAR it_return[].
        AT END OF bednr.
          CALL FUNCTION 'BAPI_CONTRACT_CREATE'
            EXPORTING
              header         = it_header
              headerx        = it_headerx
              vendor_address = it_vendor
            TABLES
              return         = it_return
              item           = it_item
              itemx          = it_itemx
              account        = it_account.
          IF NOT it_return[] IS INITIAL.
            READ TABLE it_return WITH KEY type = 'S'.
*_update for successfull message
            IF sy-subrc = 0.
              it_message-line   = l_tabix.
              it_message-bednr  = it_process-bednr.
              it_message-text = it_return-message.
              APPEND it_message. CLEAR it_message.

              CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                EXPORTING
                  wait = c_valuex.

*_update for error message
            ELSE.
              LOOP AT it_return WHERE type = 'E'.
                it_error-line   = l_tabix.
                it_error-bednr  = it_process-bednr.
                it_error-text = it_return-message.
                APPEND it_error. CLEAR it_error.
              ENDLOOP.
            ENDIF.
          ENDIF.
        ENDAT.
      ENDIF.
    ENDLOOP.

  ENDIF.
ENDFORM.                    " CREATE_CONTRACT
*&---------------------------------------------------------------------*
*&      Form  FILL_CONTRACT_HEADER
*&---------------------------------------------------------------------*
FORM fill_contract_header .
*_contract header values
  it_header-doc_type = it_process-bsart.
  it_header-comp_code = it_process-bukrs.
  it_headerx-doc_type = c_valuex.

  it_header-creat_date = sy-datum.
  it_headerx-creat_date = c_valuex.

  it_header-vendor = it_process-lifnr.
  it_headerx-vendor  = c_valuex.

  it_header-pmnttrms = it_process-zterm.
  it_headerx-pmnttrms = c_valuex.

  it_header-purch_org = it_process-ekorg.
  it_headerx-purch_org =  c_valuex.

  it_header-pur_group = it_process-ekgrp.
  it_headerx-pur_group =  c_valuex.

  it_header-currency  = it_process-waers.
  it_headerx-currency  = c_valuex.

  it_header-exch_rate = it_process-wkurs.
  it_headerx-exch_rate = c_valuex.

  it_header-doc_date = it_process-bedat.
  it_headerx-doc_date = c_valuex.

  it_header-vper_start  = it_process-kdatb.
  it_headerx-vper_start  = c_valuex.

  it_header-vper_end  = it_process-kdate.
  it_headerx-vper_end  =  c_valuex.

  it_header-acum_value = it_process-ktwrt.
  it_headerx-acum_value = c_valuex.

  it_header-incoterms1 = it_process-inco1.
  it_headerx-incoterms1 = c_valuex.

*_vendor name
*  it_vendor-name = it_process-name1.
ENDFORM.                    " FILL_CONTRACT_HEADER
*&---------------------------------------------------------------------*
*&      Form  FILL_ICONTRACT_ITEMS
*&---------------------------------------------------------------------*
FORM fill_icontract_items .
*_item values
  it_item-item_no = c_itemno + 10.
  it_itemx-item_no = c_valuex.

  it_item-short_text = it_process-txz01.
  it_itemx-short_text = c_valuex.

  it_item-material = it_process-matnr.
  it_itemx-material = c_valuex.
* Begin of UPG Retrofit Chermaine
  it_item-material_long = it_process-matnr.
  it_itemx-material_long = c_valuex.
* End of UPG Retrofit Chermaine

  it_item-plant = it_process-werks.
  it_itemx-plant = c_valuex.

  it_item-trackingno = it_process-bednr.
  it_itemx-trackingno =  c_valuex.

  it_item-matl_group = it_process-matkl.
  it_itemx-matl_group = c_valuex.

  it_item-po_unit = it_process-meins.
  it_itemx-po_unit = c_valuex.

  it_item-target_qty = it_process-menge.
  it_itemx-target_qty = c_valuex.

  it_item-net_price  = it_process-netpr.
  it_itemx-net_price  = c_valuex.

  it_item-price_unit = it_process-peinh.
  it_itemx-price_unit = c_valuex.

  it_item-acctasscat = it_process-knttp.
  it_itemx-acctasscat  = c_valuex.

  it_account-gr_rcpt = it_process-wempf.

  APPEND: it_item, it_itemx, it_account.
  CLEAR: it_item, it_itemx, it_account.
ENDFORM.                    " FILL_ICONTRACT_ITEMS
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_MESSAGE
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM display_message .

  DATA: l_title(70) TYPE c,
        it_sort TYPE slis_sortinfo_alv,
        it_layout TYPE slis_layout_alv.

*_display for any success/error message
  IF NOT it_error[] IS INITIAL.
    APPEND LINES OF it_error TO it_message[].
  ENDIF.
  IF p_srv = c_valuex.
    l_title = text-025.
  ELSE.
    l_title = text-026.
  ENDIF.

  CLEAR it_fieldcat[].
  PERFORM build_fieldcat.
  it_layout-colwidth_optimize = c_valuex.
  it_layout-zebra = c_valuex.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      i_grid_title       = l_title
      is_layout          = it_layout
      it_fieldcat        = it_fieldcat[]
      i_save             = 'X'
    TABLES
      t_outtab           = it_message
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.

ENDFORM.                    " DISPLAY_MESSAGE
*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCAT
*&---------------------------------------------------------------------*
FORM build_fieldcat .
  REFRESH it_fieldcat.
  def_fieldcat 'LINE'   'File line number'.
  def_fieldcat 'BEDNR'  'Contract Number'.
  def_fieldcat 'TEXT'   'Message details'.
ENDFORM.                    " BUILD_FIELDCAT
