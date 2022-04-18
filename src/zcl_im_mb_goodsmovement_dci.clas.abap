class ZCL_IM_MB_GOODSMOVEMENT_DCI definition
  public
  final
  create public .

public section.

*"* public components of class ZCL_IM_MB_GOODSMOVEMENT_DCI
*"* do not include other source files here!!!
  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_MB_GOODSMOVEMENT_DCI .
protected section.
*"* protected components of class ZCL_IM_MB_GOODSMOVEMENT_DCI
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_IM_MB_GOODSMOVEMENT_DCI
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_IM_MB_GOODSMOVEMENT_DCI IMPLEMENTATION.


  METHOD IF_EX_MB_GOODSMOVEMENT_DCI~SET_DCI.

    IF NOT i_dm07m-bsmng = i_dm07m-wemng.

      IF i_vm07m-elikz_old = 'X' AND i_dm07m-elikz_input = ' '.
        e_elikz = 'X'.
        e_elikz_input = 'X'.

        DATA: rc LIKE sy-subrc.
        CALL FUNCTION 'MB_CHECK_T160M'
          EXPORTING
            i_arbgb  = 'M7'
            i_msgnr  = '433'
            i_output = 'X'
          IMPORTING
            rc       = rc.
        sy-subrc = rc.

        IF sy-subrc <> 0.
          e_dci_msg = 'X'.
        ENDIF.

      ENDIF.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
