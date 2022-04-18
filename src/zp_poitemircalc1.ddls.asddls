@AbapCatalog.sqlViewName: 'ZPPOITEMIRCALC1'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO Item Invoice Calc 1'
define view ZP_POITEMIRCALC1 as  select from ZP_POITEMIRDAT1 
{
  
  key PurchaseOrder,
  key PurchaseOrderItem,
  
  sum(InvoiceReceiptQty) as InvoiceReceiptQty,
  InvoiceCurrency,
  sum(InvoiceAmtInCoCodeCrcy) as InvoiceAmtInCoCodeCrcy
  
    
}

group by 
PurchaseOrder,
PurchaseOrderItem,
InvoiceCurrency
