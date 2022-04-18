class ZCL_IM_MB_MIGO_ITEM_BADI definition
  public
  final
  create public .

*"* public components of class ZCL_IM_MB_MIGO_ITEM_BADI
*"* do not include other source files here!!!
public section.

  interfaces IF_EX_MB_MIGO_ITEM_BADI .
protected section.
*"* protected components of class ZCL_IM_MB_MIGO_ITEM_BADI
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_IM_MB_MIGO_ITEM_BADI
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_IM_MB_MIGO_ITEM_BADI IMPLEMENTATION.


METHOD if_ex_mb_migo_item_badi~item_modify.
  DATA : v_txz01 TYPE ekpo-txz01,
         v_matnr TYPE ekpo-matnr,
         v_maktx TYPE makt-maktx,
         v_spras TYPE ekko-spras.
  CLEAR : v_txz01,v_matnr,v_maktx,v_spras.
  IF is_goitem-ebeln IS INITIAL.
    SELECT SINGLE maktx INTO v_maktx FROM makt WHERE matnr = is_goitem-matnr
                                                 AND spras = sy-langu.
    IF is_goitem-sgtxt IS INITIAL.
      e_item_text = v_maktx.
    ELSE.
      e_item_text = is_goitem-sgtxt.
    ENDIF.
  ELSE.
    SELECT SINGLE matnr INTO v_matnr FROM ekpo WHERE ebeln = is_goitem-ebeln
                                                 AND ebelp = is_goitem-ebelp.
    IF v_matnr IS INITIAL.
      SELECT SINGLE txz01 INTO v_txz01 FROM ekpo WHERE ebeln = is_goitem-ebeln
                                                   AND ebelp = is_goitem-ebelp.
      IF is_goitem-sgtxt IS INITIAL.
        e_item_text = v_txz01.
      ELSE.
        e_item_text = is_goitem-sgtxt.
      ENDIF.
    ELSE.
      SELECT SINGLE spras INTO v_spras FROM ekko WHERE ebeln = is_goitem-ebeln.
      SELECT SINGLE maktx INTO v_maktx FROM makt WHERE matnr = v_matnr
                                                   AND spras = v_spras.
      IF is_goitem-sgtxt IS INITIAL.
        e_item_text = v_maktx.
      ELSE.
        e_item_text = is_goitem-sgtxt.
      ENDIF.
    ENDIF.
  ENDIF.
ENDMETHOD.
ENDCLASS.
