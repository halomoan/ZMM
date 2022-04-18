*&---------------------------------------------------------------------*
*&  Include           ZMMIGB_0008_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  INIT_DATA
*&---------------------------------------------------------------------*
*       Initial data
*----------------------------------------------------------------------*
form init_data .
  g_cmt01 = %_p_btcur1_%_app_%-text.
  g_cmt02 = %_p_btcur2_%_app_%-text.
  g_cmt03 = %_p_btcur3_%_app_%-text.
endform.                    " INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  RETRIEVE_DATA
*&---------------------------------------------------------------------*
*       Retrieve data
*----------------------------------------------------------------------*
form retrieve_data .
  refresh: it_upload[].
  CLEAR: it_upload.
  perform check_authorization.
  IF g_noaccess = 'X'.
    MESSAGE i005(zmm).
    stop.
  ENDIF.
  IF g_noaccess = space.
    IF P_BTCUR1 = 'X' OR
       P_BTCUR2 = 'X'.
      PERFORM GET_DATA.
      PERFORM PREPARE_DATA.
    ENDIF.
    if p_btcur1 = 'X'.
      PERFORM pre_download_onefile.
      PERFORM download_onefile.
    elseif p_btcur2 = 'X'.
      PERFORM pre_download_onefile.
      PERFORM download_splitfile.
   elseif p_btcur3 = 'X'.
      perform upload_file_local.
      perform build_data.
      PERFORM process_data.
      PERFORM display_data.
    endif.
  ENDIF.
endform.                    " RETRIEVE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_PCDIR
*&---------------------------------------------------------------------*
*       Filename
*----------------------------------------------------------------------*
form f_get_pcdir .
  data: fes type ref to cl_gui_frontend_services.
  data : file type string,
         path type string,
         fullpath type string.
  data : f_tab type filetable,
         rcount type i,
         wa_tab type line of filetable.
  clear : rcount,f_tab[],wa_tab.
  create object fes.

  call method fes->file_open_dialog
    exporting
      window_title            = 'Open File'
      default_extension       = '*.XLS'
      initial_directory       = 'C:\.XLS'
      multiselection          = abap_false
    changing
      file_table              = f_tab
      rc                      = rcount
    exceptions
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      others                  = 5.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
               with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.
  loop at f_tab into wa_tab.
    p_file = wa_tab-filename.
    exit.
  endloop.
  call method cl_gui_cfw=>flush.
  clear fes.
endform.                    " F_GET_PCDIR

*&---------------------------------------------------------------------*
*&      Form  UPLOAD_FILE_LOCAL
*&---------------------------------------------------------------------*
*       Upload Quotation
*----------------------------------------------------------------------*
form upload_file_local .
  data : f_name type string,
            f_len type i,
            f_head type xstring.
  data : l_header type char1,
           it_raw type truxs_t_text_data.
  clear: f_name,f_len,f_head.
  f_name = p_file.
  data : file like rlgrap-filename.
  file = p_file.
  l_header = 'X'.
  call function 'TEXT_CONVERT_XLS_TO_SAP' "#EC CI_FLDEXT_OK[2215424] P30K910009
    exporting
      i_line_header        = l_header
      i_tab_raw_data       = it_raw
      i_filename           = file
    tables
      i_tab_converted_data = it_upload[]
    exceptions
      conversion_failed    = 1
      others               = 2.

  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
               with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.
  if it_upload[] is initial.
    message i001(zfi) with 'File Error' 'No data was uploaded'.
    stop.
  endif.
endform.                    " UPLOAD_FILE_LOCAL

*&---------------------------------------------------------------------*
*&      Form  BUILD_DATA
*&---------------------------------------------------------------------*
*       Build data
*----------------------------------------------------------------------*
form build_data .
  refresh: it_konp[], it_a016[], it_data[].
  CLEAR: it_konp, it_a016, it_data.

  IF not it_upload[] is INITIAL.
    LOOP AT IT_UPLOAD INTO WA_UPLOAD.
*+b Andryanto P30K902948
      if wa_upload-disco = space AND
         wa_upload-abdis = space AND
         wa_upload-gross = space.
        DELETE IT_UPLOAD WHERE
          ebeln = WA_UPLOAD-ebeln AND
          ebelp = wa_upload-ebelp AND
          lifnr = wa_upload-lifnr.
        CLEAR: WA_UPLOAD.
        CONTINUE.
      endif.
*+e Andryanto P30K902948
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input         = WA_UPLOAD-LIFNR
        IMPORTING
          OUTPUT        = WA_UPLOAD-LIFNR
                .
      MODIFY IT_UPLOAD FROM WA_UPLOAD.
      CLEAR: WA_UPLOAD.
    ENDLOOP.
    SELECT ekko~ebeln ekpo~ebelp ekko~lifnr lfa1~name1
           ekko~waers ekpo~loekz ekpo~statu ekpo~matnr ekpo~txz01
           ekpo~ktmng ekpo~meins EKKO~KNUMV ekpo~spinf
      INTO CORRESPONDING FIELDS OF TABLE IT_DATA
      FROM EKKO JOIN EKPO
        ON EKKO~EBELN = EKPO~EBELN
           JOIN LFA1
        ON LFA1~LIFNR = EKKO~LIFNR
      FOR ALL ENTRIES IN it_upload
      WHERE EKKO~EBELN = it_upload-EBELN AND
            EKKO~BSTYP = C_A AND
            EKKO~LIFNR = it_upload-lifnr AND
            EKKO~EKORG = P_EKORG AND
            EKKO~SUBMI IN S_SUBMI.

    IF not it_data[] is INITIAL.
      SELECT * from a016
        INTO TABLE it_a016
        FOR ALL ENTRIES IN it_data
      WHERE kappl = 'M' AND
            evrtn = it_data-ebeln AND
            evrtp = it_data-ebelp.
    ENDIF.

    IF NOT IT_A016[] is INITIAL.
      SELECT * FROM konp
        INTO TABLE it_konp
        FOR ALL ENTRIES IN it_a016
      WHERE knumh = it_a016-knumh AND
            kappl = it_a016-kappl.
    ENDIF.
  ENDIF.

  sort: it_data, it_a016, it_konp.
endform.                    " BUILD_DATA

*&---------------------------------------------------------------------*
*&      Form  CHECK_AUTHORIZATION
*&---------------------------------------------------------------------*
*       Check Authorization from Purchasing Organization
*----------------------------------------------------------------------*
form check_authorization .
  CLEAR: g_noaccess.
  authority-check object 'M_ANFR_EKO'
         id 'ACTVT' field '03'
         id 'EKORG' field p_ekorg.
  IF sy-subrc <> 0.
    g_noaccess = 'X'.
  ENDIF.

endform.                    " CHECK_AUTHORIZATION

*&---------------------------------------------------------------------*
*&      Form  CHECK_SCREEN
*&---------------------------------------------------------------------*
*       Check Screen
*----------------------------------------------------------------------*
form CHECK_SCREEN .
  IF p_btcur3 = space.
    IF s_ebeln[] is INITIAL.
      IF s_submi[] is INITIAL.
        MESSAGE i000(zmm) WITH text-i01 space space space.
        stop.
      ENDIF.
    ENDIF.
    IF s_submi[] is INITIAL.
      IF s_ebeln[] is INITIAL.
        MESSAGE i000(zmm) WITH text-i02 space space space.
        stop.
      ENDIF.
    ENDIF.
  ENDIF.
endform.                    " CHECK_SCREEN

*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       Build data
*----------------------------------------------------------------------*
form GET_DATA .
  refresh: it_konp[], it_a016[], it_data[], it_lfa1[].
  CLEAR: it_konp, it_a016, it_data, it_lfa1.

  SELECT ekko~ebeln ekpo~ebelp ekko~lifnr lfa1~name1 lfa1~name2 ekko~waers
         ekpo~loekz ekpo~statu ekpo~matnr ekpo~txz01 ekpo~ktmng
         ekpo~meins EKKO~KNUMV ekpo~spinf
    INTO TABLE IT_DATA
    FROM EKKO JOIN EKPO
      ON EKKO~EBELN = EKPO~EBELN
         JOIN LFA1
      ON LFA1~LIFNR = EKKO~LIFNR
    WHERE EKKO~EBELN IN S_EBELN AND
          EKKO~BSTYP = C_A AND
          EKKO~LIFNR IN S_LIFNR AND
          EKKO~EKORG = P_EKORG AND
          EKKO~SUBMI IN S_SUBMI.

  IF not it_data[] is INITIAL.
    SELECT * from a016
      INTO TABLE it_a016
      FOR ALL ENTRIES IN it_data
    WHERE kappl = 'M' AND
          evrtn = it_data-ebeln AND
          evrtp = it_data-ebelp.

*    SELECT * from lfa1
*      INTO TABLE it_lfa1
*    FOR ALL ENTRIES IN it_data
*    WHERE lifnr = it_data-lifnr.
  ENDIF.

  IF NOT IT_A016[] is INITIAL.
    SELECT * FROM konp
      INTO TABLE it_konp
      FOR ALL ENTRIES IN it_a016
    WHERE knumh = it_a016-knumh AND
          kappl = it_a016-kappl.
  ENDIF.

  sort: it_data, it_a016, it_konp.

endform.                    " GET_DATA

*&---------------------------------------------------------------------*
*&      Form  PREPARE_DATA
*&---------------------------------------------------------------------*
*       Prepare data
*----------------------------------------------------------------------*
form PREPARE_DATA .
  refresh: it_final[], it_upload[].
  CLEAR: it_final, it_upload, wa_upload, wa_data.
  LOOP AT it_data INTO wa_data.
    wa_final-ebeln = wa_data-ebeln.
    wa_final-ebelp = wa_data-ebelp.
    WA_FINAL-LIFNR = WA_DATA-LIFNR.
    CONCATENATE wa_data-name1 wa_data-name2 INTO
      wa_final-name1 SEPARATED BY space.
    WA_FINAL-MATNR = WA_DATA-MATNR.
    WA_FINAL-TXZ01 = WA_DATA-TXZ01.
    WA_FINAL-KTMNG = WA_DATA-KTMNG.
    WA_FINAL-MEINS = WA_DATA-MEINS.
    WA_FINAL-SPINF = WA_DATA-SPINF.
    wa_final-waers = wa_data-waers.
    READ TABLE it_a016 INTO wa_a016
      with key evrtn = wa_data-ebeln
               evrtp = wa_data-ebelp.
    if sy-subrc = 0.
      WA_FINAL-validfrom = wa_a016-datab.
      WA_FINAL-validto = wa_a016-datbi.
      LOOP AT it_konp INTO wa_konp
        WHERE knumh = wa_a016-knumh AND
              kappl = wa_a016-kappl.
        CASE wa_konp-kschl.
          WHEN 'PB00'.
            wa_final-gross = wa_konp-kbetr.
            wa_final-kpein = wa_konp-kpein.
            wa_final-kmein = wa_konp-kmein.
          WHEN 'RA00'.
            wa_final-disco = wa_konp-kbetr / 10.
          WHEN 'RB00'.
            wa_final-abdis = wa_konp-kbetr.
          WHEN OTHERS.
        ENDCASE.
      ENDLOOP.
    ENDIF.
    append wa_final to it_final.
    CLEAR: wa_final.
  ENDLOOP.
endform.                    " PREPARE_DATA

*&---------------------------------------------------------------------*
*&      Form  PRE_DOWNLOAD_ONEFILE
*&---------------------------------------------------------------------*
*       Preparation download one file
*----------------------------------------------------------------------*
form PRE_DOWNLOAD_ONEFILE .
  DATA:
  lv_lines TYPE i,
  lv_name TYPE thead-tdname.
  clear: it_upload.
  refresh: it_upload[].
  LOOP AT it_final INTO wa_final.
    wa_upload-ebeln = wa_final-ebeln.
    wa_upload-ebelp = wa_final-ebelp.
    wa_upload-lifnr = wa_final-lifnr.
    wa_upload-name1 = wa_final-name1.
    wa_upload-matnr = wa_final-matnr.
    wa_upload-txz01 = wa_final-txz01.
    wa_upload-spinf = wa_final-spinf.
* Long text
    refresh: it_lines[].
    CLEAR: it_lines, lv_name, lv_lines.
    CONCATENATE wa_final-ebeln wa_final-ebelp
      INTO lv_name.
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                            = c_id
        language                      = sy-langu
        name                          = lv_name
        object                        = c_object
      tables
        lines                         = it_lines
     EXCEPTIONS
       ID                            = 1
       LANGUAGE                      = 2
       NAME                          = 3
       NOT_FOUND                     = 4
       OBJECT                        = 5
       REFERENCE_CHECK               = 6
       WRONG_ACCESS_TO_ARCHIVE       = 7
       OTHERS                        = 8
              .
    IF sy-subrc = 0.
      LOOP AT it_lines.
        add 1 to lv_lines.
        IF lv_lines > 20.
          exit.
        ENDIF.
        CASE lv_lines.
          WHEN 1.
            wa_upload-text01 = it_lines-tdline.
          WHEN 2.
            wa_upload-text02 = it_lines-tdline.
          WHEN 3.
            wa_upload-text03 = it_lines-tdline.
          WHEN 4.
            wa_upload-text04 = it_lines-tdline.
          WHEN 5.
            wa_upload-text05 = it_lines-tdline.
          WHEN 6.
            wa_upload-text06 = it_lines-tdline.
          WHEN 7.
            wa_upload-text07 = it_lines-tdline.
          WHEN 8.
            wa_upload-text08 = it_lines-tdline.
          WHEN 9.
            wa_upload-text09 = it_lines-tdline.
          WHEN 10.
            wa_upload-text10 = it_lines-tdline.
          WHEN 11.
            wa_upload-text11 = it_lines-tdline.
          WHEN 12.
            wa_upload-text12 = it_lines-tdline.
          WHEN 13.
            wa_upload-text13 = it_lines-tdline.
          WHEN 14.
            wa_upload-text14 = it_lines-tdline.
          WHEN 15.
            wa_upload-text15 = it_lines-tdline.
          WHEN 16.
            wa_upload-text16 = it_lines-tdline.
          WHEN 17.
            wa_upload-text17 = it_lines-tdline.
          WHEN 18.
            wa_upload-text18 = it_lines-tdline.
          WHEN 19.
            wa_upload-text19 = it_lines-tdline.
          WHEN 20.
            wa_upload-text20 = it_lines-tdline.
          WHEN OTHERS.
        ENDCASE.
      ENDLOOP.
    ENDIF.
    WRITE wa_final-meins to wa_upload-meins.
    wa_upload-waers = wa_final-waers.
    IF wa_final-ktmng <> '0'.
