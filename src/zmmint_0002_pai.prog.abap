*&---------------------------------------------------------------------*
*&  Include           ZMMINT_0002_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9100 INPUT.
  okcode = sy-ucomm.
  CLEAR sy-ucomm.
  CASE okcode.
    WHEN 'BACK' OR 'CANCEL'.
      LEAVE PROGRAM.
    WHEN 'EXTRACT'.
      PERFORM: f_get_data.
    WHEN 'CREATE'.
      PERFORM: f_process_data,
               f_log_transaction,
               f_display_message_log.
    WHEN 'LOG'.
      PERFORM: f_display_message_log.
    WHEN 'SALL'.
      PERFORM: f_select_all_lines.
    WHEN 'DALL'.
      PERFORM: f_deselect_all_lines.
    WHEN 'ASCEND'.
      PERFORM: f_sort_ascending.
    WHEN 'DECEND'.
      PERFORM: f_sort_descending.
    WHEN OTHERS.
      "Do nothing
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.
  okcode = sy-ucomm.
  CLEAR sy-ucomm.
  CASE okcode.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_AGREEMENT_TYPE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_agreement_type INPUT.
  DATA: lv_name   TYPE vrm_id,
        lt_values TYPE vrm_values,
        ls_values TYPE vrm_value,
        lt_t161   TYPE ty_t_t161,
        ls_t161   TYPE ty_t161.

  REFRESH: lt_t161, lt_values.
  SELECT a~bsart b~batxt INTO TABLE lt_t161
    FROM t161 AS a
    INNER JOIN t161t AS b
    ON a~bsart EQ b~bsart
    WHERE a~bstyp EQ 'K'
      AND b~spras EQ sy-langu.

  lv_name = 'P_EVART'.
  LOOP AT lt_t161 INTO ls_t161.
    ls_values-key = ls_t161-bsart.
    ls_values-text = ls_t161-batxt.
    APPEND ls_values TO lt_values.
    CLEAR ls_values.
  ENDLOOP.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = lv_name
      values = lt_values.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_DIRECTORY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_directory INPUT.
  DATA: lt_files TYPE filetable,
        ls_file  TYPE file_table,
        lv_rc    TYPE i.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = 'Please select File'
      file_filter             = cl_gui_frontend_services=>filetype_excel
    CHANGING
      file_table              = lt_files
      rc                      = lv_rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    READ TABLE lt_files INTO ls_file INDEX 1.
    IF sy-subrc EQ 0.
      p_filename = ls_file-filename.
    ENDIF.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GT_ITEM_MODIFY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE gt_item_modify INPUT.
  MODIFY gt_item FROM gs_item
  INDEX tc9100-current_line.
  CLEAR gs_item.
ENDMODULE.
