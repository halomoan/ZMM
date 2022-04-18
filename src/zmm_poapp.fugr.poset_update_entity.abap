FUNCTION POSET_UPDATE_ENTITY.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PONUMBER) TYPE  EBELN
*"     VALUE(FMACTION) TYPE  CHAR1
*"  EXPORTING
*"     VALUE(FMRETURN) TYPE  BAPIRET2
*"----------------------------------------------------------------------

 data:  lx_po     type ref to z_mm_po.

IF FMACTION = 'A'.
 create object lx_po
          exporting
            i_ponumber = PONUMBER.
        call method lx_po->set_approval
          receiving
            return = FMRETURN.

ELSEIF FMACTION = 'R'.
  create object lx_po
          exporting
            i_ponumber = PONUMBER.
        call method lx_po->set_rejected
          RECEIVING
            return = FMRETURN.
ENDIF.


ENDFUNCTION.
