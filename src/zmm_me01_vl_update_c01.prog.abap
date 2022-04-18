*&---------------------------------------------------------------------*
*& Include          ZMM_ME01_VL_UPDATE_C01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      LOCAL CLASS LCL_DATA DEFINITION                              *
*&---------------------------------------------------------------------*
CLASS lcl_data IMPLEMENTATION.

*______________________________________________________________________*
  METHOD constructor.
*______________________________________________________________________*


*    GET REFERENCE OF cv_file INTO aw_scrfields-p_file.

  ENDMETHOD.

*______________________________________________________________________*
  METHOD f4_filename.
*______________________________________________________________________*

    DATA:
      lv_rc          TYPE i,
      lt_filetable   TYPE filetable,
      lv_file_filter TYPE string.


    IF iv_xlsx IS NOT INITIAL.
      lv_file_filter = cl_gui_frontend_services=>filetype_excel.
    ELSE.
      lv_file_filter = 'Comma Delimited (*.CSV)|*.CSV'.
    ENDIF.

    cl_gui_frontend_services=>file_open_dialog(
      EXPORTING
        file_filter             = lv_file_filter
      CHANGING
        file_table              = lt_filetable
        rc                      = lv_rc
      EXCEPTIONS
        file_open_dialog_failed = 1
        cntl_error              = 2
        error_no_gui            = 3
        not_supported_by_gui    = 4
        OTHERS                  = 5
    ).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_excp_msg
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

    ELSE.
      READ TABLE lt_filetable INDEX 1 INTO rv_filename.

    ENDIF.
  ENDMETHOD.

*______________________________________________________________________*
  METHOD begin_process.
*______________________________________________________________________*

    t_result = me->upload_data( p_file ).

    me->update_source_list( CHANGING cv_data = t_result ).

    me->view( iv_data = t_result ).

  ENDMETHOD.

*______________________________________________________________________*
  METHOD upload_data.
*______________________________________________________________________*

    DATA:
      lt_file TYPE tt_file.

    CASE abap_true.
      WHEN rb_xlsx.
        lt_file = me->upload_xls_file( iv_filename ).

      WHEN OTHERS.
        lt_file = me->upload_csv_file( iv_filename ).

    ENDCASE.

    rv_data = me->data_massage( lt_file ).

  ENDMETHOD.

*______________________________________________________________________*
  METHOD get_date_format.
*______________________________________________________________________*

    DATA :
      lt_dom_val TYPE ddfixvalues.


    SELECT SINGLE datfm
      FROM usr01
      INTO @DATA(lv_datfm)
    WHERE bname = @sy-uname.
    IF sy-subrc <> 0.
      lv_datfm = '1'. "Default
    ENDIF.

    FREE lt_dom_val.
    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname        = 'USR01'
        fieldname      = 'DATFM'
        lfieldname     = 'DATFM'
      TABLES
        fixed_values   = lt_dom_val
      EXCEPTIONS
        not_found      = 1
        internal_error = 2
        OTHERS         = 3.

    READ TABLE lt_dom_val ASSIGNING FIELD-SYMBOL(<dom>)
    WITH KEY low = lv_datfm.
    IF sy-subrc = 0.
      rv_dtfm = <dom>-ddtext.
    ELSE.
      rv_dtfm = 'DD.MM.YYYY'.
    ENDIF.

  ENDMETHOD.

*______________________________________________________________________*
  METHOD data_massage.
*______________________________________________________________________*

    DATA:
      lv_dtfm  TYPE string,
      lv_s1    TYPE string,
      lv_s2    TYPE string,
      lv_s3    TYPE string,

      lr_matnr TYPE RANGE OF matnr,
      lr_werks TYPE RANGE OF werks_d,
      lr_lifnr TYPE RANGE OF lifnr,
      lr_meins TYPE RANGE OF meins,
      lr_ekorg TYPE RANGE OF ekorg.


    FREE rv_data[].

    FREE:
      lr_matnr[],
      lr_werks[],
      lr_lifnr[],
      lr_meins[],
      lr_ekorg[].


    lv_dtfm = me->get_date_format( ).

    IF lv_dtfm CA '.'.
      DATA(lv_sep) = '.'.
    ELSE.
      lv_sep = '/'.
    ENDIF.

    SPLIT lv_dtfm AT lv_sep
     INTO lv_s1
          lv_s2
          lv_s3.


