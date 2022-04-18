@AbapCatalog.sqlViewName: 'ZMATNETPRICE'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Material Net Price'
define view ZI_MATERIALNETPRICE as select from eina as a inner join eine as e on a.infnr = e.infnr inner join mara on a.matnr = mara.matnr {
    
    e.infnr, --Number of purchasing info record
    e.ekorg, --Purchasing organization
    e.esokz, --Purchasing info record category
    e.werks, --Plant
    a.matnr,    --Material Number
    mara.matkl, --Material Group
    mara.mtart, --Material Type
    e.ebeln, --Purchasing Document Number
    e.datlb, --Document Date
    e.bstyp, --Document Category    
    e.waers, --Currency Key
    e.netpr, --Net Price
    e.peinh, --Price unit    
    e.bprme, --Order Price Unit (Purchasing)
    e.erdat, --Date on which the record was created
    e.ernam  --Name of Person who Created the Object
    
}

where a.loekz = '' and e.loekz = '' and e.netpr > 0
