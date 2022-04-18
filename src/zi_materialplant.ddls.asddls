@AbapCatalog.sqlViewName: 'ZMATPLANT'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Material Plant'
define view ZI_MATERIALPLANT as select from I_MaterialPlant
{
    key Plant as Werks,
    key Material as Matnr,    
    _Material.MaterialGroup as matkl,
    _Material._MaterialGroup._Text[1:Language = $session.system_language].MaterialGroupText as matkltx,
    _Material.MaterialType as Mtart,
    _MaterialText[1:Language = $session.system_language].MaterialName as maktx 
}
