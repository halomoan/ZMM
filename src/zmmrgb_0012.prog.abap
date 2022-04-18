*&---------------------------------------------------------------------*
*& Report ZMMRGB_0012
*&---------------------------------------------------------------------*
*& Requestor: Sun, Wu
*&---------------------------------------------------------------------*
*& Description:
*&   - ZMMRGB_0012 Stock Count Posting for Outlet (TCode ZMM_0034)
*&---------------------------------------------------------------------*
*& Related object:
*&---------------------------------------------------------------------*
*& NO    DATE        TR           DEVELOPER
*& 0001  2021.10.26  P30K914117   Adhimas (asetianegara@deloitte.com)
*&   - Initial version
*&---------------------------------------------------------------------*
REPORT zmmrgb_0012.

CONSTANTS:
  gc_stock_gi TYPE bwart VALUE '251',
  gc_stock_gr TYPE bwart VALUE '252',
  gc_waste_gi TYPE bwart VALUE '551',
  gc_move_reas TYPE mb_grbew VALUE '0003'.

TYPES:
  BEGIN OF gty_upload,
    matkl TYPE matkl,
    matnr TYPE matnr40,
    maktx TYPE maktx,
    menge TYPE menge_d,
    meins TYPE meins,
    lgort TYPE lgort,
  END OF gty_upload,
  BEGIN OF gty_upload_txt,
    matkl(9),
    matnr(40),
    maktx(40),
    menge(15),
    meins(3),
    lgort(4),
  END OF gty_upload_txt,
  BEGIN OF gty_result,
    sele TYPE flag.
    INCLUDE STRUCTURE zmm_stock_count.
TYPES END OF gty_result.

PARAMETERS:
  p_werks TYPE mard-werks OBLIGATORY,
  p_lgort TYPE mard-lgort OBLIGATORY,
  p_kostl TYPE csks-kostl OBLIGATORY,
  p_budat TYPE budat OBLIGATORY,
  p_path  TYPE rlgrap-filename OBLIGATORY.

PARAMETERS:
  p_stock TYPE flag RADIOBUTTON GROUP rb1 DEFAULT 'X',
  p_waste TYPE flag RADIOBUTTON GROUP rb1.

DATA:
  gt_upload_txt TYPE TABLE OF gty_upload_txt,
  gt_upload     TYPE TABLE OF gty_upload,
  gt_result     TYPE TABLE OF gty_result.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_path.
  PERFORM f_get_path.

START-OF-SELECTION.
  PERFORM f_load.
  PERFORM f_select.
  PERFORM f_preprocess.
  PERFORM f_process.
  PERFORM f_display.

*--------------------------------------------------------------------*
FORM f_process.
  IF p_stock EQ abap_true.
    LOOP AT gt_result ASSIGNING FIELD-SYMBOL(<lwa_result>) WHERE error IS INITIAL.
      <lwa_result>-book_value = <lwa_result>-book_qty * <lwa_result>-difference_amt.
      <lwa_result>-difference_qty = <lwa_result>-counted_qty - <lwa_result>-book_qty.
      <lwa_result>-difference_amt = <lwa_result>-difference_qty * <lwa_result>-difference_amt.

      <lwa_result>-bwart = COND #(
        WHEN <lwa_result>-difference_qty < 0 THEN gc_stock_gi
        WHEN <lwa_result>-difference_qty > 0 THEN gc_stock_gr
        ELSE space ).
    ENDLOOP.

  ELSE.
    LOOP AT gt_result ASSIGNING <lwa_result> WHERE error IS INITIAL.
      <lwa_result>-book_value = <lwa_result>-book_qty * <lwa_result>-difference_amt.
      <lwa_result>-difference_qty = <lwa_result>-counted_qty.
      <lwa_result>-difference_amt = <lwa_result>-difference_qty * <lwa_result>-difference_amt.
      <lwa_result>-bwart = COND #(
        WHEN <lwa_result>-difference_qty <> 0 THEN gc_waste_gi
        ELSE space ).
    ENDLOOP.

  ENDIF.

ENDFORM.


