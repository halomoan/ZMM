class ZCL_ZRECIPECOST_ODATA_DPC_EXT definition
  public
  inheriting from ZCL_ZRECIPECOST_ODATA_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CHANGESET_BEGIN
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CHANGESET_END
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_STREAM
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~EXECUTE_ACTION
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_EXPANDED_ENTITY
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_EXPANDED_ENTITYSET
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_STREAM
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~UPDATE_STREAM
    redefinition .
protected section.

  methods COOKINGUNITSET_CREATE_ENTITY
    redefinition .
  methods COOKINGUNITSET_DELETE_ENTITY
    redefinition .
  methods COOKINGUNITSET_GET_ENTITY
    redefinition .
  methods COOKINGUNITSET_GET_ENTITYSET
    redefinition .
  methods COOKINGUNITSET_UPDATE_ENTITY
    redefinition .
  methods LOCATIONSET_CREATE_ENTITY
    redefinition .
  methods LOCATIONSET_DELETE_ENTITY
    redefinition .
  methods LOCATIONSET_GET_ENTITY
    redefinition .
  methods LOCATIONSET_GET_ENTITYSET
    redefinition .
  methods LOCATIONSET_UPDATE_ENTITY
    redefinition .
  methods MATCOOKINGUNITSE_CREATE_ENTITY
    redefinition .
  methods MATCOOKINGUNITSE_DELETE_ENTITY
    redefinition .
  methods MATCOOKINGUNITSE_GET_ENTITY
    redefinition .
  methods MATCOOKINGUNITSE_GET_ENTITYSET
    redefinition .
  methods MATCOOKINGUNITSE_UPDATE_ENTITY
    redefinition .
  methods PLANTMATERIALSET_GET_ENTITYSET
    redefinition .
  methods PLANTSET_CREATE_ENTITY
    redefinition .
  methods PLANTSET_DELETE_ENTITY
    redefinition .
  methods PLANTSET_GET_ENTITY
    redefinition .
  methods PLANTSET_GET_ENTITYSET
    redefinition .
  methods RECIPEGROUPSET_CREATE_ENTITY
    redefinition .
  methods RECIPEGROUPSET_DELETE_ENTITY
    redefinition .
  methods RECIPEGROUPSET_GET_ENTITY
    redefinition .
  methods RECIPEGROUPSET_GET_ENTITYSET
    redefinition .
  methods RECIPEGROUPSET_UPDATE_ENTITY
    redefinition .
  methods RECIPEINGRDTSET_GET_ENTITYSET
    redefinition .
  methods RECIPEPHOTOSET_GET_ENTITY
    redefinition .
  methods RECIPESET_CREATE_ENTITY
    redefinition .
  methods RECIPESET_DELETE_ENTITY
    redefinition .
  methods RECIPESET_GET_ENTITY
    redefinition .
  methods RECIPESET_GET_ENTITYSET
    redefinition .
  methods RECIPESET_UPDATE_ENTITY
    redefinition .
  methods RECIPEVERSIONSET_GET_ENTITY
    redefinition .
  methods RECIPEVERSIONSET_GET_ENTITYSET
    redefinition .
  methods SIDEGROUPMENUSET_GET_ENTITYSET
    redefinition .
  methods SIDEITEMMENUSET_GET_ENTITYSET
    redefinition .
  methods STATISTICSET_GET_ENTITYSET
    redefinition .
  methods RECIPEHTCSET_GET_ENTITY
    redefinition .
private section.

  methods SUBSTRINGOF_TO_LIKE_STR
    changing
      !IV_FILTER_STRING type STRING .
  methods GET_AUTH_PLANTS
    returning
      value(RESULT) type RANGES_WERKS_TT .
  methods HAS_AUTH_PLANT
    importing
      !PLANT type WERKS_D
    returning
      value(RESULT) type ABAP_BOOL .
ENDCLASS.



CLASS ZCL_ZRECIPECOST_ODATA_DPC_EXT IMPLEMENTATION.


  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CHANGESET_BEGIN.
**try.
*CALL METHOD SUPER->/IWBEP/IF_MGW_APPL_SRV_RUNTIME~CHANGESET_BEGIN
*  EXPORTING
*    IT_OPERATION_INFO =
**  changing
**    cv_defer_mode     =
*    .
**  catch /iwbep/cx_mgw_busi_exception.
**  catch /iwbep/cx_mgw_tech_exception.
**endtry.
  endmethod.


  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CHANGESET_END.
**try.
*CALL METHOD SUPER->/IWBEP/IF_MGW_APPL_SRV_RUNTIME~CHANGESET_END
*    .
**  catch /iwbep/cx_mgw_busi_exception.
**  catch /iwbep/cx_mgw_tech_exception.
**endtry.
  endmethod.


  method /iwbep/if_mgw_appl_srv_runtime~create_deep_entity.

    data: ls_data           type zcl_zrecipecost_odata_mpc_ext=>ts_recipeversion_deep,
          ls_recipeversion  type zrecipeversion,
          ls_recipeingrdt   type zrecipeingrdt,
          ls_ingredient     type zcl_zrecipecost_odata_mpc=>ts_recipeingrdt,
          lv_compare_result type /iwbep/if_mgw_odata_expand=>ty_e_compare_result.

    data: l_versionid type zrecipeversion-versionid.

    constants: lc_ingredients type string value 'Ingredients'.

    lv_compare_result = io_expand->compare_to( lc_ingredients ).

    if lv_compare_result eq /iwbep/if_mgw_odata_expand=>gcs_compare_result-match_equals.
      io_data_provider->read_entry_data( importing es_data = ls_data ).
    endif.

    move-corresponding ls_data to ls_recipeversion.


    if ls_recipeversion-versionid = ''.

      SELECT MAX( versionid ) FROM ZRECIPEVERSION WHERE werks = @ls_recipeversion-werks and recipeid = @ls_recipeversion-recipeid INTO @l_versionid.
      IF sy-subrc ne 0.
        l_versionid = '0000'.
      ENDIF.
      l_versionid = l_versionid + 1.
      ls_recipeversion-versionid = l_versionid .
    else.
      l_versionid = ls_recipeversion-versionid.
    endif.

    modify zrecipeversion from ls_recipeversion.

    delete from zrecipeingrdt where werks = ls_recipeversion-werks and recipeid = ls_recipeversion-recipeid and versionid = l_versionid.

    loop at ls_data-ingredients into ls_ingredient.
      move-corresponding ls_ingredient to ls_recipeingrdt.

*      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*      EXPORTING
*        INPUT  = ls_recipeingrdt-matnr
*      IMPORTING
*        OUTPUT = ls_recipeingrdt-matnr.

      if ls_recipeingrdt-versionid = ''.
        ls_recipeingrdt-versionid = l_versionid.
      endif.
      insert zrecipeingrdt from ls_recipeingrdt.
    endloop.

    ls_data-versionid = l_versionid.

    copy_data_to_ref(
      exporting
        is_data = ls_data
    changing
      cr_data = er_deep_entity
    ).

  endmethod.


  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_STREAM.
 DATA: ls_key_werks                TYPE /iwbep/s_mgw_name_value_pair,
       ls_key_recipeid             TYPE /iwbep/s_mgw_name_value_pair,
       ls_key_versionid            TYPE /iwbep/s_mgw_name_value_pair,
       ls_message                  TYPE scx_t100key,
       ls_photo                    TYPE zrecipeimg,
       ls_htc                      TYPE zrecipehtc.

    CASE iv_entity_name.
      WHEN 'RecipePhoto'.
        READ TABLE it_key_tab WITH KEY name = 'Werks' INTO ls_key_werks.
        READ TABLE it_key_tab WITH KEY name = 'RecipeID' INTO ls_key_recipeid.

        IF NOT ( ls_key_werks IS INITIAL and ls_key_recipeid IS INITIAL  ).
            ls_photo-werks = ls_key_werks-value.
            ls_photo-recipeid = ls_key_recipeid-value.
            ls_photo-mimetype = is_media_resource-mime_type.
            ls_photo-filename = iv_slug.
            ls_photo-content = is_media_resource-value.

            MODIFY zrecipeimg FROM ls_photo.

            recipephotoset_get_entity(
              EXPORTING
                iv_entity_name     = iv_entity_name
                iv_entity_set_name = iv_entity_set_name
                iv_source_name     = iv_source_name
                it_key_tab         = it_key_tab
                it_navigation_path = it_navigation_path
              IMPORTING
                er_entity          = ls_photo ).

            copy_data_to_ref( EXPORTING is_data = ls_photo
                              CHANGING  cr_data = er_entity ).
        ELSE.
          ls_message-msgid = 'SY'.
          ls_message-msgno = '002'.
          ls_message-attr1 = 'Invalid ID detected'.
          RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
            EXPORTING
              textid = ls_message.
        ENDIF.
      WHEN 'RecipeHTC'.
        READ TABLE it_key_tab WITH KEY name = 'Werks' INTO ls_key_werks.
        READ TABLE it_key_tab WITH KEY name = 'RecipeID' INTO ls_key_recipeid.
        IF NOT ( ls_key_werks IS INITIAL and ls_key_recipeid IS INITIAL  ).
            ls_htc-werks = ls_key_werks-value.
            ls_htc-recipeid = ls_key_recipeid-value.
            ls_htc-mimetype = is_media_resource-mime_type.
            ls_htc-filename = iv_slug.
            ls_htc-content = is_media_resource-value.
            ls_htc-ernam = sy-uname.
            ls_htc-aedat = sy-datum.
            ls_htc-aezet = sy-uzeit.
            MODIFY zrecipehtc FROM ls_htc.

            recipehtcset_get_entity(
              EXPORTING
                iv_entity_name     = iv_entity_name
                iv_entity_set_name = iv_entity_set_name
                iv_source_name     = iv_source_name
                it_key_tab         = it_key_tab
                it_navigation_path = it_navigation_path
              IMPORTING
                er_entity          = ls_htc ).

            copy_data_to_ref( EXPORTING is_data = ls_htc
                              CHANGING  cr_data = er_entity ).
        ELSE.
          ls_message-msgid = 'SY'.
          ls_message-msgno = '002'.
          ls_message-attr1 = 'Invalid ID detected'.
          RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
            EXPORTING
              textid = ls_message.
        ENDIF.
    ENDCASE.

  endmethod.


  method /iwbep/if_mgw_appl_srv_runtime~execute_action.
    data: ls_parameter type /iwbep/s_mgw_name_value_pair,
          l_werks      type zrecipe-werks,
          l_recipeid   type zrecipe-recipeid,
          l_recipename type zrecipe-name,
          l_count      type i,
          ls_entity    type zcl_zrecipecost_odata_mpc_ext=>ts_msgreturn.

    if it_parameter is not initial.
      case  iv_action_name.

        when 'Func_RecipeDelete'.

          read table it_parameter into ls_parameter with key name = 'Werks'.
          if sy-subrc = 0.
            l_werks = ls_parameter-value.
          endif.

          read table it_parameter into ls_parameter with key name = 'RecipeID'.
          if sy-subrc = 0.
            l_recipeid = ls_parameter-value.
          endif.

          select count(*) from zrecipeingrdt into l_count where werks = l_werks and recipeid = l_recipeid.

          "BEGIN - ALLOW DELETION
            l_count = 0.
          "END - ALLOW DELETION

          if l_count gt 0.

            select single Name from zrecipe into l_recipename where werks = l_werks and recipeid = l_recipeid.

            ls_entity-id = l_recipeid.
            ls_entity-type = 'E'.
            concatenate 'Cannot delete' l_recipename '. It has active ingredients.' into ls_entity-message separated by space.

          else.
            delete from zrecipe where werks = l_werks and recipeid = l_recipeid.
            delete from zrecipeimg where werks = l_werks and recipeid = l_recipeid.
            delete from zrecipeingrdt where werks = l_werks and recipeid = l_recipeid.
            delete from zrecipeversion where werks = l_werks and recipeid = l_recipeid.
          endif.

          copy_data_to_ref( exporting is_data = ls_entity
                  changing cr_data = er_data ).


      endcase.


    endif.

  endmethod.


  method /iwbep/if_mgw_appl_srv_runtime~get_expanded_entity.

    data: ls_recipetoversion TYPE zcl_zrecipecost_odata_mpc_ext=>TS_RECIPE_DEEP,
          ls_recipe          type zcl_zrecipecost_odata_mpc_ext=>ts_recipe,
          ls_recipeversion   type zcl_zrecipecost_odata_mpc_ext=>ts_recipeversion,
          lt_zrecipeversion  type standard table of zrecipeversion,
          ls_zrecipeversion  type zrecipeversion,
          l_werks            type werks_d,
          l_recipeid         type zrecipeversion-recipeid.

    data: ls_key_tab         type /iwbep/s_mgw_name_value_pair,
          ls_expanded_clause like line of et_expanded_tech_clauses.


    case iv_entity_set_name.
      when 'RecipeSet'.
        loop at it_key_tab into ls_key_tab.
          case ls_key_tab-name.
            when 'Werks'.
              l_werks = ls_key_tab-value.
            when 'RecipeID'.
              l_recipeid = ls_key_tab-value.
          endcase.
        endloop.

        select single * from zrecipe where werks = @l_werks and recipeid = @l_recipeid
            into corresponding fields of @ls_recipetoversion.

        select * from zrecipeversion  where werks = @l_werks and recipeid = @l_recipeid
            into table @lt_zrecipeversion
            up to 1 rows.

        loop at lt_zrecipeversion into ls_zrecipeversion.
          move-corresponding ls_zrecipeversion to ls_recipeversion.
          append ls_recipeversion to ls_recipetoversion-versions.
        endloop.

        copy_data_to_ref(
        exporting
          is_data = ls_recipetoversion
        changing
          cr_data = er_entity ).

        ls_expanded_clause = 'VERSIONS'.
        append ls_expanded_clause to et_expanded_tech_clauses.
    endcase.
  endmethod.


  method /iwbep/if_mgw_appl_srv_runtime~get_expanded_entityset.


