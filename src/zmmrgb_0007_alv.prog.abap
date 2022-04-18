TYPE-POOLS : slis.

* for call bdc screen - start
DATA class_name TYPE c LENGTH 30 VALUE 'CL_SPFLI_PERSISTENT'.
DATA: bdcdata_wa  TYPE bdcdata,
      bdcdata_tab TYPE TABLE OF bdcdata.
DATA opt TYPE ctu_params.
* for call bdc screen - end

** ALV - HEADER - START
TYPE-POOLS : slis.
DATA : gv_it_list_top_of_page TYPE slis_t_listheader.
DATA : gv_is_list_top_of_page TYPE slis_listheader.
DATA : gv_formname_top_of_page TYPE slis_formname VALUE 'TOP_OF_PAGE'.
DATA : v_top_header LIKE gv_is_list_top_of_page-info.
DATA : v_top_selection_key_1 LIKE gv_is_list_top_of_page-key.
DATA : v_top_selection_info_1 LIKE gv_is_list_top_of_page-info.
DATA : v_top_selection_key_2 LIKE gv_is_list_top_of_page-key.
DATA : v_top_selection_info_2 LIKE gv_is_list_top_of_page-info.
DATA : v_top_selection_key_3 LIKE gv_is_list_top_of_page-key.
DATA : v_top_selection_info_3 LIKE gv_is_list_top_of_page-info.
DATA : v_top_selection_key_4 LIKE gv_is_list_top_of_page-key.
DATA : v_top_selection_info_4 LIKE gv_is_list_top_of_page-info.
DATA : v_top_selection_key_5 LIKE gv_is_list_top_of_page-key.
DATA : v_top_selection_info_5 LIKE gv_is_list_top_of_page-info.
DATA : v_top_action LIKE gv_is_list_top_of_page-info.
** ALV - HEADER - END

* for check box - start
DATA : gv_grid_setting TYPE lvc_s_glay.
* for check box - end

DATA gt_colour TYPE slis_t_specialcol_alv.

DATA : gw_is_layout               TYPE        slis_layout_alv,

       gi_it_fieldcat        TYPE        slis_t_fieldcat_alv WITH HEADER
 LINE,

       gi_it_excluding        TYPE        slis_t_extab        WITH
HEADER LINE,

       gi_it_special_groups        TYPE        slis_t_sp_group_alv WITH
HEADER LINE,

       gi_it_sort               TYPE        slis_t_sortinfo_alv WITH
HEADER LINE,

       gi_it_filter               TYPE        slis_t_filter_alv   WITH
HEADER LINE,

       gw_is_sel_hide        TYPE        slis_sel_hide_alv,

       gv_i_default,

       gv_i_save,

       gw_is_variant               LIKE        disvariant,

       gi_it_events               TYPE        slis_t_event        WITH
HEADER LINE,

       gi_it_event_exit        TYPE        slis_t_event_exit   WITH
HEADER LINE,

       gw_is_print               TYPE        slis_print_alv,

       gw_is_reprep_id        TYPE        slis_reprep_id.

DATA : gv_is_events TYPE slis_alv_event.
DATA : gv_it_events TYPE slis_t_event WITH HEADER LINE.


*&--------------------------------------------------------------------*

*&      Form  fm_alv_show

*&--------------------------------------------------------------------*

*       text

*---------------------------------------------------------------------*

*      -->FT_ITAB    text

*---------------------------------------------------------------------*

FORM fm_alv_show TABLES ft_itab USING fu_type .
  DATA : lv_alv(40),
         lv_tmp(40),
         lv_count TYPE n LENGTH 10.

  CLEAR gi_it_event_exit.

  gi_it_event_exit-ucomm = '&OUP'.

  gi_it_event_exit-after = 'X'.

  APPEND gi_it_event_exit.



  CLEAR gi_it_event_exit.

  gi_it_event_exit-ucomm = '&ODN'.

  gi_it_event_exit-after = 'X'.

  APPEND gi_it_event_exit.



  CLEAR gi_it_event_exit.

  gi_it_event_exit-ucomm = '&ETA'.

  gi_it_event_exit-after = 'X'.

  APPEND gi_it_event_exit.



  CLEAR gi_it_event_exit.

  gi_it_event_exit-ucomm = '&IC1'.

  gi_it_event_exit-after = 'X'.

  APPEND gi_it_event_exit.

  IF fu_type = 'X'.
    lv_alv = 'REUSE_ALV_GRID_DISPLAY'.
  ELSE.
    lv_alv = 'REUSE_ALV_LIST_DISPLAY'.
  ENDIF.

* for check-box
  gv_grid_setting-edt_cll_cb = 'X'.

**  lv_count = LINES( ft_itab ).
**  CONCATENATE lv_count ' record(s) will be display.' INTO lv_tmp.
**  MESSAGE i208(00) WITH  lv_tmp.

  CALL FUNCTION lv_alv
    EXPORTING
*      I_INTERFACE_CHECK              = ' '

*      I_BYPASSING_BUFFER             =

*      I_BUFFER_ACTIVE                = ' '

      i_callback_program             = sy-repid

      i_callback_pf_status_set       = 'FM_ALV_SET_PF_STATUS'

      i_callback_user_command        = 'FM_ALV_USER_COMMAND'

*      I_STRUCTURE_NAME               = ''

      is_layout                      = gw_is_layout

      it_fieldcat                    = gi_it_fieldcat[]

*      IT_EXCLUDING                   =

*      IT_SPECIAL_GROUPS              =

      it_sort                        = gi_it_sort[]

      it_filter                      = gi_it_filter[]

      is_sel_hide                    = gw_is_sel_hide

      i_default                      = gv_i_default

      i_save                         = gv_i_save

      is_variant                     = gw_is_variant

      it_events                      = gi_it_events[]

      it_event_exit                  = gi_it_event_exit[]

      is_print                       = gw_is_print

      i_grid_settings                = gv_grid_setting

      is_reprep_id                   = gw_is_reprep_id

*      I_SCREEN_START_COLUMN          = 0

*      I_SCREEN_START_LINE            = 0

*      I_SCREEN_END_COLUMN            = 0

*      I_SCREEN_END_LINE              = 0

*    IMPORTING

*      E_EXIT_CAUSED_BY_CALLER        =

*      ES_EXIT_CAUSED_BY_USER         =

    TABLES

      t_outtab                       = ft_itab

    EXCEPTIONS

      program_error                  = 1

      OTHERS                         = 2

            .

  IF sy-subrc <> 0.

* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO

*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.

  ENDIF.


ENDFORM.                    "fm_alv_show

*&---------------------------------------------------------------------*
*&      Form  top_of_page
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM top_of_page.

  PERFORM alv_header.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = gv_it_list_top_of_page.


ENDFORM.                    "TOP_OF_PAGE


*&--------------------------------------------------------------------*

*&      Form  fm_alv_reset_data

*&--------------------------------------------------------------------*

*       text

*---------------------------------------------------------------------*

FORM fm_alv_reset_data.

  CLEAR : gw_is_layout,

          gi_it_fieldcat,

          gi_it_excluding,

          gi_it_special_groups,

          gi_it_sort,

          gi_it_filter,

          gw_is_sel_hide,

          gv_i_default,

          gv_i_save,

          gw_is_variant,

          gi_it_events,

          gi_it_event_exit,

          gw_is_print,

          gw_is_reprep_id.



  REFRESH : gi_it_fieldcat,

            gi_it_excluding,

            gi_it_special_groups,

            gi_it_sort,

            gi_it_filter,

            gi_it_events,

            gi_it_event_exit.



ENDFORM.                    "fm_alv_reset_data



*&--------------------------------------------------------------------*

*&      Form  fm_alv_set_layout

*&--------------------------------------------------------------------*

*       text

*---------------------------------------------------------------------*

FORM fm_alv_set_layout USING fu_tabname fu_title.

  gw_is_layout-window_titlebar    = fu_title.

*  gw_is_layout-coltab_fieldname  = 'COLOR'.

  gw_is_layout-zebra              = 'X'.

  gw_is_layout-colwidth_optimize  = 'X'.

  gw_is_layout-no_colhead         = space.

  gw_is_layout-group_change_edit  = 'X'.

*  gw_is_layout-box_fieldname      = 'OPTION'.
*
*  gw_is_layout-box_tabname        = fu_tabname.


ENDFORM.                    "fm_alv_set_layout



*&--------------------------------------------------------------------*

*&      Form  fm_alv_set_print

*&--------------------------------------------------------------------*

*       text

*---------------------------------------------------------------------*

FORM fm_alv_set_print.

  gw_is_print-no_print_listinfos    = 'X'.

  gw_is_print-no_print_selinfos     = 'X'.

  gw_is_print-no_coverpage          = 'X'.

  gw_is_print-no_print_hierseq_item = 'X'.

ENDFORM.                    "fm_alv_set_print





*&--------------------------------------------------------------------*

*&      Form  fm_alv_add_fieldcat

*&--------------------------------------------------------------------*

*       text

*---------------------------------------------------------------------*

*      -->FU_1       text

*      -->FU_2       text

*      -->FU_3       text

*      -->FU_4       text

*      -->FU_5       text

*      -->FU_6       text

*      -->FU_7       text

*      -->FU_8       text

*      -->FU_9       text

*      -->FU_10      text

*      -->FU_11      text

*      -->FU_12      text

*      -->FU_13      text

*      -->FU_14      text

*      -->FU_15      text

*      -->FU_16      text

*      -->FU_17      text

*      -->FU_18      text

*      -->FU_19      text

*      -->FU_20      text

*      -->FU_21      text

*---------------------------------------------------------------------*

