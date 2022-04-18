*&---------------------------------------------------------------------*
*& Report  ZMMRGB_0010
*&---------------------------------------------------------------------*
* Title      : Savings Report
* Author     : Willy Angkasa
* Date       : 27.04.2018
* Purpose	   : Report to calculate savings in puchasing
*----------------------------------------------------------------------*
* Modification Log
* Date         Author   Num Transport Req no.  Description
* -----------  -------  ---------------------  ------------------------*
* 27.04.2018   ZDEVAMS   P30K909486            Initial creation
*----------------------------------------------------------------------*
REPORT zmmrgb_0010 NO STANDARD PAGE HEADING.

*--------------------------------------------------------------------*
* Data Declaration
*--------------------------------------------------------------------*
* Tables
TABLES: ekko, ekpo, mara.

* Class
DATA: gcl_table        TYPE REF TO cl_salv_table,
      gcl_layout       TYPE REF TO cl_salv_layout,
      gcl_func         TYPE REF TO cl_salv_functions,
      gcl_coltable     TYPE REF TO cl_salv_columns_table,
      gcl_column       TYPE REF TO cl_salv_column,
      gcl_column_table TYPE REF TO cl_salv_column_table,
      gcl_aggr         TYPE REF TO cl_salv_aggregations,
      gcl_events       TYPE REF TO cl_salv_events_table.

* Types
TYPES: BEGIN OF gy_report,
         ekorg    TYPE ekko-ekorg,
         werks    TYPE ekpo-werks,
         ebeln    TYPE ekko-ebeln,
         ebelp    TYPE ekpo-ebelp,
         bedat    TYPE ekko-bedat,
         waers    TYPE ekko-waers,
         matkl    TYPE mara-matkl,
         wgbez60  TYPE t023t-wgbez60,
         matnr    TYPE ekpo-matnr,
         maktx    TYPE makt-maktx,
         buom     TYPE mara-meins,
         meins    TYPE ekpo-meins,
         menge    TYPE ekpo-menge,
         mbuom    TYPE ekpo-menge,
         netwr    TYPE ekpo-netwr,
         netpr    TYPE ekpo-netpr,
         netpr_b  TYPE ekpo-netpr,
         type     TYPE char10,
         infnr    TYPE ekpo-infnr,
         source   TYPE char10,
         lifnr    TYPE ekko-lifnr,
         name1    TYPE lfa1-name1,
         datab    TYPE a017-datab,
         datbi    TYPE a017-datbi,
         pirccy   TYPE konp-konwa,
         kbetr_b  TYPE konp-kbetr,
         sav_unit TYPE ekpo-netpr,
         sav_tot  TYPE ekpo-netwr,
       END OF gy_report.

TYPES: BEGIN OF gy_po,
         ebeln TYPE ekko-ebeln,
         ebelp TYPE ekpo-ebelp,
         ekorg TYPE ekko-ekorg,
         bedat TYPE ekko-bedat,
         lifnr TYPE ekko-lifnr,
         waers TYPE ekko-waers,
         werks TYPE ekpo-werks,
         matnr TYPE ekpo-matnr,
         meins TYPE ekpo-meins,
         menge TYPE ekpo-menge,
         netpr TYPE ekpo-netpr,
         netwr TYPE ekpo-netwr,
         infnr TYPE ekpo-infnr,
         peinh TYPE ekpo-peinh,
       END OF gy_po.

TYPES: BEGIN OF gy_pir,
         infnr TYPE eina-infnr,
         matnr TYPE eina-matnr,
         matkl TYPE eina-matkl,
         lifnr TYPE eina-lifnr,
         meins TYPE eina-meins,
         umrez TYPE eina-umrez,
         umren TYPE eina-umren,
         lmein TYPE eina-lmein,
         kschl TYPE a017-kschl,
         ekorg TYPE a017-ekorg,
         datbi TYPE a017-datbi,
         datab TYPE a017-datab,
         knumh TYPE a017-knumh,
         werks TYPE a017-werks,
       END OF gy_pir.

TYPES: BEGIN OF gy_mara,
         matnr TYPE mara-matnr,
         matkl TYPE mara-matkl,
         meins TYPE mara-meins,
       END OF gy_mara.

TYPES: BEGIN OF gy_lfa1,
         lifnr TYPE lfa1-lifnr,
         name1 TYPE lfa1-name1,
       END OF gy_lfa1.

