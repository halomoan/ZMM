*&---------------------------------------------------------------------*
*& Report  ZMM_PO_APPROVER_NOTIFICATION
*&
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*  MODIFICATION LOG
*-----------------------------------------------------------------------
*  DATE       change #    Programmer  Description.
*-----------------------------------------------------------------------
* 13.11.2018   BL01      Belindalee  Add a sort for table userlist &
*                                    gt_usr05 in Form READ_USER_WITH_PROF.
*----------------------------------------------------------------------*

REPORT  ZMM_PO_APPROVER_NOTIFICATION.


TYPE-POOLS: abap.

  CONSTANTS:
    lc_ptype_c        TYPE c        VALUE 'C',
    lc_ptype_s        TYPE c        VALUE 'S',
    lc_aktps_a        TYPE xuaktpas VALUE 'A',  "object status: active
    gc_authobj        TYPE XUOBJECT VALUE 'M_EINK_FRG',
    gc_fld_rg         TYPE XUFIELD  VALUE 'FRGGR',
    gc_fld_rc         TYPE XUFIELD  VALUE 'FRGCO',
    lc_dot_user(12)   TYPE c VALUE '............'.

  CONSTANTS:
    gc_lvl0           TYPE x VALUE  0, "call level 0 in recursion
    gc_lvln           TYPE x VALUE  1.

  TYPES:
    BEGIN OF ts_profs,
      profn  TYPE xuprofile,
    END OF  ts_profs,
    tt_profs TYPE TABLE OF ts_profs,

    BEGIN OF ts_prfs_lst,
       profn   TYPE xuprofile,
       subprof TYPE xuprofile,
       typ     TYPE xutyp,
    END OF ts_prfs_lst,
    tt_prfs_lst TYPE TABLE OF ts_prfs_lst,


    BEGIN OF ts_rel_str,          "Type release strategy
      no    TYPE i,
      rg    TYPE FRGGR,
      rc    TYPE FRGCO,
      rg_desc TYPE FRGGT,
      rc_desc TYPE FRGCT,
      is_released TYPE abap_bool,
      current_approval TYPE abap_bool,
    END OF ts_rel_str,
    tt_rel_str TYPE SORTED TABLE OF ts_rel_str WITH UNIQUE KEY no,

    BEGIN OF type_auth,
         auth LIKE ust12-auth,
    END OF type_auth ,
    type_auth_table TYPE SORTED TABLE OF type_auth
                              WITH UNIQUE KEY auth,

    BEGIN OF ts_auth,          "Type authorization
      no    TYPE i,
      rg    TYPE FRGGR,
      rc    TYPE FRGCO,
      auth  LIKE ust12-auth,
      profn TYPE XUPROFILE,
    END OF ts_auth,
    tt_auth TYPE TABLE OF ts_auth,

    BEGIN OF ts_prof,          "Type profiles
      no    TYPE i,
      rg    TYPE FRGGR,
      rc    TYPE FRGCO,
      profn TYPE XUPROFILE,
    END OF ts_prof,
    tt_prof TYPE TABLE OF ts_prof,

    BEGIN OF ts_user_list,          "Type Userlist
      bname     TYPE xubname,
      SMTP_ADDR TYPE adr6-SMTP_ADDR,
      gltgv     LIKE usr02-gltgv,
      gltgb     LIKE usr02-gltgb,
      name_first LIKE adrp-name_first,
      name_last  LIKE adrp-name_last,
    END OF ts_user_list,

                                                 "note 382010/2
  BEGIN OF t_userlist,
    bname     LIKE usr02-bname,
    profile   LIKE ust04-profile,
  END OF   t_userlist,
  t_it_userlist TYPE STANDARD TABLE OF t_userlist,
*                     WITH KEY bname profile,

  BEGIN OF ts_range_prof,
    SIGN      TYPE c,
    OPTION(2) TYPE c,
    LOW       TYPE xuprofile,
    HIGH      TYPE xuprofile,
  END OF ts_range_prof,
  tt_range_prof TYPE STANDARD TABLE OF ts_range_prof.


  DATA:
    gv_ret1     TYPE x,
    gt_prof_lst TYPE tt_prfs_lst,
    gt_cprfn    TYPE tt_profs,

    gt_alv_log  TYPE TABLE OF bapiret2,
    gt_usr05    TYPE TABLE OF usr05.          "User Parameter table






TYPES: tt_ekpo TYPE TABLE OF uekpo,
       tt_eket TYPE TABLE OF ueket.

DATA: gt_rel_str TYPE tt_rel_str,
      gt_ust12   TYPE ust12 OCCURS 0,
      p_a1       TYPE type_auth_table,
      gt_auth    TYPE tt_auth,
      gt_prof    TYPE tt_prof,
      gr_prof    TYPE tt_range_prof,
      userlist   TYPE STANDARD TABLE OF ts_user_list WITH HEADER LINE,
      final_list TYPE STANDARD TABLE OF ts_user_list WITH HEADER LINE,

      "Email utilities
      w_doc_data      TYPE sodocchgi1,
      t_packing_list  LIKE sopcklsti1 OCCURS 0 WITH HEADER LINE,
      it_message      TYPE STANDARD TABLE OF solisti1 WITH HEADER LINE,     "Email message body content
      t_receivers     LIKE somlreci1 OCCURS 0 WITH HEADER LINE,

      gt_ekpo         TYPE tt_ekpo,
      gt_eket         TYPE tt_eket,
      git_ust042      TYPE  t_it_userlist,
      final_user      TYPE  t_it_userlist,
      gv_rel_str_completed TYPE c,            "Release Strategy Completed flag
      gv_po_rejected  TYPE c,                 "PO Rejected flag
      gv_po_reject_cancelled TYPE c,          "PO Reject Cancellation flag
      gv_got_approvers_zpoemail TYPE c.       "Got approvers with ZPOEMAIL = 'X' parameter



LOAD-OF-PROGRAM .
  PERFORM LOAD_CPROFILES.
  PERFORM susi_resolve_all_comp_profs.
  PERFORM load_user_parameter.
*&---------------------------------------------------------------------*
*&      Form  LOAD_PROGRAM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form LOAD_CPROFILES .

    IF NOT gt_cprfn[] IS INITIAL.
      RETURN.
    ENDIF.

* get all c-profiles in a simple list
    SELECT profn FROM usr10 INTO TABLE gt_cprfn       "#EC CI_SGLSELECT
      WHERE aktps = lc_aktps_a
        AND typ   = lc_ptype_c.                         "#EC CI_GENBUFF

    SORT gt_cprfn.

endform.                    " LOAD_CPROFILES

FORM susi_resolve_one_prof USING  value(pv_prof)     TYPE xuprofile
                                    pt_prof            TYPE tt_prfs_lst
                                    pt_rec_chk         TYPE tt_profs
                                    pv_ret             TYPE x.

*    CONSTANTS:
*      lc_ptype_c        TYPE c        VALUE 'C',
*      lc_ptype_s        TYPE c        VALUE 'S',
*      lc_aktps_a        TYPE xuaktpas VALUE 'A'.  "object status: active

    STATICS:
      lt_ust10c TYPE STANDARD TABLE OF ust10c.

    DATA:
      lv_index      TYPE sytabix,
      lt_return     TYPE tt_prfs_lst,
      lt_rec_chk    TYPE tt_profs,
      lt_profs      TYPE tt_profs,
      lt_prf_lst    TYPE tt_prfs_lst,
      ls_prf_lst    TYPE ts_prfs_lst.

    FIELD-SYMBOLS:
      <fs_ust10c>   TYPE ust10c,
      <fs_prof>     TYPE ts_profs,
      <fs_prof_lst> TYPE ts_prfs_lst.
*----------------------------------------------------------------------*

    IF lt_ust10c[] IS INITIAL.
      SELECT * FROM ust10c INTO TABLE lt_ust10c
                WHERE aktps EQ lc_aktps_a.              "#EC CI_GENBUFF
      SORT lt_ust10c.
    ENDIF.

    ls_prf_lst-profn = pv_prof.
* 1a. get subprofiles for pv_prof including prof-type
    READ TABLE lt_ust10c WITH KEY profn = pv_prof
                                  aktps = lc_aktps_a
                         BINARY SEARCH
                         TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      lv_index = sy-tabix.
      LOOP AT lt_ust10c ASSIGNING <fs_ust10c> FROM lv_index.
        IF <fs_ust10c>-profn =  pv_prof.
          APPEND  <fs_ust10c>-subprof TO lt_profs.
        ELSE.
          EXIT. " hier darf kein RETRUN stehen!!!
        ENDIF.
      ENDLOOP.
    ELSE.
      EXIT. " hier darf kein RETRUN stehen!!!
    ENDIF.

    IF lt_profs[] IS INITIAL.
      RETURN.
    ENDIF.