*   Transfer file data
    LOOP AT cv_file ASSIGNING FIELD-SYMBOL(<file>).
      APPEND INITIAL LINE TO rv_data ASSIGNING FIELD-SYMBOL(<data>).
      <data>-ekorg = <file>-ekorg.
      <data>-werks = <file>-werks.
      <data>-matnr = <file>-matnr.
      <data>-maktx = <file>-maktx.
      <data>-lifnr = <file>-lifnr.
      <data>-lifnrx = <file>-lifnrx.
      <data>-meins = <file>-meins.
      <data>-flifn = <file>-flifn.

*     Convert Material to Internal Value
      CALL FUNCTION 'CONVERSION_EXIT_MATNL_INPUT'
        EXPORTING
          input        = <file>-matnr
        IMPORTING
          output       = <data>-matnr
        EXCEPTIONS
          length_error = 1
          OTHERS       = 2.
      APPEND INITIAL LINE TO lr_matnr ASSIGNING FIELD-SYMBOL(<matnr>).
      <matnr>-sign = 'I'.
      <matnr>-option = 'EQ'.
      <matnr>-low = <data>-matnr.


*     Convert Vendor to Internal Value
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <file>-lifnr
        IMPORTING
          output = <data>-lifnr.
      APPEND INITIAL LINE TO lr_lifnr ASSIGNING FIELD-SYMBOL(<lifnr>).
      <lifnr>-sign = 'I'.
      <lifnr>-option = 'EQ'.
      <lifnr>-low = <data>-lifnr.


*     Convert UOM to Internal Value
      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
        EXPORTING
          input          = <file>-meins
        IMPORTING
          output         = <data>-meins
        EXCEPTIONS
          unit_not_found = 1
          OTHERS         = 2.
      APPEND INITIAL LINE TO lr_meins ASSIGNING FIELD-SYMBOL(<meins>).
      <meins>-sign = 'I'.
      <meins>-option = 'EQ'.
      <meins>-low = <data>-meins.


      APPEND INITIAL LINE TO lr_werks ASSIGNING FIELD-SYMBOL(<werks>).
      <werks>-sign = 'I'.
      <werks>-option = 'EQ'.
      <werks>-low = <data>-werks.


      APPEND INITIAL LINE TO lr_ekorg ASSIGNING FIELD-SYMBOL(<ekorg>).
      <ekorg>-sign = 'I'.
      <ekorg>-option = 'EQ'.
      <ekorg>-low = <data>-ekorg.


*     Massage Date
      IF lv_s1 = 'YYYY'.
        <data>-vdatu = |{ <file>-vdatu+0(4) }|.
        <data>-bdatu = |{ <file>-bdatu+0(4) }|.
        <data>-vdatu = |{ <data>-vdatu }{ <file>-vdatu+3(2) }{ <file>-vdatu+8(2) }|.
        <data>-bdatu = |{ <data>-bdatu }{ <file>-bdatu+3(2) }{ <file>-bdatu+8(2) }|.


      ELSE.
        <data>-vdatu = |{ <file>-vdatu+6(4) }|.
        <data>-bdatu = |{ <file>-bdatu+6(4) }|.
        IF lv_s2 = 'MM'.
          <data>-vdatu = |{ <data>-vdatu }{ <file>-vdatu+3(2) }{ <file>-vdatu+0(2) }|.
          <data>-bdatu = |{ <data>-bdatu }{ <file>-bdatu+3(2) }{ <file>-bdatu+0(2) }|.
        ELSE.
          <data>-vdatu = |{ <data>-vdatu }{ <file>-vdatu+0(2) }{ <file>-vdatu+3(2) }|.
          <data>-bdatu = |{ <data>-bdatu }{ <file>-bdatu+0(2) }{ <file>-bdatu+3(2) }|.
        ENDIF.

      ENDIF.

    ENDLOOP.

