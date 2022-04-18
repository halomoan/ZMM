FUNCTION ZMM_GOS_EBAN_EKKO.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(GS_OBJECT) TYPE  BORIDENT OPTIONAL
*"     REFERENCE(I_EBELN) TYPE  EBELN
*"     REFERENCE(I_BANFN) TYPE  BANFN
*"----------------------------------------------------------------------

DATA: ls_object           TYPE sibflporb,
      lt_relation         TYPE TABLE OF obl_s_relt,
      lw_relation         LIKE LINE OF lt_relation,
      lt_links            TYPE TABLE OF obl_s_link,
      lw_links            TYPE obl_s_link.
DATA: ls_folder           TYPE SOODK,
      ls_objatt           TYPE SOODK,
      lt_notes            TYPE SOLI OCCURS 0,
      lw_notes            TYPE SOLI.
DATA: is_object_a         TYPE SIBFLPORB,
      is_object_b         TYPE SIBFLPORB.
DATA: ep_link_id          TYPE OBLGUID16,
      eo_property         TYPE REF TO OBJECT.

  ls_object-instid    = I_BANFN. "'1000000530'.
  ls_object-typeid    = 'BUS2105'.
  ls_object-catid     = 'BO'.
  lw_relation-sign    = 'I'.
  lw_relation-option  = 'EQ'.
  lw_relation-low     = 'ATTA'.
  APPEND lw_relation TO lt_relation.

  CALL METHOD cl_binary_relation=>read_links_of_binrels
    EXPORTING
      is_object           = ls_object
      it_relation_options = lt_relation
      ip_role             = 'GOSAPPLOBJ'
    IMPORTING
      et_links            = lt_links.


  SORT lt_links BY UTCTIME DESCENDING.          " read the latest attachment
  LOOP AT lt_links INTO lw_links.
*  READ TABLE lt_links INDEX 1 INTO lw_links.

    is_object_a-INSTID  = I_EBELN.  "'4370000009'.
    is_object_a-TYPEID  = 'BUS2012'.
    is_object_a-CATID   = 'BO'.

    is_object_b-INSTID  = lw_links-INSTID_B.
    is_object_b-TYPEID  = 'MESSAGE'.
    is_object_b-CATID   = 'BO'.

    TRY.
      CALL METHOD cl_binary_relation=>create_link
        EXPORTING
          is_object_a = is_object_a
*          ip_logsys_a = ip_logsys_a
          is_object_b = is_object_b
*          ip_logsys_b = ip_logsys_b
          ip_reltype  = 'ATTA'
*          ip_propnam  =
*          i_property  =
        IMPORTING
            ep_link_id = ep_link_id
            eo_property = eo_property
          .

      CATCH cx_obl_internal_error .
      CATCH cx_obl_model_error .
    ENDTRY.
  ENDLOOP.

  COMMIT WORK.



ENDFUNCTION.
