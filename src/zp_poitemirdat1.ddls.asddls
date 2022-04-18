@AbapCatalog.sqlViewName: 'ZPPOITEMIRDAT1'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO Item Invoice Data 1'
define view ZP_POITEMIRDAT1 as  select from I_PurchaseOrderHistory  
{
  
  key PurchaseOrder,
  key PurchaseOrderItem,
  
  
  
  case when DebitCreditCode = 'S'
          then Quantity
       else (-1 * Quantity)
  end as InvoiceReceiptQty,
    
  Currency as InvoiceCurrency,
  
  case when DebitCreditCode = 'S'
          then InvoiceAmtInCoCodeCrcy
       else (-1 * InvoiceAmtInCoCodeCrcy)
  end as InvoiceAmtInCoCodeCrcy
 
    
}

where PurchaseOrderTransactionType = '2' 
