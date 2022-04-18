************************************************************************
* FRICE#     :
* Title      : List Display of MRP Created PRs
* Author     : kristian Fredy
* Date       : 01.03.2012
* Specification Given By: Wan Woei
* Purpose	 : List Display of MRP Created PRs
*--------------------------------------_-------------------------------*
* Modification Log
* Date         Author   Num Description
*
* -----------  -------  ---  -----------------------------------------*
*----------------------------------------------------------------------*
REPORT  zmmrgb_0007.

TABLES : eban.
TABLES : sscrfields.

SELECTION-SCREEN BEGIN OF BLOCK scr WITH FRAME.
SELECT-OPTIONS : s_banfn FOR eban-banfn,
                 s_werks FOR eban-werks,
                 s_lgort FOR eban-lgort,
                 s_matnr FOR eban-matnr.
PARAMETERS : p_list(3) DEFAULT 'ALV' MODIF ID abc.
SELECT-OPTIONS : s_bsart FOR eban-bsart.
SELECT-OPTIONS : s_knttp FOR eban-knttp DEFAULT 'U'. "MODIF ID abc.
SELECTION-SCREEN END OF BLOCK scr.

*SELECTION-SCREEN BEGIN OF SCREEN 9100 AS WINDOW TITLE text_100.
*PARAMETERS : p_banfn LIKE eban-banfn.
*PARAMETERS : p_bnfpo LIKE eban-bnfpo.
*SELECTION-SCREEN BEGIN OF LINE.
*SELECTION-SCREEN COMMENT (33) text_102.
*PARAMETERS : p_matnr LIKE eban-matnr.
*PARAMETERS : p_txz01 LIKE eban-txz01.
*SELECTION-SCREEN END OF LINE.
*SELECTION-SCREEN SKIP 1.
*SELECTION-SCREEN BEGIN OF LINE.
*SELECTION-SCREEN COMMENT (60) text_101.
*SELECTION-SCREEN END OF LINE.
*SELECTION-SCREEN SKIP 1.
*PARAMETERS : p_kostl LIKE cobl-kostl.
*PARAMETERS : p_ablad LIKE meacct1100-ablad.
*PARAMETERS : p_ekgrp LIKE eban-ekgrp.
*PARAMETERS : p_wempf LIKE meacct1100-wempf.
*PARAMETERS : p_afnam LIKE eban-afnam.
*SELECTION-SCREEN END OF SCREEN 9100.

DATA : p_knttp LIKE eban-knttp.
DATA : p_menge LIKE eban-menge.
DATA : p_meins LIKE eban-meins.
DATA : p_kostl LIKE cobl-kostl.
DATA : p_ablad LIKE meacct1100-ablad.
DATA : p_ekgrp LIKE eban-ekgrp.
DATA : p_wempf LIKE meacct1100-wempf.
DATA : p_afnam LIKE eban-afnam.

DATA : gv_success_bapi_process, gv_success_bapi_process_save.
DATA : okcode_9100 LIKE sy-ucomm.
DATA : okcode_100 LIKE sy-ucomm.
DATA : okcode_200 LIKE sy-ucomm.
DATA : gv_not_valid_100.
DATA : gv_not_valid_200.
DATA : gv_detail_flag, gv_posting_result_flag, gv_posting_result_flag_dtl.
DATA : gv_line_return(4) TYPE i.
DATA : gv_okcode_main  LIKE sy-ucomm.

DATA : BEGIN OF gt_header_posting_result OCCURS 0,
       banfn_posting LIKE eban-banfn,
       status(10),
       message(200),
       custom_message(200),
       END OF gt_header_posting_result.

DATA : BEGIN OF gt_header_posting_result_dtl OCCURS 0,
       banfn_posting_del LIKE eban-banfn,
       bnfpo_posting LIKE eban-bnfpo,
       matnr_posting LIKE eban-matnr,
       txz01_posting LIKE eban-txz01,
       status(10),
       message(200),
       custom_message(200),
       END OF gt_header_posting_result_dtl.

DATA : BEGIN OF gs_csks,
       kokrs LIKE csks-kokrs,
       kostl LIKE csks-kostl,
       datbi LIKE csks-datbi,
       datab LIKE csks-datab,
       bukrs LIKE csks-bukrs,
       END OF gs_csks.

DATA : BEGIN OF gs_t024,
       ekgrp LIKE t024-ekgrp,
       eknam LIKE t024-eknam,
       END OF gs_t024.

DATA : gv_flag_new_banfn.