* Internal Table
DATA: gt_report        TYPE TABLE OF gy_report,
      gt_po            TYPE TABLE OF gy_po,
      gt_eina          TYPE TABLE OF gy_pir,
      gt_konp          TYPE TABLE OF konp,
      gt_mara          TYPE TABLE OF gy_mara,
      gt_t023t         TYPE TABLE OF t023t,
      gt_makt          TYPE TABLE OF makt,
      gt_lfa1          TYPE TABLE OF gy_lfa1,
      gt_zmm_pir_ariba TYPE TABLE OF zmm_pir_ariba.

* Work Area
DATA: gs_current TYPE gy_report,
      gs_header  TYPE gy_report,
      gs_report  TYPE gy_report.

*--------------------------------------------------------------------*
* Selection Screen
*--------------------------------------------------------------------*
* General data
SELECTION-SCREEN BEGIN OF BLOCK gdata WITH FRAME TITLE text-h01.
SELECT-OPTIONS: s_ekorg FOR ekko-ekorg OBLIGATORY,
                s_werks FOR ekpo-werks,
                s_matkl FOR mara-matkl,
                s_matnr FOR mara-matnr,
                s_bedat FOR ekko-bedat NO-EXTENSION OBLIGATORY,
                s_ebeln FOR ekko-ebeln.
SELECTION-SCREEN END OF BLOCK gdata.
SELECTION-SCREEN BEGIN OF BLOCK gdopt WITH FRAME TITLE text-h02.
PARAMETERS: cb_cross AS CHECKBOX,
            cb_ariba AS CHECKBOX,
            cb_other AS CHECKBOX DEFAULT abap_true.
SELECTION-SCREEN END OF BLOCK gdopt.

*--------------------------------------------------------------------*
* Start of selection
*--------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM get_data.
  PERFORM process_data.
  PERFORM display_report.

*--------------------------------------------------------------------*
*   FORM get_data
*--------------------------------------------------------------------*
FORM get_data.
  FREE: gt_po, gt_eina, gt_konp, gt_mara,
        gt_zmm_pir_ariba, gt_lfa1, gt_makt, gt_t023t.

  SELECT k~ebeln p~ebelp k~ekorg k~bedat k~lifnr
         k~waers p~werks p~matnr p~meins p~menge
         p~netpr p~netwr p~infnr p~peinh
    FROM ekko AS k INNER JOIN ekpo AS p
      ON k~ebeln EQ p~ebeln
        INTO TABLE gt_po
          WHERE k~ebeln IN s_ebeln
            AND k~ekorg IN s_ekorg
            AND p~werks IN s_werks
            AND p~matnr IN s_matnr
            AND k~bedat IN s_bedat
            AND p~loekz EQ space
            AND p~infnr NE space
            AND EXISTS ( SELECT * FROM mara
                        WHERE matnr EQ p~matnr
                          AND matkl IN s_matkl ).
  IF lines( gt_po ) GT 0.
    SELECT * FROM zmm_pir_ariba
      INTO TABLE gt_zmm_pir_ariba
        FOR ALL ENTRIES IN gt_po
          WHERE infnr EQ gt_po-infnr
            AND datab LE gt_po-bedat
            AND datbi GE gt_po-bedat.

*    IF cb_other IS NOT INITIAL.
    SELECT p~infnr p~matnr p~matkl p~lifnr p~meins
           p~umrez p~umren p~lmein a~kschl a~ekorg
           a~datbi a~datab a~knumh a~werks
      FROM eina AS p INNER JOIN a017 AS a
        ON p~matnr EQ a~matnr
       AND p~lifnr EQ a~lifnr
        INTO TABLE gt_eina
          FOR ALL ENTRIES IN gt_po
          WHERE p~matnr EQ gt_po-matnr
            AND p~loekz EQ space
            AND a~kappl EQ 'M'      " This value is following zmm_0023
            AND a~kschl EQ 'PB00'   " This value is following zmm_0023
            AND a~ekorg EQ gt_po-ekorg
            AND a~datab LE gt_po-bedat
            AND a~datbi GE gt_po-bedat.

    SELECT p~infnr p~matnr p~matkl p~lifnr p~meins
           p~umrez p~umren p~lmein a~kschl a~ekorg
           a~datbi a~datab a~knumh
      FROM eina AS p INNER JOIN a018 AS a
        ON p~matnr EQ a~matnr
       AND p~lifnr EQ a~lifnr
        APPENDING TABLE gt_eina
          FOR ALL ENTRIES IN gt_po
          WHERE p~matnr EQ gt_po-matnr
            AND p~loekz EQ space
            AND a~kappl EQ 'M'      " This value is following zmm_0023
            AND a~kschl EQ 'PB00'   " This value is following zmm_0023
            AND a~ekorg EQ gt_po-ekorg
            AND a~datab LE gt_po-bedat
            AND a~datbi GE gt_po-bedat.

    IF lines( gt_eina ) GT 0.
      SELECT * FROM konp
        INTO TABLE gt_konp
          FOR ALL ENTRIES IN gt_eina
            WHERE knumh EQ gt_eina-knumh
              AND kappl EQ 'M'
              AND kschl EQ 'PB00'.

      SELECT lifnr name1 FROM lfa1
        APPENDING TABLE gt_lfa1
          FOR ALL ENTRIES IN gt_eina
            WHERE lifnr EQ gt_eina-lifnr.

      SELECT * FROM zmm_pir_ariba
        APPENDING TABLE gt_zmm_pir_ariba
          FOR ALL ENTRIES IN gt_eina
            WHERE infnr EQ gt_eina-infnr
              AND datbi EQ gt_eina-datbi.
    ENDIF.
