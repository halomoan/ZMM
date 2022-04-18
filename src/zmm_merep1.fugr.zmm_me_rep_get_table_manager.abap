FUNCTION ZMM_ME_REP_GET_TABLE_MANAGER .
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IM_SERVICE) LIKE  SY-REPID OPTIONAL
*"     VALUE(IM_SCOPE) TYPE  CHAR40 OPTIONAL
*"     VALUE(IM_FORCE_TM) TYPE  XFELD OPTIONAL
*"  EXPORTING
*"     REFERENCE(EX_MANAGER) TYPE REF TO IF_TABLE_MANAGER_MM
*"--------------------------------------------------------------------

  DATA: l_active  TYPE mmpur_bool VALUE cl_mmpur_constants=>no,
        l_factory TYPE REF TO lcl_factory,
        l_service TYPE sy-repid,
        l_alv(10).

  CLEAR ex_manager.

  l_service = im_service.
  IF l_service IS INITIAL.
    l_service = sy-cprog.
  ENDIF.

  CREATE OBJECT l_factory.
* _force alv to display
   IMPORT l_alv FROM MEMORY ID 'ZALV' .
  IF l_alv  = 'ALV'.
    l_active = 'X'.
  ELSE.
  l_active = l_factory->is_active( im_service = l_service
                                   im_scope   = im_scope ).
  ENDIF.

*  CHECK l_active = cl_mmpur_constants=>yes.
  IF l_active = cl_mmpur_constants=>yes OR                         "new for ERP 1.0 PA
     im_force_tm = cl_mmpur_constants=>yes.

    IF gf_manager IS INITIAL.
      CREATE OBJECT gf_manager TYPE lcl_table_manager.
    ENDIF.
    ex_manager = gf_manager.
  ENDIF.

ENDFUNCTION.