*    data: begin of lt_recipetoversion.
*
*    data:   versions type zcl_zrecipecost_odata_mpc=>tt_recipeversion.
*    data: end of lt_recipetoversion.

data: lt_recipeversion  type zcl_zrecipecost_odata_mpc_ext=>tt_recipeversion,
      ls_recipeversion  type zcl_zrecipecost_odata_mpc_ext=>ts_recipeversion,
      ls_recipeingrdt   type zcl_zrecipecost_odata_mpc_ext=>ts_recipeingrdt,
      lt_recipeingrdt   type zcl_zrecipecost_odata_mpc_ext=>tt_recipeingrdt,
      lt_zrecipeingrdt  type standard table of zrecipeingrdt,
      ls_zrecipeingrdt  type zrecipeingrdt,
      lt_recipematprice TYPE ZTT_RECIPEMATPRICE,
      ls_recipematprice LIKE LINE OF lt_recipematprice.

data: ls_key_tab         type /iwbep/s_mgw_name_value_pair,
      lv_compare_result TYPE io_expand->ty_e_compare_result,
      ls_expanded_clause like line of et_expanded_tech_clauses.
*      lv_EKORG TYPE EKORG,
*      lv_purchorg TYPE STRING,
*      lv_plant TYPE STRING,
*      lv_filter TYPE STRING,
*      lv_matnr TYPE N LENGTH 18.




FIELD-SYMBOLS: <fs_recipeingrdt> TYPE zcl_zrecipecost_odata_mpc_ext=>ts_recipeingrdt.

data: lv_top type i.



    CASE iv_entity_set_name.
     WHEN 'RecipeVersionSet'.
        io_tech_request_context->get_converted_source_keys(
          IMPORTING
            es_key_values = ls_recipeversion ).

        lv_top = is_paging-top.

        SELECT * FROM zrecipeversion WHERE Werks = @ls_recipeversion-werks AND RecipeID = @ls_recipeversion-recipeid
          AND (IV_FILTER_STRING)
          ORDER BY versionid DESCENDING
          INTO CORRESPONDING FIELDS OF TABLE @lt_recipeversion
          UP TO @lv_top ROWS.

      ls_expanded_clause = 'VERSIONS'.
      append ls_expanded_clause to et_expanded_tech_clauses.

      copy_data_to_ref(
          exporting
            is_data = lt_recipeversion
          changing
            cr_data = er_entityset ).

     WHEN 'RecipeIngrdtSet'.
*      AND ( lv_compare_result EQ io_expand->gcs_compare_result-match_subset OR
*      lv_compare_result EQ io_expand->gcs_compare_result-match_equals ).

      io_tech_request_context->get_converted_source_keys(
          IMPORTING
            es_key_values = ls_recipeversion ).


      SELECT a~*, t~MaterialName as maktx, g~MaterialGroupText as Matkltx,t6~MSEHT as BPRMEX,tc~text as QTYUNITX FROM zrecipeingrdt as a
        INNER JOIN I_MaterialText as t ON ltrim( t~material, '0' )  = a~matnr  AND t~Language = @sy-langu
        INNER JOIN I_MaterialGroupText as g ON a~matkl = g~materialgroup AND g~Language = 'E'
        INNER JOIN T006A as t6 ON a~Bprme = t6~MSEH3 AND t6~spras = @sy-langu
        LEFT OUTER JOIN ZRECIPECOOKUNIT as tc ON a~QTYUNIT = tc~MSEHI and tc~werks = a~werks
         WHERE a~WERKS = @ls_recipeversion-werks AND RECIPEID = @ls_recipeversion-recipeid
           AND VERSIONID = @ls_recipeversion-versionid
                      INTO CORRESPONDING FIELDS OF TABLE @lt_recipeingrdt.

      LOOP AT lt_recipeingrdt ASSIGNING <fs_recipeingrdt>.
        IF <fs_recipeingrdt>-qtyunit IS INITIAL.
          <fs_recipeingrdt>-qtyunit = <fs_recipeingrdt>-Bprme.
          <fs_recipeingrdt>-qtyratio = 1.
        ENDIF.
      ENDLOOP.

*      SELECT SINGLE EKORG FROM ZRECIPEPLANT WHERE WERKS = @ls_recipeversion-werks INTO @lv_EKORG.
*
*
*      lv_purchorg = |( EKORG = '| & |{ lv_EKORG }| & |' )|.
*      lv_plant  = |( WERKS = '| & |{ ls_recipeversion-werks }| & |' )|.
*
*      LOOP AT lt_recipeingrdt ASSIGNING <fs_recipeingrdt>.
*
*        lv_matnr = <fs_recipeingrdt>-matnr.
*
*        lv_filter = |( MATNR = '| & |{ lv_matnr }| & |' )|.
*        zcl_amdp_recipecosting=>get_plant_material(
*           exporting iv_purchorg = lv_purchorg
*                     iv_plant = lv_plant
*                     iv_filter = lv_filter
*           importing et_material = lt_recipematprice ).
*
*        READ TABLE lt_recipematprice INDEX 1 INTO ls_recipematprice.
*        IF sy-subrc = 0.
*          <fs_recipeingrdt>-cpeinh = ls_recipematprice-peinh.
*          <fs_recipeingrdt>-cebeln = ls_recipematprice-ebeln.
*
*          call function 'CONVERSION_EXIT_CUNIT_OUTPUT'
*            exporting
*              input                = ls_recipematprice-bprme
*             LANGUAGE              = SY-LANGU
*           IMPORTING
**             LONG_TEXT            =
*             OUTPUT                = <fs_recipeingrdt>-cbprme
**             SHORT_TEXT           =
**           EXCEPTIONS
**             UNIT_NOT_FOUND       = 1
**             OTHERS               = 2
*                    .
*          if sy-subrc <> 0.
** Implement suitable error handling here
*          endif.
*
*        ENDIF.
*      ENDLOOP.

      ls_expanded_clause = 'INGREDIENTS'.
      append ls_expanded_clause to et_expanded_tech_clauses.

      copy_data_to_ref(
          exporting
            is_data = lt_recipeingrdt
          changing
            cr_data = er_entityset ).

    ENDCASE.

  endmethod.


  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_STREAM.
   DATA:  ls_key_werks                TYPE /iwbep/s_mgw_name_value_pair,
          ls_key_recipeid             TYPE /iwbep/s_mgw_name_value_pair,
          ls_key_filename             TYPE /iwbep/s_mgw_name_value_pair,
          ls_key_versionid            TYPE /iwbep/s_mgw_name_value_pair,
          ls_message                  TYPE scx_t100key,
          ls_photo                    TYPE zrecipeimg,
          ls_htc                      TYPE zrecipehtc,
          ls_lheader  TYPE ihttpnvp,
          ls_stream   TYPE ty_s_media_resource,
          lv_filename TYPE string.

    CASE iv_entity_name.
      WHEN 'RecipePhoto'.

        READ TABLE it_key_tab WITH KEY name = 'Werks' INTO ls_key_werks.
        READ TABLE it_key_tab WITH KEY name = 'RecipeID' INTO ls_key_recipeid.

        SELECT SINGLE * FROM zrecipeimg INTO CORRESPONDING FIELDS OF ls_photo WHERE werks = ls_key_werks-value
          AND recipeid = ls_key_recipeid-value.

        IF sy-subrc ne 0.
          SELECT SINGLE * FROM zrecipeimg INTO CORRESPONDING FIELDS OF ls_photo WHERE werks = ''
          AND recipeid = 'DEFAULT'.
        ENDIF.

        ls_stream-value = ls_photo-content.
        ls_stream-mime_type = ls_photo-mimetype.

        lv_filename = ls_photo-filename.
        lv_filename = escape( val = lv_filename
                              format = cl_abap_format=>e_url ).
        ls_lheader-name = 'Content-Disposition'.
        ls_lheader-value = |inline; filename="{ lv_filename }"|.
        set_header( is_header = ls_lheader ).

        copy_data_to_ref( EXPORTING is_data = ls_stream
                          CHANGING  cr_data = er_stream ).

       WHEN 'RecipeHTC'.

        READ TABLE it_key_tab WITH KEY name = 'Werks' INTO ls_key_werks.
        READ TABLE it_key_tab WITH KEY name = 'RecipeID' INTO ls_key_recipeid.
        READ TABLE it_key_tab WITH KEY name = 'Filename' INTO ls_key_filename.

        SELECT SINGLE * FROM zrecipehtc INTO CORRESPONDING FIELDS OF ls_htc WHERE werks = ls_key_werks-value
          AND recipeid = ls_key_recipeid-value AND Filename = ls_key_filename-value.

        IF sy-subrc = 0.
          ls_stream-value = ls_htc-content.
          ls_stream-mime_type = ls_htc-mimetype.

          lv_filename = ls_htc-filename.
          lv_filename = escape( val = lv_filename
                                format = cl_abap_format=>e_url ).
        ELSE.
          lv_filename = ls_key_filename-value.
          ls_stream-value = '3C703E3C2F703E'.
          ls_stream-mime_type = 'text/plain'.
        ENDIF.
        ls_lheader-name = 'Content-Disposition'.
        ls_lheader-value = |inline; filename="{ lv_filename }"|.
        set_header( is_header = ls_lheader ).

        copy_data_to_ref( EXPORTING is_data = ls_stream
                          CHANGING  cr_data = er_stream ).
    ENDCASE.
  endmethod.


  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~UPDATE_STREAM.

  DATA: ls_key_werks                TYPE /iwbep/s_mgw_name_value_pair,
        ls_key_recipeid             TYPE /iwbep/s_mgw_name_value_pair,
        ls_key_filename             TYPE /iwbep/s_mgw_name_value_pair,
        ls_htc                      TYPE zrecipehtc.

  CASE iv_entity_name.
      WHEN 'RecipeHTC'.
        READ TABLE it_key_tab WITH KEY name = 'Werks' INTO ls_key_werks.
        READ TABLE it_key_tab WITH KEY name = 'RecipeID' INTO ls_key_recipeid.
        READ TABLE it_key_tab WITH KEY name = 'Filename' INTO ls_key_filename.

        ls_htc-werks = ls_key_werks-value.
        ls_htc-recipeid = ls_key_recipeid-value.
        ls_htc-filename = ls_key_filename-value.
        ls_htc-mimetype = is_media_resource-mime_type.
        ls_htc-content = is_media_resource-value.
        ls_htc-ernam = sy-uname.
        ls_htc-aedat = sy-datum.
        ls_htc-aezet = sy-uzeit.
        MODIFY zrecipehtc FROM ls_htc.
  ENDCASE.
  endmethod.


  method COOKINGUNITSET_CREATE_ENTITY.

  DATA: ls_message  TYPE scx_t100key.

  DATA: lv_werks TYPE zrecipecookunit-werks,
        lv_msehi TYPE zrecipecookunit-msehi,
        ls_data LIKE ER_ENTITY,
        ls_recipecookunit TYPE zrecipecookunit.

  io_data_provider->read_entry_data( IMPORTING es_data = ls_data ).

  SELECT SINGLE * FROM ZRECIPECOOKUNIT WHERE WERKS = @ls_data-werks AND MSEHI = @ls_data-msehi INTO @ls_recipecookunit.
  IF sy-subrc = 0.
      ls_message-msgid = 'SY'.
      ls_message-msgno = '002'.
      ls_message-attr1 = 'The Unit Code is an existing unit code. Please choose another code.'.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid = ls_message.
  ELSE.
    MOVE-CORRESPONDING ls_data TO ls_recipecookunit.

    INSERT ZRECIPECOOKUNIT FROM ls_recipecookunit.
    IF sy-subrc = 0.
       ER_ENTITY = ls_recipecookunit.
    ENDIF.
  ENDIF.
  endmethod.


  method COOKINGUNITSET_DELETE_ENTITY.