FORM f_preprocess.
  CHECK gt_result IS NOT INITIAL.

  "-- get material group description from T023T-WGBEZ
  SELECT matkl, wgbez FROM t023t
    FOR ALL ENTRIES IN @gt_result
    WHERE spras = @sy-langu
      AND matkl = @gt_result-matkl
    INTO TABLE @DATA(lt_matkl_descr).

  SORT lt_matkl_descr BY matkl.

  "-- get material description from MAKT-MAKTX
  SELECT matnr, maktx FROM makt
    FOR ALL ENTRIES IN @gt_result
    WHERE spras = @sy-langu
      AND matnr = @gt_result-matnr
    INTO TABLE @DATA(lt_matnr_descr).

  SORT lt_matnr_descr BY matnr.

  "-- get material quantity from MARD-LABST
  SELECT matnr, labst FROM mard
    FOR ALL ENTRIES IN @gt_result
    WHERE matnr = @gt_result-matnr
      AND werks = @p_werks
      AND lgort = @p_lgort
    INTO TABLE @DATA(lt_book_qty).

  SORT lt_book_qty BY matnr.

  "-- get material base UoM from MARA-MEINS
  SELECT matnr, meins FROM mara
    FOR ALL ENTRIES IN @gt_result
    WHERE matnr = @gt_result-matnr
    INTO TABLE @DATA(lt_book_uom).

  SORT lt_book_uom BY matnr.

  "-- get unit price amount from MBEW-VERPR (using WERKS as valuation area)
  SELECT DISTINCT matnr, verpr FROM mbew
    FOR ALL ENTRIES IN @gt_result
    WHERE matnr = @gt_result-matnr
      AND bwkey = @p_werks
    INTO TABLE @DATA(lt_amount).

  SORT lt_amount BY matnr.

  "-- get cost center description from CSKT-LTEXT
  SELECT kostl, ltext FROM cskt
    FOR ALL ENTRIES IN @gt_result
    WHERE spras = @sy-langu
      AND kostl = @gt_result-kostl
      AND datbi >= @sy-datum
    INTO TABLE @DATA(lt_cc_descr).

  SORT lt_cc_descr BY kostl.

  LOOP AT gt_result ASSIGNING FIELD-SYMBOL(<lwa_result>).
    READ TABLE:
      lt_matkl_descr INTO DATA(lwa_matkl_descr) WITH KEY matkl = <lwa_result>-matkl BINARY SEARCH,
      lt_matnr_descr INTO DATA(lwa_matnr_descr) WITH KEY matnr = <lwa_result>-matnr BINARY SEARCH,
      lt_book_qty    INTO DATA(lwa_book_qty)    WITH KEY matnr = <lwa_result>-matnr BINARY SEARCH,
      lt_book_uom    INTO DATA(lwa_book_uom)    WITH KEY matnr = <lwa_result>-matnr BINARY SEARCH,
      lt_amount      INTO DATA(lwa_amount)      WITH KEY matnr = <lwa_result>-matnr BINARY SEARCH,
      lt_cc_descr    INTO DATA(lwa_cc_descr)    WITH KEY kostl = <lwa_result>-kostl BINARY SEARCH.

    <lwa_result>-wgbez = lwa_matkl_descr-wgbez.
    <lwa_result>-maktx = lwa_matnr_descr-maktx.
    <lwa_result>-book_qty = lwa_book_qty-labst.
    <lwa_result>-book_uom = lwa_book_uom-meins.
    <lwa_result>-difference_amt = lwa_amount-verpr.
    <lwa_result>-ltext = lwa_cc_descr-ltext.

    IF <lwa_result>-error IS INITIAL.
      <lwa_result>-error = COND #(
        WHEN lwa_matkl_descr IS INITIAL THEN 'Material group unknown'
        WHEN lwa_matnr_descr IS INITIAL THEN 'Material unknown'
*        WHEN lwa_book_qty    IS INITIAL THEN |Material quantity not found in { p_werks }/{ p_lgort }|
        WHEN lwa_book_uom    IS INITIAL THEN 'Material base unit unknown'