*      WRITE: wa_final-ktmng to wa_upload-ktmng UNIT WA_FINAL-MEINS.
      WA_UPLOAD-ktmng = wa_final-ktmng.
    ENDIF.
    IF wa_final-gross <> '0'.
      write: wa_final-gross to wa_upload-gross CURRENCY wa_final-waers.
    ENDIF.
    IF wa_final-abdis <> '0'.
      WRITE: wa_final-abdis To wa_upload-abdis CURRENCY wa_final-waers.
    ENDIF.
    IF wa_final-disco <> '0'.
      WRITE: wa_final-disco To wa_upload-disco.
    ENDIF.
    WA_UPLOAD-KPEIN = wa_final-KPEIN.
    WA_UPLOAD-KMEIN = wa_final-KMEIN.
    IF WA_FINAL-VALIDFROM <> '00000000'.
      WRITE: WA_FINAL-VALIDFROM TO WA_UPLOAD-VALIDFROM.
    ENDIF.
    IF WA_FINAL-VALIDTO <> '00000000'.
      WRITE: WA_FINAL-VALIDTO TO WA_UPLOAD-VALIDTO.
    ENDIF.
    APPEND wa_upload to it_upload.
    CLEAR: wa_upload.
  ENDLOOP.
endform.                    " PRE_DOWNLOAD_ONEFILE

*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_ONEFILE
*&---------------------------------------------------------------------*
*       Download one file
*----------------------------------------------------------------------*
form DOWNLOAD_ONEFILE .
  data:
  lv_title TYPE string,
  lv_folder TYPE string,
  lv_dir TYPE string,
  lv_filetype TYPE string,
  lv_filename type string.

* Generate header
  CLEAR: it_head.
  refresh: it_head[].
  it_head-Filed1 = 'RFQ Number'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'RFQ item'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Vendor number'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Vendor name'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Material Number'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Material Description'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Quantity'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Order Unit'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Gross Price'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = '% Disc'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Absolute Discount'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Currency'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Price Unit'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Price UoM'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Valid from (dd.mm.yyyy)'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Valid to (dd.mm.yyyy)'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Info Update'.
  APPEND it_head.
  CLEAR it_head.
*+b Andryanto P30K903206
  it_head-Filed1 = 'Item Text line 01'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Item Text line 02'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Item Text line 03'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Item Text line 04'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Item Text line 05'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Item Text line 06'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Item Text line 07'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Item Text line 08'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Item Text line 09'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Item Text line 10'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Item Text line 11'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Item Text line 12'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Item Text line 13'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Item Text line 14'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Item Text line 15'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Item Text line 16'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Item Text line 17'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Item Text line 18'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Item Text line 19'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Item Text line 20'.
  APPEND it_head.
  CLEAR it_head.
*+e Andryanto P30K903206

  sort: it_upload.

*  lv_filetype = '.xls'. "I just manipulate the file name using XLS file type.
*  CONCATENATE p_file sy-datum INTO lv_filename SEPARATED BY '_' .
*  CONCATENATE lv_filename lv_filetype INTO lv_filename.
  lv_filename = p_file.

  CALL FUNCTION 'GUI_DOWNLOAD' "#EC CI_FLDEXT_OK[2215424] P30K910009
  EXPORTING
  filename                = lv_filename
  filetype                = 'ASC'
  write_field_separator   = 'X'
  TABLES
  data_tab                = It_upload
  FIELDNAMES              = it_head
  EXCEPTIONS
  file_write_error        = 1
  no_batch                = 2
  gui_refuse_filetransfer = 3
  invalid_type            = 4
  no_authority            = 5
  unknown_error           = 6
  header_not_allowed      = 7
  separator_not_allowed   = 8
  filesize_not_allowed    = 9
  header_too_long         = 10
  dp_error_create         = 11
  dp_error_send           = 12
  dp_error_write          = 13
  unknown_dp_error        = 14
  access_denied           = 15
  dp_out_of_memory        = 16
  disk_full               = 17
  dp_timeout              = 18
  file_not_found          = 19
  dataprovider_exception  = 20
  control_flush_error     = 21
  OTHERS = 22.

  IF sy-subrc <> 0.

  ENDIF.

endform.                    " DOWNLOAD_ONEFILE

*&---------------------------------------------------------------------*
*&      Form  F_BROWSE
*&---------------------------------------------------------------------*
*       Browse for download
*----------------------------------------------------------------------*
*      <-- P_FILE  Filename
*----------------------------------------------------------------------*
form F_BROWSE  changing p_file.
  DATA: lo_gui TYPE REF TO cl_gui_frontend_services,
  lv_title TYPE string,
  lv_folder TYPE string,
  lv_dir TYPE string.

  CREATE OBJECT lo_gui.
  lv_title = 'Define download location'.
  lv_folder = 'C:'.
  CALL METHOD lo_gui->directory_browse
  EXPORTING
  window_title    = lv_title
  initial_folder  = lv_folder
  CHANGING
  selected_folder = lv_dir.
  p_file = lv_dir.
endform.                    " F_BROWSE

*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_SPLITFILE
*&---------------------------------------------------------------------*
*       Split by customer
*----------------------------------------------------------------------*
form DOWNLOAD_SPLITFILE .
  data:
  lv_title TYPE string,
  lv_folder TYPE string,
  lv_dir TYPE string,
  lv_filetype TYPE string,
  lv_filename type string.

  refresh: it_up_split[].
  CLEAR: it_up_split, wa_up_split, wa_upload.
  LOOP AT it_upload INTO wa_upload.
    move-CORRESPONDING wa_upload to wa_up_split.
    APPEND wa_up_split to it_up_split.
    CLEAR: wa_up_split.
  ENDLOOP.
  refresh: it_upload[].
  CLEAR: it_upload, wa_upload, wa_up_split.

* Generate header
  CLEAR: it_head.
  refresh: it_head[].
  it_head-Filed1 = 'RFQ Number'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'RFQ item'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Vendor number'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Vendor name'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Material Number'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Material Description'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Quantity'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Order Unit'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Gross Price'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = '% Disc'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Absolute Discount'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Currency'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Price Unit'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Price UoM'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Valid from (dd.mm.yyyy)'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Valid to (dd.mm.yyyy)'.
  APPEND it_head.
  CLEAR it_head.
  it_head-Filed1 = 'Info Update'.
  APPEND it_head.
  CLEAR it_head.
*+b Andryanto P30K903206
  it_head-filed1 = 'Item Text line 01'.
  append it_head.
  CLEAR it_head.
  it_head-filed1 = 'Item Text line 02'.
  append it_head.
  CLEAR it_head.
  it_head-filed1 = 'Item Text line 03'.
  append it_head.
  CLEAR it_head.
  it_head-filed1 = 'Item Text line 04'.
  append it_head.
  CLEAR it_head.
  it_head-filed1 = 'Item Text line 05'.
  append it_head.
  CLEAR it_head.
  it_head-filed1 = 'Item Text line 06'.
  append it_head.
  CLEAR it_head.
  it_head-filed1 = 'Item Text line 07'.
  append it_head.
  CLEAR it_head.
  it_head-filed1 = 'Item Text line 08'.
  append it_head.
  CLEAR it_head.
  it_head-filed1 = 'Item Text line 09'.
  append it_head.
  CLEAR it_head.
  it_head-filed1 = 'Item Text line 10'.
  append it_head.
  CLEAR it_head.
  it_head-filed1 = 'Item Text line 11'.
  append it_head.
  CLEAR it_head.
  it_head-filed1 = 'Item Text line 12'.
  append it_head.
  CLEAR it_head.
  it_head-filed1 = 'Item Text line 13'.
  append it_head.
  CLEAR it_head.
  it_head-filed1 = 'Item Text line 14'.
  append it_head.
  CLEAR it_head.
  it_head-filed1 = 'Item Text line 15'.
  append it_head.
  CLEAR it_head.
  it_head-filed1 = 'Item Text line 16'.
  append it_head.
  CLEAR it_head.
  it_head-filed1 = 'Item Text line 17'.
  append it_head.
  CLEAR it_head.
  it_head-filed1 = 'Item Text line 18'.
  append it_head.
  CLEAR it_head.
  it_head-filed1 = 'Item Text line 19'.
  append it_head.
  CLEAR it_head.
  it_head-filed1 = 'Item Text line 20'.
  append it_head.
  CLEAR it_head.
*+e Andryanto P30K903206

  SORT: it_up_split.
  LOOP AT it_up_split INTO wa_up_split.
    MOVE-CORRESPONDING wa_up_split to wa_upload.
    APPEND wa_upload to it_upload.
    AT END OF lifnr.
      CLEAR: lv_filename, lv_filetype.
      lv_filetype = '.xls'. "I just manipulate the file name using XLS file type.
      CONCATENATE p_file wa_upload-lifnr sy-datum INTO lv_filename SEPARATED BY '_' .
      CONCATENATE lv_filename lv_filetype INTO lv_filename.

      CALL FUNCTION 'GUI_DOWNLOAD' "#EC CI_FLDEXT_OK[2215424] P30K910009
      EXPORTING
      filename                = lv_filename
      filetype                = 'ASC'
      write_field_separator   = 'X'
      TABLES
      data_tab                = It_upload
      FIELDNAMES              = it_head
      EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      OTHERS = 22.

      IF sy-subrc <> 0.

      ENDIF.
      refresh: it_upload[].
      CLEAR: it_upload, wa_upload.
    ENDAT.
    CLEAR: wa_upload.
  ENDLOOP.
endform.                    " DOWNLOAD_SPLITFILE

*&---------------------------------------------------------------------*
*&      Form  PROCESS_DATA
*&---------------------------------------------------------------------*
*       Process upload
*----------------------------------------------------------------------*
form PROCESS_DATA .
  DATA:
  lv_matchdate, "determine date in the quotation range date
  lv_start TYPE datum,
  lv_end TYPE datum,
  lv_first,
  lv_ebelp(05),
  lv_GROSS(20),
  LV_DISCO(20),
  LV_ABDIS(20),
  lv_kpein(05).

  LOOP AT it_upload INTO wa_upload.
    READ TABLE it_data INTO wa_data
      with key ebeln = wa_upload-ebeln
               ebelp = wa_upload-ebelp
               lifnr = wa_upload-lifnr.
    IF sy-subrc = 0.
      CLEAR: lv_start, lv_end, lv_matchdate,
             v_msg, v_msg_me47.
      REFRESH: BDCDATA[], MESSTAB[], i_return[].
      CLEAR: BDCDATA, MESSTAB, i_return.
      IF wa_upload-validfrom = '00000000' or
         wa_upload-validto = '00000000'.
        CLEAR: wa_result.
        wa_result-ebeln = wa_upload-ebeln.
        wa_result-ebelp = wa_upload-ebelp.
        wa_result-spinf = wa_upload-spinf.
        wa_result-remark = c_date.
        APPEND wa_result to it_result.
        continue.
      ENDIF.
      CONCATENATE wa_upload-validfrom+6(04)
                  wa_upload-validfrom+3(02)
                  wa_upload-validfrom(02)
      INTO lv_start.
      CONCATENATE wa_upload-validto+6(04)
                  wa_upload-validto+3(02)
                  wa_upload-validto(02)
      INTO lv_end.
      LOOP AT it_a016 INTO wa_a016
        WHERE evrtn = wa_data-ebeln AND
              evrtp = wa_data-ebelp.
        IF lv_start >= wa_a016-datab.
          IF wa_a016-datbi <= c_9999.
            IF lv_end <= wa_a016-datbi.
              lv_matchdate = c_x.
              exit.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
      CLEAR: lv_GROSS, LV_DISCO, LV_ABDIS, lv_kpein, lv_ebelp, lv_first.
      lv_ebelp = wa_upload-ebelp.
      lv_GROSS = wa_upload-gross.
      lv_DISCO = wa_upload-DISCO.
      lv_ABDIS = wa_upload-ABDIS.
      lv_kpein = wa_upload-kpein.
      CONDENSE: lv_GROSS, LV_DISCO, LV_ABDIS, lv_kpein, lv_ebelp.

      IF WA_DATA-STATU EQ SPACE.