DATA: lt_keys TYPE /IWBEP/T_MGW_TECH_PAIRS,
      ls_message  TYPE scx_t100key.
DATA: lv_werks TYPE werks_d,
      lv_msehi TYPE ZRECIPECOOKUNIT-msehi,
      lv_count TYPE i.

FIELD-SYMBOLS: <ls_key> TYPE /IWBEP/S_MGW_TECH_PAIR.

lt_keys = IO_TECH_REQUEST_CONTEXT->GET_KEYS( ).

READ TABLE lt_keys WITH KEY name = 'WERKS'
      ASSIGNING <ls_key>.

  IF sy-subrc EQ 0.
      lv_werks = <ls_key>-value.
  ELSE.
      ls_message-msgid = 'SY'.
      ls_message-msgno = '002'.
      ls_message-attr1 = 'Plant ID is invalid'.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid = ls_message.
  ENDIF.


READ TABLE lt_keys WITH KEY name = 'MSEHI'
      ASSIGNING <ls_key>.

  IF sy-subrc EQ 0.
      lv_msehi = <ls_key>-value.
  ELSE.
      ls_message-msgid = 'SY'.
      ls_message-msgno = '002'.
      ls_message-attr1 = 'Unit Code is invalid'.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid = ls_message.
  ENDIF.


  SELECT COUNT(*) FROM ZRECIPEMATCUNIT INTO lv_count WHERE WERKS = lv_werks AND COOKUNIT = lv_msehi.
  IF lv_count = 0.
    DELETE FROM ZRECIPECOOKUNIT WHERE WERKS = lv_werks AND MSEHI = lv_msehi.
  ELSE.
      ls_message-msgid = 'SY'.
      ls_message-msgno = '002'.
      ls_message-attr1 = 'Cannot delete the Cook Unit. It is in use'.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid = ls_message.
  ENDIF.
  endmethod.


  method COOKINGUNITSET_GET_ENTITY.

DATA: lt_keys TYPE /IWBEP/T_MGW_TECH_PAIRS,
      ls_key TYPE /IWBEP/S_MGW_TECH_PAIR,
      lv_werks type werks_d,
      lv_msehi type zrecipecookunit-msehi.

  lt_keys = IO_TECH_REQUEST_CONTEXT->GET_KEYS( ).
  READ TABLE lt_keys with key name = 'WERKS' INTO ls_key.
  lv_werks = ls_key-value.

  READ TABLE lt_keys with key name = 'MSEHI' INTO ls_key.
  lv_msehi = ls_key-value.

  SELECT SINGLE * FROM ZRECIPECOOKUNIT INTO CORRESPONDING FIELDS OF ER_ENTITY WHERE
    WERKS = lv_werks AND MSEHI = lv_msehi.

  endmethod.


  method COOKINGUNITSET_GET_ENTITYSET.

    data: lv_werks type werks_d.
    data: ls_message TYPE scx_t100key.
    data: ls_filter_selopt like line of it_filter_select_options.
    FIELD-SYMBOLS: <fs_werks> TYPE /iwbep/s_cod_select_option.



    READ TABLE  it_filter_select_options  WITH TABLE KEY property = 'Werks' INTO ls_filter_selopt.
    IF sy-subrc EQ 0.
      READ TABLE ls_filter_selopt-select_options INDEX 1 ASSIGNING <fs_werks>.
      IF sy-subrc EQ 0.
          lv_werks = <fs_werks>-low.
      ENDIF.
    ENDIF.

    "CHECK AUTH PLANT

    IF me->has_auth_plant( lv_werks ) eq abap_false.

        ls_message-msgid = 'SY'.
        ls_message-msgno = '002'.
        ls_message-attr1 = 'No authorization'.
        ls_message-attr2 = lv_werks.
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            textid = ls_message.
        EXIT.
    ENDIF.


   DATA: lv_filter_string TYPE STRING.
   lv_filter_string = IV_FILTER_STRING.

   me->SUBSTRINGOF_TO_LIKE_STR(
    CHANGING IV_FILTER_STRING = lv_filter_string ).

 SELECT * FROM ZRECIPECOOKUNIT
      WHERE (LV_FILTER_STRING)
      ORDER BY msehi
   INTO CORRESPONDING FIELDS OF TABLE @ET_ENTITYSET.

  endmethod.


  method COOKINGUNITSET_UPDATE_ENTITY.

  DATA: lt_keys TYPE /iwbep/t_mgw_tech_pairs,
        ls_data TYPE ZRECIPECOOKUNIT.

  DATA: ls_message TYPE scx_t100key.

  DATA: lv_werks TYPE werks_d,
        lv_msehi TYPE ZRECIPECOOKUNIT-msehi.

  FIELD-SYMBOLS: <ls_key>    TYPE /iwbep/s_mgw_tech_pair.

  lt_keys = io_tech_request_context->get_keys( ).

  READ TABLE lt_keys WITH KEY name = 'WERKS'
      ASSIGNING <ls_key>.

  IF sy-subrc EQ 0.
      lv_werks = <ls_key>-value.
  ELSE.
      ls_message-msgid = 'SY'.
      ls_message-msgno = '002'.
      ls_message-attr1 = 'Plant ID is invalid'.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid = ls_message.
  ENDIF.


  READ TABLE lt_keys WITH KEY name = 'MSEHI'
      ASSIGNING <ls_key>.

  IF sy-subrc EQ 0.
      lv_msehi = <ls_key>-value.
  ELSE.
      ls_message-msgid = 'SY'.
      ls_message-msgno = '002'.
      ls_message-attr1 = 'Unit Code is invalid'.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid = ls_message.
    ENDIF.

  io_data_provider->read_entry_data( IMPORTING es_data = ls_data ).

  MODIFY ZRECIPECOOKUNIT FROM ls_data.
  IF sy-subrc ne 0.

    ls_message-msgid = 'SY'.
    ls_message-msgno = '002'.
    ls_message-attr1 = 'Cannot find the Unit Code'.

    RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid = ls_message.

  ENDIF.

  ER_ENTITY = ls_data.

  endmethod.


  method GET_AUTH_PLANTS.

    DATA: lt_auth_plant TYPE STANDARD TABLE OF usvalues,
      ls_auth_plant TYPE usvalues.

    DATA: r_plant TYPE RANGE OF MARC-WERKS,
          wr_plant LIKE LINE OF r_plant.


    CALL FUNCTION 'SUSR_USER_AUTH_FOR_OBJ_GET'
      EXPORTING
        USER_NAME                 = sy-uname
        SEL_OBJECT                = 'M_BANF_WRK'
      TABLES
        VALUES                    = lt_auth_plant
     EXCEPTIONS
       USER_NAME_NOT_EXIST       = 1
       NOT_AUTHORIZED            = 2
       INTERNAL_ERROR            = 3
       OTHERS                    = 4.

    IF SY-SUBRC <> 0.
     EXIT.
    ENDIF.


    DELETE lt_auth_plant WHERE FIELD <> 'WERKS'.
    DELETE ADJACENT DUPLICATES FROM lt_auth_plant COMPARING VON.

    LOOP AT lt_auth_plant INTO ls_auth_plant.
      IF ls_auth_plant-FIELD = 'WERKS'.
        IF ls_auth_plant-VON = '*'.
          wr_plant-sign = 'I'.
          wr_plant-option = 'CP'.
          wr_plant-low = '*'.
          APPEND wr_plant TO r_plant.
        ELSE.
          wr_plant-sign = 'I'.
          wr_plant-option = 'EQ'.
          wr_plant-low = ls_auth_plant-VON.
          APPEND wr_plant TO r_plant.
        ENDIF.
      ENDIF.
    ENDLOOP.

    RESULT = R_PLANT.

  endmethod.


  method HAS_AUTH_PLANT.

    DATA: lt_auth_plant TYPE STANDARD TABLE OF usvalues,
      ls_auth_plant TYPE usvalues.

    DATA: r_plant TYPE RANGE OF MARC-WERKS,
          wr_plant LIKE LINE OF r_plant.


    CALL FUNCTION 'SUSR_USER_AUTH_FOR_OBJ_GET'
      EXPORTING
        USER_NAME                 = sy-uname
        SEL_OBJECT                = 'M_BANF_WRK'
      TABLES
        VALUES                    = lt_auth_plant
     EXCEPTIONS
       USER_NAME_NOT_EXIST       = 1
       NOT_AUTHORIZED            = 2
       INTERNAL_ERROR            = 3
       OTHERS                    = 4.

    IF SY-SUBRC <> 0.
     EXIT.
    ENDIF.


    DELETE lt_auth_plant WHERE FIELD <> 'WERKS'.
    DELETE ADJACENT DUPLICATES FROM lt_auth_plant COMPARING VON.

    LOOP AT lt_auth_plant INTO ls_auth_plant.
      IF ls_auth_plant-FIELD = 'WERKS'.
        IF ls_auth_plant-VON = '*'.
          wr_plant-sign = 'I'.
          wr_plant-option = 'CP'.
          wr_plant-low = '*'.
          APPEND wr_plant TO r_plant.
        ELSE.
          wr_plant-sign = 'I'.
          wr_plant-option = 'EQ'.
          wr_plant-low = ls_auth_plant-VON.
          APPEND wr_plant TO r_plant.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF PLANT IN R_PLANT.
      RESULT = abap_true.
    ELSE.
      RESULT = abap_false.
    ENDIF.

  endmethod.


  method LOCATIONSET_CREATE_ENTITY.

  DATA: lv_locationid TYPE zrecipeloc-locationid,
        ls_data LIKE ER_ENTITY,
        ls_location TYPE zrecipeloc.


  io_data_provider->read_entry_data( IMPORTING es_data = ls_data ).


  SELECT MAX( LOCATIONID ) INTO lv_locationid FROM ZRECIPELOC WHERE WERKS = ls_data-werks.

  IF sy-subrc = 0.
    lv_locationid =  lv_locationid + 1.
  ELSE.
    lv_locationid = '00001'.
  ENDIF.


  ls_location-werks = ls_data-werks.
  ls_location-locationid = lv_locationid.
  ls_location-text = ls_data-text.

  INSERT zrecipeloc FROM ls_location .
  IF sy-subrc = 0.
    ER_ENTITY = ls_location.
  ENDIF.
  endmethod.


  method LOCATIONSET_DELETE_ENTITY.

DATA: lt_keys TYPE /IWBEP/T_MGW_TECH_PAIRS,
      ls_message  TYPE scx_t100key.
DATA: lv_werks TYPE werks_d,
      lv_locationID TYPE ZRECIPELOC-locationid,
      lv_count TYPE i.

FIELD-SYMBOLS: <ls_key> TYPE /IWBEP/S_MGW_TECH_PAIR.


lt_keys = IO_TECH_REQUEST_CONTEXT->GET_KEYS( ).

