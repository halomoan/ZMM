FUNCTION zmm_ariba_outbound.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(RFQ_NO) TYPE  EBELN
*"  EXPORTING
*"     VALUE(HEADER) TYPE  EKKO
*"  TABLES
*"      ITEM STRUCTURE  EKPO OPTIONAL
*"----------------------------------------------------------------------

  SELECT SINGLE * INTO header FROM ekko WHERE ebeln EQ rfq_no.

  SELECT * INTO TABLE item FROM ekpo WHERE ebeln EQ rfq_no.

ENDFUNCTION.
