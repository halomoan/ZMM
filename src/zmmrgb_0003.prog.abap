*&---------------------------------------------------------------------*
*& Report  ZMMRGB_0003
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zmmrgb_0003 LINE-SIZE 200 LINE-COUNT 60 MESSAGE-ID zmm
NO STANDARD PAGE HEADING.
*----------------------------------------------------------------------*
* Title   : Reservation Approval
* FRICE#  :
* Author  : Surjeet Singh
* Date    : 17 Nov 2010
* Purpose : Program to display and approve reservation
* Specification Given By: Audrey
*----------------------------------------------------------------------*
*  MODIFICATION LOG
*-----------------------------------------------------------------------
*  DATE     change #      Programmer  Description.
*-----------------------------------------------------------------------
* 20211102  001           ADHIMAS     Print control support
*----------------------------------------------------------------------*
* I N C L U D E S
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* T Y P E P O O L S
*----------------------------------------------------------------------*
TYPE-POOLS: truxs,slis,icon.
.
CLASS cl_abap_char_utilities DEFINITION LOAD.

*----------------------------------------------------------------------*
* T A B L E S
*----------------------------------------------------------------------*
TABLES : rkpf,resb,CSKSZ.

*----------------------------------------------------------------------*
* I N T E R N A L   T A B L E S
*----------------------------------------------------------------------*
DATA : it_rkpf TYPE STANDARD TABLE OF rkpf,
       it_resb TYPE STANDARD TABLE OF resb.

DATA : BEGIN OF it_disp OCCURS 0,
          csel  TYPE char1,
          rsnum TYPE rkpf-rsnum,
          rspos TYPE resb-rspos,
          rsdat TYPE rkpf-rsdat,
          matnr TYPE resb-matnr,
          maktx TYPE makt-maktx,
          werks TYPE resb-werks,
          lgort TYPE resb-lgort,
          bdmng TYPE resb-bdmng,
          meins TYPE resb-meins,
          xloek TYPE resb-xloek,
          kostl TYPE rkpf-kostl,
          ltext TYPE cskt-ltext,
          saknr TYPE resb-saknr,
          wempf TYPE rkpf-wempf,
       END OF it_disp.

DATA : BEGIN OF it_rest OCCURS 0,
          rsnum TYPE rkpf-rsnum,
          rspos TYPE resb-rspos,
          rsdat TYPE rkpf-rsdat,
          matnr TYPE resb-matnr,
          werks TYPE resb-werks,
          lgort TYPE resb-lgort,
          bdmng TYPE resb-bdmng,
          meins TYPE resb-meins,
          xloek TYPE resb-xloek,
          msg TYPE char200,
          sts TYPE char1,
       END OF it_rest.
*----------------------------------------------------------------------*
* C O N S T A N T   A N D   V A R I A B L E S
*----------------------------------------------------------------------*
DATA : msg(200) TYPE c.
DATA: per(3) TYPE n,
      prog_text(30) TYPE c.
FIELD-SYMBOLS: <f_rkpf> TYPE rkpf,
               <f_resb> TYPE resb.

DATA : v_repid        LIKE sy-repid,
       gt_events      TYPE slis_t_event,
       gt_layout       TYPE slis_layout_alv,
       gt_fieldcat    TYPE slis_t_fieldcat_alv,
       v_grid_title TYPE lvc_title,
       v_desc(27) TYPE c,
       v_status TYPE slis_formname VALUE 'GUI_CUST',
       gt_sortinfo TYPE slis_t_sortinfo_alv,
       gt_list_top_of_page TYPE slis_t_listheader,
       v_first TYPE c.

CONSTANTS:
        gc_forname TYPE slis_formname VALUE 'TOP_OF_PAGE'.

CONSTANTS : c_app LIKE sy-ucomm VALUE '&APP',
            c_rej LIKE sy-ucomm VALUE '&REJ',
            c_log LIKE sy-ucomm VALUE '&LOG',
            c_hspt LIKE sy-ucomm VALUE '&IC1'.

DATA : reservation  TYPE  bapi2093_res_key-reserv_no,
       it_res TYPE STANDARD TABLE OF  bapi2093_res_item_change WITH HEADER LINE,
       it_resx  TYPE STANDARD TABLE OF bapi2093_res_item_changex WITH HEADER LINE,
       it_ret	TYPE STANDARD TABLE OF bapiret2 WITH HEADER LINE.