READ TABLE lt_keys WITH KEY name = 'WERKS'
      ASSIGNING <ls_key>.

  IF sy-subrc EQ 0.
      lv_werks = <ls_key>-value.
  ELSE.
      ls_message-msgid = 'SY'.
      ls_message-msgno = '002'.
      ls_message-attr1 = 'Plant ID is invalid'.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid = ls_message.
  ENDIF.


READ TABLE lt_keys WITH KEY name = 'LOCATIONID'
      ASSIGNING <ls_key>.

  IF sy-subrc EQ 0.
      lv_locationID = <ls_key>-value.
  ELSE.
      ls_message-msgid = 'SY'.
      ls_message-msgno = '002'.
      ls_message-attr1 = 'Location ID is invalid'.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid = ls_message.
  ENDIF.


  SELECT COUNT(*) FROM ZRECIPE INTO lv_count WHERE WERKS = lv_werks AND LOCATIONID = lv_locationID.
  IF lv_count = 0.
    DELETE FROM ZRECIPELOC WHERE WERKS = lv_werks AND LOCATIONID = lv_locationID.
  ELSE.
      ls_message-msgid = 'SY'.
      ls_message-msgno = '002'.
      ls_message-attr1 = 'Cannot delete the location. It is in use'.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid = ls_message.
  ENDIF.

  endmethod.


  method LOCATIONSET_GET_ENTITY.

DATA: lt_keys TYPE /IWBEP/T_MGW_TECH_PAIRS,
      ls_key TYPE /IWBEP/S_MGW_TECH_PAIR,
      lv_werks type werks_d,
      lv_locationID type zrecipeloc-locationID.


  lt_keys = IO_TECH_REQUEST_CONTEXT->GET_KEYS( ).
  READ TABLE lt_keys with key name = 'WERKS' INTO ls_key.
  lv_werks = ls_key-value.

  READ TABLE lt_keys with key name = 'LOCATIONID' INTO ls_key.
  lv_locationID = ls_key-value.


  SELECT SINGLE * FROM ZRECIPELOC INTO ER_ENTITY WHERE
    WERKS = lv_werks AND locationID = lv_locationID.


  endmethod.


  method LOCATIONSET_GET_ENTITYSET.

    data: lv_werks type werks_d.
    data: ls_message TYPE scx_t100key.
    data: ls_filter_selopt like line of it_filter_select_options.
    FIELD-SYMBOLS: <fs_werks> TYPE /iwbep/s_cod_select_option.



    READ TABLE  it_filter_select_options  WITH TABLE KEY property = 'Werks' INTO ls_filter_selopt.
    IF sy-subrc EQ 0.
      READ TABLE ls_filter_selopt-select_options INDEX 1 ASSIGNING <fs_werks>.
      IF sy-subrc EQ 0.
          lv_werks = <fs_werks>-low.
      ENDIF.
    ENDIF.

    "CHECK AUTH PLANT

    IF me->has_auth_plant( lv_werks ) eq abap_false.

        ls_message-msgid = 'SY'.
        ls_message-msgno = '002'.
        ls_message-attr1 = 'No authorization'.
        ls_message-attr2 = lv_werks.
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            textid = ls_message.
        EXIT.
    ENDIF.

   DATA: lv_filter_string TYPE STRING.

   lv_filter_string = IV_FILTER_STRING.

   me->SUBSTRINGOF_TO_LIKE_STR(
     CHANGING IV_FILTER_STRING = lv_filter_string ).

   SELECT * FROM ZRECIPELOC
      WHERE (LV_FILTER_STRING)
      ORDER BY TEXT
      INTO TABLE @ET_ENTITYSET.


  endmethod.


  method LOCATIONSET_UPDATE_ENTITY.

  DATA: lt_keys TYPE /iwbep/t_mgw_tech_pairs,
        ls_data TYPE ZRECIPELOC.

  DATA: ls_message TYPE scx_t100key.

  DATA: lv_werks TYPE werks_d,
        lv_locationID LIKE ER_ENTITY-locationID.

  FIELD-SYMBOLS: <ls_key>    TYPE /iwbep/s_mgw_tech_pair.

  lt_keys = io_tech_request_context->get_keys( ).

  READ TABLE lt_keys WITH KEY name = 'WERKS'
      ASSIGNING <ls_key>.

  IF sy-subrc EQ 0.
      lv_werks = <ls_key>-value.
  ELSE.
      ls_message-msgid = 'SY'.
      ls_message-msgno = '002'.
      ls_message-attr1 = 'Plant ID is invalid'.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid = ls_message.
  ENDIF.


  READ TABLE lt_keys WITH KEY name = 'LOCATIONID'
      ASSIGNING <ls_key>.

  IF sy-subrc EQ 0.
      lv_locationID = <ls_key>-value.
  ELSE.
      ls_message-msgid = 'SY'.
      ls_message-msgno = '002'.
      ls_message-attr1 = 'Location ID is invalid'.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid = ls_message.
    ENDIF.

  io_data_provider->read_entry_data( IMPORTING es_data = ls_data ).

  MODIFY ZRECIPELOC FROM ls_data.
  IF sy-subrc ne 0.

    ls_message-msgid = 'SY'.
    ls_message-msgno = '002'.
    ls_message-attr1 = 'Cannot find the Location'.

    RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid = ls_message.

  ENDIF.

  ER_ENTITY = ls_data.

  endmethod.


  method MATCOOKINGUNITSE_CREATE_ENTITY.

    DATA: ls_data TYPE ZRECIPEMATCUNIT,
          l_matnr TYPE N LENGTH 18.

    io_data_provider->read_entry_data( IMPORTING es_data = ls_data ).

    l_matnr = ls_data-matnr.
    ls_data-matnr = l_matnr.

    INSERT ZRECIPEMATCUNIT FROM ls_data .
    IF sy-subrc = 0.
       MOVE-CORRESPONDING ls_data TO ER_ENTITY.
    ENDIF.

  endmethod.


  method MATCOOKINGUNITSE_DELETE_ENTITY.

DATA: lt_keys TYPE /IWBEP/T_MGW_TECH_PAIRS,
      ls_message  TYPE scx_t100key.
DATA: lv_werks TYPE werks_d,
      lv_matnr TYPE N LENGTH 18,
      lv_cookunit TYPE ZRECIPEMATCUNIT-cookunit,
      lv_count TYPE i.

FIELD-SYMBOLS: <ls_key> TYPE /IWBEP/S_MGW_TECH_PAIR.

lt_keys = IO_TECH_REQUEST_CONTEXT->GET_KEYS( ).

READ TABLE lt_keys WITH KEY name = 'WERKS' ASSIGNING <ls_key>.

IF sy-subrc EQ 0.
      lv_werks = <ls_key>-value.
ELSE.
      ls_message-msgid = 'SY'.
      ls_message-msgno = '002'.
      ls_message-attr1 = 'Plant ID is invalid'.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid = ls_message.
ENDIF.

READ TABLE lt_keys WITH KEY name = 'MATNR' ASSIGNING <ls_key>.

IF sy-subrc EQ 0.
      lv_matnr = <ls_key>-value.
ELSE.
      ls_message-msgid = 'SY'.
      ls_message-msgno = '002'.
      ls_message-attr1 = 'Material ID is invalid'.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid = ls_message.
ENDIF.

READ TABLE lt_keys WITH KEY name = 'COOKUNIT' ASSIGNING <ls_key>.

IF sy-subrc EQ 0.
      lv_cookunit = <ls_key>-value.
ELSE.
      ls_message-msgid = 'SY'.
      ls_message-msgno = '002'.
      ls_message-attr1 = 'Cooking Unit is invalid'.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid = ls_message.
ENDIF.


  DELETE FROM  ZRECIPEMATCUNIT WHERE WERKS = lv_werks AND MATNR = lv_matnr AND COOKUNIT = lv_cookunit.

  IF sy-subrc ne 0.
      ls_message-msgid = 'SY'.
      ls_message-msgno = '002'.
      ls_message-attr1 = 'Cannot delete the Cook Unit.'.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid = ls_message.
  ENDIF.

  endmethod.


  method MATCOOKINGUNITSE_GET_ENTITY.


  DATA: lt_keys TYPE /IWBEP/T_MGW_TECH_PAIRS,
        ls_key TYPE /IWBEP/S_MGW_TECH_PAIR.

  DATA: lv_werks TYPE ZRECIPEMATCUNIT-WERKS,
        lv_matnr TYPE N LENGTH 18,
        lv_cookunit TYPE ZRECIPEMATCUNIT-COOKUNIT.

  lt_keys = IO_TECH_REQUEST_CONTEXT->GET_KEYS( ).
  READ TABLE lt_keys with key name = 'WERKS' INTO ls_key.
  lv_werks = ls_key-value.

  READ TABLE lt_keys with key name = 'MATNR' INTO ls_key.
  lv_matnr = ls_key-value.

  READ TABLE lt_keys with key name = 'COOKUNIT' INTO ls_key.
  lv_cookunit = ls_key-value.


  SELECT SINGLE a~werks, LTRIM( a~matnr,'0' ) as matnr, a~cookunit, a~cookqty, a~purcunit, a~purcqty, t~maktx, tc~TEXT as COOKUNITX, t6~MSEHT as PURCUNITX
     FROM ZRECIPEMATCUNIT as a INNER JOIN MAKT as t ON a~matnr = t~matnr AND t~spras = @sy-langu
      INNER JOIN T006A as t6 ON a~purcunit = t6~mseh3 AND t6~spras = @sy-langu
      INNER JOIN ZRECIPECOOKUNIT as tc ON a~cookunit = tc~MSEHI and tc~werks = @lv_werks
      WHERE a~werks = @lv_werks AND a~matnr = @lv_matnr AND a~cookunit = @lv_cookunit
       INTO CORRESPONDING FIELDS OF @ER_ENTITY.

  endmethod.


  method MATCOOKINGUNITSE_GET_ENTITYSET.

   DATA: l_werks TYPE werks_d,
         l_matnr TYPE N LENGTH 18.

   DATA: lv_filter_string TYPE STRING.
   DATA: lt_filters  TYPE  /iwbep/t_mgw_select_option,
         ls_filter   TYPE /iwbep/s_mgw_select_option,
         ls_so TYPE  /iwbep/s_cod_select_option.

   DATA: ls_ENTITYSET LIKE LINE OF ET_ENTITYSET.

   DATA: ls_message TYPE scx_t100key.

   FIELD-SYMBOLS: <fs_werks> TYPE /iwbep/s_cod_select_option,
                  <fs_matnr> TYPE /iwbep/s_cod_select_option.

   lt_filters = io_tech_request_context->get_filter( )->get_filter_select_options( ).


   READ TABLE lt_filters WITH TABLE KEY property = 'WERKS' INTO ls_filter.
   IF sy-subrc EQ 0.
      READ TABLE ls_filter-select_options INDEX 1 ASSIGNING <fs_werks>.
   ENDIF.


   IF <fs_werks> IS ASSIGNED.
     l_werks = <fs_werks>-low.
     IF l_werks IS INITIAL.
        ls_message-msgid = 'SY'.
        ls_message-msgno = '002'.
        ls_message-attr1 = 'Filter by Plant ID is required'.
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            textid = ls_message.
     ENDIF.
   ELSE.
      ls_message-msgid = 'SY'.
      ls_message-msgno = '002'.
      ls_message-attr1 = 'Filter by Plant ID is required'.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid = ls_message.
    ENDIF.


     "CHECK AUTH PLANT

    IF me->has_auth_plant( l_werks ) eq abap_false.

        ls_message-msgid = 'SY'.
        ls_message-msgno = '002'.
        ls_message-attr1 = 'No authorization'.
        ls_message-attr2 = l_werks.
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            textid = ls_message.
        EXIT.
    ENDIF.


    READ TABLE lt_filters WITH TABLE KEY property = 'MATNR' INTO ls_filter.
    IF sy-subrc EQ 0.
      READ TABLE ls_filter-select_options INDEX 1 ASSIGNING <fs_matnr>.
    ENDIF.

   lv_filter_string = IV_FILTER_STRING.

   me->SUBSTRINGOF_TO_LIKE_STR(
     CHANGING IV_FILTER_STRING = lv_filter_string ).

   REPLACE ALL OCCURRENCES OF 'Werks' IN lv_filter_string WITH 'a~Werks'.
   REPLACE ALL OCCURRENCES OF 'Cookunit' IN lv_filter_string WITH 'a~Cookunit'.

   IF <fs_matnr> IS ASSIGNED.
     l_matnr = <fs_matnr>-low.
     DATA(MATNR) = |a~$1'{ l_matnr }'|.
     REPLACE ALL OCCURRENCES OF REGEX '(Matnr eq )''([0-9]+)''' IN lv_filter_string WITH MATNR.
   ENDIF.

   SELECT a~werks, LTRIM( a~matnr,'0' ) as matnr, a~cookunit, a~cookqty, a~purcunit, a~purcqty, t~maktx, tc~TEXT as COOKUNITX, t6~MSEHT as PURCUNITX
     FROM ZRECIPEMATCUNIT as a INNER JOIN MAKT as t ON a~matnr = t~matnr AND t~spras = @sy-langu
      INNER JOIN T006A as t6 ON a~purcunit = t6~MSEH3 AND t6~spras = @sy-langu
      INNER JOIN ZRECIPECOOKUNIT as tc ON a~cookunit = tc~MSEHI and tc~werks = @l_werks
      WHERE (LV_FILTER_STRING)
      ORDER BY t~MAKTX
      INTO CORRESPONDING FIELDS OF TABLE @ET_ENTITYSET.


   "Add Default Unit (Itself)
   READ TABLE ET_ENTITYSET INTO ls_ENTITYSET INDEX 1.
   IF sy-subrc = 0.
     ls_ENTITYSET-COOKQTY = 1.
     ls_ENTITYSET-COOKUNIT = ls_ENTITYSET-PURCUNIT.
     ls_ENTITYSET-COOKUNITX = ls_ENTITYSET-PURCUNITX.
     APPEND ls_ENTITYSET TO ET_ENTITYSET.
   ENDIF.


  endmethod.


  method MATCOOKINGUNITSE_UPDATE_ENTITY.
    DATA: lt_keys TYPE /iwbep/t_mgw_tech_pairs,
          ls_message TYPE scx_t100key.

    DATA: lv_werks TYPE werks_d,
          lv_matnr TYPE N LENGTH 18,
          lv_cookunit TYPE ZRECIPEMATCUNIT-cookunit.

    DATA: ls_data TYPE ZRECIPEMATCUNIT.

    FIELD-SYMBOLS: <ls_key>    TYPE /iwbep/s_mgw_tech_pair.


  io_data_provider->read_entry_data( IMPORTING es_data = ls_data ).

  lv_matnr = ls_data-matnr.
  ls_data-matnr = lv_matnr.

  MODIFY ZRECIPEMATCUNIT FROM ls_data.
  IF sy-subrc ne 0.

    ls_message-msgid = 'SY'.
    ls_message-msgno = '002'.
    ls_message-attr1 = 'Cannot find update the Cooking unit'.

    RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid = ls_message.

  ENDIF.

  MOVE-CORRESPONDING ls_data TO ER_ENTITY.

  endmethod.


  method plantmaterialset_get_entityset.

    data:
          lv_PLANT    type string,
          lv_PURCHORG type string,
          lv_MATTY    type string.