*        WHEN lwa_amount      IS INITIAL THEN 'Material unit price unknown'
        WHEN lwa_cc_descr    IS INITIAL THEN 'Cost center unknown'
        WHEN <lwa_result>-book_uom NE <lwa_result>-counted_uom THEN 'Counted UoM should be the same as book UoM'
        ELSE space ).
    ENDIF.

    CLEAR:
      lwa_matkl_descr,
      lwa_matnr_descr,
      lwa_book_qty,
      lwa_book_uom,
      lwa_amount,
      lwa_cc_descr.
  ENDLOOP.

ENDFORM.


FORM f_read_excel.
  DATA: lt_intern  TYPE STANDARD TABLE OF alsmex_tabline,
        lwa_upload TYPE gty_upload_txt.

  FIELD-SYMBOLS: <fs_intern> LIKE LINE OF lt_intern,
                 <fs_aux>.

  DATA: lv_index TYPE i.

  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = p_path
      i_begin_col             = '1'
      i_begin_row             = '1'
      i_end_col               = '6'
      i_end_row               = '65536'
    TABLES
      intern                  = lt_intern
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.

  IF sy-subrc <> 0.
    MESSAGE 'Incorrect file format' TYPE 'E'.
  ENDIF.

  DELETE lt_intern WHERE row EQ '0001'. "skip header

  SORT lt_intern BY row col.
  LOOP AT lt_intern ASSIGNING <fs_intern>.
    MOVE <fs_intern>-col TO lv_index.
    ASSIGN COMPONENT lv_index OF STRUCTURE lwa_upload TO <fs_aux>.
    MOVE <fs_intern>-value TO <fs_aux>.
    AT END OF row.
      APPEND lwa_upload TO gt_upload_txt.
      CLEAR lwa_upload.
    ENDAT.
  ENDLOOP.
ENDFORM.


FORM f_load.
  PERFORM f_read_excel.

  IF gt_upload_txt IS INITIAL.
    MESSAGE 'The file contains no data.' TYPE 'S'.

  ELSE.
    LOOP AT gt_upload_txt INTO DATA(lwa_upload_txt).
      DATA(lwa_upload) = VALUE gty_upload(
        matkl = lwa_upload_txt-matkl
        matnr = lwa_upload_txt-matnr
        maktx = lwa_upload_txt-maktx
        menge = lwa_upload_txt-menge
        meins = lwa_upload_txt-meins
        lgort = lwa_upload_txt-lgort
        ).

      APPEND lwa_upload TO gt_upload.
    ENDLOOP.
  ENDIF.

ENDFORM.


FORM f_get_path.
  DATA:
    lt_file   TYPE filetable,
    lv_action TYPE i,
    lv_rc     TYPE i.

  cl_gui_frontend_services=>file_open_dialog(
    EXPORTING
      default_extension = 'xlsx'
      file_filter = '*.xlsx'
      window_title = 'Open Counted Stock File'
    CHANGING
      file_table = lt_file
      rc = lv_rc
      user_action = lv_action ).

  CHECK lt_file IS NOT INITIAL.

  p_path = lt_file[ 1 ]-filename.

ENDFORM.


FORM f_select.
  DATA lwa_result TYPE gty_result.
  DATA lv_matnr TYPE matnr18.

  LOOP AT gt_upload INTO DATA(lwa_upload).
    MOVE-CORRESPONDING lwa_upload TO lwa_result.
    lv_matnr = |{ lwa_result-matnr ALPHA = IN }|.
    lwa_result-budat = p_budat.
    lwa_result-matnr = lv_matnr.
    lwa_result-werks = p_werks.
    lwa_result-lgort = p_lgort.
    lwa_result-kostl = p_kostl.
    lwa_result-counted_qty = lwa_upload-menge.
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        input          = lwa_upload-meins
      IMPORTING
        output         = lwa_result-counted_uom
      EXCEPTIONS
        unit_not_found = 1
        OTHERS         = 2.

    IF sy-subrc <> 0.
      lwa_result-error = 'Unit not found'.
    ENDIF.

    APPEND lwa_result TO gt_result.
  ENDLOOP.
ENDFORM.


FORM f_alv_status_set USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'STANDARD' EXCLUDING rt_extab..
ENDFORM.


