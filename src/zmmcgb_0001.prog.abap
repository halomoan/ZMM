*&---------------------------------------------------------------------*
*& Report  ZMMCGB_0001
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zmmcgb_0001 LINE-SIZE 200 LINE-COUNT 60 MESSAGE-ID zmm
NO STANDARD PAGE HEADING.
*----------------------------------------------------------------------*
* Title   : Data Migration
* FRICE#  : MM_05
* Author  : Surjeet Singh
* Date    : 08 Sep 2010
* Purpose : Upload and create material master
* Specification Given By: NA

*----------------------------------------------------------------------*
*  MODIFICATION LOG
*-----------------------------------------------------------------------
*  DATE     change #         Programmer  Description.
*-----------------------------------------------------------------------

*----------------------------------------------------------------------*
* I N C L U D E S
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* T Y P E P O O L S
*----------------------------------------------------------------------*
TYPE-POOLS: truxs,ehsww.

*----------------------------------------------------------------------*
* T A B L E S
*----------------------------------------------------------------------*
TABLES : mara.

*----------------------------------------------------------------------*
* I N T E R N A L   T A B L E S
*----------------------------------------------------------------------*
TYPES : BEGIN OF t_mat,
          bismt          TYPE mara-bismt,
          mtart          TYPE mara-mtart,
          matkl          TYPE mara-matkl,
          maktx          TYPE makt-maktx,
          maktx_ch       TYPE makt-maktx,
          meins          TYPE mara-meins,
          ean11          TYPE mara-ean11,
          ntgew          TYPE mara-ntgew,
          gewei          TYPE mara-gewei,
          brgew          TYPE mara-brgew,
          volum          TYPE mara-volum,
          voleh          TYPE mara-voleh,
          werks          TYPE mard-werks,
          lgort          TYPE mard-lgort,
          ekgrp          TYPE marc-ekgrp,
          bstme          TYPE mara-bstme,
          vabme          TYPE vabme,
          nrfhg          TYPE mara-nrfhg,
          kautb          TYPE marc-kautb,
          xchar          TYPE marc-xchar,
          ekwsl          TYPE mara-ekwsl,
          webaz          TYPE marc-webaz,
          text_line(150) TYPE c,
          berid          TYPE smdma-berid,
          dismm          TYPE marc-dismm,
          minbe          TYPE marc-minbe,
          dispo          TYPE marc-dispo,
*         dsnam TYPE t024d-dsnam,
          disls          TYPE marc-disls,
          bstmi          TYPE marc-bstmi,
          bstma          TYPE marc-bstma,
          bstfe          TYPE marc-bstfe,
          bstrf          TYPE marc-bstrf,
          beskz          TYPE marc-beskz,
          plifz          TYPE marc-plifz,
          eisbe          TYPE marc-eisbe,
          mtvfp          TYPE marc-mtvfp,
          etiar          TYPE mara-etiar,
          etifo          TYPE mara-etifo,
          ausme          TYPE marc-ausme,
          mhdrz          TYPE mara-mhdrz,
          mhdhb          TYPE mara-mhdhb,
          iprkz          TYPE char1,
          prctr          TYPE marc-prctr,
          bklas          TYPE mbew-bklas,
          vprsv          TYPE mbew-vprsv,
          verpr          TYPE mbew-verpr,
          peinh          TYPE mbew-peinh,
        END OF t_mat.

DATA : it_mat TYPE STANDARD TABLE OF t_mat.
FIELD-SYMBOLS: <f_mat> TYPE t_mat.