*    ENDIF.

    SELECT matnr matkl meins FROM mara
      INTO TABLE gt_mara
        FOR ALL ENTRIES IN gt_po
          WHERE matnr EQ gt_po-matnr.
    IF lines( gt_mara ) GT 0.
      SELECT * FROM makt
        INTO TABLE gt_makt
          FOR ALL ENTRIES IN gt_mara
            WHERE matnr EQ gt_mara-matnr
              AND spras EQ sy-langu.

      SELECT * FROM t023t
        INTO TABLE gt_t023t
          FOR ALL ENTRIES IN gt_mara
            WHERE spras EQ sy-langu
              AND matkl EQ gt_mara-matkl.
    ENDIF.

    SELECT lifnr name1 FROM lfa1
      APPENDING TABLE gt_lfa1
        FOR ALL ENTRIES IN gt_po
          WHERE lifnr EQ gt_po-lifnr.

    SORT gt_zmm_pir_ariba BY infnr datbi.
    SORT gt_lfa1 BY lifnr.
    SORT gt_eina BY infnr.
    DELETE ADJACENT DUPLICATES FROM gt_zmm_pir_ariba COMPARING infnr datbi.
    DELETE ADJACENT DUPLICATES FROM gt_lfa1 COMPARING lifnr.
  ENDIF.

ENDFORM.
*--------------------------------------------------------------------*
*   FORM process_data
*--------------------------------------------------------------------*
FORM process_data.
  DATA: ls_konp      TYPE konp,
        ls_konp_prev TYPE konp,
        ls_po_prev   TYPE gy_po,
        ls_po_other  TYPE gy_po,
        ls_eina_prev TYPE gy_pir,
        ls_t023t     TYPE t023t,
        ls_makt      TYPE makt,
        ls_lfa1      TYPE gy_lfa1.

  DATA: lv_sel_method TYPE string.

  FREE: gt_report.
  LOOP AT gt_po ASSIGNING FIELD-SYMBOL(<lfs_po>).
*   Current
    gs_current-ebeln = <lfs_po>-ebeln.
    gs_current-ebelp = <lfs_po>-ebelp.
    gs_current-bedat = <lfs_po>-bedat.
    gs_current-waers = <lfs_po>-waers.
    gs_current-ekorg = <lfs_po>-ekorg.
    gs_current-werks = <lfs_po>-werks.
    gs_current-matnr = <lfs_po>-matnr.
    READ TABLE gt_mara ASSIGNING FIELD-SYMBOL(<lfs_mara>)
                       WITH KEY matnr = gs_current-matnr.
    IF sy-subrc EQ 0.
      gs_current-matkl = <lfs_mara>-matkl.
      gs_current-buom = <lfs_mara>-meins.

      READ TABLE gt_t023t INTO ls_t023t
                          WITH KEY matkl = <lfs_mara>-matkl.
      IF sy-subrc EQ 0.
        gs_current-wgbez60 = ls_t023t-wgbez60.
      ENDIF.
      READ TABLE gt_makt INTO ls_makt
                         WITH KEY matnr =  <lfs_mara>-matnr.
      IF sy-subrc EQ 0.
        gs_current-maktx = ls_makt-maktx.
      ENDIF.
    ENDIF.