FORM fm_alv_add_fieldcat USING fu_1  fu_2  fu_3  fu_4  fu_5  fu_6  fu_7
 fu_8  fu_9  fu_10

                               fu_11 fu_12 fu_13 fu_14 fu_15 fu_16 fu_17
 fu_18 fu_19 fu_20 fu_21 fu_22.



  CLEAR: gi_it_fieldcat.

  gi_it_fieldcat-fieldname     = fu_1.  " Fieldname

  gi_it_fieldcat-tabname   = fu_2.  " Tablename

  gi_it_fieldcat-ref_fieldname = fu_3.  " Reference Fieldname

  gi_it_fieldcat-no_out        = fu_4.  " (O)blig.(X)no out

  gi_it_fieldcat-outputlen     = fu_5.  " Output length

  gi_it_fieldcat-seltext_l     = fu_6.  " long key word

  gi_it_fieldcat-seltext_m     = fu_7.  " middle key word

  gi_it_fieldcat-seltext_s     = fu_8.  " short key word

  gi_it_fieldcat-reptext_ddic  = fu_9.  " heading (ddic)

  gi_it_fieldcat-round         = fu_10. " round in write statement

  gi_it_fieldcat-do_sum        = fu_11. " sum up

  gi_it_fieldcat-hotspot       = fu_12.
  " 'X' = hotspot is active -> event click

  gi_it_fieldcat-decimals_out  = fu_13. " decimals in write statement

  gi_it_fieldcat-currency      = fu_14.

  gi_it_fieldcat-quantity      = fu_15.

  gi_it_fieldcat-qfieldname    = fu_16. " field with quantity unit

  gi_it_fieldcat-cfieldname    = fu_17. " field with currency unit

  gi_it_fieldcat-checkbox      = fu_18.
  " 'X' = checkbox or ' ' = not checkbox

  gi_it_fieldcat-icon          = fu_19. " 'X' = icon or ' ' = not icon

  gi_it_fieldcat-fix_column    = fu_20.
  " 'X' = Fix Column On or ' ' = fix column off  gi_it_fieldcat-key
*      = &21. "

  gi_it_fieldcat-key           = fu_21. " 'X' = Key or ' ' = not Key

  gi_it_fieldcat-ddictxt       = fu_22. " (S)hort (M)iddle (L)ong



  APPEND gi_it_fieldcat.

ENDFORM.                    "fm_alv_add_fieldcat





*&--------------------------------------------------------------------*

*&      Form  FM_ALV_SET_PF_STATUS

*&--------------------------------------------------------------------*

*       text

*---------------------------------------------------------------------*

*      -->RT_EXTAB   text

*---------------------------------------------------------------------*

FORM fm_alv_set_pf_status USING rt_extab TYPE slis_t_extab.

  IF gv_detail_flag EQ 'X'.
    SET PF-STATUS 'ZSTANDARD'.
  ENDIF.
  IF gv_posting_result_flag EQ 'X' OR
     gv_posting_result_flag_dtl EQ 'X'.
    SET PF-STATUS 'ZSTANDARD_POST'.
  ENDIF.

ENDFORM.                    "fm_alv_set_pf_status



*&--------------------------------------------------------------------*

*&      Form  FM_USER_COMMAND

*&--------------------------------------------------------------------*

*       text

*---------------------------------------------------------------------*

FORM fm_alv_user_command USING fu_ucomm    LIKE sy-ucomm

                         fu_selfield TYPE slis_selfield.

***
*** gunanya adalah : meng-handle semua aktifitas tombol yg ditekan
***                  oleh user termasuk tombol sorting
*** catatan : subroutine ini lebih baik dipindahkan dibagian
***           program utama
***

  DATA: lt_dynpread LIKE dynpread OCCURS 0 WITH HEADER LINE.



  MOVE fu_ucomm TO gv_okcode_main.




  CASE gv_okcode_main.
    WHEN '&IC1'.

      CASE fu_selfield-fieldname.

*        WHEN 'BELNR'.
*          IF gt_list_detail_temp[] IS NOT INITIAL.
*            "meaning the initial ALV is SUMMARY LEVEL
*            READ TABLE gt_list_detail_temp INDEX fu_selfield-tabindex.
*            IF sy-subrc EQ 0.
*              SET PARAMETER ID 'BLN' FIELD gt_list_detail_temp-belnr.
*              SET PARAMETER ID 'BUK' FIELD gt_list_detail_temp-bukrs.
*              SET PARAMETER ID 'GJR' FIELD gt_list_detail_temp-gjahr.
*              CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
*            ENDIF.
*          ELSE.
*            READ TABLE gt_list_detail INDEX fu_selfield-tabindex.
*            IF sy-subrc EQ 0.
*              SET PARAMETER ID 'BLN' FIELD gt_list_detail-belnr.
*              SET PARAMETER ID 'BUK' FIELD gt_list_detail-bukrs.
*              SET PARAMETER ID 'GJR' FIELD gt_list_detail-gjahr.
*              CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
*            ENDIF.
*          ENDIF.
        WHEN 'BANFN'.
          READ TABLE gt_eban INDEX fu_selfield-tabindex.
          IF sy-subrc EQ 0.
            SET PARAMETER ID 'BAN' FIELD gt_eban-banfn.
            IF gt_eban-banfn NE space.
              CALL TRANSACTION 'ME53N' AND SKIP FIRST SCREEN.
            ENDIF.
          ENDIF.
        WHEN 'BANFN_POSTING'.
          READ TABLE gt_header_posting_result INDEX fu_selfield-tabindex.
          IF sy-subrc EQ 0.
            SET PARAMETER ID 'BAN' FIELD gt_header_posting_result-banfn_posting.
            IF gt_header_posting_result-banfn_posting NE space.
              CALL TRANSACTION 'ME53N' AND SKIP FIRST SCREEN.
            ENDIF.
          ENDIF.
        WHEN 'BANFN_POSTING_DEL'.
          READ TABLE gt_header_posting_result_dtl INDEX fu_selfield-tabindex.
          IF sy-subrc EQ 0.
            SET PARAMETER ID 'BAN' FIELD gt_header_posting_result_dtl-banfn_posting_del.
            IF gt_header_posting_result_dtl-banfn_posting_del NE space.
              CALL TRANSACTION 'ME53N' AND SKIP FIRST SCREEN.
            ENDIF.
          ENDIF.
        WHEN 'EBELN'.
          READ TABLE gt_eban INDEX fu_selfield-tabindex.
          IF sy-subrc EQ 0.
            SET PARAMETER ID 'BES' FIELD gt_eban-ebeln.
            IF gt_eban-ebeln NE space.
              CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
            ENDIF.
          ENDIF.
      ENDCASE.

    WHEN 'SEL_ALL'.
      LOOP AT gt_eban.
        gt_eban-option = 'X'.
        MODIFY gt_eban INDEX sy-tabix.
      ENDLOOP.

    WHEN 'DESEL_ALL'.
      LOOP AT gt_eban.
        CLEAR gt_eban-option.
        MODIFY gt_eban INDEX sy-tabix.
      ENDLOOP.

    WHEN 'SEL_CHANGE' OR 'DEL_CHANGE' OR 'SEL_GROUP'.

      REFRESH : gt_header_posting_result, gt_header_posting_result_dtl.
      CLEAR   : gt_header_posting_result, gt_header_posting_result_dtl.

      SORT gt_eban BY banfn bnfpo ebeln badat lfdat frgdt bedat.

      gt_eban_header_option_x[] = gt_eban[].
      DELETE gt_eban_header_option_x WHERE option EQ space.
      SORT gt_eban_header_option_x BY banfn.
      DELETE ADJACENT DUPLICATES FROM gt_eban_header_option_x COMPARING banfn.

      gt_eban_option_x[] = gt_eban[].
      DELETE gt_eban_option_x WHERE option EQ space.

      IF gv_okcode_main EQ 'SEL_CHANGE' OR
         gv_okcode_main EQ 'DEL_CHANGE'.

        LOOP AT gt_eban_header_option_x WHERE option EQ 'X'.

          PERFORM bapi_initial.
          PERFORM bapi_get_detail.

          LOOP AT gt_eban WHERE banfn EQ gt_eban_header_option_x-banfn AND
                                option EQ 'X'.
            gv_save_sy_tabix = sy-tabix.

            IF gv_okcode_main EQ 'SEL_CHANGE'.
              IF gt_eban-del_indicator NE space.
                CONCATENATE 'Purchase Requisition :' gt_eban-banfn
                            'Line :' gt_eban-bnfpo
                            INTO gv_text_message SEPARATED BY space.
                MESSAGE i398(00) WITH gv_text_message
                                      'is deleted.'
                                      'Data can not be changed.'.
              ELSE.
                CLEAR gt_detail_pritem.
                READ TABLE gt_detail_pritem WITH KEY preq_item = gt_eban-bnfpo.
                CLEAR gt_detail_praccount.
                READ TABLE gt_detail_praccount WITH KEY preq_item = gt_eban-bnfpo.

                p_knttp = 'K'. "gt_detail_pritem-acctasscat.
                p_menge = gt_detail_pritem-quantity.
                p_meins = gt_detail_pritem-unit.
                p_ekgrp = gt_detail_pritem-pur_group.
                p_afnam = gt_detail_pritem-preq_name.
                p_kostl = gt_detail_praccount-costcenter.
                p_ablad = gt_detail_praccount-unload_pt.
                p_wempf = gt_detail_praccount-gr_rcpt.

                CALL SCREEN 100 STARTING AT 40 8.
              ENDIF.
            ENDIF.

            IF gv_okcode_main EQ 'DEL_CHANGE'.
              LOOP AT gt_detail_pritem WHERE preq_item EQ gt_eban-bnfpo.
                MOVE-CORRESPONDING gt_detail_pritem TO gt_change_pritem.
                gt_change_pritem-delete_ind  = 'X'.
                APPEND gt_change_pritem.

                gt_change_pritemx-preq_item   = gt_detail_pritem-preq_item.
                gt_change_pritemx-preq_itemx  = 'X'.
                gt_change_pritemx-delete_ind  = 'X'.
                APPEND gt_change_pritemx.
              ENDLOOP.
            ENDIF.

            CLEAR gt_eban-option.
            MODIFY gt_eban INDEX gv_save_sy_tabix.
          ENDLOOP.

          gs_prheaderx-preq_no = 'X'.

          IF gt_change_pritem[] IS NOT INITIAL.
            PERFORM bapi_change.

            DESCRIBE TABLE gt_change_return LINES gv_line_return.
            CLEAR gt_change_return.
            READ TABLE gt_change_return INDEX gv_line_return.
            CONCATENATE gt_change_return-message
                        gt_change_return-message_v2
                        gt_change_return-message_v3
                        gt_change_return-message_v4
                        gt_change_return-parameter
                        INTO gt_header_posting_result-message
                        SEPARATED BY '/'.

            CLEAR gv_success_bapi_process.
            PERFORM bapi_recheck.

            gt_header_posting_result-banfn_posting = gt_eban_header_option_x-banfn.

            IF gv_success_bapi_process EQ space.
              gt_header_posting_result-status = '@02@'.  "'FAIL'.
              IF gt_header_posting_result-message CS 'cross company codes is not allowed'.
                gt_header_posting_result-custom_message = 'Cross Company Codes not allowed'.
              ELSE.
                gt_header_posting_result-custom_message = gt_header_posting_result-message.
              ENDIF.
            ELSE.
              gt_header_posting_result-status = '@01@'.  "'SUCCESS'.
              IF gv_okcode_main EQ 'SEL_CHANGE' OR
                 gv_okcode_main EQ 'SEL_GROUP'.
                gt_header_posting_result-custom_message = 'Purchase Requisition successfully Updated'.
              ENDIF.
              IF gv_okcode_main EQ 'DEL_CHANGE'.
                gt_header_posting_result-custom_message = 'Purchase Requisition successfully Deleted'.
              ENDIF.
            ENDIF.
            APPEND gt_header_posting_result.
            CLEAR gt_header_posting_result.
          ENDIF.

        ENDLOOP.
      ENDIF.

      IF gv_okcode_main EQ 'SEL_GROUP'.
        CLEAR : p_knttp, p_ekgrp, p_afnam, p_kostl, p_ablad, p_wempf.
        CLEAR : gt_eban.
        READ TABLE gt_eban_option_x WITH KEY loekz = 'X'.
        IF sy-subrc EQ 0.

          CONCATENATE 'Purchase Requisition :' gt_eban_option_x-banfn
                      'Line :' gt_eban_option_x-bnfpo
                      INTO gv_text_message SEPARATED BY space.
          MESSAGE i398(00) WITH gv_text_message
                                'is deleted.'
                                'Data can not be changed.'.

        ELSE.

          LOOP AT gt_eban_header_option_x WHERE option EQ 'X'.

            PERFORM bapi_initial.
            PERFORM bapi_get_detail.

            CLEAR gt_eban.
            READ TABLE gt_eban WITH KEY banfn = gt_eban_header_option_x-banfn
                                        option = 'X'.

            CLEAR gt_detail_pritem.
            READ TABLE gt_detail_pritem WITH KEY preq_item = gt_eban-bnfpo.
            CLEAR gt_detail_praccount.
            READ TABLE gt_detail_praccount WITH KEY preq_item = gt_eban-bnfpo.

            p_knttp = 'K'. "gt_detail_pritem-acctasscat.
            p_menge = gt_detail_pritem-quantity.
            p_meins = gt_detail_pritem-unit.
            p_ekgrp = gt_detail_pritem-pur_group.
            p_afnam = gt_detail_pritem-preq_name.
            p_kostl = gt_detail_praccount-costcenter.
            p_ablad = gt_detail_praccount-unload_pt.
            p_wempf = gt_detail_praccount-gr_rcpt.

            EXIT.
          ENDLOOP.

          IF gt_eban_header_option_x[] IS NOT INITIAL.
            PERFORM prepare_alv_200.
            CALL SCREEN 200 STARTING AT 35 5.
          ENDIF.

        ENDIF.

      ENDIF.

      IF gt_header_posting_result_dtl[] IS NOT INITIAL.
        CLEAR : gv_detail_flag.
        CLEAR : gv_posting_result_flag.
        gv_posting_result_flag_dtl = 'X'.
        PERFORM fm_alv_display_data_dyn USING
                              'gt_header_posting_result_dtl'
                              'Purchase Requisition Posting Result'.
        SORT gt_header_posting_result_dtl BY banfn_posting_del bnfpo_posting.
        PERFORM fm_alv_show TABLES gt_header_posting_result_dtl USING gv_grid. "#EC CI_FLDEXT_OK[2215424] P30K910018
        gv_detail_flag = 'X'.
        CLEAR : gv_posting_result_flag_dtl, gv_posting_result_flag.
      ELSE.
        IF gt_header_posting_result[] IS NOT INITIAL.
          CLEAR : gv_detail_flag.
          CLEAR : gv_posting_result_flag_dtl.
          gv_posting_result_flag = 'X'.
          PERFORM fm_alv_display_data_dyn USING
                                'GT_HEADER_POSTING_RESULT'
                                'Purchase Requisition Posting Result'.
          SORT gt_header_posting_result BY banfn_posting.
          PERFORM fm_alv_show TABLES gt_header_posting_result USING gv_grid.
          gv_detail_flag = 'X'.
          CLEAR : gv_posting_result_flag, gv_posting_result_flag_dtl.
        ENDIF.
      ENDIF.

  ENDCASE.



  MOVE 'X' TO fu_selfield-refresh.