DATA : amara_ueb      TYPE STANDARD TABLE OF mara_ueb WITH HEADER LINE,
       amakt_ueb      TYPE STANDARD TABLE OF makt_ueb WITH HEADER LINE,
       amarc_ueb      TYPE STANDARD TABLE OF marc_ueb WITH HEADER LINE,
       amard_ueb      TYPE STANDARD TABLE OF mard_ueb WITH HEADER LINE,
       amfhm_ueb      TYPE STANDARD TABLE OF mfhm_ueb WITH HEADER LINE,
       amarm_ueb      TYPE STANDARD TABLE OF marm_ueb WITH HEADER LINE,
       amea1_ueb      TYPE STANDARD TABLE OF mea1_ueb WITH HEADER LINE,
       ambew_ueb      TYPE STANDARD TABLE OF mbew_ueb WITH HEADER LINE,
       asteu_ueb      TYPE STANDARD TABLE OF steu_ueb WITH HEADER LINE,
       astmm_ueb      TYPE STANDARD TABLE OF steumm_ueb WITH HEADER LINE,
       amlgn_ueb      TYPE STANDARD TABLE OF mlgn_ueb WITH HEADER LINE,
       amlgt_ueb      TYPE STANDARD TABLE OF mlgt_ueb WITH HEADER LINE,
       ampgd_ueb      TYPE STANDARD TABLE OF mpgd_ueb WITH HEADER LINE,
       ampop_ueb      TYPE STANDARD TABLE OF mpop_ueb WITH HEADER LINE,
       amveg_ueb      TYPE STANDARD TABLE OF mveg_ueb WITH HEADER LINE,
       amveu_ueb      TYPE STANDARD TABLE OF mveu_ueb WITH HEADER LINE,
       amvke_ueb      TYPE STANDARD TABLE OF mvke_ueb WITH HEADER LINE,
       altx1_ueb      TYPE STANDARD TABLE OF ltx1_ueb WITH HEADER LINE,
       amprw_ueb      TYPE STANDARD TABLE OF mprw_ueb WITH HEADER LINE,
       ae1cucfg_ueb	  TYPE STANDARD TABLE OF e1cucfg_ueb WITH HEADER LINE,
       ae1cuins_ueb	  TYPE STANDARD TABLE OF e1cuins_ueb WITH HEADER LINE,
       ae1cuval_ueb	  TYPE STANDARD TABLE OF e1cuval_ueb WITH HEADER LINE,
       ae1cucom_ueb	  TYPE STANDARD TABLE OF e1cucom_ueb WITH HEADER LINE,
       amfieldres     TYPE STANDARD TABLE OF mfieldres WITH HEADER LINE,
       amerrdat	      TYPE STANDARD TABLE OF merrdat WITH HEADER LINE,
       a_nfm_tkgw_ueb	TYPE STANDARD TABLE OF /nfm/tkgw_ueb WITH HEADER LINE,
       a_nfm_tvgw_ueb	TYPE STANDARD TABLE OF /nfm/tvgw_ueb WITH HEADER LINE,
       jtkgw          TYPE STANDARD TABLE OF /nfm/wptkgw WITH HEADER LINE,
       jtvgw          TYPE STANDARD TABLE OF /nfm/wptvgw WITH HEADER LINE.

*----------------------------------------------------------------------*
* C O N S T A N T   A N D   V A R I A B L E S
*----------------------------------------------------------------------*
DATA : mat_msg(200) TYPE c.
DATA: init_tranc LIKE mueb_rest-tranc VALUE 1.
DATA: d_ind LIKE mara_ueb-d_ind.

*----------------------------------------------------------------------*
* R A N G E S
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
*  P A R A M E T E R S  &  S E L E C T - O P T I O N S
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-b01.
PARAMETERS : p_file LIKE file_table-filename.
PARAMETERS : p_bsc RADIOBUTTON GROUP mod2 DEFAULT 'X',
             p_all RADIOBUTTON GROUP mod2.
SELECTION-SCREEN END OF BLOCK b1.

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
  PERFORM upload_file_local.
  PERFORM validate_data.
  PERFORM build_data.


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
  DATA : f_name TYPE string,
         f_len  TYPE i,
         f_head TYPE xstring.
  DATA : l_header TYPE char1,
         it_raw   TYPE truxs_t_text_data.
  CLEAR: f_name,f_len,f_head.
  f_name = p_file.
  DATA : file LIKE rlgrap-filename.
  file = p_file.
  l_header = 'X'.
  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
      i_line_header        = l_header
      i_tab_raw_data       = it_raw
      i_filename           = file
    TABLES
      i_tab_converted_data = it_mat[]
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  IF it_mat[] IS INITIAL.
    MESSAGE i001(zfi) WITH 'File Error' 'No data was uploaded'.
    STOP.
  ENDIF.
