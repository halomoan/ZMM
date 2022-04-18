class ZCL_ZRECIPECOST_ODATA_MPC_EXT definition
  public
  inheriting from ZCL_ZRECIPECOST_ODATA_MPC
  create public .

public section.


  types:
    ty_t_recipeversion TYPE STANDARD TABLE OF ZCL_ZRECIPECOST_ODATA_MPC=>ts_recipeversion WITH DEFAULT KEY,
    ty_t_ingredient TYPE STANDARD TABLE OF ZCL_ZRECIPECOST_ODATA_MPC=>ts_recipeingrdt WITH DEFAULT KEY .

  types: BEGIN OF TS_RECIPE_DEEP.
            INCLUDE TYPE ZCL_ZRECIPECOST_ODATA_MPC=>ts_recipe.
            TYPES: versions TYPE ty_t_recipeversion,
         END OF TS_RECIPE_DEEP.
  types:
        BEGIN OF TS_RECIPEVERSION_DEEP.
            INCLUDE TYPE ZCL_ZRECIPECOST_ODATA_MPC=>ts_recipeversion.
            TYPES: Ingredients TYPE ty_t_ingredient,
        END OF TS_RECIPEVERSION_DEEP .

  methods DEFINE
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZRECIPECOST_ODATA_MPC_EXT IMPLEMENTATION.


  method DEFINE.
    super->define( ).

    DATA:
      lo_entity_type   TYPE REF TO /iwbep/if_mgw_odata_entity_typ,
      lo_property TYPE REF TO /iwbep/if_mgw_odata_property.

    lo_entity_type = model->get_entity_type( iv_entity_name = 'RecipePhoto' ).
    lo_entity_type->set_is_media( ).

    IF lo_entity_type IS BOUND.
      lo_property = lo_entity_type->get_property( iv_property_name = 'MimeType' ).
      lo_property->set_as_content_type( ).
    ENDIF.

    lo_entity_type = model->get_entity_type( iv_entity_name = 'RecipeHTC' ).
    lo_entity_type->set_is_media( ).

    IF lo_entity_type IS BOUND.
      lo_property = lo_entity_type->get_property( iv_property_name = 'MimeType' ).
      lo_property->set_as_content_type( ).
    ENDIF.

    lo_entity_type = model->get_entity_type( iv_entity_name = 'RecipeVersion' ).
    lo_entity_type->bind_structure( iv_structure_name  = 'ZCL_ZRECIPECOST_ODATA_MPC_EXT=>TS_RECIPEVERSION_DEEP' ).

*    lo_entity_type = model->get_entity_type( iv_entity_name = 'Recipe' ).
*    lo_entity_type->bind_structure( iv_structure_name  = 'ZCL_ZRECIPECOST_ODATA_MPC_EXT=>TS_RECIPETOVERTOINGRDT_DEEP' ).
  endmethod.
ENDCLASS.
