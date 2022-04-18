*&---------------------------------------------------------------------*
*&  Include           ZMMIGB_0013_TOP
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* DATA TYPES                                                           *
*----------------------------------------------------------------------*
TYPE-POOLS: sscr, slis, szadr, truxs.

*----------------------------------------------------------------------*
* TABLES                                                               *
*----------------------------------------------------------------------*
TABLES: ekko, ekpo, lfa1, t100.

*----------------------------------------------------------------------*
* I N T E R N A L   T A B L E S
*----------------------------------------------------------------------*
types:
BEGIN OF ty_data,
  ebeln TYPE ebeln,
  ebelp TYPE ebelp,
  lifnr TYPE lifnr,
  name1 TYPE name1,
  name2 TYPE name1,
  waers TYPE ekko-waers,
  loekz TYPE ekpo-loekz,
  statu TYPE ekpo-statu,
  matnr TYPE matnr,
  txz01 TYPE char40,
  KTMNG TYPE ktmng,
  meins TYPE meins,
  KNUMV TYPE EKKO-KNUMV,
  spinf TYPE ekpo-spinf,
  idnlf TYPE idnlf,
  mwskz TYPE mwskz,
END OF ty_data,
BEGIN OF ty_final,
  lifnr TYPE lifnr,
  ebeln TYPE ebeln,
  ebelp TYPE EBELP,
  name1 TYPE char72,
  matnr type matnr,
  txz01 TYPE txz01,
  ktmng TYPE EKPO-KTMNG,
  meins TYPE EKPO-MEINS,
  gross TYPE HWSTE,
  disco TYPE HWSTE,
  abdis TYPE HWSTE,
  waers TYPE waers,
  kpein TYPE konp-kpein,
  kmein TYPE konp-kmein,
  validfrom TYPE datum,
  validto TYPE datum,
  spinf TYPE char10,
  idnlf TYPE idnlf,
  mwskz TYPE mwskz,
END OF ty_final,
begin of ty_up_split,
  lifnr TYPE lifnr,
  name1 TYPE char72,
  ebeln TYPE ebeln,
  ebelp TYPE EBELP,
  matnr type matnr,
  txz01 TYPE txz01,
  ktmng TYPE char20,
  meins TYPE char03,
  gross TYPE char20,
  disco TYPE char20,
  abdis TYPE char20,
  waers TYPE char05,
  kpein TYPE char05,
  kmein TYPE char05,
  validfrom TYPE char10,
  validto TYPE char10,
  spinf TYPE char10,
  idnlf TYPE idnlf,
  mwskz TYPE mwskz,
  text01 type TDLINE,
  text02 type TDLINE,
  text03 type TDLINE,
  text04 type TDLINE,
  text05 type TDLINE,
  text06 type TDLINE,
  text07 type TDLINE,
  text08 type TDLINE,
  text09 type TDLINE,
  text10 type TDLINE,
  text11 type TDLINE,
  text12 type TDLINE,
  text13 type TDLINE,
  text14 type TDLINE,
  text15 type TDLINE,
  text16 type TDLINE,
  text17 type TDLINE,
  text18 type TDLINE,
  text19 type TDLINE,
  text20 type TDLINE,
END OF ty_up_split,
begin of ty_upload,
  ebeln TYPE ebeln,
  ebelp TYPE EBELP,
  lifnr TYPE lifnr,
  name1 TYPE char72,
  matnr type matnr,
  txz01 TYPE txz01,
  ktmng TYPE char20,
  meins TYPE char03,
  gross TYPE char20,
  disco TYPE char20,
  abdis TYPE char20,
  waers TYPE char05,
  kpein TYPE char05,
  kmein TYPE char05,
  validfrom TYPE char10,
  validto TYPE char10,
  spinf TYPE char10,
  idnlf TYPE idnlf,
  mwskz TYPE mwskz,
  text01 type TDLINE,
  text02 type TDLINE,
  text03 type TDLINE,
  text04 type TDLINE,
  text05 type TDLINE,
  text06 type TDLINE,
  text07 type TDLINE,
  text08 type TDLINE,
  text09 type TDLINE,
  text10 type TDLINE,
  text11 type TDLINE,
  text12 type TDLINE,
  text13 type TDLINE,
  text14 type TDLINE,
  text15 type TDLINE,
  text16 type TDLINE,
  text17 type TDLINE,
  text18 type TDLINE,
  text19 type TDLINE,
  text20 type TDLINE,