ENDFORM.                    "FM_USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  fm_alv_display_data_dyn
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_GRID    text
*      -->FU_TABNAME text
*      -->FU_TITLE   text
*----------------------------------------------------------------------*
FORM fm_alv_display_data_dyn USING fu_tabname
                                   fu_title.
  PERFORM fm_alv_reset_data.

*  Set ALV Parameters and Data
  PERFORM fm_alv_set_layout USING fu_tabname fu_title.
  PERFORM fm_alv_set_print.
  PERFORM fm_alv_set_column_dyn USING fu_tabname.

  gv_i_default = 'X'.
  gv_i_save = 'A'.

ENDFORM.                    "fm_alv_display_data_dyn

*&---------------------------------------------------------------------*
*&      Form  fm_alv_set_column
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM fm_alv_set_column_dyn USING fu_tabname.
  DATA : li_dd03l LIKE STANDARD TABLE OF dd03l WITH HEADER LINE.
  DATA : lv_coloumname(30) TYPE c,
         lv_scrtext_s TYPE scrtext_s,
         lv_scrtext_m TYPE scrtext_m,
         lv_scrtext_l TYPE scrtext_l,
         lv_length TYPE outputlen,
         lv_ddtext TYPE as4text,
         lv_ddictxt.

  IF gv_detail_flag = 'X'.
    PERFORM fm_alv_add_fieldcat USING:
  'OPTION' fu_tabname  '' '' '' 'Select'
  '' '' '' '' '' '' '' '' '' '' '' 'X' '' '' '' 'L',
  'BANFN' fu_tabname  '' '' '' 'Purch. Req.'
  '' '' '' '' '' 'X' '' '' '' '' '' '' '' '' '' 'L',
  'EBELN' fu_tabname  '' '' '' 'PO'
  '' '' '' '' '' 'X' '' '' '' '' '' '' '' '' '' 'L',
  'BADAT' fu_tabname  '' '' '' 'Req. Date'
  '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' 'L',
  'LFDAT' fu_tabname  '' '' '' 'Delv. Date'
  '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' 'L',
  'BNFPO' fu_tabname  '' '' '' 'Item'
  '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' 'L',
  'MATNR' fu_tabname  '' '' '' 'Material'
  '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' 'L',
  'TXZ01' fu_tabname  '' '' '' 'Short Text'
  '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' 'L',
  'MENGE' fu_tabname  '' '' '' 'Quantity'
  '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' 'L',
  'MEINS' fu_tabname  '' '' '' 'Unit'
  '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' 'L',
  'EKGRP' fu_tabname  '' '' '' 'PGr'
  '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' 'L',
  'AFNAM' fu_tabname  '' '' '' 'Requisnr.'
  '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' 'L',
  'DEL_INDICATOR' fu_tabname  '' 'X' '' 'D'
  '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' 'L',
  'LGORT' fu_tabname  '' '' '' 'SLoc'
  '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' 'L',
  'BLCKD' fu_tabname  '' '' '' 'Block'
  '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' 'L',
  'BLCKT' fu_tabname  '' '' '' 'Blkg Text'
  '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' 'L',
  'RLWRT' fu_tabname  '' '' '' 'Total Value'
  '' '' '' '' 'X' '' '' '' '' '' 'WAERS' '' '' '' '' 'L',
  'WAERS' fu_tabname  '' 'X' '' 'Curr'
  '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' 'L'.
    PERFORM fm_alv_sort_data.

    PERFORM alv_header.
  ENDIF.
  IF gv_posting_result_flag EQ 'X'.
    PERFORM fm_alv_add_fieldcat USING:
  'BANFN_POSTING' fu_tabname  '' '' '' 'Purch. Req.'
  '' '' '' '' '' 'X' '' '' '' '' '' '' '' '' '' 'L',
  'STATUS' fu_tabname  '' '' '' 'Status'
  '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' 'L',
  'CUSTOM_MESSAGE' fu_tabname  '' '' '' 'Message'
  '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' 'L',
  'MESSAGE' fu_tabname  '' 'X' '' 'Original Message'
  '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' 'L'.
  ENDIF.
  IF gv_posting_result_flag_dtl EQ 'X'.
    PERFORM fm_alv_add_fieldcat USING:
  'BANFN_POSTING_DEL' fu_tabname  '' '' '' 'Purch. Req.'
  '' '' '' '' '' 'X' '' '' '' '' '' '' '' '' '' 'L',
  'BNFPO_POSTING' fu_tabname  '' '' '' 'Item'
  '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' 'L',
  'MATNR_POSTING' fu_tabname  '' '' '' 'Material'
  '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' 'L',
  'TXZ01_POSTING' fu_tabname  '' '' '' 'Short Text'
  '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' 'L',
  'STATUS' fu_tabname  '' '' '' 'Status'
  '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' 'L',
  'CUSTOM_MESSAGE' fu_tabname  '' '' '' 'Message'
  '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' 'L',
  'MESSAGE' fu_tabname  '' 'X' '' 'Original Message'
  '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' 'L'.
  ENDIF.
ENDFORM.                    "fm_alv_set_column
*&---------------------------------------------------------------------*
*&      Form  fm_alv_sort_data_detail
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM fm_alv_sort_data.
*  Sort and Group by Field


*    CLEAR gi_it_sort.
*    gi_it_sort-spos      = '1'.     "POSITION
*    gi_it_sort-fieldname = 'GSBER'. ">> Filled by Fieldname
*    gi_it_sort-up        = 'X'.
*    ">> 'X' = Ascending ; ' ' = descending
*    gi_it_sort-subtot    = 'X'.
*    gi_it_sort-group     = '*'.
*    ">> '*' = Grouped by field ; ' ' = not grouped by this field
*    APPEND gi_it_sort.
*
*    CLEAR gi_it_sort.
*    gi_it_sort-spos      = '2'.     "POSITION
*    gi_it_sort-fieldname = 'KUNNR'. ">> Filled by Fieldname
*    gi_it_sort-up        = 'X'.
*    ">> 'X' = Ascending ; ' ' = descending
*    gi_it_sort-subtot    = 'X'.
*    gi_it_sort-group     = '*'.
*    ">> '*' = Grouped by field ; ' ' = not grouped by this field
*    APPEND gi_it_sort.





ENDFORM.                    "fm_alv_sort_data
*&---------------------------------------------------------------------*
*&      Form  FM_ALV_SET_COLUMN_COLOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fm_alv_set_column_color .

  REFRESH gt_colour.
  CLEAR   gt_colour.