* 1b. prepare the list for appending into global list,
*     resolve the actual level
    LOOP AT lt_profs ASSIGNING <fs_prof> .

      READ TABLE gt_cprfn  WITH KEY profn = <fs_prof>-profn
           BINARY SEARCH
           TRANSPORTING NO FIELDS.
      IF sy-subrc IS INITIAL .                  "it's a c-profile
        READ TABLE pt_rec_chk WITH KEY profn = <fs_prof>-profn
             BINARY SEARCH                     " note 1427001
             TRANSPORTING NO FIELDS.
        IF sy-subrc IS INITIAL.  "c-prof exists in recursiv check table!!!
          pv_ret = 1.
          EXIT. " hier darf kein RETRUN stehen!!!
        ENDIF.

*     - 2nd resolve this composite profile
        lt_rec_chk[] = pt_rec_chk[].
        APPEND <fs_prof>-profn TO lt_rec_chk[].

        PERFORM susi_resolve_one_prof USING <fs_prof>-profn
                                            lt_return[]
                                            lt_rec_chk
                                            gv_ret1.        "#EC *
        IF gv_ret1 IS INITIAL.
*       add results to the result list on this resolution level
          ls_prf_lst-subprof = <fs_prof>-profn.
          ls_prf_lst-typ     = lc_ptype_c.
          APPEND ls_prf_lst TO lt_prf_lst.

          LOOP AT lt_return ASSIGNING <fs_prof_lst> .
            <fs_prof_lst>-profn = pv_prof.
            APPEND <fs_prof_lst> TO lt_prf_lst .
          ENDLOOP.
          CLEAR: lt_return[].
        ENDIF.
      ELSE.
*     it's a single profile ... append to return list
        ls_prf_lst-subprof = <fs_prof>-profn.
        ls_prf_lst-typ     = lc_ptype_s.
        APPEND ls_prf_lst TO lt_prf_lst.

      ENDIF.

    ENDLOOP.

    APPEND LINES OF lt_prf_lst TO pt_prof. "respect recursiv call
    SORT pt_prof BY typ subprof.
    DELETE ADJACENT DUPLICATES FROM pt_prof.


ENDFORM.                     "susi_resolve_one_prof.
*&---------------------------------------------------------------------*
*&      Form  LOAD_USER_PARAMETER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form LOAD_USER_PARAMETER .

  REFRESH: gt_usr05[].

  SELECT * FROM usr05 INTO TABLE gt_usr05
   WHERE parid = 'ZPOEMAIL'
     AND parva = 'X'.

endform.                    " LOAD_USER_PARAMETER

form po_approver_email TABLES xexpo         TYPE tt_ekpo
                              xeket         TYPE tt_eket
                       USING  VALUE(i_ekko) TYPE ekko
                              VALUE(i_ekko_old) TYPE ekko.

  PERFORM init_vars.
  PERFORM arrange_xexpo TABLES xexpo
                        USING  i_ekko.
  PERFORM arrange_xeket TABLES xeket
                        USING  i_ekko.
  PERFORM get_release_code USING i_ekko.
  PERFORM get_auth.
  PERFORM get_profs.
  PERFORM read_user_with_prof USING i_ekko.
  PERFORM validate_obj_plant TABLES gt_ekpo.
  PERFORM get_email_address.
  PERFORM generate_email TABLES gt_ekpo
                                gt_eket
                         USING  i_ekko
                                i_ekko_old.

endform.                    " po_approver_email
*&---------------------------------------------------------------------*
*&      Form  SUSI_RESOLVE_ALL_COMP_PROFS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form SUSI_RESOLVE_ALL_COMP_PROFS .


    DATA:
      lv_msg1    TYPE symsgv,
      lv_msg2    TYPE symsgv,
      lv_msg3    TYPE symsgv,
      ls_return  TYPE bapiret2,
      lt_return  TYPE tt_prfs_lst,
      lt_rec_chk TYPE tt_profs.

    FIELD-SYMBOLS:
      <fs_one_prof> TYPE ts_profs.

*----------------------------------------------------------------------*
* now we have to resolve all c-profiles and have now to resolve them
    LOOP AT gt_cprfn ASSIGNING <fs_one_prof>.
      CLEAR: lt_return[],
             lt_rec_chk[],
             gv_ret1.
      PERFORM susi_resolve_one_prof USING  <fs_one_prof>-profn
                                           lt_return[]
                                           lt_rec_chk
                                           gv_ret1.
      IF gv_ret1 IS INITIAL.
        APPEND LINES OF lt_return TO gt_prof_lst.
      ELSE.
        lv_msg1 = 'Inconsistent composite profile'(e01).    "#EC *
        lv_msg2 = 'is not analyzed'(e02).                   "#EC *
        lv_msg3 = '(profile contains cycles).'(e03) .       "#EC *
        CONCATENATE lv_msg1 <fs_one_prof>-profn
               INTO lv_msg1
               SEPARATED BY space.

        IF sy-batch IS INITIAL .

          CALL FUNCTION 'BALW_BAPIRETURN_GET2'
            EXPORTING
              type   = 'W'
              cl     = '01'
              number = '319'
              par1   = lv_msg1
              par2   = lv_msg2
              par3   = lv_msg3
            IMPORTING
              return = ls_return.
          APPEND ls_return TO gt_alv_log.
        ELSE.

          MESSAGE ID '01' TYPE 'I'  NUMBER '319'
                  WITH lv_msg1
                       lv_msg2
                       lv_msg3.
        ENDIF.
      ENDIF.
    ENDLOOP.

*   prepare fast search inl susi_get_father_profs
    SORT gt_prof_lst BY subprof.

endform.                    " SUSI_RESOLVE_ALL_COMP_PROFS
*&---------------------------------------------------------------------*
*&      Form  GET_RELEASE_CODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_EKKO  text
*----------------------------------------------------------------------*
form GET_RELEASE_CODE  using   value(i_ekko) TYPE ekko.

  CONSTANTS: mand_col_name(4) TYPE c VALUE 'FRGC'.

  DATA: lv_index               TYPE i,
        lv_indexc              TYPE c,
        ls_rel_str             TYPE ts_rel_str,
        lv_col_name(10)        TYPE c,
        ls_t16fs               TYPE t16fs,
        lv_max_rc              TYPE i,
        lv_frgzu_len           TYPE i,
        ls_t16fh               TYPE t16fh,   "Relase Group Description
        lt_t16fd               TYPE SORTED TABLE OF t16fd   "Relase Code Description
                               WITH UNIQUE KEY spras frggr frgco WITH HEADER LINE.

  FIELD-SYMBOLS: <fs_rel_code> TYPE FRGCO,
                 <fs_rel_str>  TYPE ts_rel_str.

  CHECK i_ekko-frggr IS NOT INITIAL AND
        i_ekko-frgsx IS NOT INITIAL.

* Load Release Group Descriptions
  SELECT SINGLE * FROM t16fh INTO ls_t16fh
   WHERE spras = sy-langu
     AND frggr = i_ekko-frggr.

* Load Release Code Descriptions
  SELECT * FROM t16fd INTO TABLE lt_t16fd
   WHERE spras = sy-langu
     AND frggr = i_ekko-frggr.

* Load Release Strategy
  SELECT SINGLE * FROM t16fs INTO ls_t16fs
   WHERE frggr = i_ekko-frggr
     AND frgsx = i_ekko-frgsx.

  IF sy-subrc = 0.

    DO 8 TIMES.

      CLEAR: ls_rel_str.

      ADD 1 TO lv_index.
      WRITE lv_index TO lv_indexc.
      CONCATENATE mand_col_name lv_indexc INTO lv_col_name.

      ASSIGN COMPONENT lv_col_name OF STRUCTURE ls_t16fs TO <fs_rel_code>.
      IF <fs_rel_code> IS INITIAL.
        EXIT.
      ELSE.

        ls_rel_str-no = lv_index.
        ls_rel_str-rg = i_ekko-frggr.
        ls_rel_str-rc = <fs_rel_code>.
        ls_rel_str-rg_desc = ls_t16fh-frggt.      "Release Group Desc

        READ TABLE lt_t16fd WITH TABLE KEY spras = sy-langu
                                           frggr = i_ekko-frggr
                                           frgco = ls_rel_str-rc.
        IF sy-subrc = 0.
          ls_rel_str-rc_desc = lt_t16fd-frgct.    "Release Code Desc
        ENDIF.

        APPEND ls_rel_str TO gt_rel_str.