*IT_FILTER_SELECT_OPTIONS

    data:
          ls_filter_selopt like line of it_filter_select_options,
          ls_selopt        like line of ls_filter_selopt-select_options.


    read table it_filter_select_options into ls_filter_selopt with table key property = 'Werks'.
    if sy-subrc = 0.
      try.
          lv_plant = cl_shdb_seltab=>combine_seltabs(
             it_named_seltabs = value #(
           ( name = 'WERKS' dref = ref #( ls_filter_selopt-select_options[] ) )
           ) ).
        catch cx_shdb_exception.
      endtry.

    else.
      exit.
    endif.

    read table it_filter_select_options into ls_filter_selopt with table key property = 'Mtart'.
    if sy-subrc = 0.
      try.
          lv_matty = cl_shdb_seltab=>combine_seltabs(
             it_named_seltabs = value #(
           ( name = 'MTART' dref = ref #( ls_filter_selopt-select_options[] ) )
           ) ).
        catch cx_shdb_exception.
      endtry.
    else.
      exit.
    endif.

    "Purchasing Org.
*    clear ls_filter_selopt-select_options.
*    ls_selopt-sign = 'I'.
*    ls_selopt-option = 'EQ'.
*    ls_selopt-low = 'C103'.
*    append ls_selopt to ls_filter_selopt-select_options.


    read table it_filter_select_options into ls_filter_selopt with table key property = 'Ekorg'.
    try.
        lv_purchorg = cl_shdb_seltab=>combine_seltabs(
              it_named_seltabs = value #(
            ( name = 'EKORG' dref = ref #( ls_filter_selopt-select_options[] ) )
            ) ).
      catch cx_shdb_exception.
    endtry.

    zcl_amdp_recipecosting=>get_plant_material(
      exporting iv_purchorg = lv_purchorg
                iv_plant = lv_plant
                iv_filter = lv_matty
      importing et_material = et_entityset ).


   FIELD-SYMBOLS: <fs_werks> TYPE /iwbep/s_cod_select_option.

   READ TABLE  it_filter_select_options  WITH TABLE KEY property = 'Werks' INTO ls_filter_selopt.
   IF sy-subrc EQ 0.
      READ TABLE ls_filter_selopt-select_options INDEX 1 ASSIGNING <fs_werks>.
   ENDIF.

  WITH
  +LATESTVER AS (
    SELECT v1~* FROM ZRECIPEVERSION as v1
      LEFT JOIN ZRECIPEVERSION as v2 ON ( v1~werks = v2~werks AND v1~recipeid = v2~recipeid AND v1~versionid < v2~versionid )
      WHERE v2~versionid IS NULL AND v1~werks = @<fs_werks>-low
   ),
   +RECIPE AS (

   SELECT  a~werks, a~RECIPEID as Matnr, a~NAME as Maktx, a~GROUPID as Matkl, g~TEXT as Matkltx, 'FOOD' as Mtart, a~EKORG as Ekorg, b~WAERS,
      b~TOTRECIPECOST as Netpr, 1 as Peinh, b~BPRME, a~CREATEDBY as ERNAM FROM ZRECIPE as a
      INNER JOIN ZRECIPEGROUP as g ON a~werks = g~werks AND a~GROUPID = g~GROUPID
      INNER JOIN ZRECIPEVERSION as b ON a~werks = b~werks AND a~RECIPEID = b~RECIPEID
      INNER JOIN +LATESTVER as v ON b~werks = v~werks AND b~recipeid = v~recipeid AND b~VERSIONID = v~VERSIONID

      WHERE a~werks = @<fs_werks>-low and a~ISSUBMAT = 'X' AND b~costperunit > 0

   )

   SELECT * FROM +RECIPE APPENDING CORRESPONDING FIELDS OF TABLE @et_entityset.


    call method /iwbep/cl_mgw_data_util=>filtering
      exporting
        it_select_options = it_filter_select_options
      changing
        ct_data           = et_entityset.

    if is_paging is not initial.
** The function module for $top and $skip Query Options
      call method /iwbep/cl_mgw_data_util=>paging
        exporting
          is_paging = is_paging
        changing
          ct_data   = et_entityset.
    endif.




  endmethod.


  method PLANTSET_CREATE_ENTITY.

 DATA: lv_werks TYPE zrecipeplant-werks,
        ls_data LIKE ER_ENTITY,
        ls_plant TYPE zrecipeplant.

  io_data_provider->read_entry_data( IMPORTING es_data = ls_data ).

  ls_plant-werks = ls_data-werks.
  ls_plant-ekorg = ls_data-ekorg.

  INSERT zrecipeplant FROM ls_plant .
  IF sy-subrc = 0.
    ER_ENTITY = ls_plant.
  ENDIF.
  endmethod.


  method PLANTSET_DELETE_ENTITY.

DATA: lt_keys TYPE /IWBEP/T_MGW_TECH_PAIRS,
      ls_message  TYPE scx_t100key.
DATA: lv_werks TYPE werks_d,
      lv_count TYPE i.

FIELD-SYMBOLS: <ls_key> TYPE /IWBEP/S_MGW_TECH_PAIR.


lt_keys = IO_TECH_REQUEST_CONTEXT->GET_KEYS( ).

READ TABLE lt_keys WITH KEY name = 'WERKS'
      ASSIGNING <ls_key>.

  IF sy-subrc EQ 0.
      lv_werks = <ls_key>-value.
  ELSE.
      ls_message-msgid = 'SY'.
      ls_message-msgno = '002'.
      ls_message-attr1 = 'Plant ID is invalid'.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid = ls_message.
  ENDIF.



  DELETE FROM ZRECIPEPLANT WHERE WERKS = lv_werks.
  IF sy-subrc ne 0.
      ls_message-msgid = 'SY'.
      ls_message-msgno = '002'.
      ls_message-attr1 = 'Cannot delete the Plant Assignment.'.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid = ls_message.
  ENDIF.

  endmethod.


  method PLANTSET_GET_ENTITY.

DATA: lt_keys TYPE /IWBEP/T_MGW_TECH_PAIRS,
      ls_key TYPE /IWBEP/S_MGW_TECH_PAIR,
      lv_werks type werks_d.

DATA: r_plant TYPE RANGES_WERKS_TT.

  r_plant = me->get_auth_plants( ).

  lt_keys = IO_TECH_REQUEST_CONTEXT->GET_KEYS( ).
  READ TABLE lt_keys with key name = 'WERKS' INTO ls_key.
  lv_werks = ls_key-value.


  SELECT SINGLE a~plant as WERKS, a~plantname as Name, b~EKORG FROM I_PLANTSTDVH as a LEFT OUTER JOIN ZRECIPEPLANT as b ON a~plant  = b~werks
      WHERE a~plant = @lv_werks
      AND a~plant IN @r_plant
      INTO @ER_ENTITY.
  endmethod.


  method PLANTSET_GET_ENTITYSET.

    DATA: r_plant TYPE RANGES_WERKS_TT.

    r_plant = me->get_auth_plants( ).


    SELECT a~plant as WERKS, a~plantname as Name, b~EKORG FROM I_PLANTSTDVH as a LEFT OUTER JOIN ZRECIPEPLANT as b ON a~plant  = b~werks
      WHERE (IV_FILTER_STRING)
      AND a~plant IN @r_plant
      INTO TABLE @ET_ENTITYSET.

    IF IT_ORDER IS NOT INITIAL.
    call method /iwbep/cl_mgw_data_util=>orderby
      exporting
        it_order = it_order
      changing
        ct_data  = ET_ENTITYSET
        .
   ENDIF.
  endmethod.


  method RECIPEGROUPSET_CREATE_ENTITY.

  DATA: lv_groupid TYPE zrecipegroup-groupid,
        ls_data LIKE ER_ENTITY,
        ls_group TYPE zrecipegroup.


  io_data_provider->read_entry_data( IMPORTING es_data = ls_data ).


  SELECT MAX( GROUPID ) as GROUPID INTO lv_groupid FROM ZRECIPEGROUP WHERE WERKS = ls_data-werks.

  IF sy-subrc = 0.
    lv_groupid =  lv_groupid + 1.
  ELSE.
    lv_groupid = '00001'.
  ENDIF.

  ls_group-werks = ls_data-werks.
  ls_group-groupid = lv_groupid.
  ls_group-text = ls_data-text.

  INSERT zrecipegroup FROM ls_group .

  IF sy-subrc = 0.
    ER_ENTITY = ls_group.
  ENDIF.
  endmethod.


  method RECIPEGROUPSET_DELETE_ENTITY.
DATA: lt_keys TYPE /IWBEP/T_MGW_TECH_PAIRS,
      ls_message  TYPE scx_t100key.
DATA: lv_werks TYPE werks_d,
      lv_groupid TYPE ZRECIPEGROUP-GROUPID,
      lv_count TYPE i.

FIELD-SYMBOLS: <ls_key> TYPE /IWBEP/S_MGW_TECH_PAIR.


lt_keys = IO_TECH_REQUEST_CONTEXT->GET_KEYS( ).

