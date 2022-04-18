*&---------------------------------------------------------------------*
*&  Include           ZMMRGB_0008_TOP
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&  T Y P E S
*&---------------------------------------------------------------------*
TYPE-POOLS: slis.

TYPES: BEGIN OF gty_input,
         bukrs      TYPE bukrs,                  "Company Code
         werks      TYPE ekpo-werks,             "Plant
         ekorg      TYPE ekorg,                  "Purchasing Organization
         matkl      TYPE matkl,                  "Material Group
         lifnr      TYPE lifnr,                  "Vendor
         date       TYPE sy-datum,               "Effective date
       END OF gty_input.

TYPES: BEGIN OF gty_ekpo.
         INCLUDE structure ekpo.
TYPES:   znetpr TYPE ekpo-netpr,     "zbprei,              "Net price on Base UoM
       END OF gty_ekpo,

       gty_t_ekko TYPE STANDARD TABLE OF ekko,
       gty_t_ekpo TYPE STANDARD TABLE OF gty_ekpo,
       gty_t_eket TYPE STANDARD TABLE OF eket,
       gty_t_eina TYPE STANDARD TABLE OF eina,    "PIR General data
       gty_t_eine TYPE STANDARD TABLE OF eine,    "PIR Organization data
       gty_t_a017 TYPE STANDARD TABLE OF a017,
       gty_t_a018 TYPE STANDARD TABLE OF a018,
       gty_t_konh TYPE STANDARD TABLE OF konh.

TYPES: BEGIN OF gty_konp.
         INCLUDE structure konp.
TYPES:   zlifnr LIKE konp-lifnr,
         zkonwa LIKE konp-konwa,
         zkbetr TYPE konp-kbetr, "zbprei,
         infnr  LIKE eina-infnr,
       END OF gty_konp,

       gty_t_konp TYPE STANDARD TABLE OF gty_konp.

* Type for report item 01
TYPES: BEGIN OF gty_rep_01.
         include structure ZMM_PROD_SERV_ANALYSIS.
         include structure ZMM_PSA_REP_01.
TYPES:  END OF gty_rep_01,

       gty_t_rep_01 TYPE STANDARD TABLE OF gty_rep_01.

TYPES: BEGIN OF gty_comp,                          "Common company code properties
        bukrs TYPE t001-bukrs,
        butxt TYPE t001-butxt,
        waers TYPE t001-waers,
       END OF gty_comp,

       gty_t_comp TYPE STANDARD TABLE OF gty_comp,

       BEGIN OF gty_vend,                          "Vendor properties
        lifnr TYPE lfa1-lifnr,
        name1 TYPE lfa1-name1,
       END OF gty_vend,

       gty_t_vend TYPE STANDARD TABLE OF gty_vend,

       gty_matnr TYPE makt,                         "Material properties
       gty_t_matnr TYPE STANDARD TABLE OF gty_matnr.

*&---------------------------------------------------------------------*
*&  C O N S T A N T S
*&---------------------------------------------------------------------*
CONSTANTS: c_x                                VALUE 'X',
           c_b                                VALUE 'B'.

*&---------------------------------------------------------------------*
*&  D A T A
*&---------------------------------------------------------------------*
DATA: gs_input  TYPE gty_input,
      g_yr_diff TYPE i,                           "Year difference between date from and date to
      gs_rep_01 TYPE gty_rep_01,
      gs_comp   TYPE gty_comp,

      gv_matnr_base_uom TYPE mara-meins,          "Material Base unit of measurement
      gv_convto_base_uom TYPE p DECIMALS 5,       "Material conversion from Order Price Unit to Base UOM

*&---------------------------------------------------------------------*
*&  T A B L E S
*&---------------------------------------------------------------------*
      gt_ekko   TYPE gty_t_ekko,
      gt_ekpo   TYPE gty_t_ekpo,
      gt_eket   TYPE gty_t_eket,
      gt_eina   TYPE gty_t_eina,
      gt_eine   TYPE gty_t_eine,
      gt_konh   TYPE gty_t_konh,
      gt_konp   TYPE gty_t_konp,
      gt_rep_01 TYPE gty_t_rep_01,
      gt_comp   TYPE gty_t_comp,
      gt_a0xx   TYPE TABLE OF a017,

      "Error msg table of Conversion
      T_ERRMSG(255) occurs 100 with header line,

*&---------------------------------------------------------------------*
*&  A L V
*&---------------------------------------------------------------------*
      gt_fieldcat_rep   TYPE lvc_t_fcat,
      gs_filedcat_rep   TYPE lvc_s_fcat,
      gs_layout_rep     TYPE lvc_s_layo,
      gt_sort_rep       TYPE lvc_t_sort.