*       Note the count of all Release Codes
        lv_max_rc = lv_index.

      ENDIF.

    ENDDO.

*   Get current release position
    lv_frgzu_len = STRLEN( i_ekko-frgzu ).

*   If approval have reached max Release Code, set all release code as RELEASED
    IF lv_max_rc = lv_frgzu_len.

      LOOP AT gt_rel_str ASSIGNING <fs_rel_str>.
        <fs_rel_str>-is_released = abap_true.
      ENDLOOP.
      UNASSIGN <fs_rel_str>.

      "Set global variable of Release Strategy Completed
      gv_rel_str_completed = abap_true.

    ELSE.
*      Get the next level approver of current release position
      ADD 1 TO lv_frgzu_len.

      LOOP AT gt_rel_str ASSIGNING <fs_rel_str>.

        IF <fs_rel_str>-no LT lv_frgzu_len.

          <fs_rel_str>-is_released      = abap_true.
          <fs_rel_str>-current_approval = abap_false.

        ELSEIF <fs_rel_str>-no EQ lv_frgzu_len.

          <fs_rel_str>-is_released      = abap_false.
          <fs_rel_str>-current_approval = abap_true.
          EXIT.

        ENDIF.

      ENDLOOP.
      UNASSIGN <fs_rel_str>.

    ENDIF.


  ENDIF.



endform.                    " GET_RELEASE_CODE
*&---------------------------------------------------------------------*
*&      Form  INIT_VARS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form INIT_VARS .

  REFRESH: gt_rel_str[], gt_ust12[], p_a1[], gt_auth[], gt_prof[],
           gr_prof[], git_ust042[], userlist[], it_message[], gt_ekpo[],
           gt_eket[], final_user[], final_list[].
  CLEAR:   gt_ust12, it_message, gv_rel_str_completed, gv_po_rejected,
           gv_po_reject_cancelled, gv_got_approvers_zpoemail.

endform.                    " INIT_VARS
*&---------------------------------------------------------------------*
*&      Form  GET_AUTH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form GET_AUTH .

  DATA: lt_range_field    TYPE susr_t_sel_opt_field,
        ls_range_field    LIKE LINE OF lt_range_field.

  FIELD-SYMBOLS: <fs_rel_str>   TYPE ts_rel_str,
                 <fs_p_a1>      TYPE type_auth,
                 <fs_auth>      TYPE ts_auth.

  "Only continue when still got Release Code to approve
  LOOP AT gt_rel_str TRANSPORTING NO FIELDS
                     WHERE current_approval = abap_true .
    EXIT.
  ENDLOOP.

  IF sy-subrc <> 0.
    RETURN.
  ENDIF.


*  Build field range table
  CLEAR ls_range_field.
  ls_range_field-sign   = 'I'.
  ls_range_field-option = 'EQ'.
  ls_range_field-low    = 'FRGGR'.
  APPEND ls_range_field TO lt_range_field.

  CLEAR ls_range_field.
  ls_range_field-sign   = 'I'.
  ls_range_field-option = 'EQ'.
  ls_range_field-low    = 'FRGCO'.
  APPEND ls_range_field TO lt_range_field.

  SELECT * FROM ust12 INTO TABLE gt_ust12           "#EC CI_GENBUFF
         WHERE objct = gc_authobj
           AND field IN lt_range_field
           AND aktps = lc_aktps_a
    ORDER BY objct auth aktps field von.  "UPG retrofit chermaine


  SELECT DISTINCT auth FROM ust12 INTO TABLE p_a1     "#EC CI_GENBUFF
         WHERE objct = gc_authobj                 "#EC CI_BYPASS
           AND aktps = lc_aktps_a
          ORDER BY auth.

  LOOP AT gt_rel_str ASSIGNING <fs_rel_str>.

    LOOP AT p_a1 ASSIGNING <fs_p_a1>.

      READ TABLE gt_ust12 WITH KEY objct = gc_authobj
                                   auth   = <fs_p_a1>-auth
                                   aktps  = lc_aktps_a
                                   field  = gc_fld_rg
                                   von    = <fs_rel_str>-rg
                          TRANSPORTING NO FIELDS
                          BINARY SEARCH.

      IF sy-subrc = 0.

        READ TABLE gt_ust12 WITH KEY objct = gc_authobj
                                     auth   = <fs_p_a1>-auth
                                     aktps  = lc_aktps_a
                                     field  = gc_fld_rc
                                     von    = <fs_rel_str>-rc
                            TRANSPORTING NO FIELDS
                            BINARY SEARCH.

        IF sy-subrc = 0.

          APPEND INITIAL LINE TO gt_auth ASSIGNING <fs_auth>.
          <fs_auth>-no   = <fs_rel_str>-no.
          <fs_auth>-rg   = <fs_rel_str>-rg.
          <fs_auth>-rc   = <fs_rel_str>-rc.
          <fs_auth>-auth = <fs_p_a1>-auth.

          SELECT SINGLE profn FROM ust10s INTO <fs_auth>-profn
           WHERE aktps = lc_aktps_a
             AND objct = gc_authobj
             AND auth  = <fs_p_a1>-auth.

        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDLOOP.



endform.                    " GET_AUTH
*&---------------------------------------------------------------------*
*&      Form  GET_PROFS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form GET_PROFS .

  DATA:          ls_auth    TYPE ts_auth,
                 lt_prof    TYPE tt_prof,
                 ls_prof    TYPE ts_prof,
                 ls_prof_parent    TYPE ts_prof,
                 lt_return  TYPE tt_profs,
                 ls_return  TYPE ts_profs,
                 lr_prof    LIKE LINE OF gr_prof.

  FIELD-SYMBOLS: <fs_prof>    TYPE ts_prof.

  CHECK NOT gt_auth[] IS INITIAL.

  LOOP AT gt_auth INTO ls_auth.

    APPEND INITIAL LINE TO gt_prof ASSIGNING <fs_prof>.
    MOVE-CORRESPONDING ls_auth TO <fs_prof>.

  ENDLOOP.

  DELETE ADJACENT DUPLICATES FROM gt_prof COMPARING ALL FIELDS.


*  Start getting parent Profiles

  LOOP AT gt_prof INTO ls_prof.

    APPEND ls_prof TO lt_prof.

    MOVE-CORRESPONDING ls_prof TO ls_prof_parent.

    CLEAR: lt_return[].
    PERFORM susi_get_father_profs USING ls_prof_parent-profn
                                        lt_return.

    LOOP AT lt_return INTO ls_return.
      ls_prof_parent-profn = ls_return-profn.
      APPEND ls_prof_parent TO lt_prof.
    ENDLOOP.

  ENDLOOP.


*  Return back all profiles to global table

  gt_prof[] = lt_prof[].

*  Distinct final profiles and set in range table

  CLEAR: lt_return[].

  LOOP AT gt_prof INTO ls_prof.
    ls_return-profn = ls_prof-profn.
    APPEND ls_return TO lt_return.
  ENDLOOP.

  SORT lt_return.
  DELETE ADJACENT DUPLICATES FROM lt_return.

  lr_prof-sign   = 'I'.
  lr_prof-option = 'EQ'.
  LOOP AT lt_return INTO lr_prof-low.
    APPEND lr_prof TO gr_prof.
  ENDLOOP.


endform.                    " GET_PROFS
*&---------------------------------------------------------------------*
*&      Form  SUSI_GET_FATHER_PROFS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_PROF_L_PROFN  text
*      -->P_LT_RETURN  text
*----------------------------------------------------------------------*
form SUSI_GET_FATHER_PROFS  USING value(pv_prof)    TYPE xuprofile
                                  pt_return         TYPE tt_profs.

  DATA:
    lv_index TYPE sytabix,
    ls_prof TYPE ts_profs.

  FIELD-SYMBOLS:
    <fs_prf_lst> TYPE ts_prfs_lst.

  CLEAR: pt_return[].

  READ TABLE gt_prof_lst WITH KEY subprof = pv_prof
                         BINARY SEARCH
                         TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    lv_index = sy-tabix.
    LOOP AT gt_prof_lst ASSIGNING <fs_prf_lst> FROM lv_index.
      IF <fs_prf_lst>-subprof = pv_prof.
        ls_prof-profn = <fs_prf_lst>-profn.
        APPEND ls_prof TO pt_return.
      ELSE.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDIF.

  SORT pt_return.
  DELETE ADJACENT DUPLICATES FROM pt_return.

