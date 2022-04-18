FUNCTION-POOL ZMM_MEREP1.

*--------------------------------------------------------------------*
* Pre-Definition of interfaces
*--------------------------------------------------------------------*
INTERFACE: lif_environment DEFERRED.

*--------------------------------------------------------------------*
* pre-definition of local classes
*--------------------------------------------------------------------*
CLASS: lcl_reporting_cnt_general DEFINITION DEFERRED.

*--------------------------------------------------------------------*
* used type pools
*--------------------------------------------------------------------*
TYPE-POOLS: slis, mmpur, icon.

*--------------------------------------------------------------------*
* local type definitions
*--------------------------------------------------------------------*
TYPES: lty_reporting_category TYPE i.

TYPES: lty_t_sorted_ekko TYPE SORTED TABLE OF ekko
                         WITH UNIQUE KEY ebeln,
       BEGIN OF lty_s_ekko_key,
         ebeln TYPE ekko-ebeln,
       END OF lty_s_ekko_key,

       lty_t_sorted_ekpo TYPE SORTED TABLE OF ekpo
                         WITH UNIQUE KEY ebeln ebelp,
       BEGIN OF lty_s_ekpo_key,
         ebeln TYPE ekpo-ebeln,
         ebelp TYPE ekpo-ebelp,
       END OF lty_s_ekpo_key,

       BEGIN OF lty_s_ekko_add,                             "823673
        superfield TYPE merep_super,
        ktwtr      TYPE merep_ktwtr,
       END OF lty_s_ekko_add,

       lty_t_sorted_eket TYPE SORTED TABLE OF eket
                         WITH UNIQUE KEY ebeln ebelp etenr,
       BEGIN OF lty_s_eket_key,
         ebeln TYPE eket-ebeln,
         ebelp TYPE eket-ebelp,
         etenr TYPE eket-etenr,
       END OF lty_s_eket_key,

       lty_t_sorted_ekkn TYPE SORTED TABLE OF ekkn
                         WITH UNIQUE KEY ebeln ebelp zekkn,
       BEGIN OF lty_s_ekkn_key,
         ebeln TYPE ekkn-ebeln,
         ebelp TYPE ekkn-ebelp,
         zekkn TYPE ekkn-zekkn,
       END OF lty_s_ekkn_key,

       lty_t_sorted_eine TYPE SORTED TABLE OF eine
                         WITH UNIQUE KEY infnr ekorg esokz werks,
       BEGIN OF lty_s_eine_key,
         infnr TYPE eine-infnr,
         ekorg TYPE eine-ekorg,
         esokz TYPE eine-esokz,
         werks TYPE eine-werks,
       END OF lty_s_eine_key,

       lty_t_sorted_gleine TYPE SORTED TABLE OF gleine
                           WITH UNIQUE KEY infnr ekorg esokz werks,
       BEGIN OF lty_s_gleine_key,
         infnr TYPE gleine-infnr,
         ekorg TYPE gleine-ekorg,
         esokz TYPE gleine-esokz,
         werks TYPE gleine-werks,
       END OF lty_s_gleine_key,

       lty_t_sorted_eina TYPE SORTED TABLE OF eina
                         WITH UNIQUE KEY infnr,
       BEGIN OF lty_s_eina_key,
         infnr TYPE eina-infnr,
       END OF lty_s_eina_key,

       lty_t_sorted_eipa TYPE SORTED TABLE OF merep_outtab_prhis
                         WITH UNIQUE KEY infnr ekorg esokz werks ebeln ebelp bedat,
       BEGIN OF lty_s_eipa_key,
         infnr TYPE eine-infnr,                             "1096331
         ekorg TYPE eine-ekorg,
         esokz TYPE eine-esokz,
         werks TYPE eine-werks,
         ebeln TYPE eipa-ebeln,
         ebelp TYPE eipa-ebelp,
         bedat TYPE eipa-bedat,                             "962086
       END OF lty_s_eipa_key,

       lty_t_sorted_tupel TYPE SORTED TABLE OF merep_outtab_quota_an
                           WITH UNIQUE KEY matnr werks,
       BEGIN OF lty_s_tupel_key,
         matnr TYPE tupel-matnr,
         werks TYPE tupel-werks,
       END OF lty_s_tupel_key,

       lty_t_sorted_equp TYPE SORTED TABLE OF equp
                         WITH UNIQUE KEY qunum qupos,
       BEGIN OF lty_s_equp_key,
         qunum TYPE equp-qunum,
         qupos TYPE equp-qupos,
       END OF lty_s_equp_key,

       lty_t_sorted_equk TYPE SORTED TABLE OF equk
                         WITH UNIQUE KEY matnr werks bdatu,
       BEGIN OF lty_s_equk_key,
         matnr TYPE equk-matnr,
         werks TYPE equk-werks,
         bdatu TYPE equk-bdatu,
       END OF lty_s_equk_key,

       lty_t_sorted_lfa1 TYPE SORTED TABLE OF lfa1
                         WITH UNIQUE KEY lifnr,
       BEGIN OF lty_s_lfa1_key,                             "#EC *
         lifnr TYPE lfa1-lifnr,
       END OF lty_s_lfa1_key,

       lty_t_sorted_lfm1 TYPE SORTED TABLE OF lfm1
                         WITH UNIQUE KEY lifnr ekorg,
       BEGIN OF lty_s_lfm1_key,
         lifnr TYPE lfm1-lifnr,
         ekorg TYPE lfm1-ekorg,
       END OF lty_s_lfm1_key,

       lty_t_sorted_merep_outtab_srv TYPE SORTED TABLE OF merep_outtab_srvdoc
                                     WITH UNIQUE KEY ebeln ebelp packno introw extrow,
       BEGIN OF lty_s_merep_outtab_srvdoc_key,
         ebeln  TYPE ebeln,
         ebelp  TYPE ebelp,
         packno TYPE packno,
         introw TYPE introw,
         extrow TYPE extrow,
       END OF lty_s_merep_outtab_srvdoc_key,

