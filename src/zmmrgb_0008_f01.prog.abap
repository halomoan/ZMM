*&---------------------------------------------------------------------*
*&  Include           ZMMRGB_0008_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  VALIDATE_DATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form VALIDATE_DATE .

  IF s_date IS INITIAL.

*   Assign todays date if date is initial with range within 1 year
    CLEAR s_date.
    s_date-sign = 'I'.
    s_date-option = 'BT'.
    s_date-high = sy-datum.

    CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
      EXPORTING
        date            = sy-datum
        days            = '00'
        months          = '00'
       SIGNUM           = '-'
        years           = '01'
     IMPORTING
       CALC_DATE        = s_date-low
              .
    APPEND s_date.

  ELSE.

*   Check range should only within 1 year interval
    IF s_date-low  IS NOT INITIAL AND
       s_date-high IS NOT INITIAL.

      CLEAR g_yr_diff.

      CALL FUNCTION 'FIMA_DAYS_AND_MONTHS_AND_YEARS'
        EXPORTING
          i_date_from          = s_date-low
*         I_KEY_DAY_FROM       =
          i_date_to            = s_date-high
*         I_KEY_DAY_TO         =
*         I_FLG_SEPARATE       = ' '
       IMPORTING
*         E_DAYS               =
*         E_MONTHS             =
         E_YEARS               = g_yr_diff
                .

      IF g_yr_diff > 1.
        MESSAGE i000(zmm) WITH 'Please change Date range to within 1 year'.
*        LEAVE TO TRANSACTION 'ZMM_0014'.

        SUBMIT ZMMRGB_0008 VIA SELECTION-SCREEN
          WITH s_bukrs IN s_bukrs
          WITH s_werks IN s_werks
          WITH s_ekorg IN s_ekorg
          WITH s_matkl IN s_matkl
          WITH s_lifnr IN s_lifnr
          WITH s_date  IN s_date
          WITH R1 = R1
          WITH R2 = R2
          WITH R3 = R3
          WITH R4 = R4
          WITH R5 = R5
          WITH p_item = p_item
          WITH p_vendor = p_vendor.

      ENDIF.

    ENDIF.

  ENDIF.

endform.                    " VALIDATE_DATE
*&---------------------------------------------------------------------*
*&      Form  VALIDATE_HITS_VALUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form VALIDATE_HITS_VALUE .

  DATA: l_ans.

  CASE 'X'.
    WHEN R1 OR R2 OR R3.

      IF p_item IS INITIAL.
         CALL FUNCTION 'POPUP_TO_CONFIRM'
           EXPORTING
            TITLEBAR                     = 'Maximum No of items'
             text_question               = 'No "Maximum No. of Hits" have been entered. Do you want to continue?'
            TEXT_BUTTON_1                = 'Yes'
            TEXT_BUTTON_2                = 'No'
            DISPLAY_CANCEL_BUTTON        = ''
          IMPORTING
            ANSWER                       = l_ans
          EXCEPTIONS
            TEXT_NOT_FOUND               = 1
            OTHERS                       = 2
                   .
         IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
         ENDIF.

         IF l_ans <> '1'.
*           STOP.
*           SUBMIT ZMMRGB_0008 VIA SELECTION-SCREEN.
*           LEAVE PROGRAM.

            SUBMIT ZMMRGB_0008 VIA SELECTION-SCREEN
              WITH s_bukrs IN s_bukrs
              WITH s_werks IN s_werks
              WITH s_ekorg IN s_ekorg
              WITH s_matkl IN s_matkl
              WITH s_lifnr IN s_lifnr
              WITH s_date  IN s_date
              WITH R1 = R1
              WITH R2 = R2
              WITH R3 = R3
              WITH R4 = R4
              WITH R5 = R5
              WITH p_item = p_item
              WITH p_vendor = p_vendor.

         ENDIF.

      ENDIF.

    WHEN R4 OR R5.

      IF p_vendor IS INITIAL.
         CALL FUNCTION 'POPUP_TO_CONFIRM'
           EXPORTING
            TITLEBAR                     = 'Maximum No of vendors'
             text_question               = 'No "Maximum No. of Hits" have been entered. Do you want to continue?'
            TEXT_BUTTON_1                = 'Yes'
            TEXT_BUTTON_2                = 'No'
            DISPLAY_CANCEL_BUTTON        = ''
          IMPORTING
            ANSWER                       = l_ans
          EXCEPTIONS
            TEXT_NOT_FOUND               = 1
            OTHERS                       = 2
                   .
         IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
         ENDIF.

         IF l_ans <> '1'.
*           STOP.
*           SUBMIT ZMMRGB_0008 VIA SELECTION-SCREEN.
*           LEAVE PROGRAM.

            SUBMIT ZMMRGB_0008 VIA SELECTION-SCREEN
              WITH s_bukrs IN s_bukrs
              WITH s_werks IN s_werks
              WITH s_ekorg IN s_ekorg
              WITH s_matkl IN s_matkl
              WITH s_lifnr IN s_lifnr
              WITH s_date  IN s_date
              WITH R1 = R1
              WITH R2 = R2
              WITH R3 = R3
              WITH R4 = R4
              WITH R5 = R5
              WITH p_item = p_item
              WITH p_vendor = p_vendor.

         ENDIF.

      ENDIF.
  ENDCASE.

endform.                    " VALIDATE_HITS_VALUE
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form GET_DATA .

  CASE 'X'.
    WHEN R1.
      PERFORM get_data_r1.
*    WHEN .
    WHEN OTHERS.
  ENDCASE.