* Update using ME47
        PERFORM bdc_dynpro      USING 'SAPMM06E' '0305'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '/00'.
        PERFORM bdc_field       USING 'RM06E-ANFNR'
                                      wa_upload-ebeln.
        PERFORM bdc_dynpro      USING 'SAPMM06E' '0323'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '/00'.
        PERFORM bdc_field       USING 'RM06E-EBELP'
                                      wa_upload-ebelp.
        PERFORM bdc_dynpro      USING 'SAPMM06E' '0323'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '/00'.
        PERFORM bdc_field       USING 'RM06E-EBELP'
                                      wa_upload-ebelp.
        PERFORM bdc_dynpro      USING 'SAPMM06E' '0323'.
        PERFORM bdc_field       USING 'BDC_CURSOR'
                                      'EKPO-TXZ01(01)'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '=DETA'.
        PERFORM bdc_field       USING 'RM06E-EBELP'
                                      wa_upload-ebelp.
        PERFORM bdc_dynpro      USING 'SAPMM06E' '0311'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '=KO'.
        PERFORM bdc_field       USING 'EKPO-SPINF'
                                      wa_upload-spinf.
        PERFORM bdc_dynpro      USING 'SAPMV13A' '0201'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '/00'.
        PERFORM bdc_field       USING 'RV13A-DATAB'
                                      wa_upload-validfrom.
        PERFORM bdc_field       USING 'RV13A-DATBI'
                                      wa_upload-validto.
        PERFORM bdc_field       USING 'KONP-KBETR(01)'
                                      lv_gross.
        PERFORM bdc_field       USING 'KONP-KONWA(01)'
                                      wa_upload-waers.
        PERFORM bdc_field       USING 'KONP-KPEIN(01)'
                                      lv_kpein.
        PERFORM bdc_field       USING 'KONP-KMEIN(01)'
                                      wa_upload-kmein.
        IF wa_upload-disco <> space or
           wa_upload-abdis <> space.
          IF wa_upload-disco <> space.
            PERFORM bdc_dynpro      USING 'SAPMV13A' '0201'.
            PERFORM bdc_field       USING 'BDC_OKCODE'
                                          '/00'.
            PERFORM bdc_field       USING 'RV13A-DATAB'
                                          wa_upload-validfrom.
            PERFORM bdc_field       USING 'RV13A-DATBI'
                                          wa_upload-validto.
            PERFORM bdc_field       USING 'KONP-KSCHL(02)'
                                          'RA00'.
            PERFORM bdc_field       USING 'KONP-KBETR(02)'
                                          lv_disco.
            PERFORM bdc_field       USING 'KONP-KONWA(02)'
                                          wa_upload-waers.
            PERFORM bdc_field       USING 'KONP-KPEIN(02)'
                                          lv_kpein.
            PERFORM bdc_field       USING 'KONP-KMEIN(02)'
                                          wa_upload-kmein.
            lv_first = 'X'.
          ENDIF.
          IF wa_upload-abdis <> space.
            IF lv_first = 'X'.
              PERFORM bdc_dynpro      USING 'SAPMV13A' '0201'.
              PERFORM bdc_field       USING 'BDC_CURSOR'
                                            'KONP-KSCHL(02)'.
              PERFORM bdc_field       USING 'BDC_OKCODE'
                                            '=EINF'.
              PERFORM bdc_field       USING 'RV13A-DATAB'
                                            wa_upload-validfrom.
              PERFORM bdc_field       USING 'RV13A-DATBI'
                                            wa_upload-validto.
              PERFORM bdc_field       USING 'RV130-SELKZ(02)'
                                            'X'.
              PERFORM bdc_dynpro      USING 'SAPMV13A' '0201'.
              PERFORM bdc_field       USING 'BDC_CURSOR'
                                            'KONP-KBETR(02)'.
              PERFORM bdc_field       USING 'BDC_OKCODE'
                                            '/00'.
              PERFORM bdc_field       USING 'RV13A-DATAB'
                                            wa_upload-validfrom.
              PERFORM bdc_field       USING 'RV13A-DATBI'
                                            wa_upload-validto.
              PERFORM bdc_field       USING 'RV130-SELKZ(03)'
                                            space.
              PERFORM bdc_field       USING 'KONP-KSCHL(02)'
                                            'RB00'.
              PERFORM bdc_field       USING 'KONP-KBETR(02)'
                                            lv_abdis.
              PERFORM bdc_field       USING 'KONP-KONWA(02)'
                                            wa_upload-waers.
              PERFORM bdc_field       USING 'KONP-KPEIN(02)'
                                            lv_kpein.
              PERFORM bdc_field       USING 'KONP-KMEIN(02)'
                                            wa_upload-kmein.
            ELSE.
              PERFORM bdc_dynpro      USING 'SAPMV13A' '0201'.
              PERFORM bdc_field       USING 'BDC_OKCODE'
                                            '/00'.
              PERFORM bdc_field       USING 'RV13A-DATAB'
                                            wa_upload-validfrom.
              PERFORM bdc_field       USING 'RV13A-DATBI'
                                            wa_upload-validto.
              PERFORM bdc_field       USING 'KONP-KSCHL(02)'
                                            'RB00'.
              PERFORM bdc_field       USING 'KONP-KBETR(02)'
                                            lv_abdis.
              PERFORM bdc_field       USING 'KONP-KONWA(02)'
                                            wa_upload-waers.
              PERFORM bdc_field       USING 'KONP-KPEIN(02)'
                                            lv_kpein.
              PERFORM bdc_field       USING 'KONP-KMEIN(02)'
                                            wa_upload-kmein.
            ENDIF.
          ENDIF.
        ENDIF.
        PERFORM bdc_dynpro      USING 'SAPMV13A' '0201'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '=BACK'.
        PERFORM bdc_dynpro      USING 'SAPMM06E' '0323'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '=BU'.
        PERFORM bdc_transaction_me47 USING 'ME47'.
        LOOP AT i_return WHERE message_v3 EQ messtab-msgv1.
          MODIFY i_return TRANSPORTING message_v4 log_no WHERE message_v3 EQ messtab-msgv1.
        ENDLOOP.
        IF v_msg_ME47 = 'X'.
          CLEAR: wa_result.
          wa_result-ebeln = wa_upload-ebeln.
          wa_result-ebelp = wa_upload-ebelp.
          wa_result-spinf = wa_upload-spinf.
          wa_result-remark = 'RFQ condition maintained & info update changed'.
          APPEND wa_result to it_result.
        elseif v_msg_me47 = space.
          clear: wa_result.
          wa_result-ebeln = wa_upload-ebeln.
          wa_result-ebelp = wa_upload-ebelp.
          wa_result-spinf = wa_upload-spinf.
          wa_result-remark = 'Update RFQ failed'.
          append wa_result to it_result.
        ENDIF.
      ELSEIF WA_DATA-STATU = C_A.
        IF lv_matchdate EQ SPACE.
* New range date
        PERFORM bdc_dynpro      USING 'SAPMM06E' '0305'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '/00'.
        PERFORM bdc_field       USING 'RM06E-ANFNR'
                                      wa_upload-ebeln.
        PERFORM bdc_dynpro      USING 'SAPMM06E' '0323'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '/00'.
        PERFORM bdc_field       USING 'RM06E-EBELP'
                                      wa_upload-ebelp.
        PERFORM bdc_dynpro      USING 'SAPMM06E' '0323'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '/00'.
        PERFORM bdc_field       USING 'RM06E-EBELP'
                                      wa_upload-ebelp.
        PERFORM bdc_dynpro      USING 'SAPMM06E' '0323'.
        PERFORM bdc_field       USING 'BDC_CURSOR'
                                      'EKPO-TXZ01(01)'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '=DETA'.
        PERFORM bdc_field       USING 'RM06E-EBELP'
                                      wa_upload-ebelp.
        PERFORM bdc_dynpro      USING 'SAPMM06E' '0311'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '=KO'.
        PERFORM bdc_field       USING 'EKPO-SPINF'
                                      wa_upload-spinf.
        PERFORM bdc_dynpro      USING 'SAPLV14A' '0102'.
        PERFORM bdc_field       USING 'BDC_CURSOR'
                                      'BLOCK1'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '=NEWD'.
        PERFORM bdc_dynpro      USING 'SAPMV13A' '0201'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '/00'.
        PERFORM bdc_field       USING 'RV13A-DATAB'
                                      wa_upload-validfrom.
        PERFORM bdc_field       USING 'RV13A-DATBI'
                                      wa_upload-validto.
        PERFORM bdc_field       USING 'KONP-KBETR(01)'
                                      lv_gross.
        PERFORM bdc_field       USING 'KONP-KONWA(01)'
                                      wa_upload-waers.
        PERFORM bdc_field       USING 'KONP-KPEIN(01)'
                                      lv_kpein.
        PERFORM bdc_field       USING 'KONP-KMEIN(01)'
                                      wa_upload-kmein.
        IF wa_upload-disco <> space or
           wa_upload-abdis <> space.
          IF wa_upload-disco <> space.
            PERFORM bdc_dynpro      USING 'SAPMV13A' '0201'.
            PERFORM bdc_field       USING 'BDC_OKCODE'
                                          '/00'.
            PERFORM bdc_field       USING 'RV13A-DATAB'
                                          wa_upload-validfrom.
            PERFORM bdc_field       USING 'RV13A-DATBI'
                                          wa_upload-validto.
            PERFORM bdc_field       USING 'KONP-KSCHL(02)'
                                          'RA00'.
            PERFORM bdc_field       USING 'KONP-KBETR(02)'
                                          lv_disco.
            PERFORM bdc_field       USING 'KONP-KONWA(02)'
                                          wa_upload-waers.
            PERFORM bdc_field       USING 'KONP-KPEIN(02)'
                                          lv_kpein.
            PERFORM bdc_field       USING 'KONP-KMEIN(02)'
                                          wa_upload-kmein.
            lv_first = 'X'.
          ENDIF.
          IF wa_upload-abdis <> space.
            IF lv_first = 'X'.
              PERFORM bdc_dynpro      USING 'SAPMV13A' '0201'.
              PERFORM bdc_field       USING 'BDC_CURSOR'
                                            'KONP-KSCHL(02)'.
              PERFORM bdc_field       USING 'BDC_OKCODE'
                                            '=EINF'.
              PERFORM bdc_field       USING 'RV13A-DATAB'
                                            wa_upload-validfrom.
              PERFORM bdc_field       USING 'RV13A-DATBI'
                                            wa_upload-validto.
              PERFORM bdc_field       USING 'RV130-SELKZ(02)'
                                            'X'.
              PERFORM bdc_dynpro      USING 'SAPMV13A' '0201'.
              PERFORM bdc_field       USING 'BDC_CURSOR'
                                            'KONP-KBETR(02)'.
              PERFORM bdc_field       USING 'BDC_OKCODE'
                                            '/00'.
              PERFORM bdc_field       USING 'RV13A-DATAB'
                                            wa_upload-validfrom.
              PERFORM bdc_field       USING 'RV13A-DATBI'
                                            wa_upload-validto.
              PERFORM bdc_field       USING 'RV130-SELKZ(03)'
                                            space.
              PERFORM bdc_field       USING 'KONP-KSCHL(02)'
                                            'RB00'.
              PERFORM bdc_field       USING 'KONP-KBETR(02)'
                                            lv_abdis.
              PERFORM bdc_field       USING 'KONP-KONWA(02)'
                                            wa_upload-waers.
              PERFORM bdc_field       USING 'KONP-KPEIN(02)'
                                            lv_kpein.
              PERFORM bdc_field       USING 'KONP-KMEIN(02)'
                                            wa_upload-kmein.
            ELSE.
              PERFORM bdc_dynpro      USING 'SAPMV13A' '0201'.
              PERFORM bdc_field       USING 'BDC_OKCODE'
                                            '/00'.
              PERFORM bdc_field       USING 'RV13A-DATAB'
                                            wa_upload-validfrom.
              PERFORM bdc_field       USING 'RV13A-DATBI'
                                            wa_upload-validto.
              PERFORM bdc_field       USING 'KONP-KSCHL(02)'
                                            'RB00'.
              PERFORM bdc_field       USING 'KONP-KBETR(02)'
                                            lv_abdis.
              PERFORM bdc_field       USING 'KONP-KONWA(02)'
                                            wa_upload-waers.
              PERFORM bdc_field       USING 'KONP-KPEIN(02)'
                                            lv_kpein.
              PERFORM bdc_field       USING 'KONP-KMEIN(02)'
                                            wa_upload-kmein.
            ENDIF.
          ENDIF.
        ENDIF.
        PERFORM bdc_dynpro      USING 'SAPMV13A' '0201'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '=BACK'.
        PERFORM bdc_dynpro      USING 'SAPMM06E' '0323'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '=BU'.
        PERFORM bdc_transaction_me47 USING 'ME47'.
        LOOP AT i_return WHERE message_v3 EQ messtab-msgv1.
          MODIFY i_return TRANSPORTING message_v4 log_no WHERE message_v3 EQ messtab-msgv1.
        ENDLOOP.
        IF v_msg_ME47 = 'X'.
          CLEAR: wa_result.
          wa_result-ebeln = wa_upload-ebeln.
          wa_result-ebelp = wa_upload-ebelp.
          wa_result-spinf = wa_upload-spinf.
          wa_result-remark = 'RFQ condition maintained & info update changed'.
          APPEND wa_result to it_result.
        elseif v_msg_me47 = space.
          clear: wa_result.
          wa_result-ebeln = wa_upload-ebeln.
          wa_result-ebelp = wa_upload-ebelp.
          wa_result-spinf = wa_upload-spinf.
          wa_result-remark = 'Update RFQ failed'.
          append wa_result to it_result.
        ENDIF.