ENDFORM.                    " UPLOAD_FILE_LOCAL
*&---------------------------------------------------------------------*
*&      Form  VALIDATE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validate_data .
  DATA : indx TYPE sy-tabix.
  DATA : wa_mat TYPE t_mat.
  DATA : temp_mat TYPE STANDARD TABLE OF t_mat.
  DATA : count TYPE sy-tabix.
  temp_mat[] = it_mat[].
  LOOP AT it_mat ASSIGNING <f_mat>.
    CLEAR : wa_mat,count.
    indx = sy-tabix.
    IF p_bsc = 'X'.
      SELECT SINGLE * FROM mara WHERE bismt = <f_mat>-bismt.
      IF sy-subrc = 0.
*Start replacement brianrabe P30K909970
*        WRITE :/1 <f_mat>-bismt, 35 'Old material number already exist for',
*               85 mara-matnr.
        WRITE :/1 <f_mat>-bismt, 57 'Old material number already exist for',
               107 mara-matnr.
*End replacement brianrabe P30K909970
        DELETE it_mat INDEX indx.
        CONTINUE.
      ENDIF.
      LOOP AT temp_mat INTO wa_mat WHERE bismt = <f_mat>-bismt.
        ADD 1 TO count.
        IF count > 1.
*Start replacement brianrabe P30K909970
*          WRITE :/1 <f_mat>-bismt, 35 'Duplicate record exist in Excel file'.
          WRITE :/1 <f_mat>-bismt, 57 'Duplicate record exist in Excel file'.
*End replacement brianrabe P30K909970
          DELETE it_mat INDEX indx.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " VALIDATE_DATA
*&---------------------------------------------------------------------*
*&      Form  CREATE_MATNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_matnr USING p_indx p_mat TYPE t_mat CHANGING p_msg.
  DATA: c_false    VALUE ' ',
        matnr_last LIKE  mara-matnr,
        err_trans  LIKE  tbist-numerror,
        msg(200)   TYPE c.
  REFRESH amerrdat[].
  CLEAR amerrdat.

  CALL FUNCTION 'MATERIAL_MAINTAIN_DARK'
    EXPORTING
      p_kz_no_warn              = 'N'
      kz_prf                    = 'W'
      kz_aend                   = 'X'
      kz_verw                   = 'X'
      kz_dispo                  = 'X'
      call_mode                 = ''
      sperrmodus                = 'E'
      max_errors                = 1
      flag_muss_pruefen         = c_false
    IMPORTING
      matnr_last                = matnr_last
      number_errors_transaction = err_trans
    TABLES
      amara_ueb                 = amara_ueb
      amakt_ueb                 = amakt_ueb
      amarc_ueb                 = amarc_ueb
      amard_ueb                 = amard_ueb
      amfhm_ueb                 = amfhm_ueb
      amarm_ueb                 = amarm_ueb
      amea1_ueb                 = amea1_ueb
      ambew_ueb                 = ambew_ueb
      asteu_ueb                 = asteu_ueb
      astmm_ueb                 = astmm_ueb
      amlgn_ueb                 = amlgn_ueb
      amlgt_ueb                 = amlgt_ueb
      ampgd_ueb                 = ampgd_ueb
      ampop_ueb                 = ampop_ueb
      amveg_ueb                 = amveg_ueb
      amveu_ueb                 = amveu_ueb
      amvke_ueb                 = amvke_ueb
      altx1_ueb                 = altx1_ueb
      amprw_ueb                 = amprw_ueb
      ae1cucfg_ueb              = ae1cucfg_ueb
      ae1cuins_ueb              = ae1cuins_ueb
      ae1cuval_ueb              = ae1cuval_ueb
      ae1cucom_ueb              = ae1cucom_ueb
      amfieldres                = amfieldres
      amerrdat                  = amerrdat
    EXCEPTIONS
      kstatus_empty             = 1
      tkstatus_empty            = 2
      t130m_error               = 3
      internal_error            = 4
      too_many_errors           = 5
      update_error              = 6
      error_propagate_header    = 7
      OTHERS                    = 8.

  IF sy-subrc = 0.
    CLEAR msg.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