endform.                    " GET_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_R1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form GET_DATA_R1  .

  CLEAR: gt_ekko, gt_ekpo, gt_eket,
         gt_eina, gt_eine.

  SELECT * FROM EKKO
    INTO TABLE gt_ekko
   WHERE BUKRS IN s_bukrs
     AND EKORG IN s_ekorg           "Purchasing Organization
     AND LIFNR IN s_lifnr
     AND BEDAT IN s_date
*   AND EBELN = '4130000031'
*   AND EBELN = '4130000004'
*     AND bsart IN ('NB', 'ZML')
*     AND frgke = 'R'.               "Only PO with released indicator
     AND (
         ( bsart = 'NB' AND frgke = 'R' )
         OR
         ( bsart = 'ZML' )
         ).

  IF NOT gt_ekko[] IS INITIAL.
    SELECT * FROM EKPO
      INTO TABLE gt_ekpo
     FOR ALL ENTRIES IN gt_ekko
     WHERE ebeln = gt_ekko-ebeln
       AND werks IN s_werks         "Plant
       AND matkl IN s_matkl         "Material Group
       AND INFNR <> SPACE.          "Should have info record
  ENDIF.

  IF NOT gt_ekpo[] IS INITIAL.
    SELECT * FROM EKET
      INTO TABLE gt_eket
     FOR ALL ENTRIES IN gt_ekpo
     WHERE ebeln = gt_ekpo-ebeln
       AND ebelp = gt_ekpo-ebelp.
  ENDIF.

*  IF NOT gt_ekpo IS INITIAL.
*
*    SELECT * FROM EINA
*      INTO TABLE gt_eina
*       FOR ALL ENTRIES IN gt_ekpo
*     WHERE infnr = gt_ekpo-infnr.
*
*    SELECT * FROM EINE
*      INTO TABLE gt_eine
*       FOR ALL ENTRIES IN gt_ekpo
*     WHERE infnr = gt_ekpo-infnr.
*
*  ENDIF.

  PERFORM get_mat_inf_rec_r1.


endform.                    " GET_DATA_R1
*&---------------------------------------------------------------------*
*&      Form  GET_MAT_INF_REC_R1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form GET_MAT_INF_REC_R1 .

  FIELD-SYMBOLS: <fs_ekko> TYPE ekko,
                 <fs_ekpo> TYPE gty_ekpo,
                 <fs_eket> TYPE eket.

  DATA: ls_eina TYPE eina,
        ls_eine TYPE eine,
        ls_a0xx TYPE a017,
        ls_konp TYPE gty_konp.

  DATA: exchange_rate   TYPE TCURR-UKURS,
        foreign_factor  TYPE TCURR-FFACT,
        local_factor    TYPE TCURR-TFACT,
        report_counter  TYPE ZTBMAXSEL.

  DATA: lrc LIKE sy-subrc.

  REFRESH: gt_rep_01[].
  CLEAR:   gs_rep_01, report_counter.

  "PO iteration
  LOOP AT gt_ekko ASSIGNING <fs_ekko>.

     "PO line items iteration
     LOOP AT gt_ekpo ASSIGNING <fs_ekpo> WHERE ebeln = <fs_ekko>-ebeln.

       REFRESH: gt_eina, gt_eine,
                gt_a0xx, gt_konp.

       CLEAR: ls_a0xx, ls_konp,
              exchange_rate, foreign_factor, local_factor,
              gs_rep_01,
              gv_matnr_base_uom,
              gv_convto_base_uom.

       REFRESH: T_ERRMSG[].
       CLEAR  : T_ERRMSG.

*       READ TABLE gt_eina INTO ls_eina WITH KEY infnr = <fs_ekpo>-infnr.
*       READ TABLE gt_eine INTO ls_eine WITH KEY infnr = <fs_ekpo>-infnr.

       "report line item must not exceeding Max hits value
       IF p_item IS NOT INITIAL AND
          report_counter >= p_item.
         STOP.
       ENDIF.

       "Skip line items if the status is Deleted
       IF NOT <fs_ekpo>-loekz IS INITIAL.
         CONTINUE.
       ENDIF.

       "PO item should have GR either partial or full GR as long as eket-menge <> 0
       READ TABLE gt_eket ASSIGNING <fs_eket> WITH KEY ebeln = <fs_ekpo>-ebeln
                                                       ebelp = <fs_ekpo>-ebelp.
       IF sy-subrc = 0.
         IF <fs_eket>-menge IS INITIAL.
           CONTINUE.
         ENDIF.
       ELSE.
         CONTINUE.
       ENDIF.

       "Assign Material base unit of measurement
       SELECT SINGLE meins FROM mara
         INTO gv_matnr_base_uom
        WHERE matnr = <fs_ekpo>-matnr.

       "Fill price per unit on Material Base UoM
       PERFORM ekpo_baseuom_netprice CHANGING <fs_ekpo>.

       "Purchasing Info record - general data
       SELECT * FROM eina INTO ls_eina
        WHERE matnr = <fs_ekpo>-matnr
          AND loekz = SPACE.

          CLEAR: ls_eine,
                 ls_a0xx, ls_konp.
          CLEAR: lrc.

          "Purchasing info record - purchasing org data
          SELECT SINGLE * FROM eine INTO ls_eine
           WHERE infnr = ls_eina-infnr
             AND ekorg = <fs_ekko>-ekorg
             AND esokz = '0'
             AND LOEKZ = SPACE.                     "Deletion indicator  = SPACE

          IF sy-subrc = 0.

            IF NOT ls_eine-werks IS INITIAL.      "Material info record Plant-specific data (A017)
                SELECT SINGLE kappl kschl lifnr matnr ekorg esokz datbi datab knumh
                  FROM A017
                  INTO (ls_a0xx-kappl, ls_a0xx-kschl, ls_a0xx-lifnr, ls_a0xx-matnr, ls_a0xx-ekorg, ls_a0xx-esokz, ls_a0xx-datbi, ls_a0xx-datab, ls_a0xx-knumh)
                 WHERE kappl = 'M'
                   AND kschl = 'PB00'
                   AND lifnr = ls_eina-lifnr
                   AND matnr = <fs_ekpo>-matnr
                   AND ekorg = <fs_ekko>-ekorg
                   AND werks = ls_eine-werks
                   AND esokz = '0'                    "Standard
                   AND datbi >= <fs_ekko>-bedat
                   AND datab <= <fs_ekko>-bedat.
            ELSE.
                SELECT SINGLE kappl kschl lifnr matnr ekorg esokz datbi datab knumh
                  FROM A018
                  INTO (ls_a0xx-kappl, ls_a0xx-kschl, ls_a0xx-lifnr, ls_a0xx-matnr, ls_a0xx-ekorg, ls_a0xx-esokz, ls_a0xx-datbi, ls_a0xx-datab, ls_a0xx-knumh)
                 WHERE kappl = 'M'
                   AND kschl = 'PB00'
                   AND lifnr = ls_eina-lifnr
                   AND matnr = <fs_ekpo>-matnr
                   AND ekorg = <fs_ekko>-ekorg