* bapi get-detail - start
*"  EXPORTING
DATA : gs_prheader LIKE  bapimereqheader.
DATA :
gt_detail_return LIKE bapiret2 OCCURS 0 WITH HEADER LINE,
gt_detail_pritem LIKE bapimereqitem OCCURS 0 WITH HEADER LINE,
gt_detail_praccount LIKE bapimereqaccount OCCURS 0 WITH HEADER LINE,
gt_detail_praddrdelivery LIKE bapimerqaddrdelivery OCCURS 0 WITH HEADER LINE,
gt_detail_pritemtext LIKE bapimereqitemtext OCCURS 0 WITH HEADER LINE,
gt_detail_prheadertext LIKE bapimereqheadtext OCCURS 0 WITH HEADER LINE,
gt_detail_extensionout LIKE bapiparex OCCURS 0 WITH HEADER LINE,
gt_detail_allversions LIKE bapimedcm_allversions OCCURS 0 WITH HEADER LINE,
gt_detail_prcomponents LIKE bapimereqcomponent OCCURS 0 WITH HEADER LINE,
gt_detail_serialnumbers LIKE bapimereqserialno OCCURS 0 WITH HEADER LINE,
gt_detail_serviceoutline LIKE bapi_srv_outline OCCURS 0 WITH HEADER LINE,
gt_detail_servicelines LIKE bapi_srv_service_line OCCURS 0 WITH HEADER LINE,
gt_detail_servicelimit LIKE bapi_srv_limit_data OCCURS 0 WITH HEADER LINE,
*gt_detail_servicecontractlimits LIKE bapi_srv_contract_limits OCCURS 0 WITH HEADER LINE,
gt_detail_serviceaccount LIKE bapi_srv_acc_data OCCURS 0 WITH HEADER LINE,
gt_detail_servicelongtexts LIKE bapi_srv_longtexts OCCURS 0 WITH HEADER LINE.

DATA :
gt_detail_2_return LIKE bapiret2 OCCURS 0 WITH HEADER LINE,
gt_detail_2_pritem LIKE bapimereqitem OCCURS 0 WITH HEADER LINE,
gt_detail_2_praccount LIKE bapimereqaccount OCCURS 0 WITH HEADER LINE,
gt_detail_2_praddrdelivery LIKE bapimerqaddrdelivery OCCURS 0 WITH HEADER LINE,
gt_detail_2_pritemtext LIKE bapimereqitemtext OCCURS 0 WITH HEADER LINE,
gt_detail_2_prheadertext LIKE bapimereqheadtext OCCURS 0 WITH HEADER LINE,
gt_detail_2_extensionout LIKE bapiparex OCCURS 0 WITH HEADER LINE,
gt_detail_2_allversions LIKE bapimedcm_allversions OCCURS 0 WITH HEADER LINE,
gt_detail_2_prcomponents LIKE bapimereqcomponent OCCURS 0 WITH HEADER LINE,
gt_detail_2_serialnumbers LIKE bapimereqserialno OCCURS 0 WITH HEADER LINE,
gt_detail_2_serviceoutline LIKE bapi_srv_outline OCCURS 0 WITH HEADER LINE,
gt_detail_2_servicelines LIKE bapi_srv_service_line OCCURS 0 WITH HEADER LINE,
gt_detail_2_servicelimit LIKE bapi_srv_limit_data OCCURS 0 WITH HEADER LINE,
*gt_detail_servicecontractlimits LIKE bapi_srv_contract_limits OCCURS 0 WITH HEADER LINE,
gt_detail_2_serviceaccount LIKE bapi_srv_acc_data OCCURS 0 WITH HEADER LINE,
gt_detail_2_servicelongtexts LIKE bapi_srv_longtexts OCCURS 0 WITH HEADER LINE.

* bapi change - start
DATA : gs_prheaderbapimereqheader.
DATA : gs_prheaderx LIKE bapimereqheaderx.