*          PERFORM bdc_dynpro      USING 'SAPMV13A' '0100'.
*          PERFORM bdc_field       USING 'BDC_OKCODE'
*                                        '/00'.
*          PERFORM bdc_field       USING 'RV130-KAPPL'
*                                        'M'.
*          PERFORM bdc_field       USING 'RV13A-KSCHL'
*                                        'PB00'.
*          PERFORM bdc_field       USING 'RV13A-KOTABNR'
*                                        '016'.
*          PERFORM bdc_dynpro      USING 'RV13A016' '1000'.
*          PERFORM bdc_field       USING 'BDC_CURSOR'
*                                        'F002-LOW'.
*          PERFORM bdc_field       USING 'BDC_OKCODE'
*                                        '=ONLI'.
*          PERFORM bdc_field       USING 'F001'
*                                        wa_upload-ebeln.
*          PERFORM bdc_field       USING 'F002-LOW'
*                                        wa_upload-ebelp.
*          PERFORM bdc_field       USING 'SEL_DATE'
*                                        wa_upload-validfrom.
*          PERFORM bdc_dynpro      USING 'SAPMV13A' '1016'.
*          PERFORM bdc_field       USING 'BDC_CURSOR'
*                                        'RV13A-DATBI(01)'.
*          PERFORM bdc_field       USING 'BDC_OKCODE'
*                                        '/00'.
*          PERFORM bdc_field       USING 'KOMG-EVRTN'
*                                        wa_upload-ebeln.
*          PERFORM bdc_field       USING 'KOMG-EVRTP(01)'
*                                        wa_upload-ebelp.
*          PERFORM bdc_field       USING 'KONP-KBETR(01)'
*                                        lv_gross.
*          PERFORM bdc_field       USING 'KONP-KONWA(01)'
*                                        wa_upload-waers.
*          PERFORM bdc_field       USING 'KONP-KPEIN(01)'
*                                        lv_kpein.
*          PERFORM bdc_field       USING 'KONP-KMEIN(01)'
*                                        wa_upload-kmein.
*          PERFORM bdc_field       USING 'RV13A-DATAB(01)'
*                                        wa_upload-validfrom.
*          PERFORM bdc_field       USING 'RV13A-DATBI(01)'
*                                        wa_upload-validto.
*          PERFORM bdc_dynpro      USING 'SAPMV13A' '1016'.
*          PERFORM bdc_field       USING 'BDC_CURSOR'
*                                        'KOMG-EVRTP(01)'.
*          PERFORM bdc_field       USING 'BDC_OKCODE'
*                                        '=KPOS'.
*          IF wa_upload-abdis <> space or
*             wa_upload-disco <> space.
*            IF wa_upload-abdis <> space.
*              PERFORM bdc_dynpro      USING 'SAPMV13A' '0201'.
*              PERFORM bdc_field       USING 'BDC_CURSOR'
*                                            'KONP-KMEIN(02)'.
*              PERFORM bdc_field       USING 'BDC_OKCODE'
*                                            '/00'.
*              PERFORM bdc_field       USING 'RV13A-DATAB'
*                                            wa_upload-validfrom.
*              PERFORM bdc_field       USING 'RV13A-DATBI'
*                                            wa_upload-validto.
*              PERFORM bdc_field       USING 'KONP-KSCHL(02)'
*                                            'RB00'.
*              PERFORM bdc_field       USING 'KONP-KBETR(02)'
*                                            lv_abdis.
*              PERFORM bdc_field       USING 'KONP-KONWA(02)'
*                                            wa_upload-waers.
*              PERFORM bdc_field       USING 'KONP-KPEIN(02)'
*                                            lv_kpein.
*              PERFORM bdc_field       USING 'KONP-KMEIN(02)'
*                                            wa_upload-kmein.
*              lv_first = 'X'.
*            endif.
*            IF wa_upload-disco <> space.
*              IF lv_first = 'X'.
*                PERFORM bdc_dynpro      USING 'SAPMV13A' '0201'.
*                PERFORM bdc_field       USING 'BDC_CURSOR'
*                                              'KONP-KSCHL(02)'.
*                PERFORM bdc_field       USING 'BDC_OKCODE'
*                                              '=EINF'.
*                PERFORM bdc_field       USING 'RV13A-DATAB'
*                                              wa_upload-validfrom.
*                PERFORM bdc_field       USING 'RV13A-DATBI'
*                                              wa_upload-validto.
*                PERFORM bdc_field       USING 'RV130-SELKZ(02)'
*                                              C_X.
*                PERFORM bdc_dynpro      USING 'SAPMV13A' '0201'.
*                PERFORM bdc_field       USING 'BDC_CURSOR'
*                                              'KONP-KMEIN(02)'.
*                PERFORM bdc_field       USING 'BDC_OKCODE'
*                                              '/00'.
*                PERFORM bdc_field       USING 'RV13A-DATAB'
*                                              wa_upload-validfrom.
*                PERFORM bdc_field       USING 'RV13A-DATBI'
*                                              wa_upload-validto.
*                PERFORM bdc_field       USING 'RV130-SELKZ(03)'
*                                              space.
*                PERFORM bdc_field       USING 'KONP-KSCHL(02)'
*                                              'RA00'.
*                PERFORM bdc_field       USING 'KONP-KBETR(02)'
*                                              lv_disco.
*              else.
*                PERFORM bdc_dynpro      USING 'SAPMV13A' '0201'.
*                PERFORM bdc_field       USING 'BDC_CURSOR'
*                                              'KONP-KMEIN(02)'.
*                PERFORM bdc_field       USING 'BDC_OKCODE'
*                                              '/00'.
*                PERFORM bdc_field       USING 'RV13A-DATAB'
*                                              wa_upload-validfrom.
*                PERFORM bdc_field       USING 'RV13A-DATBI'
*                                              wa_upload-validto.
*                PERFORM bdc_field       USING 'KONP-KSCHL(02)'
*                                              'RA00'.
*                PERFORM bdc_field       USING 'KONP-KBETR(02)'
*                                              lv_disco.
*              endif.
*            ENDIF.
*            PERFORM bdc_dynpro      USING 'SAPMV13A' '0201'.
*            PERFORM bdc_field       USING 'BDC_CURSOR'
*                                          'KONP-KSCHL(02)'.
*            PERFORM bdc_field       USING 'BDC_OKCODE'
*                                          '=SICH'.
*            PERFORM bdc_field       USING 'RV13A-DATAB'
*                                          wa_upload-validfrom.
*            PERFORM bdc_field       USING 'RV13A-DATBI'
*                                          wa_upload-validto.
*          endif.
        ELSEIF LV_MATCHDATE EQ C_X.
* In the range date from Quotation pricing
        PERFORM bdc_dynpro      USING 'SAPMM06E' '0305'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '/00'.
        PERFORM bdc_field       USING 'RM06E-ANFNR'
                                      wa_upload-ebeln.
        PERFORM bdc_dynpro      USING 'SAPMM06E' '0323'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '/00'.
        PERFORM bdc_field       USING 'RM06E-EBELP'
                                      wa_upload-ebelp.
        PERFORM bdc_dynpro      USING 'SAPMM06E' '0323'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '/00'.
        PERFORM bdc_field       USING 'RM06E-EBELP'
                                      wa_upload-ebelp.
        PERFORM bdc_dynpro      USING 'SAPMM06E' '0323'.
        PERFORM bdc_field       USING 'BDC_CURSOR'
                                      'EKPO-TXZ01(01)'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '=DETA'.
        PERFORM bdc_field       USING 'RM06E-EBELP'
                                      wa_upload-ebelp.
        PERFORM bdc_dynpro      USING 'SAPMM06E' '0311'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '=KO'.
        PERFORM bdc_field       USING 'EKPO-SPINF'
                                      wa_upload-spinf.
        PERFORM bdc_dynpro      USING 'SAPLV14A' '0102'.
        PERFORM bdc_field       USING 'BDC_CURSOR'
                                      'BLOCK1'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '=NEWD'.
        PERFORM bdc_dynpro      USING 'SAPMV13A' '0201'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '/00'.
        PERFORM bdc_field       USING 'RV13A-DATAB'
                                      wa_upload-validfrom.
        PERFORM bdc_field       USING 'RV13A-DATBI'
                                      wa_upload-validto.
        PERFORM bdc_field       USING 'KONP-KBETR(01)'
                                      lv_gross.
        PERFORM bdc_field       USING 'KONP-KONWA(01)'
                                      wa_upload-waers.
        PERFORM bdc_field       USING 'KONP-KPEIN(01)'
                                      lv_kpein.
        PERFORM bdc_field       USING 'KONP-KMEIN(01)'
                                      wa_upload-kmein.
        IF wa_upload-disco <> space or
           wa_upload-abdis <> space.
          IF wa_upload-disco <> space.
            PERFORM bdc_dynpro      USING 'SAPMV13A' '0201'.
            PERFORM bdc_field       USING 'BDC_OKCODE'
                                          '/00'.
            PERFORM bdc_field       USING 'RV13A-DATAB'
                                          wa_upload-validfrom.
            PERFORM bdc_field       USING 'RV13A-DATBI'
                                          wa_upload-validto.
            PERFORM bdc_field       USING 'KONP-KSCHL(02)'
                                          'RA00'.
            PERFORM bdc_field       USING 'KONP-KBETR(02)'
                                          lv_disco.
            PERFORM bdc_field       USING 'KONP-KONWA(02)'
                                          wa_upload-waers.
            PERFORM bdc_field       USING 'KONP-KPEIN(02)'
                                          lv_kpein.
            PERFORM bdc_field       USING 'KONP-KMEIN(02)'
                                          wa_upload-kmein.
            lv_first = 'X'.
          ENDIF.
          IF wa_upload-abdis <> space.
            IF lv_first = 'X'.
              PERFORM bdc_dynpro      USING 'SAPMV13A' '0201'.
              PERFORM bdc_field       USING 'BDC_CURSOR'
                                            'KONP-KSCHL(02)'.
              PERFORM bdc_field       USING 'BDC_OKCODE'
                                            '=EINF'.
              PERFORM bdc_field       USING 'RV13A-DATAB'
                                            wa_upload-validfrom.
              PERFORM bdc_field       USING 'RV13A-DATBI'
                                            wa_upload-validto.
              PERFORM bdc_field       USING 'RV130-SELKZ(02)'
                                            'X'.
              PERFORM bdc_dynpro      USING 'SAPMV13A' '0201'.
              PERFORM bdc_field       USING 'BDC_CURSOR'
                                            'KONP-KBETR(02)'.
              PERFORM bdc_field       USING 'BDC_OKCODE'
                                            '/00'.
              PERFORM bdc_field       USING 'RV13A-DATAB'
                                            wa_upload-validfrom.
              PERFORM bdc_field       USING 'RV13A-DATBI'
                                            wa_upload-validto.
              PERFORM bdc_field       USING 'RV130-SELKZ(03)'
                                            space.
              PERFORM bdc_field       USING 'KONP-KSCHL(02)'
                                            'RB00'.
              PERFORM bdc_field       USING 'KONP-KBETR(02)'
                                            lv_abdis.
              PERFORM bdc_field       USING 'KONP-KONWA(02)'
                                            wa_upload-waers.
              PERFORM bdc_field       USING 'KONP-KPEIN(02)'
                                            lv_kpein.
              PERFORM bdc_field       USING 'KONP-KMEIN(02)'
                                            wa_upload-kmein.
            ELSE.
              PERFORM bdc_dynpro      USING 'SAPMV13A' '0201'.
              PERFORM bdc_field       USING 'BDC_OKCODE'
                                            '/00'.
              PERFORM bdc_field       USING 'RV13A-DATAB'
                                            wa_upload-validfrom.
              PERFORM bdc_field       USING 'RV13A-DATBI'
                                            wa_upload-validto.
              PERFORM bdc_field       USING 'KONP-KSCHL(02)'
                                            'RB00'.
              PERFORM bdc_field       USING 'KONP-KBETR(02)'
                                            lv_abdis.
              PERFORM bdc_field       USING 'KONP-KONWA(02)'
                                            wa_upload-waers.
              PERFORM bdc_field       USING 'KONP-KPEIN(02)'
                                            lv_kpein.
              PERFORM bdc_field       USING 'KONP-KMEIN(02)'
                                            wa_upload-kmein.
            ENDIF.
          ENDIF.
        ENDIF.
        PERFORM bdc_dynpro      USING 'SAPMV13A' '0201'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '=BACK'.
        PERFORM bdc_dynpro      USING 'SAPMM06E' '0323'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '=BU'.
        PERFORM bdc_transaction_me47 USING 'ME47'.
        LOOP AT i_return WHERE message_v3 EQ messtab-msgv1.
          MODIFY i_return TRANSPORTING message_v4 log_no WHERE message_v3 EQ messtab-msgv1.
        ENDLOOP.
        IF v_msg_ME47 = 'X'.
          CLEAR: wa_result.
          wa_result-ebeln = wa_upload-ebeln.
          wa_result-ebelp = wa_upload-ebelp.
          wa_result-spinf = wa_upload-spinf.
          wa_result-remark = 'RFQ condition maintained & info update changed'.
          APPEND wa_result to it_result.
        elseif v_msg_me47 = space.
          clear: wa_result.
          wa_result-ebeln = wa_upload-ebeln.
          wa_result-ebelp = wa_upload-ebelp.
          wa_result-spinf = wa_upload-spinf.
          wa_result-remark = 'Update RFQ failed'.
          append wa_result to it_result.
        ENDIF.