* Note 699776

       lty_t_sorted_essr TYPE SORTED TABLE OF essr
                         WITH UNIQUE KEY lblni,
       BEGIN OF lty_s_essr_key,
         lblni TYPE essr-lblni,
       END OF lty_s_essr_key,

       lty_t_sorted_ekbe TYPE SORTED TABLE OF ekbe
                          WITH UNIQUE KEY ebeln ebelp zekkn vgabe gjahr belnr buzei,

       BEGIN OF lty_s_ekbe_key,
         ebeln TYPE ekbe-ebeln,
         ebelp TYPE ekbe-ebelp,
         zekkn TYPE ekbe-zekkn,
         vgabe TYPE ekbe-vgabe,
         gjahr TYPE ekbe-gjahr,
         belnr TYPE ekbe-belnr,
         buzei TYPE ekbe-buzei,
       END OF lty_s_ekbe_key,

*--------------------------------------------------------------------*
* Component consumption - SAP ERP 6.0 EhP 4
*--------------------------------------------------------------------*
       lty_t_sorted_ekbe_sc TYPE SORTED TABLE OF ekbe_sc "EhP4 Comp. Consumption
                             WITH UNIQUE KEY ebeln ebelp gjahr belnr buzei line_id,

       BEGIN OF lty_s_ekbe_sc_key, "EhP4 Comp. Consumption
         ebeln   TYPE ebeln,
         ebelp   TYPE ebelp,
         gjahr   TYPE mjahr,
         belnr   TYPE mblnr,
         buzei   TYPE mblpo,
         line_id TYPE mb_line_id,
       END OF lty_s_ekbe_sc_key,