FORM f_alv_user_command  USING r_ucomm LIKE sy-ucomm
                         rs_selfield TYPE slis_selfield.
  DATA lv_error TYPE flag.

  CASE r_ucomm.
    WHEN 'POST'.
      READ TABLE gt_result WITH KEY sele = abap_true TRANSPORTING NO FIELDS.
      IF sy-subrc EQ 0.
        PERFORM f_stock_movement CHANGING lv_error.
        IF lv_error = abap_false.
          PERFORM f_preprocess.
          PERFORM f_process.
        ENDIF.

      ELSE.
        MESSAGE 'Please select a line' TYPE 'E'.
      ENDIF.

      rs_selfield-refresh = abap_true.
      PERFORM f_alv_col_resize.

    WHEN 'LOG'.
      PERFORM f_save_log.
  ENDCASE.
ENDFORM.


FORM f_alv_col_resize.
  DATA: l_grid(33),

  ls_layout TYPE lvc_s_layo.
  FIELD-SYMBOLS <fs_grid> TYPE REF TO cl_gui_alv_grid.
  UNASSIGN <fs_grid>.

  l_grid = '(SAPLSLVC_FULLSCREEN)GT_GRID-GRID'.
  ASSIGN (l_grid) TO <fs_grid>.

  IF <fs_grid> IS ASSIGNED.
    CLEAR ls_layout.
    CALL METHOD <fs_grid>->get_frontend_layout
      IMPORTING
        es_layout = ls_layout.

    IF sy-subrc EQ 0.
      ls_layout-cwidth_opt = 'X'.
      CALL METHOD <fs_grid>->set_frontend_layout
        EXPORTING
          is_layout = ls_layout.
    ENDIF.
  ENDIF.

ENDFORM.


FORM f_save_log.
  DATA:
    lv_fullpath TYPE string,
    lv_file     TYPE string,
    lv_path     TYPE string,
    lv_action   TYPE i.

  cl_gui_frontend_services=>file_save_dialog(
    EXPORTING
      default_extension = 'xlsx'
    CHANGING
      filename = lv_file
      path = lv_path
      fullpath = lv_fullpath
      user_action = lv_action ).

  CHECK lv_action = cl_gui_frontend_services=>action_ok.

  DATA:
    lt_error  TYPE STANDARD TABLE OF zmm_stock_count,
    lwa_error TYPE zmm_stock_count.

  LOOP AT gt_result INTO DATA(lwa_result) WHERE error IS NOT INITIAL.
    MOVE-CORRESPONDING lwa_result TO lwa_error.
    APPEND lwa_error TO lt_error.
  ENDLOOP.

  cl_gui_frontend_services=>gui_download(
    EXPORTING
      filename = lv_fullpath
      write_field_separator = abap_true
    CHANGING
      data_tab = lt_error ).

  IF sy-subrc EQ 0.
    MESSAGE |Saved to { lv_fullpath }| TYPE 'S'.
  ELSE.
    MESSAGE |Can't save to { lv_fullpath }| TYPE 'S'.
  ENDIF.
ENDFORM.