*          PERFORM bdc_dynpro      USING 'SAPMV13A' '0100'.
*          PERFORM bdc_field       USING 'BDC_OKCODE'
*                                        '/00'.
*          PERFORM bdc_field       USING 'RV130-KAPPL'
*                                        'M'.
*          PERFORM bdc_field       USING 'RV13A-KSCHL'
*                                        'PB00'.
*          PERFORM bdc_field       USING 'RV13A-KOTABNR'
*                                        '016'.
*          PERFORM bdc_dynpro      USING 'RV13A016' '1000'.
*          PERFORM bdc_field       USING 'BDC_CURSOR'
*                                        'SEL_DATE'.
*          PERFORM bdc_field       USING 'BDC_OKCODE'
*                                        '=ONLI'.
*          PERFORM bdc_field       USING 'F001'
*                                        wa_upload-ebeln.
*          PERFORM bdc_field       USING 'F002-LOW'
*                                        wa_upload-ebelp.
*          PERFORM bdc_field       USING 'SEL_DATE'
*                                        wa_upload-validfrom.
*          PERFORM bdc_dynpro      USING 'SAPMV13A' '1016'.
*          PERFORM bdc_field       USING 'BDC_CURSOR'
*                                        'RV13A-DATBI(01)'.
*          PERFORM bdc_field       USING 'BDC_OKCODE'
*                                        '/00'.
*          PERFORM bdc_field       USING 'KOMG-EVRTP(01)'
*                                        wa_upload-ebelp.
*          PERFORM bdc_field       USING 'KONP-KBETR(01)'
*                                        lv_gross.
*          PERFORM bdc_field       USING 'KONP-KONWA(01)'
*                                        wa_upload-waers.
*          PERFORM bdc_field       USING 'KONP-KPEIN(01)'
*                                        lv_kpein.
*          PERFORM bdc_field       USING 'KONP-KMEIN(01)'
*                                        wa_upload-kmein.
*          PERFORM bdc_field       USING 'RV13A-DATAB(01)'
*                                        wa_upload-validfrom.
*          PERFORM bdc_field       USING 'RV13A-DATBI(01)'
*                                        wa_upload-validto.
*          IF wa_upload-abdis = space AND
*             wa_upload-disco = space.
*            PERFORM bdc_dynpro      USING 'SAPMV13A' '1016'.
*            PERFORM bdc_field       USING 'BDC_CURSOR'
*                                          'KOMG-EVRTP(01)'.
*            PERFORM bdc_field       USING 'BDC_OKCODE'
*                                          '=SICH'.
*          ELSE.
*            PERFORM bdc_dynpro      USING 'SAPMV13A' '1016'.
*            PERFORM bdc_field       USING 'BDC_CURSOR'
*                                          'TEXT_DEFAULT-TEXT(01)'.
*            PERFORM bdc_field       USING 'BDC_OKCODE'
*                                          '=KPOS'.
*            PERFORM bdc_dynpro      USING 'SAPMV13A' '0201'.
*            PERFORM bdc_field       USING 'BDC_CURSOR'
*                                          'RV13A-DATAB'.
*            PERFORM bdc_field       USING 'BDC_OKCODE'
*                                          '=MARL'.
*            PERFORM bdc_field       USING 'RV13A-DATBI'
*                                          wa_upload-validfrom.
*            PERFORM bdc_field       USING 'RV13A-DATBI'
*                                          wa_upload-validto.
*            PERFORM bdc_dynpro      USING 'SAPMV13A' '0201'.
*            PERFORM bdc_field       USING 'BDC_CURSOR'
*                                          'RV13A-DATAB'.
*            PERFORM bdc_field       USING 'BDC_OKCODE'
*                                          '=DLIN'.
*            PERFORM bdc_field       USING 'RV13A-DATAB'
*                                          wa_upload-validfrom.
*            PERFORM bdc_field       USING 'RV13A-DATBI'
*                                          wa_upload-validto.
*            IF wa_upload-abdis <> space or
*               wa_upload-disco <> space.
*              IF wa_upload-abdis <> space.
*                PERFORM bdc_dynpro      USING 'SAPMV13A' '0201'.
*                PERFORM bdc_field       USING 'BDC_CURSOR'
*                                              'KONP-KBETR(02)'.
*                PERFORM bdc_field       USING 'BDC_OKCODE'
*                                              '/00'.
*                PERFORM bdc_field       USING 'RV13A-DATAB'
*                                              wa_upload-validfrom.
*                PERFORM bdc_field       USING 'RV13A-DATBI'
*                                              wa_upload-validto.
*                PERFORM bdc_field       USING 'KONP-KSCHL(02)'
*                                              'RB00'.
*                PERFORM bdc_field       USING 'KONP-KBETR(02)'
*                                              lv_abdis.
*                lv_first = 'X'.
*              endif.
*              IF wa_upload-disco <> space.
*                IF lv_first = 'X'.
*                  PERFORM bdc_dynpro      USING 'SAPMV13A' '0201'.
*                  PERFORM bdc_field       USING 'BDC_CURSOR'
*                                                'KONP-KSCHL(02)'.
*                  PERFORM bdc_field       USING 'BDC_OKCODE'
*                                                '=EINF'.
*                  PERFORM bdc_field       USING 'RV13A-DATAB'
*                                                wa_upload-validfrom.
*                  PERFORM bdc_field       USING 'RV13A-DATBI'
*                                                wa_upload-validto.
*                  PERFORM bdc_field       USING 'RV130-SELKZ(02)'
*                                                C_X.
*                  PERFORM bdc_dynpro      USING 'SAPMV13A' '0201'.
*                  PERFORM bdc_field       USING 'BDC_CURSOR'
*                                                'KONP-KMEIN(02)'.
*                  PERFORM bdc_field       USING 'BDC_OKCODE'
*                                                '/00'.
*                  PERFORM bdc_field       USING 'RV13A-DATAB'
*                                                wa_upload-validfrom.
*                  PERFORM bdc_field       USING 'RV13A-DATBI'
*                                                wa_upload-validto.
*                  PERFORM bdc_field       USING 'RV130-SELKZ(03)'
*                                                space.
*                  PERFORM bdc_field       USING 'KONP-KSCHL(02)'
*                                                'RA00'.
*                  PERFORM bdc_field       USING 'KONP-KBETR(02)'
*                                                lv_disco.
*                else.
*                  PERFORM bdc_dynpro      USING 'SAPMV13A' '0201'.
*                  PERFORM bdc_field       USING 'BDC_CURSOR'
*                                                'KONP-KMEIN(02)'.
*                  PERFORM bdc_field       USING 'BDC_OKCODE'
*                                                '/00'.
*                  PERFORM bdc_field       USING 'RV13A-DATAB'
*                                                wa_upload-validfrom.
*                  PERFORM bdc_field       USING 'RV13A-DATBI'
*                                                wa_upload-validto.
*                  PERFORM bdc_field       USING 'KONP-KSCHL(02)'
*                                                'RA00'.
*                  PERFORM bdc_field       USING 'KONP-KBETR(02)'
*                                                lv_disco.
*                endif.
*              ENDIF.
*              PERFORM bdc_dynpro      USING 'SAPMV13A' '0201'.
*              PERFORM bdc_field       USING 'BDC_CURSOR'
*                                            'KONP-KSCHL(02)'.
*              PERFORM bdc_field       USING 'BDC_OKCODE'
*                                            '=SICH'.
*              PERFORM bdc_field       USING 'RV13A-DATAB'
*                                            wa_upload-validfrom.
*              PERFORM bdc_field       USING 'RV13A-DATBI'
*                                            wa_upload-validto.
*            endif.
*          ENDIF.
        ENDIF.
*        PERFORM bdc_transaction USING 'XK14'.
*        LOOP AT i_return WHERE message_v3 EQ messtab-msgv1.
*          MODIFY i_return TRANSPORTING message_v4 log_no WHERE message_v3 EQ messtab-msgv1.
*        ENDLOOP.
*        IF v_msg = 'X'.
*          CLEAR: wa_result.
*          wa_result-ebeln = wa_upload-ebeln.
*          wa_result-ebelp = wa_upload-ebelp.
*          wa_result-spinf = wa_upload-spinf.
*          wa_result-remark = 'Condition records saved'.
*          APPEND wa_result to it_result.
*        ELSEIF v_msg = SPACE.
*          CLEAR: wa_result.
*          wa_result-ebeln = wa_upload-ebeln.
*          wa_result-ebelp = wa_upload-ebelp.
*          wa_result-spinf = wa_upload-spinf.
*          wa_result-remark = 'Condition records failed'.
*          APPEND wa_result to it_result.
*        ENDIF.
*   Update EKPO-SPINF
*   Using ME47
*        PERFORM bdc_dynpro      USING 'SAPMM06E' '0305'.
*        PERFORM bdc_field       USING 'BDC_OKCODE'
*                                      '/00'.
*        PERFORM bdc_field       USING 'RM06E-ANFNR'
*                                      wa_upload-ebeln.
*
*        PERFORM bdc_dynpro      USING 'SAPMM06E' '0323'.
*        PERFORM bdc_field       USING 'BDC_OKCODE'
*                                      '/00'.
*        PERFORM bdc_field       USING 'RM06E-EBELP'
*                                      wa_upload-ebelp.
*
*        PERFORM bdc_dynpro      USING 'SAPMM06E' '0323'.
*        PERFORM bdc_field       USING 'BDC_CURSOR'
*                                      'EKPO-TXZ01(01)'.
*        PERFORM bdc_field       USING 'BDC_OKCODE'
*                                      '=DETA'.
*        PERFORM bdc_field       USING 'RM06E-EBELP'
*                                      wa_upload-ebelp.
*
*        PERFORM bdc_dynpro      USING 'SAPMM06E' '0311'.
*        PERFORM bdc_field       USING 'BDC_OKCODE'
*                                      '=BU'.
*        PERFORM bdc_field       USING 'EKPO-SPINF'
*                                      wa_upload-spinf.
*
*        PERFORM bdc_transaction_me47 USING 'ME47'.
*        LOOP AT i_return WHERE message_v3 EQ messtab-msgv1.
*          MODIFY i_return TRANSPORTING message_v4 log_no WHERE message_v3 EQ messtab-msgv1.
*        ENDLOOP.
*        IF v_msg_ME47 = 'X'.
*          CLEAR: wa_result.
*          wa_result-ebeln = wa_upload-ebeln.
*          wa_result-ebelp = wa_upload-ebelp.
*          wa_result-spinf = wa_upload-spinf.
*          wa_result-remark = 'Info Update changed'.
*          APPEND wa_result to it_result.
*        ELSEIF v_msg_ME47 = SPACE.
*          CLEAR: wa_result.
*          wa_result-ebeln = wa_upload-ebeln.
*          wa_result-ebelp = wa_upload-ebelp.
*          wa_result-spinf = wa_upload-spinf.
*          wa_result-remark = 'Info Update no data changed'.
*          APPEND wa_result to it_result.
*        ENDIF.
      ENDIF.
*      IF wa_data-STATU = 'A'.
** Update using ME47
*        CLEAR: lv_GROSS, LV_DISCO, LV_ABDIS, lv_kpein, lv_ebelp, lv_first.
*        lv_ebelp = wa_upload-ebelp.
*        lv_GROSS = wa_upload-gross.
*        lv_DISCO = wa_upload-DISCO.
*        lv_ABDIS = wa_upload-ABDIS.
*        lv_kpein = wa_upload-kpein.
*        CONDENSE: lv_GROSS, LV_DISCO, LV_ABDIS, lv_kpein, lv_ebelp.
*
*        PERFORM bdc_dynpro      USING 'SAPMM06E' '0305'.
*        PERFORM bdc_field       USING 'BDC_OKCODE'
*                                      '/00'.
*        PERFORM bdc_field       USING 'RM06E-ANFNR'
*                                      wa_upload-ebeln.
*
*        PERFORM bdc_dynpro      USING 'SAPMM06E' '0323'.
*        PERFORM bdc_field       USING 'BDC_OKCODE'
*                                      '/00'.
*        PERFORM bdc_field       USING 'RM06E-EBELP'
*                                      wa_upload-ebelp.
*
*        PERFORM bdc_dynpro      USING 'SAPMM06E' '0323'.
*        PERFORM bdc_field       USING 'BDC_OKCODE'
*                                      '/00'.
*        PERFORM bdc_field       USING 'RM06E-EBELP'
*                                      wa_upload-ebelp.
*
*        PERFORM bdc_dynpro      USING 'SAPMM06E' '0323'.
*        PERFORM bdc_field       USING 'BDC_CURSOR'
*                                      'EKPO-TXZ01(01)'.
*        PERFORM bdc_field       USING 'BDC_OKCODE'
*                                      '=DETA'.
*        PERFORM bdc_field       USING 'RM06E-EBELP'
*                                      wa_upload-ebelp.
*
*        PERFORM bdc_dynpro      USING 'SAPMM06E' '0311'.
*        PERFORM bdc_field       USING 'BDC_OKCODE'
*                                      '=KO'.
*        PERFORM bdc_field       USING 'EKPO-SPINF'
*                                      wa_upload-spinf.
*
*        PERFORM bdc_dynpro      USING 'SAPMV13A' '0201'.
*        PERFORM bdc_field       USING 'BDC_OKCODE'
*                                      '/00'.
*        PERFORM bdc_field       USING 'RV13A-DATAB'
*                                      wa_upload-validfrom.
*        PERFORM bdc_field       USING 'RV13A-DATBI'
*                                      wa_upload-validto.
*        PERFORM bdc_field       USING 'KONP-KBETR(01)'
*                                      lv_gross.
*        PERFORM bdc_field       USING 'KONP-KONWA(01)'
*                                      wa_upload-waers.
*        PERFORM bdc_field       USING 'KONP-KPEIN(01)'
*                                      lv_kpein.
*        PERFORM bdc_field       USING 'KONP-KMEIN(01)'
*                                      wa_upload-kmein.
*
*        IF wa_upload-disco <> space or
*           wa_upload-abdis <> space.
*          IF wa_upload-disco <> space.
*            PERFORM bdc_dynpro      USING 'SAPMV13A' '0201'.
*            PERFORM bdc_field       USING 'BDC_OKCODE'
*                                          '/00'.
*            PERFORM bdc_field       USING 'RV13A-DATAB'
*                                          wa_upload-validfrom.
*            PERFORM bdc_field       USING 'RV13A-DATBI'
*                                          wa_upload-validto.
*            PERFORM bdc_field       USING 'KONP-KSCHL(02)'
*                                          'RA00'.
*            PERFORM bdc_field       USING 'KONP-KBETR(02)'
*                                          lv_disco.
*            PERFORM bdc_field       USING 'KONP-KONWA(02)'
*                                          wa_upload-waers.
*            PERFORM bdc_field       USING 'KONP-KPEIN(02)'
*                                          lv_kpein.
*            PERFORM bdc_field       USING 'KONP-KMEIN(02)'
*                                          wa_upload-kmein.
*            lv_first = 'X'.
*          ENDIF.
*          IF wa_upload-abdis <> space.
*            IF lv_first = 'X'.
*              PERFORM bdc_dynpro      USING 'SAPMV13A' '0201'.
*              PERFORM bdc_field       USING 'BDC_CURSOR'
*                                            'KONP-KSCHL(02)'.
*              PERFORM bdc_field       USING 'BDC_OKCODE'
*                                            '=EINF'.
*              PERFORM bdc_field       USING 'RV13A-DATAB'
*                                            wa_upload-validfrom.
*              PERFORM bdc_field       USING 'RV13A-DATBI'
*                                            wa_upload-validto.
*              PERFORM bdc_field       USING 'RV130-SELKZ(02)'
*                                            'X'.
*              PERFORM bdc_dynpro      USING 'SAPMV13A' '0201'.
*              PERFORM bdc_field       USING 'BDC_CURSOR'
*                                            'KONP-KBETR(02)'.
*              PERFORM bdc_field       USING 'BDC_OKCODE'
*                                            '/00'.
*              PERFORM bdc_field       USING 'RV13A-DATAB'
*                                            wa_upload-validfrom.
*              PERFORM bdc_field       USING 'RV13A-DATBI'
*                                            wa_upload-validto.
*              PERFORM bdc_field       USING 'RV130-SELKZ(03)'
*                                            space.
*              PERFORM bdc_field       USING 'KONP-KSCHL(02)'
*                                            'RB00'.
*              PERFORM bdc_field       USING 'KONP-KBETR(02)'
*                                            lv_abdis.
*              PERFORM bdc_field       USING 'KONP-KONWA(02)'
*                                            wa_upload-waers.
*              PERFORM bdc_field       USING 'KONP-KPEIN(02)'
*                                            lv_kpein.
*              PERFORM bdc_field       USING 'KONP-KMEIN(02)'
*                                            wa_upload-kmein.
*            ELSE.
*              PERFORM bdc_dynpro      USING 'SAPMV13A' '0201'.
*              PERFORM bdc_field       USING 'BDC_OKCODE'
*                                            '/00'.
*              PERFORM bdc_field       USING 'RV13A-DATAB'
*                                            wa_upload-validfrom.
*              PERFORM bdc_field       USING 'RV13A-DATBI'
*                                            wa_upload-validto.
*              PERFORM bdc_field       USING 'KONP-KSCHL(02)'
*                                            'RB00'.
*              PERFORM bdc_field       USING 'KONP-KBETR(02)'
*                                            lv_abdis.
*              PERFORM bdc_field       USING 'KONP-KONWA(02)'
*                                            wa_upload-waers.
*              PERFORM bdc_field       USING 'KONP-KPEIN(02)'
*                                            lv_kpein.
*              PERFORM bdc_field       USING 'KONP-KMEIN(02)'
*                                            wa_upload-kmein.
*            ENDIF.
*          ENDIF.
*
*
*        ENDIF.
*
*        PERFORM bdc_dynpro      USING 'SAPMV13A' '0201'.
*        PERFORM bdc_field       USING 'BDC_OKCODE'
*                                      '=BACK'.
*        PERFORM bdc_dynpro      USING 'SAPMM06E' '0323'.
*        PERFORM bdc_field       USING 'BDC_OKCODE'
*                                      '=BU'.
*
*        BREAK ANDRYANTO.
*        PERFORM bdc_transaction_me47 USING 'ME47'.
*        LOOP AT i_return WHERE message_v3 EQ messtab-msgv1.
*          MODIFY i_return TRANSPORTING message_v4 log_no WHERE message_v3 EQ messtab-msgv1.
*        ENDLOOP.

