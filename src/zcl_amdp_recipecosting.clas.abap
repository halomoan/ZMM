class ZCL_AMDP_RECIPECOSTING definition
  public
  final
  create public .

public section.
    INTERFACES: if_amdp_marker_hdb.
    CLASS-METHODS:
        GET_PLANT_MATERIAL
            AMDP OPTIONS READ-ONLY
            CDS SESSION CLIENT current
                    IMPORTING VALUE(IV_PURCHORG) TYPE STRING
                              VALUE(IV_PLANT) TYPE STRING
                              VALUE(IV_FILTER) TYPE STRING
                    EXPORTING VALUE(ET_MATERIAL) TYPE ZTT_RECIPEMATPRICE
            raising cx_amdp_error .
protected section.
private section.
ENDCLASS.



CLASS ZCL_AMDP_RECIPECOSTING IMPLEMENTATION.
    METHOD GET_PLANT_MATERIAL BY database procedure for hdb language sqlscript options read-only USING ZI_MATERIALPLANT ZI_MATERIALNETPRICE.


       IT_MATERIALNETPRICE = apply_filter ( ZI_MATERIALNETPRICE,:IV_PURCHORG);
       IT_LASTPURDATE = SELECT a.MATNR, MAX( datlb ) as datlb FROM ZI_MATERIALNETPRICE as a
                            GROUP BY a.MATNR;


       IT_LATESTMATNETPRICE = SELECT a.* FROM :IT_MATERIALNETPRICE as a INNER JOIN :IT_LASTPURDATE as b ON
                a.MATNR = b.MATNR  and a.datlb = b.datlb ;


       IT_MATERIALPLANT = apply_filter (ZI_MATERIALPLANT, :IV_PLANT);

       ET_MATERIAL =
        SELECT a.WERKS,a.MATNR,a.maktx, a.MATKL, a.matkltx, a.MTART,
            b.infnr,b.ekorg,b.esokz,b.EBELN,b.DATLB,b.BSTYP,b.WAERS,b.NETPR,b.PEINH,b.BPRME,b.ERDAT,b.ERNAM
        FROM :IT_MATERIALPLANT as a LEFT OUTER JOIN :IT_LATESTMATNETPRICE as b ON a.matnr = b.matnr ORDER BY a.matnr;


       ET_MATERIAL = apply_filter (:ET_MATERIAL, :IV_FILTER);


    endmethod.
ENDCLASS.