*                   AND werks = ls_eine-werks
                   AND esokz = '0'                    "Standard
                   AND datbi >= <fs_ekko>-bedat
                   AND datab <= <fs_ekko>-bedat.
            ENDIF.

            IF NOT ls_a0xx-knumh IS INITIAL.
                "Loop condition items (KONP) within no deletion flag
                SELECT * FROM konp
                  INTO CORRESPONDING FIELDS OF ls_konp
                 WHERE knumh = ls_a0xx-knumh
                   AND kschl = 'PB00'                "Only for gross price
                   AND loevm_ko = SPACE.             "Deletion indicator  = SPACE

                    ls_konp-zlifnr =  ls_a0xx-lifnr.
                    ls_konp-infnr  =  ls_eina-infnr.

*                    APPEND ls_eina TO gt_eina.
*                    APPEND ls_eine TO gt_eine.
*                    APPEND ls_a0xx TO gt_a0xx.

                    "Fill price per unit on Material Base UoM
                    PERFORM konp_baseuom_netprice USING <fs_ekpo>-matnr
                                                        ls_eina
                                                        ls_eine
                                               CHANGING ls_konp
                                                        lrc.

                    IF NOT lrc IS INITIAL.
                      EXIT.
                    ENDIF.

                    "If PO currency differents from PIR currency, translate using exchange rate
                    IF <fs_ekko>-waers NE ls_konp-konwa.

                       CALL FUNCTION 'READ_EXCHANGE_RATE'
                         EXPORTING
                          date                    = <fs_ekko>-bedat
                          foreign_currency        = ls_konp-konwa      "PIR Currency as Foreign Currency
                          local_currency          = <fs_ekko>-waers    "PO item currency as Local Currency
                          TYPE_OF_RATE            = 'M'
                        IMPORTING
                          EXCHANGE_RATE           = exchange_rate
                          FOREIGN_FACTOR          = foreign_factor
                          LOCAL_FACTOR            = local_factor
                        EXCEPTIONS
                          NO_RATE_FOUND           = 1
                          NO_FACTORS_FOUND        = 2
                          NO_SPREAD_FOUND         = 3
                          DERIVED_2_TIMES         = 4
                          OVERFLOW                = 5
                          ZERO_RATE               = 6
                          OTHERS                  = 7
                                 .
                       IF sy-subrc = 0.

                         ls_konp-zkonwa = <fs_ekko>-waers.
                         ls_konp-zkbetr =  ( ls_konp-zkbetr / foreign_factor ) * exchange_rate * local_factor .

                       ENDIF.

                    ELSE.

                         ls_konp-zkonwa = <fs_ekko>-waers.
                         ls_konp-zkbetr =  ls_konp-zkbetr.

                    ENDIF.

                    APPEND ls_konp TO gt_konp.

                ENDSELECT.

                IF sy-subrc = 0.
                  APPEND ls_eina TO gt_eina.
                  APPEND ls_eine TO gt_eine.
                  APPEND ls_a0xx TO gt_a0xx.
                ENDIF.

            ENDIF.
          ENDIF.
       ENDSELECT.

       SORT gt_konp by zkbetr ASCENDING.
       READ TABLE gt_konp INTO ls_konp INDEX 1.
       IF sy-subrc = 0.                                       "Lower price is found

         IF ls_konp-zkbetr < <fs_ekpo>-znetpr.

           "Prepare report content
           PERFORM r01_report_content TABLES gt_konp
                                             gt_a0xx
                                       USING <fs_ekko>
                                             <fs_ekpo>
                                    CHANGING gs_rep_01.

           APPEND gs_rep_01 TO gt_rep_01.
           ADD 1 TO report_counter.

         ENDIF.

       ELSEIF sy-subrc <> 0 AND T_ERRMSG[] IS NOT INITIAL.    "There is no PIR and error was found during unit conversion

           "Prepare report content
           PERFORM r01_report_content TABLES gt_konp
                                             gt_a0xx
                                       USING <fs_ekko>
                                             <fs_ekpo>
                                    CHANGING gs_rep_01.

           APPEND gs_rep_01 TO gt_rep_01.
           ADD 1 TO report_counter.

       ENDIF.