** Update using XK14
*        IF wa_upload-gross <> space.
*          CLEAR: lv_gross, lv_disco, lv_abdis, lv_kpein, lv_ebelp.
*          lv_ebelp = wa_upload-ebelp.
*          lv_gross = wa_upload-gross.
*          lv_disco = wa_upload-disco.
*          lv_abdis = wa_upload-abdis.
*          lv_kpein = wa_upload-kpein.
*          CONDENSE: lv_gross, lv_disco, lv_abdis, lv_kpein, lv_ebelp.
*
*          PERFORM bdc_dynpro      USING 'SAPMV13A' '0100'.
*          PERFORM bdc_field       USING 'BDC_OKCODE'
*                                        '/00'.
*          PERFORM bdc_field       USING 'RV130-KAPPL'
*                                        'M'.
*          PERFORM bdc_field       USING 'RV13A-KSCHL'
*                                        'PB00'.
*          PERFORM bdc_field       USING 'RV13A-KOTABNR'
*                                        '016'.
*
*          PERFORM bdc_dynpro      USING 'RV13A016' '1000'.
*          PERFORM bdc_field       USING 'BDC_CURSOR'
*                                        'SEL_DATE'.
*          PERFORM bdc_field       USING 'BDC_OKCODE'
*                                        '=ONLI'.
*          PERFORM bdc_field       USING 'F001'
*                                        wa_upload-ebeln.
*          PERFORM bdc_field       USING 'F002-LOW'
*                                        wa_upload-ebelp.
*          PERFORM bdc_field       USING 'SEL_DATE'
*                                        wa_upload-validfrom.
*
*          PERFORM bdc_dynpro      USING 'SAPMV13A' '1016'.
*          PERFORM bdc_field       USING 'BDC_CURSOR'
*                                        'RV13A-DATBI(01)'.
*          PERFORM bdc_field       USING 'BDC_OKCODE'
*                                        '/00'.
*          PERFORM bdc_field       USING 'KONP-KBETR(01)'
*                                        lv_gross.
*          PERFORM bdc_field       USING 'KONP-KONWA(01)'
*                                        wa_upload-waers.
*          PERFORM bdc_field       USING 'KONP-KPEIN(01)'
*                                        lv_kpein.
*          PERFORM bdc_field       USING 'KONP-KMEIN(01)'
*                                        wa_upload-kmein.
*          PERFORM bdc_field       USING 'RV13A-DATBI(01)'
*                                        wa_upload-validto.
*
*          PERFORM bdc_dynpro      USING 'SAPMV13A' '1016'.
*          PERFORM bdc_field       USING 'BDC_CURSOR'
*                                        'KOMG-EVRTP(01)'.
*          PERFORM bdc_field       USING 'BDC_OKCODE'
*                                        '=SICH'.
*
*          BREAK ANDRYANTO.
*          PERFORM bdc_transaction USING 'XK14'.
*          LOOP AT i_return WHERE message_v3 EQ messtab-msgv1.
*            MODIFY i_return TRANSPORTING message_v4 log_no WHERE message_v3 EQ messtab-msgv1.
*          ENDLOOP.
*        ENDIF.
*
*        IF wa_upload-disco <> space.
*          CLEAR: lv_disco, lv_kpein.
*          lv_disco = wa_upload-disco.
*          lv_kpein = wa_upload-kpein.
*          CONDENSE: lv_disco, lv_kpein.
*
*          PERFORM bdc_dynpro      USING 'SAPMV13A' '0100'.
*          PERFORM bdc_field       USING 'BDC_OKCODE'
*                                        '/00'.
*          PERFORM bdc_field       USING 'RV130-KAPPL'
*                                        'M'.
*          PERFORM bdc_field       USING 'RV13A-KSCHL'
*                                        'RA00'.
*          PERFORM bdc_field       USING 'RV13A-KOTABNR'
*                                        '019'.
*
*          PERFORM bdc_dynpro      USING 'RV13A016' '1000'.
*          PERFORM bdc_field       USING 'BDC_OKCODE'
*                                        '=ONLI'.
*          PERFORM bdc_field       USING 'F001'
*                                        wa_upload-ebeln.
*          PERFORM bdc_field       USING 'F002-LOW'
*                                        wa_upload-ebelp.
*          PERFORM bdc_field       USING 'SEL_DATE'
*                                        wa_upload-validfrom.
*
*          PERFORM bdc_dynpro      USING 'SAPMV13A' '1016'.
*          PERFORM bdc_field       USING 'BDC_CURSOR'
*                                        'RV13A-DATBI(01)'.
*          PERFORM bdc_field       USING 'BDC_OKCODE'
*                                        '/00'.
*          PERFORM bdc_field       USING 'KONP-KBETR(01)'
*                                        lv_disco.
*          PERFORM bdc_field       USING 'KONP-KONWA(01)'
*                                        wa_upload-waers.
*          PERFORM bdc_field       USING 'KONP-KPEIN(01)'
*                                        lv_kpein.
*          PERFORM bdc_field       USING 'KONP-KMEIN(01)'
*                                        wa_upload-kmein.
*          PERFORM bdc_field       USING 'RV13A-DATBI(01)'
*                                        wa_upload-validto.
*
*          PERFORM bdc_dynpro      USING 'SAPMV13A' '1016'.
*          PERFORM bdc_field       USING 'BDC_CURSOR'
*                                        'KOMG-EVRTP(01)'.
*          PERFORM bdc_field       USING 'BDC_OKCODE'
*                                        '=SICH'.
*
*          BREAK ANDRYANTO.
*          PERFORM bdc_transaction USING 'XK14'.
*          LOOP AT i_return WHERE message_v3 EQ messtab-msgv1.
*            MODIFY i_return TRANSPORTING message_v4 log_no WHERE message_v3 EQ messtab-msgv1.
*          ENDLOOP.
*        ENDIF.
*
*        IF wa_upload-abdis <> space.
*          CLEAR: lv_abdis, lv_kpein.
*          lv_abdis = wa_upload-abdis.
*          lv_kpein = wa_upload-kpein.
*          CONDENSE: lv_abdis, lv_kpein.
*
*          PERFORM bdc_dynpro      USING 'SAPMV13A' '0100'.
*          PERFORM bdc_field       USING 'BDC_OKCODE'
*                                        '/00'.
*          PERFORM bdc_field       USING 'RV130-KAPPL'
*                                        'M'.
*          PERFORM bdc_field       USING 'RV13A-KSCHL'
*                                        'RB00'.
*          PERFORM bdc_field       USING 'RV13A-KOTABNR'
*                                        '016'.
*
*          PERFORM bdc_dynpro      USING 'RV13A016' '1000'.
*          PERFORM bdc_field       USING 'BDC_OKCODE'
*                                        '=ONLI'.
*          PERFORM bdc_field       USING 'F001'
*                                        wa_upload-ebeln.
*          PERFORM bdc_field       USING 'F002-LOW'
*                                        wa_upload-ebelp.
*          PERFORM bdc_field       USING 'SEL_DATE'
*                                        wa_upload-validfrom.
*
*          PERFORM bdc_dynpro      USING 'SAPMV13A' '1016'.
*          PERFORM bdc_field       USING 'BDC_CURSOR'
*                                        'RV13A-DATBI(01)'.
*          PERFORM bdc_field       USING 'BDC_OKCODE'
*                                        '/00'.
*          PERFORM bdc_field       USING 'KONP-KBETR(01)'
*                                        lv_abdis.
*          PERFORM bdc_field       USING 'KONP-KONWA(01)'
*                                        wa_upload-waers.
*          PERFORM bdc_field       USING 'KONP-KPEIN(01)'
*                                        lv_kpein.
*          PERFORM bdc_field       USING 'KONP-KMEIN(01)'
*                                        wa_upload-kmein.
*          PERFORM bdc_field       USING 'RV13A-DATBI(01)'
*                                        wa_upload-validto.
*
*          PERFORM bdc_dynpro      USING 'SAPMV13A' '1016'.
*          PERFORM bdc_field       USING 'BDC_CURSOR'
*                                        'KOMG-EVRTP(01)'.
*          PERFORM bdc_field       USING 'BDC_OKCODE'
*                                        '=SICH'.
*
*          BREAK ANDRYANTO.
*          PERFORM bdc_transaction USING 'XK14'.
*          LOOP AT i_return WHERE message_v3 EQ messtab-msgv1.
*            MODIFY i_return TRANSPORTING message_v4 log_no WHERE message_v3 EQ messtab-msgv1.
*          ENDLOOP.
*        ENDIF.
*      ELSE.
** Update using XK14
*        IF wa_upload-gross <> space.
*          CLEAR: lv_gross, lv_disco, lv_abdis, lv_kpein, lv_ebelp.
*          lv_ebelp = wa_upload-ebelp.
*          lv_gross = wa_upload-gross.
*          lv_disco = wa_upload-disco.
*          lv_abdis = wa_upload-abdis.
*          lv_kpein = wa_upload-kpein.
*          CONDENSE: lv_gross, lv_disco, lv_abdis, lv_kpein, lv_ebelp.
*
*          PERFORM bdc_dynpro      USING 'SAPMV13A' '0100'.
*          PERFORM bdc_field       USING 'BDC_OKCODE'
*                                        '/00'.
*          PERFORM bdc_field       USING 'RV130-KAPPL'
*                                        'M'.
*          PERFORM bdc_field       USING 'RV13A-KSCHL'
*                                        'PB00'.
*          PERFORM bdc_field       USING 'RV13A-KOTABNR'
*                                        '016'.
*
*          PERFORM bdc_dynpro      USING 'RV13A016' '1000'.
*          PERFORM bdc_field       USING 'BDC_CURSOR'
*                                        'F002-LOW'.
*          PERFORM bdc_field       USING 'BDC_OKCODE'
*                                        '/00'.
*          PERFORM bdc_field       USING 'F001'
*                                        wa_upload-ebeln.
*          PERFORM bdc_field       USING 'F002-LOW'
*                                        wa_upload-ebelp.
*          PERFORM bdc_field       USING 'SEL_DATE'
*                                        wa_upload-validfrom.
*          PERFORM bdc_dynpro      USING 'RV13A016' '1000'.
*          PERFORM bdc_field       USING 'BDC_CURSOR'
*                                        'F002-LOW'.
*          PERFORM bdc_field       USING 'BDC_OKCODE'
*                                        '=ONLI'.
*          PERFORM bdc_field       USING 'F001'
*                                        wa_upload-ebeln.
*          PERFORM bdc_field       USING 'F002-LOW'
*                                        wa_upload-ebelp.
*          PERFORM bdc_field       USING 'SEL_DATE'
*                                        wa_upload-validfrom.
*
*          PERFORM bdc_dynpro      USING 'SAPMV13A' '1016'.
*          PERFORM bdc_field       USING 'BDC_CURSOR'
*                                        'RV13A-DATBI(01)'.
*          PERFORM bdc_field       USING 'BDC_OKCODE'
*                                        '=SICH'.
*          PERFORM bdc_field       USING 'KOMG-EVRTN'
*                                        wa_upload-ebeln.
*          PERFORM bdc_field       USING 'KOMG-EVRTP(01)'
*                                        wa_upload-ebelp.
*          PERFORM bdc_field       USING 'KONP-KBETR(01)'
*                                        lv_gross.
*          PERFORM bdc_field       USING 'KONP-KONWA(01)'
*                                        wa_upload-waers.
*          PERFORM bdc_field       USING 'KONP-KPEIN(01)'
*                                        lv_kpein.
*          PERFORM bdc_field       USING 'KONP-KMEIN(01)'
*                                        wa_upload-kmein.
*          PERFORM bdc_field       USING 'RV13A-DATAB(01)'
*                                        wa_upload-validfrom.
*          PERFORM bdc_field       USING 'RV13A-DATBI(01)'
*                                        wa_upload-validto.
*
*          BREAK ANDRYANTO.
*          PERFORM bdc_transaction USING 'XK14'.
*          LOOP AT i_return WHERE message_v3 EQ messtab-msgv1.
*            MODIFY i_return TRANSPORTING message_v4 log_no WHERE message_v3 EQ messtab-msgv1.
*          ENDLOOP.
*        ENDIF.
*
*        IF wa_upload-disco <> space.
*          CLEAR: lv_disco, lv_kpein, lv_ebelp.
*          lv_ebelp = wa_upload-ebelp.
*          lv_disco = wa_upload-gross.
*          lv_kpein = wa_upload-kpein.
*          CONDENSE: lv_disco, lv_kpein, lv_ebelp.
*
*          PERFORM bdc_dynpro      USING 'SAPMV13A' '0100'.
*          PERFORM bdc_field       USING 'BDC_OKCODE'
*                                        '/00'.
*          PERFORM bdc_field       USING 'RV130-KAPPL'
*                                        'M'.
*          PERFORM bdc_field       USING 'RV13A-KSCHL'
*                                        'RA00'.
*          PERFORM bdc_field       USING 'RV13A-KOTABNR'
*                                        '019'.
*
*          PERFORM bdc_dynpro      USING 'RV13A016' '1000'.
*          PERFORM bdc_field       USING 'BDC_CURSOR'
*                                        'F002-LOW'.
*          PERFORM bdc_field       USING 'BDC_OKCODE'
*                                        '/00'.
*          PERFORM bdc_field       USING 'F001'
*                                        wa_upload-ebeln.
*          PERFORM bdc_field       USING 'F002-LOW'
*                                        wa_upload-ebelp.
*          PERFORM bdc_field       USING 'SEL_DATE'
*                                        wa_upload-validfrom.
*          PERFORM bdc_dynpro      USING 'RV13A016' '1000'.
*          PERFORM bdc_field       USING 'BDC_CURSOR'
*                                        'F002-LOW'.
*          PERFORM bdc_field       USING 'BDC_OKCODE'
*                                        '=ONLI'.
*          PERFORM bdc_field       USING 'F001'
*                                        wa_upload-ebeln.
*          PERFORM bdc_field       USING 'F002-LOW'
*                                        wa_upload-ebelp.
*          PERFORM bdc_field       USING 'SEL_DATE'
*                                        wa_upload-validfrom.
*
*          PERFORM bdc_dynpro      USING 'SAPMV13A' '1016'.
*          PERFORM bdc_field       USING 'BDC_CURSOR'
*                                        'RV13A-DATBI(01)'.
*          PERFORM bdc_field       USING 'BDC_OKCODE'
*                                        '=SICH'.
*          PERFORM bdc_field       USING 'KOMG-EVRTN'
*                                        wa_upload-ebeln.
*          PERFORM bdc_field       USING 'KOMG-EVRTP(01)'
*                                        wa_upload-ebelp.
*          PERFORM bdc_field       USING 'KONP-KBETR(01)'
*                                        lv_disco.
*          PERFORM bdc_field       USING 'KONP-KONWA(01)'
*                                        wa_upload-waers.
*          PERFORM bdc_field       USING 'KONP-KPEIN(01)'
*                                        lv_kpein.
*          PERFORM bdc_field       USING 'KONP-KMEIN(01)'
*                                        wa_upload-kmein.
*          PERFORM bdc_field       USING 'RV13A-DATAB(01)'
*                                        wa_upload-validfrom.
*          PERFORM bdc_field       USING 'RV13A-DATBI(01)'
*                                        wa_upload-validto.
*
*          BREAK ANDRYANTO.
*          PERFORM bdc_transaction USING 'XK14'.
*          LOOP AT i_return WHERE message_v3 EQ messtab-msgv1.
*            MODIFY i_return TRANSPORTING message_v4 log_no WHERE message_v3 EQ messtab-msgv1.
*          ENDLOOP.
*        ENDIF.
*
*        IF wa_upload-abdis <> space.
*          CLEAR: lv_abdis, lv_kpein, lv_ebelp.
*          lv_ebelp = wa_upload-ebelp.
*          lv_abdis = wa_upload-gross.
*          lv_kpein = wa_upload-kpein.
*          CONDENSE: lv_abdis, lv_kpein, lv_ebelp.
*
*          PERFORM bdc_dynpro      USING 'SAPMV13A' '0100'.
*          PERFORM bdc_field       USING 'BDC_OKCODE'
*                                        '/00'.
*          PERFORM bdc_field       USING 'RV130-KAPPL'
*                                        'M'.
*          PERFORM bdc_field       USING 'RV13A-KSCHL'
*                                        'RB00'.
*          PERFORM bdc_field       USING 'RV13A-KOTABNR'
*                                        '016'.
*
*          PERFORM bdc_dynpro      USING 'RV13A016' '1000'.
*          PERFORM bdc_field       USING 'BDC_CURSOR'
*                                        'F002-LOW'.
*          PERFORM bdc_field       USING 'BDC_OKCODE'
*                                        '/00'.
*          PERFORM bdc_field       USING 'F001'
*                                        wa_upload-ebeln.
*          PERFORM bdc_field       USING 'F002-LOW'
*                                        wa_upload-ebelp.
*          PERFORM bdc_field       USING 'SEL_DATE'
*                                        wa_upload-validfrom.
*          PERFORM bdc_dynpro      USING 'RV13A016' '1000'.
*          PERFORM bdc_field       USING 'BDC_CURSOR'
*                                        'F002-LOW'.
*          PERFORM bdc_field       USING 'BDC_OKCODE'
*                                        '=ONLI'.
*          PERFORM bdc_field       USING 'F001'
*                                        wa_upload-ebeln.
*          PERFORM bdc_field       USING 'F002-LOW'
*                                        wa_upload-ebelp.
*          PERFORM bdc_field       USING 'SEL_DATE'
*                                        wa_upload-validfrom.
*
*          PERFORM bdc_dynpro      USING 'SAPMV13A' '1016'.
*          PERFORM bdc_field       USING 'BDC_CURSOR'
*                                        'RV13A-DATBI(01)'.
*          PERFORM bdc_field       USING 'BDC_OKCODE'
*                                        '=SICH'.
*          PERFORM bdc_field       USING 'KOMG-EVRTN'
*                                        wa_upload-ebeln.
*          PERFORM bdc_field       USING 'KOMG-EVRTP(01)'
*                                        wa_upload-ebelp.
*          PERFORM bdc_field       USING 'KONP-KBETR(01)'
*                                        lv_abdis.
*          PERFORM bdc_field       USING 'KONP-KONWA(01)'
*                                        wa_upload-waers.
*          PERFORM bdc_field       USING 'KONP-KPEIN(01)'
*                                        lv_kpein.
*          PERFORM bdc_field       USING 'KONP-KMEIN(01)'
*                                        wa_upload-kmein.
*          PERFORM bdc_field       USING 'RV13A-DATAB(01)'
*                                        wa_upload-validfrom.
*          PERFORM bdc_field       USING 'RV13A-DATBI(01)'
*                                        wa_upload-validto.
*
*          BREAK ANDRYANTO.
*          PERFORM bdc_transaction USING 'XK14'.
*          LOOP AT i_return WHERE message_v3 EQ messtab-msgv1.
*            MODIFY i_return TRANSPORTING message_v4 log_no WHERE message_v3 EQ messtab-msgv1.
*          ENDLOOP.
*        ENDIF.
*      ENDIF.
*
** Update EKPO-SPINF
** Using ME47
*      PERFORM bdc_dynpro      USING 'SAPMM06E' '0305'.
*      PERFORM bdc_field       USING 'BDC_OKCODE'
*                                    '/00'.
*      PERFORM bdc_field       USING 'RM06E-ANFNR'
*                                    wa_upload-ebeln.
*
*      PERFORM bdc_dynpro      USING 'SAPMM06E' '0323'.
*      PERFORM bdc_field       USING 'BDC_OKCODE'
*                                    '/00'.
*      PERFORM bdc_field       USING 'RM06E-EBELP'
*                                    wa_upload-ebelp.
*
*      PERFORM bdc_dynpro      USING 'SAPMM06E' '0323'.
*      PERFORM bdc_field       USING 'BDC_CURSOR'
*                                    'EKPO-TXZ01(01)'.
*      PERFORM bdc_field       USING 'BDC_OKCODE'
*                                    '=DETA'.
*      PERFORM bdc_field       USING 'RM06E-EBELP'
*                                    wa_upload-ebelp.
*
*      PERFORM bdc_dynpro      USING 'SAPMM06E' '0311'.
*      PERFORM bdc_field       USING 'BDC_OKCODE'
*                                    '=BU'.
*      PERFORM bdc_field       USING 'EKPO-SPINF'
*                                    wa_upload-spinf.
*
*      BREAK ANDRYANTO.
*      PERFORM bdc_transaction_me47 USING 'ME47'.
*      LOOP AT i_return WHERE message_v3 EQ messtab-msgv1.
*        MODIFY i_return TRANSPORTING message_v4 log_no WHERE message_v3 EQ messtab-msgv1.
*      ENDLOOP.
*
*      IF v_msg_ME47 = 'X'.
*        CLEAR: wa_result.
*        wa_result-ebeln = wa_upload-ebeln.
*        wa_result-ebelp = wa_upload-ebelp.
*        wa_result-spinf = wa_upload-spinf.
*        wa_result-remark = c_success.
*        APPEND wa_result to it_result.
*      ENDIF.
    ELSE.
      CLEAR: wa_result.
      wa_result-ebeln = wa_upload-ebeln.
      wa_result-ebelp = wa_upload-ebelp.
      wa_result-spinf = wa_upload-spinf.
      wa_result-remark = 'Quotation number not in the purchasing organization'.
      APPEND wa_result to it_result.
    ENDIF.
  ENDLOOP.