READ TABLE lt_keys WITH KEY name = 'WERKS'
      ASSIGNING <ls_key>.

  IF sy-subrc EQ 0.
      lv_werks = <ls_key>-value.
  ELSE.
      ls_message-msgid = 'SY'.
      ls_message-msgno = '002'.
      ls_message-attr1 = 'Plant ID is invalid'.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid = ls_message.
  ENDIF.


READ TABLE lt_keys WITH KEY name = 'GROUPID'
      ASSIGNING <ls_key>.

  IF sy-subrc EQ 0.
      lv_groupid = <ls_key>-value.
  ELSE.
      ls_message-msgid = 'SY'.
      ls_message-msgno = '002'.
      ls_message-attr1 = 'Group ID is invalid'.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid = ls_message.
  ENDIF.

  SELECT COUNT(*) FROM ZRECIPE INTO lv_count WHERE WERKS = lv_werks AND GROUPID = lv_groupid.
  IF lv_count = 0.
    DELETE FROM ZRECIPEGROUP WHERE WERKS = lv_werks AND GROUPID = lv_groupid.
  ELSE.
      ls_message-msgid = 'SY'.
      ls_message-msgno = '002'.
      ls_message-attr1 = 'Cannot delete the Group. It is in use'.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid = ls_message.
  ENDIF.
  endmethod.


  method RECIPEGROUPSET_GET_ENTITY.

DATA: lt_keys TYPE /IWBEP/T_MGW_TECH_PAIRS,
      ls_key TYPE /IWBEP/S_MGW_TECH_PAIR,
      lv_werks type werks_d,
      lv_groupid type zrecipegroup-groupid.


  lt_keys = IO_TECH_REQUEST_CONTEXT->GET_KEYS( ).

  READ TABLE lt_keys with key name = 'WERKS' INTO ls_key.
  lv_werks = ls_key-value.

  READ TABLE lt_keys with key name = 'GROUPID' INTO ls_key.
  lv_groupid = ls_key-value.


  SELECT SINGLE * FROM ZRECIPEGROUP INTO ER_ENTITY WHERE
    WERKS = lv_werks AND GROUPID = lv_groupid.

  endmethod.


  method recipegroupset_get_entityset.


    data: lv_werks type werks_d.
    data: ls_message TYPE scx_t100key.
    data: ls_filter_selopt like line of it_filter_select_options.
    FIELD-SYMBOLS: <fs_werks> TYPE /iwbep/s_cod_select_option.



    READ TABLE  it_filter_select_options  WITH TABLE KEY property = 'Werks' INTO ls_filter_selopt.
    IF sy-subrc EQ 0.
      READ TABLE ls_filter_selopt-select_options INDEX 1 ASSIGNING <fs_werks>.
      IF sy-subrc EQ 0.
          lv_werks = <fs_werks>-low.
      ENDIF.
    ENDIF.

    "CHECK AUTH PLANT

    IF me->has_auth_plant( lv_werks ) eq abap_false.

        ls_message-msgid = 'SY'.
        ls_message-msgno = '002'.
        ls_message-attr1 = 'No authorization'.
        ls_message-attr2 = lv_werks.
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            textid = ls_message.
        EXIT.
    ENDIF.

    data: lv_filter_string type string.

    lv_filter_string = iv_filter_string.

    me->substringof_to_like_str(
     changing iv_filter_string = lv_filter_string ).

    select * from zrecipegroup
      where (lv_filter_string)
      into table @et_entityset.

    if it_filter_select_options is not initial.

      call method /iwbep/cl_mgw_data_util=>filtering
        exporting
          it_select_options = it_filter_select_options
        changing
          ct_data           = et_entityset.

    endif.

    if it_order is not initial.
      call method /iwbep/cl_mgw_data_util=>orderby
        exporting
          it_order = it_order
        changing
          ct_data  = et_entityset.
    endif.

  endmethod.


  method RECIPEGROUPSET_UPDATE_ENTITY.
DATA: lt_keys TYPE /iwbep/t_mgw_tech_pairs,
      ls_data TYPE ZRECIPEGROUP.

  DATA: ls_message TYPE scx_t100key.

  DATA: lv_werks TYPE werks_d,
        lv_groupid LIKE ER_ENTITY-GROUPID.

  FIELD-SYMBOLS: <ls_key>    TYPE /iwbep/s_mgw_tech_pair.

  lt_keys = io_tech_request_context->get_keys( ).


  READ TABLE lt_keys WITH KEY name = 'WERKS'
      ASSIGNING <ls_key>.

  IF sy-subrc EQ 0.
      lv_werks = <ls_key>-value.
  ELSE.
      ls_message-msgid = 'SY'.
      ls_message-msgno = '002'.
      ls_message-attr1 = 'Plant ID is invalid'.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid = ls_message.
  ENDIF.

  READ TABLE lt_keys WITH KEY name = 'GROUPID'
      ASSIGNING <ls_key>.

  IF sy-subrc EQ 0.
      lv_groupid = <ls_key>-value.
  ELSE.
      ls_message-msgid = 'SY'.
      ls_message-msgno = '002'.
      ls_message-attr1 = 'Group ID is invalid'.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid = ls_message.
    ENDIF.

  io_data_provider->read_entry_data( IMPORTING es_data = ls_data ).

  MODIFY ZRECIPEGROUP FROM ls_data.

  IF sy-subrc ne 0.

    ls_message-msgid = 'SY'.
    ls_message-msgno = '002'.
    ls_message-attr1 = 'Cannot find the Group'.

    RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid = ls_message.

  ENDIF.

  ER_ENTITY = ls_data.

  endmethod.


  method RECIPEHTCSET_GET_ENTITY.
**try.
*CALL METHOD SUPER->RECIPEHTCSET_GET_ENTITY
*  EXPORTING
*    IV_ENTITY_NAME          =
*    IV_ENTITY_SET_NAME      =
*    IV_SOURCE_NAME          =
*    IT_KEY_TAB              =
**    io_request_object       =
**    io_tech_request_context =
*    IT_NAVIGATION_PATH      =
**  importing
**    er_entity               =
**    es_response_context     =
*    .
**  catch /iwbep/cx_mgw_busi_exception.
**  catch /iwbep/cx_mgw_tech_exception.
**endtry.
  endmethod.


  method RECIPEINGRDTSET_GET_ENTITYSET.


    data: lv_werks type werks_d.
    data: ls_message TYPE scx_t100key.
    data: ls_filter_selopt like line of it_filter_select_options.
    FIELD-SYMBOLS: <fs_werks> TYPE /iwbep/s_cod_select_option.



    READ TABLE  it_filter_select_options  WITH TABLE KEY property = 'Werks' INTO ls_filter_selopt.
    IF sy-subrc EQ 0.
      READ TABLE ls_filter_selopt-select_options INDEX 1 ASSIGNING <fs_werks>.
      IF sy-subrc EQ 0.
          lv_werks = <fs_werks>-low.
      ENDIF.
    ENDIF.

    "CHECK AUTH PLANT

    IF me->has_auth_plant( lv_werks ) eq abap_false.

        ls_message-msgid = 'SY'.
        ls_message-msgno = '002'.
        ls_message-attr1 = 'No authorization'.
        ls_message-attr2 = lv_werks.
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            textid = ls_message.
        EXIT.
    ENDIF.

     SELECT * FROM ZI_RECIPEINGREDIENT INTO CORRESPONDING FIELDS OF TABLE @ET_ENTITYSET
      WHERE (IV_FILTER_STRING).
  endmethod.


  method RECIPEPHOTOSET_GET_ENTITY.

  endmethod.


  method recipeset_create_entity.

    data: ls_data   like er_entity,
          ls_recipe type zrecipe,
          ls_message TYPE scx_t100key,
          ls_recipeingrdt TYPE zrecipeingrdt.


    data: lv_lastnum type zrecipeplant-lastnum,
          lv_id type zrecipe-recipeid,
          lv_orig_id type zrecipe-recipeid,
          lv_tstamp  type timestamp.

*    try.
*        call method cl_system_uuid=>if_system_uuid_static~create_uuid_c32
*          receiving
*            uuid = lv_id.
*
*      catch cx_uuid_error .
*
**      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
**              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*
*    endtry.



    io_data_provider->read_entry_data( importing es_data = ls_data ).

    "Get Recipe ID
    SELECT SINGLE LASTNUM FROM ZRECIPEPLANT WHERE WERKS = @ls_data-werks INTO @lv_lastnum.
    IF sy-subrc eq 0.
      lv_lastnum = lv_lastnum + 1.
    ELSE.
      ls_message-attr1 = 'Cannot Generate New Recipe ID - Error Detected During Creation.'.
      ls_message-msgid = 'SY'.
      ls_message-msgno = '002'.

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid = ls_message.
    ENDIF.

    get time stamp field lv_tstamp.

    lv_orig_id = ls_data-recipeid.

    call function 'LOCATION_GET_PLANT_CURRENCY'
      exporting
        i_werks = ls_data-werks
      importing
        o_waers = ls_recipe-waers
*   EXCEPTIONS
*       INVALID_PLANT                  = 1
*       VALUATION_AREA_NOT_FOUND       = 2
*       BUKRS_NOT_FOUND                = 3
*       NO_CURRENCY_AVAILABLE          = 4
*       OTHERS  = 5
      .
    if sy-subrc <> 0.
* Implement suitable error handling here
    endif.

      ls_recipe-mandt = sy-mandt.
      CONCATENATE ls_data-werks lv_lastnum INTO lv_id.
      ls_recipe-recipeid = lv_id.
      ls_recipe-werks = ls_data-werks.
      ls_recipe-name = ls_data-name.
      ls_recipe-groupid = ls_data-groupid.
      ls_recipe-locationid = ls_data-locationid.
      ls_recipe-ekorg = ls_data-ekorg.
      ls_recipe-vlink = ls_data-vlink.
      ls_recipe-BPRME = 'UN'.
      ls_recipe-ISSUBMAT = ls_data-ISSUBMAT.
      ls_recipe-peinh = ls_data-peinh.
      ls_recipe-createdby = sy-uname.
      ls_recipe-createdon = lv_tstamp.

      insert zrecipe from ls_recipe.

      update zrecipeplant SET lastnum = lv_lastnum WHERE WERKS = ls_data-werks.

    if lv_orig_id is not initial.

      SELECT SINGLE * FROM zrecipeimg WHERE WERKS = @ls_data-werks AND RECIPEID = @lv_orig_id INTO @DATA(ls_recipeimg).
      IF sy-subrc = 0.
         ls_recipeimg-recipeid = lv_id.
         INSERT zrecipeimg FROM ls_recipeimg.
      ENDIF.

      SELECT SINGLE * FROM zrecipeversion WHERE WERKS = @ls_data-werks AND RECIPEID = @lv_orig_id INTO @DATA(ls_recipeversion).
      IF sy-subrc = 0.
         ls_recipeversion-recipeid = lv_id.
         ls_recipeversion-versionid = '0000'.
         INSERT zrecipeversion FROM ls_recipeversion.
      ENDIF.

      SELECT * FROM zrecipeingrdt WHERE WERKS = @ls_data-werks AND RECIPEID = @lv_orig_id
        AND versionid = ( SELECT MAX( versionid ) FROM zrecipeingrdt WHERE WERKS = @ls_data-werks AND RECIPEID = @lv_orig_id )
        INTO TABLE @DATA(lt_recipeingrdt).
      IF sy-subrc = 0.
        LOOP AT lt_recipeingrdt INTO ls_recipeingrdt.
          ls_recipeingrdt-recipeid = lv_id.
          ls_recipeingrdt-versionid = '0000'.

          INSERT zrecipeingrdt FROM ls_recipeingrdt.

        ENDLOOP.
      ENDIF.

    endif.

    if sy-subrc = 0.
      er_entity = ls_data.
    endif.

  endmethod.


  method RECIPESET_DELETE_ENTITY.

  DATA: lt_keys TYPE /IWBEP/T_MGW_TECH_PAIRS,
        ls_key TYPE /IWBEP/S_MGW_TECH_PAIR,
        ls_message TYPE scx_t100key,
        l_count type i,
        l_name TYPE ZRECIPE-name,
        l_werks type Werks_D,
        l_recipeid type ZRECIPE-RecipeID.

  lt_keys = IO_TECH_REQUEST_CONTEXT->GET_KEYS( ).

  READ TABLE lt_keys with key name = 'WERKS' INTO ls_key.
  l_werks = ls_key-value.

  READ TABLE lt_keys with key name = 'RECIPEID' INTO ls_key.
  l_recipeid = ls_key-value.

  IF l_werks IS NOT INITIAL and l_recipeid IS NOT INITIAL.
    SELECT COUNT(*) INTO l_count FROM ZRECIPEINGRDT WHERE WERKS = l_werks AND RECIPEID = l_recipeid.

    IF l_count gt 0.
      SELECT SINGLE Name FROM ZRECIPE  INTO l_name WHERE WERKS = l_werks AND RECIPEID = l_recipeid.

      CONCATENATE 'Cannot delete Recipe ID:' l_recipeid '-' l_name ' is in use' INTO ls_message-attr1 SEPARATED BY space.
      ls_message-msgid = 'SY'.
      ls_message-msgno = '002'.

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid = ls_message.
    ELSE.

      DELETE FROM ZRECIPE WHERE WERKS = l_werks AND RECIPEID = l_recipeid.

    ENDIF.
  ENDIF.


  endmethod.


  method RECIPESET_GET_ENTITY.