*   Validate Further
    IF lr_matnr[] IS NOT INITIAL.
      SORT lr_matnr BY low.
      DELETE ADJACENT DUPLICATES FROM lr_matnr COMPARING low.

      SORT lr_meins BY low.
      DELETE ADJACENT DUPLICATES FROM lr_meins COMPARING low.

      SELECT matnr, meins
        FROM mara
        INTO TABLE @DATA(lt_mara)
       WHERE ( matnr IN @lr_matnr
          OR meins IN @lr_meins ).
    ENDIF.

    IF lr_werks[] IS NOT INITIAL.
      SORT lr_werks BY low.
      DELETE ADJACENT DUPLICATES FROM lr_werks COMPARING low.

      SELECT werks
        FROM t001w
        INTO TABLE @DATA(lt_werks)
       WHERE werks IN @lr_werks.
    ENDIF.

    IF lr_lifnr[] IS NOT INITIAL.
      SORT lr_lifnr BY low.
      DELETE ADJACENT DUPLICATES FROM lr_lifnr COMPARING low.

      SELECT lifnr
        FROM lfa1
        INTO TABLE @DATA(lt_lifnr)
       WHERE lifnr IN @lr_lifnr.
    ENDIF.

    IF lr_ekorg[] IS NOT INITIAL.
      SORT lr_ekorg BY low.
      DELETE ADJACENT DUPLICATES FROM lr_ekorg COMPARING low.

      SELECT ekorg
        FROM t024e
        INTO TABLE @DATA(lt_ekorg)
       WHERE ekorg IN @lr_ekorg.
    ENDIF.

*   Validate data
    LOOP AT rv_data ASSIGNING <data>.
*     Material Validation
      READ TABLE lt_mara TRANSPORTING NO FIELDS
      WITH KEY matnr = <data>-matnr.
      IF sy-subrc <> 0.
        <data>-status = icon_red_light.
        <data>-message = 'Invalid Material'.
      ENDIF.

*     Plant Validation
      READ TABLE lt_werks TRANSPORTING NO FIELDS
      WITH KEY werks = <data>-werks.
      IF sy-subrc <> 0.
        <data>-status = icon_red_light.
        <data>-message = 'Invalid Plant'.
      ENDIF.

*     Vendor Validation
      READ TABLE lt_lifnr TRANSPORTING NO FIELDS
      WITH KEY lifnr = <data>-lifnr.
      IF sy-subrc <> 0.
        <data>-status = icon_red_light.
        <data>-message = 'Invalid Vendor'.
      ENDIF.

*     UoM Validation
*      READ TABLE lt_mara TRANSPORTING NO FIELDS
*      WITH KEY meins = <data>-meins.
*      IF sy-subrc <> 0.
*        <data>-status = icon_red_light.
*        <data>-message = 'Invalid Order Unit'.
*      ENDIF.

*     Pur. Group Validation
      READ TABLE lt_ekorg TRANSPORTING NO FIELDS
      WITH KEY ekorg = <data>-ekorg.
      IF sy-subrc <> 0.
        <data>-status = icon_red_light.
        <data>-message = 'Invalid Purchasing Org.'.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

*______________________________________________________________________*
  METHOD update_source_list.
*______________________________________________________________________*

    DATA:
      lt_data  TYPE tt_result,
      lt_eordu TYPE TABLE OF eordu,
      lt_eord  TYPE TABLE OF eordu,
      lt_tupel TYPE TABLE OF metup.

    DATA:
      ls_eordu TYPE eordu,
      ls_oeina TYPE eina,
      ls_omarc TYPE marc.

    data:
          lv_uflag type abap_bool.

    FIELD-SYMBOLS:
      <ls_oeord> TYPE eord.


    FREE:
      lt_data[],
      lt_eordu[],
      lt_eord[],
      lt_tupel[].


    SORT cv_data BY status message matnr werks.

    SELECT *
      FROM eord
      INTO TABLE @DATA(t_eord)
       FOR ALL ENTRIES IN @cv_data
     WHERE matnr = @cv_data-matnr
       AND werks = @cv_data-werks.
    IF sy-subrc = 0.
      SORT t_eord BY matnr werks lifnr ekorg.
    ENDIF.