*It return subrc as true but sometime still no changes recorded
    LOOP AT amerrdat WHERE matnr <> space.
      CALL FUNCTION 'FORMAT_MESSAGE'
        EXPORTING
          id        = amerrdat-msgid
          lang      = 'EN'
          no        = amerrdat-msgno
          v1        = amerrdat-msgv1
          v2        = amerrdat-msgv2
          v3        = amerrdat-msgv3
          v4        = amerrdat-msgv4
        IMPORTING
          msg       = msg
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.
      p_msg = amerrdat-matnr.
*Start replacement brianrabe P30K909970
*      WRITE :/ p_indx, 15 p_mat-bismt, 35 p_msg.
      WRITE :/ p_indx, 15 p_mat-bismt, 57 p_msg.
*End replacement brianrabe P30K909970
      EXIT.
    ENDLOOP.
    IF sy-subrc <> 0.
      LOOP AT amerrdat WHERE msgty = 'E' OR msgty = 'H' OR msgty = 'D'.
        CALL FUNCTION 'FORMAT_MESSAGE'
          EXPORTING
            id        = amerrdat-msgid
            lang      = 'EN'
            no        = amerrdat-msgno
            v1        = amerrdat-msgv1
            v2        = amerrdat-msgv2
            v3        = amerrdat-msgv3
            v4        = amerrdat-msgv4
          IMPORTING
            msg       = msg
          EXCEPTIONS
            not_found = 1
            OTHERS    = 2.
*Start replacement brianrabe P30K909970
*        WRITE :/ p_indx, 15 p_mat-bismt, 35 msg.
        WRITE :/ p_indx, 15 p_mat-bismt, 57 msg.
*End replacement brianrabe P30K909970
      ENDLOOP.
    ENDIF.

  ELSE.
    LOOP AT amerrdat WHERE msgty = 'E' OR msgty = 'H' OR msgty = 'D'.
      CALL FUNCTION 'FORMAT_MESSAGE'
        EXPORTING
          id        = amerrdat-msgid
          lang      = 'EN'
          no        = amerrdat-msgno
          v1        = amerrdat-msgv1
          v2        = amerrdat-msgv2
          v3        = amerrdat-msgv3
          v4        = amerrdat-msgv4
        IMPORTING
          msg       = msg
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.
*Start replacement brianrabe P30K909970
*        WRITE :/ p_indx, 15 p_mat-bismt, 35 msg.
      WRITE :/ p_indx, 15 p_mat-bismt, 57 msg.
*End replacement brianrabe P30K909970
    ENDLOOP.
  ENDIF.
ENDFORM.                    " CREATE_MATNR
*&---------------------------------------------------------------------*
*&      Form  BUILD_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_data .
  DATA : indx    TYPE sy-index,
         wa_mara TYPE mara.
  CLEAR indx.
  d_ind = d_ind + 1.
  LOOP AT it_mat ASSIGNING <f_mat>.
    CLEAR wa_mara.
    REFRESH : amara_ueb[],amakt_ueb[],amarc_ueb[],amard_ueb[],amarm_ueb[],amarm_ueb[],ambew_ueb[].
    CLEAR : amara_ueb,amakt_ueb,amarc_ueb,amard_ueb,amarm_ueb,amarm_ueb,ambew_ueb.
    indx = sy-tabix.
    IF  p_bsc = 'X'.
      MOVE-CORRESPONDING <f_mat> TO amara_ueb.
      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
        EXPORTING
          input    = <f_mat>-meins
          language = sy-langu
        IMPORTING
          output   = amara_ueb-meins.