DATA :
gt_change_return LIKE bapiret2 OCCURS 0 WITH HEADER LINE,
gt_change_pritem LIKE bapimereqitemimp OCCURS 0 WITH HEADER LINE,
gt_change_pritemx LIKE bapimereqitemx OCCURS 0 WITH HEADER LINE,
*"      PRITEMEXP STRUCTURE  BAPIMEREQITEM OPTIONAL
*"      PRITEMSOURCE STRUCTURE  BAPIMEREQSOURCE OPTIONAL
gt_change_praccount LIKE bapimereqaccount OCCURS 0 WITH HEADER LINE,
*"      PRACCOUNTPROITSEGMENT STRUCTURE  BAPIMEREQACCOUNTPROFITSEG
*"       OPTIONAL
gt_change_praccountx LIKE bapimereqaccountx OCCURS 0 WITH HEADER LINE.
*"      PRADDRDELIVERY STRUCTURE  BAPIMERQADDRDELIVERY OPTIONAL
*"      PRITEMTEXT STRUCTURE  BAPIMEREQITEMTEXT OPTIONAL
*"      PRHEADERTEXT STRUCTURE  BAPIMEREQHEADTEXT OPTIONAL
*"      EXTENSIONIN STRUCTURE  BAPIPAREX OPTIONAL
*"      EXTENSIONOUT STRUCTURE  BAPIPAREX OPTIONAL
*"      PRVERSION STRUCTURE  BAPIMEREQDCM OPTIONAL
*"      PRVERSIONX STRUCTURE  BAPIMEREQDCMX OPTIONAL

DATA : gv_grid(1) VALUE 'X'.
DATA : gv_amount_dec6 TYPE p DECIMALS 6.
DATA : gv_save_sy_tabix LIKE sy-tabix.
DATA : gv_answer.
DATA : gv_text_message(60).
DATA : BEGIN OF gt_eban OCCURS 0,
       banfn LIKE eban-banfn,
       bnfpo LIKE eban-bnfpo,
       ebeln LIKE eban-ebeln,
       badat LIKE eban-badat,"Requisition (Request) Date
       lfdat LIKE eban-lfdat, "Item Delivery Date
       frgdt LIKE eban-frgdt, "Purchase Requisition Release Date
       bedat LIKE eban-bedat, "Purchase Order Date
       matnr LIKE eban-matnr,
       txz01 LIKE eban-txz01, "material text
       menge LIKE eban-menge, "Purchase Requisition Quantity
       meins LIKE eban-meins, "Purchase Requisition Unit of Measure
       ekgrp LIKE eban-ekgrp, "Purchasing Group
       afnam LIKE eban-afnam, "Name of Requisitioner/Requester

       lgort LIKE eban-lgort,
       blckd LIKE eban-blckd, "Purchase Requisition Blocked
       blckt LIKE eban-blckt, "Reason for Item Block
       preis LIKE eban-preis, "Price in Purchase Requisition
       peinh LIKE eban-peinh, "Price Unit
       rlwrt LIKE eban-rlwrt, "Total value at time of release
             "rlwrt = (preis/peinh)* menge
       loekz LIKE eban-loekz,
       waers LIKE eban-waers,

       werks LIKE eban-werks,
       reswk LIKE eban-reswk,

       del_indicator(4),

       option(1),
         END OF gt_eban.

DATA : gt_eban_header_option_x LIKE gt_eban OCCURS 0 WITH HEADER LINE.
DATA : gt_eban_option_x LIKE gt_eban OCCURS 0 WITH HEADER LINE.

DATA : BEGIN OF gt_t001w OCCURS 0,
       werks LIKE t001w-werks,
       END OF gt_t001w.

DATA : BEGIN OF gt_mara OCCURS 0,
       matnr LIKE mara-matnr,
       END OF gt_mara.

DATA : BEGIN OF gt_bsart_t161 OCCURS 0,
       bsart LIKE t161-bsart,
       END OF gt_bsart_t161.

* alv - start
* General -
CLASS cl_gui_object DEFINITION LOAD.
INCLUDE <cl_alv_control>.

DATA: gs_f4 TYPE lvc_s_f4,
      gt_f4 TYPE lvc_t_f4.

CLASS lcl_event_receiver DEFINITION DEFERRED.

DATA: gv_ls_mod_cells TYPE lvc_s_modi.
DATA: dg_ls_cells TYPE lvc_s_modi.
DATA: ls_cell TYPE lvc_s_styl.
DATA: gs_variant TYPE disvariant.
DATA: gt_fieldcat TYPE lvc_t_fcat.
*DATA: gt_fieldcat TYPE slis_t_fieldcat_alv WITH HEADER LINE.
DATA: gt_sort     TYPE lvc_t_sort.
DATA: gs_sort     TYPE lvc_s_sort.
DATA: gs_layout   TYPE lvc_s_layo.
DATA: gs_fieldcat TYPE lvc_s_fcat.

DATA : g_container TYPE scrfname VALUE 'CONTAINER',
       grid1  TYPE REF TO cl_gui_alv_grid,
       g_custom_container TYPE REF TO cl_gui_custom_container.