*   Source List Validation
    LOOP AT cv_data ASSIGNING FIELD-SYMBOL(<data>)
      WHERE status <> icon_red_light.

** [AJ001] Added Checks on Valid Until in The Past, Material Plant Check
** Valid Until Can't be in the past
      IF <data>-bdatu < sy-datum.
        <data>-status = icon_red_light.
        <data>-message = 'Valid Until date must not be in the past'.
        CONTINUE.
      ENDIF.

** Material, Plant Combination have to exist
      CLEAR ls_omarc.
      SELECT SINGLE *
        FROM marc
        INTO ls_omarc
        WHERE matnr = <data>-matnr AND
              werks = <data>-werks.
      IF sy-subrc <> 0.
        <data>-status = icon_red_light.
        <data>-message = |Material { <data>-matnr }, plant { <data>-werks } combination does not exist|.
        CONTINUE.
      ENDIF.

** Check Material Plant Vendor Combination
      CLEAR ls_oeina.
      SELECT SINGLE *
        FROM eina
        INTO ls_oeina
        WHERE matnr = <data>-matnr AND
              lifnr = <data>-lifnr.
      IF sy-subrc <> 0.
        <data>-status = icon_red_light.
        <data>-message = |Info record for supplier { <data>-lifnr } and material { <data>-matnr } does not exist|.
        CONTINUE.
      ENDIF.
    ENDLOOP.


*   Skip error records
    lt_data[] = cv_data[].
    DELETE cv_data WHERE status = icon_red_light.
    DELETE lt_data WHERE status = icon_green_light.
    DELETE lt_data WHERE status = ' '.


*   Start Source List Update
    LOOP AT cv_data ASSIGNING <data>.

      FREE:
        lt_eordu[],
        lt_eord[].

      LOOP AT t_eord ASSIGNING <ls_oeord>
      WHERE matnr = <data>-matnr
        AND werks = <data>-werks
        AND ( ( vdatu <= <data>-vdatu AND bdatu >= <data>-vdatu )
         OR ( vdatu <= <data>-bdatu AND bdatu >= <data>-bdatu )
         OR ( vdatu >= <data>-vdatu AND bdatu <= <data>-bdatu ) ).

        APPEND INITIAL LINE TO lt_eord ASSIGNING FIELD-SYMBOL(<xeord>).
        MOVE-CORRESPONDING <ls_oeord> TO <xeord>.
        <xeord>-ekorg = <data>-ekorg.
        <xeord>-meins = <data>-meins.
        <xeord>-vdatu = <data>-vdatu.
        <xeord>-bdatu = <data>-bdatu.
        <xeord>-flifn = <data>-flifn.

        APPEND INITIAL LINE TO lt_eordu ASSIGNING FIELD-SYMBOL(<yeord>).
        MOVE-CORRESPONDING <xeord> TO <yeord>.
        <yeord>-kz = 'U'.

        EXIT.

      ENDLOOP.

*IF sy-subrc <> 0.
*        <data>-status = icon_red_light.
*        <data>-message = 'No valid list found. Check Validity period entries'.
*        CONTINUE.
*      ENDIF.
*     Temporary Result - during Testing
      <data>-status = icon_green_light.
      <data>-message = 'No Error Found'.

      IF cb_test = abap_false.
        IF lt_eordu IS NOT INITIAL.
          CALL FUNCTION 'ME_UPDATE_SOURCES_OF_SUPPLY'
            EXPORTING
              i_changedocument = 'X'
            TABLES
              xeord            = lt_eordu
              yeord            = lt_eord.

          IF sy-subrc = 0.
            lv_uflag = abap_true.
            <data>-status = icon_green_light.
            <data>-message = 'Updated Successfully'.
          ELSE.
            <data>-status = icon_red_light.
            <data>-message = 'Update Failed'.
          ENDIF.
        ELSE.
          FREE: ls_eordu, lt_eordu.