FORM f_display.
  DATA lwa_layout TYPE slis_layout_alv.
  lwa_layout-colwidth_optimize = abap_true.
  lwa_layout-zebra = abap_true.
  lwa_layout-box_fieldname = 'SELE'.

  DATA lt_fieldcat TYPE slis_t_fieldcat_alv.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'ZMM_STOCK_COUNT'
    CHANGING
      ct_fieldcat      = lt_fieldcat.

  LOOP AT lt_fieldcat ASSIGNING FIELD-SYMBOL(<ls_waste_qty>).
    CASE <ls_waste_qty>-fieldname.
      WHEN 'BOOK_UOM'.
        <ls_waste_qty>-seltext_l = 'Book Unit of Measure'.
        <ls_waste_qty>-reptext_ddic = 'Book Unit of Measure'.

      WHEN 'COUNTED_UOM'.
        IF p_waste EQ abap_true.
          <ls_waste_qty>-seltext_l = 'Wastage Unit of Measure'.
          <ls_waste_qty>-reptext_ddic = 'Wastage Unit of Measure'.

        ELSE.
          <ls_waste_qty>-seltext_l = 'Counted Unit of Measure'.
          <ls_waste_qty>-reptext_ddic = 'Counted Unit of Measure'.

        ENDIF.

      WHEN 'COUNTED_QTY'.
        IF p_waste EQ abap_true.
          DELETE lt_fieldcat INDEX sy-tabix.
        ENDIF.

      WHEN 'DIFFERENCE_QTY'.
        IF p_waste EQ abap_true.
          <ls_waste_qty>-seltext_s = <ls_waste_qty>-seltext_m = <ls_waste_qty>-seltext_l = 'Wastage'.
          <ls_waste_qty>-reptext_ddic = 'Wastage Quantity'.
        ENDIF.

      WHEN 'DIFFERENCE_AMT'.
        IF p_waste EQ abap_true.
          <ls_waste_qty>-seltext_s = 'W. Value'.
          <ls_waste_qty>-seltext_m = <ls_waste_qty>-seltext_l = 'Wastage Value'.
          <ls_waste_qty>-reptext_ddic = 'Wastage Value'.
        ENDIF.
    ENDCASE.
  ENDLOOP.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-cprog
      i_callback_pf_status_set = 'F_ALV_STATUS_SET'
      i_callback_user_command  = 'F_ALV_USER_COMMAND'
      is_layout                = lwa_layout
      it_fieldcat              = lt_fieldcat
    TABLES
      t_outtab                 = gt_result.

ENDFORM.


FORM f_stock_movement CHANGING fc_error TYPE flag.

  DATA: ls_mmdochdr LIKE bapi2017_gm_head_01,
        lt_gm       TYPE STANDARD TABLE OF bapi2017_gm_item_create,
        ls_gm       LIKE bapi2017_gm_item_create,
        lt_ret      TYPE STANDARD TABLE OF bapiret2,
        ls_ret      LIKE bapiret2,
        ls_hdr      LIKE bapi2017_gm_head_ret,
        ls_ser      LIKE bapi2017_gm_serialnumber,
        lt_ser      LIKE  STANDARD TABLE OF bapi2017_gm_serialnumber.

* Prepare Data for Goods Movement
  ls_mmdochdr-pstng_date = p_budat.
  ls_mmdochdr-doc_date = sy-datum.

  LOOP AT gt_result INTO DATA(lwa_result) WHERE difference_qty <> 0 AND error IS INITIAL AND sele = abap_true.
    ls_gm-move_type = lwa_result-bwart .
    ls_gm-material = lwa_result-matnr.
    ls_gm-plant = lwa_result-werks.
    ls_gm-stge_loc = lwa_result-lgort.
    ls_gm-entry_qnt = abs( lwa_result-difference_qty ).
    ls_gm-costcenter = lwa_result-kostl.
    IF p_waste EQ abap_true.
      ls_gm-move_reas = gc_move_reas.
    ENDIF.
    APPEND ls_gm TO lt_gm.
    CLEAR ls_gm.
  ENDLOOP.

* Call BAPI
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      goodsmvt_header  = ls_mmdochdr
      goodsmvt_code    = '03'
    IMPORTING
      goodsmvt_headret = ls_hdr
    TABLES
      goodsmvt_item    = lt_gm
      return           = lt_ret.

  IF lt_ret IS INITIAL.
    MESSAGE |Material Document posted: { ls_hdr-mat_doc } { ls_hdr-doc_year }| TYPE 'S'.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' EXPORTING wait = 'X'.
    fc_error = abap_false.

    IF p_waste EQ abap_true.
      LOOP AT gt_result ASSIGNING FIELD-SYMBOL(<lwa_result>) WHERE difference_qty <> 0 AND error IS INITIAL AND sele = abap_true.
        <lwa_result>-counted_qty = 0.
      ENDLOOP.
    ENDIF.

  ELSE.
    DATA lv_message TYPE string.
    fc_error = abap_true.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    lv_message = 'Error during posting Material document:'.

    IF lt_ret IS NOT INITIAL.
      LOOP AT lt_ret INTO DATA(lwa_ret) ."WHERE type = 'E'.
        lv_message = lv_message && lwa_ret-message.
        EXIT.
      ENDLOOP.
    ENDIF.
    MESSAGE lv_message TYPE 'E'.
  ENDIF.

ENDFORM.
