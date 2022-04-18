FUNCTION SUPPLIER_GET_ENTITYSET.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PONUMBER) TYPE  EBELN
*"  TABLES
*"      FM_ENTITIES STRUCTURE  ZTS_SUPPLIER
*"----------------------------------------------------------------------

DATA: lx_po type ref to z_mm_po,
      lx_sup  type ref to z_mm_supplier,
      ls_data TYPE ZTS_SUPPLIER.

 create object lx_po
          exporting
            i_ponumber = PONUMBER.
 lx_sup = lx_po->get_supplier( ).

        ls_data-supplierid = lx_sup->supplier_id.
        ls_data-name = lx_sup->name.
        ls_data-address = lx_sup->address.
        ls_data-email = lx_sup->email.
        ls_data-telephone = lx_sup->telephone.
        append ls_data to FM_ENTITIES.


ENDFUNCTION.
