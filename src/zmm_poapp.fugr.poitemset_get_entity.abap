FUNCTION POITEMSET_GET_ENTITY.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PONUMBER) TYPE  EBELN
*"     VALUE(POITEM) TYPE  EBELP
*"  EXPORTING
*"     VALUE(FM_ENTITY) TYPE  ZTS_POITEM
*"----------------------------------------------------------------------

DATA: lx_po TYPE REF TO z_mm_po,
      lx_poitem TYPE REF TO z_mm_poitem,
      lt_poitem TYPE TABLE OF REF TO z_mm_poitem.

CREATE OBJECT lx_po
  EXPORTING i_ponumber = PONUMBER.

IF sy-subrc = 0.
  lt_poitem = lx_po->get_items( ).
  LOOP AT lt_poitem INTO lx_poitem.
    CHECK lx_poitem->po_item = POITEM.
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
  ENDLOOP.

ENDIF.



ENDFUNCTION.