*  PERFORM col_color USING:
*
*      'FIELD_NAME1' c_colour_green gt_colour,
*      'FIELD_NAME2' c_colour_green gt_colour.

ENDFORM.                    " FM_ALV_SET_COLUMN_COLOR
*&---------------------------------------------------------------------*
*&      Form  col_color
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->IM_FIELD      text
*      -->IM_COLOR      text
*      -->IM_COLOR_TAB  text
*----------------------------------------------------------------------*
FORM col_color USING im_field
                     im_color
                     im_color_tab TYPE slis_t_specialcol_alv.

  DATA: ls_cell_color TYPE slis_color,
        lw_color_tab TYPE slis_specialcol_alv.

  ls_cell_color-col = im_color.
  ls_cell_color-int = 0.

  lw_color_tab-fieldname = im_field.
  lw_color_tab-color     = ls_cell_color.

  APPEND lw_color_tab TO im_color_tab.

ENDFORM.                    " COL_COLOR
*FORM prepare_bdc_call_screen.
*
*  REFRESH bdcdata_tab.
*
*  CLEAR bdcdata_wa.
*  bdcdata_wa-program  = 'SAPMF02C'.
*  bdcdata_wa-dynpro   = '0100'.
*  bdcdata_wa-dynbegin = 'X'.
*  APPEND bdcdata_wa TO bdcdata_tab.
*
*
****
*  CLEAR bdcdata_wa.
*  bdcdata_wa-fnam = 'BDC_CURSOR'.
*  bdcdata_wa-fval = 'RF02L-KUNNR'.
*  APPEND bdcdata_wa TO bdcdata_tab.
*
*  CLEAR bdcdata_wa.
*  bdcdata_wa-fnam = 'RF02L-KUNNR'.
*  bdcdata_wa-fval = gv_kunnr_input.
*  APPEND bdcdata_wa TO bdcdata_tab.
*
*
****
*  CLEAR bdcdata_wa.
*  bdcdata_wa-fnam = 'BDC_CURSOR'.
*  bdcdata_wa-fval = 'RF02L-KKBER'.
*  APPEND bdcdata_wa TO bdcdata_tab.
*
*  CLEAR bdcdata_wa.
*  bdcdata_wa-fnam = 'RF02L-KKBER'.
*  bdcdata_wa-fval = gt_list_summary-kkber.
*  APPEND bdcdata_wa TO bdcdata_tab.
*
****
*  CLEAR bdcdata_wa.
*  bdcdata_wa-fnam = 'BDC_CURSOR'.
*  bdcdata_wa-fval = 'RF02L-D0210'.
*  APPEND bdcdata_wa TO bdcdata_tab.
*
*  CLEAR bdcdata_wa.
*  bdcdata_wa-fnam = 'RF02L-D0210'.
*  bdcdata_wa-fval = 'X'.
*  APPEND bdcdata_wa TO bdcdata_tab.
*
*
*  CLEAR bdcdata_wa.
*  bdcdata_wa-fnam = 'BDC_OKCODE'.
*  bdcdata_wa-fval = '/00'.
*  APPEND bdcdata_wa TO bdcdata_tab.
*
*  opt-dismode = 'E'.
*  opt-defsize = 'X'.
*
*ENDFORM.                    " PREPARE_BDC_CALL_SCREEN
*&---------------------------------------------------------------------*
*&      Form  alv_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM alv_header .


  REFRESH : gv_it_list_top_of_page, gi_it_events.
  CLEAR   : gv_it_list_top_of_page, gi_it_events.

  CLEAR : v_top_header, v_top_selection_key_1.
*  IF p_detail = 'X'.
*    v_top_header =
*  ELSE.
*    v_top_header =
*  ENDIF.
  PERFORM get_list_top_of_page USING v_top_header 'H' v_top_selection_key_1.

  CLEAR : v_top_header, v_top_selection_key_1.
  READ TABLE s_banfn INDEX 1.
  v_top_selection_key_1 = 'Purch. Requisition : '.
  CONCATENATE s_banfn-low
              '-'
              s_banfn-high
              INTO v_top_header SEPARATED BY space.
  PERFORM get_list_top_of_page USING v_top_header 'S' v_top_selection_key_1.

  CLEAR : v_top_header, v_top_selection_key_1.
  READ TABLE s_werks INDEX 1.
  v_top_selection_key_1 = 'Plant : '.
  CONCATENATE s_werks-low
              '-'
              s_werks-high
              INTO v_top_header SEPARATED BY space.
  PERFORM get_list_top_of_page USING v_top_header 'S' v_top_selection_key_1.

  CLEAR : v_top_header, v_top_selection_key_1.
  READ TABLE s_lgort INDEX 1.
  v_top_selection_key_1 = 'Storage Location :'.
  CONCATENATE s_lgort-low
              '-'
              s_lgort-high
              INTO v_top_header SEPARATED BY space.
  PERFORM get_list_top_of_page USING v_top_header 'S' v_top_selection_key_1.

  CLEAR : v_top_header, v_top_selection_key_1.
  READ TABLE s_werks INDEX 1.
  v_top_selection_key_1 = 'Material : '.
  CONCATENATE s_matnr-low "#EC CI_FLDEXT_OK[2215424] P30K910018
              '-'
              s_matnr-high
              INTO v_top_header SEPARATED BY space.
  PERFORM get_list_top_of_page USING v_top_header 'S' v_top_selection_key_1.

  CLEAR : v_top_header, v_top_selection_key_1.
  READ TABLE s_bsart INDEX 1.
  v_top_selection_key_1 = 'Document Type : '.
  CONCATENATE s_bsart-low
              '-'
              s_bsart-high
              INTO v_top_header SEPARATED BY space.
  PERFORM get_list_top_of_page USING v_top_header 'S' v_top_selection_key_1.

  CLEAR : v_top_header, v_top_selection_key_1.
  READ TABLE s_knttp INDEX 1.
  v_top_selection_key_1 = 'Acct AssignmentCat :'.
  CONCATENATE s_knttp-low
              '-'
              s_knttp-high
              INTO v_top_header SEPARATED BY space.
  PERFORM get_list_top_of_page USING v_top_header 'S' v_top_selection_key_1.


ENDFORM.                    " ALV_HEADER
*&---------------------------------------------------------------------*
*&      Form  get_list_top_of_page
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_V_TOP_HEADER           text
*      -->P_V_TOP_SELECTION_KEY_1  text
*      -->P_V_SELECTION_INFO_1     text
*      -->P_V_TOP_SELECTION_KEY_2  text
*      -->P_V_SELECTION_INFO_2     text
*      -->P_V_TOP_ACTION           text
*----------------------------------------------------------------------*
FORM get_list_top_of_page  USING    p_v_top_header
                                    p_type
                                    p_v_top_selection_key_1.
*                                    p_v_selection_info_1
*                                    p_v_top_selection_key_2
*                                    p_v_selection_info_2
*                                    p_v_top_action.

  CLEAR gv_is_list_top_of_page.
  gv_is_list_top_of_page-typ  = p_type.
  gv_is_list_top_of_page-key = p_v_top_selection_key_1.
  gv_is_list_top_of_page-info = p_v_top_header.
  APPEND gv_is_list_top_of_page TO gv_it_list_top_of_page.

** Kopfinfo: Typ S
*  CLEAR gv_is_list_top_of_page.
*  gv_is_list_top_of_page-typ  = 'S'.
*  gv_is_list_top_of_page-key  = p_v_top_selection_key_1.
*  gv_is_list_top_of_page-info = p_v_selection_info_1.
*  APPEND gv_is_list_top_of_page TO gv_it_list_top_of_page.
*  gv_is_list_top_of_page-key  = p_v_top_selection_key_2.
*  gv_is_list_top_of_page-info = p_v_selection_info_2.
*  APPEND gv_is_list_top_of_page TO gv_it_list_top_of_page.
** Aktionsinfo: Typ A
*  CLEAR gv_is_list_top_of_page.
*  gv_is_list_top_of_page-typ  = 'A'.
** gv_is_list_top_of_page-KEY:  not used for this type
*  gv_is_list_top_of_page-info = p_v_top_action.
*  APPEND gv_is_list_top_of_page TO  gv_it_list_top_of_page.

  MOVE gv_formname_top_of_page TO gv_is_events-form.
  MOVE gv_formname_top_of_page TO gv_is_events-name.
  APPEND gv_is_events TO gi_it_events.


ENDFORM.                    " get_list_top_of_page
*&---------------------------------------------------------------------*
*&      Form  get_events
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_events .

  MOVE gv_formname_top_of_page TO gv_is_events-form.
  MOVE gv_formname_top_of_page TO gv_is_events-name.
  APPEND gv_is_events TO gv_it_events.

ENDFORM.                    " get_events
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  IF okcode_100 EQ 'CONFIRM'.

    IF gv_not_valid_100 EQ space.
      CLEAR gv_answer.
      PERFORM popup_confirm.
    ENDIF.

  ENDIF.
  IF okcode_100 EQ 'CANCEL'.
    SET SCREEN 0.
    LEAVE SCREEN.
  ENDIF.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&      Form  UPDATE_PR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM prepare_bapi_change.

  LOOP AT gt_detail_pritem WHERE preq_item EQ gt_eban-bnfpo.
    MOVE-CORRESPONDING gt_detail_pritem TO gt_change_pritem.
    gt_change_pritem-acctasscat = p_knttp.
    gt_change_pritem-pur_group  = p_ekgrp.
    gt_change_pritem-preq_name  = p_afnam.

    IF p_menge NE gt_detail_pritem-quantity.
      gt_change_pritem-quantity = p_menge.
    ELSE.
      gt_change_pritem-quantity = gt_detail_pritem-quantity.
    ENDIF.

*    IF gt_eban-meins NE gt_detail_pritem-unit.
*      gt_change_pritem-unit       = p_meins.

    IF gt_eban-meins NE gt_detail_pritem-po_unit.
CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
  EXPORTING
    input                = p_meins
   language             = sy-langu
 IMPORTING
   output               = gt_change_pritem-po_unit
 EXCEPTIONS
   unit_not_found       = 1
   OTHERS               = 2
          .
IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
ENDIF.
gt_change_pritem-po_unit_iso = gt_change_pritem-po_unit.

    ELSE.
*      gt_change_pritem-unit       = gt_eban-meins.
CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
  EXPORTING
    input                = gt_eban-meins
   language             = sy-langu
 IMPORTING
   output               = gt_change_pritem-po_unit
 EXCEPTIONS
   unit_not_found       = 1
   OTHERS               = 2
          .
IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
ENDIF.
gt_change_pritem-po_unit_iso = gt_change_pritem-po_unit.
    ENDIF.

    APPEND gt_change_pritem.
    CLEAR gt_change_pritem.

    gt_change_pritemx-preq_item   = gt_detail_pritem-preq_item.
    gt_change_pritemx-preq_itemx  = 'X'.
    gt_change_pritemx-acctasscat  = 'X'.
    gt_change_pritemx-pur_group   = 'X'.
    gt_change_pritemx-preq_name   = 'X'.
    gt_change_pritemx-quantity    = 'X'.
*    gt_change_pritemx-unit        = 'X'.
    gt_change_pritemx-po_unit     = 'X'.
    gt_change_pritemx-po_unit_iso = 'X'.
    APPEND gt_change_pritemx.
    CLEAR gt_change_pritemx.
  ENDLOOP.

  LOOP AT gt_detail_praccount WHERE preq_item EQ gt_eban-bnfpo.

    MOVE-CORRESPONDING gt_detail_praccount TO gt_change_praccount.
    gt_change_praccount-costcenter = p_kostl.
    gt_change_praccount-unload_pt  = p_ablad.
    gt_change_praccount-gr_rcpt    = p_wempf.

*  gt_change_praccount-gl_account   = '0000706011'. "gl account
*  gt_change_praccount-co_area      = '1000'.      "controlling area
**gt_change_praccount-BUS_AREA      "business area
    gt_change_praccount-serial_no   = '01'.      "controlling area

*    IF p_menge NE gt_detail_praccount-quantity.
*      gt_change_praccount-quantity    = p_menge.
*    ELSE.
*      gt_change_praccount-quantity    = gt_detail_praccount-quantity.
*    ENDIF.

    APPEND gt_change_praccount.
    CLEAR gt_change_praccount.

    gt_change_praccountx-preq_item = gt_detail_praccount-preq_item.
    gt_change_praccountx-preq_itemx = 'X'.
    gt_change_praccountx-costcenter = 'X'.
    gt_change_praccountx-unload_pt  = 'X'.
    gt_change_praccountx-gr_rcpt    = 'X'.

*  gt_change_praccountx-gl_account   = 'X'. "gl account
*  gt_change_praccountx-co_area      = 'X'.      "controlling area
**gt_change_praccountx-BUS_AREA      "business area
    gt_change_praccountx-serial_no    = '01'.      "controlling area

*    gt_change_praccountx-quantity    = 'X'.


**    IF gt_change_praccount-serial_no NE space.
**      gt_change_praccountx-serial_no = gt_change_praccount-serial_no.
**    ENDIF.
**
**    gt_change_praccountx-preq_itemx = 'X'.
**    gt_change_praccountx-serial_nox = 'X'.
**    gt_change_praccountx-delete_ind = 'X'.
**    gt_change_praccountx-creat_date = 'X'.
**    gt_change_praccountx-quantity = 'X'.
**    gt_change_praccountx-distr_perc = 'X'.
**    gt_change_praccountx-net_value = 'X'.
**    gt_change_praccountx-gl_account = 'X'.
**    gt_change_praccountx-bus_area = 'X'.
**    gt_change_praccountx-costcenter = 'X'.
**    gt_change_praccountx-sd_doc = 'X'.
**    gt_change_praccountx-itm_number = 'X'.
**    gt_change_praccountx-sched_line = 'X'.
**    gt_change_praccountx-asset_no = 'X'.
**    gt_change_praccountx-sub_number = 'X'.
**    gt_change_praccountx-orderid = 'X'.
**    gt_change_praccountx-gr_rcpt = 'X'.
**    gt_change_praccountx-unload_pt = 'X'.
**    gt_change_praccountx-co_area = 'X'.
**    gt_change_praccountx-costobject = 'X'.
**    gt_change_praccountx-profit_ctr = 'X'.
**    gt_change_praccountx-wbs_element = 'X'.
**    gt_change_praccountx-network = 'X'.
**    gt_change_praccountx-rl_est_key = 'X'.
**    gt_change_praccountx-part_acct = 'X'.
**    gt_change_praccountx-cmmt_item = 'X'.
**    gt_change_praccountx-rec_ind = 'X'.
**    gt_change_praccountx-funds_ctr = 'X'.
**    gt_change_praccountx-fund = 'X'.
**    gt_change_praccountx-func_area = 'X'.
**    gt_change_praccountx-ref_date = 'X'.
**    gt_change_praccountx-tax_code = 'X'.
**    gt_change_praccountx-taxjurcode = 'X'.
**    gt_change_praccountx-nond_itax = 'X'.
**    gt_change_praccountx-acttype = 'X'.
**    gt_change_praccountx-co_busproc = 'X'.
**    gt_change_praccountx-res_doc = 'X'.
**    gt_change_praccountx-res_item = 'X'.
**    gt_change_praccountx-activity = 'X'.
**    gt_change_praccountx-grant_nbr = 'X'.
**    gt_change_praccountx-cmmt_item_long = 'X'.
**    gt_change_praccountx-func_area_long = 'X'.
**    gt_change_praccountx-budget_period = 'X'.

    APPEND gt_change_praccountx.
    CLEAR gt_change_praccountx.
  ENDLOOP.

  READ TABLE gt_change_praccount WITH KEY preq_item = gt_eban-bnfpo.
  IF sy-subrc EQ 0.

*CALL FUNCTION 'BAPI_PR_CREATE'
* EXPORTING
*   PRHEADER                     = gs_prheader
*   PRHEADERX                    = gs_prheaderx
**   TESTRUN                      =
** IMPORTING
**   NUMBER                       =
**   PRHEADEREXP                  =
*  TABLES
**   RETURN                       =
*    pritem                       =
**   PRITEMX                      =
**   PRITEMEXP                    =
**   PRITEMSOURCE                 =
**   PRACCOUNT                    =
**   PRACCOUNTPROITSEGMENT        =
**   PRACCOUNTX                   =
**   PRADDRDELIVERY               =
**   PRITEMTEXT                   =
**   PRHEADERTEXT                 =
**   EXTENSIONIN                  =
**   EXTENSIONOUT                 =
**   PRVERSION                    =
**   PRVERSIONX                   =
**   ALLVERSIONS                  =
**   PRCOMPONENTS                 =
**   PRCOMPONENTSX                =
**   SERVICEOUTLINE               =
**   SERVICEOUTLINEX              =
**   SERVICELINES                 =
**   SERVICELINESX                =
**   SERVICELIMIT                 =
**   SERVICELIMITX                =
**   SERVICECONTRACTLIMITS        =
**   SERVICECONTRACTLIMITSX       =
**   SERVICEACCOUNT               =
**   SERVICEACCOUNTX              =
**   SERVICELONGTEXTS             =
**   SERIALNUMBER                 =
**   SERIALNUMBERX                =
*          .

  ELSE.

    gt_change_praccount-preq_item  = gt_eban-bnfpo.
    gt_change_praccount-costcenter = p_kostl.
    gt_change_praccount-unload_pt  = p_ablad.
    gt_change_praccount-gr_rcpt    = p_wempf.
    gt_change_praccount-serial_no    = '01'.      "controlling area

**    gt_change_praccount-quantity     = gt_eban-menge.
*    IF gt_eban-menge NE p_menge.
*      gt_change_praccount-quantity    = p_menge.
*    ELSE.
*      gt_change_praccount-quantity    = gt_eban-menge.
*    ENDIF.

        APPEND gt_change_praccount.
    CLEAR gt_change_praccount.


    gt_change_praccountx-preq_item  = gt_eban-bnfpo.
    gt_change_praccountx-preq_itemx = 'X'.
    gt_change_praccountx-costcenter = 'X'.
    gt_change_praccountx-unload_pt  = 'X'.
    gt_change_praccountx-gr_rcpt    = 'X'.
    gt_change_praccountx-serial_no    = '01'.      "controlling area
*    gt_change_praccountx-quantity     = 'X'.
    APPEND gt_change_praccountx.
    CLEAR gt_change_praccountx.

  ENDIF.

ENDFORM.                    " prepare_bapi_CHANGE
*&      Form  UPDATE_PR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM prepare_bapi_change_0200.

  LOOP AT gt_detail_pritem WHERE preq_item EQ gt_eban-bnfpo.
    MOVE-CORRESPONDING gt_detail_pritem TO gt_change_pritem.
    gt_change_pritem-acctasscat = p_knttp.
    gt_change_pritem-pur_group  = p_ekgrp.
    gt_change_pritem-preq_name  = p_afnam.

*<<< DELETED BY RAMSES - START 10.04.2012
*    IF p_menge NE gt_detail_pritem-quantity.
*      gt_change_pritem-quantity = p_menge.
*    ELSE.
*      gt_change_pritem-quantity = gt_detail_pritem-quantity.
*    ENDIF.
*<<< DELETED BY RAMSES - END 10.04.2012

*    IF gt_eban-meins NE gt_detail_pritem-unit.
*      gt_change_pritem-unit       = p_meins.

*<<< DELETED BY RAMSES - START 10.04.2012
*    IF gt_eban-meins NE gt_detail_pritem-po_unit.
*CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
*  EXPORTING
*    input                = p_meins
*   LANGUAGE             = SY-LANGU
* IMPORTING
*   OUTPUT               = gt_change_pritem-po_unit
* EXCEPTIONS
*   UNIT_NOT_FOUND       = 1
*   OTHERS               = 2
*          .
*IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*ENDIF.
*gt_change_pritem-po_unit_iso = gt_change_pritem-po_unit.
*
*    ELSE.
**      gt_change_pritem-unit       = gt_eban-meins.
*CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
*  EXPORTING
*    input                = gt_eban-meins
*   LANGUAGE             = SY-LANGU
* IMPORTING
*   OUTPUT               = gt_change_pritem-po_unit
* EXCEPTIONS
*   UNIT_NOT_FOUND       = 1
*   OTHERS               = 2
*          .
*IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*ENDIF.
*gt_change_pritem-po_unit_iso = gt_change_pritem-po_unit.
*    ENDIF.
*<<< DELETED BY RAMSES - END 10.04.2012

    APPEND gt_change_pritem.
    CLEAR gt_change_pritem.

    gt_change_pritemx-preq_item   = gt_detail_pritem-preq_item.
    gt_change_pritemx-preq_itemx  = 'X'.
    gt_change_pritemx-acctasscat  = 'X'.
    gt_change_pritemx-pur_group   = 'X'.
    gt_change_pritemx-preq_name   = 'X'.
