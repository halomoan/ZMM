*&---------------------------------------------------------------------*
*& Report  ZMMIGB_0007
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zmmigb_0007 LINE-SIZE 200 LINE-COUNT 60 MESSAGE-ID zmm
NO STANDARD PAGE HEADING.
*----------------------------------------------------------------------*
* Title   : Interface to upload purcahse Requisitions
* FRICE#  :
* Author  : Surjeet Singh
* Date    : 22 Mar 2011
* Purpose : Upload Purchase Requisitions
* Specification Given By:
*----------------------------------------------------------------------*
*  MODIFICATION LOG
*-----------------------------------------------------------------------
*  DATE     change #         Programmer  Description.
*-----------------------------------------------------------------------

*----------------------------------------------------------------------*
* I N C L U D E S
*----------------------------------------------------------------------*
INCLUDE <icon>.

*----------------------------------------------------------------------*
* T Y P E P O O L S
*----------------------------------------------------------------------*
TYPE-POOLS: truxs,ehsww.

*----------------------------------------------------------------------*
* T A B L E S
*----------------------------------------------------------------------*
TABLES : csks.

*----------------------------------------------------------------------*
* I N T E R N A L   T A B L E S
*----------------------------------------------------------------------*
TYPES : BEGIN OF t_pr_h,
          param TYPE char100,
          val   TYPE char100,
        END OF t_pr_h.
DATA : wa_pr_h TYPE t_pr_h.

DATA : it_pr_h TYPE STANDARD TABLE OF t_pr_h WITH HEADER LINE.

TYPES : BEGIN OF t_pr,
          knttp TYPE eban-knttp,
          pstyp TYPE eban-pstyp,
          matnr TYPE matnr,
          txz01 TYPE txz01,
          menge TYPE ktmng,
          meins TYPE meins,
          lfdat TYPE eban-lfdat,
          matkl TYPE matkl,
          lgort TYPE lgort_d,
          kostl TYPE kostl,
          text  TYPE string,
        END OF t_pr.

DATA : it_pr TYPE STANDARD TABLE OF t_pr.
DATA : wa_pr TYPE t_pr.
FIELD-SYMBOLS: <f_pr> TYPE t_pr.

DATA : it_item TYPE STANDARD TABLE OF bapiebanc WITH HEADER LINE,
       it_acct TYPE STANDARD TABLE OF bapiebkn WITH HEADER LINE,
       it_text TYPE STANDARD TABLE OF bapiebantx WITH HEADER LINE.

DATA : it_ret TYPE STANDARD TABLE OF bapireturn WITH HEADER LINE.
DATA : BEGIN OF it_dummy OCCURS 0,
         cola(10)  TYPE c,
         colb(1)   TYPE c,
         colc(18)  TYPE c,
         cold(40)  TYPE c,
         cole(17)  TYPE c,
         colf(3)   TYPE c,
         colg(8)   TYPE c,
         colh(9)   TYPE c,
         coli(4)   TYPE c,
         colj(10)  TYPE c,
         colk(512) TYPE c,
       END OF it_dummy.

DATA : it_excel LIKE alsmex_tabline OCCURS 0 WITH HEADER LINE.
DATA : wa_mara LIKE mara,
       wa_marc LIKE marc.

*>>> SUPPORT TICKET T008095 ADDED BY RAMSES 18.07.2012 - START P30K905153
DATA : wa_prheader    TYPE bapimereqheader,
       wa_prheaderx   TYPE bapimereqheaderx,
       gv_number      LIKE bapimereqheader-preq_no,
       wa_prheaderexp TYPE bapimereqheader,
       it_return      TYPE STANDARD TABLE OF bapiret2 WITH HEADER LINE,
       it_pritem      TYPE STANDARD TABLE OF bapimereqitemimp WITH HEADER LINE,
       it_pritemx     TYPE STANDARD TABLE OF bapimereqitemx WITH HEADER LINE,
       it_praccount   TYPE STANDARD TABLE OF bapimereqaccount WITH HEADER LINE,
       it_praccountx  TYPE STANDARD TABLE OF bapimereqaccountx WITH HEADER LINE,

       gv_tabix       LIKE sy-tabix.

FIELD-SYMBOLS: <f_pr_line> TYPE t_pr.
*<<< SUPPORT TICKET T008095 ADDED BY RAMSES 18.07.2012 - END

*----------------------------------------------------------------------*
* C O N S T A N T   A N D   V A R I A B L E S
*----------------------------------------------------------------------*
DATA : msg(200) TYPE c.
DATA : ebelp TYPE ebelp,
       etenr TYPE etenr,
       s_no  TYPE dzekkn.
DATA : preq_no TYPE bapiebanc-preq_no.
DATA : e_flag(1) TYPE c.