endform.                    " SUSI_GET_FATHER_PROFS
*&---------------------------------------------------------------------*
*&      Form  READ_USER_WITH_PROF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form READ_USER_WITH_PROF using   value(i_ekko) TYPE ekko.

  DATA: ld_index     LIKE  sy-tabix VALUE 0.

  CHECK NOT gr_prof[] IS INITIAL.

  SELECT bname gltgv gltgb FROM usr02
    INTO CORRESPONDING FIELDS OF TABLE userlist
   WHERE zbvmaster EQ SPACE.                "note 1032451

  DELETE userlist WHERE bname = lc_dot_user.

**BEGIN BL01 12.11.2018
**Sort both tables to correct use deletion error.
  SORT userlist BY bname.
  SORT gt_usr05 BY bname.
**END BL01 12.11.2018

* Filter user based on validity period
  LOOP AT userlist.

    ld_index = sy-tabix.

    "Check user parameter (shouldnt have param ZPOEMAIL = 'X'
    READ TABLE gt_usr05 WITH KEY bname = userlist-bname TRANSPORTING NO FIELDS BINARY SEARCH.
    IF sy-subrc = 0.

      gv_got_approvers_zpoemail = abap_true.      "Set global flag

      "This user doesnt expect to get notification
      DELETE userlist INDEX ld_index.
      CONTINUE.                           "Continue loop to the next item
    ENDIF.

    IF userlist-gltgv IS INITIAL AND    "If there no validity date, means still valid
       userlist-gltgb IS INITIAL.
        CONTINUE.
    ELSEIF userlist-gltgv IS INITIAL.
        userlist-gltgv = '19000101'.
    ELSEIF userlist-gltgb IS INITIAL.
        userlist-gltgb = '29990101'.
    ENDIF.

    IF sy-datum GE userlist-gltgv AND
       sy-datum LE userlist-gltgb.
        "User is valid
    ELSE.
      "User is not valid and exclude from list
      DELETE userlist INDEX ld_index.
    ENDIF.


  ENDLOOP.

* Benutzer anhand Selektionskriterium values1 ermitteln
  PERFORM select_users USING i_ekko.

endform.                    " READ_USER_WITH_PROF
*&---------------------------------------------------------------------*
*&      Form  SELECT_USERS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GR_PROF  text
*----------------------------------------------------------------------*
form SELECT_USERS   using   value(i_ekko) TYPE ekko.

  DATA:          "lit_ust042   TYPE  t_it_userlist,
                 ld_index     LIKE  sy-tabix VALUE 0.

  CHECK NOT gr_prof[] IS INITIAL.

  PERFORM sel_users_to_profs_from_ust04
                          USING  gr_prof[]
                                 userlist[]
                                 i_ekko
                          CHANGING  git_ust042[].

* combine users found from previous selection with current
* selection of profiles:
  LOOP AT userlist.
    ld_index = sy-tabix.
    READ TABLE git_ust042
      TRANSPORTING NO FIELDS
      BINARY SEARCH
      WITH KEY bname = userlist-bname.
    IF sy-subrc NE 0.
      DELETE userlist INDEX ld_index.
    ENDIF.
  ENDLOOP.


endform.                    " SELECT_USERS
*&---------------------------------------------------------------------*
*&      Form  SEL_USERS_TO_PROFS_FROM_UST04
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->p_cprof1_include
*      <-- p_userlist_incl
*----------------------------------------------------------------------*
form SEL_USERS_TO_PROFS_FROM_UST04  USING     p_cprof1_include LIKE gr_prof[]
                                              p_userlist       LIKE userlist[]
                                              value(i_ekko) TYPE ekko
                                    CHANGING  p_userlist_incl    TYPE   t_it_userlist.

* -------------------------- local types -------------------------
  TYPES: BEGIN OF lt_user,
           bname   LIKE usr02-bname,
         END OF lt_user,

         BEGIN OF ts_range_user,
           SIGN      TYPE c,
           OPTION(2) TYPE c,
           LOW       LIKE usr02-bname,
           HIGH      LIKE usr02-bname,
         END OF ts_range_user,
         tt_range_user TYPE STANDARD TABLE OF ts_range_user.

* -------------------------- local constants ---------------------
  CONSTANTS:     lc_dot_prof(12)     TYPE c VALUE '............'.

* -------------------------- local data --------------------------
  DATA:          ld_index            LIKE sy-tabix,
                 lit_usr02           TYPE lt_user OCCURS 0,
                 lr_user             TYPE tt_range_user WITH HEADER LINE,
                 lt_agr_users        TYPE TABLE OF agr_users,
                 ls_agr_prof         TYPE agr_prof,
                 lv_valid_profile    TYPE c.

* -------------------------- local field symbols -----------------
  FIELD-SYMBOLS: <lp_userlist_incl>  TYPE LINE OF t_it_userlist,
                 <fs_agr_users>      LIKE LINE OF lt_agr_users.

* Order userlist in a range
  lr_user-sign   = 'I'.
  lr_user-option = 'EQ'.
  LOOP AT userlist.
    lr_user-low = userlist-bname.
    APPEND lr_user.
  ENDLOOP.


* -- preperations: valid for case 3 to 5 --------------------------
*    Read all existing users from USR02 again to prevent displaying
*    entries of USR04/UST04 for non-existing users:
  SELECT bname FROM usr02
    INTO TABLE lit_usr02
    WHERE      zbvmaster EQ space                      " note 977898
     AND       bname IN lr_user
    ORDER BY   bname.
  DELETE lit_usr02 WHERE bname = lc_dot_user.


  SELECT DISTINCT bname profile
    FROM       ust04
    INTO TABLE p_userlist_incl
    WHERE      bname IN lr_user
      AND      profile IN p_cprof1_include
    ORDER BY   bname profile.

* -- post-processing: valid for case 3 to 5 ----------------------
*    During this step:
*    1.) the indicator entry for usr04-ust04-synchronization
*       'lc_dot_user' with 'lc_dot_prof' will be found and deleted
*                               AND
*    2.) we prevents to display entries of USR04/UST04 for
*        non-existing users:
  LOOP AT p_userlist_incl ASSIGNING <lp_userlist_incl>.
    ld_index = sy-tabix.

    READ TABLE lit_usr02
      WITH KEY bname = <lp_userlist_incl>-bname
      TRANSPORTING NO FIELDS
      BINARY SEARCH.

    IF sy-subrc NE 0.
      DELETE p_userlist_incl INDEX ld_index.
    ENDIF.
  ENDLOOP.


* Check Roles/Profiles validity period
  LOOP AT p_userlist_incl ASSIGNING <lp_userlist_incl>.

    ld_index = sy-tabix.
    lv_valid_profile = abap_false.

    SELECT * FROM agr_users INTO TABLE lt_agr_users
     WHERE uname = <lp_userlist_incl>-bname
       AND from_dat LE sy-datum
       AND to_dat   GE sy-datum.

    IF sy-subrc = 0.

      LOOP AT lt_agr_users ASSIGNING <fs_agr_users>.

        SELECT SINGLE * FROM agr_prof INTO ls_agr_prof
         WHERE agr_name = <fs_agr_users>-agr_name
*           AND langu    = sy-langu                         "Allow multiple languages usage of Role
           AND profile  = <lp_userlist_incl>-profile .

          IF sy-subrc = 0.
            lv_valid_profile = abap_true.
            EXIT.
          ENDIF.

      ENDLOOP.

    ENDIF.

*   Delete profile if it is not valid
    IF lv_valid_profile = abap_false.
      DELETE p_userlist_incl INDEX ld_index.
    ENDIF.

  ENDLOOP.

endform.                    " SEL_USERS_TO_PROFS_FROM_UST04
*&---------------------------------------------------------------------*
*&      Form  VALIDATE_OBJ_PLANT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form VALIDATE_OBJ_PLANT TABLES xexpo TYPE tt_ekpo.

  CONSTANTS: obj                TYPE XUOBJECT VALUE 'M_BEST_WRK'.

  FIELD-SYMBOLS: <fs_xexpo>     LIKE LINE OF xexpo.
  DATA: lv_valid_plant          TYPE c,
        lv_werks                LIKE UST12-VON,   "TYPE EWERK,
        obj1                    TYPE usr12-objct,
        it_us335                TYPE STANDARD TABLE OF us335 WITH HEADER LINE,
        ls_final_user           TYPE t_userlist,
        ld_index                LIKE sy-tabix.

  RANGES: r_werks FOR xexpo-werks.

  final_user[] = git_ust042[].

  LOOP AT final_user INTO ls_final_user.

    ld_index = sy-tabix.