*data con_tab  type c value cl_abap_char_utilities=>HORIZONTAL_TAB.

*----------------------------------------------------------------------*
* R A N G E S
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
*  P A R A M E T E R S  &  S E L E C T - O P T I O N S
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-b01.
PARAMETERS :  p_werks LIKE resb-werks OBLIGATORY.
SELECT-OPTIONS : s_rsnum FOR rkpf-rsnum,
                 s_rsdat FOR rkpf-rsdat,
                 s_bwart FOR resb-bwart.
PARAMETERS : p_xloek AS CHECKBOX,
             p_wempf AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK b2.


SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE text-b02.
SELECT-OPTIONS : s_kostl FOR CSKSZ-kostl,
                 s_saknr FOR resb-saknr.
SELECTION-SCREEN END OF BLOCK b3.

*----------------------------------------------------------------------*
* I N I T I A L I Z A T I O N
*----------------------------------------------------------------------*
INITIALIZATION.
  v_repid = sy-repid.
*----------------------------------------------------------------------*
* A T  S E L E C T I O N  S C R E E N
*----------------------------------------------------------------------*

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
  PERFORM check_authority.
  PERFORM get_data.
  PERFORM build_data.
*List display
  PERFORM f_mergefield USING gt_fieldcat[].
  PERFORM f_e06_t_sort_build USING gt_sortinfo[].
  PERFORM f_printdata.
*&---------------------------------------------------------------------*
*&      Form  CHECK_AUTHORITY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_authority .
  AUTHORITY-CHECK OBJECT 'M_MRES_WWA'
                    ID 'ACTVT' FIELD '02'
                    ID 'WERKS' FIELD p_werks.
  IF sy-subrc <> 0.
    MESSAGE i000(zmm) WITH text-001 p_werks.
    STOP.
  ENDIF.
ENDFORM.                    " CHECK_AUTHORITY
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data .
  per = 10.
  prog_text = 'Reading Data'.
  DATA : v_xloek TYPE xloek,
         v_wempf TYPE wempf.

  CLEAR :v_wempf,v_xloek.

  v_xloek = p_xloek.
  IF p_wempf = 'X'.
    v_wempf = 'REJ'.
  ENDIF.

  PERFORM prog_indicator USING per prog_text.

  SELECT * INTO TABLE it_rkpf FROM rkpf WHERE rsnum IN s_rsnum
                                          AND rsdat IN s_rsdat
                                          AND bwart IN s_bwart
                                          AND kostl IN s_kostl
                                          AND wempf = space.
  IF p_wempf = 'X'.
    SELECT * APPENDING TABLE it_rkpf FROM rkpf WHERE rsnum IN s_rsnum
                                           AND rsdat IN s_rsdat
                                           AND bwart IN s_bwart
                                           AND kostl IN s_kostl
                                           AND wempf = v_wempf.
  ENDIF.

  IF it_rkpf[] IS INITIAL.
    MESSAGE i000(zmm) WITH text-002.
    STOP.
  ENDIF.
  SELECT * INTO TABLE it_resb FROM resb FOR ALL ENTRIES IN it_rkpf
                                              WHERE rsnum = it_rkpf-rsnum
                                                AND werks = p_werks
                                                AND xloek = space
                                                AND xwaok = space
                                                AND saknr IN s_saknr.
  IF p_xloek = 'X'.
    SELECT * APPENDING TABLE it_resb FROM resb FOR ALL ENTRIES IN it_rkpf
                                            WHERE rsnum = it_rkpf-rsnum
                                              AND werks = p_werks
                                              AND xloek = v_xloek
                                              AND xwaok = space
                                              AND saknr IN s_saknr.
  ENDIF.
  per = 100.
  PERFORM prog_indicator USING per prog_text.
ENDFORM.                    " GET_DATA
*&---------------------------------------------------------------------*
*&      Form  prog_indicator
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PER      text
*      -->TXT        text
*----------------------------------------------------------------------*
FORM prog_indicator USING p_per txt.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = p_per
      text       = txt.
