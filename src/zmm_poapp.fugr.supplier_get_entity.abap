FUNCTION SUPPLIER_GET_ENTITY.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PONUMBER) TYPE  EBELN
*"  EXPORTING
*"     VALUE(FM_ENTITY) TYPE  ZTS_SUPPLIER
*"----------------------------------------------------------------------

DATA: lx_po    type ref to z_mm_po,
      lx_sup   type ref to z_mm_supplier.

 create object lx_po
          exporting
            i_ponumber = PONUMBER.
 lx_sup = lx_po->get_supplier( ).

 FM_ENTITY-supplierid = lx_sup->supplier_id.
 FM_ENTITY-name = lx_sup->name.
 FM_ENTITY-address = lx_sup->address.
 FM_ENTITY-email = lx_sup->email.
 FM_ENTITY-telephone = lx_sup->telephone.


ENDFUNCTION.