*   Set initial valid as false
    lv_valid_plant = abap_false.

    REFRESH: it_us335[], r_werks[].
    CLEAR:   it_us335,   r_werks.

*   Get authorization value of object M_BEST_WRK --> Plant
    CALL FUNCTION 'GET_AUTH_VALUES'
      EXPORTING
        object1           = obj
        user              = ls_final_user-bname
      TABLES
        values            = it_us335
      EXCEPTIONS
        user_doesnt_exist = 1
        OTHERS            = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    LOOP AT it_us335 WHERE field = 'WERKS'.
      r_werks-low = it_us335-lowval.
      r_werks-sign = 'I'.
      r_werks-option = 'EQ'.
      APPEND r_werks.
      CLEAR r_werks.
    ENDLOOP.


    LOOP AT xexpo ASSIGNING <fs_xexpo> WHERE werks IN r_werks.

      CLEAR: lv_werks.
      lv_werks = <fs_xexpo>-werks.

      CALL FUNCTION 'AUTHORITY_CHECK'
        EXPORTING
*         NEW_BUFFERING             = 3
         USER                      = ls_final_user-bname
         object                    = obj
         FIELD1                    = 'ACTVT'
         VALUE1                    = '02'
         FIELD2                    = 'WERKS'
         VALUE2                    = lv_werks
       EXCEPTIONS
         USER_DONT_EXIST           = 1
         USER_IS_AUTHORIZED        = 2
         USER_NOT_AUTHORIZED       = 3
         USER_IS_LOCKED            = 4
         OTHERS                    = 5
                .
      IF sy-subrc = 2.
        lv_valid_plant = abap_true.
        EXIT.
      ENDIF.

    ENDLOOP.

    IF lv_valid_plant = abap_false.
      DELETE final_user INDEX ld_index.
    ENDIF.

  ENDLOOP.

endform.                    " VALIDATE_OBJ_PLANT
*&---------------------------------------------------------------------*
*&      Form  GET_EMAIL_ADDRESS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form GET_EMAIL_ADDRESS .

  DATA: ls_usr21 TYPE usr21,
        lv_index TYPE sytabix.

  CHECK NOT userlist[] IS INITIAL.


  LOOP AT userlist.

     lv_index = sy-tabix.

     CLEAR: ls_usr21.

     SELECT SINGLE * FROM usr21 INTO ls_usr21
      WHERE bname = userlist-bname.

     IF sy-subrc = 0.

       SELECT SINGLE smtp_addr FROM adr6 INTO userlist-smtp_addr
        WHERE addrnumber = ls_usr21-addrnumber
          AND persnumber = ls_usr21-persnumber.

       IF sy-subrc = 0 .
         MODIFY userlist INDEX lv_index.
       ENDIF.

*      Complement with first name and last name, get from the last record
       SELECT name_first name_last FROM adrp
         INTO (userlist-name_first, userlist-name_last)
        WHERE persnumber = ls_usr21-persnumber.

       ENDSELECT.

       IF userlist-name_first IS NOT INITIAL OR
          userlist-name_last  IS NOT INITIAL.

            MODIFY userlist INDEX lv_index.
       ENDIF.

     ENDIF.

  ENDLOOP.

endform.                    " GET_EMAIL_ADDRESS
*&---------------------------------------------------------------------*
*&      Form  GENERATE_EMAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_XEXPO  text
*      -->P_I_EKKO  text
*----------------------------------------------------------------------*
form GENERATE_EMAIL  TABLES xexpo TYPE tt_ekpo
                            xeket TYPE tt_eket
                     using   value(i_ekko) TYPE ekko
                             value(i_ekko_old) TYPE ekko.

  DATA: ls_rel_str TYPE ts_rel_str,
        ls_prof             TYPE ts_prof,
        ls_final_user          TYPE t_userlist.

  "Only process the release strategy when PO has status not rejected
  IF i_ekko-procstat EQ '08'.     "  08 --> PO Rejected
    gv_po_rejected = abap_true.
  ELSE.

*   Check PO Reject cancellation
    IF i_ekko_old-procstat EQ '08' AND i_ekko-procstat EQ '03'.
      gv_po_reject_cancelled = abap_true.
    ENDIF.

    READ TABLE gt_rel_str INTO ls_rel_str WITH KEY current_approval = abap_true.

  ENDIF.


*  "Only continue when still got Release Code to approve
*  LOOP AT gt_rel_str INTO ls_rel_str WHERE current_approval = abap_true .
*    EXIT.
*  ENDLOOP.
*  IF sy-subrc <> 0.
*    RETURN.
*  ENDIF.

* Check whether there is userlist and email address to which email will be sent to
  DATA: lv_got_userlist  TYPE c,
        lv_got_emailaddr TYPE c.

  LOOP AT gt_prof INTO ls_prof WHERE no = ls_rel_str-NO
                                 AND rg = ls_rel_str-RG
                                 AND rc = ls_rel_str-RC.

    LOOP AT final_user INTO ls_final_user WHERE profile = ls_prof-profn.

      IF NOT ls_final_user-bname IS INITIAL.
        lv_got_userlist = abap_true.
      ENDIF.

      LOOP AT userlist WHERE bname = ls_final_user-bname.

        IF NOT userlist-SMTP_ADDR IS INITIAL.
          lv_got_emailaddr = abap_true.
        ENDIF.

        APPEND userlist TO final_list[].

      ENDLOOP.

    ENDLOOP.

  ENDLOOP.

* Prevent to send more than one emails to the same receiver addresses
  SORT final_list BY SMTP_ADDR ASCENDING.
  DELETE ADJACENT DUPLICATES FROM final_list COMPARING SMTP_ADDR.

*  IF NOT userlist[] IS INITIAL.
*    lv_got_userlist = abap_true.
*  ENDIF.
*
*
** Run email program only if there is at least one address to which will be send to
*  LOOP AT userlist WHERE NOT SMTP_ADDR IS INITIAL.
*    lv_got_emailaddr = abap_true.
*    EXIT.
*  ENDLOOP.

*  IF sy-subrc <> 0.
*    EXIT.
*  ENDIF.


  PERFORM populate_email_message_body TABLES xexpo
                                             xeket
                                      USING i_ekko
                                            lv_got_userlist
                                            lv_got_emailaddr.
  PERFORM send_email TABLES xexpo
                     USING i_ekko
                           lv_got_userlist
                           lv_got_emailaddr.
  PERFORM initiate_mail_execute_program USING lv_got_emailaddr.



endform.                    " GENERATE_EMAIL
*&---------------------------------------------------------------------*
*&      Form  POPULATE_EMAIL_MESSAGE_BODY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form POPULATE_EMAIL_MESSAGE_BODY  TABLES xexpo            TYPE tt_ekpo
                                         xeket            TYPE tt_eket
                                  using   value(i_ekko)   TYPE ekko
                                          p_got_userlist  TYPE c
                                          p_got_emailaddr TYPE c.

  FIELD-SYMBOLS: <fs_xexpo> LIKE LINE OF xexpo.
  DATA: lv_netwr            TYPE bwert,
        lv_netwrc(13)       TYPE c,
        ls_rel_str          TYPE ts_rel_str,
        lv_creator_name(50),
        text_string         TYPE string,
        ls_xexpo            LIKE LINE OF xexpo,
        ls_xeket            LIKE LINE OF XEKET,
        ls_prof             TYPE ts_prof,
        lit_ust042          TYPE t_userlist,
        counterC(5).
*Begin of changes P30K909314
DATA:lt_cdpos TYPE TABLE OF cdpos,
     lt_cdhdr TYPE TABLE OF cdhdr,
     ls_cdhdr TYPE cdhdr,
     ls_v_usr_name TYPE v_usr_name.