*       IF NOT ls_eine-werks IS INITIAL.        "Material info record Plant-specific data (A017)
*
*         SELECT SINGLE kappl kschl lifnr matnr ekorg esokz datbi datab knumh
*           FROM A017
*           INTO (ls_a0xx-kappl, ls_a0xx-kschl, ls_a0xx-lifnr, ls_a0xx-matnr, ls_a0xx-ekorg, ls_a0xx-esokz, ls_a0xx-datbi, ls_a0xx-datab, ls_a0xx-knumh)
*          WHERE kappl = 'M'
*            AND kschl = 'PB00'
*            AND lifnr = <fs_ekko>-lifnr
*            AND matnr = <fs_ekpo>-matnr
*            AND ekorg = <fs_ekko>-ekorg
*            AND werks = ls_eine-werks
*            AND esokz = '0'                    "Standard
*            AND datbi >= <fs_ekko>-bedat
*            AND datab <= <fs_ekko>-bedat.
*
*       ELSE.                                   "Material info record General data (A018)
*
*         SELECT SINGLE kappl kschl lifnr matnr ekorg esokz datbi datab knumh
*           FROM A018
*           INTO (ls_a0xx-kappl, ls_a0xx-kschl, ls_a0xx-lifnr, ls_a0xx-matnr, ls_a0xx-ekorg, ls_a0xx-esokz, ls_a0xx-datbi, ls_a0xx-datab, ls_a0xx-knumh)
*          WHERE kappl = 'M'
*            AND kschl = 'PB00'
*            AND lifnr = <fs_ekko>-lifnr
*            AND matnr = <fs_ekpo>-matnr
*            AND ekorg = <fs_ekko>-ekorg
**            AND werks = ls_eine-werks
*            AND esokz = '0'                    "Standard
*            AND datbi >= <fs_ekko>-bedat
*            AND datab <= <fs_ekko>-bedat.
*
*       ENDIF.
*
*       IF NOT ls_a0xx-knumh IS INITIAL.
*
*         SELECT SINGLE * FROM konp
*           INTO CORRESPONDING FIELDS OF ls_konp
*          WHERE knumh = ls_a0xx-knumh
*            AND kopos = 1.
*
*         IF sy-subrc = 0.
*
*            gs_rep_01-waers = <fs_ekko>-waers.
*            gs_rep_01-konwa = ls_konp-konwa.      "PIR currency
*
*            IF gs_rep_01-waers NE gs_rep_01-konwa.
*              "Convert PIR currency into PO item currency
*
*              CALL FUNCTION 'READ_EXCHANGE_RATE'
*                EXPORTING
*                 date                    = gs_rep_01-bedat
*                 foreign_currency        = gs_rep_01-konwa    "PIR Currency as Foreign Currency
*                 local_currency          = gs_rep_01-waers    "PO item currency as Local Currency
*                 TYPE_OF_RATE            = 'M'
*               IMPORTING
*                 EXCHANGE_RATE           = exchange_rate
*                 FOREIGN_FACTOR          = foreign_factor
*                 LOCAL_FACTOR            = local_factor
*               EXCEPTIONS
*                 NO_RATE_FOUND           = 1
*                 NO_FACTORS_FOUND        = 2
*                 NO_SPREAD_FOUND         = 3
*                 DERIVED_2_TIMES         = 4
*                 OVERFLOW                = 5
*                 ZERO_RATE               = 6
*                 OTHERS                  = 7
*                        .
*              IF sy-subrc = 0.
*
*                gs_rep_01-kbetr = ( ls_konp-kbetr / foreign_factor ) * exchange_rate * local_factor .
*
*              ENDIF.
*
*            ELSE.
*              gs_rep_01-kbetr = ls_konp-kbetr.
*            ENDIF.
*
*            gs_rep_01-netpr = <fs_ekpo>-netpr.      "PO items price
*
*            "Consider if PO items price is higher than PIR price
*            IF gs_rep_01-netpr > gs_rep_01-kbetr.
*
*              gs_rep_01-zprdif = gs_rep_01-netpr - gs_rep_01-kbetr.
*
*              gs_rep_01-bukrs = <fs_ekko>-bukrs.
*              gs_rep_01-ekorg = <fs_ekko>-bukrs.
*              gs_rep_01-werks = <fs_ekpo>-werks.
*              gs_rep_01-ekgrp = <fs_ekko>-ekgrp.
*              gs_rep_01-ebeln = <fs_ekko>-ebeln.
*              gs_rep_01-ebelp = <fs_ekpo>-ebelp.
*              gs_rep_01-ebelp = <fs_ekpo>-ebelp.
*              gs_rep_01-bsart = <fs_ekko>-bsart.
*              gs_rep_01-bedat = <fs_ekko>-bedat.
*              gs_rep_01-lifnr = <fs_ekko>-lifnr.
*
*              IF NOT gs_rep_01-lifnr IS INITIAL.
*                PERFORM get_vendor_name USING gs_rep_01-lifnr gs_rep_01-name1.
*              ENDIF.
*
*              gs_rep_01-ernam = <fs_ekko>-ernam.
*              gs_rep_01-matnr = <fs_ekpo>-matnr.
*
*              gs_rep_01-maktx = <fs_ekpo>-txz01.
*
*              gs_rep_01-menge = <fs_ekpo>-menge.
*              gs_rep_01-meins = <fs_ekpo>-meins.
*              gs_rep_01-netwr = <fs_ekpo>-netwr.
*
*              gs_rep_01-ztot_prdif = ( gs_rep_01-netpr - gs_rep_01-kbetr ) * gs_rep_01-menge.
*              gs_rep_01-zlifnr = ls_a0xx-lifnr.
*
*              IF NOT ls_a0xx-lifnr IS INITIAL.
*                PERFORM get_vendor_name USING ls_a0xx-lifnr gs_rep_01-zname1.
*              ENDIF.
*
*              APPEND gs_rep_01 TO gt_rep_01.
*
*            ENDIF.
*
*         ENDIF.
*
*       ENDIF.

     ENDLOOP.

  ENDLOOP.