*<<< DELETED BY RAMSES - START 10.04.2012
*    gt_change_pritemx-quantity    = 'X'.
*<<< DELETED BY RAMSES - END 10.04.2012
*    gt_change_pritemx-unit        = 'X'.
*<<< DELETED BY RAMSES - START 10.04.2012
*    gt_change_pritemx-po_unit     = 'X'.
*    gt_change_pritemx-po_unit_iso = 'X'.
*<<< DELETED BY RAMSES - END 10.04.2012
    APPEND gt_change_pritemx.
    CLEAR gt_change_pritemx.
  ENDLOOP.

  LOOP AT gt_detail_praccount WHERE preq_item EQ gt_eban-bnfpo.

    MOVE-CORRESPONDING gt_detail_praccount TO gt_change_praccount.
    gt_change_praccount-costcenter = p_kostl.
    gt_change_praccount-unload_pt  = p_ablad.
    gt_change_praccount-gr_rcpt    = p_wempf.

*  gt_change_praccount-gl_account   = '0000706011'. "gl account
*  gt_change_praccount-co_area      = '1000'.      "controlling area
**gt_change_praccount-BUS_AREA      "business area
    gt_change_praccount-serial_no   = '01'.      "controlling area

*    IF p_menge NE gt_detail_praccount-quantity.
*      gt_change_praccount-quantity    = p_menge.
*    ELSE.
*      gt_change_praccount-quantity    = gt_detail_praccount-quantity.
*    ENDIF.

    APPEND gt_change_praccount.
    CLEAR gt_change_praccount.

    gt_change_praccountx-preq_item = gt_detail_praccount-preq_item.
    gt_change_praccountx-preq_itemx = 'X'.
    gt_change_praccountx-costcenter = 'X'.
    gt_change_praccountx-unload_pt  = 'X'.
    gt_change_praccountx-gr_rcpt    = 'X'.

*  gt_change_praccountx-gl_account   = 'X'. "gl account
*  gt_change_praccountx-co_area      = 'X'.      "controlling area
**gt_change_praccountx-BUS_AREA      "business area
    gt_change_praccountx-serial_no    = '01'.      "controlling area

*    gt_change_praccountx-quantity    = 'X'.


**    IF gt_change_praccount-serial_no NE space.
**      gt_change_praccountx-serial_no = gt_change_praccount-serial_no.
**    ENDIF.
**
**    gt_change_praccountx-preq_itemx = 'X'.
**    gt_change_praccountx-serial_nox = 'X'.
**    gt_change_praccountx-delete_ind = 'X'.
**    gt_change_praccountx-creat_date = 'X'.
**    gt_change_praccountx-quantity = 'X'.
**    gt_change_praccountx-distr_perc = 'X'.
**    gt_change_praccountx-net_value = 'X'.
**    gt_change_praccountx-gl_account = 'X'.
**    gt_change_praccountx-bus_area = 'X'.
**    gt_change_praccountx-costcenter = 'X'.
**    gt_change_praccountx-sd_doc = 'X'.
**    gt_change_praccountx-itm_number = 'X'.
**    gt_change_praccountx-sched_line = 'X'.
**    gt_change_praccountx-asset_no = 'X'.
**    gt_change_praccountx-sub_number = 'X'.
**    gt_change_praccountx-orderid = 'X'.
**    gt_change_praccountx-gr_rcpt = 'X'.
**    gt_change_praccountx-unload_pt = 'X'.
**    gt_change_praccountx-co_area = 'X'.
**    gt_change_praccountx-costobject = 'X'.
**    gt_change_praccountx-profit_ctr = 'X'.
**    gt_change_praccountx-wbs_element = 'X'.
**    gt_change_praccountx-network = 'X'.
**    gt_change_praccountx-rl_est_key = 'X'.
**    gt_change_praccountx-part_acct = 'X'.
**    gt_change_praccountx-cmmt_item = 'X'.
**    gt_change_praccountx-rec_ind = 'X'.
**    gt_change_praccountx-funds_ctr = 'X'.
**    gt_change_praccountx-fund = 'X'.
**    gt_change_praccountx-func_area = 'X'.
**    gt_change_praccountx-ref_date = 'X'.
**    gt_change_praccountx-tax_code = 'X'.
**    gt_change_praccountx-taxjurcode = 'X'.
**    gt_change_praccountx-nond_itax = 'X'.
**    gt_change_praccountx-acttype = 'X'.
**    gt_change_praccountx-co_busproc = 'X'.
**    gt_change_praccountx-res_doc = 'X'.
**    gt_change_praccountx-res_item = 'X'.
**    gt_change_praccountx-activity = 'X'.
**    gt_change_praccountx-grant_nbr = 'X'.
**    gt_change_praccountx-cmmt_item_long = 'X'.
**    gt_change_praccountx-func_area_long = 'X'.
**    gt_change_praccountx-budget_period = 'X'.

    APPEND gt_change_praccountx.
    CLEAR gt_change_praccountx.
  ENDLOOP.

  READ TABLE gt_change_praccount WITH KEY preq_item = gt_eban-bnfpo.
  IF sy-subrc EQ 0.

*CALL FUNCTION 'BAPI_PR_CREATE'
* EXPORTING
*   PRHEADER                     = gs_prheader
*   PRHEADERX                    = gs_prheaderx
**   TESTRUN                      =
** IMPORTING
**   NUMBER                       =
**   PRHEADEREXP                  =
*  TABLES
**   RETURN                       =
*    pritem                       =
**   PRITEMX                      =
**   PRITEMEXP                    =
**   PRITEMSOURCE                 =
**   PRACCOUNT                    =
**   PRACCOUNTPROITSEGMENT        =
**   PRACCOUNTX                   =
**   PRADDRDELIVERY               =
**   PRITEMTEXT                   =
**   PRHEADERTEXT                 =
**   EXTENSIONIN                  =
**   EXTENSIONOUT                 =
**   PRVERSION                    =
**   PRVERSIONX                   =
**   ALLVERSIONS                  =
**   PRCOMPONENTS                 =
**   PRCOMPONENTSX                =
**   SERVICEOUTLINE               =
**   SERVICEOUTLINEX              =
**   SERVICELINES                 =
**   SERVICELINESX                =
**   SERVICELIMIT                 =
**   SERVICELIMITX                =
**   SERVICECONTRACTLIMITS        =
**   SERVICECONTRACTLIMITSX       =
**   SERVICEACCOUNT               =
**   SERVICEACCOUNTX              =
**   SERVICELONGTEXTS             =
**   SERIALNUMBER                 =
**   SERIALNUMBERX                =
*          .

  ELSE.

    gt_change_praccount-preq_item  = gt_eban-bnfpo.
    gt_change_praccount-costcenter = p_kostl.
    gt_change_praccount-unload_pt  = p_ablad.
    gt_change_praccount-gr_rcpt    = p_wempf.
    gt_change_praccount-serial_no    = '01'.      "controlling area

**    gt_change_praccount-quantity     = gt_eban-menge.
*    IF gt_eban-menge NE p_menge.
*      gt_change_praccount-quantity    = p_menge.
*    ELSE.
*      gt_change_praccount-quantity    = gt_eban-menge.
*    ENDIF.

        APPEND gt_change_praccount.
    CLEAR gt_change_praccount.


    gt_change_praccountx-preq_item  = gt_eban-bnfpo.
    gt_change_praccountx-preq_itemx = 'X'.
    gt_change_praccountx-costcenter = 'X'.
    gt_change_praccountx-unload_pt  = 'X'.
    gt_change_praccountx-gr_rcpt    = 'X'.
    gt_change_praccountx-serial_no    = '01'.      "controlling area
*    gt_change_praccountx-quantity     = 'X'.
    APPEND gt_change_praccountx.
    CLEAR gt_change_praccountx.

  ENDIF.

ENDFORM.                    " prepare_bapi_CHANGE_0200
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS '100'.
  SET TITLEBAR '100'.
ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_100 INPUT.

  IF okcode_100 EQ 'CANCEL'.
    SET SCREEN 0.
    LEAVE SCREEN.
  ENDIF.

ENDMODULE.                 " EXIT_100  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_KNTTP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_knttp INPUT.

* account assignment category
  IF gv_not_valid_100 EQ space.
    IF p_knttp NE 'K'.
      MESSAGE e398(00) WITH 'Account Assignment Category can be changed only to K'.
      gv_not_valid_100 = 'X'.
    ENDIF.
  ENDIF.

ENDMODULE.                 " VALIDATE_KNTTP  INPUT
*----------------------------------------------------------------------*
*  MODULE VALIDATE_kostl INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE validate_kostl INPUT.

* cost center
  IF gv_not_valid_100 EQ space.
    IF gt_detail_praccount-co_area EQ space.
      SELECT SINGLE kokrs kostl datbi datab bukrs
             INTO gs_csks
             FROM csks
             WHERE kokrs EQ '1000' AND
                   kostl EQ p_kostl AND
                   datbi GE sy-datum AND
                   datab LE sy-datum.
    ELSE.
      SELECT SINGLE kokrs kostl datbi datab bukrs
             INTO gs_csks
             FROM csks
             WHERE kokrs EQ gt_detail_praccount-co_area AND
                   kostl EQ p_kostl AND
                   datbi GE sy-datum AND
                   datab LE sy-datum.
    ENDIF.
    IF sy-subrc NE 0.
      MESSAGE e398(00) WITH 'Cost Center is not Valid'.
      gv_not_valid_100 = 'X'.
    ENDIF.
  ENDIF.

ENDMODULE.                 " VALIDATE_KNTTP  INPUT
*----------------------------------------------------------------------*
*  MODULE VALIDATE_ekgrp INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE validate_ekgrp INPUT.
* purchasing group
  IF gv_not_valid_100 EQ space.
    SELECT SINGLE ekgrp eknam INTO gs_t024
           FROM t024
           WHERE ekgrp EQ p_ekgrp.
    IF sy-subrc NE 0.
      MESSAGE e398(00) WITH 'Purchasing Group is not Valid'.
      gv_not_valid_100 = 'X'.
    ENDIF.
  ENDIF.
ENDMODULE.                    "VALIDATE_ekgrp INPUT
*&---------------------------------------------------------------------*
*&      Module  INITIAL_FLAG  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE initial_flag OUTPUT.
  CLEAR gv_not_valid_100.
  CLEAR okcode_100.
  CLEAR gv_not_valid_200.
  CLEAR okcode_200.

