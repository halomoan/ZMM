*&---------------------------------------------------------------------*
*& Include          ZMM_ME01_VL_UPDATE_TOP
*&---------------------------------------------------------------------*



*&---------------------------------------------------------------------*
*&       SELECTION-SCREEN                                              *
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE TEXT-002.

PARAMETERS:
  p_file  TYPE string LOWER CASE.
PARAMETERS:
  rb_xlsx TYPE flag RADIOBUTTON GROUP a1 DEFAULT 'X' USER-COMMAND zfile,
  rb_csv  TYPE flag RADIOBUTTON GROUP a1.
PARAMETERS cb_whdr AS CHECKBOX DEFAULT 'X' .

SELECTION-SCREEN END OF BLOCK blk1.

SELECTION-SCREEN BEGIN OF BLOCK blk2 WITH FRAME TITLE TEXT-003.
PARAMETERS:
  cb_test TYPE flag AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK blk2.



*______________________________________________________________________*
*&---------------------------------------------------------------------*
*&      LCL_DATA DEFINITION                                            *
*&_____________________________________________________________________*
*&---------------------------------------------------------------------*
CLASS lcl_data DEFINITION FINAL.
*______________________________________________________________________*
*&      PUBLIC INSTANCE METHODS
*______________________________________________________________________*

  PUBLIC SECTION.

*   CONSTANT DECLARATIONS
    CONSTANTS:
      BEGIN OF gc_stat,
        pass TYPE bapi_mtype VALUE 'S',
        fail TYPE bapi_mtype VALUE 'E',
      END OF gc_stat,

      BEGIN OF cc_type,
        date     TYPE char1 VALUE 'D',
        ext_xls  TYPE char4 VALUE 'XLS',
        ext_xlsx TYPE char4 VALUE 'XLSX',
        ext_csv  TYPE char4 VALUE 'CSV',
        ext_txt  TYPE char4 VALUE 'TXT',
      END OF cc_type .


*   DATA DECLARATIONS
    TYPES:
      BEGIN OF ty_file,
        ekorg  TYPE string,
        werks  TYPE string,
        matnr  TYPE string,
        maktx  TYPE string,
        lifnr  TYPE string,
        lifnrx TYPE string,
        meins  TYPE string,
        vdatu  TYPE string,
        bdatu  TYPE string,
        flifn  TYPE string,
        tmp    TYPE string,
      END OF ty_file,
      tt_file TYPE TABLE OF ty_file WITH DEFAULT KEY,

      BEGIN OF ty_result,
        status  TYPE icon-id, "ICON_GREEN_LIGHT/ICON_RED_LIGHT
        message TYPE bapi_msg,
        ekorg   TYPE eord-ekorg,
        werks   TYPE eord-werks,
        matnr   TYPE eord-matnr,
        maktx   TYPE makt-maktx,
        lifnr   TYPE eord-lifnr,
        lifnrx  TYPE lfa1-name1,
        meins   TYPE eord-meins,
        vdatu   TYPE eord-vdatu,
        bdatu   TYPE eord-bdatu,
        flifn   TYPE eord-flifn,
      END OF ty_result,
      tt_result TYPE TABLE OF ty_result WITH DEFAULT KEY,

      BEGIN OF ty_alsmex_tline,
        row   TYPE kcd_ex_row_n,
        col   TYPE kcd_ex_col_n,
        value TYPE text1024,
      END OF ty_alsmex_tline,
      tt_intern TYPE TABLE OF ty_alsmex_tline WITH DEFAULT KEY.



    DATA:
      t_result     TYPE TABLE OF ty_result WITH DEFAULT KEY.


*   METHODS DECLARATIONS
    METHODS:
      constructor,

      f4_filename IMPORTING iv_xlsx            TYPE abap_bool OPTIONAL
                  RETURNING VALUE(rv_filename) TYPE string,

      begin_process,

      upload_data     IMPORTING iv_filename    TYPE string
                      RETURNING VALUE(rv_data) TYPE tt_result,

      data_massage    IMPORTING cv_file        TYPE tt_file
                      RETURNING VALUE(rv_data) TYPE tt_result,

      update_source_list CHANGING cv_data TYPE tt_result,

      view            IMPORTING iv_data         TYPE tt_result.


  PRIVATE SECTION.
    METHODS:
      upload_csv_file IMPORTING iv_filename    TYPE string
                      RETURNING VALUE(cv_file) TYPE tt_file,

      upload_xls_file IMPORTING iv_filename    TYPE string
                      RETURNING VALUE(cv_file) TYPE tt_file,

      get_date_format RETURNING VALUE(rv_dtfm) TYPE string,

      alv_out         CHANGING iv_out_tab TYPE ANY TABLE,

      set_alv_fields  CHANGING co_columns TYPE REF TO cl_salv_columns_table.


ENDCLASS.