*CLASS cl_abap_char_utilities DEFINITION LOAD.
*data con_tab  type c value cl_abap_char_utilities=>HORIZONTAL_TAB.
DATA : msg_text1 TYPE char50,
       msg_text2 TYPE char50,
       ans(1)    TYPE c.

DATA :l_timer_begin(16) TYPE p,
      l_timer_end(16)   TYPE p,
      l_timer_2dec(16)  TYPE p DECIMALS 2.

*----------------------------------------------------------------------*
* R A N G E S
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
*  P A R A M E T E R S  &  S E L E C T - O P T I O N S
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-b01.
PARAMETERS : p_bsart LIKE eban-bsart OBLIGATORY DEFAULT '',
             p_werks LIKE ekpo-werks OBLIGATORY,
             p_ekorg LIKE ekko-ekorg NO-DISPLAY,
             p_ekgrp LIKE ekko-ekgrp OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-b03.
PARAMETERS : p_test AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK b3.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-b02.
PARAMETERS : p_file LIKE file_table-filename OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b2.
SELECTION-SCREEN COMMENT 1(55) TEXT-001.


*----------------------------------------------------------------------*
* I N I T I A L I Z A T I O N
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* A T  S E L E C T I O N  S C R E E N
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM f_get_pcdir.

*----------------------------------------------------------------------*
* T O P   O F   P A G E
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* A T  L I N E  S E L E C T I O N
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* A T    U S E R   C O M M A N D
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* S T A R T   O F   S E L E C T I O N
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM check_authorisation.
  PERFORM start_counter.
  PERFORM write_report.
  PERFORM upload_file_local.
  PERFORM validations.
  IF e_flag = 'X'.
    SKIP 1.
    WRITE :/ icon_red_light,8 'Faulty Items, Purchase Requisition cannot be created'.
    PERFORM end_counter.
    MESSAGE i000(zfi) WITH 'There are still some error(s), ' 'Correct those error(s) to proceed'.
  ELSE.
    IF p_test IS INITIAL.
      CLEAR: msg_text1,msg_text2,ans.

      msg_text1 = 'Do you wish to continue ?'.
      msg_text2 = 'Item(s) with Zero quantity will be ignored!!!'.

      CALL FUNCTION 'POPUP_WITH_2_BUTTONS_TO_CHOOSE'
        EXPORTING
          defaultoption = '1'
          diagnosetext1 = msg_text1
          textline1     = msg_text2
          text_option1  = 'Yes'
          text_option2  = 'No'
          titel         = 'Create Purcahse Requisition'
        IMPORTING
          answer        = ans.
      IF ans = '1'.
        PERFORM build_data.
      ELSE.
        WRITE :/ 'Action Terminated by user'.
      ENDIF.
    ENDIF.
    PERFORM end_counter.
  ENDIF.



*&---------------------------------------------------------------------*
*&      Form  F_GET_PCDIR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_pcdir .
  DATA: fes TYPE REF TO cl_gui_frontend_services.
  DATA : file     TYPE string,
         path     TYPE string,
         fullpath TYPE string.
  DATA : f_tab  TYPE filetable,
         rcount TYPE i,
         wa_tab TYPE LINE OF filetable.
  CLEAR : rcount,f_tab[],wa_tab.
  CREATE OBJECT fes.

  CALL METHOD fes->file_open_dialog
    EXPORTING
      window_title            = 'Open File'
      default_extension       = '*.txt'
      initial_directory       = 'C:\'
      multiselection          = abap_false
    CHANGING
      file_table              = f_tab
      rc                      = rcount
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  LOOP AT f_tab INTO wa_tab.
    p_file = wa_tab-filename.
    EXIT.
  ENDLOOP.
  CALL METHOD cl_gui_cfw=>flush.
  CLEAR fes.
ENDFORM.                    " F_GET_PCDIR
*&---------------------------------------------------------------------*
*&      Form  UPLOAD_FILE_LOCAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM upload_file_local .
  DATA : sindex TYPE sy-tabix,
         eindex TYPE sy-tabix.
  DATA : f_name TYPE string,
         f_len  TYPE i,
         f_head TYPE xstring.
  DATA : l_header TYPE char1,
         it_raw   TYPE truxs_t_text_data.
  DATA : file LIKE rlgrap-filename.
  file = p_file.
  CLEAR: f_name,f_len,f_head.
  f_name = p_file.

*Read header data
  DATA : w_xl  TYPE alsmex_tabline.
  FIELD-SYMBOLS <data>.


  REFRESH : it_pr_h, it_excel.
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = file
      i_begin_col             = 1
      i_begin_row             = 6
      i_end_col               = 2
      i_end_row               = 11
    TABLES
      intern                  = it_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  LOOP AT it_excel INTO w_xl.