* Note 699776

       lty_t_sorted_ekbel TYPE SORTED TABLE OF ekbel
                          WITH UNIQUE KEY ebeln ebelp,

       lty_t_sorted_eban TYPE SORTED TABLE OF eban
                         WITH UNIQUE KEY banfn bnfpo,

       BEGIN OF lty_s_eban_key,
         banfn TYPE eban-banfn,
         bnfpo TYPE eban-bnfpo,
       END OF lty_s_eban_key,

       lty_t_sorted_frgadd TYPE SORTED TABLE OF merep_frgadd
                           WITH UNIQUE KEY ebeln ebelp,

       lty_t_sorted_ebkn TYPE SORTED TABLE OF ebkn
                         WITH UNIQUE KEY banfn bnfpo zebkn,

       lty_t_sorted_ekbes TYPE SORTED TABLE OF merep_ekbes
                          WITH UNIQUE KEY ebeln ebelp,

       BEGIN OF lty_s_ebkn_key,
         banfn TYPE ebkn-banfn,
         bnfpo TYPE ebkn-bnfpo,
         zebkn TYPE ebkn-zebkn,
       END OF lty_s_ebkn_key,

       lty_t_sorted_ekab TYPE SORTED TABLE OF ekab
                          WITH UNIQUE KEY konnr ktpnr ebeln ebelp,

       BEGIN OF lty_s_ekab_key,                             "1001282
         konnr TYPE ekab-konnr,
         ktpnr TYPE ekab-ktpnr,
         ebeln TYPE ekab-ebeln,
         ebelp TYPE ekab-ebelp,
       END OF lty_s_ekab_key,

       lty_t_sorted_eord TYPE SORTED TABLE OF eord
                         WITH UNIQUE KEY matnr werks zeord,

       BEGIN OF lty_s_eord_key,
         matnr TYPE eord-matnr,
         werks TYPE eord-werks,
         zeord TYPE eord-zeord,
       END OF lty_s_eord_key,

      lty_t_sorted_eord_me06 TYPE SORTED TABLE OF           "#EC *
                             merep_outtab_source_list
                             WITH UNIQUE KEY matnr werks,

       BEGIN OF lty_s_eord_me06_key,                        "#EC *
         matnr TYPE eord-matnr,
         werks TYPE eord-werks,
       END OF lty_s_eord_me06_key,

       lty_t_sorted_messages TYPE SORTED TABLE OF merep_outtab_messages
                                   WITH UNIQUE KEY ebeln ebelp etenr,

       lty_t_sorted_downpay  TYPE SORTED TABLE OF merep_outtab_downpay "GPFR Chorus
                                   WITH UNIQUE KEY ebeln ebelp,

       lty_t_sorted_authority TYPE SORTED TABLE OF merep_authority
                              WITH UNIQUE KEY ebeln ebelp,

       lty_t_outtab_ebanacc   TYPE STANDARD TABLE OF
                              merep_outtab_ebanacc,

       lty_t_outtab_schedlines TYPE STANDARD TABLE OF
                               merep_outtab_schedlines,

       lty_t_outtab_accounting TYPE STANDARD TABLE OF
                               merep_outtab_accounting,

       lty_t_outtab_compconsump TYPE STANDARD TABLE OF      "#EC *
                                merep_outtab_compconsump,

       lty_t_outtab_scrap       TYPE STANDARD TABLE OF      "Scrap EhP4
                                merep_outtab_scrap,