endform.                    " PROCESS_DATA

*----------------------------------------------------------------------*
*        Start new transaction according to parameters                 *
*----------------------------------------------------------------------*
FORM bdc_transaction USING tcode.
  DATA: l_mstring(480).
  DATA: l_subrc LIKE sy-subrc.
* batch input session
  IF session = 'X'.
    CALL FUNCTION 'BDC_INSERT'
      EXPORTING
        tcode     = tcode
      TABLES
        dynprotab = bdcdata.
    IF smalllog <> 'X'.
      WRITE: / 'BDC_INSERT'(i03),
               tcode,
               'returncode:'(i05),
               sy-subrc,
               'RECORD:',
               sy-index.
    ENDIF.
* call transaction using
  ELSE.
    REFRESH messtab.
    CALL TRANSACTION tcode USING bdcdata
                     MODE   ctumode
                     UPDATE cupdate
                     MESSAGES INTO messtab.
    l_subrc = sy-subrc.
    IF smalllog <> 'X'.

      LOOP AT messtab.
        MOVE: messtab-msgtyp TO i_return-type.
        CONCATENATE messtab-msgid messtab-msgnr INTO i_return-message_v1 SEPARATED BY space.

        IF messtab-msgtyp EQ 'S' AND messtab-msgid EQ 'VK' AND messtab-msgnr EQ '023'.
          v_msg = 'X'.
        ENDIF.
        SELECT SINGLE * FROM t100 WHERE sprsl = messtab-msgspra
                             AND   arbgb = messtab-msgid
                             AND   msgnr = messtab-msgnr.
        IF sy-subrc = 0.
          i_return-message = t100-text.
          l_mstring = t100-text.
          i_return-message_v2 = messtab-msgv2.
          i_return-message_v3 = messtab-msgv1.
          IF l_mstring CS '&1'.
            REPLACE '&1' WITH messtab-msgv1 INTO l_mstring.
            REPLACE '&2' WITH messtab-msgv2 INTO l_mstring.
            REPLACE '&3' WITH messtab-msgv3 INTO l_mstring.
            REPLACE '&4' WITH messtab-msgv4 INTO l_mstring.
          ELSE.
            REPLACE '&' WITH messtab-msgv1 INTO l_mstring.
            REPLACE '&' WITH messtab-msgv2 INTO l_mstring.
            REPLACE '&' WITH messtab-msgv3 INTO l_mstring.
            REPLACE '&' WITH messtab-msgv4 INTO l_mstring.
          ENDIF.
          CONDENSE l_mstring.
          i_return-message = l_mstring(250).
          INSERT table i_return.
          CLEAR i_return.
        ELSE.
          i_return-message_v2 = messtab-msgv2.
          i_return-message_v3 = messtab-msgv1.
          INSERT table i_return.
          CLEAR i_return.
        ENDIF.
      ENDLOOP.
    ENDIF.
** Erzeugen fehlermappe ************************************************
    IF l_subrc <> 0 AND e_group <> space.
      IF e_group_opened = ' '.
        CALL FUNCTION 'BDC_OPEN_GROUP'
          EXPORTING
            client   = sy-mandt
            group    = e_group
            user     = sy-uname
            keep     = space
            holddate = space.
        e_group_opened = 'X'.
      ENDIF.
      CALL FUNCTION 'BDC_INSERT'
        EXPORTING
          tcode     = tcode
        TABLES
          dynprotab = bdcdata.
    ENDIF.
  ENDIF.
  REFRESH bdcdata.
ENDFORM.                    "BDC_TRANSACTION

*----------------------------------------------------------------------*
*        Start new transaction according to parameters                 *
*----------------------------------------------------------------------*
FORM bdc_transaction_me47 USING tcode.
  DATA: l_mstring(480).
  DATA: l_subrc LIKE sy-subrc.
* batch input session
  IF session = 'X'.
    CALL FUNCTION 'BDC_INSERT'
      EXPORTING
        tcode     = tcode
      TABLES
        dynprotab = bdcdata.
    IF smalllog <> 'X'.
      WRITE: / 'BDC_INSERT'(i03),
               tcode,
               'returncode:'(i05),
               sy-subrc,
               'RECORD:',
               sy-index.
    ENDIF.
