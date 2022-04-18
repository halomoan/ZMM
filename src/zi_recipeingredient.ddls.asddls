@AbapCatalog.sqlViewName: 'ZIRECIPEINGRDT'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Recipe Ingredients'
define view ZI_RECIPEINGREDIENT as select from zrecipeingrdt as a inner join I_MaterialPlant as b on a.werks = b.Plant and a.matnr = b.Material {
    key a.werks,
    key a.recipeid,
    key a.versionid, 
    a.matnr,
    b._MaterialText[1:Language = $session.system_language].MaterialName as maktx,
    b._Material._MaterialGroup.MaterialGroup as Matkl,
    b._Material._MaterialGroup._Text[1:Language = $session.system_language].MaterialGroupText as matkltx,
    a.ebeln,
    a.waers,
    a.netpr,
    a.peinh,
    a.bprme,
    a.calccost,
    a.qtyused
}