END OF ty_upload,
BEGIN OF TY_RESULT,
  ebeln TYPE ekpo-ebeln,
  ebelp TYPE ekpo-ebelp,
  spinf TYPE ekpo-spinf,
  remark(72) TYPE c,
END OF TY_RESULT.

DATA:
it_lines TYPE tline occurs 0 with header line,
it_lfa1 TYPE STANDARD TABLE OF lfa1,
it_a016 TYPE STANDARD TABLE OF a016,
it_konp TYPE STANDARD TABLE OF konp,
it_data TYPE STANDARD TABLE OF ty_data,
it_final TYPE STANDARD TABLE OF ty_final,
it_result TYPE STANDARD TABLE OF ty_result,
it_upload TYPE STANDARD TABLE OF ty_upload,
it_up_split TYPE STANDARD TABLE OF ty_up_split.

DATA:
wa_lfa1 TYPE lfa1,
wa_a016 TYPE a016,
wa_konp TYPE konp,
wa_data TYPE ty_data,
wa_final TYPE ty_final,
wa_result TYPE ty_result,
wa_upload TYPE ty_upload,
wa_upslit TYPE ty_upload,
wa_up_split TYPE ty_up_split.

DATA:
begin of it_head occurs 0,
  Filed1(20) type c,                     " Header Data
end of it_head.

data: li_return_error like BAPIRET2   OCCURS 0 with header line,
      I_RETURN        LIKE BAPIRETURN OCCURS 0 WITH HEADER LINE,
      V_MSG,
      V_MSG_ME47.

*       Batchinputdata of single transaction
DATA:   BDCDATA LIKE BDCDATA    OCCURS 0 WITH HEADER LINE.
*       messages of call transaction
DATA:   MESSTAB LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE.
*       error session opened (' ' or 'X')
DATA:   E_GROUP_OPENED.
*       message texts


Data: SESSION,
      SMALLLOG,
*       CTUMODE LIKE CTU_PARAMS-DISMODE value 'A', "E - DISPLAY ERROR ONLY
      CTUMODE LIKE CTU_PARAMS-DISMODE value 'N',  "N - Processing without display of screens
*       CUPDATE LIKE CTU_PARAMS-UPDMODE value 'L', "Local update.
*       CUPDATE LIKE CTU_PARAMS-UPDMODE value 'A', "Asynchronous.
      CUPDATE LIKE CTU_PARAMS-UPDMODE value 'S',  "Synchronous processing.
      E_GROUP(12),
      NODATA value ' '.

FIELD-SYMBOLS: <f_upload> TYPE ty_upload.

*----------------------------------------------------------------------*
* R A N G E S
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* CONSTANTS                                                            *
*----------------------------------------------------------------------*
CONSTANTS:
c_id TYPE THEAD-TDID VALUE 'A01',
c_object TYPE THEAD-TDOBJECT vALUE 'EKPO',
c_x TYPE c VALUE 'X',
c_9999 TYPE datum VALUE '99991231',
c_date TYPE makt-maktx VALUE 'Please check valid from or valid to',
C_A TYPE EKKO-BSTYP VALUE 'A'.

*----------------------------------------------------------------------*
* DATA OBJECTS                                                         *
*----------------------------------------------------------------------*
DATA:
g_error TYPE c,
g_noaccess TYPE c.

data: gt_fldcat type slis_t_fieldcat_alv,
      gt_sortab type slis_t_sortinfo_alv,
      gt_events type slis_t_event,
      gs_layout     type slis_layout_alv,
      gs_setting type lvc_s_glay.

data: gt_ret type standard table of ddshretval,
      gs_ret type ddshretval.
