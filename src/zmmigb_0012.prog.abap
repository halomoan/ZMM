*&---------------------------------------------------------------------*
*& Report  ZMMIGB_0012
*&
*&---------------------------------------------------------------------*
*& Object name : ZMMC_RFQ
*& Object Type : Convertion
*& Title : Upload RFQ
*& Purpose : Upload RFQ
*&---------------------------------------------------------------------*
*& Author : HH (Deloitte)
*& Date : 16/08/2021
*&---------------------------------------------------------------------*
*& Tracking History
*&---------------------------------------------------------------------*
*& Date        Name      Description                         TR
*&---------------------------------------------------------------------*
*& 16/08/2021  HH Initial creation(Copied ZMMIGB_0009  P30K913844
*&---------------------------------------------------------------------*
REPORT  zmmigb_0012 LINE-SIZE 500.

*&---------------------------------------------------------------------*
*& Data Declarations
*&---------------------------------------------------------------------*

TYPE-POOLS: slis, icon. "abap.

DATA: BEGIN OF ty_rfq,
        ematn(40),
        txz01(40),
        anmng(17),
        meins(3),
        eeind(10),
        idnlf(35),
        lgort(4),
      END OF ty_rfq.

DATA: BEGIN OF ty_log,
        icon(4),
        anfnr   TYPE anfnr,
        msg     TYPE text132,
        anfdt   TYPE anfdt,
        angdt   TYPE angab,
        ekorg   TYPE ekorg,
        bukrs   TYPE bukrs,
        ekgrp   TYPE bkgrp,
        submi   TYPE submi,
        kdatb   TYPE kdatb,
        kdate   TYPE kdate,
        lifnr   TYPE elifn,
        ematn   TYPE ematnr,
        txz01   TYPE txz01,
        anmng   TYPE anmng,
        meins   TYPE bstme,
        uom(3),
        eeind   TYPE eeind,
        idnlf   TYPE idnlf,
        werks   TYPE ewerk,
        lgort   TYPE lgort_d,
      END OF ty_log.

DATA: t_alv_fieldcat            TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      t_alv_event               TYPE slis_t_event WITH HEADER LINE,
      t_events                  TYPE slis_t_event,
      t_alv_isort               TYPE slis_t_sortinfo_alv WITH HEADER LINE,
      t_alv_filter              TYPE slis_t_filter_alv WITH HEADER LINE,
      t_event_exit              TYPE slis_t_event_exit WITH HEADER LINE,
      d_alv_isort               TYPE slis_sortinfo_alv,
      d_alv_variant             TYPE disvariant,
      d_alv_list_scroll         TYPE slis_list_scroll,
      d_alv_sort_postn          TYPE i,
      d_alv_keyinfo             TYPE slis_keyinfo_alv,
      d_alv_fieldcat            TYPE slis_fieldcat_alv,
      d_alv_formname            TYPE slis_formname,
      d_alv_ucomm               TYPE slis_formname,
      d_alv_print               TYPE slis_print_alv,
      d_alv_repid               LIKE sy-repid,
      d_alv_tabix               LIKE sy-tabix,
      d_alv_subrc               LIKE sy-subrc,
      d_alv_screen_start_column TYPE i,
      d_alv_screen_start_line   TYPE i,
      d_alv_screen_end_column   TYPE i,
      d_alv_screen_end_line     TYPE i,
      d_alv_layout              TYPE slis_layout_alv.

DATA: d_layout TYPE slis_layout_alv,
      d_repid  LIKE sy-repid,
      d_print  TYPE slis_print_alv.

DATA: gt_list_top_of_page TYPE slis_t_listheader.

DATA  gt_rfq  LIKE STANDARD TABLE OF ty_rfq.
DATA  gt_log  LIKE STANDARD TABLE OF ty_log.
DATA  gw_rfq  LIKE ty_rfq.
DATA  bdc_tab LIKE bdcdata OCCURS 0 WITH HEADER LINE.
DATA  gv_valid.
DATA  gv_table(4).
DATA  gv_msg TYPE bapi_msg.

RANGES  gr_kschl FOR t685-kschl.


*&---------------------------------------------------------------------*
*& Selection Screen and Parameters
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-b01.
  PARAMETERS: p_bukrs LIKE t001-bukrs, " DEFAULT '1000',
              p_ekorg TYPE ekorg OBLIGATORY, " DEFAULT 'C103',
              p_ekgrp TYPE bkgrp OBLIGATORY, " DEFAULT '012',
              p_werks TYPE ewerk,
              p_anfdt TYPE anfdt OBLIGATORY, " DEFAULT sy-datum,
              p_angdt TYPE angab OBLIGATORY, " DEFAULT '20161015',
              p_submi TYPE submi OBLIGATORY, " DEFAULT 'RFQ_Test1',
              p_kdatb TYPE kdatb OBLIGATORY, " DEFAULT '20161101',
              p_kdate TYPE kdate OBLIGATORY, " DEFAULT '20161231',
              p_lifnr TYPE lifnr OBLIGATORY. " DEFAULT 'VTIC1011'.
SELECTION-SCREEN END OF BLOCK b1.
*SELECTION-SCREEN SKIP.
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-b02.
  PARAMETERS: p_file(128) DEFAULT 'C:\temp\*.xlsx',
              p_mode      LIKE ctu_params-dismode DEFAULT 'N' OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b2.

*&---------------------------------------------------------------------*
* Start of Selection event
*&---------------------------------------------------------------------*
START-OF-SELECTION.
*  PERFORM get_data CHANGING p_file.          "text input
  PERFORM get_excel_data CHANGING p_file.
  PERFORM validate_data TABLES gt_rfq gt_log
                        CHANGING gv_valid.
*                                 gv_msg.
  IF gv_valid = 'X'.
    PERFORM run_bdc.
  ENDIF.
*  PERFORM f_badi_rfq TABLES gt_rfq gt_log.
  PERFORM f_alv TABLES gt_log. "#EC CI_FLDEXT_OK[2215424] P30K910011


INITIALIZATION.
  PERFORM init.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM f4_val_req_fname CHANGING p_file.

*AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
*  CALL METHOD yclacrs_filebrowsertools=>find_filename
*    CHANGING
*      filename = p_file.

AT SELECTION-SCREEN OUTPUT.

AT SELECTION-SCREEN.
  PERFORM pai.




*&---------------------------------------------------------------------*
*&      Form  INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init .

*  m_fill_ranges gr_kschl 'I':
*    gc_zair '',  "PrePd:SIMPack A/Time
*    gc_zc00 '',
*    gc_zcom '',  "PrePd:TUTs Comm
*    gc_zdpt '',  "Promo Disc.-TUT/E-T
*    gc_zmod '',  "Modem
*    gc_zptu '',  "Phys-TUT bundling %
*    gc_zrfg '',  "PrePd:TUTFree A/Time
*    gc_zsic '',  "PrePd:Sim Pack Comm
*    gc_zsim '',  "PrePd:SIM Pack
*    gc_zstu '',  "SIM - TUT fix value
*    gc_ztut '',  "PrePd:TUTs 60/100
*    gc_vkp0 ''.

ENDFORM.                    " INIT


*&---------------------------------------------------------------------*
*&      Form  f_build_event_exit
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_build_event_exit.
  CLEAR t_event_exit.
  t_event_exit-ucomm = '&OUP'.
  t_event_exit-after = 'X'.
  APPEND t_event_exit.

  CLEAR t_event_exit.
  t_event_exit-ucomm = '&ODN'.
  t_event_exit-after = 'X'.
  APPEND t_event_exit.
ENDFORM.                    " f_build_event_exit


*&---------------------------------------------------------------------*
*&      Form  f_clear_alv_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_clear_alv_data.
  CLEAR: t_alv_fieldcat,
         t_alv_event,
         t_events,
         t_alv_isort,
         t_alv_filter,
         t_event_exit,
         d_alv_isort,
         d_alv_variant,
         d_alv_list_scroll,
         d_alv_sort_postn,
         d_alv_keyinfo,
         d_alv_fieldcat,
         d_alv_formname,
         d_alv_ucomm,
         d_alv_print,
         d_alv_repid,
         d_alv_tabix,
         d_alv_subrc,
         d_alv_screen_start_column,
         d_alv_screen_start_line,
         d_alv_screen_end_column,
         d_alv_screen_end_line,
         d_alv_layout,
         d_layout,
         d_repid,
         d_print.

  REFRESH: t_alv_fieldcat,
           t_alv_event,
           t_events,
           t_alv_isort,
           t_alv_filter,
           t_event_exit.

  d_repid = sy-repid.
ENDFORM.                    " f_clear_alv_data

*&---------------------------------------------------------------------*
*&      Form  f4_val_req_fname
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f4_val_req_fname CHANGING fc_file.
  DATA: lv_program_name  LIKE sy-repid,
        lv_dynpro_number LIKE sy-dynnr,
        lv_field_name    LIKE dynpread-fieldname,
        lv_file_name     LIKE ibipparms-path.

  lv_program_name  = sy-repid.
  lv_dynpro_number = sy-dynnr.
  lv_field_name    = 'P_FNAME'.

  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = lv_program_name
      dynpro_number = lv_dynpro_number
      field_name    = lv_field_name
    IMPORTING
      file_name     = lv_file_name.

  fc_file = lv_file_name.
ENDFORM.                    " f4_val_req_fname

*&---------------------------------------------------------------------*
*&      Form  POPULATE_BDC_TAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0283   text
*      -->P_0284   text
*      -->P_0285   text
*----------------------------------------------------------------------*
FORM populate_bdc_tab USING flag var1 var2.
  CLEAR bdc_tab.

  IF flag = 'X'.
    bdc_tab-program = var1.
    bdc_tab-dynpro  = var2.
    bdc_tab-dynbegin = 'X'.
  ELSE.
    bdc_tab-fnam  = var1.
    bdc_tab-fval = var2.
  ENDIF.

  APPEND bdc_tab.
ENDFORM.                    " POPULATE_BDC_TAB


*&---------------------------------------------------------------------*
*&      Form  insert_to_bdc_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_to_bdc_header USING fu_log LIKE ty_log.

  DATA lv_anfdt(10).
  DATA lv_angdt(10).
  DATA lv_eeind(10).
  DATA lv_kdatb(10).
  DATA lv_kdate(10).
  DATA lv_bukrs LIKE t024e-bukrs.

  CONCATENATE fu_log-anfdt+6(2) '.' fu_log-anfdt+4(2) '.' fu_log-anfdt(4) INTO lv_anfdt.
  CONCATENATE fu_log-angdt+6(2) '.' fu_log-angdt+4(2) '.' fu_log-angdt(4) INTO lv_angdt.
*  CONCATENATE fu_log-eeind+6(2) '.' fu_log-eeind+4(2) '.' fu_log-eeind(4) INTO lv_eeind.
  CONCATENATE fu_log-kdatb+6(2) '.' fu_log-kdatb+4(2) '.' fu_log-kdatb(4) INTO lv_kdatb.
  CONCATENATE fu_log-kdate+6(2) '.' fu_log-kdate+4(2) '.' fu_log-kdate(4) INTO lv_kdate.

* header
  PERFORM populate_bdc_tab USING:
    'X' 'SAPMM06E'    '0300',
    ' ' 'BDC_CURSOR'  'RM06E-EEIND',
*    ' ' 'BDC_OKCODE'  '/00',
    ' ' 'RM06E-ASART' 'AN',
    ' ' 'EKKO-SPRAS'  'EN',
    ' ' 'RM06E-ANFDT' lv_anfdt,
    ' ' 'EKKO-ANGDT'  lv_angdt,
    ' ' 'EKKO-EKORG'  fu_log-ekorg,
    ' ' 'EKKO-EKGRP'  fu_log-ekgrp,
*    ' ' 'RM06E-EEIND' lv_eeind,
    ' ' 'RM06E-LPEIN' 'T'.
* Consider Plant being populated by memory!!!
  PERFORM populate_bdc_tab USING:
    ' ' 'RM06E-WERKS' p_werks.

  IF p_werks IS INITIAL.
    PERFORM populate_bdc_tab USING:
      ' ' 'BDC_OKCODE'  '/00'.

    "check purchasing organization has been assigned to company code
    CLEAR lv_bukrs.
    SELECT SINGLE bukrs
      FROM t024e INTO lv_bukrs
      WHERE ekorg = fu_log-ekorg.
    IF lv_bukrs IS INITIAL.
      PERFORM populate_bdc_tab USING:
        'X' 'SAPMM06E'   '0514',
        ' ' 'BDC_CURSOR' 'EKKO-BUKRS',
        ' ' 'BDC_OKCODE' '=ENTE',
        ' ' 'EKKO-BUKRS' fu_log-bukrs.
    ENDIF.

    "From items go to header
    PERFORM populate_bdc_tab USING:
      'X' 'SAPMM06E'   '0320',
      ' ' 'BDC_CURSOR' 'EKPO-EMATN(01)',
      ' ' 'BDC_OKCODE' 'KOPF',
      'X' 'SAPMM06E'   '0301',
      ' ' 'BDC_CURSOR' 'EKKO-KDATE',
      ' ' 'BDC_OKCODE' '/00',
      ' ' 'EKKO-SUBMI' fu_log-submi,
*     ' ' 'EKKO-SPRAS' 'EN',
*     ' ' 'EKKO-UPINC' '1',
*     ' ' 'EKKO-ANGDT' '15.10.2016',
      ' ' 'EKKO-KDATB' lv_kdatb,
      ' ' 'EKKO-KDATE' lv_kdate.

  ELSE.   "P_WERKS is not initial
    "From selection screen go to header
    PERFORM populate_bdc_tab USING:
      ' ' 'RM06E-WERKS' p_werks,
      ' ' 'BDC_OKCODE'  'KOPF',
      'X' 'SAPMM06E'   '0301',
      ' ' 'BDC_CURSOR' 'EKKO-KDATE',
      ' ' 'BDC_OKCODE' '/00',
      ' ' 'EKKO-SUBMI' fu_log-submi,
*     ' ' 'EKKO-SPRAS' 'EN',
*     ' ' 'EKKO-UPINC' '1',
*     ' ' 'EKKO-ANGDT' '15.10.2016',
      ' ' 'EKKO-KDATB' lv_kdatb,
      ' ' 'EKKO-KDATE' lv_kdate.
  ENDIF.

  "vendor
  IF fu_log-lifnr IS NOT INITIAL.
    PERFORM populate_bdc_tab USING:
      'X' 'SAPMM06E'   '0301',
      ' ' 'BDC_CURSOR' 'EKKO-KDATE',
      ' ' 'BDC_OKCODE' '=LS',
      'X' 'SAPMM06E'   '0140',
      ' ' 'BDC_CURSOR' 'EKKO-LIFNR',
      ' ' 'BDC_OKCODE' 'AB',
      ' ' 'EKKO-LIFNR' fu_log-lifnr.
    DATA: lv_spras TYPE spras.
    CLEAR lv_spras.
    SELECT SINGLE spras INTO lv_spras
      FROM lfa1
      WHERE lifnr EQ fu_log-lifnr.

    IF lv_spras IS INITIAL.
      PERFORM populate_bdc_tab USING:
        'X' 'SAPLMEXF'    '0100',
        ' ' 'BDC_OKCODE'  '=ENTE',
        ' ' 'BUTTON_INIT' 'X'.
    ENDIF.
  ELSE.
    PERFORM populate_bdc_tab USING:
      'X' 'SAPMM06E'   '0301',
      ' ' 'BDC_CURSOR' 'EKKO-KDATE',
      ' ' 'BDC_OKCODE' '=AB'.
  ENDIF.
ENDFORM.                    " insert_to_bdc_header

*&---------------------------------------------------------------------*
*&      Form  insert_to_bdc_items
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_to_bdc_items USING fu_tabix
                         CHANGING fc_rfq LIKE ty_rfq.

  DATA lv_tabixn(2) TYPE n.
  DATA lv_tabixc(2).
  DATA lv_ematn(20).
  DATA lv_txz01(20).
  DATA lv_anmng(20).
  DATA lv_meins(20).
  DATA lv_werks(20).
  DATA lv_lgort(20).
  DATA lv_eeind(20).
  DATA lv_qty(20).
  DATA lv_idnlf(20).
  DATA lv_matnr LIKE mara-matnr.

  lv_tabixn = fu_tabix.
  lv_tabixc = lv_tabixn.

* items
  CONCATENATE 'EKPO-EMATN('  lv_tabixc ')' INTO lv_ematn.
  CONCATENATE 'RM06E-ANMNG(' lv_tabixc ')' INTO lv_anmng.
  CONCATENATE 'EKPO-MEINS('  lv_tabixc ')' INTO lv_meins.
  CONCATENATE 'EKPO-IDNLF('  lv_tabixc ')' INTO lv_idnlf.
  CONCATENATE 'RM06E-EEIND(' lv_tabixc ')' INTO lv_eeind.
  WRITE fc_rfq-anmng UNIT fc_rfq-meins TO lv_qty.
  CONDENSE lv_qty.

  IF fc_rfq-ematn IS NOT INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_MATNE_INPUT'
      EXPORTING
        input  = fc_rfq-ematn
      IMPORTING
        output = lv_matnr.

    "with material
    PERFORM populate_bdc_tab USING:
      'X' 'SAPMM06E'   '0320',
      ' ' 'BDC_CURSOR' lv_ematn,
      ' ' 'BDC_OKCODE' '/00',
      ' ' lv_ematn     fc_rfq-ematn,
      ' ' lv_anmng     lv_qty,
      ' ' lv_meins     fc_rfq-meins,
      ' ' lv_eeind     fc_rfq-eeind,   "lv_dlvdate,
      ' ' lv_idnlf     fc_rfq-idnlf.   "lv_mara_matkl.

  ELSE.
    CONCATENATE 'EKPO-TXZ01('  lv_tabixc ')' INTO lv_txz01.
    PERFORM populate_bdc_tab USING:
      'X' 'SAPMM06E'   '0320',
      ' ' 'BDC_CURSOR' lv_txz01,
      ' ' 'BDC_OKCODE' '/00',
      ' ' lv_txz01     fc_rfq-txz01,
      ' ' lv_anmng     lv_qty,
      ' ' lv_meins     fc_rfq-meins,
      ' ' lv_eeind     fc_rfq-eeind,
      ' ' lv_idnlf     fc_rfq-idnlf.
  ENDIF.

  IF p_werks IS NOT INITIAL.
    CONCATENATE 'EKPO-WERKS(' lv_tabixc ')' INTO lv_werks.
    PERFORM populate_bdc_tab USING ' ' lv_werks p_werks.
*  ELSEIF fc_rfq-werks IS NOT INITIAL.
*    CONCATENATE 'EKPO-WERKS(' lv_tabixc ')' INTO lv_werks.
*    PERFORM populate_bdc_tab USING ' ' lv_werks fc_rfq-werks.
  ENDIF.

  IF fc_rfq-lgort IS NOT INITIAL.
    CONCATENATE 'EKPO-LGORT(' lv_tabixc ')' INTO lv_lgort.
    PERFORM populate_bdc_tab USING ' ' lv_lgort fc_rfq-lgort.
  ENDIF.

ENDFORM.                    " insert_to_bdc_items

*&---------------------------------------------------------------------*
*&      Form  insert_to_bdc_end
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_to_bdc_end USING VALUE(fu_lifnr).

  PERFORM populate_bdc_tab USING:
*    "message
    'X' 'SAPMM06E'    '0320',
    ' ' 'BDC_CURSOR'  'EKPO-EMATN(01)',
    ' ' 'BDC_OKCODE'  '=DR',
    'X' 'SAPDV70A'    '0100',
    ' ' 'BDC_CURSOR'  'DNAST-KSCHL(01)',
    ' ' 'BDC_OKCODE'  '/00',
    ' ' 'DNAST-KSCHL(01)' 'NEU',
    ' ' 'NAST-NACHA(01)' '1',
    'X' 'SAPDV70A'    '0100',
    ' ' 'BDC_CURSOR'  'DNAST-KSCHL(01)',
    ' ' 'BDC_OKCODE'  '/00',
    'X' 'SAPDV70A'    '0100',
    ' ' 'BDC_CURSOR'  'DNAST-KSCHL(01)',
    ' ' 'BDC_OKCODE'  '=V70B',
    'X' 'SAPDV70A'    '0101',
    ' ' 'BDC_CURSOR'  'NAST-LDEST',
    ' ' 'BDC_OKCODE'  '/00',
    ' ' 'NAST-LDEST'  'LOCL',
    'X' 'SAPDV70A'    '0101',
    ' ' 'BDC_CURSOR'  'NAST-LDEST',
    ' ' 'BDC_OKCODE'  '=V70B',
    ' ' 'NAST-LDEST'  'LOCL',
    'X' 'SAPDV70A'    '0100',
    ' ' 'BDC_CURSOR'  'DNAST-KSCHL(01)',
    ' ' 'BDC_OKCODE'  '=V70B',
    'X' 'SAPMM06E'    '0301',
    ' ' 'BDC_CURSOR'  'EKKO-EKGRP',
    ' ' 'BDC_OKCODE'  '=BU'.

ENDFORM.                    " insert_to_bdc_end

*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_FILE  text
*----------------------------------------------------------------------*
FORM get_data CHANGING  fc_file.
  DATA lv_fname TYPE string.
  lv_fname = fc_file.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = lv_fname
      filetype                = 'DAT'
      has_field_separator     = ' '
*     HEADER_LENGTH           = 0
*     READ_BY_LINE            = 'X'
*     DAT_MODE                = ' '
*     CODEPAGE                = ' '
*     IGNORE_CERR             = ABAP_TRUE
      replacement             = '#'
*     CHECK_BOM               = ' '
*     VIRUS_SCAN_PROFILE      =
*     NO_AUTH_CHECK           = ' '
*       IMPORTING
*     FILELENGTH              =
*     HEADER                  =
    TABLES
      data_tab                = gt_rfq
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " GET_DATA

*&---------------------------------------------------------------------*
*&      Form  RUN_BDC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM run_bdc .

  DATA lw_rfq LIKE ty_rfq.
  DATA lt_msg  TYPE STANDARD TABLE OF bdcmsgcoll WITH HEADER LINE.
  DATA lw_log LIKE ty_log.
  DATA lv_tabix(10).
  DATA lv_bdc.
  REFRESH: bdc_tab, lt_msg, gt_log.
  lv_tabix = sy-tabix.
  CONDENSE lv_tabix.

  CLEAR lw_log.
  lw_log-bukrs = p_bukrs.
  lw_log-ekorg = p_ekorg.
  lw_log-ekgrp = p_ekgrp.
  lw_log-werks = p_werks.
  lw_log-anfdt = p_anfdt.
  lw_log-angdt = p_angdt.
  lw_log-submi = p_submi.
  lw_log-kdatb = p_kdatb.
  lw_log-kdate = p_kdate.
  lw_log-lifnr = p_lifnr.

  PERFORM insert_to_bdc_header USING lw_log.
  LOOP AT gt_rfq INTO lw_rfq.

    PERFORM insert_bdc_items USING sy-tabix
                             CHANGING lw_rfq.
    MOVE-CORRESPONDING lw_rfq TO lw_log.
    PERFORM get_text USING    lw_log-ematn "#EC CI_FLDEXT_OK[2215424] P30K910011
                     CHANGING lw_log-txz01.
    lw_log-uom = lw_log-meins.
    PERFORM uom CHANGING lw_log-meins.
    APPEND lw_log TO gt_log.
  ENDLOOP.
  PERFORM insert_to_bdc_end USING p_lifnr.

  lv_bdc = 'X'. EXPORT lv_bdc TO MEMORY ID 'UPLOADRFQ'.
  CALL TRANSACTION 'ME41' USING    bdc_tab
                          MODE     p_mode
                          UPDATE   'S'
                          MESSAGES INTO lt_msg.

  CLEAR lv_bdc. FREE MEMORY ID 'UPLOADRFQ'.
  READ TABLE lt_msg WITH KEY msgtyp = 'E'.
  IF sy-subrc = 0.   "Error
    LOOP AT gt_log INTO lw_log.
      lw_log-icon = icon_red_light.
      MESSAGE ID lt_msg-msgid TYPE lt_msg-msgtyp NUMBER lt_msg-msgnr
              WITH lt_msg-msgv1 lt_msg-msgv2 lt_msg-msgv3 lt_msg-msgv4
              INTO lw_log-msg.
      MODIFY gt_log FROM lw_log INDEX sy-tabix.
    ENDLOOP.

  ELSE.
    READ TABLE lt_msg WITH KEY msgtyp = 'A'.
    IF sy-subrc = 0.    "abort
      LOOP AT gt_log INTO lw_log.
        lw_log-icon = icon_red_light.
        MESSAGE ID lt_msg-msgid TYPE lt_msg-msgtyp NUMBER lt_msg-msgnr
                WITH lt_msg-msgv1 lt_msg-msgv2 lt_msg-msgv3 lt_msg-msgv4
                INTO lw_log-msg.
        MODIFY gt_log FROM lw_log INDEX sy-tabix
                      TRANSPORTING icon msg.
      ENDLOOP.

    ELSE.     "Successful
      COMMIT WORK AND WAIT.
      READ TABLE lt_msg WITH KEY msgtyp = 'S'
                                 msgid  = '06'
                                 msgnr  = '017'
                                 msgv1  = 'RFQ'.
      LOOP AT gt_log INTO lw_log.
        lw_log-icon = icon_green_light.
        lw_log-anfnr = lt_msg-msgv2.
        MESSAGE i398(00) WITH TEXT-001 INTO lw_log-msg.
        MODIFY gt_log FROM lw_log INDEX sy-tabix
                      TRANSPORTING icon anfnr msg.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDFORM.                    " RUN_BDC

*&---------------------------------------------------------------------*
*&      Form  VALIDATE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_RFQ  text
*----------------------------------------------------------------------*
FORM validate_data  TABLES ft_rfq STRUCTURE ty_rfq
                           ft_log STRUCTURE ty_log
                    CHANGING VALUE(fc_valid).

  DATA lv_tabix TYPE sytabix.
  DATA lv_tabix_ch(15).
  DATA lw_rfq LIKE ty_rfq.
  DATA lv_uom TYPE meins.
  DATA lv_datum TYPE sydatum.
  DATA lv_anmng TYPE text20.
  DATA lw_mara TYPE mara.
  DATA lw_log LIKE ty_log.


  fc_valid = 'X'.

  CLEAR lw_log.
  lw_log-bukrs = p_bukrs.
  lw_log-ekorg = p_ekorg.
  lw_log-ekgrp = p_ekgrp.
  lw_log-werks = p_werks.
  lw_log-anfdt = p_anfdt.
  lw_log-angdt = p_angdt.
  lw_log-submi = p_submi.
  lw_log-kdatb = p_kdatb.
  lw_log-kdate = p_kdate.
  lw_log-lifnr = p_lifnr.


  LOOP AT ft_rfq INTO lw_rfq.

    lv_tabix_ch = lv_tabix = sy-tabix.
    CONDENSE lv_tabix_ch.
    CLEAR: lw_log-icon,  lw_log-txz01, lw_log-eeind, lw_log-idnlf,
           lw_log-lgort, lw_log-ematn, lw_log-anmng, lw_log-meins,
           lw_log-msg.

    lw_log-icon  = icon_led_green.
    lw_log-txz01 = lw_rfq-txz01.
    lw_log-eeind = lw_rfq-eeind.
    lw_log-lgort = lw_rfq-lgort.

    "Check delivery date...............................................................
    CONCATENATE lw_rfq-eeind+06(4)
                lw_rfq-eeind+03(2)
                lw_rfq-eeind(2)
           INTO lv_datum.
    CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
      EXPORTING
        date                      = lv_datum
      EXCEPTIONS
        plausibility_check_failed = 1
        OTHERS                    = 2.
    IF sy-subrc <> 0.
      "Invalid date DD.MM.YYYY of item XX
      lw_log-icon = icon_led_red.
      MESSAGE e398(00) WITH TEXT-e06 lw_rfq-eeind '' '' "text-e02 lv_tabix_ch
         INTO lw_log-msg.
      CLEAR fc_valid.
    ENDIF.

    "Check UOM.........................................................................
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        input          = lw_rfq-meins
        language       = sy-langu
      IMPORTING
        output         = lw_log-meins   "lv_uom
      EXCEPTIONS
        unit_not_found = 1
        OTHERS         = 2.
    IF sy-subrc <> 0.
      "Invalid UoM XXX of Item YY
      lw_log-icon  = icon_led_red.
      MESSAGE e398(00) WITH TEXT-e03 lw_rfq-meins '' ''  "text-e02 lv_tabix_ch
         INTO lw_log-msg.
      CLEAR fc_valid.
    ENDIF.

    "Check quantity....................................................................
    TRY.
        lw_log-anmng = lw_rfq-anmng.
      CATCH cx_sy_conversion_no_number.
        "invalid quantity XXXXX of item YY
        lw_log-icon  = icon_led_red.
        lv_anmng = lw_rfq-anmng. CONDENSE lv_anmng.
        MESSAGE e398(00) WITH TEXT-e01 lv_anmng  '' '' "text-e02  lv_tabix_ch
           INTO lw_log-msg.
        CLEAR fc_valid.
    ENDTRY.

    IF lw_rfq-ematn IS INITIAL.
      lw_log-idnlf = lw_rfq-idnlf.
    ELSE.
      lw_log-idnlf = lw_rfq-idnlf.
      CALL FUNCTION 'CONVERSION_EXIT_MATNE_INPUT'
        EXPORTING
          input  = lw_rfq-ematn
        IMPORTING
          output = lw_log-ematn.

      SELECT SINGLE *
        FROM mara INTO lw_mara
        WHERE matnr = lw_log-ematn.
      IF sy-subrc NE 0.
        "Invalid material XXXXXXXXXXXX of item YY
        lw_log-icon  = icon_led_red.
        CONDENSE lw_rfq-ematn.
        MESSAGE e398(00) WITH TEXT-e04 lw_rfq-ematn  '' '' "text-e02 lv_tabix_ch
           INTO lw_log-msg.
        CLEAR fc_valid.
      ENDIF.

      SELECT SINGLE meins FROM mara INTO @DATA(lv_meins)
        WHERE matnr = @lw_log-ematn.
      IF lv_meins NE lw_log-meins.
        SELECT SINGLE * FROM marm INTO @DATA(lv_marm)
          WHERE matnr = @lw_log-ematn
            AND meinh = @lw_log-meins.
        IF sy-subrc NE 0.
          lw_log-icon = icon_red_light.
          lw_log-msg = 'Conversion Factor could not be determined'.
          CLEAR fc_valid.
        ENDIF.
      ENDIF.
* --> Start added by Allan T. - 19/10/2016
    ENDIF.
* <-- End added by Allan T. - 19/10/2016

    APPEND lw_log TO ft_log.
  ENDLOOP.
ENDFORM.                    " VALIDATE_DATA


*&---------------------------------------------------------------------*
*&      Form  f_fieldcatg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_fieldcatg USING
         VALUE(fu_types)  VALUE(fu_fname)
                          VALUE(fu_reftb)
                          VALUE(fu_refld)
                          VALUE(fu_noout)
                          VALUE(fu_outln)
                          VALUE(fu_just)
                          VALUE(fu_fltxt)
                          VALUE(fu_dosum)
                          VALUE(fu_hotsp)
                          VALUE(fu_dec)
                          VALUE(fu_waers)
                          VALUE(fu_meins)
                          VALUE(fu_waers_f)
                          VALUE(fu_meins_f)
                          VALUE(fu_checkbox)
*                         value(fu_fixcolumn)
                          VALUE(fu_key)
                          VALUE(fu_icon)
                          VALUE(fu_input).

  DATA: ld_fieldcat  TYPE  slis_fieldcat_alv.
  CLEAR: ld_fieldcat.

  ld_fieldcat-tabname       = fu_types.
  ld_fieldcat-fieldname     = fu_fname.
  ld_fieldcat-ref_tabname   = fu_reftb.
  ld_fieldcat-ref_fieldname = fu_refld.
  ld_fieldcat-no_out        = fu_noout.
  ld_fieldcat-outputlen     = fu_outln.
  ld_fieldcat-just          = fu_just.
  ld_fieldcat-seltext_l     = fu_fltxt.
  ld_fieldcat-seltext_m     = fu_fltxt.
  ld_fieldcat-seltext_s     = fu_fltxt.
  ld_fieldcat-reptext_ddic  = fu_fltxt.
*  ld_fieldcat-no_out        = fu_noout.
  ld_fieldcat-do_sum        = fu_dosum.
  ld_fieldcat-hotspot       = fu_hotsp.
  ld_fieldcat-decimals_out  = fu_dec.
  ld_fieldcat-currency      = fu_waers.
  ld_fieldcat-quantity      = fu_meins.
  ld_fieldcat-qfieldname    = fu_meins_f.
  ld_fieldcat-cfieldname    = fu_waers_f.
  ld_fieldcat-checkbox      = fu_checkbox.
* ld_fieldcat-fix_column    = fu_fixcolumn.
  ld_fieldcat-key           = fu_key.
  ld_fieldcat-icon          = fu_icon.
  ld_fieldcat-input         = fu_input.
  APPEND ld_fieldcat TO t_alv_fieldcat.
  CLEAR ld_fieldcat.
ENDFORM.                    " f_fieldcatg

*&---------------------------------------------------------------------*
*&      Form  header_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_LIST_TOP_OF_PAGE[]  text
*----------------------------------------------------------------------*
FORM header_build USING lt_top_of_page TYPE slis_t_listheader.

  DATA: ls_line     TYPE slis_listheader,
        print_tm(8).

  CLEAR ls_line.
  ls_line-typ  = 'H'.
  ls_line-info = sy-title.
  APPEND ls_line TO lt_top_of_page.

  CLEAR ls_line.
  ls_line-typ  = 'S'.
  ls_line-info = 'Print date:'.
  CONCATENATE ls_line-info sy-datum+6(2) sy-datum+4(2) sy-datum(4)
  INTO ls_line-info
  SEPARATED BY space.
  APPEND ls_line TO lt_top_of_page.

  CLEAR ls_line.
  ls_line-typ  = 'S'.
  ls_line-info = 'Print time: '.
  WRITE sy-uzeit TO print_tm USING EDIT MASK '__:__:__'.
  CONCATENATE ls_line-info print_tm INTO ls_line-info
  SEPARATED BY space.
  APPEND ls_line TO lt_top_of_page.

*  user name
  CLEAR ls_line.
  ls_line-typ  = 'S'.
  ls_line-info = 'User name:'.
  CONCATENATE ls_line-info sy-uname INTO ls_line-info
    SEPARATED BY space.
  APPEND ls_line TO lt_top_of_page.
ENDFORM.                    " header_build

*&---------------------------------------------------------------------*
*&      Form  f_build_sortfield
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_SORT  text
*----------------------------------------------------------------------*
FORM f_build_sortfield
  USING  fu_sort      TYPE slis_t_sortinfo_alv.
*.        fu_tabname   like slis_sortinfo_alv-tabname
*         fu_fieldname
*         fu_up
*         fu_subtot.
  DATA: ld_sort TYPE slis_sortinfo_alv.

*  CLEAR ld_sort.
**  ld_sort-tabname   = 'T_IVAG'.                 "ALV Hierarchy
*  ld_sort-fieldname = 'WERKS'.
*  ld_sort-group     = '* '.
*  ld_sort-up        = 'X'.
*  ld_sort-subtot    = 'X'.
*  APPEND ld_sort TO fu_sort.
*
*  ld_sort-fieldname = 'LGORT'.
*  ld_sort-group     = '* '.
*  ld_sort-up        = 'X'.
*  ld_sort-subtot    = 'X'.
*  APPEND ld_sort TO fu_sort.

ENDFORM.                    " f_build_sortfield


*&---------------------------------------------------------------------*
*&      Form  f_gui_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->fu_text1   text
*      -->fu_text2   text
*----------------------------------------------------------------------*
FORM f_gui_message USING    fu_text1 fu_text2 fu_percentage.
  DATA: ld_text1(100)    TYPE c.
  CONCATENATE fu_text1 fu_text2 INTO ld_text1
              SEPARATED BY space.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = fu_percentage
      text       = ld_text1.
ENDFORM.                    " f_gui_message


*---------------------------------------------------------------------*
*       FORM f_user_command                                          *
*---------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm    LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread LIKE dynpread OCCURS 0 WITH HEADER LINE.
  CASE fu_ucomm.
    WHEN "'BACK' OR 'EXIT' OR 'CANC'.
         '&F03' OR '&F15' OR '&F12'.
      MOVE 'X' TO fu_selfield-exit.
  ENDCASE.

ENDFORM.                    "f_user_command


*&---------------------------------------------------------------------*
*&      Form  F_SET_PFSTATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_set_pfstatus USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'ZMMC_RFQ'.
ENDFORM.                    " F_SET_PFSTATUS


*---------------------------------------------------------------------*
*       FORM f_alv                                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FT_DATA                                                       *
*---------------------------------------------------------------------*
FORM f_alv TABLES ft_report.

  DATA: lv_pfstat TYPE slis_formname,
        lv_usrcom TYPE slis_formname.

  MOVE 'F_SET_PFSTATUS' TO lv_pfstat.
  MOVE 'F_USER_COMMAND' TO lv_usrcom.

  PERFORM f_gui_message      USING 'Write Data in Progress ...' '' 80.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat.   "TABLES  ft_report.
  PERFORM f_build_layout     USING   d_layout.
  PERFORM f_build_sortfield  USING   t_alv_isort[].     "ALV Hierarchy is a must
* PERFORM header_build USING gt_list_top_of_page[].     "for ALV Grid

  PERFORM f_build_event      TABLES  t_alv_event[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print      USING   d_print.
* perform f_alv_variant_exist using   p_vari
*                                     d_alv_variant.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK        = ' '
*     I_BYPASSING_BUFFER       =
*     I_BUFFER_ACTIVE          = ' '
      i_callback_program       = d_repid
      i_callback_pf_status_set = lv_pfstat
      i_callback_user_command  = lv_usrcom
*     I_STRUCTURE_NAME         =
      is_layout                = d_layout
      it_fieldcat              = t_alv_fieldcat[]
*     IT_EXCLUDING             =
*     IT_SPECIAL_GROUPS        =
      it_sort                  = t_alv_isort[]
*     IT_FILTER                =
*     IS_SEL_HIDE              =
      i_default                = 'X'
      i_save                   = 'A'
      is_variant               = d_alv_variant
      it_events                = t_alv_event[]
      it_event_exit            = t_event_exit[]
      is_print                 = d_print
*     IS_REPREP_ID             =
*     I_SCREEN_START_COLUMN    = 0
*     I_SCREEN_START_LINE      = 0
*     I_SCREEN_END_COLUMN      = 0
*     I_SCREEN_END_LINE        = 0
* IMPORTING
*     E_EXIT_CAUSED_BY_CALLER  =
*     ES_EXIT_CAUSED_BY_USER   =
    TABLES
      t_outtab                 = ft_report
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                     " f_alv

*&---------------------------------------------------------------------*
*&      Form  f_build_print
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_PRINT  text
*----------------------------------------------------------------------*
FORM f_build_print USING    fu_print TYPE slis_print_alv.
  fu_print-no_print_listinfos    = 'X'.
  fu_print-no_print_selinfos     = 'X'.
  fu_print-no_coverpage          = 'X'.
  fu_print-no_print_hierseq_item = 'X'.
ENDFORM.                    " f_build_print

*&---------------------------------------------------------------------*
*&      Form  f_build_fieldcat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FT_REPORT  text
*----------------------------------------------------------------------*
FORM f_build_fieldcat. "TABLES   ft_report.
  REFRESH: t_alv_fieldcat.
  PERFORM f_fieldcatg USING 'GT_LOG': "ft_report:
   'ICON' '' '' '' '' 'L' 'Status' '' '' '' '' '' '' '' '' '' 'X' '',
   'ANFNR' 'RM06E' 'ANFNR' '' '' 'L' '' '' '' '' '' '' '' '' '' '' '' '',
   'MSG' '' '' '' '' 'L' 'Message' '' '' '' '' '' '' '' '' '' '' '',
   'ANFDT' 'RM06E' 'ANFDT' '' '' 'L' '' '' '' '' '' '' '' '' '' '' '' '',
   'ANGDT' 'EKKO' 'ANGDT' '' '' 'L' '' '' '' '' '' '' '' '' '' '' '' '',
   'EKORG' 'EKKO' 'EKORG' '' '' 'L' '' '' '' '' '' '' '' '' '' '' '' '',
   'EKGRP' 'EKKO' 'EKGRP' '' '' 'L' '' '' '' '' '' '' '' '' '' '' '' '',
   'SUBMI' 'EKKO' 'SUBMI' '' '' 'L' '' '' '' '' '' '' '' '' '' '' '' '',
   'KDATB' 'EKKO' 'KDATB' '' '' 'L' '' '' '' '' '' '' '' '' '' '' '' '',
   'KDATE' 'EKKO' 'KDATE' '' '' 'L' '' '' '' '' '' '' '' '' '' '' '' '',
   'LIFNR' 'EKKO' 'LIFNR' '' '' 'L' '' '' '' '' '' '' '' '' '' '' '' '',
   'EMATN' 'EKPO' 'EMATN' '' '' 'L' '' '' '' '' '' '' '' '' '' '' '' '',
   'TXZ01' 'EKPO' 'TXZ01' '' '' 'L' '' '' '' '' '' '' '' '' '' '' '' '',
   'ANMNG' 'RM06E' 'ANMNG' '' '' 'R' '' '' '' '' '' '' '' 'MEINS' '' '' '' '',
   'MEINS' 'EKPO' 'MEINS' '' '' 'L' '' '' '' '' '' '' '' '' '' '' '' '',
*   'UOM' '' '' '' '' 'L' 'UoM' '' '' '' '' '' '' '' '' '' '' '',
   'EEIND' 'RM06E' 'EEIND' '' '' 'L' '' '' '' '' '' '' '' '' '' '' '' '',
   'IDNLF' 'EKPO' 'IDNLF' '' '' 'L' '' '' '' '' '' '' '' '' '' '' '' '',
   'WERKS' 'RM06E' 'WERKS' '' '' 'L' '' '' '' '' '' '' '' '' '' '' '' '',
   'LGORT' 'RM06E' 'LGORT' '' '' 'L' '' '' '' '' '' '' '' '' '' '' '' ''.
*  '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
ENDFORM.                    " f_build_fieldcat

*&---------------------------------------------------------------------*
*&      Form  f_build_layout
*&---------------------------------------------------------------------*
*       text
*-----  -----------------------------------------------------------------*
*      -->FU_LAYOUT  text
*----------------------------------------------------------------------*
FORM f_build_layout USING    fu_layout TYPE slis_layout_alv.
* fu_layout-f2code             = '&ETA'.
  fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = 'X'.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.
* fu_layout-box_fieldname      = 'CHBOX'.
ENDFORM.                    " f_build_layout

*&---------------------------------------------------------------------*
*&      Form  f_build_event
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      --> FT_EVENTS
*----------------------------------------------------------------------*
FORM f_build_event TABLES ft_events LIKE t_events.
  REFRESH: ft_events.

  CLEAR ft_events.
  ft_events-name = slis_ev_top_of_list.
  ft_events-form = 'F_TOP_OF_LIST'.
  APPEND ft_events.

  CLEAR ft_events.
  ft_events-name = slis_ev_top_of_page.
  ft_events-form = 'F_TOP_OF_PAGE'.
  APPEND ft_events.

*  CLEAR ft_events.
*  ft_events-name = slis_ev_end_of_page.
*  ft_events-form = 'F_END_OF_PAGE'.
*  APPEND ft_events.

*  CLEAR ft_events.
*  ft_events-name = slis_ev_before_line_output.
*  ft_events-form = 'F_BEFORE_LINE_OUTPUT'.
*  APPEND ft_events.

*  CLEAR ft_events.
*  ft_events-name = slis_ev_after_line_output.
*  ft_events-form = 'F_AFTER_LINE_OUTPUT'.
*  APPEND ft_events.
*
*  CLEAR ft_events.
*  ft_events-name = slis_ev_subtotal_text.
*  ft_events-form = 'F_SUBTOTAL'.
*  APPEND ft_events.
ENDFORM.                    " f_build_event


*---------------------------------------------------------------------*
*       FORM f_top_of_list                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_list.

**-------- if using ALV list
*  IF s_brand-high IS NOT INITIAL.
*    READ TABLE t_brnd WITH KEY vtext = s_brand-high.
*    lv_brand_h = t_brnd-vtext.
*  ENDIF.
*  IF s_brand-low IS NOT INITIAL.
*    READ TABLE t_brnd WITH KEY vtext = s_brand-low.
*    lv_brand_l = t_brnd-vtext.
*  ENDIF.


**-------- if using ALV grid
*  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
*       EXPORTING
**           I_LOGO             = 'ENJOYSAP_LOGO'
*            IT_LIST_COMMENTARY = GT_LIST_TOP_OF_PAGE.

ENDFORM.                    "f_top_of_list

*---------------------------------------------------------------------*
*       FORM f_top_of_page                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_page.

**-------- if using ALV grid
*  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
*       EXPORTING
**           I_LOGO             = 'ENJOYSAP_LOGO'
*            IT_LIST_COMMENTARY = GT_LIST_TOP_OF_PAGE.

ENDFORM.                    "f_top_of_page


*&---------------------------------------------------------------------*
*&      Form  GET_EXCEL_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_P_FILE  text
*----------------------------------------------------------------------*
FORM get_excel_data  CHANGING fc_file.

  DATA lv_file  LIKE rlgrap-filename.
*  DATA lv_sheet TYPE i.
*  DATA lv_endcol TYPE i.
  DATA: lt_itab   TYPE TABLE OF alsmex_tabline,
        lw_itab   TYPE alsmex_tabline,
        lw_itab_c TYPE alsmex_tabline,
        lw_itab_r TYPE alsmex_tabline.
*  DATA lv_fmap(100).
*  DATA lv_off TYPE sycucol.
  DATA lv_colc TYPE kcd_ex_col_n.
  DATA lv_colt TYPE kcd_ex_col_n.
*  DATA lv_sname(132).

* --> Start added by Allan T. - 19/10/2016
  DATA lt_header TYPE TABLE OF alsmex_tabline.
* <-- End added by Allan T. - 19/10/2016

  FIELD-SYMBOLS: "<lfs_upltb> TYPE STANDARD TABLE,
    <lfs_uplwa> TYPE any,
    <lfs_value> TYPE any.

  lv_file = fc_file.
*  PERFORM validate_excel_filename USING lv_file
*                                  CHANGING lv_sname.
*  gv_table = lv_sname.
*  lv_sheet = 1.
*01 matnr(18),                "Material
*02 txz01(04),                "Short Text
*03 anmng(04),                "RFQ Quantity
*04 meins(02),                "UOM
*05 eeind(10),                "Delivery Date
*06 matkl(10),                "Material Group
*07 lgort(04),                "Storage Location

*  lv_fmap = '01020304050607'.

  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'        "CALL FUNCTION 'ZFM_ALSM_EXCEL_TO_INT_TABLE'
    EXPORTING
      filename                = lv_file
      "i_sheet                 = lv_sheet
      i_begin_col             = 1
      i_begin_row             = 2
      i_end_col               = 7    "lv_endcol
      i_end_row               = 5000
    TABLES
      intern                  = lt_itab
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.

  IF sy-subrc <> 0.
* --> Start changed by Allan T. - 12.10.2016
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

    MESSAGE TEXT-e07 TYPE 'E'.
* <-- End changed by Allan T. - 12.10.2016
  ELSE.
* --> Start changed by Allan T. - 19/10/2016
*    LOOP AT lt_itab INTO lw_itab_r WHERE col EQ '0001'
*                                     AND row NE '0000'.

    REFRESH lt_header.
    lt_header[] = lt_itab[].
    SORT lt_header BY row ASCENDING.
    DELETE ADJACENT DUPLICATES FROM lt_header COMPARING row.
    LOOP AT lt_header INTO lw_itab_r WHERE row NE '0000'.
* <-- End changed by Allan T. - 19/10/2016

      LOOP AT lt_itab INTO lw_itab_c WHERE row EQ lw_itab_r-row.
*                                       AND col NE '0001'.
*        lv_colc = ( ( lw_itab_c-col - 1 ) * 2 ) - 2.
        lv_colc = lw_itab_c-col.
        lv_colt = lv_colc.
*        lv_colt = lv_fmap+lv_colc(2).
        IF sy-subrc = 0.
          "ASSIGN COMPONENT lw_itab_c-col OF STRUCTURE gw_RFQ TO <lfs_value>.
          ASSIGN COMPONENT lv_colt OF STRUCTURE gw_rfq TO <lfs_value>.
          <lfs_value> = lw_itab_c-value.
        ENDIF.
      ENDLOOP.
      APPEND gw_rfq TO gt_rfq.
* --> Start added by Allan Taufiq 20/10/2016 -P30K908587
      CLEAR gw_rfq.
* <-- End added by Allan Taufiq 20/10/2016 -P30K908587
    ENDLOOP.

  ENDIF.

ENDFORM.                    " GET_EXCEL_DATA

**&---------------------------------------------------------------------*
**&      Form  VALIDATE_EXCEL_FILENAME
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**      -->P_LV_FILE  text
**----------------------------------------------------------------------*
*FORM validate_excel_filename  USING    fu_file
*                              CHANGING fc_file.
*
*  DATA lv_fpath(132).
*  DATA lv_sname(132).
*
*  CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
*    EXPORTING
*      full_name     = fu_file
*    IMPORTING
*      stripped_name = fc_file
*      file_path     = lv_fpath
*    EXCEPTIONS
*      x_error       = 1
*      OTHERS        = 2.
*  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ELSE.
*    IF fc_file(4) = gc_a004 OR fc_file(4) = gc_a005 OR
*       fc_file(4) = gc_a503 OR fc_file(4) = gc_a504 OR
*       fc_file(4) = gc_a505 OR fc_file(4) = gc_a506 OR
*       fc_file(4) = gc_a507 OR fc_file(4) = gc_a508 OR
*       fc_file(4) = gc_a509 OR fc_file(4) = gc_a510 OR
*       fc_file(4) = gc_a071 OR fc_file(4) = gc_a073.
*    ELSE.
*      MESSAGE e398(00) WITH 'Invalid excel filename' '' '' ''.
*    ENDIF.
*  ENDIF.
*
*ENDFORM.                    " VALIDATE_EXCEL_FILENAME

*&---------------------------------------------------------------------*
*&      Form  F_BADI_RFQ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_RFQ  text
*      -->P_GT_LOG  text
*----------------------------------------------------------------------*
FORM f_badi_rfq  TABLES   ft_rfq STRUCTURE ty_rfq
                          ft_log STRUCTURE ty_log.

  DATA lw_rfq       LIKE ty_rfq.
  DATA lw_log       LIKE ty_log.
  DATA lw_header    TYPE bs01mmhead.
  DATA lw_address   TYPE bapiaddress.
  DATA lv_quotation TYPE bapiekkoc-po_number.
  DATA lw_items     TYPE bs01mmitem.
  DATA lt_items     TYPE STANDARD TABLE OF bs01mmitem.
  DATA lw_schedules TYPE bs01mmschedule.
  DATA lt_schedules TYPE STANDARD TABLE OF bs01mmschedule.
  DATA lt_return    TYPE STANDARD TABLE OF bapiret2.
  DATA lw_return    TYPE bapiret2.
  DATA lv_rfqno     TYPE bapiekkoc-po_number.
  DATA lv_tabix     TYPE sytabix.

********************************************** header
  CLEAR lw_header.
  lw_header-created_by  = sy-uname.
  lw_header-co_code     = p_bukrs.
  lw_header-doc_cat     = 'A'.
  lw_header-doc_type    = 'AN'.
  lw_header-vendor      = p_lifnr.
  lw_header-language    = sy-langu.
  lw_header-purch_org   = p_ekorg.
  lw_header-pur_group   = p_ekgrp.
*  lw_header-currency    = 'RUB'.
  lw_header-doc_date    = sy-datum.
*  lw_header-applic_by   = '20131231'. " BWBDT
  lw_header-quot_dead   = p_angdt.
  lw_header-coll_no     = p_submi.    "Collective number

  lw_log-bukrs = p_bukrs.
  lw_log-ekorg = p_ekorg.
  lw_log-ekgrp = p_ekgrp.
  lw_log-werks = p_werks.
  lw_log-anfdt = p_anfdt.
  lw_log-submi = p_submi.
  lw_log-kdatb = p_kdatb.
  lw_log-kdate = p_kdate.
  lw_log-lifnr = p_lifnr.

********************************************** items
  LOOP AT ft_rfq INTO lw_rfq.
    CLEAR lw_items.
    lw_items-material     = lw_rfq-ematn.
    lw_items-pur_mat      = lw_items-material.
*Start of insert brianrabe P30K910011
    lw_items-material_long = lw_rfq-ematn.
    lw_items-pur_mat_long  = lw_items-material_long.
*end of insert brianrabe P30K910011
    lw_items-co_code      = p_bukrs.
    lw_items-plant        = p_werks.
    lw_items-store_loc    = lw_rfq-lgort.
*   lw_items-trackingno   = '1001'.
    lw_items-doc_cat      = 'A'. "
    lw_items-quot_dead    = p_angdt.
    APPEND lw_items TO lt_items.

    MOVE-CORRESPONDING lw_rfq TO lw_log.
    APPEND lw_log TO ft_log.
  ENDLOOP.

********************************************* schedules
*  CLEAR wa_schedules.
*  wa_schedules-DEL_DATCAT  = '1'. "
*  wa_schedules-deliv_date  = '20140101'.
*  wa_schedules-QUANTITY    = '3'.
*  APPEND wa_schedules TO gt_schedules.

********************************************* run bapi
  CALL FUNCTION 'BS01_MM_QUOTATION_CREATE'
    EXPORTING
      quotation_header         = lw_header
*     QUOTATION_ADDRESS        =
*     SKIP_ITEMS_WITH_ERROR    = 'X'
    IMPORTING
      quotation                = lv_rfqno
    TABLES
      quotation_items          = lt_items
      quotation_item_schedules = lt_schedules
*     QUOTATION_ACCOUNT_ASSIGNMENT =
*     QUOTATION_ITEM_TEXT      =
      return                   = lt_return
*     QUOTATION_LIMITS         =
*     QUOTATION_CONTRACT_LIMITS =
*     QUOTATION_SERVICES       =
*     QUOTATION_SRV_ACCASS_VALUES =
*     QUOTATION_SERVICES_TEXT  =
*     EXTENSIONIN              =
    .

  LOOP AT lt_return INTO  lw_return
                    WHERE type = 'E'
                    OR    type = 'A'.
    ROLLBACK WORK.
*      lw_log-icon = icon_red_light.
*      MESSAGE ID gt_msg-msgid TYPE gt_msg-msgtyp NUMBER gt_msg-msgnr
*              WITH gt_msg-msgv1 gt_msg-msgv2 gt_msg-msgv3 gt_msg-msgv4
*              INTO lw_log-msg.
*      CONCATENATE 'Error item: ' lv_tabix lw_log-msg INTO lw_log-msg.
*      APPEND lw_log TO gt_log.
    EXIT.
  ENDLOOP.  " return

  IF sy-subrc NE 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
    LOOP AT ft_rfq INTO lw_rfq.
      lv_tabix = sy-tabix.
      lw_log-icon  = icon_green_light.
      READ TABLE lt_return INTO lw_return WITH KEY type = 'S'.
      IF sy-subrc = 0.
        lw_log-anfnr = lv_rfqno.
      ENDIF.
      MESSAGE i398(00) WITH TEXT-001 INTO lw_log-msg.
      MODIFY ft_log FROM lw_log INDEX lv_tabix.
    ENDLOOP.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LW_LOG_EMATN  text
*      <--P_LW_LOG_TXZ01  text
*----------------------------------------------------------------------*
FORM get_text  USING    VALUE(fu_ematn)
               CHANGING VALUE(fu_txz01).

  DATA lv_matnr LIKE mara-matnr.

  IF fu_ematn IS NOT INITIAL.
*Start of replace brianrabe P30K910011
*    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*      EXPORTING
*        input  = fu_ematn
*      IMPORTING
*        output = lv_matnr.
    CALL FUNCTION 'CONVERSION_EXIT_MATNE_INPUT'
      EXPORTING
        input  = fu_ematn
      IMPORTING
        output = lv_matnr.
*End of replace brianrabe P30K910011

    SELECT SINGLE maktx
      FROM makt INTO fu_txz01
      WHERE matnr = lv_matnr
        AND spras = sy-langu.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  UOM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LW_LOG_MEINS  text
*----------------------------------------------------------------------*
FORM uom  CHANGING fc_meins.

  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
    EXPORTING
      input          = fc_meins
      language       = sy-langu
    IMPORTING
      output         = fc_meins
    EXCEPTIONS
      unit_not_found = 1
      OTHERS         = 2.
  IF sy-subrc <> 0.
    "Implement suitable error handling here
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  PAI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pai .

  IF sy-ucomm = 'ONLI'.
    IF p_bukrs IS INITIAL AND p_werks IS INITIAL.
      SET CURSOR FIELD 'P_BUKRS'.
      MESSAGE e398(00) WITH TEXT-e05 '' '' ''.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  INSERT_BDC_ITEMS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SY_TABIX  text
*      <--P_LW_RFQ  text
*----------------------------------------------------------------------*
FORM insert_bdc_items  USING    p_tabix
                       CHANGING fc_rfq LIKE ty_rfq.

  DATA: lv_qty   TYPE menge_bi,
        lv_matnr TYPE matnr.

  CLEAR: lv_qty, lv_matnr.
  WRITE fc_rfq-anmng UNIT fc_rfq-meins TO lv_qty.
  CONDENSE lv_qty.

  IF fc_rfq-ematn IS NOT INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_MATNE_INPUT'
      EXPORTING
        input  = fc_rfq-ematn
      IMPORTING
        output = lv_matnr.
  ENDIF.

  IF p_tabix EQ 1.
    PERFORM populate_bdc_tab USING:
      'X' 'SAPMM06E'            '0320',
      ' ' 'BDC_OKCODE'          '/00',
      ' ' 'EKPO-EMATN(01)'      fc_rfq-ematn,
      ' ' 'EKPO-TXZ01(01)'      fc_rfq-txz01,
      ' ' 'RM06E-ANMNG(01)'     lv_qty,
      ' ' 'EKPO-MEINS(01)'      fc_rfq-meins,
      ' ' 'RM06E-EEIND(01)'     fc_rfq-eeind,
*      ' ' 'EKPO-MATKL(01)'      fc_rfq-matkl,
      ' ' 'EKPO-WERKS(01)'      p_werks,
      ' ' 'EKPO-LGORT(01)'      fc_rfq-lgort.

    "Go to detail
    PERFORM populate_bdc_tab USING:
  'X' 'SAPMM06E'            '0320',
  ' ' 'BDC_CURSOR'          'EKPO-TXZ01(01)',
  ' ' 'BDC_OKCODE'          '=DETA'.

    "Back
    PERFORM populate_bdc_tab USING:
    'X' 'SAPMM06E'            '0311',
    ' ' 'EKPO-IDNLF'          fc_rfq-idnlf,
    ' ' 'BDC_OKCODE'          '=BACK'.


  ELSEIF p_tabix EQ 2.
    PERFORM populate_bdc_tab USING:
      'X' 'SAPMM06E'            '0320',
      ' ' 'BDC_OKCODE'          '/00',
      ' ' 'EKPO-EMATN(02)'      fc_rfq-ematn,
      ' ' 'EKPO-TXZ01(02)'      fc_rfq-txz01,
      ' ' 'RM06E-ANMNG(02)'     lv_qty,
      ' ' 'EKPO-MEINS(02)'      fc_rfq-meins,
      ' ' 'RM06E-EEIND(02)'     fc_rfq-eeind,
*      ' ' 'EKPO-MATKL(02)'      fc_rfq-matkl,
      ' ' 'EKPO-WERKS(02)'      p_werks,
      ' ' 'EKPO-LGORT(02)'      fc_rfq-lgort.

    "Go to detail
    PERFORM populate_bdc_tab USING:
    'X' 'SAPMM06E'            '0320',
    ' ' 'BDC_CURSOR'          'EKPO-TXZ01(02)',
    ' ' 'BDC_OKCODE'          '=DETA'.

    "Back
    PERFORM populate_bdc_tab USING:
    'X' 'SAPMM06E'            '0311',
    ' ' 'EKPO-IDNLF'          fc_rfq-idnlf,
    ' ' 'BDC_OKCODE'          '=BACK'.
  ELSE.
    PERFORM populate_bdc_tab USING:
      'X' 'SAPMM06E'            '0320',
      ' ' 'BDC_OKCODE'          '=MALL'.

    PERFORM populate_bdc_tab USING:
      'X' 'SAPMM06E'            '0320',
      ' ' 'BDC_OKCODE'          '=NP'.

    PERFORM populate_bdc_tab USING:
      'X' 'SAPMM06E'            '0320',
      ' ' 'BDC_OKCODE'          '/00',
      ' ' 'EKPO-EMATN(02)'      fc_rfq-ematn,
      ' ' 'EKPO-TXZ01(02)'      fc_rfq-txz01,
      ' ' 'RM06E-ANMNG(02)'     lv_qty,
      ' ' 'EKPO-MEINS(02)'      fc_rfq-meins,
      ' ' 'RM06E-EEIND(02)'     fc_rfq-eeind,
*      ' ' 'EKPO-MATKL(02)'      fc_rfq-matkl,
      ' ' 'EKPO-WERKS(02)'      p_werks,
      ' ' 'EKPO-LGORT(02)'      fc_rfq-lgort.

    PERFORM populate_bdc_tab USING:
      'X' 'SAPMM06E'            '0320',
      ' ' 'BDC_OKCODE'          '=MDEL'.

    "Go to detail
    PERFORM populate_bdc_tab USING:
    'X' 'SAPMM06E'            '0320',
    ' ' 'BDC_CURSOR'          'EKPO-TXZ01(02)',
    ' ' 'BDC_OKCODE'          '=DETA'.
    "Back
    PERFORM populate_bdc_tab USING:
    'X' 'SAPMM06E'            '0311',
    ' ' 'EKPO-IDNLF'          fc_rfq-idnlf,
    ' ' 'BDC_OKCODE'          '=BACK'.
  ENDIF.
ENDFORM.