ENDFORM. " PROG_INDICATOR
*&---------------------------------------------------------------------*
*&      Form  BUILD_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_data .
  LOOP AT it_resb ASSIGNING <f_resb>.
    READ TABLE it_rkpf ASSIGNING <f_rkpf> WITH KEY rsnum = <f_resb>-rsnum.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING <f_resb> TO it_disp.
      MOVE-CORRESPONDING <f_rkpf> TO it_disp.
      SELECT SINGLE maktx INTO it_disp-maktx FROM makt WHERE spras = sy-langu
                                                         AND matnr = <f_resb>-matnr.
      SELECT SINGLE ltext INTO it_disp-ltext FROM cskt WHERE spras = sy-langu
                                                         AND kostl = <f_rkpf>-kostl.
      APPEND it_disp.
      CLEAR it_disp.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " BUILD_DATA
*&---------------------------------------------------------------------*
*&      Form  f_mergefield
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RT_FIELDCAT  text
*----------------------------------------------------------------------*
FORM f_mergefield USING rt_fieldcat TYPE slis_t_fieldcat_alv.

  DATA: ls_fieldcat TYPE slis_fieldcat_alv,
        pos TYPE i VALUE 1,
        gs_sort TYPE slis_sortinfo_alv.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos       =  pos.
  ls_fieldcat-fieldname     = 'RSNUM'.
  ls_fieldcat-ref_fieldname = 'RSNUM'.
  ls_fieldcat-ref_tabname   = 'RKPF'.
  ls_fieldcat-hotspot       = 'X'.
  ls_fieldcat-key           = 'X'.
  APPEND ls_fieldcat TO  gt_fieldcat.
  CLEAR ls_fieldcat.
  pos = pos + 1.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos       =  pos.
  ls_fieldcat-fieldname     = 'RSPOS'.
  ls_fieldcat-ref_fieldname = 'RSPOS'.
  ls_fieldcat-ref_tabname   = 'RESB'.
*  ls_fieldcat-seltext_l     = 'Invoice No'.
  ls_fieldcat-key           = 'X'.
  APPEND ls_fieldcat TO  gt_fieldcat.
  CLEAR ls_fieldcat.
  pos = pos + 1.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos       =  pos.
  ls_fieldcat-fieldname     = 'RSDAT'.
  ls_fieldcat-ref_fieldname = 'RSDAT'.
  ls_fieldcat-ref_tabname   = 'RKPF'.
  ls_fieldcat-key           = 'X'.
  APPEND ls_fieldcat TO  gt_fieldcat.
  CLEAR ls_fieldcat.
  pos = pos + 1.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos       =  pos.
  ls_fieldcat-fieldname     = 'MATNR'.
  ls_fieldcat-ref_fieldname = 'MATNR'.
  ls_fieldcat-ref_tabname   = 'RESB'.
  APPEND ls_fieldcat TO  gt_fieldcat.
  CLEAR ls_fieldcat.
  pos = pos + 1.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos       =  pos.
  ls_fieldcat-fieldname     = 'MAKTX'.
  ls_fieldcat-ref_fieldname = 'MAKTX'.
  ls_fieldcat-ref_tabname   = 'MAKT'.
  APPEND ls_fieldcat TO  gt_fieldcat.
  CLEAR ls_fieldcat.
  pos = pos + 1.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos       =  pos.
  ls_fieldcat-fieldname     = 'WERKS'.
  ls_fieldcat-ref_fieldname = 'WERKS'.
  ls_fieldcat-ref_tabname   = 'RESB'.
  APPEND ls_fieldcat TO  gt_fieldcat.
  CLEAR ls_fieldcat.
  pos = pos + 1.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos       =  pos.
  ls_fieldcat-fieldname     = 'LGORT'.
  ls_fieldcat-ref_fieldname = 'LGORT'.
  ls_fieldcat-ref_tabname   = 'RESB'.
  APPEND ls_fieldcat TO  gt_fieldcat.
  CLEAR ls_fieldcat.
  pos = pos + 1.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos       =  pos.
  ls_fieldcat-fieldname     = 'BDMNG'.
  ls_fieldcat-ref_fieldname = 'BDMNG'.
  ls_fieldcat-ref_tabname   = 'RESB'.
  APPEND ls_fieldcat TO  gt_fieldcat.
  CLEAR ls_fieldcat.
  pos = pos + 1.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos       =  pos.
  ls_fieldcat-fieldname     = 'MEINS'.
  ls_fieldcat-ref_fieldname = 'MEINS'.
  ls_fieldcat-ref_tabname   = 'RESB'.
  APPEND ls_fieldcat TO  gt_fieldcat.
  CLEAR ls_fieldcat.
  pos = pos + 1.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos       =  pos.
  ls_fieldcat-fieldname     = 'XLOEK'.
  ls_fieldcat-ref_fieldname = 'XLOEK'.
  ls_fieldcat-ref_tabname   = 'RESB'.
  APPEND ls_fieldcat TO  gt_fieldcat.
  CLEAR ls_fieldcat.
  pos = pos + 1.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos       =  pos.
  ls_fieldcat-fieldname     = 'KOSTL'.
  ls_fieldcat-ref_fieldname = 'KOSTL'.
  ls_fieldcat-ref_tabname   = 'RKPF'.
  APPEND ls_fieldcat TO  gt_fieldcat.
  CLEAR ls_fieldcat.
  pos = pos + 1.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos       =  pos.
  ls_fieldcat-fieldname     = 'LTEXT'.
  ls_fieldcat-ref_fieldname = 'LTEXT'.
  ls_fieldcat-ref_tabname   = 'CSKT'.
  APPEND ls_fieldcat TO  gt_fieldcat.
  CLEAR ls_fieldcat.
  pos = pos + 1.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos       =  pos.
  ls_fieldcat-fieldname     = 'SAKNR'.
  ls_fieldcat-ref_fieldname = 'SAKNR'.
  ls_fieldcat-ref_tabname   = 'RESB'.
  APPEND ls_fieldcat TO  gt_fieldcat.
  CLEAR ls_fieldcat.
  pos = pos + 1.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos       =  pos.
  ls_fieldcat-fieldname     = 'WEMPF'.
  ls_fieldcat-ref_fieldname = 'WEMPF'.
  ls_fieldcat-ref_tabname   = 'RKPF'.
  APPEND ls_fieldcat TO  gt_fieldcat.
  CLEAR ls_fieldcat.
  pos = pos + 1.

