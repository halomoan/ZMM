@AbapCatalog.sqlViewName: 'ZVPOITEMFACT1'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@Analytics.dataCategory: #FACT
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO Item Fact 1'
define view ZV_POITEM_FACT1 as select from I_PurchaseOrderItem as POItem
    association [1..1] to ZP_POITEMIRCALC1 as _POItemIR on POItem.PurchaseOrder = _POItemIR.PurchaseOrder and POItem.PurchaseOrderItem = _POItemIR.PurchaseOrderItem
{
  key PurchaseOrder,
  key PurchaseOrderItem,
  
  
  DocumentCurrency,  
  NetAmount,
  
  _POItemIR.InvoiceCurrency,
  _POItemIR.InvoiceAmtInCoCodeCrcy,
  _POItemIR.InvoiceReceiptQty
  
  
}