*   gs_header will be used to group up current with other and previous.
*   Therefore they need to have the same value.
    MOVE gs_current TO gs_header.

    gs_current-meins = <lfs_po>-meins.
    gs_current-menge = <lfs_po>-menge.

    IF gs_current-meins NE gs_current-buom.
      CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT' "#EC CI_FLDEXT_OK[2215424] P30K910024
        EXPORTING
          i_matnr              = gs_current-matnr
          i_in_me              = gs_current-meins
          i_out_me             = gs_current-buom
          i_menge              = gs_current-menge
        IMPORTING
          e_menge              = gs_current-mbuom
        EXCEPTIONS
          error_in_application = 1
          error                = 2
          OTHERS               = 3.

    ELSE.
      gs_current-mbuom = gs_current-menge.
    ENDIF.

    gs_current-netwr = <lfs_po>-netwr.
    IF <lfs_po>-peinh IS NOT INITIAL.
      gs_current-netpr = <lfs_po>-netpr / <lfs_po>-peinh.
    ELSE.
      gs_current-netpr = <lfs_po>-netpr.
    ENDIF.

    IF gs_current-mbuom IS NOT INITIAL.
      gs_current-netpr_b = gs_current-netwr / gs_current-mbuom.
    ENDIF.

*   Current
    gs_current-type = text-r01.
    gs_current-infnr = <lfs_po>-infnr.

*    READ TABLE gt_zmm_pir_ariba WITH KEY infnr = gs_current-infnr
*                                TRANSPORTING NO FIELDS.
    LOOP AT gt_zmm_pir_ariba INTO DATA(ls_zmm_pir_ariba)
                             WHERE infnr EQ gs_current-infnr
                               AND datab LE gs_current-bedat
                               AND datbi GE gs_current-bedat.
    ENDLOOP.
    IF sy-subrc EQ 0.
*     Ariba
      gs_current-source = text-r05.
    ELSE.
*     Manual
      gs_current-source = text-r04.
    ENDIF.
    gs_current-lifnr = <lfs_po>-lifnr.
    READ TABLE gt_lfa1 INTO ls_lfa1
                       WITH KEY lifnr = gs_current-lifnr.
    IF sy-subrc EQ 0.
      gs_current-name1 = ls_lfa1-name1.
    ENDIF.

    READ TABLE gt_eina ASSIGNING FIELD-SYMBOL(<lfs_eina>)
                       WITH KEY infnr = gs_current-infnr.
    IF sy-subrc EQ 0.
      gs_current-datab = <lfs_eina>-datab.
      gs_current-datbi = <lfs_eina>-datbi.
      READ TABLE gt_konp INTO ls_konp
                         WITH KEY knumh = <lfs_eina>-knumh.
      IF sy-subrc EQ 0.
        gs_current-pirccy = ls_konp-konwa.
        IF <lfs_eina>-lmein IS NOT INITIAL
          AND <lfs_eina>-lmein NE <lfs_eina>-meins.

          gs_current-kbetr_b = ls_konp-kbetr * <lfs_eina>-umrez
                              / <lfs_eina>-umren.
        ELSE.
          gs_current-kbetr_b = ls_konp-kbetr.
        ENDIF.
      ENDIF.
    ENDIF.

    APPEND gs_current TO gt_report.

*   Get Previous PIR
    lv_sel_method = 'k~ekorg EQ gs_current-ekorg'.
    IF cb_cross IS INITIAL.
      CONCATENATE lv_sel_method
                  'AND p~werks EQ gs_current-werks'
                  INTO lv_sel_method
                    SEPARATED BY space.
    ENDIF.

    IF cb_ariba IS NOT INITIAL.
      SELECT k~ebeln p~ebelp k~ekorg k~bedat k~lifnr
             k~waers p~werks p~matnr p~meins p~menge
             p~netpr p~netwr p~infnr p~peinh
      FROM ekko AS k INNER JOIN ekpo AS p
        ON k~ebeln EQ p~ebeln
          INTO ls_po_prev
            UP TO 1 ROWS
              WHERE k~bedat LE gs_current-bedat
                AND p~ebeln NE gs_current-ebeln
*                AND p~infnr NE gs_current-infnr
                AND p~infnr NE space
                AND p~loekz EQ space
                AND p~matnr EQ gs_current-matnr
                AND (lv_sel_method)
                AND EXISTS ( SELECT * FROM zmm_pir_ariba
                                WHERE infnr EQ p~infnr
                                  AND datab LE k~bedat
                                  AND datbi GE k~bedat )
                ORDER BY k~bedat DESCENDING k~aedat DESCENDING.
      ENDSELECT.
    ELSE.
      SELECT k~ebeln p~ebelp k~ekorg k~bedat k~lifnr
             k~waers p~werks p~matnr p~meins p~menge
             p~netpr p~netwr p~infnr p~peinh
      FROM ekko AS k INNER JOIN ekpo AS p
        ON k~ebeln EQ p~ebeln
          INTO ls_po_prev
            UP TO 1 ROWS
              WHERE k~bedat LE gs_current-bedat
                AND p~ebeln NE gs_current-ebeln
