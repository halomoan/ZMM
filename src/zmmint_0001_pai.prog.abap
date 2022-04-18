*&---------------------------------------------------------------------*
*&  Include           ZMMINT_ARIBA_PAI
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
    WHEN 'CREATE'.
      IF p_ebeln IS INITIAL OR p_rfp IS INITIAL OR p_proj_desc IS INITIAL OR
         p_waers IS INITIAL.
        MESSAGE text-e01 TYPE 'E'.
      ENDIF.
      READ TABLE gt_item TRANSPORTING NO FIELDS
                         WITH KEY mark = abap_true.
      IF sy-subrc NE 0.
        MESSAGE text-e02 TYPE 'E'.
      ENDIF.
      PERFORM: f_init_message,
               f_create_ariba_project,
               f_create_ariba_event,
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
      PERFORM: f_consolidate_data.
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
*&      Module  GT_ITEM_MODIFY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE gt_item_modify INPUT.
  MODIFY gt_item FROM gs_item
  INDEX tc9100-current_line.
  CLEAR gs_item.
ENDMODULE.
