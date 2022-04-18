FUNCTION POSET_GET_ENTITYSET.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      FMFILTER STRUCTURE  SELOPT
*"      FM_ENTITIES STRUCTURE  ZTS_PURCHASEORDER
*"----------------------------------------------------------------------
DATA: lx_po   type ref to z_mm_po,
      lt_pos  type table of ref to z_mm_po,
      ls_data TYPE ZTS_PURCHASEORDER.

call method z_mm_po=>get_pending_approval
        receiving
          return = lt_pos.

loop at lt_pos into lx_po.

   check lx_po->po_number ne ''.
   check lx_po->po_number in fmfilter.
   ls_data-purchaseorderid = lx_po->po_number.

    " Here we fill the entity data to be returned.
    ls_data-destinationplant = lx_po->get_dest_plant_text( ).
    ls_data-purchasegroup = lx_po->get_pgroup_text( ).
    ls_data-previousapprovalcomments = lx_po->comments.
    ls_data-totalvalue = lx_po->total_value.
    ls_data-advancepercentage = lx_po->advance_percentage.
    ls_data-incoterms = lx_po->incoterms.
    ls_data-currency = lx_po->currency.
    ls_data-paymentterms = lx_po->get_payment_term_text( ).
    ls_data-createdby = lx_po->get_created_by( ).
    ls_data-date = lx_po->creation_date.
    ls_data-status = lx_po->get_status( ).
    append ls_data to FM_ENTITIES.

endloop.

ENDFUNCTION.
