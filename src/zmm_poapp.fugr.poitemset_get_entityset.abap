FUNCTION POITEMSET_GET_ENTITYSET.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PONUMBER) TYPE  EBELN
*"  TABLES
*"      FM_ENTITIES STRUCTURE  ZTS_POITEM
*"----------------------------------------------------------------------

DATA: lx_po TYPE REF TO z_mm_po,
      lx_poitem TYPE REF TO z_mm_poitem,
      lt_poitem TYPE TABLE OF REF TO z_mm_poitem,
      fm_entity TYPE ZTS_POITEM.

CREATE OBJECT lx_po
  EXPORTING i_ponumber = PONUMBER.

IF sy-subrc = 0.
  lt_poitem = lx_po->get_items( ).
  LOOP AT lt_poitem INTO lx_poitem.

    CLEAR FM_ENTITY.

    concatenate lx_poitem->po_number lx_poitem->po_item into fm_entity-purchaseorderitemid.

    fm_entity-material = lx_poitem->material_id.
    fm_entity-mat_text = lx_poitem->material.
    fm_entity-quantity = lx_poitem->quantity.
    fm_entity-unit = lx_poitem->unit.
    fm_entity-convertionbase = lx_poitem->box_conversion.
    fm_entity-netprice = lx_poitem->net_price.
    fm_entity-netvalue = lx_poitem->net_value.
    fm_entity-currency = lx_po->currency.
    fm_entity-deliverydate = lx_poitem->delivery_date.
    fm_entity-itemtext = lx_poitem->itemtext.
    fm_entity-deliveryplant = lx_poitem->delivery_plant.
    APPEND fm_entity TO fm_entities.
  ENDLOOP.

ENDIF.



ENDFUNCTION.