*    CHECK w_xl-row GT 1.
    AT NEW row.
      CLEAR : wa_pr_h.
    ENDAT.
    ASSIGN COMPONENT w_xl-col OF STRUCTURE wa_pr_h TO <data>.
    IF sy-subrc IS INITIAL.
      <data> = w_xl-value.
    ENDIF.
    AT END OF row.
      TRANSLATE wa_pr_h-param TO UPPER CASE.
      TRANSLATE wa_pr_h-val TO UPPER CASE.
      APPEND wa_pr_h TO it_pr_h.
    ENDAT.
  ENDLOOP.

*Read Items
  l_header = 'X'.
  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
      i_line_header        = l_header
      i_tab_raw_data       = it_raw
      i_filename           = file
    TABLES
      i_tab_converted_data = it_dummy[]
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  IF it_dummy[] IS INITIAL.
    MESSAGE i001(zfi) WITH 'File Error' 'No data was uploaded'.
    STOP.
  ENDIF.

  CLEAR: sindex,eindex.
  READ TABLE it_dummy WITH KEY cola = 'Acct Assign'.
  IF sy-subrc = 0.
    sindex = sy-tabix.
  ELSE.
    REFRESH it_dummy[].
    WRITE :/ icon_red_light,8 'Acct Assign col not found in the file'.
    e_flag = 'X'.
  ENDIF.
  READ TABLE it_dummy WITH KEY cola = 'EOR'.
  IF sy-subrc = 0.
    eindex = sy-tabix.
  ELSE.
    REFRESH it_dummy[].
    WRITE :/ icon_red_light,8 'EOR not found in the file'.
    e_flag = 'X'.
  ENDIF.

  LOOP AT it_dummy.
    IF sy-tabix > sindex AND sy-tabix < eindex.
      wa_pr-knttp = it_dummy-cola.
      wa_pr-pstyp = it_dummy-colb.
      wa_pr-matnr = it_dummy-colc.
      wa_pr-txz01 = it_dummy-cold.
      wa_pr-menge = it_dummy-cole.
      wa_pr-meins = it_dummy-colf.
      wa_pr-lfdat = it_dummy-colg.
      wa_pr-matkl = it_dummy-colh.
      wa_pr-lgort = it_dummy-coli.
      wa_pr-kostl = it_dummy-colj.
      wa_pr-text = it_dummy-colk.
      APPEND wa_pr TO it_pr.
      CLEAR wa_pr.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " UPLOAD_FILE_LOCAL
*&---------------------------------------------------------------------*
*&      Form  BUILD_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_data .

  " UPG Retrofit Changes : TR : P30K909941 User : AKSHAYK : Start
  TYPES: BEGIN OF ehsww_text,
           text(512),
*        form(2),
         END OF ehsww_text,
         ehsww_text_t   TYPE ehsww_text OCCURS 0,
         ehsww_text72_t TYPE ehsww_text OCCURS 0.
  " UPG Retrofit Changes : TR : P30K909941 User : AKSHAYK : End
  DATA : it_cust_text TYPE STANDARD TABLE OF ehsww_text,
         wa_text      TYPE ehsww_text.
  DATA : head_text TYPE char512.

  PERFORM flush.
  LOOP AT it_pr ASSIGNING <f_pr>.

*Consider only when item with qty,item being ignored later anyway
    IF <f_pr>-menge IS INITIAL.
    ELSE.
      ADD 10 TO ebelp.
      ADD 1 TO etenr.
      ADD 1 TO s_no.
    ENDIF.

    it_item-preq_item = ebelp.
*    it_item-purch_org = p_ekorg.
    it_item-pur_group = p_ekgrp.
    it_item-plant = p_werks.
    it_item-doc_type = p_bsart.
    IF <f_pr>-knttp = 'U' OR <f_pr>-knttp = 'K' OR <f_pr>-knttp = 'S'.
      it_item-acctasscat = <f_pr>-knttp.
    ENDIF.

    IF <f_pr>-pstyp = 'K'.
      it_item-item_cat = <f_pr>-pstyp.
    ENDIF.

    READ TABLE it_pr_h WITH KEY param = 'REQUISITIONER'.
    IF sy-subrc = 0.
      it_item-preq_name = it_pr_h-val.
    ENDIF.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input  = <f_pr>-matnr
      IMPORTING
        output = it_item-material.

*Start of insertion brianrabe P30K909972
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input  = <f_pr>-matnr
      IMPORTING
        output = it_item-material_long.
*End of insertion brianrabe P30K909972

    IF it_item-material IS INITIAL.
      it_item-short_text = <f_pr>-txz01.
      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
        EXPORTING
          input          = <f_pr>-meins
          language       = sy-langu
        IMPORTING
          output         = it_item-unit
        EXCEPTIONS
          unit_not_found = 1
          OTHERS         = 2.
      it_item-mat_grp = <f_pr>-matkl.
    ELSE.
      SELECT SINGLE * FROM mara INTO  wa_mara WHERE matnr = it_item-material.
      IF sy-subrc = 0.
        it_item-unit = wa_mara-meins.