*    amara_ueb-BSTME = amara_ueb-meins.
      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
        EXPORTING
          input    = <f_mat>-voleh
          language = sy-langu
        IMPORTING
          output   = amara_ueb-voleh.

      CALL FUNCTION 'CONVERSION_EXIT_PERKZ_INPUT'
        EXPORTING
          input  = <f_mat>-iprkz
        IMPORTING
          output = amara_ueb-iprkz.

      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
        EXPORTING
          input    = <f_mat>-bstme
          language = sy-langu
        IMPORTING
          output   = amara_ueb-bstme.

      amara_ueb-mandt = sy-mandt.
      amara_ueb-tcode = 'MM01'.
      amara_ueb-mbrsh = 'H'.

      amara_ueb-vpsta = 'K'.
      amara_ueb-pstat = 'K'.

      amara_ueb-xchpf = <f_mat>-xchar.
      amara_ueb-tranc = init_tranc.
      amara_ueb-d_ind = d_ind.
      APPEND amara_ueb.
      CLEAR amara_ueb.
      MOVE-CORRESPONDING <f_mat> TO amakt_ueb.
      amakt_ueb-mandt = sy-mandt.
      amakt_ueb-spras = sy-langu.
      amakt_ueb-tranc = init_tranc.
      amakt_ueb-d_ind = d_ind.
      APPEND amakt_ueb.
      CLEAR amakt_ueb.

      IF NOT <f_mat>-maktx_ch IS INITIAL.
        MOVE-CORRESPONDING <f_mat> TO amakt_ueb.
        amakt_ueb-mandt = sy-mandt.
        amakt_ueb-spras = '1'.
        amakt_ueb-maktx = <f_mat>-maktx_ch.
        amakt_ueb-tranc = init_tranc.
        amakt_ueb-d_ind = d_ind.
        APPEND amakt_ueb.
        CLEAR amakt_ueb.
      ENDIF.

    ELSE.
      SELECT SINGLE * INTO wa_mara FROM mara WHERE bismt = <f_mat>-bismt.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING <f_mat> TO amara_ueb.
        MOVE wa_mara-matnr TO amara_ueb-matnr.

        CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
          EXPORTING
            input    = <f_mat>-meins
            language = sy-langu
          IMPORTING
            output   = amara_ueb-meins.

*    amara_ueb-BSTME = amara_ueb-meins.
        CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
          EXPORTING
            input    = <f_mat>-voleh
            language = sy-langu
          IMPORTING
            output   = amara_ueb-voleh.

        CALL FUNCTION 'CONVERSION_EXIT_PERKZ_INPUT'
          EXPORTING
            input  = <f_mat>-iprkz
          IMPORTING
            output = amara_ueb-iprkz.

        CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
          EXPORTING
            input    = <f_mat>-bstme
            language = sy-langu
          IMPORTING
            output   = amara_ueb-bstme.

        amara_ueb-mandt = sy-mandt.
        amara_ueb-tcode = 'MM01'.
        amara_ueb-mbrsh = 'H'.

        DATA : pstat LIKE t134-pstat.
        CLEAR pstat.
        SELECT SINGLE pstat INTO pstat FROM t134 WHERE mtart = <f_mat>-mtart.
*        amara_ueb-vpsta = 'KEDLBZX'.
*        amara_ueb-pstat = 'KEDLB'.

        amara_ueb-vpsta = pstat.
        amara_ueb-pstat = pstat.
        amara_ueb-tranc = init_tranc.
        amara_ueb-d_ind = d_ind.

        APPEND amara_ueb.
        CLEAR amara_ueb.
      ELSE.

      ENDIF.
    ENDIF.
    IF  p_bsc <> 'X'.
      MOVE-CORRESPONDING <f_mat> TO amarc_ueb.
      MOVE wa_mara-matnr TO amarc_ueb-matnr.
      amarc_ueb-mandt = sy-mandt.
*      amarc_ueb-pstat = 'EDLB'.
      amarc_ueb-pstat = pstat.
      amarc_ueb-xchpf = <f_mat>-xchar.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <f_mat>-prctr
        IMPORTING
          output = amarc_ueb-prctr.

      amarc_ueb-tranc = init_tranc.
      amarc_ueb-d_ind = d_ind.
      CLEAR : amarc_ueb-ekgrp.
      APPEND amarc_ueb.
      CLEAR amarc_ueb.

      SELECT SINGLE pstat INTO pstat FROM t134 WHERE mtart = <f_mat>-mtart.
      IF pstat CA 'L'.
        MOVE-CORRESPONDING <f_mat> TO amard_ueb.
        MOVE wa_mara-matnr TO amard_ueb-matnr.
        amard_ueb-mandt = sy-mandt.
        amard_ueb-tranc = init_tranc.
        amard_ueb-d_ind = d_ind.
        amard_ueb-pstat = pstat.

        APPEND amard_ueb.
        CLEAR amard_ueb.
      ENDIF.

      MOVE-CORRESPONDING <f_mat> TO amarm_ueb.
      MOVE wa_mara-matnr TO amarm_ueb-matnr.
      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
        EXPORTING
          input    = <f_mat>-meins
          language = sy-langu
        IMPORTING
          output   = amarm_ueb-meinh.
      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
        EXPORTING
          input    = <f_mat>-voleh
          language = sy-langu
        IMPORTING
          output   = amarm_ueb-voleh.
      amarm_ueb-mandt = sy-mandt.
      amarm_ueb-tranc = init_tranc.
      amarm_ueb-d_ind = d_ind.
      APPEND amarm_ueb.
      CLEAR amarm_ueb.


