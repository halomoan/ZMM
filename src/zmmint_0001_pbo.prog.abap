*&---------------------------------------------------------------------*
*&  Include           ZMMINT_ARIBA_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_9100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9100 OUTPUT.
  DATA: lt_ucomm TYPE TABLE OF sy-ucomm.
  REFRESH: lt_ucomm.
  IF gt_message[] IS INITIAL.
    APPEND: 'LOG' TO lt_ucomm.
  ENDIF.
  SET PF-STATUS 'S9100' EXCLUDING lt_ucomm IMMEDIATELY.
  SET TITLEBAR 'T9100' WITH text-t01.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  TABLE_LINES_9100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE table_lines_9100 OUTPUT.
  DESCRIBE TABLE gt_item LINES tc9100-lines.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  INITIALIZE_9100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE initialize_9100 OUTPUT.
ENDMODULE.