endform.                    " GET_MAT_INF_REC_R1
*&---------------------------------------------------------------------*
*&      Form  GET_GENERAL_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form GET_GENERAL_DATA .

  REFRESH: gt_comp[].
  CLEAR:   gs_comp.

  IF NOT s_bukrs IS INITIAL.

    SELECT bukrs butxt waers FROM t001
      INTO TABLE gt_comp
     WHERE bukrs IN s_bukrs.

  ENDIF.

endform.                    " GET_GENERAL_DATA
*&---------------------------------------------------------------------*
*&      Form  PREPARE_REPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form PREPARE_REPORT .

  DATA: lv_struc_name LIKE DD02L-TABNAME.

  REFRESH: gt_fieldcat_rep[],
           gt_sort_rep[].
  CLEAR:   gs_filedcat_rep,
           gs_layout_rep.

* Prepare ALV Settings
  PERFORM: prepare_layout,                                "Layout
           prepare_sort,                                  "Sort

           general_fielcat.                               "General Fieldcat column

* Set specific Fieldcat column based on selected report category
  CASE 'X'.
    WHEN R1.
      lv_struc_name = text-r01.
    WHEN OTHERS.
  ENDCASE.

* Get field category
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = lv_struc_name
      i_bypassing_buffer     = 'X'
    CHANGING
      ct_fieldcat            = gt_fieldcat_rep
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

* If successful
  IF sy-subrc = 0.

*   Format fieldcat_category (Report)
    PERFORM rearrange_fieldcat.

  ENDIF.


endform.                    " PREPARE_REPORT
*&---------------------------------------------------------------------*
*&      Form  GENERAL_FIELCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form GENERAL_FIELCAT .

* Get field category
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = text-r00
      i_bypassing_buffer     = 'X'
    CHANGING
      ct_fieldcat            = gt_fieldcat_rep
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

* If successful
  IF sy-subrc = 0.

  ENDIF.

endform.                    " GENERAL_FIELCAT
*&---------------------------------------------------------------------*
*&      Form  PREPARE_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_ES_LAYOUT_REP  text
*----------------------------------------------------------------------*
form PREPARE_LAYOUT.

  gs_layout_rep-cwidth_opt = c_x.      "Optimize column width
  gs_layout_rep-zebra      = c_x.      "Zebra pattern

*  gs_layout_rep-no_rowmark = c_x.      "No Rowmark
  gs_layout_rep-sel_mode   = c_b.      "Selection Mode - Simple

endform.                    " PREPARE_LAYOUT
*&---------------------------------------------------------------------*
*&      Form  PREPARE_SORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form PREPARE_SORT .

  FIELD-SYMBOLS: <ls_sort> TYPE lvc_s_sort.

  UNASSIGN: <ls_sort>.
  APPEND INITIAL LINE TO gt_sort_rep ASSIGNING <ls_sort>.
  <ls_sort>-spos      = 1.
  <ls_sort>-fieldname = 'BUKRS'.
  <ls_sort>-UP = c_x.
  <ls_sort>-NO_OUT = 'X'.
*  <ls_sort>-SUBTOT = c_x.

*  UNASSIGN: <ls_sort>.
*  APPEND INITIAL LINE TO gt_sort_rep ASSIGNING <ls_sort>.
*  <ls_sort>-spos      = 2.
*  <ls_sort>-fieldname = 'EBELN'.
*  <ls_sort>-UP = c_x.
**  <ls_sort>-SUBTOT = c_x.
*
*  UNASSIGN: <ls_sort>.
*  APPEND INITIAL LINE TO gt_sort_rep ASSIGNING <ls_sort>.
*  <ls_sort>-spos      = 3.
*  <ls_sort>-fieldname = 'EBELP'.
*  <ls_sort>-UP = c_x.
**  <ls_sort>-SUBTOT = c_x.


endform.                    " PREPARE_SORT
*&---------------------------------------------------------------------*
*&      Form  REARRANGE_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form REARRANGE_FIELDCAT .

  FIELD-SYMBOLS: <fs_fcrep>  TYPE lvc_s_fcat.

  CASE 'X'.
    WHEN R1.

      LOOP AT gt_fieldcat_rep ASSIGNING <fs_fcrep>.

        CASE <fs_fcrep>-fieldname.
