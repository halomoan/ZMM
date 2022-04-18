*&---------------------------------------------------------------------*
*&  Include           ZMMINT_ARIBA_F01
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
  DATA: lt_user_dir TYPE TABLE OF user_dir,
        ls_user_dir TYPE user_dir.

  SELECT * INTO TABLE lt_user_dir FROM user_dir.
  READ TABLE lt_user_dir INTO ls_user_dir
                         WITH KEY aliass = 'ZDIR_ARBA_TEMPLATES'.
  IF sy-subrc = 0.
    gv_temp_dir = ls_user_dir-dirname.
  ENDIF.

  GET PARAMETER ID 'ZMM_ARIBA_USER'
    FIELD gv_ariba_sid.
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
  DATA: lt_ekko TYPE ty_t_ekko,
        lt_ekpo TYPE ty_t_ekpo,
        lt_makt TYPE ty_t_makt,
        ls_ekko TYPE ty_ekko,
        ls_ekpo TYPE ty_ekpo,
        ls_makt TYPE ty_makt.

  REFRESH: gt_item,
           lt_ekpo,
           lt_ekko,
           lt_makt.

  SELECT ebeln ebelp txz01 matnr bukrs werks ktmng menge
         meins netpr matkl mtart
    INTO TABLE lt_ekpo
    FROM ekpo
    WHERE ebeln EQ p_ebeln
      AND loekz EQ space.

  IF NOT lt_ekpo[] IS INITIAL.
    SELECT ebeln bstyp aedat ernam lifnr ekorg ekgrp waers
      INTO TABLE lt_ekko
      FROM ekko
      FOR ALL ENTRIES IN lt_ekpo
      WHERE ebeln EQ lt_ekpo-ebeln
        AND bstyp EQ gc_a.

    SELECT matnr maktx
      INTO TABLE lt_makt
      FROM makt
      FOR ALL ENTRIES IN lt_ekpo
      WHERE matnr EQ lt_ekpo-matnr
        AND spras EQ sy-langu.
  ENDIF.

  LOOP AT lt_ekpo INTO ls_ekpo.
    READ TABLE lt_ekko INTO ls_ekko
                       WITH KEY ebeln = ls_ekpo-ebeln.
    IF sy-subrc EQ 0.
      gs_item-lifnr = ls_ekko-lifnr.
      gs_item-ekorg = ls_ekko-ekorg.
      gs_item-ekgrp = ls_ekko-ekgrp.
      gs_item-waers = ls_ekko-waers.

      IF p_ernam IS INITIAL.
        p_ernam = ls_ekko-ernam.
      ENDIF.
      IF p_aedat IS INITIAL.
        p_aedat = ls_ekko-aedat.
      ENDIF.
    ELSE.
      CONTINUE.
    ENDIF.

    READ TABLE lt_makt INTO ls_makt
                       WITH KEY matnr = ls_ekpo-matnr.
    IF sy-subrc EQ 0.
      gs_item-maktx = ls_makt-maktx.
    ELSE.
      gs_item-maktx = ls_ekpo-txz01.
    ENDIF.

    IF p_waers IS INITIAL.
      SELECT SINGLE waers INTO p_waers
        FROM t001
        WHERE bukrs EQ ls_ekpo-bukrs.
    ENDIF.

    gs_item-mark  = abap_true.
    gs_item-ebeln = ls_ekpo-ebeln.
    gs_item-ebelp = ls_ekpo-ebelp.
    gs_item-matnr = ls_ekpo-matnr.
    gs_item-bukrs = ls_ekpo-bukrs.
    gs_item-werks = ls_ekpo-werks.
    gs_item-ktmng = ls_ekpo-ktmng.
    gs_item-menge = ls_ekpo-ktmng.
    gs_item-meins = ls_ekpo-meins.
    gs_item-netpr = ls_ekpo-netpr.
    gs_item-matkl = ls_ekpo-matkl.
    gs_item-mtart = ls_ekpo-mtart.

    APPEND gs_item TO gt_item.
    CLEAR gs_item.
  ENDLOOP.

  IF gt_item[] IS INITIAL AND p_ebeln IS NOT INITIAL.
    MESSAGE s255(oiucm) DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_CREATE_ARIBA_PROJECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_create_ariba_project .
  PERFORM: f_display_progress USING text-i01,
           f_ariba_project_proxy.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATE_INTERVAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_EKKO_KDATB  text