*Start of insertion brianrabe P30K909972
      ELSE.
        SELECT SINGLE * FROM mara INTO  wa_mara WHERE matnr = it_item-material_long.
        IF sy-subrc = 0.
          it_item-unit = wa_mara-meins.
        ENDIF.
*End of insertion brianrabe P30K909972
      ENDIF.
    ENDIF.

    READ TABLE it_pr_h WITH KEY param = 'TRACKING NUMBER'.
    IF sy-subrc = 0.
      it_item-trackingno = it_pr_h-val.
    ENDIF.

    it_item-store_loc = <f_pr>-lgort.
    it_item-del_datcat = '1'.
    CONCATENATE <f_pr>-lfdat+4(4) <f_pr>-lfdat+2(2) <f_pr>-lfdat+0(2) INTO it_item-deliv_date .
*    IF <f_pr>-menge IS INITIAL.
*      CONTINUE.
*    ELSE.
*      it_item-quantity = <f_pr>-menge.
*    ENDIF.

    IF <f_pr>-knttp = ' ' OR <f_pr>-knttp = 'K'.
      it_item-gr_ind = 'X'.
      it_item-ir_ind = 'X'.
    ENDIF.
    IF <f_pr>-knttp = 'S' OR <f_pr>-knttp = 'U'.
      it_item-ir_ind = 'X'.
    ENDIF.

*Only consider items with quantity.
    IF <f_pr>-menge IS INITIAL.
      CLEAR it_item.
    ELSE.
      it_item-quantity = <f_pr>-menge.
      APPEND it_item.
      CLEAR it_item.
    ENDIF.

*Account Assignment
    it_acct-preq_item = ebelp.
    it_acct-serial_no = '01'.
    it_acct-preq_qty = <f_pr>-menge.
    it_acct-change_id = 'I'.

    READ TABLE it_pr_h WITH KEY param = 'UNLOADING POINT'.
    IF sy-subrc = 0.
      it_acct-unload_pt = it_pr_h-val.
    ENDIF.

    READ TABLE it_pr_h WITH KEY param = 'RECIPIENT'.
    IF sy-subrc = 0.
      it_acct-gr_rcpt = it_pr_h-val.
    ENDIF.

    IF <f_pr>-knttp = 'K'.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <f_pr>-kostl
        IMPORTING
          output = it_acct-cost_ctr.
    ELSEIF <f_pr>-knttp = 'S'.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <f_pr>-kostl
        IMPORTING
          output = it_acct-cost_ctr.
    ELSEIF <f_pr>-knttp = 'U'.
    ENDIF.
    APPEND it_acct.
    CLEAR it_acct.

*Item text
*Start of replacement brianrabe P30K909972
*    DATA: txt_len TYPE sy-tabix.
*    REFRESH : it_cust_text[].
*    CLEAR : wa_text,head_text,txt_len.
*
*    head_text = <f_pr>-text.
*    txt_len = strlen( <f_pr>-text ).
*    CALL FUNCTION 'EHS00_WORDWRAP02'
*      EXPORTING
*        im_string = head_text
*        im_len    = 70
*      TABLES
*        ex_ftext  = it_cust_text.
*
*    LOOP AT it_cust_text INTO wa_text.
*      it_text-preq_item = ebelp.
*      it_text-text_id = 'B01'.
*      it_text-text_form = '*'.
*      it_text-text_line = wa_text-text.
*      APPEND it_text.
*      CLEAR it_text.
*    ENDLOOP.

    DATA : lv_textline(512) TYPE c,
           lt_outline       TYPE TABLE OF char512,
           ls_outline       LIKE LINE OF lt_outline.

    REFRESH lt_outline[]. "Chermaine P30K910206
    CLEAR lv_textline.    "Chermaine P30K910206
    lv_textline = <f_pr>-text.

    CALL FUNCTION 'IQAPI_WORD_WRAP'
      EXPORTING
        textline            = lv_textline
        outputlen           = 70
      TABLES
        out_lines           = lt_outline
      EXCEPTIONS
        outputlen_too_large = 1
        OTHERS              = 2.

    IF sy-subrc = 0.
      LOOP AT lt_outline INTO ls_outline.
        it_text-preq_item = ebelp.
        it_text-text_id   = 'B01'.
        it_text-text_form = '*'.
        it_text-text_line = ls_outline.
        APPEND it_text.
        CLEAR it_text.
      ENDLOOP.
    ENDIF.

*End of replacement brianrabe P30K909972


*create PR
    AT LAST.
      PERFORM call_bapi CHANGING msg.
    ENDAT.
  ENDLOOP.