DATA  g_custom_container2 TYPE REF TO cl_gui_custom_container.

DATA: event_receiver TYPE REF TO lcl_event_receiver.

DATA:  is_row_id_set TYPE lvc_s_row,
       is_column_id_set TYPE lvc_s_col,
       is_row_no_set TYPE lvc_s_roid.

DATA: set_row4 TYPE lvc_s_roid.
DATA: my_col4 TYPE lvc_s_col.
DATA: set_row4r TYPE lvc_s_row.

DATA : it_celltab TYPE lvc_t_styl.
DATA: lt_dropdown TYPE lvc_t_drop,
      ls_dropdown TYPE lvc_s_drop.

*---------------------------------------------------------------------*
*       CLASS lcl_event_receiver DEFINITION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
CLASS lcl_event_receiver DEFINITION.
  PUBLIC SECTION.
    METHODS handle_data_changed
      FOR EVENT data_changed OF cl_gui_alv_grid
      IMPORTING er_data_changed.

    METHODS handle_f4
      FOR EVENT onf4 OF cl_gui_alv_grid
      IMPORTING e_fieldname
                e_fieldvalue
                es_row_no
                er_event_data
                et_bad_cells
                e_display.

ENDCLASS.                    "lcl_event_receiver DEFINITION

*--------------------------------------------------------------

*       CLASS lcl_event_receiver IMPLEMENTATION
*---------------------------------------------------------------

*       ........

*---------------------------------------------------------------

CLASS lcl_event_receiver IMPLEMENTATION.
  METHOD handle_data_changed.
    PERFORM data_changed USING er_data_changed.
  ENDMETHOD.                    "handle_data_changed

  METHOD handle_f4.
**    PERFORM f4 USING e_fieldname
**                     e_fieldvalue
**                     es_row_no
**                     er_event_data
**                     et_bad_cells
**                     e_display.

    PERFORM f4 USING e_fieldname
                     es_row_no
                     er_event_data
                     et_bad_cells.

  ENDMETHOD.                                                "handle_f4

ENDCLASS.                    "lcl_event_receiver IMPLEMENTATION

* alv - end

INCLUDE zmmrgb_0007_alv.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'ABC'.
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

AT SELECTION-SCREEN ON s_banfn.
  SELECT banfn INTO TABLE gt_eban
         FROM eban
         WHERE banfn IN s_banfn.
  IF s_banfn[] IS NOT INITIAL.
    IF gt_eban[] IS INITIAL.
      MESSAGE e398(00) WITH 'Purchase Requisition Number is not Exist'.
    ENDIF.
  ENDIF.

AT SELECTION-SCREEN ON s_werks.
  SELECT werks INTO TABLE gt_t001w
         FROM t001w
         WHERE werks IN s_werks.
  IF s_werks[] IS NOT INITIAL.
    IF gt_t001w[] IS INITIAL.
      MESSAGE e398(00) WITH 'Plant is not Exist'.
    ENDIF.
  ENDIF.

AT SELECTION-SCREEN ON s_matnr.
  SELECT matnr INTO TABLE gt_mara
         FROM mara
         WHERE matnr IN s_matnr.
  IF s_matnr[] IS NOT INITIAL.
    IF gt_mara[] IS INITIAL.
      MESSAGE e398(00) WITH 'Material is not Exist'.
    ENDIF.
  ENDIF.

AT SELECTION-SCREEN ON s_bsart.
  SELECT bsart INTO TABLE gt_bsart_t161
         FROM t161
         WHERE bsart IN s_bsart.
  IF s_bsart[] IS NOT INITIAL.
    IF gt_bsart_t161[] IS INITIAL.
      MESSAGE e398(00) WITH 'Document Type is not Exist'.
    ENDIF.
  ENDIF.

INITIALIZATION.
*  text_100 = 'Process Selected PR for Purchasing'.
*  text_101 = 'Enter Values for Purchasing Requisition Items'.
*  text_102 = 'Material'.
*C:\PROJECT\ptmn\BAPI_XXXXXXXXX (CALL FUNCTION) -- \ZBAPI_PR_CHANGE