ENDFORM.                    " MERGEFIELD
*&---------------------------------------------------------------------*
*&      Form  PRINTDATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_printdata.
  PERFORM f_eventtab_build CHANGING gt_events.
  PERFORM f_comment_build  CHANGING gt_list_top_of_page.


  gt_layout-zebra = 'X'.
  gt_layout-window_titlebar = text-tt1.
  gt_layout-confirmation_prompt = 'X'.
  gt_layout-get_selinfos = 'X'.
  gt_layout-group_change_edit = 'X'.

  gt_layout-detail_popup = 'X'.
  gt_layout-detail_initial_lines = 'X'.
  gt_layout-reprep   = 'X'.
  gt_layout-detail_titlebar = 'Detail Window'.
  gt_layout-colwidth_optimize = 'X'.
*  gt_layout-lights_fieldname = 'LIGHTS'.
*  gt_layout-lights_tabname = 'IT_DISP'.
*  gt_layout-lights_rollname = 'ZSTAT1'.
  gt_layout-box_fieldname     = 'CSEL'.

*  v_grid_title = text-004.
  DATA: lvc_s_glay TYPE lvc_s_glay.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY' "#EC CI_FLDEXT_OK[2215424] P30K910015
    EXPORTING
      i_callback_program       = v_repid
      i_callback_pf_status_set = v_status
      i_callback_user_command  = text-ucm
      i_grid_title             = v_grid_title
      i_grid_settings          = lvc_s_glay
      is_layout                = gt_layout
      it_fieldcat              = gt_fieldcat[]
      it_sort                  = gt_sortinfo[]
      i_default                = 'X'
      i_save                   = 'A'
      it_events                = gt_events
    TABLES
      t_outtab                 = it_disp
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
ENDFORM.                    " PRINTDATA
*-----------------------------------------------------------------------
*    FORM COMMENT_BUILD
*-----------------------------------------------------------------------
*    ........
*-----------------------------------------------------------------------
*    --> GT_TOP_OF_PAGE
*-----------------------------------------------------------------------
FORM f_comment_build CHANGING gt_top_of_page TYPE slis_t_listheader.
  DATA: gs_line TYPE slis_listheader.
  CLEAR gs_line.
  gs_line-typ  = 'H'.
  gs_line-key  = 'Reservation List'.

  APPEND gs_line TO gt_top_of_page.

  gs_line-typ  = 'S'.

  gs_line-key  = 'Plant'.
  MOVE p_werks TO gs_line-info.
  APPEND gs_line TO gt_top_of_page.

  DATA : date1(10) TYPE c,
         time1(8) TYPE c .
  WRITE : sy-datum TO date1,
          sy-uzeit TO time1.
  gs_line-key  = 'User/Date/Time'.
  CONCATENATE sy-uname '/' date1 '/' time1 INTO gs_line-info.
  APPEND gs_line TO gt_top_of_page.

  gs_line-key  = 'Report ref'.
  gs_line-info = sy-repid.
  APPEND gs_line TO gt_top_of_page.

  DATA : rcount TYPE i.
  DESCRIBE TABLE it_disp LINES rcount.

  gs_line-key  = 'No of Reocrd(s)'.
  gs_line-info = rcount.
  APPEND gs_line TO gt_top_of_page.