*End of changes P30K909314
  CONSTANTS: val1 TYPE string VALUE '$val1',
             val2 TYPE string VALUE '$val2'.

  READ TABLE gt_rel_str INTO ls_rel_str WITH KEY current_approval = abap_true.

  REFRESH it_message.
  CLEAR it_message.

  IF NOT gv_po_rejected IS INITIAL.                             "PO rejected

    it_message = ' '.
    APPEND it_message.

    CONCATENATE 'This PO has been rejected by' sy-uname INTO it_message SEPARATED BY space.
    APPEND it_message.

    it_message = '==============================================================='.
    APPEND it_message.

    it_message = ' '.
    APPEND it_message.

  ELSEIF NOT gv_po_reject_cancelled IS INITIAL.                  "PO Rejection is cancelled

    it_message = ' '.
    APPEND it_message.

    it_message =  'This PO rejection has been cancelled and now needs your approval'.
    APPEND it_message.

    it_message = '==============================================================='.
    APPEND it_message.

    it_message = ' '.
    APPEND it_message.

  ELSEIF NOT gv_rel_str_completed IS INITIAL.                   "Release Strategy completed

    it_message = ' '.
    APPEND it_message.

    it_message = 'This PO has got approved by all respective approvers'.
    APPEND it_message.

    it_message = '==============================================================='.
    APPEND it_message.

    it_message = ' '.
    APPEND it_message.

  ELSEIF p_got_userlist IS INITIAL .

    it_message = ' '.
    APPEND it_message.

    it_message = 'This Notification was supposed to be sent to approver(s) in:'.
    APPEND it_message.

    CONCATENATE 'Release Group :' ls_rel_str-rg_desc '(' ls_rel_str-rg ')' INTO it_message SEPARATED BY SPACE.
    APPEND it_message.

    CONCATENATE 'Release Code :' ls_rel_str-rc_desc '(' ls_rel_str-rc ')' INTO it_message SEPARATED BY SPACE.
    APPEND it_message.

    it_message = ' '.
    APPEND it_message.

    it_message = 'But there is no approver(s) assigned to above Release Group and Release Code.'.
    APPEND it_message.

    it_message = ' '.
    APPEND it_message.

    it_message = 'Please contact SAP Administrator!'.
    APPEND it_message.

    it_message = '==============================================================='.
    APPEND it_message.

    it_message = ' '.
    APPEND it_message.

  ELSEIF p_got_emailaddr IS INITIAL .

    it_message = ' '.
    APPEND it_message.

    it_message = 'This Notification was supposed to be sent to below User ID(s):'.
    APPEND it_message.

    LOOP AT gt_prof INTO ls_prof WHERE no = ls_rel_str-NO
                                   AND rg = ls_rel_str-RG
                                   AND rc = ls_rel_str-RC.

      CLEAR it_message.

      LOOP AT git_ust042 INTO lit_ust042 WHERE profile = ls_prof-profn.

        LOOP AT userlist WHERE bname = lit_ust042-bname.

         CONCATENATE '(' userlist-name_last ',' userlist-name_first ')' INTO it_message.
         CONCATENATE userlist-bname it_message INTO it_message SEPARATED BY SPACE.
         APPEND it_message.

        ENDLOOP.

      ENDLOOP.

    ENDLOOP.

    it_message = ' '.
    APPEND it_message.

    it_message = 'But there is no email address tagged to above list of User ID.'.
    APPEND it_message.

    it_message = ' '.
    APPEND it_message.

    it_message = 'Please contact SAP Administrator!'.
    APPEND it_message.

    it_message = '==============================================================='.
    APPEND it_message.

    it_message = ' '.
    APPEND it_message.

  ENDIF.

  it_message = text-001.         "The following purchase order (PO) requires your immediate approval.
  APPEND it_message.

  it_message = ' '.
  APPEND it_message.



  "PO Plant
  "Get Plant name
  DATA: plant_name TYPE T001W-NAME1.
  LOOP AT xexpo INTO ls_xexpo WHERE NOT werks IS INITIAL.
    SELECT SINGLE name1 FROM t001w INTO  plant_name
     WHERE werks = ls_xexpo-werks.
    EXIT.
  ENDLOOP.

  CLEAR text_string.
  text_string = text-002.
  REPLACE ALL OCCURRENCES OF '#' IN text_string WITH cl_abap_char_utilities=>horizontal_tab.
  CONDENSE plant_name.
  REPLACE val1 WITH plant_name     INTO text_string.
  REPLACE val2 WITH ls_xexpo-werks INTO text_string.

  it_message = text_string.      "PO Plant: <Plant Name> (<Plant Code>)
  APPEND it_message.



  "PO Purchasing Group
  "Get Purchasing Group name
  DATA: purgroup_name TYPE T024-EKNAM.
  SELECT SINGLE eknam FROM t024 INTO purgroup_name
   WHERE ekgrp = i_ekko-ekgrp.

  CLEAR text_string.
  text_string = text-003.
  REPLACE ALL OCCURRENCES OF '#' IN text_string WITH cl_abap_char_utilities=>horizontal_tab.
  CONDENSE purgroup_name.
  REPLACE val1 WITH purgroup_name INTO text_string.
  REPLACE val2 WITH i_ekko-ekgrp  INTO text_string.

  it_message = text_string.      "PO Purchasing Group: <PGp Name> (<PGp Code>)
  APPEND it_message.



  "PO Number
  CLEAR text_string.
  text_string = text-004.
  REPLACE ALL OCCURRENCES OF '#' IN text_string WITH cl_abap_char_utilities=>horizontal_tab.
  REPLACE val1 WITH i_ekko-ebeln INTO text_string.

  it_message = text_string.         "PO Number:
  APPEND it_message.



  "PO Value
  "Get PO Value
  LOOP AT xexpo ASSIGNING <fs_xexpo> WHERE loekz IS INITIAL.
    lv_netwr = lv_netwr + <fs_xexpo>-netwr.
  ENDLOOP.

  WRITE lv_netwr TO lv_netwrc.
  CONDENSE lv_netwrc.
  CLEAR text_string.
  text_string = text-005.
  REPLACE ALL OCCURRENCES OF '#' IN text_string WITH cl_abap_char_utilities=>horizontal_tab.
  REPLACE val1 WITH i_ekko-waers INTO text_string.
  REPLACE val2 WITH lv_netwrc    INTO text_string.

  it_message = text_string.      "PO Value: <Currency Code> <Value>
  APPEND it_message.



  "PO Vendor
  "Get Vendor Name
  DATA: vendor_name TYPE LFA1-NAME1.
  SELECT SINGLE name1 FROM lfa1 INTO vendor_name
   WHERE lifnr = i_ekko-lifnr.

  CLEAR text_string.
  text_string = text-006.
  REPLACE ALL OCCURRENCES OF '#' IN text_string WITH cl_abap_char_utilities=>horizontal_tab.
  CONDENSE vendor_name.
  REPLACE val1 WITH vendor_name  INTO text_string.
  REPLACE val2 WITH i_ekko-lifnr INTO text_string.

  it_message = text_string.         "PO Vendor: <Vendor Name> (<Vendor Code>)
  APPEND it_message.



  "PO Creation Date
  DATA: creation_date(10).
  CLEAR text_string.
  text_string = text-007.
  REPLACE ALL OCCURRENCES OF '#' IN text_string WITH cl_abap_char_utilities=>horizontal_tab.
  WRITE i_ekko-bedat TO creation_date dd/mm/yyyy.
  REPLACE val1 WITH creation_date  INTO text_string.

  it_message = text_string.         "PO Creation Date: <DD/MM/YYYY>
  APPEND it_message.



  "PO Delivery Date
  "Get PO Delivery Date
  DATA: delivery_date(10).
  LOOP AT xeket INTO ls_xeket WHERE NOT eindt IS INITIAL.
    EXIT.
  ENDLOOP.

  CLEAR text_string.
  text_string = text-008.
  REPLACE ALL OCCURRENCES OF '#' IN text_string WITH cl_abap_char_utilities=>horizontal_tab.
  WRITE ls_xeket-eindt TO delivery_date DD/MM/YYYY.
  REPLACE val1 WITH delivery_date INTO text_string.

  it_message = text_string.         "PO Delivery Date: <DD/MM/YYYY>
  APPEND it_message.



  "PO Requester
  CLEAR text_string.
  text_string = text-009.
  REPLACE ALL OCCURRENCES OF '#' IN text_string WITH cl_abap_char_utilities=>horizontal_tab.
  REPLACE val1 WITH i_ekko-ernam INTO text_string.

  it_message = text_string.         "PO Requester:
  APPEND it_message.



  "Level Pending Release
  "Get Current Release Code
  READ TABLE gt_rel_str INTO ls_rel_str WITH KEY current_approval = abap_true.

  IF sy-subrc = 0.

    CLEAR text_string.
    text_string = text-010.
    REPLACE ALL OCCURRENCES OF '#' IN text_string WITH cl_abap_char_utilities=>horizontal_tab.
    CONDENSE ls_rel_str-rc_desc.
    REPLACE val1 WITH ls_rel_str-rc_desc INTO text_string.
    REPLACE val2 WITH ls_rel_str-rc      INTO text_string.

    it_message = text_string.         "Level Pending Release: <Release Code Description> (<Release Code>)
    APPEND it_message.

  ENDIF.

  it_message = ' '.
  APPEND it_message.
  APPEND it_message.