*          WHEN 'EKORG'.                           "Purch Org
*            <fs_fcrep>-NO_OUT = 'X'.
*          WHEN 'WERKS'.                           "Plant
*            <fs_fcrep>-NO_OUT = 'X'.
          WHEN 'EBELN'.                           "Purch Group
            <fs_fcrep>-HOTSPOT = c_x.
          WHEN 'EKGRP'.                           "Purch Group
            <fs_fcrep>-NO_OUT = 'X'.
          WHEN 'BSART'.                           "Purch Doc Type
            <fs_fcrep>-NO_OUT = 'X'.
          WHEN 'BEDAT'.                           "Purch Doc Date
            <fs_fcrep>-NO_OUT = 'X'.
          WHEN 'LIFNR'.                           "Vendor ID
            <fs_fcrep>-COLTEXT = 'Vendor in PO'.
          WHEN 'NAME1'.                           "Vendor Name
            <fs_fcrep>-COLTEXT = 'Vendor Name in PO'.
          WHEN 'NETPR'.                           "Price per OUn
            <fs_fcrep>-COLTEXT   = 'Price per OUn'.
            <fs_fcrep>-SCRTEXT_L = 'Price per OUn'.
            <fs_fcrep>-SCRTEXT_M = 'Price per OUn'.
            <fs_fcrep>-SCRTEXT_S = 'Price per OUn'.
            <fs_fcrep>-REPTEXT   = 'Price per OUn'.
          WHEN 'ZNETPR'.                           "Price per BUoM
            <fs_fcrep>-COLTEXT = 'Price per BUoM'.
          WHEN 'NETWR'.                            "Order Value
            <fs_fcrep>-COLTEXT = 'Order Value'.
          WHEN 'WAERS'.                            "PO Currency
            <fs_fcrep>-COLTEXT = 'PO Currency'.
          WHEN 'ERNAM'.                           "Creator Name
            <fs_fcrep>-NO_OUT = 'X'.
          WHEN 'ZKBETR'.                          "Lowest Price in PIR
            <fs_fcrep>-COLTEXT = 'Lowest Price in PIR'.
          WHEN 'KONWA'.                           "PIR Currency
            <fs_fcrep>-COLTEXT   = 'PIR Currency'.
            <fs_fcrep>-SCRTEXT_L = 'PIR Currency'.
            <fs_fcrep>-SCRTEXT_M = 'PIR Currency'.
            <fs_fcrep>-SCRTEXT_S = 'PIR Currency'.
            <fs_fcrep>-REPTEXT   = 'PIR Currency'.
          WHEN 'ZLIFNR'.                           "Vendor of PIR
            <fs_fcrep>-COLTEXT = 'Vendor of PIR'.
          WHEN 'INFNR'.                            "PIR of lowest price
            <fs_fcrep>-HOTSPOT = c_x.
          WHEN 'ZNAME1'.                           "Vendor of PIR
            <fs_fcrep>-COLTEXT = 'Vendor Name of PIR'.
          WHEN 'ZPRDIF'.                           "Price Difference
            <fs_fcrep>-COLTEXT = 'Price Difference'.
          WHEN 'ZTOT_PRDIF'.                      "Total Amount Difference
            <fs_fcrep>-COLTEXT = 'Total Amount Difference'.
          WHEN 'REMARK'.                          "Remark for conversion error message
            <fs_fcrep>-COLTEXT     = 'Remark'.
            <fs_fcrep>-SCRTEXT_S   = 'Remark'.
          WHEN 'ZCONV'.                           "Base UOM Conversion
            <fs_fcrep>-SCRTEXT_L = 'Base UOM Conversion'.
            <fs_fcrep>-SCRTEXT_M = 'Base UOM Conv'.
            <fs_fcrep>-SCRTEXT_S = 'Base UOM Conv'.
            <fs_fcrep>-REPTEXT   = 'Base UOM Conv'.
        ENDCASE.

      ENDLOOP.

    WHEN OTHERS.
  ENDCASE.


endform.                    " REARRANGE_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_REPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form DISPLAY_REPORT .

  DATA: ld_prog LIKE sy-cprog.
  ld_prog = sy-cprog.

*  DATA: ls_s_prnt TYPE LVC_S_PRNT.
*  ls_s_prnt-print = 'X'.


  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC' "#EC CI_FLDEXT_OK[2215424] P30K910040
    EXPORTING
      i_callback_program       = ld_prog
      i_callback_pf_status_set = text-pf1
      i_callback_user_command  = text-uc1
      is_layout_lvc            = gs_layout_rep
      it_fieldcat_lvc          = gt_fieldcat_rep
      it_sort_lvc              = gt_sort_rep
*      IS_PRINT_LVC = ls_s_prnt
    TABLES
      t_outtab                 = gt_rep_01
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.

endform.                    " DISPLAY_REPORT
*&---------------------------------------------------------------------*
*&      Form  GET_VENDOR_NAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_REP_01_LIFNR  text
*      -->P_GS_REP_01_NAME1  text
*----------------------------------------------------------------------*
form GET_VENDOR_NAME  using    p_lifnr
                               p_name1.

  SELECT SINGLE name1 FROM LFA1
    INTO p_name1
   WHERE lifnr = p_lifnr.

endform.                    " GET_VENDOR_NAME
*&---------------------------------------------------------------------*
*&      Form  R01_REPORT_CONTENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_<FS_EKKO>  text
*      -->P_<FS_EKPO>  text
*      -->P_LS_A0XX  text
*      -->P_GT_KONP  text
*----------------------------------------------------------------------*
form R01_REPORT_CONTENT  tables   p_gt_konp TYPE gty_t_konp
                                  p_gt_a0xx TYPE gty_t_a017
                         using    p_ekko TYPE ekko
                                  p_ekpo TYPE gty_ekpo
                         CHANGING p_gs_rep_01 TYPE gty_rep_01.


  DATA: ls_konp TYPE gty_konp,
        ls_a0xx TYPE a017,
        lv_tabix LIKE sy-tabix.

  READ TABLE p_gt_konp INTO ls_konp INDEX 1.

  IF sy-subrc = 0.

    LOOP AT p_gt_konp TRANSPORTING NO FIELDS WHERE zkbetr = ls_konp-zkbetr.
      ADD 1 TO lv_tabix.
    ENDLOOP.

    IF lv_tabix > 1.
      READ TABLE p_gt_konp INTO ls_konp WITH KEY zkbetr = ls_konp-zkbetr
                                                 zlifnr = p_ekko-lifnr.
      IF sy-subrc <> 0.
        SORT p_gt_konp BY zkbetr lifnr ASCENDING.
        READ TABLE p_gt_konp INTO ls_konp INDEX 1.
      ENDIF.

    ENDIF.

    READ TABLE p_gt_a0xx INTO ls_a0xx WITH KEY knumh = ls_konp-knumh.

  ENDIF.

  "Prepare report fields
  PERFORM r01_report_fields USING p_ekko
                                  p_ekpo
                                  ls_a0xx
                                  ls_konp
                         CHANGING p_gs_rep_01.