ENDFORM.                    "comment_build
*-----------------------------------------------------------------------
*    FORM EVENTTAB_BUILD
*-----------------------------------------------------------------------
*    ........
*-----------------------------------------------------------------------
*    --> LT_EVENTS
*-----------------------------------------------------------------------
FORM f_eventtab_build CHANGING lt_events TYPE slis_t_event.
  REFRESH : lt_events.
  CLEAR : lt_events.

  CONSTANTS:
  gc_formname_top_of_page TYPE slis_formname VALUE 'TOP_OF_PAGE'.
*GC_FORMNAME_END_OF_PAGE TYPE SLIS_FORMNAME VALUE 'END_OF_PAGE'.

  DATA: ls_event TYPE slis_alv_event.

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = lt_events.

  READ TABLE lt_events WITH KEY name =  slis_ev_top_of_page
                           INTO ls_event.
  IF sy-subrc = 0.
    MOVE gc_formname_top_of_page TO ls_event-form.
    APPEND ls_event TO lt_events.
  ENDIF.
ENDFORM.                    "eventtab_build
*---------------------------------------------------------------------*
*       FORM TOP_OF_PAGE                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM top_of_page.
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = gt_list_top_of_page
      i_logo             = 'ENJOYSAP_LOGO'.
ENDFORM.                    "top_of_page
*&---------------------------------------------------------------------*
*&      Form  e06_t_sort_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->E06_LT_SORT  text
*----------------------------------------------------------------------*
FORM f_e06_t_sort_build USING e06_lt_sort TYPE slis_t_sortinfo_alv.
  DATA: ls_sort TYPE slis_sortinfo_alv.

  ls_sort-fieldname = 'RSNUM'.
  ls_sort-tabname   = 'IT_DISP'.
  ls_sort-spos      = 1.
  ls_sort-up        = 'X'.
  APPEND ls_sort TO e06_lt_sort.
  ls_sort-fieldname = 'RSPOS'.
  ls_sort-tabname   = 'IT_DISP'.
  ls_sort-spos      = 2.
  ls_sort-up        = 'X'.
  APPEND ls_sort TO e06_lt_sort.
  ls_sort-fieldname = 'RSDAT'.
  ls_sort-tabname   = 'IT_DISP'.
  ls_sort-spos      = 3.
  ls_sort-up        = 'X'.
  APPEND ls_sort TO e06_lt_sort.
ENDFORM.                    "e06_t_sort_build
*&---------------------------------------------------------------------*
*&      Form  GUI_CUST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->EXTAB      text
*----------------------------------------------------------------------*
FORM gui_cust USING  extab TYPE slis_t_extab.
  SET PF-STATUS 'GUI_CUST1' EXCLUDING extab.
ENDFORM.                    "GUI_CUST