* Verdichtungstabellen
* Volumen, Gewicht
     BEGIN OF lty_t_verd_dat,                               "1001282
        werks     TYPE ekpo-werks,
        eindt     TYPE eket-eindt,
        uzeit     TYPE eket-uzeit,
        ebeln     TYPE ekko-ebeln,
        voleh     TYPE ekpo-voleh,
        volum     TYPE f,          "ekpo-volum ungenau (3 Nachkommast)
        volfehler TYPE c LENGTH 1, "Flag für fehlende Volumen-EH
        gewei     TYPE ekpo-gewei,
        ntgew     TYPE f,
        brgew     TYPE f,
        gewfehler TYPE c LENGTH 1, "Flag für fehlende Gewichts-EH
        anzanl    TYPE i,          "Anzahl Anlieferungen
        anzpos    TYPE i,          "Anzahl Positionen
      END OF lty_t_verd_dat,

       lty_t_sorted_verd_dat   TYPE STANDARD TABLE OF
                               lty_t_verd_dat,

       BEGIN OF lty_source_key,
         reswk TYPE eban-reswk,
         beswk TYPE eban-beswk,
         flief TYPE eban-flief,
         ekorg TYPE eban-ekorg,
         fname1 TYPE name1_gp,
       END OF lty_source_key,

       lty_t_environment TYPE STANDARD TABLE OF
                         REF TO lif_environment,

       BEGIN OF lty_material_key,
         matnr TYPE ekpo-matnr,
         txz01 TYPE ekpo-txz01,
       END OF lty_material_key,

       BEGIN OF lty_matkl_key,
         matkl TYPE t023t-matkl,
         wgbez TYPE t023t-wgbez,
       END OF lty_matkl_key,

       BEGIN OF lty_vendor_key,
         lifnr TYPE lfa1-lifnr,
         name1 TYPE lfa1-name1,
       END OF lty_vendor_key,

       BEGIN OF lty_s_document_key, "#EhP4 Outsourced Manufacturing
         ebeln TYPE ebeln,
         ebelp TYPE ebelp,
         bstyp TYPE bstyp,
         banfn TYPE banfn,
         bnfpo TYPE bnfpo,
         vbeln TYPE vbeln,
         rsnum TYPE rsnum,
         rspos TYPE rspos,
       END OF lty_s_document_key.

TYPES: BEGIN OF merep_hide.
INCLUDE TYPE ekko.
TYPES:   ebelp TYPE ekpo-ebelp,
         name1 TYPE addr1_val-name1,
         telfx TYPE lfa1-telfx,
         teltx TYPE lfa1-teltx,
         telx1 TYPE lfa1-telx1,
         land1 TYPE lfa1-land1,
         zeile TYPE sy-linno,
         seite TYPE sy-pagno,
         sel   TYPE c LENGTH 1,
         mahn  TYPE c LENGTH 1,
      END OF merep_hide.

TYPES: BEGIN OF  merep_outtab_reldoc.                       "1001282
INCLUDE TYPE ekab.
TYPES:   netwf TYPE ekabf-netwf,
      END OF  merep_outtab_reldoc.

* Data Privacy and Protection
TYPES:                                                      "v2119324
  BEGIN OF t_dpp_checked,
    lifnr         TYPE lifnr,
    kunnr         TYPE kunnr,
    bukrs         TYPE bukrs,
    xblck         TYPE cvp_xblck,
    auditor       TYPE cvp_auth_master,
    fallback      TYPE xfeld,
  END OF t_dpp_checked.                                     "^2119324
*--------------------------------------------------------------------*
* define constants
*--------------------------------------------------------------------*
CONSTANTS:
*--------------------------------------------------------------------*
* datablade handles.
*--------------------------------------------------------------------*
  c_handle_base       TYPE slis_handl VALUE '0001',
  c_handle_accounting TYPE slis_handl VALUE '0002',
  c_handle_schedules  TYPE slis_handl VALUE '0003',
  c_handle_source     TYPE slis_handl VALUE '0004',
  c_handle_downpay    TYPE slis_handl VALUE '0005',         "EhP4 DP
  c_handle_day        TYPE slis_handl VALUE '0006',     "#EC * "1001282
  c_handle_time       TYPE slis_handl VALUE '0007',     "#EC * "1001282
  c_handle_total      TYPE slis_handl VALUE '0008',     "#EC * "1001282
  c_handle_document   TYPE slis_handl VALUE '0009',     "#EC * "1001282
  c_handle_compcons   TYPE slis_handl VALUE '0010',
  c_handle_scrap      TYPE slis_handl VALUE '0011', "EhP4 Outs. Manuf.
  c_handle_subcon     TYPE slis_handl VALUE if_mmpur_subcon_reporting=>mc_scope_collapse,
  c_handle_subconexp  TYPE slis_handl VALUE if_mmpur_subcon_reporting=>mc_scope_expand,
  c_handle_sc_batch   TYPE slis_handl VALUE if_mmpur_subcon_reporting=>mc_scope_batch, "#EC *