ENDFORM.                    " BUILD_DATA
*&---------------------------------------------------------------------*
*&      Form  CALL_BAPI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM call_bapi CHANGING p_msg.

  CLEAR : it_ret[],preq_no.

  CALL FUNCTION 'BAPI_REQUISITION_CREATE'
    EXPORTING
      automatic_source               = ' '
    IMPORTING
      number                         = preq_no
    TABLES
      requisition_items              = it_item
      requisition_account_assignment = it_acct
      requisition_item_text          = it_text
      return                         = it_ret.


  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = 'X'.

  IF preq_no IS NOT INITIAL.
    CONCATENATE preq_no 'Created in plant' p_werks INTO p_msg SEPARATED BY space.
    WRITE :/ icon_green_light,8 p_msg.
  ENDIF.

  LOOP AT it_ret WHERE type = 'E' OR type = 'A'.
    CALL FUNCTION 'FORMAT_MESSAGE'
      EXPORTING
        id        = it_ret-code+0(2)
        lang      = sy-langu
        no        = it_ret-code+2(3)
        v1        = it_ret-message_v1
        v2        = it_ret-message_v2
        v3        = it_ret-message_v3
        v4        = it_ret-message_v4
      IMPORTING
        msg       = p_msg
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    WRITE :/ icon_red_light,8 p_msg.
  ENDLOOP.

ENDFORM.                    " CALL_BAPI
*&---------------------------------------------------------------------*
*&      Form  FLUSH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM flush .
  CLEAR : it_item,it_acct,it_text,e_flag,ebelp,etenr,s_no.
  REFRESH : it_item[],it_acct[],it_text[].
ENDFORM.                    " FLUSH
*&---------------------------------------------------------------------*
*&      Form  CHECK_AUTHORISATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_authorisation .
  AUTHORITY-CHECK OBJECT 'M_BANF_BSA'
           ID 'ACTVT' FIELD '01'
           ID 'BSART' FIELD p_bsart.
  IF sy-subrc <> 0.
    MESSAGE e000(zfi) WITH 'No authorisation to create document type ' p_bsart.
  ENDIF.

  AUTHORITY-CHECK OBJECT 'M_BANF_WRK'
           ID 'ACTVT' FIELD '01'
           ID 'WERKS' FIELD p_werks.
  IF sy-subrc <> 0.
    MESSAGE e000(zfi) WITH 'No authorisation to create Requisition' 'in Plant' p_werks.
  ENDIF.
ENDFORM.                    " CHECK_AUTHORISATION
*&---------------------------------------------------------------------*
*&      Form  WRITE_REPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_report .
*Write posting log Header
  WRITE :/50 'PR Creation Log' COLOR COL_HEADING.
  IF p_test = 'X'.
    WRITE :/50 'Test Run'.
  ELSE.
    WRITE :/50 'Posting Run'.
  ENDIF.
  WRITE : sy-uline.
  WRITE :/40 'User',65 sy-uname.
  WRITE :/40 'Date',65 sy-datum.
  WRITE :/40 'Time',65 sy-uzeit.
  WRITE :/40 'Page no', 65 sy-pagno.
  WRITE : sy-uline.
ENDFORM.                    " WRITE_REPORT
*&---------------------------------------------------------------------*
*&      Form  VALIDATIONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validations .

  CLEAR e_flag.
  READ TABLE it_pr_h WITH KEY param = 'PLANT'.
  IF sy-subrc = 0.
    IF it_pr_h-val IS INITIAL.
      WRITE :/ icon_red_light,8 'Please enter Plant in the Excel sheet Row #6'.
      e_flag = 'X'.
    ELSE.
      IF it_pr_h-val <> p_werks.
        WRITE :/ icon_red_light,8 'Please enter valid Plant in the Excel sheet & Selection screen'.
        e_flag = 'X'.
      ENDIF.
    ENDIF.
  ELSE.
    WRITE :/ icon_red_light,8 'Please enter Plant in the Excel sheet Row #6'.
    e_flag = 'X'.
  ENDIF.

  READ TABLE it_pr_h WITH KEY param = 'REQUISITIONER'.
  IF it_pr_h-val IS INITIAL.
    WRITE :/ icon_red_light,8 'Please enter Requisitioner name in the Excel sheet Row #7'.
    e_flag = 'X'.
  ENDIF.

  READ TABLE it_pr_h WITH KEY param = 'PURCHASING GROUP'.
  IF sy-subrc = 0.
    IF it_pr_h-val IS INITIAL.
      WRITE :/ icon_red_light,8 'Please enter Purchasing Group in the Excel sheet Row #9'.
      e_flag = 'X'.
    ELSE.
      IF it_pr_h-val <> p_ekgrp.
        WRITE :/ icon_red_light,8 'Please enter valid Purchasing Group in the Excel sheet & Selection screen'.
        e_flag = 'X'.
      ENDIF.
    ENDIF.
  ELSE.
    WRITE :/ icon_red_light,8 'Please enter Purchasing Group in the Excel sheet'.
    e_flag = 'X'.
  ENDIF.

  LOOP AT it_pr ASSIGNING <f_pr>.
    IF <f_pr>-knttp = 'K' OR <f_pr>-knttp = 'S'.
      EXIT.
    ENDIF.
  ENDLOOP.
  IF <f_pr>-knttp = 'K' OR <f_pr>-knttp = 'S'.
    READ TABLE it_pr_h WITH KEY param = 'UNLOADING POINT'.
    IF it_pr_h-val IS INITIAL OR it_pr_h-val = space.
      WRITE :/ icon_red_light,8 'Unloading Point is not maintained'.
      e_flag = 'X'.
    ENDIF.

    READ TABLE it_pr_h WITH KEY param = 'RECIPIENT'.
    IF it_pr_h-val IS INITIAL OR it_pr_h-val = space.
      WRITE :/ icon_red_light,8 'Recipient is not maintained'.
      e_flag = 'X'.
    ENDIF.
  ENDIF.