*                AND p~infnr NE gs_current-infnr
                AND p~infnr NE space
                AND p~loekz EQ space
                AND p~matnr EQ gs_current-matnr
                AND (lv_sel_method)
                ORDER BY k~bedat DESCENDING k~aedat DESCENDING.
      ENDSELECT.
    ENDIF.
    IF sy-subrc EQ 0.
*     Found
      MOVE gs_header TO gs_report.

*     Previous
      gs_report-type = text-r02.
      gs_report-infnr = ls_po_prev-infnr.

      SELECT SINGLE infnr FROM zmm_pir_ariba
        INTO @DATA(lv_infnr_prev)
          WHERE infnr EQ @gs_report-infnr
            AND datab LE @ls_po_prev-bedat
            AND datbi GE @ls_po_prev-bedat.
      IF sy-subrc EQ 0.
*       Ariba
        gs_report-source = text-r05.
      ELSE.
*       Manual
        gs_report-source = text-r04.
      ENDIF.

      gs_report-lifnr = ls_po_prev-lifnr.

      SELECT SINGLE lifnr name1 FROM lfa1
        INTO ls_lfa1
          WHERE lifnr EQ ls_po_prev-lifnr.
      IF sy-subrc EQ 0.
        gs_report-name1 = ls_lfa1-name1.
      ENDIF.

      SELECT p~infnr p~matnr p~matkl p~lifnr p~meins
             p~umrez p~umren p~lmein a~kschl a~ekorg
             a~datbi a~datab a~knumh a~werks
        FROM eina AS p INNER JOIN a017 AS a
          ON p~matnr EQ a~matnr
         AND p~lifnr EQ a~lifnr
          UP TO 1 ROWS
          INTO ls_eina_prev
            WHERE p~infnr EQ ls_po_prev-infnr
              AND p~loekz EQ space
              AND a~werks EQ ls_po_prev-werks
              AND a~kappl EQ 'M'      " This value is following zmm_0023
              AND a~kschl EQ 'PB00'   " This value is following zmm_0023
              AND a~ekorg EQ ls_po_prev-ekorg
              ORDER BY datbi DESCENDING.
      ENDSELECT.
      IF sy-subrc NE 0.
        SELECT p~infnr p~matnr p~matkl p~lifnr p~meins
               p~umrez p~umren p~lmein a~kschl a~ekorg
               a~datbi a~datab a~knumh
          FROM eina AS p INNER JOIN a018 AS a
            ON p~matnr EQ a~matnr
           AND p~lifnr EQ a~lifnr
            UP TO 1 ROWS
            INTO ls_eina_prev
              WHERE p~infnr EQ ls_po_prev-infnr
                AND p~loekz EQ space
                AND a~kappl EQ 'M'      " This value is following zmm_0023
                AND a~kschl EQ 'PB00'   " This value is following zmm_0023
                AND a~ekorg EQ ls_po_prev-ekorg
                ORDER BY datbi DESCENDING.
        ENDSELECT.
        IF sy-subrc EQ 0.
          SELECT SINGLE * FROM konp
            INTO ls_konp_prev
              WHERE knumh EQ ls_eina_prev-knumh
                AND kappl EQ 'M'
                AND kschl EQ 'PB00'.
        ENDIF.
      ELSE.
        SELECT SINGLE * FROM konp
          INTO ls_konp_prev
            WHERE knumh EQ ls_eina_prev-knumh
              AND kappl EQ 'M'
              AND kschl EQ 'PB00'.
      ENDIF.

      gs_report-datab = ls_eina_prev-datab.
      gs_report-datbi = ls_eina_prev-datbi.
      gs_report-pirccy = ls_konp_prev-konwa.
      IF ls_eina_prev-lmein IS NOT INITIAL
        AND ls_eina_prev-lmein NE ls_eina_prev-meins.

        gs_report-kbetr_b = ls_konp_prev-kbetr * ls_eina_prev-umrez
                            / ls_eina_prev-umren.
      ELSE.
        gs_report-kbetr_b = ls_konp_prev-kbetr.
      ENDIF.
      IF gs_report-pirccy NE gs_current-pirccy.
        CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
          EXPORTING
            date             = gs_current-bedat
            foreign_amount   = gs_report-kbetr_b
            foreign_currency = gs_report-pirccy
            local_currency   = gs_current-pirccy
          IMPORTING
            local_amount     = gs_report-kbetr_b
          EXCEPTIONS
            no_rate_found    = 1
            overflow         = 2
            no_factors_found = 3
            no_spread_found  = 4
            derived_2_times  = 5
            OTHERS           = 6.

        gs_report-pirccy = gs_current-pirccy.
      ENDIF.

      gs_report-sav_unit = gs_current-kbetr_b - gs_report-kbetr_b.
      gs_report-sav_tot = gs_report-sav_unit * gs_current-mbuom.

      APPEND gs_report TO gt_report.
      CLEAR: gs_report, ls_eina_prev, ls_konp_prev.
    ENDIF.

    IF cb_other IS NOT INITIAL.