ENDMODULE.                 " INITIAL_FLAG  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS '200'.
  SET TITLEBAR '200'.

ENDMODULE.                 " STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_200 INPUT.
  IF okcode_200 EQ 'CANCEL'.
    SET SCREEN 0.
    LEAVE SCREEN.
  ENDIF.
ENDMODULE.                 " EXIT_200  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  IF okcode_200 EQ 'CONFIRM'.

    IF gv_not_valid_200 EQ space.
      CLEAR gv_answer.
      PERFORM popup_confirm.
    ENDIF.

  ENDIF.
  IF okcode_200 EQ 'CANCEL'.
    SET SCREEN 0.
    LEAVE SCREEN.
  ENDIF.

ENDMODULE.                 " USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*&      Form  popup_confirm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM popup_confirm.

  CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'

    EXPORTING
      defaultoption        = 'Y'
      diagnosetext1        = 'Updating data will be processed'
*               diagnosetext2        = ' '
*               DIAGNOSETEXT3       = ' '
      textline1            = 'Do you want to continue?'
*               TEXTLINE2            = ' '
      titel                = 'Confirmation'
      start_column         = 25
      start_row            = 6
      cancel_display       = ' '
    IMPORTING
      answer               = gv_answer.

  IF gv_answer EQ 'J'.
    IF okcode_100 EQ 'CONFIRM'.
      PERFORM prepare_bapi_change.
    ENDIF.
    IF okcode_200 EQ 'CONFIRM'.
      LOOP AT gt_eban_header_option_x WHERE option EQ 'X'.

        PERFORM bapi_initial.
        PERFORM bapi_get_detail.

        LOOP AT gt_eban WHERE banfn EQ gt_eban_header_option_x-banfn AND
                              option EQ 'X'.
          gv_save_sy_tabix = sy-tabix.
          PERFORM prepare_bapi_change_0200.
          CLEAR gt_eban-option.
          MODIFY gt_eban INDEX gv_save_sy_tabix.
        ENDLOOP.

        gs_prheaderx-preq_no = 'X'.

        IF gt_change_pritem[] IS NOT INITIAL.
          PERFORM bapi_change.

          DESCRIBE TABLE gt_change_return LINES gv_line_return.
          CLEAR gt_change_return.
          READ TABLE gt_change_return INDEX gv_line_return.
          CONCATENATE gt_change_return-message
                      gt_change_return-message_v2
                      gt_change_return-message_v3
                      gt_change_return-message_v4
                      gt_change_return-parameter
                      INTO gt_header_posting_result-message
                      SEPARATED BY '/'.

          CLEAR gv_success_bapi_process.
          PERFORM bapi_recheck.

          gt_header_posting_result-banfn_posting = gt_eban_header_option_x-banfn.

          IF gv_success_bapi_process EQ space.
            gt_header_posting_result-status = '@02@'.  "'FAIL'.
            IF gt_header_posting_result-message CS 'cross company codes is not allowed'.
              gt_header_posting_result-custom_message = 'Cross Company Codes not allowed'.
            ELSE.
              gt_header_posting_result-custom_message = gt_header_posting_result-message.
            ENDIF.
          ELSE.
            gt_header_posting_result-status = '@01@'.  "'SUCCESS'.
            IF gv_okcode_main EQ 'SEL_CHANGE' OR
               gv_okcode_main EQ 'SEL_GROUP'.
              gt_header_posting_result-custom_message = 'Purchase Requisition successfully Updated'.
            ENDIF.
            IF gv_okcode_main EQ 'DEL_CHANGE'.
              gt_header_posting_result-custom_message = 'Purchase Requisition successfully Deleted'.
            ENDIF.
          ENDIF.
          APPEND gt_header_posting_result.
          CLEAR gt_header_posting_result.
        ENDIF.

      ENDLOOP.
    ENDIF.
    SET SCREEN 0.
    LEAVE SCREEN.
  ENDIF.

ENDFORM.                    "popup_confirm
*&---------------------------------------------------------------------*
*&      Form  BAPI_CHANGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM bapi_change .

  CALL FUNCTION 'BAPI_PR_CHANGE' "#EC CI_USAGE_OK[2438131] P30K910018
    EXPORTING
      number                       = gt_eban_header_option_x-banfn
      prheader                     = gs_prheader
      prheaderx                    = gs_prheaderx
*           TESTRUN                      = 'X'
*         IMPORTING
*           PRHEADEREXP                  =
    TABLES
      return                       = gt_change_return
      pritem                       = gt_change_pritem
      pritemx                      = gt_change_pritemx
*           PRITEMEXP                    =
*           PRITEMSOURCE                 =
      praccount                    = gt_change_praccount
*           PRACCOUNTPROITSEGMENT        =
      praccountx                   = gt_change_praccountx
*           PRADDRDELIVERY               =
*           PRITEMTEXT                   =
*           PRHEADERTEXT                 =
*           EXTENSIONIN                  =
*           EXTENSIONOUT                 =
*           PRVERSION                    =
*           PRVERSIONX                   =
*           ALLVERSIONS                  =
*           PRCOMPONENTS                 =
*           PRCOMPONENTSX                =
*           SERVICEOUTLINE               =
*           SERVICEOUTLINEX              =
*           SERVICELINES                 =
*           SERVICELINESX                =
*           SERVICELIMIT                 =
*           SERVICELIMITX                =
*           SERVICECONTRACTLIMITS        =
*           SERVICECONTRACTLIMITSX       =
*           SERVICEACCOUNT               =
*           SERVICEACCOUNTX              =
*           SERVICELONGTEXTS             =
*           SERIALNUMBER                 =
*           SERIALNUMBERX                =
            .

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = 'X'.

ENDFORM.                    " BAPI_CHANGE
*&---------------------------------------------------------------------*
*&      Form  BAPI_INITIAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM bapi_initial .

  CLEAR gs_prheader.
  REFRESH : gt_detail_return,
            gt_detail_pritem,
            gt_detail_praccount,
            gt_detail_praddrdelivery,
            gt_detail_pritemtext,
            gt_detail_prheadertext,
            gt_detail_extensionout,
            gt_detail_allversions,
            gt_detail_prcomponents,
            gt_detail_serialnumbers,
            gt_detail_serviceoutline,
            gt_detail_servicelines,
            gt_detail_servicelimit,
*                    gt_detail_servicecontraclimits,
            gt_detail_serviceaccount,
            gt_detail_servicelongtexts.
  CLEAR : gt_detail_return,
            gt_detail_pritem,
            gt_detail_praccount,
            gt_detail_praddrdelivery,
            gt_detail_pritemtext,
            gt_detail_prheadertext,
            gt_detail_extensionout,
            gt_detail_allversions,
            gt_detail_prcomponents,
            gt_detail_serialnumbers,
            gt_detail_serviceoutline,
            gt_detail_servicelines,
            gt_detail_servicelimit,
*                    gt_detail_servicecontraclimits,
            gt_detail_serviceaccount,
            gt_detail_servicelongtexts.

  REFRESH : gt_change_return.
  CLEAR   : gt_change_return.

  REFRESH : gt_change_pritem, gt_change_pritemx.
  CLEAR   : gt_change_pritem, gt_change_pritemx.

  REFRESH : gt_change_praccount, gt_change_praccountx.
  CLEAR   : gt_change_praccount, gt_change_praccountx.


ENDFORM.                    " BAPI_INITIAL
*&---------------------------------------------------------------------*
*&      Form  BAPI_GET_DETAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM bapi_get_detail .

  CALL FUNCTION 'BAPI_PR_GETDETAIL' "#EC CI_USAGE_OK[2438131] P30K910018
    EXPORTING
      number                = gt_eban_header_option_x-banfn
      account_assignment    = 'X'
    IMPORTING
      prheader              = gs_prheader
    TABLES
      return                = gt_detail_return
      pritem                = gt_detail_pritem
      praccount             = gt_detail_praccount
      praddrdelivery        = gt_detail_praddrdelivery
      pritemtext            = gt_detail_pritemtext
      prheadertext          = gt_detail_prheadertext
      extensionout          = gt_detail_extensionout
      allversions           = gt_detail_allversions
      prcomponents          = gt_detail_prcomponents
      serialnumbers         = gt_detail_serialnumbers
      serviceoutline        = gt_detail_serviceoutline
      servicelines          = gt_detail_servicelines
      servicelimit          = gt_detail_servicelimit
*              servicecontractlimits = gt_detail_servicecontraclimits
      serviceaccount        = gt_detail_serviceaccount
      servicelongtexts      = gt_detail_servicelongtexts.

ENDFORM.                    " BAPI_GET_DETAIL
*&---------------------------------------------------------------------*
*&      Form  bapi_recheck
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM bapi_recheck.

** re-check
  REFRESH : gt_detail_2_return,
            gt_detail_2_pritem,
            gt_detail_2_praccount,
            gt_detail_2_praddrdelivery,
            gt_detail_2_pritemtext,
            gt_detail_2_prheadertext,
            gt_detail_2_extensionout,
            gt_detail_2_allversions,
            gt_detail_2_prcomponents,
            gt_detail_2_serialnumbers,
            gt_detail_2_serviceoutline,
            gt_detail_2_servicelines,
            gt_detail_2_servicelimit,
*                    gt_detail_servicecontraclimits,
            gt_detail_2_serviceaccount,
            gt_detail_2_servicelongtexts.
  CLEAR : gt_detail_2_return,
            gt_detail_2_pritem,
            gt_detail_2_praccount,
            gt_detail_2_praddrdelivery,
            gt_detail_2_pritemtext,
            gt_detail_2_prheadertext,
            gt_detail_2_extensionout,
            gt_detail_2_allversions,
            gt_detail_2_prcomponents,
            gt_detail_2_serialnumbers,
            gt_detail_2_serviceoutline,
            gt_detail_2_servicelines,
            gt_detail_2_servicelimit,
*                    gt_detail_servicecontraclimits,
            gt_detail_2_serviceaccount,
            gt_detail_2_servicelongtexts.
  CALL FUNCTION 'BAPI_PR_GETDETAIL' "#EC CI_USAGE_OK[2438131] P30K910018
    EXPORTING
      number                = gt_eban_header_option_x-banfn
      account_assignment    = 'X'
    IMPORTING
      prheader              = gs_prheader
    TABLES
      return                = gt_detail_2_return
      pritem                = gt_detail_2_pritem
      praccount             = gt_detail_2_praccount
      praddrdelivery        = gt_detail_2_praddrdelivery
      pritemtext            = gt_detail_2_pritemtext
      prheadertext          = gt_detail_2_prheadertext
      extensionout          = gt_detail_2_extensionout
      allversions           = gt_detail_2_allversions
      prcomponents          = gt_detail_2_prcomponents
      serialnumbers         = gt_detail_2_serialnumbers
      serviceoutline        = gt_detail_2_serviceoutline
      servicelines          = gt_detail_2_servicelines
      servicelimit          = gt_detail_2_servicelimit