*Item Data
  DATA : matnr TYPE mara-matnr,
         kostl TYPE csks-kostl.
  DATA : s_flag(1)  TYPE c,
         er_flag(1) TYPE c.

*>>> SUPPORT TICKET T008095 ADDED BY RAMSES 18.07.2012 - START P30K905153
  CLEAR : gv_tabix.
*<<< SUPPORT TICKET T008095 ADDED BY RAMSES 18.07.2012 - END

  LOOP AT it_pr ASSIGNING <f_pr>.

*>>> SUPPORT TICKET T008095 ADDED BY RAMSES 18.07.2012 - START P30K905153
    gv_tabix = sy-tabix.
*<<< SUPPORT TICKET T008095 ADDED BY RAMSES 18.07.2012 - END

    ADD 10 TO ebelp.
    CLEAR : matnr,kostl,csks,s_flag,er_flag.

    IF <f_pr>-knttp = 'U' OR <f_pr>-knttp = 'K' OR <f_pr>-knttp = 'S'.
      s_flag = 'X'.
    ELSE.
      IF <f_pr>-knttp IS NOT INITIAL.
        WRITE :/ icon_red_light,8 'Item ', 20 ebelp, 28 'Account assignment is not allowed.',65 '"' , 66 <f_pr>-knttp , 68 '"' .
        er_flag = e_flag = 'X'.
      ENDIF.
    ENDIF.

    IF <f_pr>-knttp = 'K' OR <f_pr>-knttp = 'S'.
      IF <f_pr>-kostl IS INITIAL.
        WRITE :/ icon_red_light,8 'Item ', 20 ebelp, 28 'Cost center is missing for the item.'.
        er_flag = e_flag = 'X'.
      ELSE.
        s_flag = 'X'.
      ENDIF.
    ENDIF.

    IF <f_pr>-pstyp = 'K'.
      s_flag = 'X'.
    ELSE.
      IF <f_pr>-pstyp IS NOT INITIAL.
        WRITE :/ icon_red_light,8 'Item ', 20 ebelp, 28 'Only Item category "K" is allowed'.
        er_flag = e_flag = 'X'.
      ENDIF.
    ENDIF.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input  = <f_pr>-matnr
      IMPORTING
        output = matnr.

    IF matnr IS INITIAL.
    ELSE.
      SELECT SINGLE * FROM mara INTO  wa_mara WHERE matnr = matnr.
      IF sy-subrc <> 0.
*Start replacement brianrabe P30K909972
*        WRITE :/ icon_red_light,8 'Item ', 20 ebelp, 28 'Material ',39 matnr, 50 ' is not maintained'.
        WRITE :/ icon_red_light,8 'Item ', 20 ebelp, 28 'Material ',39 matnr, 72 ' is not maintained'.
*End replacement brianrabe P30K909972
        er_flag = e_flag = 'X'.
      ELSE.
        s_flag = 'X'.
      ENDIF.

      IF wa_mara-meins IS INITIAL.
        WRITE :/ icon_red_light,8 'Item ', 20 ebelp, 28 'UOM is not maintained for material', 50 matnr.
        er_flag = e_flag = 'X'.
      ELSE.
        s_flag = 'X'.
      ENDIF.

      SELECT SINGLE * FROM marc INTO wa_marc WHERE matnr = matnr
                                               AND werks = p_werks.
      IF sy-subrc <> 0.
*Start replacement brianrabe P30K909972
*        WRITE :/ icon_red_light,8 'Item ', 20 ebelp, 28 'Material ',  39 matnr, 50 ' not extended to plant',74 p_werks.
        WRITE :/ icon_red_light,8 'Item ', 20 ebelp, 28 'Material ',  39 matnr, 72 ' not extended to plant',96 p_werks.