*--------------------------------------------------------------------*
* categories
*--------------------------------------------------------------------*
  c_cat_unsupported   TYPE lty_reporting_category VALUE 0,
  c_cat_eban          TYPE lty_reporting_category VALUE 1,
  c_cat_eban_enjoy    TYPE lty_reporting_category VALUE 2,
  c_cat_purchdoc      TYPE lty_reporting_category VALUE 3,
  c_cat_srvdoc        TYPE lty_reporting_category VALUE 4,
  c_cat_infrec        TYPE lty_reporting_category VALUE 5,
  c_cat_eord          TYPE lty_reporting_category VALUE 6,
  c_cat_prhis         TYPE lty_reporting_category VALUE 7,
  c_cat_messages      TYPE lty_reporting_category VALUE 8,
  c_cat_quota         TYPE lty_reporting_category VALUE 9,
  c_cat_quota_an      TYPE lty_reporting_category VALUE 10,
  c_cat_eban_rel      TYPE lty_reporting_category VALUE 11,
  c_cat_purchdoc_rel  TYPE lty_reporting_category VALUE 12,
  c_cat_purchdoc_acc  TYPE lty_reporting_category VALUE 13,
  c_cat_eban_acc      TYPE lty_reporting_category VALUE 14,
  c_cat_eord_me06     TYPE lty_reporting_category VALUE 15,
  c_cat_rel_doc       TYPE lty_reporting_category VALUE 16,
  c_cat_exp_gr        TYPE lty_reporting_category VALUE 17, "1001282
  c_cat_downpay       TYPE lty_reporting_category VALUE 18, "EhP4 DP
  c_cat_subcon        TYPE lty_reporting_category VALUE 19, "EhP4 Outs. Manuf.
  c_cat_scrap         TYPE lty_reporting_category VALUE 21, "EhP4 Outs. Manuf.

*--------------------------------------------------------------------*
* local field constants
*--------------------------------------------------------------------*
  c_max_orewr_f       TYPE f  VALUE '9999999999999.99'.

*--------------------------------------------------------------------*
* Define global data objects
*--------------------------------------------------------------------*
DATA:

  gf_controller TYPE REF TO lcl_reporting_cnt_general,
  gf_manager    TYPE REF TO if_table_manager_mm,
  gt_list_top_of_page TYPE slis_t_listheader,               "1001282
  gt_dpp_checked TYPE TABLE OF t_dpp_checked,               "2119324