*              servicecontractlimits = gt_detail_servicecontraclimits
      serviceaccount        = gt_detail_2_serviceaccount
      servicelongtexts      = gt_detail_2_servicelongtexts.

  CLEAR : gv_success_bapi_process_save.

  LOOP AT gt_detail_pritem.
    READ TABLE gt_detail_2_pritem WITH KEY preq_item = gt_detail_pritem-preq_item.
    IF sy-subrc EQ 0.

      CLEAR gv_success_bapi_process.
      READ TABLE gt_eban_option_x WITH KEY banfn = gt_eban_header_option_x-banfn
                                           bnfpo = gt_detail_pritem-preq_item.
      IF sy-subrc EQ 0.

      READ TABLE gt_eban WITH KEY banfn = gt_eban_header_option_x-banfn
                                  bnfpo = gt_eban_option_x-bnfpo.
      IF sy-subrc EQ 0.
        gv_save_sy_tabix = sy-tabix.

        gt_header_posting_result_dtl-banfn_posting_del = gt_eban-banfn.
        gt_header_posting_result_dtl-bnfpo_posting = gt_eban-bnfpo.
        gt_header_posting_result_dtl-matnr_posting = gt_eban-matnr.
        gt_header_posting_result_dtl-txz01_posting = gt_eban-txz01.

        gt_header_posting_result_dtl-message = gt_header_posting_result-message.

        IF gt_detail_2_pritem-delete_ind NE gt_detail_pritem-delete_ind OR
           gt_detail_2_pritem-acctasscat NE gt_detail_pritem-acctasscat OR
           gt_detail_2_pritem-pur_group  NE gt_detail_pritem-pur_group OR
           gt_detail_2_pritem-preq_name  NE gt_detail_pritem-preq_name.
          gv_success_bapi_process = 'X'.
          gv_success_bapi_process_save = gv_success_bapi_process.

          IF gv_okcode_main EQ 'DEL_CHANGE'.
            gt_eban-del_indicator = '@11@'.
            DELETE gt_eban INDEX gv_save_sy_tabix.
            CLEAR gt_eban.
          ENDIF.
          IF gv_okcode_main EQ 'SEL_CHANGE' OR
             gv_okcode_main EQ 'SEL_GROUP'.
            DELETE gt_eban INDEX gv_save_sy_tabix.
          ENDIF.

        ENDIF.

        IF gv_success_bapi_process EQ space.
          gt_header_posting_result_dtl-status = '@02@'.  "'FAIL'.
          IF gt_header_posting_result_dtl-message CS 'cross company codes is not allowed'.
            gt_header_posting_result_dtl-custom_message = 'Cross Company Codes not allowed'.
          ELSE.
            gt_header_posting_result_dtl-custom_message = gt_header_posting_result_dtl-message.
          ENDIF.
        ELSE.
          gt_header_posting_result_dtl-status = '@01@'.  "'SUCCESS'.
          IF gv_okcode_main EQ 'SEL_CHANGE' OR
             gv_okcode_main EQ 'SEL_GROUP'.
            gt_header_posting_result_dtl-custom_message = 'Purchase Requisition successfully Updated'.
          ELSE.
            IF gv_okcode_main EQ 'DEL_CHANGE'.
              gt_header_posting_result_dtl-custom_message = 'Purchase Requisition successfully Deleted'.
            ENDIF.
          ENDIF.
        ENDIF.

        APPEND gt_header_posting_result_dtl.
        CLEAR gt_header_posting_result_dtl.
      ENDIF.
     ENDIF.
    ENDIF.
  ENDLOOP.

  gv_success_bapi_process = gv_success_bapi_process_save.

  LOOP AT gt_detail_praccount.
    READ TABLE gt_detail_2_praccount WITH KEY preq_item = gt_detail_praccount-preq_item.
    IF sy-subrc EQ 0.
      IF gt_detail_2_praccount-unload_pt NE gt_detail_praccount-unload_pt OR
         gt_detail_2_praccount-gr_rcpt NE gt_detail_praccount-gr_rcpt.
        gv_success_bapi_process = 'X'.
        READ TABLE gt_header_posting_result_dtl WITH KEY banfn_posting_del = gt_eban_header_option_x-banfn
                                                         bnfpo_posting = gt_detail_praccount-preq_item.
        IF sy-subrc EQ 0.
          IF gt_header_posting_result_dtl-status NE '@01@'. "success
            gt_header_posting_result_dtl-status = '@01@'.
            MODIFY gt_header_posting_result_dtl INDEX sy-tabix.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.


ENDFORM.                    "bapi_recheck
*&---------------------------------------------------------------------*
*&      Form  prepare_alv_200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM prepare_alv_200.

  CLEAR gt_fieldcat. "delete all records

  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'BANFN'.
  gs_fieldcat-datatype  = 'CHAR'.
  gs_fieldcat-coltext   = 'Purchase Requisition'.
  gs_fieldcat-outputlen = '20'.
  gs_fieldcat-key = 'X'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'BNFPO'.
  gs_fieldcat-datatype  = 'NUMC'.
  gs_fieldcat-coltext   = 'Item'.
  gs_fieldcat-outputlen = '5'.
  gs_fieldcat-key = 'X'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'MATNR'.
  gs_fieldcat-datatype  = 'CHAR'.
  gs_fieldcat-coltext   = 'Material'.
  gs_fieldcat-outputlen = '10'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'TXZ01'.
  gs_fieldcat-datatype  = 'CHAR'.
  gs_fieldcat-coltext   = 'Description'.
  gs_fieldcat-outputlen = '40'.
  APPEND gs_fieldcat TO gt_fieldcat.

ENDFORM.                    "prepare_alv_200
*----------------------------------------------------------------------*
*  MODULE custom_container OUTPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE custom_container OUTPUT.

  DATA: lt_exclude TYPE ui_functions.

  IF g_custom_container IS INITIAL.
    IF sy-batch IS INITIAL.
      CREATE OBJECT g_custom_container
        EXPORTING
          container_name = g_container.
    ENDIF.
    CREATE OBJECT grid1
      EXPORTING
        i_parent       = g_custom_container
        i_applogparent = g_custom_container2.

    CREATE OBJECT event_receiver.
    SET HANDLER event_receiver->handle_data_changed FOR grid1.

    CALL METHOD grid1->set_drop_down_table
      EXPORTING
        it_drop_down = lt_dropdown.

    SET HANDLER event_receiver->handle_f4 FOR grid1.

    CALL METHOD grid1->register_f4_for_fields
      EXPORTING
        it_f4 = gt_f4.
    IF sy-batch IS INITIAL.
      CALL METHOD grid1->register_edit_event
        EXPORTING
          i_event_id = cl_gui_alv_grid=>mc_evt_enter.
    ENDIF.

    PERFORM exclude_tb_functions CHANGING lt_exclude.

    gs_variant-report = sy-repid.
    gs_layout-stylefname = 'CELLTAB'.
    CALL METHOD grid1->set_table_for_first_display  "#EC CI_FLDEXT_OK[2215424] P30K910018
      EXPORTING            "i_buffer_active = 'X'
        i_save               = 'A'
        is_variant           = gs_variant
        is_layout            = gs_layout
        it_toolbar_excluding = lt_exclude
      CHANGING
        it_fieldcatalog      = gt_fieldcat
        it_sort              = gt_sort
        it_outtab            = gt_eban_option_x[].

  ELSE.

    CALL METHOD grid1->refresh_table_display.

  ENDIF.

  CALL METHOD grid1->set_ready_for_input
    EXPORTING
      i_ready_for_input = 0.

ENDMODULE.                 " custom_container  OUTPUT
*&--------------------------------------------------------------------*
*&      Form  exclude_tb_functions
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->PT_EXCLUDE text
*---------------------------------------------------------------------*
FORM exclude_tb_functions CHANGING pt_exclude TYPE ui_functions.
* Only allow to change data not to create new entries (exclude
* generic functions).

  DATA ls_exclude TYPE ui_func.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_move_row.
  APPEND ls_exclude TO pt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_undo.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_cut.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
  APPEND ls_exclude TO pt_exclude.

ENDFORM.                    "exclude_tb_functions
*&--------------------------------------------------------------------*
*&      Form  data_changed
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->RR_DATA_CHAtext
*---------------------------------------------------------------------*
FORM data_changed
USING  rr_data_changed TYPE REF TO cl_alv_changed_data_protocol.

  DATA: ls_tcurc LIKE tcurc.                                "#EC needed

  SORT rr_data_changed->mt_good_cells BY tabix.
  LOOP AT rr_data_changed->mt_good_cells INTO gv_ls_mod_cells.

  ENDLOOP.
ENDFORM.                    "data_changed
*&---------------------------------------------------------------------*
*&      Form  f4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->R_FIELDNAME    text
*      -->RS_ROW_NO      text
*      -->RR_EVENT_DATA  text
*      -->RT_BAD_CELLS   text
*----------------------------------------------------------------------*
FORM f4 USING r_fieldname TYPE lvc_fname
              rs_row_no TYPE lvc_s_roid
              rr_event_data TYPE REF TO cl_alv_event_data
              rt_bad_cells TYPE lvc_t_modi.                 "#EC *

  FIELD-SYMBOLS: <lt_f4> TYPE lvc_t_modi.
  DATA: ls_f4 TYPE lvc_s_modi.


  ASSIGN rr_event_data->m_data->* TO <lt_f4>.
  ls_f4-fieldname = r_fieldname.
  ls_f4-row_id = rs_row_no-row_id.

  rr_event_data->m_event_handled = 'X'.

ENDFORM.                                                    " F4
*&---------------------------------------------------------------------*
*&      Module  HIDE_QUAN_REQ  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE hide_quan_req OUTPUT.
  LOOP AT SCREEN.
    CASE screen-name.
      WHEN '%#AUTOTEXT011' OR 'P_MENGE' OR 'P_MEINS'.
*        screen-input = '0'.
*        screen-output = '0'.
*        screen-invisible = '1'.
        screen-active = '0'.
        MODIFY SCREEN.
    ENDCASE.
  ENDLOOP.
ENDMODULE.                 " HIDE_QUAN_REQ  OUTPUT