*&---------------------------------------------------------------------*
*&      Form  usr_comm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->IN_UCOMM     text
*      -->IN_SELFIELD  text
*----------------------------------------------------------------------*
FORM usr_comm USING  in_ucomm LIKE sy-ucomm
                             in_selfield TYPE slis_selfield.
  DATA: lfs_data1 LIKE it_disp.
  CLEAR : lfs_data1.

  IF in_ucomm = c_hspt.
    CLEAR it_disp.
    READ TABLE it_disp INDEX in_selfield-tabindex
             INTO lfs_data1.
    IF sy-subrc = 0.
      SET PARAMETER ID: 'RES' FIELD lfs_data1-rsnum.
      CALL TRANSACTION 'MB23' AND SKIP FIRST SCREEN.
    ENDIF.
  ENDIF.

  IF in_ucomm = c_app.
    REFRESH : it_res[],it_resx[],it_rest[].
    CLEAR : it_res[],it_resx[],it_rest[],reservation.

    MESSAGE i000(zmm) WITH text-i01.

    LOOP AT it_disp WHERE csel = 'X' AND xloek = space.
      MOVE-CORRESPONDING it_disp TO it_rest.
      APPEND it_rest.
      CLEAR it_rest.
    ENDLOOP.

    SORT it_rest BY rsnum rspos.
    LOOP AT it_rest.
      AT NEW rsnum.
        REFRESH : it_res[],it_resx[],it_ret[].
        CLEAR : it_res[],it_resx[],reservation,it_ret.
      ENDAT.

      reservation = it_rest-rsnum.

      it_res-res_item = it_rest-rspos.
      it_res-movement = 'X'.
      it_res-item_text = sy-datum.    "change # 001
      it_res-unload_pt = sy-uname.    "change # 001
      APPEND it_res.
      CLEAR it_res.
      it_resx-res_item = it_rest-rspos.
      it_resx-movement = 'X'.
      it_resx-item_text = abap_true.  "change # 001
      it_resx-unload_pt = abap_true.  "change # 001
      APPEND it_resx.
      CLEAR it_resx.

      AT END OF rspos.
        CALL FUNCTION 'BAPI_RESERVATION_CHANGE' "#EC CI_USAGE_OK[2438131] P30K910015
          EXPORTING
            reservation               = reservation
          TABLES
            reservationitems_changed  = it_res
            reservationitems_changedx = it_resx
            return                    = it_ret.



        LOOP AT it_ret WHERE type = 'E' OR type = 'A'.
          CALL FUNCTION 'FORMAT_MESSAGE'
            EXPORTING
              id        = it_ret-id
              lang      = sy-langu
              no        = it_ret-number
              v1        = it_ret-message_v1
              v2        = it_ret-message_v2
              v3        = it_ret-message_v3
              v4        = it_ret-message_v4
            IMPORTING
              msg       = msg
            EXCEPTIONS
              not_found = 1
              OTHERS    = 2.
          it_rest-msg = msg.
          it_rest-sts = 'E'.
          EXIT.
        ENDLOOP.
        IF sy-subrc <> 0.
          it_rest-msg = 'Item approved'.
          it_rest-sts = 'S'.
          UPDATE rkpf SET wempf = space
                      WHERE rsnum = reservation.

          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = 'X'.
        ENDIF.
        MODIFY it_rest.
        CLEAR it_rest.
      ENDAT.
    ENDLOOP.
    MESSAGE i000(zmm) WITH text-004.
    MESSAGE s000(zmm) WITH text-005.
  ELSEIF in_ucomm = c_rej.
    DATA : it_data TYPE STANDARD TABLE OF resb WITH HEADER LINE.

    REFRESH : it_res[],it_resx[],it_rest[],it_data[],it_ret[].
    CLEAR : it_res[],it_resx[],it_rest[],it_data[],reservation,it_ret.
    LOOP AT it_disp WHERE csel = 'X'.
      MOVE-CORRESPONDING it_disp TO it_rest.
      APPEND it_rest.
      CLEAR it_rest.
    ENDLOOP.
    SORT it_rest BY rsnum rspos.

    IF NOT it_rest[] IS INITIAL.
      SELECT * INTO TABLE it_data FROM resb FOR ALL ENTRIES IN it_rest
                                              WHERE rsnum = it_rest-rsnum.
      REFRESH it_rest[].
      CLEAR it_rest[].
    ENDIF.

    SORT it_data BY rsnum rspos.
    LOOP AT it_data.
      AT NEW rsnum.
        REFRESH : it_res[],it_resx[],it_ret[].
        CLEAR : it_res[],it_resx[],reservation,it_ret.
      ENDAT.

      reservation = it_data-rsnum.

      it_res-res_item = it_data-rspos.
      it_res-movement = ' '.
      APPEND it_res.
      CLEAR it_res.
      it_resx-res_item = it_data-rspos.
      it_resx-movement = 'X'.
      APPEND it_resx.
      CLEAR it_resx.

      AT END OF rsnum.

        MOVE it_data-rsnum TO it_rest-rsnum.

        CALL FUNCTION 'BAPI_RESERVATION_CHANGE' "#EC CI_USAGE_OK[2438131] P30K910015
          EXPORTING
            reservation               = reservation
          TABLES
            reservationitems_changed  = it_res
            reservationitems_changedx = it_resx
            return                    = it_ret.

        LOOP AT it_ret WHERE type = 'E' OR type = 'A'.
          CALL FUNCTION 'FORMAT_MESSAGE'
            EXPORTING
              id        = it_ret-id
              lang      = sy-langu
              no        = it_ret-number
              v1        = it_ret-message_v1
              v2        = it_ret-message_v2
              v3        = it_ret-message_v3
              v4        = it_ret-message_v4
            IMPORTING
              msg       = msg
            EXCEPTIONS
              not_found = 1
              OTHERS    = 2.
          it_rest-msg = msg.
          it_rest-sts = 'E'.
          EXIT.
        ENDLOOP.

        IF sy-subrc <> 0.
          it_rest-msg = 'Reservation Rejected'.
          it_rest-sts = 'S'.
          UPDATE rkpf SET wempf = 'REJ'
                      WHERE rsnum = it_data-rsnum.
        ENDIF.

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.

        APPEND it_rest.
        CLEAR it_rest.
      ENDAT.
    ENDLOOP.
    MESSAGE i000(zmm) WITH text-003.
    MESSAGE s000(zmm) WITH text-005.
  ELSEIF in_ucomm = c_log.
    DATA : ltext(80) TYPE c,
           endpos_col TYPE  int4 VALUE '80',
           endpos_row TYPE  int4 VALUE '30',
           startpos_col TYPE  int4 VALUE '5',
           startpos_row TYPE  int4 VALUE '5',
           titletext  TYPE  char80 VALUE 'Processing log',
           choise LIKE  sy-tabix.

    DATA: BEGIN OF listtab OCCURS 1,
           field(80),
          END OF listtab.

    LOOP AT it_rest.
      AT FIRST.
        MOVE 'Processing log' TO listtab-field.
        APPEND listtab.
        CLEAR listtab.
      ENDAT.
      CLEAR ltext.
      IF it_rest-sts = 'E'.
        IF it_rest-rspos IS INITIAL.
          CONCATENATE '@0A@' ' ' it_rest-rsnum ' ' it_rest-msg INTO listtab-field SEPARATED BY space RESPECTING BLANKS.
        ELSE.
          CONCATENATE '@0A@' ' ' it_rest-rsnum ' ' it_rest-rspos ' ' it_rest-msg INTO listtab-field SEPARATED BY space RESPECTING BLANKS.
        ENDIF.
        APPEND listtab.
        CLEAR listtab.
      ELSE.
        IF it_rest-rspos IS INITIAL.
          CONCATENATE '@08@' ' ' it_rest-rsnum ' ' it_rest-msg INTO listtab-field SEPARATED BY space RESPECTING BLANKS.
        ELSE.
          CONCATENATE '@08@' ' ' it_rest-rsnum ' ' it_rest-rspos ' ' it_rest-msg INTO listtab-field SEPARATED BY space RESPECTING BLANKS.
        ENDIF.
        APPEND listtab.
        CLEAR listtab.
      ENDIF.
    ENDLOOP.
    IF sy-subrc = 0.
      CALL FUNCTION 'POPUP_WITH_TABLE_DISPLAY'
        EXPORTING
          endpos_col   = endpos_col
          endpos_row   = endpos_row
          startpos_col = startpos_col
          startpos_row = startpos_row
          titletext    = titletext
        IMPORTING
          choise       = choise
        TABLES
          valuetab     = listtab
        EXCEPTIONS
          break_off    = 1
          OTHERS       = 2.
    ENDIF.
  ENDIF.
ENDFORM.                    "usr_comm
