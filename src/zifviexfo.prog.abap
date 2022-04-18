*&---------------------------------------------------------------------*
*&  Include           IFVIEXFO
*&---------------------------------------------------------------------*
*
* This include contains subprograms needed to enhance RealEstate
* external applications with RE specific select options.
*
**********************************************************************
* FORM    :  re_f4_objart
*
* submodule is called by event 'on value-request for s_obart-low'
* in 'INCLUDE ifviexev'
**********************************************************************
FORM re_f4_objart.

  INCLUDE zrbonrart.
  DATA: lt_allow_obart LIKE TABLE OF tbo01-obart.
  REFRESH lt_allow_obart.

*=================================================================
  INCLUDE zifre_begin_of_re_ea_fin.
*   RE-FX - see function group KOBS, FORM APROF_TO_ALLOWED_KONTYS
  APPEND objektart_ia TO lt_allow_obart.
  APPEND objektart_ib TO lt_allow_obart.
  APPEND objektart_ig TO lt_allow_obart.
  APPEND objektart_is TO lt_allow_obart.
  APPEND objektart_iw TO lt_allow_obart.
  APPEND objektart_i1 TO lt_allow_obart.
  APPEND objektart_im TO lt_allow_obart.
  INCLUDE zifre_end_of_re_ea_fin.
*=================================================================
  INCLUDE zifre_begin_of_re_classic.
  APPEND objektart_ia TO lt_allow_obart.
  APPEND objektart_ib TO lt_allow_obart.
  APPEND objektart_ig TO lt_allow_obart.
  APPEND objektart_is TO lt_allow_obart.
  APPEND objektart_iw TO lt_allow_obart.
  APPEND objektart_iv TO lt_allow_obart.
  APPEND objektart_im TO lt_allow_obart.
  APPEND objektart_ic TO lt_allow_obart.
  INCLUDE zifre_end_of_re_classic.

*=================================================================
  CALL FUNCTION 'HELP_REQUEST_FOR_OBART'
    IMPORTING
      select_value = s_obart-low
    TABLES
      t_only_obart = lt_allow_obart.

ENDFORM.                    "RE_f4_objart

**********************************************************************
* FORM    :  re_get_object_keys
*
*  Define receiving table as follows:
*      gt_imkeys type table of virekey.
*  Call subprogram as follows:
*      perform re_get_object_keys
*        using s_bukrs-low
*              p_stich
*        changing gt_imkeys.
**********************************************************************
FORM re_get_object_keys
  USING i_bukrs TYPE rfviexso-bukrs
        i_dstich TYPE rfviexso-dstchtag
  CHANGING ct_imkeys TYPE table.

  DATA:
    lt_imkeys TYPE TABLE OF virekey.

  CALL FUNCTION 'REMD_GET_IMKEY_FOR_SELECT_OPT'
    EXPORTING
      i_bukrs  = i_bukrs
      i_dstich = i_dstich
    TABLES
      s_swenr  = s_swenr
      s_sgenr  = s_sgenr
      s_sgrnr  = s_sgrnr
      s_smenr  = s_smenr
      s_smive  = s_smive
      s_svwnr  = s_svwnr
      s_snksl  = s_snksl
      s_empsl  = s_sempsl
      s_recnnr = s_recnnr
      s_obart  = s_obart
      s_vonbis = s_vonbis
      e_imkeys = ct_imkeys.

*   this might become necessary:
*   DELETE lt_imkeys WHERE imkey = space.
*   ct_imkeys[] = lt_imkeys[].
ENDFORM.                    "RE_get_object_keys

**********************************************************************
* FORM    :  RE_modif_selection_screen
*
*  Call subprogram at event 'at selection-screen output' as follows:
*      perform re_modif_selection_screen.
**********************************************************************
Form RE_modif_selection_screen.
  INCLUDE zifre_begin_of_re_ea_fin.
  LOOP AT SCREEN.
    IF screen-group1 = 'RCL'
      AND ( screen-name CS 'S_SMIVE'
           or screen-name CS 'S_SVWNR' ).
      screen-active = '0'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
  INCLUDE zifre_end_of_re_ea_fin.
endform.

**********************************************************************
* FORM    :  RE_check_selection
*
* You might call subprogram until you process 'RE_get_object_keys'
* in order to avoid db-selection over all
**********************************************************************
Form RE_check_selection
  CHANGING RE_selection type flag.

  CLEAR RE_selection.
  IF NOT s_swenr[]  IS INITIAL OR
     NOT s_sgenr[]  IS INITIAL OR
     NOT s_sgrnr[]  IS INITIAL OR
     NOT s_smenr[]  IS INITIAL OR
     NOT s_smive[]  IS INITIAL OR
     NOT s_svwnr[]  IS INITIAL OR
     NOT s_snksl[]  IS INITIAL OR
     NOT s_sempsl[] IS INITIAL OR
     NOT s_recnnr[] IS INITIAL OR
     NOT s_obart[]  IS INITIAL OR
     NOT p_dvon     IS INITIAL OR
     NOT p_dbis     IS INITIAL.
    RE_selection = 'X'.
  ENDIF.

endform.