DATA: lt_keys TYPE /IWBEP/T_MGW_TECH_PAIRS,
      ls_key TYPE /IWBEP/S_MGW_TECH_PAIR,
      lv_werks type werks_d,
      lv_recipeid TYPE ZRECIPE-RECIPEID.


  lt_keys = IO_TECH_REQUEST_CONTEXT->GET_KEYS( ).
  READ TABLE lt_keys with key name = 'WERKS' INTO ls_key.
  lv_werks = ls_key-value.

  READ TABLE lt_keys with key name = 'RECIPEID' INTO ls_key.
  lv_recipeid = ls_key-value.


  WITH
  +LATESTVER AS (
    SELECT v1~* FROM ZRECIPEVERSION as v1
      LEFT JOIN ZRECIPEVERSION as v2 ON ( v1~werks = v2~werks AND v1~recipeid = v2~recipeid AND v1~versionid < v2~versionid )
      WHERE v2~versionid IS NULL
   ),
   +RECIPE AS (
     SELECT a~*, l~TEXT as LOCATIONTXT, g~TEXT as GROUPTXT,
          v~PRICEPERUNIT, v~COSTPERUNIT FROM ZRECIPE as a
       LEFT OUTER JOIN ZRECIPELOC as l ON a~werks = l~werks AND
         a~locationid = l~locationid
       LEFT OUTER JOIN ZRECIPEGROUP as g ON a~werks = g~werks AND a~groupid = g~groupid
       LEFT OUTER JOIN +LATESTVER as v ON a~werks = v~werks AND a~recipeid = v~recipeid


   )

   SELECT * FROM +RECIPE
   WHERE WERKS = @lv_werks AND RECIPEID = @lv_recipeid
   INTO CORRESPONDING FIELDS OF @ER_ENTITY.

 ENDWITH.

  endmethod.


  method recipeset_get_entityset.

    data: lv_werks type werks_d.
    data: ls_message TYPE scx_t100key.
    data: ls_filter_selopt like line of it_filter_select_options.
    FIELD-SYMBOLS: <fs_werks> TYPE /iwbep/s_cod_select_option.



    READ TABLE  it_filter_select_options  WITH TABLE KEY property = 'Werks' INTO ls_filter_selopt.
    IF sy-subrc EQ 0.
      READ TABLE ls_filter_selopt-select_options INDEX 1 ASSIGNING <fs_werks>.
      IF sy-subrc EQ 0.
          lv_werks = <fs_werks>-low.
      ENDIF.
    ENDIF.

    "CHECK AUTH PLANT

    IF me->has_auth_plant( lv_werks ) eq abap_false.

        ls_message-msgid = 'SY'.
        ls_message-msgno = '002'.
        ls_message-attr1 = 'No authorization'.
        ls_message-attr2 = lv_werks.
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            textid = ls_message.
        EXIT.
    ENDIF.


    data: lv_filter_string type string.
    lv_filter_string = iv_filter_string.

    me->substringof_to_like_str(
     changing iv_filter_string = lv_filter_string ).

    "REPLACE ALL OCCURRENCES OF 'Name' IN lv_FILTER_STRING WITH 'a~Name'.
    "REPLACE ALL OCCURRENCES OF 'Werks' IN lv_FILTER_STRING WITH 'a~Werks'.
    "REPLACE ALL OCCURRENCES OF 'GroupID' IN lv_FILTER_STRING WITH 'a~GroupID'.


    with
    +latestver as (
      select v1~* from zrecipeversion as v1
        left join zrecipeversion as v2 on ( v1~werks = v2~werks and v1~recipeid = v2~recipeid and v1~versionid < v2~versionid )
        where v2~versionid is null AND v1~werks = @lv_werks
     ),
     +recipe as (
       select a~*, l~text as locationtxt, g~text as grouptxt,
           v~priceperunit, v~costperunit, v~profitperunit from zrecipe as a
         inner join zrecipeloc as l on a~werks = l~werks and
           a~locationid = l~locationid
         inner join zrecipegroup as g on a~werks = g~werks and a~groupid = g~groupid
         "left outer join +latestver as v on a~werks = v~werks and a~recipeid = v~recipeid
         inner join ZRECIPEVERSION as b ON a~werks = b~werks AND a~RECIPEID = b~RECIPEID
         inner join +LATESTVER as v ON b~werks = v~werks AND b~recipeid = v~recipeid AND b~VERSIONID = v~VERSIONID


     )
     select * from +recipe
     where (lv_filter_string)
     into corresponding fields of table @et_entityset.

    if it_filter_select_options is not initial.

      call method /iwbep/cl_mgw_data_util=>filtering
        exporting
          it_select_options = it_filter_select_options
        changing
          ct_data           = et_entityset.

    endif.

    if it_order is not initial.
      call method /iwbep/cl_mgw_data_util=>orderby
        exporting
          it_order = it_order
        changing
          ct_data  = et_entityset.
    endif.

  endmethod.


  method RECIPESET_UPDATE_ENTITY.

    DATA: ls_entity LIKE er_entity,
          ls_data TYPE ZCL_ZRECIPECOST_ODATA_MPC=>TS_RECIPE,
          ls_recipe TYPE ZRECIPE,
          ls_message TYPE scx_t100key.

    DATA: l_werks TYPE werks_d,
          l_recipeid TYPE zrecipe-recipeid.

    io_data_provider->read_entry_data( IMPORTING es_data = ls_data ).

    io_tech_request_context->get_converted_keys(
      IMPORTING
         es_key_values = ls_entity ).

    l_werks = ls_entity-werks.
    l_recipeid = ls_entity-recipeid.

    MOVE-CORRESPONDING ls_data TO ls_recipe.

    call function 'LOCATION_GET_PLANT_CURRENCY'
      exporting
        i_werks = ls_data-werks
      importing
        o_waers = ls_recipe-waers
*   EXCEPTIONS
*       INVALID_PLANT                  = 1
*       VALUATION_AREA_NOT_FOUND       = 2
*       BUKRS_NOT_FOUND                = 3
*       NO_CURRENCY_AVAILABLE          = 4
*       OTHERS  = 5
      .
    if sy-subrc <> 0.
* Implement suitable error handling here
    endif.

    ls_recipe-BPRME = 'UN'.
    ls_recipe-changedby = sy-uname.
    get time stamp field ls_recipe-changedon.

    UPDATE ZRECIPE FROM ls_recipe.
    IF sy-subrc ne 0.
       CONCATENATE 'Recipe ID: ' ls_recipe-RecipeID ' - Error Detected During Update.' INTO ls_message-attr1 SEPARATED BY space.
      ls_message-msgid = 'SY'.
      ls_message-msgno = '002'.

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid = ls_message.
    ENDIF.


    ER_ENTITY = ls_data.

  endmethod.


  method RECIPEVERSIONSET_GET_ENTITY.

    DATA: lt_keys TYPE /IWBEP/T_MGW_TECH_PAIRS,
      ls_key TYPE /IWBEP/S_MGW_TECH_PAIR,
      lv_werks type werks_d,
      lv_recipeid TYPE ZRECIPEVERSION-RECIPEID,
      lv_versionid TYPE zrecipeversion-VERSIONID.

  lt_keys = IO_TECH_REQUEST_CONTEXT->GET_KEYS( ).

  READ TABLE lt_keys with key name = 'WERKS' INTO ls_key.
  lv_werks = ls_key-value.

  READ TABLE lt_keys with key name = 'RECIPEID' INTO ls_key.
  lv_recipeid = ls_key-value.

  READ TABLE lt_keys with key name = 'VERSIONID' INTO ls_key.
  lv_versionid = ls_key-value.

  SELECT SINGLE * FROM ZRECIPEVERSION as a
     WHERE a~WERKS = @lv_werks AND a~RECIPEID = @lv_recipeid AND a~VERSIONID = @lv_versionid
    INTO CORRESPONDING FIELDS OF @ER_ENTITY.
  endmethod.


  method RECIPEVERSIONSET_GET_ENTITYSET.

    data: lv_werks type werks_d.
    data: ls_message TYPE scx_t100key.
    data: ls_filter_selopt like line of it_filter_select_options.
    FIELD-SYMBOLS: <fs_werks> TYPE /iwbep/s_cod_select_option.



    READ TABLE  it_filter_select_options  WITH TABLE KEY property = 'Werks' INTO ls_filter_selopt.
    IF sy-subrc EQ 0.
      READ TABLE ls_filter_selopt-select_options INDEX 1 ASSIGNING <fs_werks>.
      IF sy-subrc EQ 0.
          lv_werks = <fs_werks>-low.
      ENDIF.
    ENDIF.

    "CHECK AUTH PLANT

    IF me->has_auth_plant( lv_werks ) eq abap_false.

        ls_message-msgid = 'SY'.
        ls_message-msgno = '002'.
        ls_message-attr1 = 'No authorization'.
        ls_message-attr2 = lv_werks.
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            textid = ls_message.
        EXIT.
    ENDIF.

  DATA: lv_filter_string TYPE STRING.

  lv_filter_string = IV_FILTER_STRING.

   me->SUBSTRINGOF_TO_LIKE_STR(
    CHANGING IV_FILTER_STRING = lv_filter_string ).

    SELECT * FROM ZRECIPEVERSION
      WHERE (LV_FILTER_STRING)
      INTO CORRESPONDING FIELDS OF TABLE @et_entityset.
  endmethod.


  method SIDEGROUPMENUSET_GET_ENTITYSET.

    DATA: LS_ENTITYSET LIKE LINE OF ET_ENTITYSET.

    LS_ENTITYSET-ID = 'G001'.
    LS_ENTITYSET-NAME = 'Recipe Management'.
    LS_ENTITYSET-ICON = 'sap-icon://course-book'.

    APPEND LS_ENTITYSET TO ET_ENTITYSET.

    LS_ENTITYSET-ID = 'G002'.
    LS_ENTITYSET-NAME = 'Reporting'.
    LS_ENTITYSET-ICON = 'sap-icon://manager-insight'.

    APPEND LS_ENTITYSET TO ET_ENTITYSET.

    LS_ENTITYSET-ID = 'SAPG1'.
    LS_ENTITYSET-NAME = 'SAPCC Management'.
    LS_ENTITYSET-ICON = 'sap-icon://sap-logo-shape'.

    APPEND LS_ENTITYSET TO ET_ENTITYSET.



  endmethod.


  method SIDEITEMMENUSET_GET_ENTITYSET.

    DATA: lv_so_id     TYPE bapi_epm_so_id,
          ls_key_tab   TYPE /iwbep/s_mgw_name_value_pair.
    DATA: LS_ENTITYSET LIKE LINE OF ET_ENTITYSET.


    READ TABLE it_key_tab INTO ls_key_tab WITH KEY name = 'ID'.
    IF sy-subrc = 0.
      lv_so_id = ls_key_tab-value.
    ENDIF.

    CASE lv_so_id.
      WHEN 'G001'.
        LS_ENTITYSET-ID = 'S001'.
        LS_ENTITYSET-GROUPID = lv_so_id.
        LS_ENTITYSET-NAME = 'Recipes'.
        LS_ENTITYSET-ICON = 'sap-icon://crm-service-manager'.
        LS_ENTITYSET-TARGET = 'RECIPES'.
        APPEND LS_ENTITYSET TO ET_ENTITYSET.


        LS_ENTITYSET-ID = 'S003'.
        LS_ENTITYSET-GROUPID = lv_so_id.
        LS_ENTITYSET-NAME = 'Image Editor'.
        LS_ENTITYSET-ICON = 'sap-icon://image-viewer'.
        LS_ENTITYSET-TARGET = 'IMAGEEDITOR'.
        APPEND LS_ENTITYSET TO ET_ENTITYSET.

      WHEN 'G002'.

        LS_ENTITYSET-ID = 'S001'.
        LS_ENTITYSET-GROUPID = lv_so_id.
        LS_ENTITYSET-NAME = 'Price/Cost/Profit Range'.
        LS_ENTITYSET-ICON = 'sap-icon://monitor-payments'.
        LS_ENTITYSET-TARGET = 'RPTRANGE'.
        APPEND LS_ENTITYSET TO ET_ENTITYSET.

        LS_ENTITYSET-ID = 'S002'.
        LS_ENTITYSET-GROUPID = lv_so_id.
        LS_ENTITYSET-NAME = 'Costly Recipe'.
        LS_ENTITYSET-ICON = 'sap-icon://monitor-payments'.
        LS_ENTITYSET-TARGET = 'RPTCOSTLY'.
        APPEND LS_ENTITYSET TO ET_ENTITYSET.

      WHEN 'SAPG1'.
        LS_ENTITYSET-ID = 'SAP01'.
        LS_ENTITYSET-GROUPID = lv_so_id.
        LS_ENTITYSET-NAME = 'Set Plant To Purch. Org'.
        LS_ENTITYSET-ICON = 'sap-icon://course-program'.
        LS_ENTITYSET-TARGET = 'PLANT'.
        APPEND LS_ENTITYSET TO ET_ENTITYSET.