*      -->P_LS_EKKO_KDATE  text
*      <--P_LV_MONTH  text
*----------------------------------------------------------------------*
FORM f_get_date_interval  USING    p_kdatb
                                   p_kdate
                          CHANGING p_months.

  DATA: lv_days   TYPE vtbbewe-atage,
        lv_months TYPE vtbbewe-atage,
        lv_years  TYPE vtbbewe-atage.

  CALL FUNCTION 'FIMA_DAYS_AND_MONTHS_AND_YEARS'
    EXPORTING
      i_date_from    = p_kdatb
      i_date_to      = p_kdate
      i_flg_separate = ' '
    IMPORTING
      e_days         = lv_days
      e_months       = lv_months
      e_years        = lv_years.

  p_months = lv_months.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_CREATE_ARIBA_EVENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_create_ariba_event .
  CHECK NOT gv_workspace_id IS INITIAL.
  IF NOT go_zipper IS BOUND.
    CREATE OBJECT go_zipper.
  ENDIF.

  PERFORM: f_display_progress USING text-i02,
           f_prepare_content,
           f_prepare_participants,
           f_prepare_pricing,
           f_prepare_rules,
           f_prepare_terms,
           f_ariba_event_proxy.

  MESSAGE text-i03 TYPE 'S'.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_CONTENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_prepare_content .
  PERFORM f_file_to_itab USING gc_content.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_PARTICIPANTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_prepare_participants .
  PERFORM f_file_to_itab USING gc_participants.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_PRICING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_prepare_pricing .
  PERFORM: f_modify_pricing_file,
           f_file_to_itab USING gc_pricing.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_RULES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_prepare_rules .
  PERFORM f_file_to_itab USING gc_rules.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_TERMS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_prepare_terms .
  PERFORM f_file_to_itab USING gc_terms.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_ARIBA_EVENT_PROXY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_ariba_event_proxy .
  DATA: lv_event_quote    TYPE REF TO zaico_event_import_port_type,
        lv_event_in       TYPE zaievent_import_request_messa1,
        lv_event_out      TYPE zaievent_import_reply_message1,
        lv_oref           TYPE REF TO cx_root,
        lv_text           TYPE string,
        lv_attachments    TYPE arbfnd_extension_data,
        lv_contents       TYPE arbfnd_attachment_content,
        lt_commodity_item TYPE zairfxdocument_wsproject_i_tab,
        ls_commodity_item TYPE zairfxdocument_wsproject_impor,
        lv_xsdboolean     TYPE xsdboolean.

  CLEAR gv_document_id.
  CALL METHOD go_zipper->save
    RECEIVING
      zip = gv_zip.

  lv_event_in-partition = '?'.
  lv_event_in-variant = '?'.
  lv_event_in-wsrfxdocument_input_bean_item-item-action = 'Create'.
  lv_event_in-wsrfxdocument_input_bean_item-item-attachments = lv_attachments.
  lv_contents = gv_zip.
  lv_event_in-wsrfxdocument_input_bean_item-item-contents = lv_contents.
  lv_event_in-wsrfxdocument_input_bean_item-item-document_name = 'WebServiceEvent'.
  lv_event_in-wsrfxdocument_input_bean_item-item-on_behalf_user_id = gv_ariba_sid.
  lv_event_in-wsrfxdocument_input_bean_item-item-on_behalf_user_password_adapte = 'PasswordAdapter1'.
  lv_event_in-wsrfxdocument_input_bean_item-item-rfxdocument_header_fields-base_language-unique_name = 'EN'.

  ls_commodity_item-domain = 'custom'.
  ls_commodity_item-unique_name = 'All'.
  APPEND ls_commodity_item TO lt_commodity_item.
  lv_event_in-wsrfxdocument_input_bean_item-item-rfxdocument_header_fields-commodity-item = lt_commodity_item.

  lv_event_in-wsrfxdocument_input_bean_item-item-rfxdocument_header_fields-currency-unique_name = p_waers.
  lv_event_in-wsrfxdocument_input_bean_item-item-rfxdocument_header_fields-description-default_string_translation = p_proj_desc.
  lv_event_in-wsrfxdocument_input_bean_item-item-rfxdocument_header_fields-title-default_string_translation = p_rfp.
  lv_event_in-wsrfxdocument_input_bean_item-item-replace_event_content = lv_xsdboolean.
  lv_event_in-wsrfxdocument_input_bean_item-item-workspace_id = gv_workspace_id.

  TRY.
      CREATE OBJECT lv_event_quote
        EXPORTING
          logical_port_name = 'ZARBA_CREATE_EVENT'.

    CATCH cx_ai_system_fault INTO lv_oref.
      lv_text = lv_oref->get_text( ).
      APPEND lv_text TO gt_message.
  ENDTRY.

  TRY.
      CALL METHOD lv_event_quote->event_import_operation
        EXPORTING
          input  = lv_event_in
        IMPORTING
          output = lv_event_out.

    CATCH cx_ai_system_fault INTO lv_oref.
      lv_text = lv_oref->get_text( ).
      IF lv_event_out-wsrfxdocument_output_bean_item-item-document_id IS INITIAL.
        APPEND lv_text TO gt_message.
      ENDIF.
  ENDTRY.

  lv_text = lv_event_out-wsrfxdocument_output_bean_item-item-error_message.
  APPEND lv_text TO gt_message.
  CLEAR lv_text.
  lv_text = lv_event_out-wsrfxdocument_output_bean_item-item-document_id.
  APPEND lv_text TO gt_message.
  CLEAR lv_text.
  gv_document_id = lv_event_out-wsrfxdocument_output_bean_item-item-document_id.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_FILE_TO_ITAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GC_CONTENT  text
