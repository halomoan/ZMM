*&---------------------------------------------------------------------*
*&  Include           ZMMRGB_0009_TOP
*&---------------------------------------------------------------------*
TABLES: eban,
        tline.

TYPES: BEGIN OF ty_output,
         banfn TYPE banfn,
         bnfpo TYPE bnfpo,
         ernam TYPE ernam,
         erdat TYPE aedat,
         werks TYPE ewerk,
         statx TYPE val_text,
         txz01 TYPE txz01,
         ekgrp TYPE ekgrp,
         aseid TYPE tdline,
       END OF ty_output,

       BEGIN OF ty_eban,
         banfn TYPE banfn,
         bnfpo TYPE bnfpo,
         ernam TYPE ernam,
         erdat TYPE aedat,
         werks TYPE ewerk,
         statu TYPE banst,
         txz01 TYPE txz01,
         ekgrp TYPE ekgrp,
         aseid TYPE tdline,
       END OF ty_eban,

       BEGIN OF ty_stxl,
         tdname TYPE stxl-tdname,
         clustr TYPE stxl-clustr,
         clustd TYPE stxl-clustd,
       END OF ty_stxl,

       BEGIN OF ty_stxl_key,
         tdname TYPE stxl-tdname,
       END OF ty_stxl_key,

       BEGIN OF ty_stxl_raw,
         clustr TYPE stxl-clustr,
         clustd TYPE stxl-clustd,
       END OF ty_stxl_raw.

TYPES: ty_t_output   TYPE TABLE OF ty_output,
       ty_t_eban     TYPE TABLE OF ty_eban,
       ty_t_stxl     TYPE TABLE OF ty_stxl,
       ty_t_stxl_key TYPE TABLE OF ty_stxl_key,
       ty_t_stxl_raw TYPE TABLE OF ty_stxl_raw.

DATA: gt_output TYPE ty_t_output,
      gt_eban   TYPE ty_t_eban.

DATA: go_alv       TYPE REF TO cl_salv_table,
      go_column    TYPE REF TO cl_salv_column,
      go_columns   TYPE REF TO cl_salv_columns,
      go_coltab    TYPE REF TO cl_salv_column_table,
      go_colstab   TYPE REF TO cl_salv_columns_table,
      go_functions TYPE REF TO cl_salv_functions,
      go_disp_set  TYPE REF TO cl_salv_display_settings.

CONSTANTS: c_tx   TYPE stxl-relid    VALUE 'TX',
           c_eban	TYPE stxl-tdobject VALUE 'EBAN',
           c_b06  TYPE stxl-tdid     VALUE 'B06',
           c_n    TYPE eban-statu    VALUE 'N'.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-b01.
SELECT-OPTIONS: s_banfn FOR eban-banfn,
                s_aseid FOR tline-tdline,
                s_ernam FOR eban-ernam NO INTERVALS,
                s_erdat FOR eban-erdat,
                s_werks FOR eban-werks.
SELECTION-SCREEN END OF BLOCK b1.