*
*
*        LS_ENTITYSET-ID = 'S003'.
*        LS_ENTITYSET-GROUPID = lv_so_id.
*        LS_ENTITYSET-NAME = 'Group'.
*        LS_ENTITYSET-ICON = 'sap-icon://group'.
*        LS_ENTITYSET-TARGET = 'GROUP'.
*        APPEND LS_ENTITYSET TO ET_ENTITYSET.

    ENDCASE.


  endmethod.


  method STATISTICSET_GET_ENTITYSET.

    DATA: BEGIN OF ls_datatemp.
             INCLUDE TYPE ZCL_ZRECIPECOST_ODATA_MPC=>TS_STATISTIC.
    DATA:    RECIPEID TYPE ZRECIPEVERSION-RECIPEID,
             VERSIONID TYPE ZRECIPEVERSION-VERSIONID.
    DATA:  END OF ls_datatemp.


    DATA: lt_datatemp LIKE STANDARD TABLE OF ls_datatemp.

    DATA: l_statid TYPE STRING,
          l_werks TYPE werks_d,
          l_filter1 TYPE STRING,
          l_filter2 TYPE STRING.

    DATA: ls_message TYPE scx_t100key.

    DATA: lt_filters  TYPE  /iwbep/t_mgw_select_option,
          ls_filter   TYPE /iwbep/s_mgw_select_option,
          ls_so TYPE  /iwbep/s_cod_select_option.

    lt_filters = io_tech_request_context->get_filter( )->get_filter_select_options( ).

    READ TABLE lt_filters WITH TABLE KEY property = 'STATID' INTO ls_filter.
    IF sy-subrc EQ 0.
      LOOP AT ls_filter-select_options INTO ls_so.
        l_statid = ls_so-low.
      ENDLOOP.
    ENDIF.

    READ TABLE lt_filters WITH TABLE KEY property = 'WERKS' INTO ls_filter.
    IF sy-subrc EQ 0.
      LOOP AT ls_filter-select_options INTO ls_so.
        l_werks = ls_so-low.
      ENDLOOP.
    ENDIF.

    READ TABLE lt_filters WITH TABLE KEY property = 'FILTER1' INTO ls_filter.
    IF sy-subrc EQ 0.
      LOOP AT ls_filter-select_options INTO ls_so.
        l_filter1 = ls_so-low.
      ENDLOOP.
    ENDIF.
    READ TABLE lt_filters WITH TABLE KEY property = 'FILTER2' INTO ls_filter.
    IF sy-subrc EQ 0.
      LOOP AT ls_filter-select_options INTO ls_so.
        l_filter2 = ls_so-low.
      ENDLOOP.
    ENDIF.


    "CHECK AUTH PLANT
    IF me->has_auth_plant( l_werks ) eq abap_false.

        ls_message-msgid = 'SY'.
        ls_message-msgno = '002'.
        ls_message-attr1 = 'No authorization'.
        ls_message-attr2 = l_werks.
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            textid = ls_message.

    ENDIF.

    CASE l_statid.
      WHEN 'RecipeByGroup'.

        SELECT 'RecipeByGroup' as StatID, g~Werks, g~TEXT as LABEL, COUNT( a~recipeid ) as VALUE, g~GroupID as SECONDID FROM
          ZRECIPEGROUP as g LEFT OUTER JOIN ZRECIPE as a ON a~werks = g~werks AND a~groupid = g~groupid
          WHERE g~werks = @l_werks
          GROUP BY g~Werks, g~TEXT , g~GroupID
          INTO CORRESPONDING FIELDS OF TABLE @ET_ENTITYSET.


         if it_filter_select_options is not initial.

           call method /iwbep/cl_mgw_data_util=>filtering
             exporting
               it_select_options = it_filter_select_options
             changing
               ct_data           = et_entityset.

         endif.

      WHEN 'CostlyRecipe'.
         SELECT 'CostlyRecipe' as StatID, a~Werks,a~RECIPEID, a~NAME as LABEL, DIVISION( v~COSTPERUNIT , v~PRICEPERUNIT , 2 ) * 100 as VALUE, v~versionid FROM ZRECIPE as a
          INNER JOIN ZRECIPEVERSION as v ON a~werks = v~werks AND a~recipeid = v~recipeid
          WHERE a~werks = 'PPHS' and v~PRICEPERUNIT > 0
          ORDER BY v~recipeid, v~versionid DESCENDING
           INTO CORRESPONDING FIELDS OF TABLE @lt_datatemp.

         DELETE ADJACENT DUPLICATES FROM lt_datatemp COMPARING RECIPEID.
         MOVE-CORRESPONDING lt_datatemp TO ET_ENTITYSET.


          if it_filter_select_options is not initial.

            call method /iwbep/cl_mgw_data_util=>filtering
              exporting
                it_select_options = it_filter_select_options
              changing
                ct_data           = et_entityset.

          endif.

      WHEN 'SellPriceByGroup'.

        with
          +latestver as (
            select v1~* from zrecipeversion as v1
            left join zrecipeversion as v2 on ( v1~werks = v2~werks and v1~recipeid = v2~recipeid and v1~versionid < v2~versionid )
            where v2~versionid is null
          ),
          +recipe as (
            SELECT 'SellPriceByGroup' as StatID, g~Werks, g~TEXT as LABEL, COUNT( a~recipeid ) as VALUE, g~GroupID as SECONDID
                FROM ZRECIPEGROUP as g LEFT OUTER JOIN ZRECIPE as a ON a~werks = g~werks AND a~groupid = g~groupid
                 INNER JOIN ZRECIPEVERSION as b ON a~werks = b~werks AND a~RECIPEID = b~RECIPEID
                 INNER JOIN +LATESTVER as v ON b~werks = v~werks AND b~recipeid = v~recipeid AND b~VERSIONID = v~VERSIONID
                 WHERE g~werks = @l_werks and v~priceperunit between @l_filter1 and @l_filter2
                 GROUP BY g~Werks, g~TEXT , g~GroupID
         )
       	 select * from +recipe ORDER BY VALUE DESCENDING
       	 INTO CORRESPONDING FIELDS OF TABLE @ET_ENTITYSET.

     WHEN 'CostByGroup'.

        with
          +latestver as (
            select v1~* from zrecipeversion as v1
            left join zrecipeversion as v2 on ( v1~werks = v2~werks and v1~recipeid = v2~recipeid and v1~versionid < v2~versionid )
            where v2~versionid is null
          ),
          +recipe as (
            SELECT 'CostByGroup' as StatID, g~Werks, g~TEXT as LABEL, COUNT( a~recipeid ) as VALUE, g~GroupID as SECONDID
                FROM ZRECIPEGROUP as g LEFT OUTER JOIN ZRECIPE as a ON a~werks = g~werks AND a~groupid = g~groupid
                 INNER JOIN ZRECIPEVERSION as b ON a~werks = b~werks AND a~RECIPEID = b~RECIPEID
                 INNER JOIN +LATESTVER as v ON b~werks = v~werks AND b~recipeid = v~recipeid AND b~VERSIONID = v~VERSIONID
                 WHERE g~werks = @l_werks and v~costperunit between @l_filter1 and @l_filter2
                 GROUP BY g~Werks, g~TEXT , g~GroupID
         )
       	 select * from +recipe ORDER BY VALUE DESCENDING
       	 INTO CORRESPONDING FIELDS OF TABLE @ET_ENTITYSET.

    WHEN 'ProfitByGroup'.

        with
          +latestver as (
            select v1~* from zrecipeversion as v1
            left join zrecipeversion as v2 on ( v1~werks = v2~werks and v1~recipeid = v2~recipeid and v1~versionid < v2~versionid )
            where v2~versionid is null
          ),
          +recipe as (
            SELECT 'ProfitByGroup' as StatID, g~Werks, g~TEXT as LABEL, COUNT( a~recipeid ) as VALUE, g~GroupID as SECONDID
                FROM ZRECIPEGROUP as g LEFT OUTER JOIN ZRECIPE as a ON a~werks = g~werks AND a~groupid = g~groupid
                 INNER JOIN ZRECIPEVERSION as b ON a~werks = b~werks AND a~RECIPEID = b~RECIPEID
                 INNER JOIN +LATESTVER as v ON b~werks = v~werks AND b~recipeid = v~recipeid AND b~VERSIONID = v~VERSIONID
                 WHERE g~werks = @l_werks and v~profitperunit between @l_filter1 and @l_filter2
                 GROUP BY g~Werks, g~TEXT , g~GroupID
         )
       	 select * from +recipe ORDER BY VALUE DESCENDING
       	 INTO CORRESPONDING FIELDS OF TABLE @ET_ENTITYSET.


    ENDCASE.



*** The module for $top and $skip Query Options
     CALL METHOD /iwbep/cl_mgw_data_util=>paging
       EXPORTING
         is_paging = is_paging
       CHANGING
         ct_data   = et_entityset.

*** The module for Orderby condition
     CALL METHOD /iwbep/cl_mgw_data_util=>orderby
       EXPORTING
         it_order = it_order
       CHANGING
         ct_data  = et_entityset.

  endmethod.


  method SUBSTRINGOF_TO_LIKE_STR.

    DATA: regex TYPE REF TO cl_abap_regex.
    DATA: l_VALUE TYPE STRING,
          l_FIELD TYPE STRING,
          l_SUBSTRINGOF TYPE STRING,
          l_LIKE TYPE STRING.


    CREATE OBJECT regex
    EXPORTING
      pattern      =  'substringof\s\(\s''([\w|\s]+)''\s,\s(\w+)\s\)'
      simple_regex = abap_false.

    DATA(lo_matcher) = regex->create_matcher( text = IV_FILTER_STRING ).

    WHILE lo_matcher->find_next( ) = 'X'.
      l_SUBSTRINGOF  = lo_matcher->get_submatch( 0 ).
      l_FIELD =  lo_matcher->get_submatch( 2 ).
      l_VALUE =  lo_matcher->get_submatch( 1 ).
      TRANSLATE l_VALUE TO UPPER CASE.

      l_LIKE = |{ l_FIELD } LIKE '%{ l_VALUE }%'|.

      REPLACE ALL OCCURRENCES OF l_SUBSTRINGOF IN IV_FILTER_STRING WITH l_LIKE.

    ENDWHILE.

  endmethod.
ENDCLASS.