* Print PO Release Level----------------
  CHECK NOT gt_rel_str[] IS INITIAL.

  it_message = 'PO Release Levels:'.
  APPEND it_message.

  LOOP AT gt_rel_str INTO ls_rel_str .

    CLEAR :text_string.

    WRITE ls_rel_str-NO TO counterC.
    CONDENSE counterC.
    CONCATENATE counterC '.' INTO text_string.

    CONCATENATE text_string ls_rel_str-rc_desc    INTO text_string SEPARATED BY space.
    CONCATENATE text_string '('                   INTO text_string SEPARATED BY space.
    CONCATENATE text_string ls_rel_str-rc ')'     INTO text_string.


    IF ls_rel_str-is_released IS INITIAL.
      CONCATENATE text_string '-> Pending Release' cl_abap_char_utilities=>newline  INTO text_string SEPARATED BY space.
    ELSE.
      CONCATENATE text_string '-> Released'        cl_abap_char_utilities=>cr_lf  INTO text_string SEPARATED BY space.
    ENDIF.

* This part is definetely not needed since the appover User ID not need to be shown
*    LOOP AT gt_prof INTO ls_prof WHERE no = ls_rel_str-NO
*                                   AND rg = ls_rel_str-RG
*                                   AND rc = ls_rel_str-RC.
*
*      LOOP AT git_ust042 INTO lit_ust042 WHERE profile = ls_prof-profn.
*
*        LOOP AT userlist WHERE bname = lit_ust042-bname.
*
*          IF NOT username IS INITIAL.
*            CONCATENATE username ',' INTO username.
*            CONCATENATE username userlist-name_last userlist-name_first INTO username SEPARATED BY space.
*          ELSE.
*            CONCATENATE userlist-name_last userlist-name_first INTO username SEPARATED BY space.
*          ENDIF.
*
*        ENDLOOP.
*
*      ENDLOOP.
*
*    ENDLOOP.
*
*    IF NOT username IS INITIAL.
*      CONCATENATE '(' username ')' INTO username.
*    ENDIF.
*
*
*    CONCATENATE text_string username INTO text_string SEPARATED BY space.

    it_message = text_string.         "PO Release Level
    APPEND it_message.

  ENDLOOP.



  it_message = ' '.
  APPEND it_message.
  APPEND it_message.

*Begin of changes P30K909314
SELECT * FROM cdpos
  INTO TABLE lt_cdpos
  WHERE objectclas EQ 'EINKBELEG'
  AND objectid EQ i_ekko-ebeln
  AND   tabname EQ 'EKKO'
  AND   fname EQ 'FRGZU'
  AND   value_new EQ 'X'.
  IF sy-subrc IS INITIAL.
   SELECT * FROM cdhdr
     INTO TABLE lt_cdhdr
     FOR ALL ENTRIES IN lt_cdpos
     WHERE objectclas EQ 'EINKBELEG'
     AND   objectid EQ i_ekko-ebeln
     AND   changenr EQ lt_cdpos-changenr.
     IF sy-subrc IS INITIAL.
       SORT lt_cdhdr BY udate utime DESCENDING.
       READ TABLE lt_cdhdr INTO ls_cdhdr INDEX 1.
       IF sy-subrc IS INITIAL.
          SELECT SINGLE * INTO ls_v_usr_name
            FROM v_usr_name
            WHERE  bname = ls_cdhdr-username.
            IF sy-subrc IS INITIAL.
*-begin of remove last action Feb 28 2018
*              CONCATENATE 'Last Action By:' ls_v_usr_name-name_text INTO it_message SEPARATED BY space.
*              APPEND it_message.
            ENDIF.
*-end of remove last action Feb 28 2018
       ENDIF.
     ENDIF.
  ENDIF.
*End of changes P30K909314

  CLEAR text_string.
  text_string = text-031.
  it_message = text_string.         "To approve, please login to your SAP system.
  APPEND it_message.

*  it_message = ' '.
*  APPEND it_message.
*
*  CLEAR text_string.
*  text_string = text-032.
*  it_message = text_string.         "This is an automated email.
*  APPEND it_message.

  it_message = ' '.
  it_message = ' '.
  APPEND it_message.


endform.                    " POPULATE_EMAIL_MESSAGE_BODY
*&---------------------------------------------------------------------*
*&      Form  SEND_EMAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form SEND_EMAIL TABLES  xexpo           TYPE tt_ekpo
                using   value(i_ekko)   TYPE ekko
                        p_got_userlist  TYPE c
                        p_got_emailaddr TYPE c.

  DATA: ld_error          TYPE sy-subrc,
         ld_reciever       TYPE sy-subrc,
         ld_mtitle         LIKE sodocchgi1-obj_descr,
*         ld_email          LIKE somlreci1-receiver,
         ld_format         TYPE so_obj_tp ,
         ld_attdescription TYPE so_obj_nam ,
         ld_attfilename    TYPE so_obj_des ,
         ld_sender_address LIKE soextreci1-receiver,
         ld_sender_address_type LIKE soextreci1-adr_typ,
         ld_receiver       LIKE sy-subrc,
         w_cnt TYPE i,
         w_sent_all(1)   TYPE c,
         ls_usr21        TYPE usr21.

  DATA: ls_xexpo LIKE LINE OF xexpo,
        lv_netwr            TYPE bwert,
        lv_netwrc(13)       TYPE c,
        ls_rel_str          TYPE ts_rel_str,
        ls_prof             TYPE ts_prof,
        lit_ust042          TYPE t_userlist.

  FIELD-SYMBOLS: <fs_xexpo> LIKE LINE OF xexpo.

*  IF p_user IS INITIAL.
*    p_user = sy-uname.
*  ENDIF.

*  ld_email               = p_user.

  IF NOT gv_po_rejected IS INITIAL.

    CONCATENATE 'SAP PO Approval:' i_ekko-ebeln 'HAS BEEN REJECTED!!' INTO ld_mtitle SEPARATED BY SPACE.

  ELSEIF NOT gv_po_reject_cancelled IS INITIAL.

    CONCATENATE 'SAP PO Approval:' i_ekko-ebeln 'REJECTION HAS BEEN CANCELLED!!' INTO ld_mtitle SEPARATED BY SPACE.

  ELSEIF NOT gv_rel_str_completed IS INITIAL.

    CONCATENATE 'SAP PO Approval:' i_ekko-ebeln 'HAS BEEN APPROVED!!' INTO ld_mtitle SEPARATED BY SPACE.

  ELSEIF p_got_emailaddr IS INITIAL.

     CONCATENATE 'SAP PO Approval:' i_ekko-ebeln 'NO VALID USER NOTIFIED!!' INTO ld_mtitle SEPARATED BY SPACE.

  ELSE.
*     CONCATENATE 'PO No:' i_ekko-ebeln 'is awaiting your approval' INTO ld_mtitle SEPARATED BY SPACE.

      "PO Plant
      LOOP AT xexpo INTO ls_xexpo WHERE NOT werks IS INITIAL.
        EXIT.
      ENDLOOP.

      CONDENSE ls_xexpo-werks.
      CONCATENATE 'SAP PO Approval:' ls_xexpo-werks INTO ld_mtitle SEPARATED BY space.

      "PO Number
      CONCATENATE ld_mtitle i_ekko-ebeln INTO ld_mtitle SEPARATED BY space.


      "PO Value
      "Get PO Value
      LOOP AT xexpo ASSIGNING <fs_xexpo> WHERE loekz IS INITIAL.
        lv_netwr = lv_netwr + <fs_xexpo>-netwr.
      ENDLOOP.

      WRITE lv_netwr TO lv_netwrc.
      CONDENSE lv_netwrc.

      CONCATENATE ld_mtitle i_ekko-waers  lv_netwrc INTO ld_mtitle SEPARATED BY space.

  ENDIF.

*  ld_format              = 'CSV'.
*  ld_attdescription      = 'HIS Recon'.
*  LD_ATTFILENAME         = P_FILENAME.
*Begin of changes P30K909314
*  ld_sender_address      = sy-uname.
*  ld_sender_address_type = 'B'.
  ld_sender_address      = 'donotreply@uol.com.sg'.
  ld_sender_address_type = 'INT'.
*End of chnages P30K909314
* Fill the document data.
  w_doc_data-doc_size = 1.

* Populate the subject/generic message attributes
  w_doc_data-obj_langu  = sy-langu.
  w_doc_data-obj_name   = 'SAPRPT'.
  w_doc_data-obj_descr  = ld_mtitle .
  w_doc_data-sensitivty = 'F'.