*        maktx   TYPE makt-maktx,
*        lifnrx  TYPE lfa1-name1,
          ls_eordu-matnr = <data>-matnr.
          ls_eordu-werks = <data>-werks.
          ls_eordu-vdatu = <data>-vdatu.
          ls_eordu-bdatu = <data>-bdatu.
          ls_eordu-lifnr = <data>-lifnr.
          ls_eordu-ekorg = <data>-ekorg.
          ls_eordu-flifn = <data>-flifn.
          ls_eordu-meins = <data>-meins.
          ls_eordu-kz    = 'I'. "I for insert
          APPEND ls_eordu TO lt_eordu.

          CALL FUNCTION 'ME_INITIALIZE_SOURCE_LIST' .
          CALL FUNCTION 'ME_DIRECT_INPUT_SOURCE_LIST'
            EXPORTING
              i_matnr          = <data>-matnr
              i_werks          = <data>-werks
            TABLES
              t_eord           = lt_eordu
            EXCEPTIONS
              plant_missing    = 1
              material_missing = 2
              OTHERS           = 3.

          IF sy-subrc = 0.
            CALL FUNCTION 'ME_POST_SOURCE_LIST_NEW'
            EXPORTING
              i_matnr = <data>-matnr.

            lv_uflag = abap_true.
            <data>-status = icon_green_light.
            <data>-message = 'Created Successfully'.
          ELSE.
            <data>-status = icon_red_light.
            <data>-message = 'Creation Failed'.
          ENDIF.
        ENDIF.
      ENDIF.

    ENDLOOP.


*   Post
    IF cb_test = abap_false AND lv_uflag = abap_true.
      COMMIT WORK AND WAIT.
    ENDIF.

    IF lt_data[] IS NOT INITIAL.
      APPEND LINES OF lt_data TO cv_data.
    ENDIF.

  ENDMETHOD.

*______________________________________________________________________*
  METHOD upload_xls_file.
*______________________________________________________________________*

    DATA:
      lt_datatab TYPE truxs_t_text_data,
      lv_file    TYPE rlgrap-filename.


    CALL FUNCTION 'GUI_UPLOAD'
      EXPORTING
        filename                = p_file
        filetype                = 'ASC'
        has_field_separator     = 'X'
        dat_mode                = ' '
      TABLES
        data_tab                = lt_datatab
      EXCEPTIONS
        file_open_error         = 1
        file_read_error         = 2
        no_batch                = 3
        gui_refuse_filetransfer = 4
        invalid_type            = 5
        no_authority            = 6
        unknown_error           = 7
        bad_data_format         = 8
        header_not_allowed      = 9
        separator_not_allowed   = 10
        header_too_long         = 11
        unknown_dp_error        = 12
        access_denied           = 13
        dp_out_of_memory        = 14
        disk_full               = 15
        dp_timeout              = 16
        OTHERS                  = 17.


    lv_file = p_file.
    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
        i_field_seperator    = 'X'
        i_tab_raw_data       = lt_datatab
        i_filename           = lv_file
      TABLES
        i_tab_converted_data = cv_file    "TYPE tt_file
      EXCEPTIONS
        conversion_failed    = 1
        OTHERS               = 2.

    IF cb_whdr EQ abap_true.
      DELETE cv_file INDEX 1.
    ENDIF.

  ENDMETHOD.

*______________________________________________________________________*
  METHOD upload_csv_file.
