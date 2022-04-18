*&---------------------------------------------------------------------*
*&  Include           ZMMRGB_0009_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_INITIALIZE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_initialize .
  DATA: it_tvarvc TYPE STANDARD TABLE OF tvarvc.

  FIELD-SYMBOLS: <fs_tvarvc> TYPE tvarvc.
  REFRESH: it_tvarvc.

  SELECT * INTO TABLE it_tvarvc
    FROM tvarvc
    WHERE name = 'ZMM0009_DATE_CUTOVER'.
  IF NOT it_tvarvc[] IS INITIAL.
    READ TABLE it_tvarvc ASSIGNING <fs_tvarvc> INDEX 1.
    s_erdat-sign = 'I'.
    s_erdat-option = 'EQ'.
    s_erdat-low = <fs_tvarvc>-low.
    APPEND s_erdat.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_INITIALIZE_ITAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_initialize_itab .
  REFRESH: gt_output.
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
  SELECT banfn
         bnfpo
         ernam
         erdat
         werks
         statu
         txz01
         ekgrp
         INTO TABLE gt_eban
         FROM eban
         WHERE banfn IN s_banfn
           AND erdat IN s_erdat
           AND ernam IN s_ernam
           AND werks IN s_werks
           AND statu EQ c_n.
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
  DATA: lv_tdname   TYPE thead-tdname,
        lt_stxl     TYPE ty_t_stxl,
        lt_stxl_key TYPE ty_t_stxl_key,
        lt_stxl_raw TYPE ty_t_stxl_raw,
        lt_tline    TYPE TABLE OF tline,
        lv_match    TYPE flag.

  FIELD-SYMBOLS: <fs_output>   TYPE ty_output,
                 <fs_eban>     TYPE ty_eban,
                 <fs_stxl>     TYPE ty_stxl,
                 <fs_stxl_key> TYPE ty_stxl_key,
                 <fs_stxl_raw> TYPE ty_stxl_raw,
                 <fs_tline>    TYPE tline.

  UNASSIGN <fs_eban>.
  LOOP AT gt_eban ASSIGNING <fs_eban>.
    APPEND INITIAL LINE TO lt_stxl_key ASSIGNING <fs_stxl_key>.
    <fs_stxl_key>-tdname =  <fs_eban>-banfn && <fs_eban>-bnfpo.
    UNASSIGN <fs_stxl_key>.
  ENDLOOP.

  IF NOT lt_stxl_key[] IS INITIAL.
    SELECT tdname
           clustr
           clustd
           INTO TABLE lt_stxl
           FROM stxl
           FOR ALL ENTRIES IN lt_stxl_key
           WHERE relid    EQ c_tx
           AND   tdobject EQ c_eban
           AND   tdname   EQ lt_stxl_key-tdname
           AND   tdid     EQ c_b06.
  ENDIF.

  UNASSIGN: <fs_output>,
            <fs_eban>.
  LOOP AT gt_eban ASSIGNING <fs_eban>.
    REFRESH: lt_stxl_raw, lt_tline.
    CLEAR: lv_tdname, lv_match.

    lv_tdname = <fs_eban>-banfn && <fs_eban>-bnfpo.

    READ TABLE lt_stxl TRANSPORTING NO FIELDS
                       WITH KEY tdname = lv_tdname.
    IF sy-subrc = 0.
      UNASSIGN: <fs_stxl>, <fs_stxl_raw>.

      LOOP AT lt_stxl ASSIGNING <fs_stxl> FROM sy-tabix WHERE tdname EQ lv_tdname.
        APPEND INITIAL LINE TO lt_stxl_raw ASSIGNING <fs_stxl_raw>.
        <fs_stxl_raw>-clustr = <fs_stxl>-clustr.
        <fs_stxl_raw>-clustd = <fs_stxl>-clustd.
        UNASSIGN <fs_stxl_raw>.
      ENDLOOP.

      IMPORT tline = lt_tline FROM INTERNAL TABLE lt_stxl_raw.
    ENDIF.

    UNASSIGN <fs_tline>.
    LOOP AT lt_tline ASSIGNING <fs_tline>.
      <fs_eban>-aseid = <fs_tline>-tdline.
      IF <fs_tline>-tdline IN s_aseid.
        lv_match = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF NOT s_aseid[] IS INITIAL.
      IF lv_match EQ abap_false.
        DELETE gt_eban.
        CONTINUE.
      ENDIF.
    ENDIF.

    APPEND INITIAL LINE TO gt_output ASSIGNING <fs_output>.
    MOVE-CORRESPONDING <fs_eban> TO <fs_output>.
    CASE <fs_eban>-statu.
      WHEN 'N'.	<fs_output>-statx = 'Not edited'.
      WHEN 'B'. <fs_output>-statx = 'PO created'.
      WHEN 'A'. <fs_output>-statx = 'RFQ created'.
      WHEN 'K'. <fs_output>-statx = 'Contract created'.
      WHEN 'L'. <fs_output>-statx = 'Scheduling agreement created'.
      WHEN 'S'. <fs_output>-statx = 'Service entry sheet created'.
      WHEN 'E'. <fs_output>-statx = 'RFQ sent to external system for sourcing'.
    ENDCASE.
    UNASSIGN <fs_output>.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_display_alv .
  IF NOT gt_output[] IS INITIAL.
    cl_salv_table=>factory(
      IMPORTING
        r_salv_table   = go_alv
      CHANGING
        t_table        = gt_output ).

    go_columns = go_alv->get_columns( ).
    PERFORM f_set_columns:
      USING 'BANFN' 'PR Number'(m01),
      USING 'BNFPO' 'PR Item'(m02),
      USING 'ERNAM' 'Created By'(m03),
      USING 'ERDAT' 'Creation Date'(m04),
      USING 'WERKS' 'Plant'(m06),
      USING 'STATX' 'Status of PR'(m07),
      USING 'TXZ01' 'Description'(m08),
      USING 'EKGRP' 'Purchasing Group'(m09),
      USING 'ASEID' 'Ariba Event ID'(m05).

    go_colstab = go_alv->get_columns( ).
    go_colstab->set_optimize( abap_true ).

    go_functions = go_alv->get_functions( ).
    go_functions->set_all( abap_true ).

    go_disp_set = go_alv->get_display_settings( ).
    go_disp_set->set_striped_pattern( abap_true ).

    go_alv->display( ).
  ELSE.
    MESSAGE s255(oiucm).
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_SET_COLUMNS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0214   text
*      -->P_0215   text
*----------------------------------------------------------------------*
FORM f_set_columns  USING p_column
                          p_long.
  TRY.
      go_column = go_columns->get_column( p_column ).
      go_column->set_short_text( '' ).
      go_column->set_medium_text( '' ).
      go_column->set_long_text( p_long ).
    CATCH cx_salv_not_found.
  ENDTRY.
ENDFORM.