*     Get Other PIR
      LOOP AT gt_eina ASSIGNING <lfs_eina>
                      WHERE infnr NE gs_current-infnr
                        AND infnr NE ls_po_prev-infnr
                        AND matnr EQ gs_current-matnr
                        AND ekorg EQ gs_current-ekorg.

        IF cb_cross IS INITIAL.
          CHECK <lfs_eina>-werks EQ gs_current-werks.
        ENDIF.
        IF cb_ariba IS NOT INITIAL.
*          READ TABLE gt_zmm_pir_ariba WITH KEY infnr = <lfs_eina>-infnr
*                                      TRANSPORTING NO FIELDS.
          LOOP AT gt_zmm_pir_ariba INTO ls_zmm_pir_ariba
                                   WHERE infnr EQ <lfs_eina>-infnr
                                     AND datbi EQ <lfs_eina>-datbi.
          ENDLOOP.
          CHECK sy-subrc EQ 0.
        ENDIF.

        MOVE gs_header TO gs_report.
        gs_report-lifnr = <lfs_eina>-lifnr.
        READ TABLE gt_lfa1 INTO ls_lfa1
                           WITH KEY lifnr = gs_report-lifnr.
        IF sy-subrc EQ 0.
          gs_report-name1 = ls_lfa1-name1.
        ENDIF.

        IF cb_ariba IS NOT INITIAL.
*         Ariba
          gs_report-source = text-r05.
        ELSE.
*          READ TABLE gt_zmm_pir_ariba WITH KEY infnr = <lfs_eina>-infnr
*                                      TRANSPORTING NO FIELDS.
          LOOP AT gt_zmm_pir_ariba INTO ls_zmm_pir_ariba
                                   WHERE infnr EQ <lfs_eina>-infnr
                                     AND datbi EQ <lfs_eina>-datbi.
          ENDLOOP.
          IF sy-subrc EQ 0.
*           Ariba
            gs_report-source = text-r05.
          ELSE.
*           Manual
            gs_report-source = text-r04.
          ENDIF.
        ENDIF.

*       Other
        gs_report-type = text-r03.
        gs_report-infnr = <lfs_eina>-infnr.
        gs_report-datab = <lfs_eina>-datab.
        gs_report-datbi = <lfs_eina>-datbi.

        READ TABLE gt_konp INTO ls_konp
                           WITH KEY knumh = <lfs_eina>-knumh.
        IF sy-subrc EQ 0.
          gs_report-pirccy = ls_konp-konwa.
          IF <lfs_eina>-lmein IS NOT INITIAL
            AND <lfs_eina>-lmein NE <lfs_eina>-meins.

            gs_report-kbetr_b = ls_konp-kbetr * <lfs_eina>-umrez
                                / <lfs_eina>-umren.
          ELSE.
            gs_report-kbetr_b = ls_konp-kbetr.
          ENDIF.
        ENDIF.
        IF gs_report-pirccy NE gs_current-pirccy.
          CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
            EXPORTING
              date             = gs_current-bedat
              foreign_amount   = gs_report-kbetr_b
              foreign_currency = gs_report-pirccy
              local_currency   = gs_current-pirccy
            IMPORTING
              local_amount     = gs_report-kbetr_b
            EXCEPTIONS
              no_rate_found    = 1
              overflow         = 2
              no_factors_found = 3
              no_spread_found  = 4
              derived_2_times  = 5
              OTHERS           = 6.

          gs_report-pirccy = gs_current-pirccy.
        ENDIF.

        gs_report-sav_unit = gs_current-kbetr_b - gs_report-kbetr_b.
        gs_report-sav_tot = gs_report-sav_unit * gs_current-mbuom.

        APPEND gs_report TO gt_report.
        CLEAR: ls_po_other, gs_report.
      ENDLOOP.
    ENDIF.

    CLEAR: gs_header, gs_current, ls_po_prev.
  ENDLOOP.