*End replacement brianrabe P30K909972
        er_flag = e_flag = 'X'.
      ELSE.
        s_flag = 'X'.
      ENDIF.
    ENDIF.

    IF <f_pr>-lfdat IS INITIAL OR <f_pr>-lfdat = space.
      WRITE :/ icon_red_light,8 'Item ', 20 ebelp,28 'Delivery Date is not maintained'.
      er_flag = e_flag = 'X'.
    ELSE.
      s_flag = 'X'.
    ENDIF.

    IF <f_pr>-kostl IS NOT INITIAL.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <f_pr>-kostl
        IMPORTING
          output = kostl.
      SELECT SINGLE * FROM csks WHERE kostl = kostl
                                  AND datbi GE sy-datum
                                  AND datab LE sy-datum.
      IF sy-subrc <> 0.
        WRITE :/ icon_red_light,8 'Item ', 20 ebelp,28 'Cost Center is not valid'.
        er_flag = e_flag = 'X'.
      ELSE.
        s_flag = 'X'.
      ENDIF.
    ENDIF.

    IF <f_pr>-menge IS INITIAL.
      WRITE :/ icon_yellow_light,8 'Item ', 20 ebelp,28 'Qty is not maintained (Item will be ignored)'.
      CLEAR s_flag.
    ELSE.
      s_flag = 'X'.
    ENDIF.

    IF p_test = 'X'.

*>>> SUPPORT TICKET T008095 ADDED BY RAMSES 18.07.2012 - START P30K905153
      PERFORM build_test_data USING gv_tabix .

      CALL FUNCTION 'BAPI_PR_CREATE'
        EXPORTING
          prheader    = wa_prheader
          prheaderx   = wa_prheaderx
          testrun     = 'X'
        IMPORTING
          number      = gv_number
          prheaderexp = wa_prheaderexp
        TABLES
          return      = it_return
          pritem      = it_pritem
          pritemx     = it_pritemx
          praccount   = it_praccount
          praccountx  = it_praccountx.

      LOOP AT it_return WHERE type = 'E' AND id <> 'BAPI' .
        WRITE :/ icon_red_light,8 'Item ', 20 ebelp,28 it_return-message.
      ENDLOOP.

      IF sy-subrc = 0.
        er_flag = e_flag = 'X'.
      ELSE.
        s_flag = 'X'.
      ENDIF.
*<<< SUPPORT TICKET T008095 ADDED BY RAMSES 18.07.2012 - END

      IF s_flag = 'X' AND er_flag IS INITIAL.
        WRITE :/ icon_green_light,8 'Item ', 20 ebelp.
      ENDIF.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " VALIDATIONS
*&---------------------------------------------------------------------*
*&      Form  START_COUNTER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM start_counter .
  SET RUN TIME CLOCK RESOLUTION HIGH.
  GET RUN TIME FIELD l_timer_begin.
ENDFORM.                    " START_COUNTER
*&---------------------------------------------------------------------*
*&      Form  END_COUNTER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM end_counter .
  GET RUN TIME FIELD l_timer_end.
  l_timer_2dec = ( l_timer_end - l_timer_begin ) / 1000.
  l_timer_2dec = l_timer_2dec / 3600.
  SKIP 2.
  WRITE : sy-uline.
  WRITE : 'Total Execution Time in Seconds',50  l_timer_2dec.
  WRITE : sy-uline.
ENDFORM.                    " END_COUNTER
*&---------------------------------------------------------------------*
*&      Form  BUILD_TEST_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_test_data USING iv_tabix.

  PERFORM flush_test_data.

  PERFORM build_header_test.

  READ TABLE it_pr ASSIGNING <f_pr_line> INDEX iv_tabix.

  IF sy-subrc = 0.

    it_pritem-preq_item = ebelp.
    it_pritem-pur_group = p_ekgrp.
    it_pritem-plant = p_werks.

    it_pritemx-preq_item = ebelp.
    it_pritemx-pur_group = 'X'.
    it_pritemx-plant = 'X'.

    IF <f_pr_line>-knttp = 'U' OR <f_pr_line>-knttp = 'K' OR <f_pr_line>-knttp = 'S'.
      it_pritem-acctasscat = <f_pr_line>-knttp.
      it_pritemx-acctasscat = 'X'.
    ENDIF.


    IF <f_pr_line>-pstyp = 'K'.
      it_pritem-item_cat = <f_pr_line>-pstyp.
      it_pritemx-item_cat = 'X'.
    ENDIF.

    READ TABLE it_pr_h WITH KEY param = 'REQUISITIONER'.
    IF sy-subrc = 0.
      it_pritem-preq_name = it_pr_h-val.
      it_pritemx-preq_name = 'X'.
    ENDIF.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input  = <f_pr_line>-matnr
      IMPORTING
        output = it_pritem-material.

    it_pritemx-material = 'X'.

*Start of insertion brianrabe P30K909972
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input  = <f_pr_line>-matnr
      IMPORTING
        output = it_pritem-material_long.

    it_pritemx-material_long = 'X'.