*--------------------------------------------------------------------*
* global output tables
*--------------------------------------------------------------------*
  gt_outtab_purchdoc     TYPE STANDARD TABLE OF merep_outtab_purchdoc,
  gt_outtab_purchdoc_rel TYPE STANDARD TABLE OF
  merep_outtab_purchdoc_rel,
  gt_outtab_schedlines   TYPE STANDARD TABLE OF merep_outtab_schedlines,
  gt_outtab_accounting   TYPE STANDARD TABLE OF merep_outtab_accounting,
  gt_outtab_eban         TYPE STANDARD TABLE OF merep_outtab_eban,
  gt_outtab_ebanacc      TYPE STANDARD TABLE OF merep_outtab_ebanacc,
  gt_outtab_eban_rel     TYPE STANDARD TABLE OF merep_outtab_ebanov,
  gt_outtab_srvdoc       TYPE STANDARD TABLE OF merep_outtab_srvdoc,
  gt_outtab_infrec       TYPE STANDARD TABLE OF merep_outtab_infrec,
  gt_eord                TYPE STANDARD TABLE OF eord,
  gt_outtab_source_list  TYPE STANDARD TABLE OF merep_outtab_source_list,
  gt_outtab_prhis        TYPE STANDARD TABLE OF merep_outtab_prhis,
  gt_outtab_messages     TYPE STANDARD TABLE OF merep_outtab_messages,
  gt_outtab_quota        TYPE STANDARD TABLE OF merep_outtab_quota,
  gt_outtab_quota_an     TYPE STANDARD TABLE OF merep_outtab_quota_an,
  gt_outtab_reldoc       TYPE STANDARD TABLE OF merep_outtab_reldoc, "1001282
  gt_outtab_exp_gr       TYPE STANDARD TABLE OF mere_outtab_me2v, "1001282
  gt_outtab_downpay      TYPE STANDARD TABLE OF merep_outtab_downpay, "EhP4 DP
  gt_outtab_compcons     TYPE STANDARD TABLE OF merep_outtab_compconsump, "#EC *
  gt_outtab_scrap        TYPE STANDARD TABLE OF merep_outtab_scrap,  "EhP4 Outs. Manuf.
  gt_outtab_subcon       TYPE STANDARD TABLE OF merep_outtab_subcon. "EhP4 Outs. Manuf.

* Direktwert zur Pruefung von Nettowertueberlaeufen         "633587
DATA:                                                       "633587

  maxwert TYPE gswrt VALUE '99999999999.99',                "633587
  refe1   TYPE p LENGTH 16 DECIMALS 3.                      "653899

DATA: gv_fsh_scon TYPE smp_dyntxt.
DEFINE call_env.
  create object l_env type lcl_env_&1.
  check l_env is bound.
  call method l_env->execute
    exporting
      im_fieldname = &2
      im_line      = im_wa.
END-OF-DEFINITION.

DEFINE valid_line.
  if not sy-subrc is initial.
    message id 'ME' type 'S' number '201'.
    exit.
  endif.
  if &1 is initial.
    message id 'ME' type 'S' number '201'.
    exit.
  endif.
END-OF-DEFINITION.
DATA: mo_arun_process TYPE REF TO cl_arun_subconpo_process,
      gv_refresh(1)   TYPE c.
*INCLUDE fmmexdir.
INCLUDE lmerepd01.
INCLUDE lmerepd02.
INCLUDE lmerepd03.
INCLUDE lmerepd04.
INCLUDE lmerepd05.
INCLUDE lmerepd06.
INCLUDE lmerepd07.
INCLUDE lmerepd21.
INCLUDE lmerepd22.
INCLUDE lmerepd23.
INCLUDE lmerepd24.
INCLUDE lmerepd25.
INCLUDE lmerepd26.
INCLUDE lmerepd27.
INCLUDE lmerepd28.
INCLUDE lmerepd29.
INCLUDE lmerepd30.
INCLUDE lmerepd31.
INCLUDE lmerepd32.
INCLUDE lmerepd33.
INCLUDE lmerepd34.
INCLUDE lmerepd35.
INCLUDE lmerepd36.
INCLUDE lmerepd37.
INCLUDE lmerepd38.
INCLUDE lmerepd39.
INCLUDE lmerepd40.
INCLUDE lmerepd43.
INCLUDE lmerepd08.
INCLUDE lmerepd09.
INCLUDE lmerepd10.
INCLUDE lmerepd11.
INCLUDE lmerepd12.
INCLUDE lmerepd13.
INCLUDE lmerepd14.
INCLUDE lmerepd15.
INCLUDE lmerepd16.
INCLUDE lmerepd18.
INCLUDE lmerepd19.
INCLUDE lmerepd20.
INCLUDE lmerepd41.                                          "1001282
INCLUDE lmerepd44. "lcl_datablade_subcon
INCLUDE lmerepd45. "lcl_reporting_cnt_subcon
* government procurement
INCLUDE lmerepd99.