*______________________________________________________________________*

    DATA:
      lt_datatab  TYPE table_of_strings,
      lv_filename TYPE string.

    CONSTANTS:
      lc_tab      TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
      lc_comma(1) VALUE ','.

    FIELD-SYMBOLS:
      <lt_dtab> TYPE STANDARD TABLE,
      <fs>      TYPE any.


    lv_filename = iv_filename.

    CLEAR lt_datatab[].
    CALL METHOD cl_gui_frontend_services=>gui_upload   "#EC CI_SUBRC
      EXPORTING
        filename                = lv_filename
        filetype                = 'ASC'
      CHANGING
        data_tab                = lt_datatab
      EXCEPTIONS ##SUBRC_OK
        file_open_error         = 1
        file_read_error         = 2
        no_batch                = 3
        gui_refuse_filetransfer = 4
        invalid_type            = 5
        no_authority            = 6
        unknown_error           = 7
        bad_data_format         = 8
        header_not_allowed      = 9
        separator_not_allowed   = 10
        header_too_long         = 11
        unknown_dp_error        = 12
        access_denied           = 13
        dp_out_of_memory        = 14
        disk_full               = 15
        dp_timeout              = 16
        not_supported_by_gui    = 17
        error_no_gui            = 18
        OTHERS                  = 19.


    LOOP AT lt_datatab ASSIGNING FIELD-SYMBOL(<file>).
      IF sy-tabix = 1.
        CONTINUE.
      ENDIF.

      APPEND INITIAL LINE TO cv_file ASSIGNING FIELD-SYMBOL(<fl>).
      SPLIT <file> AT lc_comma
       INTO <fl>-ekorg
            <fl>-werks
            <fl>-matnr
            <fl>-maktx
            <fl>-lifnr
            <fl>-lifnrx
            <fl>-meins
            <fl>-vdatu
            <fl>-bdatu
            <fl>-flifn
            <fl>-tmp.
    ENDLOOP.

  ENDMETHOD.

*&----------------------------------------------------------------------*
*&   VIEW
*&----------------------------------------------------------------------*
  METHOD view.

    FIELD-SYMBOLS :
      <result_tab> TYPE any.

    DATA(lv_tmp) = 'me->t_result'.
    ASSIGN (lv_tmp) TO <result_tab>.

    IF <result_tab> IS ASSIGNED.
      me->alv_out( CHANGING iv_out_tab = <result_tab> ).
    ENDIF.

  ENDMETHOD.

*&----------------------------------------------------------------------*
*&   ALV_OUT
*&----------------------------------------------------------------------*
  METHOD alv_out.

    DATA:
      lo_alv     TYPE REF TO cl_salv_table,
      lo_columns TYPE REF TO cl_salv_columns_table.



    "Create ALV Grid Object
    TRY .
        cl_salv_table=>factory(
          EXPORTING
            list_display = abap_false
          IMPORTING
            r_salv_table = lo_alv
          CHANGING
            t_table      = iv_out_tab ).

*       Enable all functionality
        lo_alv->get_functions( )->set_all( abap_true ).

*       Update Fields Name
        lo_columns = lo_alv->get_columns( ).
        lo_columns->set_optimize( abap_true ).
        set_alv_fields( CHANGING co_columns = lo_columns ).

*       Display ALV
        lo_alv->display( ).

      CATCH cx_salv_msg INTO DATA(lcx_msg).
        MESSAGE lcx_msg->get_text( ) TYPE gc_stat-fail.
      CATCH cx_salv_not_found INTO DATA(lcx_not_found).
        MESSAGE lcx_not_found->get_text( ) TYPE gc_stat-fail.
    ENDTRY.

  ENDMETHOD.

*&----------------------------------------------------------------------*
*&   SET_ALV_FIELDS
*&----------------------------------------------------------------------*
  METHOD set_alv_fields.

    FIELD-SYMBOLS: <ls_columns> TYPE salv_s_column_ref.

    LOOP AT co_columns->get( ) ASSIGNING <ls_columns>.
      CASE <ls_columns>-columnname.
        WHEN 'LIFNRX'.
          <ls_columns>-r_column->set_short_text( 'VendName' ) ##NO_TEXT.
          <ls_columns>-r_column->set_long_text( 'Vendor Name' ) ##NO_TEXT.


      ENDCASE.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