* call transaction using
  ELSE.
    REFRESH messtab.
    CALL TRANSACTION tcode USING bdcdata
                     MODE   ctumode
                     UPDATE cupdate
                     MESSAGES INTO messtab.
    l_subrc = sy-subrc.
    IF smalllog <> 'X'.

      LOOP AT messtab.
        MOVE: messtab-msgtyp TO i_return-type.
        CONCATENATE messtab-msgid messtab-msgnr INTO i_return-message_v1 SEPARATED BY space.

        IF ( messtab-msgtyp EQ 'S' AND messtab-msgid EQ 'ME' AND messtab-msgnr EQ '379' ) or
           ( messtab-msgtyp EQ 'S' AND messtab-msgid EQ '06' AND messtab-msgnr EQ '023' ).
          v_msg_ME47 = 'X'.
        ENDIF.
        SELECT SINGLE * FROM t100 WHERE sprsl = messtab-msgspra
                             AND   arbgb = messtab-msgid
                             AND   msgnr = messtab-msgnr.
        IF sy-subrc = 0.
          i_return-message = t100-text.
          l_mstring = t100-text.
          i_return-message_v2 = messtab-msgv2.
          i_return-message_v3 = messtab-msgv1.
          IF l_mstring CS '&1'.
            REPLACE '&1' WITH messtab-msgv1 INTO l_mstring.
            REPLACE '&2' WITH messtab-msgv2 INTO l_mstring.
            REPLACE '&3' WITH messtab-msgv3 INTO l_mstring.
            REPLACE '&4' WITH messtab-msgv4 INTO l_mstring.
          ELSE.
            REPLACE '&' WITH messtab-msgv1 INTO l_mstring.
            REPLACE '&' WITH messtab-msgv2 INTO l_mstring.
            REPLACE '&' WITH messtab-msgv3 INTO l_mstring.
            REPLACE '&' WITH messtab-msgv4 INTO l_mstring.
          ENDIF.
          CONDENSE l_mstring.
          i_return-message = l_mstring(250).
          INSERT table i_return.
          CLEAR i_return.
        ELSE.
          i_return-message_v2 = messtab-msgv2.
          i_return-message_v3 = messtab-msgv1.
          INSERT table i_return.
          CLEAR i_return.
        ENDIF.
      ENDLOOP.
    ENDIF.
** Erzeugen fehlermappe ************************************************
    IF l_subrc <> 0 AND e_group <> space.
      IF e_group_opened = ' '.
        CALL FUNCTION 'BDC_OPEN_GROUP'
          EXPORTING
            client   = sy-mandt
            group    = e_group
            user     = sy-uname
            keep     = space
            holddate = space.
        e_group_opened = 'X'.
      ENDIF.
      CALL FUNCTION 'BDC_INSERT'
        EXPORTING
          tcode     = tcode
        TABLES
          dynprotab = bdcdata.
    ENDIF.
  ENDIF.
  REFRESH bdcdata.
ENDFORM.                    "BDC_TRANSACTION_ME47

*----------------------------------------------------------------------*
*        Start new screen                                              *
*----------------------------------------------------------------------*
FORM bdc_dynpro USING program dynpro.
  CLEAR bdcdata.
  bdcdata-program  = program.
  bdcdata-dynpro   = dynpro.
  bdcdata-dynbegin = 'X'.
  APPEND bdcdata.
ENDFORM.                    "BDC_DYNPRO

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM bdc_field USING fnam fval.
  IF fval <> nodata.
    CLEAR bdcdata.
    bdcdata-fnam = fnam.
    bdcdata-fval = fval.
    APPEND bdcdata.
  ENDIF.
ENDFORM.                    "BDC_FIELD

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA
*&---------------------------------------------------------------------*
*       Display data
*----------------------------------------------------------------------*
form DISPLAY_DATA .
  perform build_fld_catalog using:
    'EBELN'  text-t01 text-t01 'X'      space   10  '' '' changing gt_fldcat,
    'EBELP'  text-t02 text-t02 'X'      space   10 '' '' changing gt_fldcat,
    'SPINF'  text-t03 text-t03 'X'      space   10 '' '' changing gt_fldcat,
    'REMARK'  text-t04 text-t04 'X'      space   20 '' '' changing gt_fldcat.

* construct sort information
  perform build_sort using: 'EBELN'  'X'    changing gt_sortab.
  perform build_sort using: 'EBELP'  'X'    changing gt_sortab.

* Assign properties for the Layout
  perform assign_layout.

* Define ALV Events
  perform define_events.

* Display Layout in an ALV grid
  perform display_grid.

endform.                    " DISPLAY_DATA

*&---------------------------------------------------------------------*
*&      Form  BUILD_FLD_CATALOG
*&---------------------------------------------------------------------*
*       Build fieldcatalog
*----------------------------------------------------------------------*
*      -->pv_fieldname   Fieldname
*      -->pv_longtext    Field Description
*      -->pv_key         Key Field
*      -->pv_REFUNIT     Reference Unit
*      <--pt_fieldtab    Field Catalog
*----------------------------------------------------------------------*

form build_fld_catalog using pv_fieldname
                                pv_longtext
                                pv_shorttext
                                pv_key
                                pv_refunit
                                pv_length
                                pv_do_sum
                                pv_cfieldname
                       changing pt_fieldtab type slis_t_fieldcat_alv.

  data:  ls_fieldcat  type slis_fieldcat_alv.
  clear: ls_fieldcat.

  ls_fieldcat-tabname   = 'IT_REPORT'.
  ls_fieldcat-fieldname = pv_fieldname.
  ls_fieldcat-outputlen = pv_length.
  ls_fieldcat-do_sum = pv_do_sum.
  ls_fieldcat-cfieldname = pv_cfieldname.

*  ls_fieldcat-fix_column = 'X'.

  if pv_longtext is not initial.
    ls_fieldcat-seltext_s = pv_shorttext.
    ls_fieldcat-seltext_m = pv_shorttext.
    ls_fieldcat-seltext_l = pv_longtext.
  endif.
  ls_fieldcat-key       = pv_key.

  append ls_fieldcat to pt_fieldtab.
  clear ls_fieldcat.
endform. " BUILD_FLD_CATALOG

*&---------------------------------------------------------------------*
*&      Form  BUILD_SORT
*&---------------------------------------------------------------------*
*       Construct Sort fields
*----------------------------------------------------------------------*
*      -->PV_FIELD   Sort Field
*      <--PT_SORTAB  Sorting table
*----------------------------------------------------------------------*

form build_sort using pv_fieldname
                          pv_subtotal
                    changing pt_sortab type slis_t_sortinfo_alv.
  data:  ls_sort_line type slis_sortinfo_alv.

  clear ls_sort_line.
  ls_sort_line-fieldname = pv_fieldname.
  ls_sort_line-up = 'X'.
  ls_sort_line-subtot = pv_subtotal.
  append ls_sort_line to pt_sortab.

endform. " BUILD_SORT

*&---------------------------------------------------------------------*
*&      Form  ASSIGN_LAYOUT
*&---------------------------------------------------------------------*
*       Define ALV layout
*----------------------------------------------------------------------*

form assign_layout .


* Define layout

  gs_layout-zebra             = 'X'.
  gs_layout-colwidth_optimize = 'X'.
  gs_layout-numc_sum          = 'X'.

*  gs_layout-subtot            = 'X'.
*  gs_layout-lights_tabname = 'IT_REPORT'.
*  gs_layout-lights_fieldname = 'STATUS'.

* gs_setting-no_colwopt = 'X'.
*  gs_setting-coll_end_l = 'X'.
*subtot

endform. " ASSIGN_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_GRID
*&---------------------------------------------------------------------*
*       Display Gain / Loss  Report
*----------------------------------------------------------------------*

form display_grid.

*  SORT it_report by kunnr. gs_setting
* Display Gain/Loss Report in an ALV GRID
    call function 'REUSE_ALV_GRID_DISPLAY'
      exporting
        i_callback_program = sy-cprog
        is_layout          = gs_layout
        i_grid_settings    = gs_setting
        it_fieldcat        = gt_fldcat
        it_sort            = gt_sortab

*        i_save             = 'X'

        i_save             = 'A'
        it_events          = gt_events[]
      tables
        t_outtab           = it_result[]
      exceptions
        program_error      = 1
        others             = 2.

  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

endform. " DISPLAY_GRID


*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&---------------------------------------------------------------------*
*       Header for the ALV report
*----------------------------------------------------------------------*

form top_of_page .
  data: ls_comments type line of slis_t_listheader,
        lt_comments type slis_t_listheader.
  data: lv_date(10) type c.
  clear ls_comments.

* Add Company code

  ls_comments-typ  = 'S'.
  ls_comments-key  = text-h01.
  ls_comments-info = p_ekorg.
  append ls_comments to lt_comments.

* Add report title
  ls_comments-typ  = 'S'.
  ls_comments-key  = text-h01.
  ls_comments-info = 'Quotation Upload'.
  append ls_comments to lt_comments.


* Add User/date/time

  data: lv_datum(10) type c,
         lv_uzeit(10) type c.

  write: sy-datum to lv_datum,
         sy-uzeit to lv_uzeit.

  ls_comments-typ  = 'S'.
  ls_comments-key  = text-h04.
  concatenate sy-uname '/' lv_datum '/' lv_uzeit into ls_comments-info.
  append ls_comments to lt_comments.


* Add Report Ref

  ls_comments-typ  = 'S'.
  ls_comments-key  = text-h06.
  ls_comments-info = sy-cprog.
  append ls_comments to lt_comments.

  call function 'REUSE_ALV_COMMENTARY_WRITE'
    exporting
      it_list_commentary = lt_comments[].

*   I_LOGO                   =
*   I_END_OF_LIST_GRID       =



endform. "TOP_OF_PAGE

**&---------------------------------------------------------------------*
**&      Form  END_OF_PAGE
**&---------------------------------------------------------------------*
**       Footer for the ALV report
**----------------------------------------------------------------------*
*FORM end_of_page.
*  DATA: listwidth TYPE i,
*        ld_pagepos(10) TYPE c,
*        ld_page(10)    TYPE c.
*
*  WRITE: sy-uline(50).
*  SKIP.
*  WRITE:/40 'Page:', sy-pagno .
*
*
*ENDFORM.                    "END_OF_PAGE
*&---------------------------------------------------------------------*
*&      Form  DEFINE_EVENTS
*&---------------------------------------------------------------------*
*       Define top-of-page events
*----------------------------------------------------------------------*

form define_events .

  data: lt_events type slis_alv_event.


* To import the Top of Page event

  call function 'REUSE_ALV_EVENTS_GET'
    exporting
      i_list_type     = 0
    importing
      et_events       = gt_events
    exceptions
      list_type_wrong = 1
      others          = 2.

  if sy-subrc eq 0.

* To read the TOP-OF-PAGE event

    sort gt_events by name.
    clear lt_events.
    read table gt_events with key name = slis_ev_top_of_page
                            into lt_events
                            binary search.

    if sy-subrc = 0.
      move 'TOP_OF_PAGE' to lt_events-form.
      modify gt_events from lt_events index sy-tabix
                                            transporting form.
    endif.

*+b Andryanto P30K902948
    clear lt_events.
    read table gt_events with key name = slis_ev_user_command
                            into lt_events
                            binary search.

    if sy-subrc = 0.
      move 'USER_COMMAND1' to lt_events-form.
      modify gt_events from lt_events index sy-tabix
                                            transporting form.
    endif.
*+e Andryanto P30K902948

*    CLEAR lt_events.
*    READ TABLE gt_events WITH KEY name = slis_ev_end_of_page
*                            INTO lt_events
*                            BINARY SEARCH.
*
*    IF sy-subrc = 0.
*
*      MOVE 'END_OF_PAGE' TO lt_events-form.
*      MODIFY gt_events FROM lt_events INDEX sy-tabix
*                                            TRANSPORTING form.
*    ENDIF.

*    CLEAR lt_events.
*    READ TABLE gt_events WITH KEY name = slis_ev_end_of_list
*                            INTO lt_events
*                            BINARY SEARCH.
*
*    IF sy-subrc = 0.
*
*      MOVE 'END_OF_LIST' TO lt_events-form.
*      MODIFY gt_events FROM lt_events INDEX sy-tabix
*                                            TRANSPORTING form.
*    ENDIF.
  endif.  "IF SY-SUBRC EQ 0.
endform. " DEFINE_EVENTS

*----------------------------------------------------------------------*
*       FORM USER_COMMAND1
*       New Form ..... P30K902948
*&---------------------------------------------------------------------*
*       REUSE ALV: User Command 1
*----------------------------------------------------------------------*
*  -->  F_UCOMM           Function Code
*  -->  F_S_SELFIELD      Information Cursor Position ALV
*----------------------------------------------------------------------*
form user_command1 using f_ucomm  type sy-ucomm             "#EC CALLED
                         f_s_selfield type slis_selfield.

  case f_ucomm.
    when '&IC1'.
      case f_s_selfield-fieldname.
        when 'EBELN' OR
             'EBELP'.
          read table it_result INTO wa_result
          index f_s_selfield-tabindex.
          if sy-subrc = 0.
            if not wa_result-ebeln is initial.
              set parameter id 'ANF' field wa_result-ebeln.
              call transaction 'ME48' and skip first screen.
            endif.
            clear wa_result.
          endif.
      endcase.
  endcase.

endform.                    " USER_COMMAND1

*&---------------------------------------------------------------------*
*&      Form  CHECK_AUTHORISATION
*&---------------------------------------------------------------------*
*       Authorisation checking
*----------------------------------------------------------------------*
form CHECK_AUTHORISATION .
  CLEAR: g_error.
  AUTHORITY-CHECK OBJECT 'M_ANFR_EKO'
           ID 'ACTVT' FIELD '01'
           ID 'EKORG' FIELD P_EKORG.
  if sy-subrc <> 0.
    message i006(zmm) with p_ekorg.
    g_error = 'X'.
  endif.
endform.                    " CHECK_AUTHORISATION