endform.                    " R01_REPORT_CONTENT
*&---------------------------------------------------------------------*
*&      Form  R01_REPORT_FIELDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_EKKO  text
*      -->P_P_EKPO  text
*      -->P_P_LS_A0XX  text
*      -->P_LS_KONP  text
*      <--P_P_GS_REP_01  text
*----------------------------------------------------------------------*
form R01_REPORT_FIELDS  using    p_ekko TYPE ekko
                                 p_ekpo TYPE gty_ekpo
                                 p_ls_a0xx TYPE a017
                                 p_ls_konp type gty_konp
                        changing p_gs_rep_01 TYPE gty_rep_01.


    p_gs_rep_01-bukrs = p_ekko-bukrs.
    p_gs_rep_01-ekorg = p_ekko-ekorg.
    p_gs_rep_01-werks = p_ekpo-werks.
    p_gs_rep_01-ekgrp = p_ekko-ekgrp.
    p_gs_rep_01-ebeln = p_ekko-ebeln.
    p_gs_rep_01-ebelp = p_ekpo-ebelp.
    p_gs_rep_01-bsart = p_ekko-bsart.
    p_gs_rep_01-bedat = p_ekko-bedat.
    p_gs_rep_01-lifnr = p_ekko-lifnr.

    IF NOT p_gs_rep_01-lifnr IS INITIAL.
      PERFORM get_vendor_name USING p_ekko-lifnr p_gs_rep_01-name1.
    ENDIF.

    p_gs_rep_01-ernam = p_ekko-ernam.
    p_gs_rep_01-matnr = p_ekpo-matnr.
    p_gs_rep_01-maktx = p_ekpo-txz01.
    p_gs_rep_01-menge = p_ekpo-menge.
    p_gs_rep_01-meins = p_ekpo-meins.
    p_gs_rep_01-bprme = p_ekpo-bprme.      "Order Price Unit

    p_gs_rep_01-zbuom = gv_matnr_base_uom.
    p_gs_rep_01-zconv = gv_convto_base_uom.

    p_gs_rep_01-netpr = p_ekpo-netpr.      "PO items price
    p_gs_rep_01-netwr = p_ekpo-netwr.
    p_gs_rep_01-waers = p_ekko-waers.
    p_gs_rep_01-zkbetr = p_ls_konp-zkbetr.
    p_gs_rep_01-konwa = p_ls_konp-konwa.      "PIR currency
    p_gs_rep_01-zlifnr = p_ls_a0xx-lifnr.
    p_gs_rep_01-infnr  = p_ls_konp-infnr.     "PIR of lowest price

    IF NOT p_ls_a0xx-lifnr IS INITIAL.
      PERFORM get_vendor_name USING p_ls_a0xx-lifnr p_gs_rep_01-zname1.
    ENDIF.

    IF NOT p_ls_a0xx IS INITIAL.    "Price different is not set if there is no PIR

      p_gs_rep_01-zprdif = p_ekpo-znetpr - p_ls_konp-zkbetr.

      IF p_ekpo-bprme EQ gv_matnr_base_uom.
        p_gs_rep_01-ztot_prdif = ( p_ekpo-znetpr - p_ls_konp-zkbetr ) * p_ekpo-menge.
      ELSE.
        IF p_ls_konp-zkbetr IS INITIAL.
          p_gs_rep_01-ztot_prdif = p_ekpo-netwr.
        ELSE.
          p_gs_rep_01-ztot_prdif = ( p_ekpo-znetpr - p_ls_konp-zkbetr ) * gv_convto_base_uom * p_ekpo-menge.
        ENDIF.
      ENDIF.

    ELSE.
      CLEAR T_ERRMSG.               "Add error message log to ALV
      READ TABLE T_ERRMSG INDEX 1.
      p_gs_rep_01-remark = T_ERRMSG.
    ENDIF.

    p_gs_rep_01-znetpr = p_ekpo-znetpr.

endform.                    " R01_REPORT_FIELDS

FORM SET_PF_STATUS USING rt_extab TYPE slis_t_extab.

  DATA: ex_ucomm TYPE TABLE OF sy-ucomm.
  APPEND '&REFRESH' TO ex_ucomm.

  SET PF-STATUS 'STANDARD_FULLSCREEN' EXCLUDING ex_ucomm.

ENDFORM.  "SET_PF_STATUS

FORM USER_COMMAND USING iv_ucomm    LIKE sy-ucomm
                        is_selfield TYPE slis_selfield.

  FIELD-SYMBOLS: <ls_rep_01> TYPE gty_rep_01.


  CASE  iv_ucomm.

    WHEN text-c01.  "Navigate (&IC1)

      CASE is_selfield-fieldname.
        WHEN 'EBELN'.                   "PO Number

          UNASSIGN: <ls_rep_01>.
          "Get PO Number
          READ TABLE gt_rep_01 INDEX is_selfield-tabindex
                               ASSIGNING <ls_rep_01>.
          IF sy-subrc = 0.
*           Set Screen Parameters for Transaction Call to view PO
            SET PARAMETER ID: 'BES'    FIELD <ls_rep_01>-ebeln.
            CALL TRANSACTION 'ME23N'." AND SKIP FIRST SCREEN.
          ENDIF.

        WHEN 'INFNR'.                   "PIR
          "Get PIR No.
          READ TABLE gt_rep_01 INDEX is_selfield-tabindex
                               ASSIGNING <ls_rep_01>.
          IF sy-subrc = 0.
