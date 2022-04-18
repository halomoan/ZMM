*&---------------------------------------------------------------------*
*&  Include           YMMCGB_0001_GLOBAL_DATA
*&---------------------------------------------------------------------*

TYPE-POOLS: slis.

DATA: BEGIN OF it_upload OCCURS 0,
          bednr  TYPE bednr,
          lifnr TYPE lifnr,
          bsart TYPE bsart,
          bedat(10) TYPE c,
          ekorg(4)  TYPE c,
          ekgrp(3) TYPE c,
          bukrs(4),
          wkurs(15) TYPE c,
          kdatb(10) TYPE c,
          kdate(10) TYPE c,
          ktwrt(18) TYPE c,
          zterm(4) TYPE c,
          inco1 TYPE inco1,
          waers(5) TYPE c,
          knttp TYPE knttp,
          matnr TYPE matnr,
          maktx TYPE maktx,
          txz01 TYPE txz01,
          menge(18) TYPE c,
          meins(3) TYPE c,
          netpr(15),
          peinh(5),
          matkl TYPE matkl,
          werks TYPE werks_d,
          wempf TYPE wempf,
          feskz TYPE feskz,
*          name1 TYPE name1_gp,
        END OF it_upload,
*        it_process LIKE it_upload OCCURS 0 WITH HEADER LINE,
        BEGIN OF it_process OCCURS 0.
        INCLUDE STRUCTURE it_upload.
        DATA: line_no LIKE sy-tabix,
        END OF it_process.
        DATA: BEGIN OF it_error OCCURS 0,
          line TYPE syindex,
          bednr TYPE bednr,
          text(220),
        END OF it_error,
        it_message LIKE it_error OCCURS 0 WITH HEADER LINE.

DATA: it_header  TYPE bapimeoutheader,
      it_headerx TYPE bapimeoutheaderx,
      it_vendor  TYPE bapimeoutaddrvendor,
      it_item    LIKE bapimeoutitem OCCURS 0 WITH HEADER LINE,
      it_itemx   TYPE bapimeoutitemx OCCURS 0 WITH HEADER LINE,
      it_account TYPE bapimeoutaccount OCCURS 0 WITH HEADER LINE,
      it_return  TYPE bapiret2 OCCURS 0 WITH HEADER LINE,
      it_fieldcat TYPE slis_t_fieldcat_alv WITH HEADER LINE.

CONSTANTS: c_valuex VALUE 'X',
           c_itemno TYPE ebelp VALUE '00000',
           c_knttp VALUE 'U'.