*      <--P_GT_CONTENT  text
*----------------------------------------------------------------------*
FORM f_file_to_itab  USING p_filename .
  DATA: lv_xstring  TYPE xstring,
        lv_filename TYPE string.

  gv_file = gv_temp_dir && '\' && p_filename.
  OPEN DATASET gv_file FOR INPUT IN BINARY MODE.
  IF sy-subrc EQ 0.
    DO.
      READ DATASET gv_file INTO lv_xstring.
      IF sy-subrc EQ 0.
        EXIT.
      ENDIF.
    ENDDO.
  ENDIF.
  CLOSE DATASET gv_file.

  lv_filename = p_filename.
  CALL METHOD go_zipper->add
    EXPORTING
      name    = lv_filename
      content = lv_xstring.
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
  IF NOT gt_message[] IS INITIAL.
    LOOP AT gt_message INTO ls_message.
      WRITE / ls_message.
      LEAVE TO LIST-PROCESSING.
    ENDLOOP.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_ARIBA_PROJECT_PROXY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_ariba_project_proxy .
  DATA: lv_proj_quote     TYPE REF TO zaico_sourcing_project_import,
        lv_proj_in        TYPE zaisourcing_project_import_re1,
        lv_proj_out       TYPE zaisourcing_project_import_re2,
        lv_oref           TYPE REF TO cx_root,
        lv_text           TYPE string,
        lt_client_item    TYPE zaisourcing_project_wspro_tab2,
        ls_client_item    TYPE zaisourcing_project_wsproject2,
        lt_commodity_item TYPE zaisourcing_project_wspro_tab1,
        ls_commodity_item TYPE zaisourcing_project_wsproject1,
        ls_ekko           TYPE ekko,
        lv_date_xsd       TYPE xsddatetime_z,
        lv_months         TYPE bearzeit,
        ls_t001           TYPE t001,
        lt_region_item    TYPE zaisourcing_project_wsproj_tab,
        ls_region_item    TYPE zaisourcing_project_wsproject,
        ls_tvarvc         TYPE tvarvc.

  CHECK sy-subrc NE 1.
  lv_proj_in-partition = '?'.
  lv_proj_in-variant = '?'.
  lv_proj_in-wssourcing_project_input_bean-item-action = 'Create'.
  lv_proj_in-wssourcing_project_input_bean-item-on_behalf_user_id = gv_ariba_sid.
  lv_proj_in-wssourcing_project_input_bean-item-on_behalf_user_password_adapte = 'PasswordAdapter1'.
  lv_proj_in-wssourcing_project_input_bean-item-project_header_fields-base_language-unique_name = 'EN'.
  lv_proj_in-wssourcing_project_input_bean-item-project_header_fields-currency-unique_name = p_waers.

  ls_client_item-department_id = '012'.
  APPEND ls_client_item TO lt_client_item.
  lv_proj_in-wssourcing_project_input_bean-item-project_header_fields-client-item = lt_client_item.

  ls_commodity_item-domain = 'custom'.
  ls_commodity_item-unique_name = 'All'.
  APPEND ls_commodity_item TO lt_commodity_item.
  lv_proj_in-wssourcing_project_input_bean-item-project_header_fields-commodity-item = lt_commodity_item.

  READ TABLE gt_item INTO gs_item INDEX 1.
  SELECT SINGLE * INTO ls_ekko
    FROM ekko
    WHERE ebeln EQ gs_item-ebeln.

  lv_date_xsd = ls_ekko-kdatb && sy-uzeit.
  lv_proj_in-wssourcing_project_input_bean-item-project_header_fields-contract_effective_date = lv_date_xsd.

  PERFORM f_get_date_interval USING ls_ekko-kdatb
                                    ls_ekko-kdate
                              CHANGING
                                    lv_months.

  lv_proj_in-wssourcing_project_input_bean-item-project_header_fields-contract_months = lv_months.
  lv_proj_in-wssourcing_project_input_bean-item-project_header_fields-currency-unique_name = p_waers.

  SELECT SINGLE * INTO ls_t001 FROM t001 WHERE bukrs EQ ls_ekko-bukrs.
  lv_proj_in-wssourcing_project_input_bean-item-project_header_fields-description-default_string_translation = p_rfp.
  lv_proj_in-wssourcing_project_input_bean-item-project_header_fields-owner-unique_name = gv_ariba_sid.

  ls_region_item-region = ls_t001-land1.
  APPEND ls_region_item TO lt_region_item.
  lv_proj_in-wssourcing_project_input_bean-item-project_header_fields-region-item = lt_region_item.
  lv_proj_in-wssourcing_project_input_bean-item-project_header_fields-title-default_string_translation = p_proj_desc.

  SELECT SINGLE * INTO ls_tvarvc
    FROM tvarvc
    WHERE name EQ 'ZARIBA_TEMPLATE_ID'.
  lv_proj_in-wssourcing_project_input_bean-item-template_id = ls_tvarvc-low.

  TRY.
      CREATE OBJECT lv_proj_quote
        EXPORTING
          logical_port_name = 'ZARBA_CREATE_PROJECT'.

    CATCH cx_ai_system_fault INTO lv_oref.
      lv_text = lv_oref->get_text( ).
      APPEND lv_text TO gt_message.
  ENDTRY.

  TRY.
      CALL METHOD lv_proj_quote->sourcing_project_import_operat
        EXPORTING
          input  = lv_proj_in
        IMPORTING
          output = lv_proj_out.

    CATCH cx_ai_system_fault INTO lv_oref.
      lv_text = lv_oref->get_text( ).
      APPEND lv_text TO gt_message.
  ENDTRY.

  lv_text = lv_proj_out-wssourcing_project_output_bean-item-error_message.
  APPEND lv_text TO gt_message.
  lv_text = lv_proj_out-wssourcing_project_output_bean-item-url.
  APPEND lv_text TO gt_message.
  lv_text = lv_proj_out-wssourcing_project_output_bean-item-workspace_id.
  APPEND lv_text TO gt_message.
  gv_workspace_id = lv_proj_out-wssourcing_project_output_bean-item-workspace_id.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_PROGRESS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_display_progress USING p_text.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text = p_text.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_INIT_MESSAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_message .
  REFRESH: gt_message.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_PRICING_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_modify_pricing_file .
  TYPES: BEGIN OF ty_historical_price,
           ebeln TYPE ebeln,
           ebelp TYPE ebelp,
           aedat TYPE paedt,
           matnr TYPE matnr,
           werks TYPE ewerk,
           matkl TYPE matkl,
           mtart TYPE mtart,
           meins TYPE bstme,
           netpr TYPE bprei,
           lifnr TYPE elifn,
           bstyp TYPE ebstyp,
           waers TYPE waers,
           name1 TYPE name1_gp,
           peinh type peinh,
         END OF ty_historical_price.

  DATA: lt_string           TYPE TABLE OF string WITH HEADER LINE,
        lt_components       TYPE TABLE OF rstrucinfo,
        ls_components       TYPE rstrucinfo,
        lo_tab_descr        TYPE REF TO cl_abap_tabledescr,
        lo_struc_descr      TYPE REF TO cl_abap_structdescr,
        ls_comp             TYPE abap_compdescr,
        lt_data             TYPE ty_t_excel,
        ls_data             TYPE ty_excel,
        lv_string           TYPE string,
        lv_tabfield(20)     TYPE c,
        lv_tabix(4)         TYPE c,
        lv_lines            TYPE i,
        lv_itemno           TYPE numc5,
        lt_historical_price TYPE TABLE OF ty_historical_price,
        ls_historical_price TYPE ty_historical_price.

  FIELD-SYMBOLS: <fs_tabfield>.

  CHECK NOT sy-subrc EQ 1.
  gv_file = gv_temp_dir && '\' && gc_pricing.
  OPEN DATASET gv_file FOR INPUT IN TEXT MODE ENCODING DEFAULT IGNORING CONVERSION ERRORS.
  IF sy-subrc EQ 0.
    DO.
      READ DATASET gv_file INTO lv_string.
      IF sy-subrc EQ 0.
        SPLIT lv_string AT gc_comma INTO TABLE lt_string.

        lo_tab_descr ?= cl_abap_tabledescr=>describe_by_data( lt_data ).
        CHECK sy-subrc = 0.
        lo_struc_descr ?= lo_tab_descr->get_table_line_type( ).

        LOOP AT lt_string.
          READ TABLE lo_struc_descr->components INTO ls_comp INDEX sy-tabix.
          CONCATENATE 'LS_DATA-' ls_comp-name INTO lv_tabfield.
          CONDENSE lv_tabfield NO-GAPS.
          ASSIGN (lv_tabfield) TO <fs_tabfield>.
          IF sy-subrc NE 0.
            EXIT.
          ENDIF.
          <fs_tabfield> = lt_string.
        ENDLOOP.
        APPEND ls_data TO lt_data.
        CLEAR ls_data.
      ELSE.
        EXIT.
      ENDIF.
    ENDDO.
  ENDIF.
  CLOSE DATASET gv_file.

  DELETE lt_data FROM 9.
  LOOP AT gt_item INTO gs_item WHERE mark EQ abap_true.
    ADD 1 TO lv_itemno.
    WRITE lv_itemno TO ls_data-colb1.
    SHIFT ls_data-colb1 LEFT DELETING LEADING '0'.
    ls_data-colb1 = '4.' && ls_data-colb1.
    CONDENSE ls_data-colb1 NO-GAPS.

    ls_data-colc1  = 'Line Item'.
    ls_data-cold1  = gs_item-maktx.
    REPLACE ALL OCCURRENCES OF gc_comma IN ls_data-cold1 WITH space.

    ls_data-cole1  = gs_item-maktx.
    REPLACE ALL OCCURRENCES OF gc_comma IN ls_data-cole1 WITH space.

    ls_data-colf1  = gs_item-maktx.
    REPLACE ALL OCCURRENCES OF gc_comma IN ls_data-colf1 WITH space.

    ls_data-colg1  = '0'.
    ls_data-colh1  = 'Yes'.
    ls_data-colj1  = gs_item-matkl.
    ls_data-coll1  = 'Yes'.
    ls_data-colm1  = 'No'.

    "* Quantity
    WRITE gs_item-menge UNIT gs_item-meins TO ls_data-cols1 .
    SHIFT ls_data-cols1 LEFT DELETING LEADING space.
    REPLACE ALL OCCURRENCES OF gc_comma IN ls_data-cols1 WITH space.
    CONDENSE ls_data-cols1 NO-GAPS.

    "* UOM.Quantity
    ls_data-colt1  = gs_item-meins.
    ls_data-colu1  = '''Price''''*''''Quantity'''.
    ls_data-colw1  = '0'.
    ls_data-coly1  = 'Savings("''Extended_Price''")'.
    ls_data-colaa1 = 'Not Applicable'.

    SELECT a~ebeln a~ebelp a~aedat a~matnr a~werks
           a~matkl a~mtart a~meins a~netpr
           b~lifnr b~bstyp b~waers
           c~name1 a~peinh
      INTO TABLE lt_historical_price
      FROM ekpo AS a
      INNER JOIN ekko AS b ON a~ebeln EQ b~ebeln
      INNER JOIN lfa1 AS c ON b~lifnr EQ c~lifnr
      UP TO 10 ROWS
      WHERE a~matnr EQ gs_item-matnr
        AND a~loekz EQ space
        AND a~aedat LE sy-datum
        AND a~werks EQ gs_item-werks
        AND b~bstyp EQ 'F'
        AND b~loekz EQ space
        ORDER BY a~aedat DESCENDING
                 a~ebeln DESCENDING.

    IF sy-subrc NE 0.
      SELECT a~ebeln a~ebelp a~aedat a~matnr a~werks
             a~matkl a~mtart a~meins a~netpr
             b~lifnr b~bstyp b~waers
             c~name1 a~peinh
        INTO TABLE lt_historical_price
        FROM ekpo AS a
        INNER JOIN ekko AS b ON a~ebeln EQ b~ebeln
        INNER JOIN lfa1 AS c ON b~lifnr EQ c~lifnr
        UP TO 10 ROWS
        WHERE a~matnr EQ gs_item-matnr
          AND a~loekz EQ space
          AND a~aedat LE sy-datum
          AND b~bstyp EQ 'F'
          AND b~loekz EQ space
          AND b~ekorg EQ gs_item-ekorg
          ORDER BY a~aedat DESCENDING
                   a~ebeln DESCENDING.
    ENDIF.

    READ TABLE lt_historical_price INTO ls_historical_price INDEX 1.
    IF sy-subrc EQ 0.
      "*Existing Supplier Name
      CONCATENATE ls_historical_price-lifnr ls_historical_price-name1
      INTO ls_data-colab1 SEPARATED BY space.
      "Historic.Price
      ls_historical_price-netpr = ls_historical_price-netpr / ls_historical_price-peinh.
      WRITE ls_historical_price-netpr CURRENCY ls_historical_price-waers TO ls_data-colq1.
      SHIFT ls_data-colq1 LEFT DELETING LEADING space.
    REPLACE ALL OCCURRENCES OF gc_comma IN ls_data-colq1 WITH space.
    CONDENSE ls_data-colq1 NO-GAPS.
    ELSE.
      ls_data-colab1 = 'N.A'.
      ls_data-colq1 = '0'.
    ENDIF.

    "Material Group
    ls_data-colaf1 = gs_item-matkl.
    "Material Number
    ls_data-colag1 = gs_item-matnr.
    "Material Type
    ls_data-colah1 = gs_item-mtart.
    "*Order Unit
    PERFORM f_uom_conversion USING gs_item-meins
                             CHANGING ls_data-colai1.
    "Plant
    ls_data-colaj1 = gs_item-werks.
    "Item Category
    IF NOT gs_item-matnr IS INITIAL.
      ls_data-colak1 = 'M Material'.
    ENDIF.

    APPEND ls_data TO lt_data.
    CLEAR ls_data.
  ENDLOOP.

  OPEN DATASET gv_file FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
  LOOP AT lt_data INTO ls_data.
    CONCATENATE ls_data-cola1
                ls_data-colb1
                ls_data-colc1
                ls_data-cold1
                ls_data-cole1
                ls_data-colf1
                ls_data-colg1
                ls_data-colh1
                ls_data-coli1
                ls_data-colj1
                ls_data-colk1
                ls_data-coll1
                ls_data-colm1
                ls_data-coln1
                ls_data-colo1
                ls_data-colp1
                ls_data-colq1
                ls_data-colr1
                ls_data-cols1
                ls_data-colt1
                ls_data-colu1
                ls_data-colv1
                ls_data-colw1
                ls_data-colx1
                ls_data-coly1
                ls_data-colz1
                ls_data-colaa1
                ls_data-colab1
                ls_data-colac1
                ls_data-colad1
                ls_data-colae1
                ls_data-colaf1
                ls_data-colag1
                ls_data-colah1
                ls_data-colai1
                ls_data-colaj1
                ls_data-colak1
                ls_data-colal1
                INTO lv_string SEPARATED BY gc_comma.

    TRANSFER lv_string TO gv_file.
    CLEAR lv_string.
  ENDLOOP.
  CLOSE DATASET gv_file.
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
    WHERE bukrs NE space.
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
    WHERE bukrs NE space.
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
*&      Form  F_UOM_CONVERSION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_ITEM_MEINS  text
*      <--P_LS_DATA_COLT1  text
*----------------------------------------------------------------------*
FORM f_uom_conversion  USING    p_input
                       CHANGING p_output .

  DATA: lv_iso_code TYPE t006-isocode.

  CALL FUNCTION 'UNIT_OF_MEASURE_SAP_TO_ISO'
    EXPORTING
      sap_code    = p_input
    IMPORTING
      iso_code    = lv_iso_code
    EXCEPTIONS
      not_found   = 1
      no_iso_code = 2
      OTHERS      = 3.

  IF lv_iso_code IS INITIAL.
    p_output = p_input.
  ELSE.
    p_output = lv_iso_code.
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

  ls_ariba_log-ztype   = 'IN'.
  ls_ariba_log-zwsid   = gv_workspace_id.
  ls_ariba_log-zadoc   = gv_document_id.
  ls_ariba_log-rfqno   = p_ebeln.
  ls_ariba_log-uname   = sy-uname.
  ls_ariba_log-erdat   = sy-datum.
  ls_ariba_log-uzeit   = sy-uzeit.
  MODIFY zbcgb_ariba_log FROM ls_ariba_log.
ENDFORM.