*           Set Screen Parameters for Transaction Call to view PO
            SET PARAMETER ID: 'LIF'    FIELD <ls_rep_01>-zlifnr.
            SET PARAMETER ID: 'MAT'    FIELD <ls_rep_01>-matnr.  "#EC CI_FLDEXT_OK[2215424] P30K910040
            SET PARAMETER ID: 'EKO'    FIELD <ls_rep_01>-ekorg.
            SET PARAMETER ID: 'WRK'    FIELD <ls_rep_01>-werks.
            SET PARAMETER ID: 'INF'    FIELD <ls_rep_01>-infnr.
            CALL TRANSACTION 'ME13' AND SKIP FIRST SCREEN.
          ENDIF.

      ENDCASE.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  EKPO_BASEUOM_PRICE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_<FS_EKPO>  text
*----------------------------------------------------------------------*
form EKPO_BASEUOM_NETPRICE  changing p_ekpo TYPE gty_ekpo.

  DATA: lv_menge TYPE ekpo-menge.

  IF p_ekpo-bprme EQ gv_matnr_base_uom.

    p_ekpo-znetpr = ( p_ekpo-netpr / p_ekpo-peinh ).
    gv_convto_base_uom = 1.

  ELSE.

    "Convert Order Price Unit to Base UoM
     CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
       EXPORTING
         i_matnr                    = p_ekpo-matnr
         i_in_me                    = p_ekpo-bprme
         i_out_me                   = gv_matnr_base_uom
         i_menge                    = 1
      IMPORTING
        E_MENGE                    = lv_menge
      EXCEPTIONS
        ERROR_IN_APPLICATION       = 1
        ERROR                      = 2
        OTHERS                     = 3
               .
     IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.

        p_ekpo-znetpr = ( p_ekpo-netpr / p_ekpo-peinh ) / ( p_ekpo-bpumn / p_ekpo-bpumz ).
        gv_convto_base_uom = 1 / ( p_ekpo-bpumn / p_ekpo-bpumz ).

     ELSE.

       p_ekpo-znetpr = ( p_ekpo-netpr / p_ekpo-peinh ) / lv_menge.
       gv_convto_base_uom = lv_menge.

     ENDIF.


  ENDIF.

endform.                    " EKPO_BASEUOM_PRICE
*&---------------------------------------------------------------------*
*&      Form  KONP_BASEUOM_NETPRICE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LS_KONP  text
*----------------------------------------------------------------------*
form KONP_BASEUOM_NETPRICE  using    p_matnr type gty_ekpo-matnr
                                     p_eina  type eina
                                     p_eine  type eine
                            changing p_konp  TYPE gty_konp
                                     p_rc    TYPE sy-subrc.

  DATA: lv_menge TYPE ekpo-menge.


  IF p_konp-kmein EQ gv_matnr_base_uom.

    p_konp-zkbetr = ( p_konp-kbetr / p_konp-kpein ).

  ELSE.

    IF p_konp-kmein NE p_eina-meins AND p_konp-kmein EQ p_eine-bprme.                         "Conversion at PIR Purchasing Org. level

      p_konp-zkbetr = ( p_konp-kbetr / p_konp-kpein ) * ( p_eine-bpumz / p_eine-bpumn ) .

    ELSEIF p_konp-kmein EQ p_eina-meins AND p_konp-kmein NE p_eina-lmein.

      p_konp-zkbetr = ( p_konp-kbetr / p_konp-kpein ) / ( p_eina-umrez / p_eina-umren  ) .    "Conversion at PIR General data

    ELSE.

      "Convert Condition Order Unit to Base UoM                                               "Conversion at Material Master
       CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
         EXPORTING
           i_matnr                    = p_matnr
           i_in_me                    = p_konp-kmein
           i_out_me                   = gv_matnr_base_uom
           i_menge                    = 1
        IMPORTING
          E_MENGE                    = lv_menge
        EXCEPTIONS
          ERROR_IN_APPLICATION       = 1
          ERROR                      = 2
          OTHERS                     = 3
                 .
       IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
         p_rc = sy-subrc.

         "Get error message
         CALL FUNCTION 'MESSAGE_TEXT_BUILD'
           EXPORTING
             msgid                     = SY-MSGID
             msgnr                     = SY-MSGNO
             MSGV1                     = SY-MSGV1
             MSGV2                     = SY-MSGV2
             MSGV3                     = SY-MSGV3
             MSGV4                     = SY-MSGV4
           IMPORTING
             MESSAGE_TEXT_OUTPUT       = T_ERRMSG.

          APPEND T_ERRMSG.

       ELSE.
         p_konp-zkbetr = ( p_konp-kbetr / p_konp-kpein ) / lv_menge.
       ENDIF.

    ENDIF.

  ENDIF.

endform.                    " KONP_BASEUOM_NETPRICE
*&---------------------------------------------------------------------*
*&      Form  CHECK_BUKRS_AND_WERKS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form CHECK_BUKRS_AND_WERKS .

  IF s_bukrs IS INITIAL AND s_werks IS INITIAL.

    MESSAGE e000(zmm) with 'Please fill either Company Code or Plant'.

  ENDIF.

endform.                    " CHECK_BUKRS_AND_WERKS
*&---------------------------------------------------------------------*
*&      Form  SET_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form SET_SCREEN .

  LOOP AT SCREEN.
    IF screen-group1 = 'RW'.
      SCREEN-INPUT = 0.
*      SCREEN-INVISIBLE = 1.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

endform.                    " SET_SCREEN