*    MOVE-CORRESPONDING <f_mat> TO amvke_ueb.
*    APPEND amvke_ueb.
*    CLEAR amvke_ueb.

      MOVE-CORRESPONDING <f_mat> TO ambew_ueb.
      MOVE wa_mara-matnr TO ambew_ueb-matnr.
      ambew_ueb-mandt = sy-mandt.
      ambew_ueb-pstat = 'B'.
      ambew_ueb-bwkey = <f_mat>-werks.
      ambew_ueb-tranc = init_tranc.
      ambew_ueb-d_ind = d_ind.
      APPEND ambew_ueb.
      CLEAR ambew_ueb.
    ENDIF.
*    amfieldres-tranc = init_tranc.

    CHECK NOT amara_ueb[] IS INITIAL.
    PERFORM create_matnr USING indx <f_mat> CHANGING mat_msg.


*Update Text
    " UPG Retrofit Changes : TR : P30K909941 User : AKSHAYK : Start
    TYPES: BEGIN OF ehsww_text,
             text(512),
*        form(2),
           END OF ehsww_text,
           ehsww_text_t   TYPE ehsww_text OCCURS 0,
           ehsww_text72_t TYPE ehsww_text OCCURS 0.
    " UPG Retrofit Changes : TR : P30K909941 User : AKSHAYK : End
    DATA : header LIKE  thead.
    DATA : it_cust_text TYPE STANDARD TABLE OF ehsww_text,
           wa_text      TYPE ehsww_text.
    DATA : it_lines LIKE TABLE OF tline WITH HEADER LINE.
    DATA matnr TYPE mara-matnr.
    DATA : head_text TYPE char512.
    REFRESH : it_lines[],it_cust_text.
    CLEAR : wa_text,header,head_text,matnr.
    IF NOT <f_mat>-text_line IS INITIAL.
      SELECT * FROM mara WHERE bismt = <f_mat>-bismt
                            ORDER BY matnr DESCENDING.
        matnr = mara-matnr.
        EXIT.
      ENDSELECT.

      IF sy-subrc = 0.

        head_text = <f_mat>-text_line.
        header-tdobject = 'MATERIAL'.
        header-tdid = 'BEST'.
        header-tdspras = sy-langu.
        MOVE matnr TO header-tdname.

*Start of replacement brianrabe P30K909970
*        CALL FUNCTION 'EHS00_WORDWRAP02'
*          EXPORTING
*            im_string = head_text
*            im_len    = 70
*          TABLES
*            ex_ftext  = it_cust_text.
*
*        LOOP AT it_cust_text INTO wa_text.
*          it_lines-tdformat = '*'.
*          it_lines-tdline = wa_text-text.
*          APPEND it_lines.
*        ENDLOOP.
        DATA : lv_textline(512) TYPE c,
               lt_outline       TYPE TABLE OF char512,
               ls_outline       LIKE LINE OF lt_outline.

        lv_textline = <f_mat>-text_line.

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
            it_lines-tdformat = '*'.
            it_lines-tdline = ls_outline.
            APPEND it_lines.
          ENDLOOP.
        ENDIF.
*End of replacement brianrabe P30K909970

        CALL FUNCTION 'SAVE_TEXT'
          EXPORTING
            client          = sy-mandt
            header          = header
            savemode_direct = 'X'
          TABLES
            lines           = it_lines.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " BUILD_DATA
