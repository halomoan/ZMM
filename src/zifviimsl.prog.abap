*----------------------------------------------------------------------*
*   INCLUDE IFVIIMSL                                                   *
*----------------------------------------------------------------------*
*   Select-Options für MM-Report zur Suche nach Bestellungen,          *
*   die auf Immobilienobjekt kontiert wurden                           *
*----------------------------------------------------------------------*


* Begin of SPC_953041
*TABLES: VIOB01,                        "Wirtschaftseinheiten
*        VIOB02,                        "Grundstücke
*        VIOB03,                        "Gebäude
*        VIMI01,                        "Mieteinheiten
*        VIMIMV,                        "Mietverträge
*        VIVW01,                        "Verwaltungsverträge
*        VICN01,                        "allg. Immobilienvertrag
*        VIAK03,                        "Abrechnungseinheit
*        RFVILSP,
*        ionr.
tables: rfviexso.

SELECTION-SCREEN BEGIN OF BLOCK IMMO WITH FRAME TITLE text-p02. "#EC *
PARAMETERS:     I_BUKRS   LIKE rfviexso-BUKRS.
SELECT-OPTIONS: s_obart   for rfviexso-sobart no intervals,
                S_SWENR   FOR rfviexso-SWENR,
                S_SGENR   FOR rfviexso-SGENR,
                S_SGRNR   FOR rfviexso-SGRNR,
                S_SMENR   FOR rfviexso-SMENR,
                S_SMIVE   FOR rfviexso-SMIVE,
                S_SVWNR   FOR rfviexso-SVWNR,
                S_RECNNR  FOR rfviexso-RECNNR,
                S_SNKSL   FOR rfviexso-SNKSL,
                S_SEMPSL  FOR rfviexso-SEMPSL.
* End of SPC_953041

* Übergabe des Zeitraums als Select-Option. Wird im FB in
* die beiden Parameter P_DVON und P_DBIS der LDB umkopiert.
select-options: s_vonbis  for rfviexso-dvonbis no-extension. "SPC_953041

*SELECTION-SCREEN BEGIN OF LINE.
*  SELECTION-SCREEN COMMENT 1(31) TEXT-P01.
*  SELECTION-SCREEN POSITION 33.
* Begin of  SPC_953041
    PARAMETERS: P_DVON    LIKE  rfviexso-DVONDAT no-display.
*  SELECTION-SCREEN POSITION 58.
    PARAMETERS: P_DBIS    LIKE  rfviexso-DBISDAT no-display.
*SELECTION-SCREEN END OF LINE.

PARAMETERS:     P_STICH LIKE rfviexso-dstchtag.
* End of SPC_953041
SELECTION-SCREEN END OF BLOCK IMMO.

**----------------------------------------------------------------------
*at selection-screen on help-request for s_obart.
**----------------------------------------------------------------------
*
*append fviot_con_objtyp-wirtschaftseinheit to lt_allow_obart.
*append fviot_con_objtyp-gebaeude to lt_allow_obart.
*append fviot_con_objtyp-grundstueck to lt_allow_obart.
*append fviot_con_objtyp-mieteinheit to lt_allow_obart.
*append fviot_con_objtyp-mietvertrag to lt_allow_obart.
*append fviot_con_objtyp-abrechnungseinheit to lt_allow_obart.
*append fviot_con_objtyp-verwaltungsvertrag to lt_allow_obart.
*append fviot_con_objtyp-vertrag to lt_allow_obart.
*
*CALL FUNCTION 'HELP_REQUEST_FOR_OBART'
**    EXPORTING
**         TABNAME                    = 'TBO00'
**         FIELDNAME                  = 'OBART'
**         SETTLEMENT_RECEIVER_ONLY   = ' '
**         SETTLEMENT_RECEIVER_ACTUAL = 'X'
**         SETTLEMENT_RECEIVER_PLAN   = ' '
**         SETTLEMENT_RECEIVER_POR    = ' '
**         SETTLEMENT_RECEIVER_PLANT  = ' '
*    IMPORTING
*         SELECT_VALUE               = s_obart-low
*    TABLES
*         T_ONLY_OBART               = lt_allow_obart
*          .