START-OF-SELECTION.
  PERFORM get_data.
  PERFORM process_data.
  IF gt_eban[] IS NOT INITIAL.
    gv_detail_flag = 'X'.
    CLEAR : gv_posting_result_flag, gv_posting_result_flag_dtl.
    PERFORM fm_alv_display_data_dyn USING
                          'GT_EBAN'
                          'List Display of MRP Created PRs'.
    LOOP AT gi_it_fieldcat WHERE fieldname = 'OPTION'.
      gi_it_fieldcat-edit  = 'X'.
      gi_it_fieldcat-input = 'X'.
      MODIFY gi_it_fieldcat INDEX sy-tabix.
    ENDLOOP.
    SORT gt_eban BY banfn bnfpo ebeln badat lfdat frgdt bedat.
    PERFORM fm_alv_show TABLES gt_eban USING gv_grid. "#EC CI_FLDEXT_OK[2215424] P30K910018
  ENDIF.
*&---------------------------------------------------------------------*
*&      Form  get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_data.

  REFRESH gt_eban.
  CLEAR   gt_eban.

  IF s_banfn[] IS NOT INITIAL.
    SELECT banfn
           bnfpo
           ebeln
           badat "Requisition (Request) Date
           lfdat "Item Delivery Date
           frgdt "Purchase Requisition Release Date
           bedat "Purchase Order Date
           matnr
           txz01 "material text
           menge "Purchase Requisition Quantity
           meins "Purchase Requisition Unit of Measure
           ekgrp "Purchasing Group
           afnam "Name of Requisitioner/Requester

           lgort
           blckd "Purchase Requisition Blocked
           blckt "Reason for Item Block
           preis "Price in Purchase Requisition
           peinh "Price Unit
           rlwrt "Total value at time of release
                 "rlwrt = (preis/peinh)* menge
           loekz
           waers

           werks
           reswk

           INTO TABLE gt_eban
           FROM eban
           WHERE banfn IN s_banfn AND
                 matnr IN s_matnr AND
                 werks IN s_werks AND
                 bsart IN s_bsart AND
                 lgort IN s_lgort AND
                 knttp IN s_knttp AND
                 loekz EQ space.
  ELSE.
    SELECT banfn
           bnfpo
           ebeln
           badat "Requisition (Request) Date
           lfdat "Item Delivery Date
           frgdt "Purchase Requisition Release Date
           bedat "Purchase Order Date
           matnr
           txz01 "material text
           menge "Purchase Requisition Quantity
           meins "Purchase Requisition Unit of Measure
           ekgrp "Purchasing Group
           afnam "Name of Requisitioner/Requester

           lgort
           blckd "Purchase Requisition Blocked
           blckt "Reason for Item Block
           preis "Price in Purchase Requisition
           peinh "Price Unit
           rlwrt "Total value at time of release
                 "rlwrt = (preis/peinh)* menge
           loekz
           waers

           werks
           reswk

                 INTO TABLE gt_eban
                 FROM eban
                 WHERE matnr IN s_matnr AND
                       werks IN s_werks AND
                       bsart IN s_bsart AND
                       lgort IN s_lgort AND
                       knttp IN s_knttp AND
                       loekz EQ space.
    "using index 1 --> matnr / werks / loekz / matkl
  ENDIF.

* CR#9 - CLOSED BY RAMSES 03.04.2012 - START
  IF gt_eban[] IS INITIAL.
    MESSAGE s398(00) WITH 'No MRP created PRs available' DISPLAY LIKE 'E' .
  ENDIF.
* CR#9 - CLOSED BY RAMSES 03.04.2012 - END

  LOOP AT gt_eban.
    gv_save_sy_tabix = sy-tabix.
    IF gt_eban-loekz NE space.
      gt_eban-del_indicator = '@11@'.
    ENDIF.
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
      EXPORTING
        input                = gt_eban-MEINS
       language             = sy-langu
     IMPORTING
*       LONG_TEXT            =
       output               = gt_eban-MEINS
*       SHORT_TEXT           =
     EXCEPTIONS
       unit_not_found       = 1
       OTHERS               = 2
              .
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    MODIFY gt_eban INDEX gv_save_sy_tabix.
  ENDLOOP.

ENDFORM.                    "get_data.
*&---------------------------------------------------------------------*
*&      Form  process_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM process_data.
  LOOP AT gt_eban.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT' ""#EC CI_FLDEXT_OK[2215424] P30K910018
      EXPORTING
        input  = gt_eban-matnr
      IMPORTING
        output = gt_eban-matnr.

    gv_save_sy_tabix = sy-tabix.
    gv_amount_dec6 = ( gt_eban-preis / gt_eban-peinh ) * gt_eban-menge .
    gt_eban-rlwrt = gv_amount_dec6.
    MODIFY gt_eban INDEX gv_save_sy_tabix.
  ENDLOOP.
ENDFORM.                    "process_data
