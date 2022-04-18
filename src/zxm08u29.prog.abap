*&---------------------------------------------------------------------*
*&  Include           ZXM08U29
*&---------------------------------------------------------------------*
  DATA : v_txz01 TYPE ekpo-txz01,
         v_matnr TYPE ekpo-matnr,
         v_maktx TYPE makt-maktx,
         v_spras TYPE ekko-spras.

  CLEAR : v_txz01,v_matnr,v_maktx,v_spras.

  SELECT SINGLE matnr INTO v_matnr FROM ekpo WHERE ebeln = tab_drseg-ebeln
                                               AND ebelp = tab_drseg-ebelp.
  IF v_matnr IS INITIAL.
    SELECT SINGLE txz01 INTO v_txz01 FROM ekpo WHERE ebeln = tab_drseg-ebeln
                                                 AND ebelp = tab_drseg-ebelp.
    IF tab_drseg-sgtxt IS INITIAL.
      e_sgtxt = v_txz01.
    ELSE.
      e_sgtxt = tab_drseg-sgtxt.
    ENDIF.
  ELSE.
    SELECT SINGLE spras INTO v_spras FROM ekko WHERE ebeln = tab_drseg-ebeln.
    SELECT SINGLE maktx INTO v_maktx FROM makt WHERE matnr = v_matnr
                                                 AND spras = v_spras.
    IF tab_drseg-sgtxt IS INITIAL.
      e_sgtxt = v_maktx.
    ELSE.
      e_sgtxt = tab_drseg-sgtxt.
    ENDIF.
  ENDIF.
