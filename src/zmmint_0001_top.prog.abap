*&---------------------------------------------------------------------*
*&  Include           ZMMINT_ARIBA_TOP
*&---------------------------------------------------------------------*
TYPES: BEGIN OF ty_item,
         mark  TYPE c,
         ebeln TYPE ebeln,
         lifnr TYPE elifn,
         ekorg TYPE ekorg,
         ekgrp TYPE bkgrp,
         waers TYPE waers,
         ebelp TYPE ebelp,
         matnr TYPE matnr,
         bukrs TYPE bukrs,
         werks TYPE ewerk,
         ktmng TYPE ktmng,
         menge TYPE bstmg,
         meins TYPE bstme,
         netpr TYPE bwert,
         matkl TYPE matkl,
         mtart TYPE mtart,
         maktx TYPE maktx,
       END OF ty_item.

TYPES: BEGIN OF ty_ekko,
         ebeln TYPE ebeln,
         bstyp TYPE ebstyp,
         aedat TYPE erdat,
         ernam TYPE ernam,
         lifnr TYPE elifn,
         ekorg TYPE ekorg,
         ekgrp TYPE bkgrp,
         waers TYPE waers,
       END OF ty_ekko.

TYPES: BEGIN OF ty_ekpo,
         ebeln TYPE ebeln,
         ebelp TYPE ebelp,
         txz01 TYPE txz01,
         matnr TYPE matnr,
         bukrs TYPE bukrs,
         werks TYPE ewerk,
         ktmng TYPE ktmng,
         menge TYPE bstmg,
         meins TYPE bstme,
         netpr TYPE bwert,
         matkl TYPE matkl,
         mtart TYPE mtart,
       END OF ty_ekpo.

TYPES: BEGIN OF ty_makt,
         matnr TYPE matnr,
         maktx TYPE maktx,
       END OF ty_makt.

TYPES: BEGIN OF ty_excel,
         cola1  TYPE text1000,
         colb1  TYPE text1000,
         colc1  TYPE text1000,
         cold1  TYPE text1000,
         cole1  TYPE text1000,
         colf1  TYPE text1000,
         colg1  TYPE text1000,
         colh1  TYPE text1000,
         coli1  TYPE text1000,
         colj1  TYPE text1000,
         colk1  TYPE text1000,
         coll1  TYPE text1000,
         colm1  TYPE text1000,
         coln1  TYPE text1000,
         colo1  TYPE text1000,
         colp1  TYPE text1000,
         colq1  TYPE text1000,
         colr1  TYPE text1000,
         cols1  TYPE text1000,
         colt1  TYPE text1000,
         colu1  TYPE text1000,
         colv1  TYPE text1000,
         colw1  TYPE text1000,
         colx1  TYPE text1000,
         coly1  TYPE text1000,
         colz1  TYPE text1000,
         colaa1 TYPE text1000,
         colab1 TYPE text1000,
         colac1 TYPE text1000,
         colad1 TYPE text1000,
         colae1 TYPE text1000,
         colaf1 TYPE text1000,
         colag1 TYPE text1000,
         colah1 TYPE text1000,
         colai1 TYPE text1000,
         colaj1 TYPE text1000,
         colak1 TYPE text1000,
         colal1 TYPE text1000,
       END OF ty_excel.

TYPES: ty_t_item   TYPE TABLE OF ty_item,
       ty_t_ekko   TYPE TABLE OF ty_ekko,
       ty_t_ekpo   TYPE TABLE OF ty_ekpo,
       ty_t_makt   TYPE TABLE OF ty_makt,
       ty_t_excel  TYPE TABLE OF ty_excel,
       ty_t_string TYPE TABLE OF string.

DATA: gt_item    TYPE ty_t_item,
      gs_item    TYPE ty_item,
      gt_message TYPE ty_t_string,
      gt_pricing TYPE ty_t_excel.

DATA: p_ebeln     TYPE ekko-ebeln,
      p_proj_desc TYPE string,
      p_rfp       TYPE string,
      p_waers     TYPE waers,
      p_ernam     TYPE ekko-ernam,
      p_aedat     TYPE ekko-aedat,
      okcode      TYPE sy-ucomm.

DATA: gv_ariba_sid    TYPE xuvalue,
      gv_workspace_id TYPE string,
      gv_document_id  TYPE string,
      gv_temp_dir     TYPE rlgrap-filename,
      gv_file         TYPE rlgrap-filename.

DATA: go_zipper TYPE REF TO cl_abap_zip,
      gv_zip    TYPE xstring.

CONSTANTS: gc_a            TYPE bstyp VALUE 'A',
           gc_content      TYPE rlgrap-filename VALUE 'Content.csv',
           gc_participants TYPE rlgrap-filename VALUE 'Participants.csv',
           gc_pricing      TYPE rlgrap-filename VALUE 'Pricing.csv',
           gc_rules        TYPE rlgrap-filename VALUE 'Rules.csv',
           gc_terms        TYPE rlgrap-filename VALUE 'Terms.csv',
           gc_comma        TYPE c VALUE ','.

CONTROLS: tc9100 TYPE TABLEVIEW USING SCREEN 9100.