*End of insertion brianrabe P30K909972

    IF it_pritem-material IS INITIAL.

      it_pritem-short_text = <f_pr_line>-txz01.
      it_pritemx-short_text = 'X'.

      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
        EXPORTING
          input          = <f_pr_line>-meins
          language       = sy-langu
        IMPORTING
          output         = it_pritem-unit
        EXCEPTIONS
          unit_not_found = 1
          OTHERS         = 2.

      it_pritemx-unit = 'X'.

      it_pritem-matl_group = <f_pr_line>-matkl.
      it_pritemx-matl_group = 'X'.

    ELSE.

      SELECT SINGLE * FROM mara INTO  wa_mara WHERE matnr = it_pritem-material.
      IF sy-subrc = 0.
        it_pritem-unit = wa_mara-meins.
        it_pritemx-unit = 'X'.
*Start of insertion brianrabe P30K909972
      ELSE.

        SELECT SINGLE * FROM mara INTO  wa_mara WHERE matnr = it_pritem-material_long.
        IF sy-subrc = 0.
          it_pritem-unit = wa_mara-meins.
          it_pritemx-unit = 'X'.
        ENDIF.
*End of insertion brianrabe P30K909972
      ENDIF.

    ENDIF.

    READ TABLE it_pr_h WITH KEY param = 'TRACKING NUMBER'.
    IF sy-subrc = 0.
      it_pritem-trackingno = it_pr_h-val.
      it_pritemx-trackingno = 'X'.
    ENDIF.

    it_pritem-store_loc = <f_pr_line>-lgort.
    it_pritem-del_datcat_ext = '1'.

    it_pritemx-store_loc = 'X'.
    it_pritemx-del_datcat_ext = 'X'.


    CONCATENATE <f_pr_line>-lfdat+4(4) <f_pr_line>-lfdat+2(2) <f_pr_line>-lfdat+0(2) INTO it_pritem-deliv_date .
    it_pritemx-deliv_date = 'X'.

    IF <f_pr_line>-knttp = ' ' OR <f_pr_line>-knttp = 'K'.
      it_pritem-gr_ind = 'X'.
      it_pritem-ir_ind = 'X'.

      it_pritemx-gr_ind = 'X'.
      it_pritemx-ir_ind = 'X'.
    ENDIF.
    IF <f_pr_line>-knttp = 'S' OR <f_pr_line>-knttp = 'U'.
      it_pritem-ir_ind = 'X'.
      it_pritemx-ir_ind = 'X'.
    ENDIF.

*Only consider items with quantity.
    IF <f_pr_line>-menge IS INITIAL.
      CLEAR it_pritem.
    ELSE.
      it_pritem-quantity = <f_pr_line>-menge.
      it_pritemx-quantity = 'X'.
      APPEND it_pritem.
      CLEAR it_pritem.

      APPEND it_pritemx.
      CLEAR it_pritemx.
    ENDIF.

*Account Assignment
    it_praccount-preq_item = ebelp.
    it_praccount-serial_no = '01'.
    it_praccount-quantity = <f_pr_line>-menge.
*    it_acct-change_id = 'I'.     "No field

    it_praccountx-preq_item = ebelp.
    it_praccountx-serial_no = '01'.
    it_praccountx-quantity = 'X'.

    READ TABLE it_pr_h WITH KEY param = 'UNLOADING POINT'.
    IF sy-subrc = 0.
      it_praccount-unload_pt = it_pr_h-val.
      it_praccountx-unload_pt = 'X'.
    ENDIF.

    READ TABLE it_pr_h WITH KEY param = 'RECIPIENT'.
    IF sy-subrc = 0.
      it_praccount-gr_rcpt = it_pr_h-val.
      it_praccountx-gr_rcpt = 'X'.
    ENDIF.

    IF <f_pr_line>-knttp = 'K'.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <f_pr_line>-kostl
        IMPORTING
          output = it_praccount-costcenter.
      it_praccountx-costcenter = 'X'.

    ELSEIF <f_pr_line>-knttp = 'S'.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <f_pr_line>-kostl
        IMPORTING
          output = it_praccount-costcenter.
      it_praccountx-costcenter = 'X'.

    ELSEIF <f_pr_line>-knttp = 'U'.
    ENDIF.

    APPEND it_praccount.
    CLEAR it_praccount.

    APPEND it_praccountx.
    CLEAR it_praccountx.

  ENDIF.

ENDFORM.                    " BUILD_TEST DATA
*&---------------------------------------------------------------------*
*&      Form  FLUSH_TEST_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM flush_test_data .
  CLEAR : wa_prheader , wa_prheaderx, gv_number, wa_prheaderexp.
  REFRESH : it_return[], it_pritem[], it_pritemx[], it_praccount, it_praccountx.
ENDFORM.                    " FLUSH
*&---------------------------------------------------------------------*
*&      Form  BUILD_HEADER_TEST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_header_test .

  wa_prheader-pr_type = p_bsart.
  wa_prheaderx-pr_type = 'X'.

ENDFORM.                    " BUILD_HEADER_TEST