ENDFORM.
*--------------------------------------------------------------------*
*   FORM display_report
*--------------------------------------------------------------------*
FORM display_report.
  PERFORM generate_fieldcat.

  gcl_func = gcl_table->get_functions( ).
  gcl_func->set_all( abap_true ).
  gcl_table->display( ).
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GENERATE_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM generate_fieldcat .
  DATA: ls_key    TYPE salv_s_layout_key.
  FREE: gcl_table, gcl_coltable, gcl_layout.

  TRY.
      CALL METHOD cl_salv_table=>factory( "#EC CI_FLDEXT_OK[2215424] P30K910024
        EXPORTING
          list_display = if_salv_c_bool_sap=>false
        IMPORTING
          r_salv_table = gcl_table
        CHANGING
          t_table      = gt_report[] ).
    CATCH cx_salv_msg.
*     System error, unable to generate field catalog
  ENDTRY.

  gcl_layout = gcl_table->get_layout( ).
  ls_key-report = sy-repid.
  gcl_layout->set_key( ls_key ).
  gcl_layout->set_save_restriction(
              if_salv_c_layout=>restrict_none ).

  gcl_coltable = gcl_table->get_columns( ).
  gcl_coltable->set_optimize( ).

  PERFORM set_field USING 'EKORG'
                          06
                          text-t01 " P.Org
                          abap_true
                          space
                          space
                          space.

  PERFORM set_field USING 'WERKS'
                          05
                          text-t02 " Plant
                          abap_true
                          space
                          space
                          space.

  PERFORM set_field USING 'EBELN'
                          10
                          text-t03 " PO Number
                          abap_true
                          space
                          space
                          '==ALPHA'.

  PERFORM set_field USING 'EBELP'
                          08
                          text-t04 " PO Item
                          abap_true
                          space
                          space
                          space.

  PERFORM set_field USING 'BEDAT'
                          10
                          text-t05 " PO Date
                          abap_true
                          space
                          space
                          space.

  PERFORM set_field USING 'WAERS'
                          11
                          text-t14 " PO Currency
                          abap_true
                          space
                          space
                          space.

  PERFORM set_field USING 'MATKL'
                          20
                          text-t06 " Material Group Code
                          abap_true
                          space
                          space
                          space.

  PERFORM set_field USING 'WGBEZ60'
                          60
                          text-t07 " Material Group Name
                          abap_true
                          space
                          space
                          space.

  PERFORM set_field USING 'MATNR'
                          18
                          text-t08 " Material Code
                          abap_true
                          space
                          space
                          '==MATN1'.

  PERFORM set_field USING 'MAKTX'
                          60
                          text-t09 " Material Name
                          abap_true
                          space
                          space
                          space.

  PERFORM set_field USING 'BUOM'
                          10
                          text-t10 " Base UoM
                          abap_true
                          space
                          space
                          '==CUNIT'.

  PERFORM set_field USING 'MEINS'
                          15
                          text-t11 " Purchase UoM
                          abap_true
                          space
                          space
                          '==CUNIT'.

  PERFORM set_field USING 'MENGE'
                          25
                          text-t12 " Quantity in Purchase UoM
                          abap_true
                          'MEINS'
                          space
                          space.

  PERFORM set_field USING 'MBUOM'
                          25
                          text-t13 " Quantity in Base UoM
                          abap_true
                          'BUOM'
                          space
                          space.

  PERFORM set_field USING 'NETWR'
                          25
                          text-t15 " PO Amount
                          abap_true
                          space
                          'WAERS'
                          space.

  PERFORM set_field USING 'NETPR'
                          25
                          text-t16 " PO Unit Price in PO item
                          abap_true
                          space
                          'WAERS'
                          space.

  PERFORM set_field USING 'NETPR_B'
                          25
                          text-t17 " PO Unit Price in BUOM
                          abap_true
                          space
                          'WAERS'
                          space.

  PERFORM set_field USING 'TYPE'
                          10
                          text-t18 " Type
                          abap_true
                          space
                          space
                          space.

  PERFORM set_field USING 'INFNR'
                          15
                          text-t19 " PIR Number
                          abap_true
                          space
                          space
                          '==ALPHA'.

  PERFORM set_field USING 'SOURCE'
                          10
                          text-t20 " Source
                          abap_true
                          space
                          space
                          space.

  PERFORM set_field USING 'LIFNR'
                          11
                          text-t21 " Vendor Code
                          abap_true
                          space
                          space
                          '==ALPHA'.

  PERFORM set_field USING 'NAME1'
                          50
                          text-t22 " Vendor Name
                          abap_true
                          space
                          space
                          space.

  PERFORM set_field USING 'DATAB'
                          20
                          text-t23 " PIR Validity From
                          abap_true
                          space
                          space
                          space.

  PERFORM set_field USING 'DATBI'
                          20
                          text-t24 " PIR Validity To
                          abap_true
                          space
                          space
                          space.

  PERFORM set_field USING 'PIRCCY'
                          15
                          text-t25 " PIR Currency
                          abap_true
                          space
                          space
                          space.

  PERFORM set_field USING 'KBETR_B'
                          25
                          text-t26 " Unit Price Base UOM
                          abap_true
                          space
                          'PIRCCY'
                          space.

  PERFORM set_field USING 'SAV_UNIT'
                          25
                          text-t27 " Savings per BUOM
                          abap_true
                          space
                          'PIRCCY'
                          space.

  PERFORM set_field USING 'SAV_TOT'
                          25
                          text-t28 " Savings for the line item
                          abap_true
                          space
                          'PIRCCY'
                          space.