** Fill the document data and get size of attachment
*  CLEAR w_doc_data.
*  READ TABLE it_attach INDEX w_cnt.
*  w_doc_data-doc_size   = ( w_cnt - 1 ) * 255 + STRLEN( it_attach-line ).
*  w_doc_data-obj_langu  = sy-langu.
*  w_doc_data-obj_name   = 'SAPRPT'.
*  w_doc_data-obj_descr  = ld_mtitle.
*  w_doc_data-sensitivty = 'F'.

* Describe the body of the message
  CLEAR t_packing_list.
  REFRESH t_packing_list.
  t_packing_list-transf_bin = space.
  t_packing_list-head_start = 1.
  t_packing_list-head_num = 0.
  t_packing_list-body_start = 1.
  DESCRIBE TABLE it_message LINES t_packing_list-body_num.
  t_packing_list-doc_type = 'RAW'.
  APPEND t_packing_list.

** Create attachment notification
*  t_packing_list-transf_bin = 'X'.
*  t_packing_list-head_start = 1.
*  t_packing_list-head_num = 1.
*  t_packing_list-body_start = 1.
*
*  DESCRIBE TABLE it_attach LINES t_packing_list-body_num.
*  t_packing_list-doc_type  = ld_format.
*  t_packing_list-obj_descr = ld_attdescription.
*  t_packing_list-obj_name  = ld_attfilename.
*  t_packing_list-doc_size  = t_packing_list-body_num * 255.
*  APPEND t_packing_list.


*  If there is not userlist, send email to the PO creator.
  IF p_got_userlist IS INITIAL OR
     p_got_emailaddr IS INITIAL.

    CLEAR: userlist.
    userlist-bname = i_ekko-ernam.

    "If no approvers email will be sent to because of ZPOEMAIL parameter,
    "no email will be sent to purchaser either
    IF NOT gv_got_approvers_zpoemail IS INITIAL.
      RETURN.
    ENDIF.

    "Check user list parameter ZPOEMAIL = 'X'
    READ TABLE gt_usr05 WITH KEY bname = userlist-bname TRANSPORTING NO FIELDS BINARY SEARCH.
    IF sy-subrc = 0.
      "Cancel email notification
      RETURN.
    ENDIF.

    SELECT SINGLE * FROM usr21 INTO ls_usr21
     WHERE bname = userlist-bname.

    IF sy-subrc = 0.

      SELECT SINGLE smtp_addr FROM adr6 INTO userlist-smtp_addr
       WHERE addrnumber = ls_usr21-addrnumber
         AND persnumber = ls_usr21-persnumber.

      IF sy-subrc = 0 .
        APPEND userlist TO final_list.
      ENDIF.
    ENDIF.

  ENDIF.


  REFRESH t_receivers.

  LOOP AT final_list WHERE NOT smtp_addr IS INITIAL.

*   Add the recipients email address
    CLEAR t_receivers.
*    t_receivers-receiver   = 'ZTEST'.  "wa_zbcgb_intfmast-distlistf.
    t_receivers-receiver   = final_list-smtp_addr.
    t_receivers-rec_type   = 'U'.
*    t_receivers-rec_type   = 'C'.
*    t_receivers-com_type   = 'INT'.
    t_receivers-notif_del  = 'X'.
    t_receivers-notif_ndel = 'X'.
    APPEND t_receivers.

*   Set variable email address flag
    p_got_emailaddr = abap_true.
  ENDLOOP.

  IF sy-subrc NE 0.       "No need to call below function if there is no email address to send to
    p_got_emailaddr = abap_false.
    EXIT.
  ENDIF.



  CALL FUNCTION 'SO_DOCUMENT_SEND_API1'
    EXPORTING
      document_data              = w_doc_data
      put_in_outbox              = 'X'
      sender_address             = ld_sender_address
      sender_address_type        = ld_sender_address_type
      commit_work                = 'X'
    IMPORTING
      sent_to_all                = w_sent_all
    TABLES
      packing_list               = t_packing_list
*      contents_bin               = it_attach
      contents_txt               = it_message
      receivers                  = t_receivers
    EXCEPTIONS
      too_many_receivers         = 1
      document_not_sent          = 2
      document_type_not_exist    = 3
      operation_no_authorization = 4
      parameter_error            = 5
      x_error                    = 6
      enqueue_error              = 7
      OTHERS                     = 8.


endform.                    " SEND_EMAIL
*&---------------------------------------------------------------------*
*&      Form  INITIATE_MAIL_EXECUTE_PROGRAM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form INITIATE_MAIL_EXECUTE_PROGRAM  USING p_got_emailaddr TYPE c.

  CHECK NOT p_got_emailaddr IS INITIAL.

  WAIT UP TO 2 SECONDS.
  SUBMIT RSCONN01 WITH MODE = 'INT'
  WITH OUTPUT = ''
  AND RETURN.
endform.                    " INITIATE_MAIL_EXECUTE_PROGRAM
*&---------------------------------------------------------------------*
*&      Form  GET_CREATOR_NAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_EKKO_ERNAM  text
*      -->P_LV_CREATOR_NAME  text
*----------------------------------------------------------------------*
form GET_CREATOR_NAME  using    value(p_ernam) TYPE ekko-ernam
                                p_creator      TYPE char50.


  DATA: lv_name_first LIKE adrp-name_first,
        lv_name_last  LIKE adrp-name_last,
        ls_usr21      TYPE usr21.

  SELECT SINGLE * FROM usr21 INTO ls_usr21
   WHERE bname = p_ernam.

  IF sy-subrc = 0.
    SELECT name_first name_last FROM adrp
      INTO (lv_name_first, lv_name_last)
     WHERE persnumber = ls_usr21-persnumber.

    ENDSELECT.
  ENDIF.

  CONCATENATE '(' lv_name_last ', ' lv_name_first ')' INTO p_creator.

endform.                    " GET_CREATOR_NAME
*&---------------------------------------------------------------------*
*&      Form  ARRANGE_XEXPO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_XEXPO  text
*      -->P_I_EKKO  text
*----------------------------------------------------------------------*
form ARRANGE_XEXPO  TABLES xexpo         TYPE tt_ekpo
                    USING  VALUE(i_ekko) TYPE ekko.

  DATA: lt_ekpo TYPE tt_ekpo,
        ls_ekpo LIKE LINE OF xexpo.

  SELECT * FROM ekpo INTO CORRESPONDING FIELDS OF TABLE lt_ekpo
   WHERE ebeln = i_ekko-ebeln.


  LOOP AT xexpo INTO ls_ekpo.

    IF ls_ekpo-kz = 'I'.          "Insert of new items

      READ TABLE lt_ekpo WITH KEY ebelp = ls_ekpo-ebelp TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        APPEND ls_ekpo TO lt_ekpo.
      ENDIF.

    ELSEIF ls_ekpo-kz = 'U'.

      IF NOT ls_ekpo-loekz IS INITIAL.      "Deletion of items

        DELETE lt_ekpo WHERE ebeln = i_ekko-ebeln AND ebelp = ls_ekpo-ebelp.

      ELSEIF ls_ekpo-loekz IS INITIAL.      "Update of items

        DELETE lt_ekpo WHERE ebeln = i_ekko-ebeln AND ebelp = ls_ekpo-ebelp.
        APPEND ls_ekpo TO lt_ekpo.

      ENDIF.

    ENDIF.

  ENDLOOP.

* Copy to global ekpo table
  gt_ekpo[] = lt_ekpo[].

endform.                    " ARRANGE_XEXPO
*&---------------------------------------------------------------------*
*&      Form  ARRANGE_XEKET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_XEKET  text
*      -->P_I_EKKO  text
*----------------------------------------------------------------------*
form ARRANGE_XEKET  TABLES xeket         TYPE tt_eket
                    USING  VALUE(i_ekko) TYPE ekko.

  DATA: lt_eket TYPE tt_eket,
        ls_eket LIKE LINE OF xeket.

  SELECT * FROM eket INTO CORRESPONDING FIELDS OF TABLE lt_eket
   WHERE ebeln = i_ekko-ebeln.


  LOOP AT xeket INTO ls_eket.

    IF ls_eket-kz = 'I'.          "Insert of new items

      READ TABLE lt_eket WITH KEY ebelp = ls_eket-ebelp TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        APPEND ls_eket TO lt_eket.
      ENDIF.

    ELSEIF ls_eket-kz = 'U'.

      DELETE lt_eket WHERE ebeln = ls_eket-ebeln
         AND ebelp = ls_eket-ebelp
         AND etenr = ls_eket-etenr.
      APPEND ls_eket TO lt_eket.

    ENDIF.

  ENDLOOP.

* Copy to global eket table
  gt_eket[] = lt_eket[].

endform.                    " ARRANGE_XEKET