* Set key fixation = allow freeze column
  gcl_coltable->set_key_fixation( abap_true ).

* freeze columns
  gcl_column_table ?= gcl_coltable->get_column( 'EKORG' ).
  IF gcl_column_table IS BOUND.
    gcl_column_table->set_key( abap_true ).
    gcl_column_table->set_key_presence_required( abap_true ).
  ENDIF.

  gcl_column_table ?= gcl_coltable->get_column( 'WERKS' ).
  IF gcl_column_table IS BOUND.
    gcl_column_table->set_key( abap_true ).
    gcl_column_table->set_key_presence_required( abap_true ).
  ENDIF.

  gcl_column_table ?= gcl_coltable->get_column( 'EBELN' ).
  IF gcl_column_table IS BOUND.
    gcl_column_table->set_key( abap_true ).
    gcl_column_table->set_key_presence_required( abap_true ).
  ENDIF.

  gcl_column_table ?= gcl_coltable->get_column( 'EBELP' ).
  IF gcl_column_table IS BOUND.
    gcl_column_table->set_key( abap_true ).
    gcl_column_table->set_key_presence_required( abap_true ).
  ENDIF.
*
** For total
*  gcl_aggr = gcl_table->get_aggregations( ).
*  gcl_aggr->clear( ).
*
*  TRY.
*      gcl_aggr->add_aggregation( columnname = 'FKIMG' ).
*    CATCH cx_salv_not_found cx_salv_data_error cx_salv_existing.
*  ENDTRY.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0043   text
*      -->P_20     text
*      -->P_TEXT_H01  text
*----------------------------------------------------------------------*
FORM set_field  USING p_field
                      p_len
                      p_title
                      p_dsp
                      p_unit
                      p_waers
                      p_mask.

  DATA: lv_textm TYPE scrtext_m,
        lv_textl TYPE scrtext_l.

  DATA: lv_err   TYPE c.

  FREE: gcl_column, lv_err.

  lv_textm = lv_textl = p_title.

  TRY.
      gcl_column = gcl_coltable->get_column( p_field ).
    CATCH cx_salv_not_found.
*     Field not found, correct the set field part
      lv_err = abap_true.
  ENDTRY.

  CHECK lv_err IS INITIAL.

  gcl_column->set_output_length( p_len ).
  gcl_column->set_medium_text( lv_textm ).
  gcl_column->set_long_text( lv_textl ).
  gcl_column->set_fixed_header_text( 'L' ).
  gcl_column->set_visible( p_dsp ).
  gcl_column->set_edit_mask( p_mask ).

  IF p_waers IS NOT INITIAL.
    gcl_column->set_sign( abap_true ).
  ENDIF.

  TRY.
      gcl_column->set_quantity_column( p_unit ).
      gcl_column->set_currency_column( p_waers ).

    CATCH cx_salv_not_found
      cx_salv_data_error.
  ENDTRY.
ENDFORM.
