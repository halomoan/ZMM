*----------------------------------------------------------------------*
***INCLUDE ZMMRGB_0005_FETCH_SUB .
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
* Program    : ZMMRGB_0005_FETCH_SUB
* FRICE#     : MMGBE_016
* Title      : PO Approval Report
* Author     : Venkatesh Gopalarathnam
* Date       : 28.12.2010
* Specification Given By:
* Purpose	   : To generate display POs for approval and enable user to
*              approve POs relevant to the user.
*---------------------------------------------------------------------*
* Modification Log
* Date         Author          Num  Transpor no.     Description
* -----------  -------         ---  ---------------------------------*
* 28.12.2010   VEGOPALARATH    001                Initial creation
* 10.01.2011   VEGOPALARATH    002  P30K901533    Deletion indicator issue
*                                                 Alloy tkt no - T000409
*---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  FETCH_PORD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM fetch_pord .
*Local data declaration
  DATA : lt_ekko TYPE STANDARD TABLE OF ty_ekko.
*Fetch POs based on input selection parameters
  SELECT ebeln
         bsart
         aedat
         ernam
         lifnr
         ekorg
         ekgrp
         waers
         frgzu
         frggr
         frgsx
         procstat
    FROM ekko
    INTO TABLE it_ekko
    WHERE ebeln IN s_ebeln
    AND lifnr IN s_lifnr
    AND ekorg IN s_ekorg
    AND ekgrp IN s_ekgrp
    AND bukrs IN s_bukrs
    AND bstyp IN s_bstyp
    AND aedat IN s_aedat
    AND ernam IN s_ernam
    AND frgrl IN s_frgrl
    AND frggr IN s_frggr
    AND frgke IN s_frgke.

  IF sy-subrc EQ 0.
    SORT it_ekko BY ebeln.
  ELSE.
    MESSAGE text-002 TYPE c_s DISPLAY LIKE c_e.
    LEAVE LIST-PROCESSING.
  ENDIF.

  lt_ekko = it_ekko.
  SORT lt_ekko BY ekgrp.
  DELETE ADJACENT DUPLICATES FROM lt_ekko COMPARING ekgrp.
*Fetch Purchase group name.
  IF it_ekko IS NOT INITIAL.
    SELECT ekgrp
           eknam
      FROM t024
      INTO TABLE it_t024
      FOR ALL ENTRIES IN lt_ekko
      WHERE ekgrp = lt_ekko-ekgrp.

    IF sy-subrc EQ 0.
      SORT it_t024 BY ekgrp.
    ENDIF.
  ENDIF.
ENDFORM.                    " FETCH_PORD

*Begin of P30K903020
*&---------------------------------------------------------------------*
*&      Form  FETCH_RFQ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fetch_rfq .

* If PO items exist
  IF NOT it_ekpo[] IS INITIAL.

    REFRESH: it_rfq.

*   Get Related Purchasing Documents
    SELECT eket~banfn
           eket~bnfpo
           eket~ebeln
           eket~ebelp
           ekpo~prdat
      FROM eket
      JOIN ekko ON eket~ebeln = ekko~ebeln
      JOIN ekpo ON eket~ebeln = ekpo~ebeln AND
                   eket~ebelp = ekpo~ebelp
      INTO TABLE it_rfq
       FOR ALL ENTRIES IN it_ekpo
     WHERE eket~banfn = it_ekpo-banfn AND
           eket~bnfpo = it_ekpo-bnfpo AND
           ekko~bstyp = text-pdc.

    SORT it_rfq BY banfn
                   bnfpo
                   ebeln
                   ebelp.

*   Delete entries without Purchase Requisition Number
    DELETE it_rfq WHERE banfn IS INITIAL.

  ENDIF.

ENDFORM.                    " FETCH_RFQ

*End   of P30K903020

*&---------------------------------------------------------------------*
*&      Form  FETCH_EKPO_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM fetch_ekpo_data .
*Fetch records from EKPO for Plant and Amount data

  IF it_ekko IS NOT INITIAL.
*   Begin of P30K903020
    SELECT ekpo~ebeln
           ekpo~ebelp
           ekpo~matnr
           ekpo~bukrs
           ekpo~txz01
           ekpo~werks
           ekpo~menge
           ekpo~meins
           ekpo~netpr
           ekpo~peinh
           ekpo~netwr
           ekpo~bprme
           ekpo~knttp
           ekpo~vrtkz
           ekpo~pstyp
           ekpo~banfn
           ekpo~bnfpo
           ekpo~anfnr
           ekpo~anfps
           ekpo~konnr
           ekpo~ktpnr
           ekpo~infnr
           ekpo~retpo
           ekpo~prdat
           ekpo~bstyp
           ekko~lifnr
           ekko~ekorg
           ekko~bedat
*>>> SUPPORT TICKET T010721 - ADDED BY RAMSES 04.06.2013 - START  P30K905789
           ekko~waers
*<<< SUPPORT TICKET T010721 - ADDED BY RAMSES 04.06.2013 - END
      FROM ekko
      JOIN ekpo ON ekko~ebeln = ekpo~ebeln
*>>> SUPPORT TICKET T010721 - CHANGED BY RAMSES 04.06.2013 - START  P30K905789
*      INTO TABLE it_ekpo
      INTO CORRESPONDING FIELDS OF TABLE it_ekpo
*<<< SUPPORT TICKET T010721 - CHANGED BY RAMSES 04.06.2013 - END
       FOR ALL ENTRIES IN it_ekko
     WHERE ekko~ebeln = it_ekko-ebeln
*Start of changes by Venkatesh<VEGOPALARATH> on 10-Jan-11
*Fixing indicator issue - Alloy Tkt no. - T000409
*      AND   loekz NE c_x.
      AND  ekpo~loekz EQ ' '.
*End of Changes by Venkatesh<VEGOPALARATH> on 10-Jan-11
*    End of P30K903020

    IF sy-subrc EQ 0.
      SORT it_ekpo BY ebeln werks.

*     Begin of P30K903020
      SELECT matnr
             maktx
        FROM makt
        INTO TABLE it_makt
         FOR ALL ENTRIES IN it_ekpo
       WHERE matnr = it_ekpo-matnr AND
             spras = sy-langu.
*     End   of P30K903020
    ENDIF.
  ENDIF.

ENDFORM.                    " FETCH_EKPO_DATA
*&---------------------------------------------------------------------*
*&      Form  REARRANGE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM rearrange_data .
*Local data declaration.
  DATA : lt_ekpo  TYPE STANDARD TABLE OF zzmmsg_ekpodet,    "P30K903020
         ls_ekpo  TYPE zzmmsg_ekpodet,                      "P30K903020
         ls_ekko  TYPE ty_ekko,
         ls_t001w TYPE ty_t001w,
         ls_t16fs TYPE ty_t16fs,
         ls_t16fd TYPE ty_t16fd,
         ls_final TYPE ty_final,
         ls_lfa1  TYPE ty_lfa1,
         ls_t024  TYPE ty_t024,
         lv_netwr TYPE ekpo-netwr.

*Local constants
  DATA : lc_01(2) TYPE c VALUE '01',
         lc_02(2) TYPE c VALUE '02',
         lc_03(2) TYPE c VALUE '03',
         lc_04(2) TYPE c VALUE '04',
         lc_05(2) TYPE c VALUE '05',
         lc_08(2) TYPE c VALUE '08'.

  FIELD-SYMBOLS: <ls_acc>   TYPE zzmmsg_accdet,
                 <ls_asc>   TYPE zzmmsg_ascdet,             "P30K903020
                 <ls_asi>   TYPE zzmmsg_asidet,             "P30K903020
                 <ls_rfq>   TYPE zzmmsg_rfqdet,             "P30K903020
                 <ls_ekpo>  TYPE zzmmsg_ekpodet,            "P30K903020
                 <ls_makt>  TYPE ty_makt,                   "P30K903020
                 <ls_t024w> TYPE ty_t024w.                  "P30K903020

*Select Plant name

*Fetch Plant and Name from T001W
  IF s_werks IS NOT INITIAL.
    SELECT werks
           name1
      FROM t001w
      INTO TABLE it_t001w
      WHERE werks IN s_werks.

    IF sy-subrc EQ 0.
      SORT it_t001w BY werks.
    ENDIF.
  ELSE. " If Plant is not selected on sel screen
    REFRESH : lt_ekpo.
    lt_ekpo = it_ekpo.
    SORT lt_ekpo BY werks.
    DELETE ADJACENT DUPLICATES FROM lt_ekpo COMPARING werks.

    SELECT werks
           name1
      FROM t001w
      INTO TABLE it_t001w
      FOR ALL ENTRIES IN lt_ekpo
      WHERE werks EQ lt_ekpo-werks.
    IF sy-subrc EQ 0.
      SORT it_t001w BY werks.
    ENDIF.
  ENDIF.

*Store Plant and Description in main table
  REFRESH : lt_ekpo.
  lt_ekpo = it_ekpo.


  SORT lt_ekpo BY ebeln.
*GEt unique POs.
  DELETE ADJACENT DUPLICATES FROM lt_ekpo COMPARING ebeln.

* Store Plant
  LOOP AT it_ekko INTO ls_ekko.

*Read PLant from EKPO
    READ TABLE lt_ekpo INTO ls_ekpo WITH KEY
                        ebeln = ls_ekko-ebeln.
    IF sy-subrc EQ 0.
      ls_ekko-werks = ls_ekpo-werks.
      READ TABLE it_t001w INTO ls_t001w WITH KEY werks = ls_ekpo-werks.
      IF sy-subrc EQ 0.
        ls_ekko-name1 = ls_t001w-name1.
      ELSE.
        CLEAR ls_t001w.
      ENDIF.
      MODIFY it_ekko FROM ls_ekko.
    ELSE.
      CLEAR ls_ekpo.
    ENDIF.
  ENDLOOP.

*Filter by plant if selected

  IF s_werks IS NOT INITIAL.

    LOOP AT it_ekko INTO ls_ekko.
      READ TABLE it_t001w INTO ls_t001w
               WITH KEY werks = ls_ekko-werks.
      IF sy-subrc NE 0.
        DELETE it_ekko WHERE werks = ls_ekko-werks.
      ENDIF.
    ENDLOOP.
  ENDIF.

*Calculate PO Amount

  LOOP AT it_ekko INTO ls_ekko.

*   Begin of P30K903020
    UNASSIGN: <ls_ekpo>.

    LOOP AT it_ekpo ASSIGNING <ls_ekpo>
                    WHERE     ebeln = ls_ekko-ebeln.

*     Check if Material has description
      UNASSIGN: <ls_makt>.

      READ TABLE it_makt WITH KEY  matnr = <ls_ekpo>-matnr
                         ASSIGNING <ls_makt>.

*     If Material has description
      IF sy-subrc = 0.

*       Populate Material description
        <ls_ekpo>-maktx = <ls_makt>-maktx.

      ENDIF.

*     If Account Assignment Category is not empty
      IF NOT <ls_ekpo>-knttp IS INITIAL.

*       If Multiple Account Assignment is not empty
        IF NOT <ls_ekpo>-vrtkz IS INITIAL.

          <ls_ekpo>-zicon_acc = text-ic1. "Instances exist

        ELSE. "If Multiple Account Assignment is empty

          UNASSIGN: <ls_acc>.
*         Read Account Assignment
          READ TABLE it_acc WITH KEY  ebeln = <ls_ekpo>-ebeln
                                      ebelp = <ls_ekpo>-ebelp
                            ASSIGNING <ls_acc>.

*         If found
          IF sy-subrc = 0.

            <ls_ekpo>-kostl = <ls_acc>-kostl. "Cost Center
            <ls_ekpo>-ltext = <ls_acc>-ltext. "Cost Center Description
            <ls_ekpo>-sakto = <ls_acc>-sakto. "G/L Acount
            <ls_ekpo>-txt50 = <ls_acc>-txt50. "G/L Account Description

          ENDIF.

        ENDIF.

      ENDIF.

*     Check for RFQs
      UNASSIGN: <ls_rfq>.

      READ TABLE it_rfq WITH KEY  banfn = <ls_ekpo>-banfn
                                  bnfpo = <ls_ekpo>-bnfpo
                        ASSIGNING <ls_rfq>.

      IF sy-subrc = 0.

*         Check Icon
        <ls_ekpo>-zicon_rfq = text-ic1.

      ENDIF.

*     If PO material exists
      IF NOT <ls_ekpo>-matnr IS INITIAL.

*       Check for Available Source Contracts
        UNASSIGN: <ls_asc>.

        LOOP AT it_asc ASSIGNING <ls_asc>
                           WHERE matnr = <ls_ekpo>-matnr.

          IF <ls_ekpo>-pstyp = 0.

            READ TABLE it_t024w WITH KEY  ekorg = <ls_asc>-ekorg
                                          werks = <ls_ekpo>-werks
                                ASSIGNING <ls_t024w>.

            IF sy-subrc = 0.

*             Check Icon
              <ls_ekpo>-zicon_asc = text-ic1.

            ENDIF.

          ENDIF.

        ENDLOOP.

*       Check Available Source Info Records for the PO Item
        UNASSIGN: <ls_asi>.

        READ TABLE it_asi WITH KEY  matnr = <ls_ekpo>-matnr
                          ASSIGNING <ls_asi>.

        IF sy-subrc = 0.

*         Check Icon
          <ls_ekpo>-zicon_asi = text-ic1.

        ENDIF.

      ENDIF.

*     Mark all PO value for "return items" as negative
      IF <ls_ekpo>-retpo = 'X'.

        <ls_ekpo>-netwr = <ls_ekpo>-netwr *
                          -1.

      ENDIF.

      lv_netwr = lv_netwr + <ls_ekpo>-netwr.

    ENDLOOP.
*   End   of P30K903020

    IF sy-subrc = 0.

      ls_ekko-netwr = lv_netwr.
      MODIFY it_ekko FROM ls_ekko TRANSPORTING netwr.
      CLEAR lv_netwr.

    ELSE.

      DELETE it_ekko.

    ENDIF.

  ENDLOOP.

*Rearrrange into final itab

  LOOP AT it_ekko INTO ls_ekko.
    MOVE-CORRESPONDING ls_ekko TO ls_final.
*Read entries from T16fs  for Release code
    READ TABLE it_t16fs INTO ls_t16fs WITH KEY frggr = ls_ekko-frggr
                                               frgsx = ls_ekko-frgsx.
    IF sy-subrc EQ 0.
*Check for appropriate levels and populate in the work area
*R1
      IF ls_t16fs-frgc1 IS NOT INITIAL.
*Store Description
        ls_final-r1 = ls_t16fs-frgc1.
        READ TABLE it_t16fd INTO ls_t16fd WITH KEY
                               frggr = ls_ekko-frggr
                               frgco = ls_t16fs-frgc1.
        IF sy-subrc EQ 0.
*Store Decription
          ls_final-des1 = ls_t16fd-frgct.
        ELSE.
          CLEAR ls_t16fd.
        ENDIF.
*Store release status
        ls_final-st1 = ls_ekko-frgzu+0(1).
      ELSE.
        CLEAR ls_t16fs.
      ENDIF.
*R2
      IF ls_t16fs-frgc2 IS NOT INITIAL.
        ls_final-r2 = ls_t16fs-frgc2.
        READ TABLE it_t16fd INTO ls_t16fd WITH KEY
                               frggr = ls_ekko-frggr
                               frgco = ls_t16fs-frgc2.
        IF sy-subrc EQ 0.
*Store Decription
          ls_final-des2 = ls_t16fd-frgct.
        ELSE.
          CLEAR ls_t16fd.
        ENDIF.
*Store release status
        ls_final-st2 = ls_ekko-frgzu+1(1).
      ELSE.
        CLEAR ls_t16fs.
      ENDIF.
*R3
      IF ls_t16fs-frgc3 IS NOT INITIAL.
        ls_final-r3 = ls_t16fs-frgc3.
        READ TABLE it_t16fd INTO ls_t16fd WITH KEY
                               frggr = ls_ekko-frggr
                               frgco = ls_t16fs-frgc3.
        IF sy-subrc EQ 0.
*Store Decription
          ls_final-des3 = ls_t16fd-frgct.
        ELSE.
          CLEAR ls_t16fd.
        ENDIF.
*Store release status
        ls_final-st3 = ls_ekko-frgzu+2(1).
      ELSE.
        CLEAR ls_t16fs.
      ENDIF.
*R4
      IF ls_t16fs-frgc4 IS NOT INITIAL.
        ls_final-r4 = ls_t16fs-frgc4.
        READ TABLE it_t16fd INTO ls_t16fd WITH KEY
                               frggr = ls_ekko-frggr
                               frgco = ls_t16fs-frgc4.
        IF sy-subrc EQ 0.
*Store Decription
          ls_final-des4 = ls_t16fd-frgct.
        ELSE.
          CLEAR ls_t16fd.
        ENDIF.
*Store release status
        ls_final-st4 = ls_ekko-frgzu+3(1).
      ELSE.
        CLEAR ls_t16fs.
      ENDIF.
*R5
      IF ls_t16fs-frgc5 IS NOT INITIAL.
        ls_final-r5 = ls_t16fs-frgc5.
        READ TABLE it_t16fd INTO ls_t16fd WITH KEY
                               frggr = ls_ekko-frggr
                               frgco = ls_t16fs-frgc5.
        IF sy-subrc EQ 0.
*Store Decription
          ls_final-des5 = ls_t16fd-frgct.
        ELSE.
          CLEAR ls_t16fd.
        ENDIF.
*Store release status
        ls_final-st5 = ls_ekko-frgzu+4(1).
      ELSE.
        CLEAR ls_t16fs.
      ENDIF.
*R6
      IF ls_t16fs-frgc6 IS NOT INITIAL.
        ls_final-r6 = ls_t16fs-frgc6.
        READ TABLE it_t16fd INTO ls_t16fd WITH KEY
                               frggr = ls_ekko-frggr
                               frgco = ls_t16fs-frgc6.
        IF sy-subrc EQ 0.
*Store Decription
          ls_final-des6 = ls_t16fd-frgct.
        ELSE.
          CLEAR ls_t16fd.
        ENDIF.
*Store release status
        ls_final-st6 = ls_ekko-frgzu+5(1).
      ELSE.
        CLEAR ls_t16fs.
      ENDIF.
*R7
      IF ls_t16fs-frgc7 IS NOT INITIAL.
        ls_final-r7 = ls_t16fs-frgc7.
        READ TABLE it_t16fd INTO ls_t16fd WITH KEY
                               frggr = ls_ekko-frggr
                               frgco = ls_t16fs-frgc7.
        IF sy-subrc EQ 0.
*Store Decription
          ls_final-des7 = ls_t16fd-frgct.
        ELSE.
          CLEAR ls_t16fd.
        ENDIF.
*Store release status
        ls_final-st7 = ls_ekko-frgzu+6(1).
      ELSE.
        CLEAR ls_t16fs.
      ENDIF.
*R8
      IF ls_t16fs-frgc8 IS NOT INITIAL.
        ls_final-r8 = ls_t16fs-frgc8.
        READ TABLE it_t16fd INTO ls_t16fd WITH KEY
                               frggr = ls_ekko-frggr
                               frgco = ls_t16fs-frgc1.
        IF sy-subrc EQ 0.
*Store Decription
          ls_final-des8 = ls_t16fd-frgct.
        ELSE.
          CLEAR ls_t16fd.
        ENDIF.
*Store release status
        ls_final-st8 = ls_ekko-frgzu+7(1).
      ELSE.
        CLEAR ls_t16fs.
      ENDIF.
    ENDIF.
*Store Vendor name.
    READ TABLE it_lfa1 INTO ls_lfa1 WITH KEY lifnr = ls_ekko-lifnr.
    IF sy-subrc EQ 0.
      ls_final-vname = ls_lfa1-name1.
    ELSE.
      CLEAR ls_lfa1.
    ENDIF.
*Store Purchasing grp and description
    READ TABLE it_t024 INTO ls_t024 WITH KEY ekgrp = ls_ekko-ekgrp.
    IF sy-subrc EQ 0.
      CONCATENATE ls_ekko-ekgrp ls_t024-eknam INTO
                 ls_final-eknam SEPARATED BY space.
    ELSE.
      CLEAR ls_t024.
    ENDIF.
*Addition of Document type
    ls_final-bsart = ls_ekko-bsart.
*PO processing state
    CASE ls_ekko-procstat.
      WHEN lc_01.
        ls_final-procstat = ls_ekko-procstat.
        ls_final-prodes   = text-010.
      WHEN lc_02.
        ls_final-procstat = ls_ekko-procstat.
        ls_final-prodes   = text-011.
      WHEN lc_03.
        ls_final-procstat = ls_ekko-procstat.
        ls_final-prodes   = text-012.
      WHEN lc_04.
        ls_final-procstat = ls_ekko-procstat.
        ls_final-prodes   = text-013.
      WHEN lc_05.
        ls_final-procstat = ls_ekko-procstat.
        ls_final-prodes   = text-014.
      WHEN lc_08.
        ls_final-procstat = ls_ekko-procstat.
        ls_final-prodes   = text-015.
    ENDCASE.
    APPEND ls_final TO it_final.
    CLEAR ls_final.
  ENDLOOP.

ENDFORM.                    " REARRANGE_DATA
*&---------------------------------------------------------------------*
*&      Form  FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM field_catalog .
*Local data
  DATA : ls_fldcat TYPE slis_fieldcat_alv.

  CONSTANTS : lc_c      TYPE c LENGTH 1 VALUE 'C',
              lc_l      TYPE c LENGTH 1 VALUE 'L'.

  FIELD-SYMBOLS: <ls_fldcat_acc> TYPE slis_fieldcat_alv,
                 <ls_fldcat_asc> TYPE slis_fieldcat_alv,    "P30K903020
                 <ls_fldcat_asi> TYPE slis_fieldcat_alv,    "P30K903020
                 <ls_fldcat_det> TYPE slis_fieldcat_alv,    "P30K903020
                 <ls_fldcat_rfq> TYPE slis_fieldcat_alv,    "P30K903020
                 <ls_sort_rfq>   TYPE slis_sortinfo_alv,    "P30K903020
                 <ls_sort_asc>   TYPE slis_sortinfo_alv,    "P30K903020
                 <ls_sort_asi>   TYPE slis_sortinfo_alv.    "P30K903020

  CLEAR ls_fldcat.
*Populate the contents for PO num

  ls_fldcat-fieldname = 'EBELN'.
  ls_fldcat-tabname   = 'IT_FINAL'.
  ls_fldcat-outputlen = 10.
  ls_fldcat-seltext_l = 'Purchase Ord. No.'.
  ls_fldcat-hotspot   = c_x.
  ls_fldcat-just      = lc_l.
  ls_fldcat-key       = c_x.
  APPEND ls_fldcat TO it_fldcat.

  CLEAR ls_fldcat.

*Plant
  ls_fldcat-fieldname = 'WERKS'.
  ls_fldcat-tabname   = 'IT_FINAL'.
  ls_fldcat-outputlen = 4.
  ls_fldcat-seltext_l = 'Plant'.
  ls_fldcat-just      = lc_l.
  APPEND ls_fldcat TO it_fldcat.

  CLEAR ls_fldcat.

*plant name
  ls_fldcat-fieldname =  'NAME1'.
  ls_fldcat-tabname   = 'IT_FINAL'.
  ls_fldcat-outputlen = 10.
  ls_fldcat-seltext_l = 'Plant Name'.
  ls_fldcat-just      = lc_l.
  APPEND ls_fldcat TO it_fldcat.

*Vendor

  CLEAR ls_fldcat.

  ls_fldcat-fieldname =  'LIFNR'.
  ls_fldcat-tabname   = 'IT_FINAL'.
  ls_fldcat-outputlen = 10.
  ls_fldcat-seltext_l = 'Vendor'.
  ls_fldcat-just      = lc_l.
  APPEND ls_fldcat TO it_fldcat.

*Vendor name

  CLEAR ls_fldcat.

  ls_fldcat-fieldname =  'VNAME'.
  ls_fldcat-tabname   = 'IT_FINAL'.
  ls_fldcat-outputlen = 15.
  ls_fldcat-seltext_l = 'Vendor Name'.
  ls_fldcat-just      = lc_l.
  APPEND ls_fldcat TO it_fldcat.

*Net Amount

  CLEAR ls_fldcat.

  ls_fldcat-fieldname =  'NETWR'.
  ls_fldcat-tabname   = 'IT_FINAL'.
  ls_fldcat-cfieldname = 'WAERS'.
  ls_fldcat-outputlen = 20.
  ls_fldcat-seltext_l = 'Total PO Value'.
  ls_fldcat-just      = 'R'.
  APPEND ls_fldcat TO it_fldcat.

*Currency

  CLEAR ls_fldcat.

  ls_fldcat-fieldname = 'WAERS'.
  ls_fldcat-tabname   = 'IT_FINAL'.
  ls_fldcat-outputlen = 4.
  ls_fldcat-seltext_l = 'Document Currency'.
  ls_fldcat-just      = lc_l.
  APPEND ls_fldcat TO it_fldcat.

*Purchaser

  CLEAR ls_fldcat.

  ls_fldcat-fieldname = 'ERNAM'.
  ls_fldcat-tabname   = 'IT_FINAL'.
  ls_fldcat-outputlen = 12.
  ls_fldcat-seltext_l = 'Purchaser'.
  ls_fldcat-just      = lc_l.
  APPEND ls_fldcat TO it_fldcat.

*Purchase grp

  CLEAR ls_fldcat.

  ls_fldcat-fieldname = 'EKNAM'.
  ls_fldcat-tabname   = 'IT_FINAL'.
  ls_fldcat-outputlen = 22.
  ls_fldcat-seltext_l = 'Purchasing Group'.
  ls_fldcat-just      = lc_l.
  APPEND ls_fldcat TO it_fldcat.
*
*Release Group
  CLEAR ls_fldcat.

  ls_fldcat-fieldname = 'FRGGR'.
  ls_fldcat-tabname   = 'IT_FINAL'.
  ls_fldcat-outputlen = 2.
  ls_fldcat-seltext_l = 'Release Group'.
  ls_fldcat-just      = lc_l.
  ls_fldcat-no_out    = c_x.
  APPEND ls_fldcat TO it_fldcat.
*
*
*Release strategy
  CLEAR ls_fldcat.

  ls_fldcat-fieldname = 'FRGSX'.
  ls_fldcat-tabname   = 'IT_FINAL'.
  ls_fldcat-outputlen = 2.
  ls_fldcat-seltext_l = 'Release Strategy'.
  ls_fldcat-just      = lc_l.
  ls_fldcat-no_out    = c_x.
  APPEND ls_fldcat TO it_fldcat.

*Release Code 1
  CLEAR ls_fldcat.

  ls_fldcat-fieldname = 'R1'.
  ls_fldcat-tabname   = 'IT_FINAL'.
  ls_fldcat-outputlen = 2.
  ls_fldcat-seltext_l = 'R1'.
  ls_fldcat-just      = lc_l.
  APPEND ls_fldcat TO it_fldcat.

*Release Code Description
  CLEAR ls_fldcat.

  ls_fldcat-fieldname = 'DES1'.
  ls_fldcat-tabname   = 'IT_FINAL'.
  ls_fldcat-outputlen = 20.
  ls_fldcat-seltext_l = 'R1 Desc.'.
  ls_fldcat-just      = lc_l.
  APPEND ls_fldcat TO it_fldcat.

*Release status
  CLEAR ls_fldcat.

  ls_fldcat-fieldname = 'ST1'.
  ls_fldcat-tabname   = 'IT_FINAL'.
  ls_fldcat-outputlen = 2.
  ls_fldcat-seltext_l = 'R1 St.'.
  ls_fldcat-just      = lc_l.
  APPEND ls_fldcat TO it_fldcat.


*Release Code 2
  CLEAR ls_fldcat.
  ls_fldcat-fieldname = 'R2'.
  ls_fldcat-tabname   = 'IT_FINAL'.
  ls_fldcat-outputlen = 2.
  ls_fldcat-seltext_l = 'R2'.
  ls_fldcat-just      = lc_l.
  APPEND ls_fldcat TO it_fldcat.

*Release Code Description
  CLEAR ls_fldcat.

  ls_fldcat-fieldname = 'DES2'.
  ls_fldcat-tabname   = 'IT_FINAL'.
  ls_fldcat-outputlen = 20.
  ls_fldcat-seltext_l = 'R2 Desc'.
  ls_fldcat-just      = lc_l.
  APPEND ls_fldcat TO it_fldcat.

*Release status
  CLEAR ls_fldcat.

  ls_fldcat-fieldname = 'ST2'.
  ls_fldcat-tabname   = 'IT_FINAL'.
  ls_fldcat-outputlen = 2.
  ls_fldcat-seltext_l = 'R2 St.'.
  ls_fldcat-just      = lc_l.
  APPEND ls_fldcat TO it_fldcat.

*Release Code 3
  CLEAR ls_fldcat.
  ls_fldcat-fieldname = 'R3'.
  ls_fldcat-tabname   = 'IT_FINAL'.
  ls_fldcat-outputlen = 2.
  ls_fldcat-seltext_l = 'R3'.
  ls_fldcat-just      = lc_l.
  APPEND ls_fldcat TO it_fldcat.

*Release Code Description
  CLEAR ls_fldcat.

  ls_fldcat-fieldname = 'DES3'.
  ls_fldcat-tabname   = 'IT_FINAL'.
  ls_fldcat-outputlen = 20.
  ls_fldcat-seltext_l = 'R3 Desc'.
  ls_fldcat-just      = lc_l.
  APPEND ls_fldcat TO it_fldcat.

*Release status
  CLEAR ls_fldcat.

  ls_fldcat-fieldname = 'ST3'.
  ls_fldcat-tabname   = 'IT_FINAL'.
  ls_fldcat-outputlen = 2.
  ls_fldcat-seltext_l = 'R3 St.'.
  ls_fldcat-just      = lc_l.
  APPEND ls_fldcat TO it_fldcat.


*Release Code 4
  CLEAR ls_fldcat.
  ls_fldcat-fieldname = 'R4'.
  ls_fldcat-tabname   = 'IT_FINAL'.
  ls_fldcat-outputlen = 2.
  ls_fldcat-seltext_l = 'R4'.
  ls_fldcat-just      = lc_l.
  APPEND ls_fldcat TO it_fldcat.

*Release Code Description
  CLEAR ls_fldcat.

  ls_fldcat-fieldname = 'DES4'.
  ls_fldcat-tabname   = 'IT_FINAL'.
  ls_fldcat-outputlen = 20.
  ls_fldcat-seltext_l = 'R4 Desc'.
  ls_fldcat-just      = lc_l.
  APPEND ls_fldcat TO it_fldcat.

*Release status
  CLEAR ls_fldcat.

  ls_fldcat-fieldname = 'ST4'.
  ls_fldcat-tabname   = 'IT_FINAL'.
  ls_fldcat-outputlen = 2.
  ls_fldcat-seltext_l = 'R4 St.'.
  ls_fldcat-just      = lc_l.
  APPEND ls_fldcat TO it_fldcat.


*Release Code 5
  CLEAR ls_fldcat.
  ls_fldcat-fieldname = 'R5'.
  ls_fldcat-tabname   = 'IT_FINAL'.
  ls_fldcat-outputlen = 2.
  ls_fldcat-seltext_l = 'R5'.
  ls_fldcat-just      = lc_l.
  APPEND ls_fldcat TO it_fldcat.

*Release Code Description
  CLEAR ls_fldcat.

  ls_fldcat-fieldname = 'DES5'.
  ls_fldcat-tabname   = 'IT_FINAL'.
  ls_fldcat-outputlen = 20.
  ls_fldcat-seltext_l = 'R5 Desc'.
  ls_fldcat-just      = lc_l.
  APPEND ls_fldcat TO it_fldcat.

*Release status
  CLEAR ls_fldcat.

  ls_fldcat-fieldname = 'ST5'.
  ls_fldcat-tabname   = 'IT_FINAL'.
  ls_fldcat-outputlen = 2.
  ls_fldcat-seltext_l = 'R5 St.'.
  ls_fldcat-just      = lc_l.
  APPEND ls_fldcat TO it_fldcat.

*Release Code 6
  CLEAR ls_fldcat.
  ls_fldcat-fieldname = 'R6'.
  ls_fldcat-tabname   = 'IT_FINAL'.
  ls_fldcat-outputlen = 2.
  ls_fldcat-seltext_l = 'R6'.
  ls_fldcat-just      = lc_l.
  APPEND ls_fldcat TO it_fldcat.

*Release Code Description
  CLEAR ls_fldcat.

  ls_fldcat-fieldname = 'DES6'.
  ls_fldcat-tabname   = 'IT_FINAL'.
  ls_fldcat-outputlen = 20.
  ls_fldcat-seltext_l = 'R6 Desc'.
  ls_fldcat-just      = lc_l.
  APPEND ls_fldcat TO it_fldcat.

*Release status
  CLEAR ls_fldcat.

  ls_fldcat-fieldname = 'ST6'.
  ls_fldcat-tabname   = 'IT_FINAL'.
  ls_fldcat-outputlen = 2.
  ls_fldcat-seltext_l = 'R6 St.'.
  ls_fldcat-just      = lc_l.
  APPEND ls_fldcat TO it_fldcat.

*Release Code 7
  CLEAR ls_fldcat.
  ls_fldcat-fieldname = 'R7'.
  ls_fldcat-tabname   = 'IT_FINAL'.
  ls_fldcat-outputlen = 2.
  ls_fldcat-seltext_l = 'R7'.
  ls_fldcat-just      = lc_l.
  ls_fldcat-no_out    = c_x.
  APPEND ls_fldcat TO it_fldcat.

*Release Code Description
  CLEAR ls_fldcat.

  ls_fldcat-fieldname = 'DES7'.
  ls_fldcat-tabname   = 'IT_FINAL'.
  ls_fldcat-outputlen = 20.
  ls_fldcat-seltext_l = 'R7 Desc'.
  ls_fldcat-just      = lc_l.
  ls_fldcat-no_out    = c_x.
  APPEND ls_fldcat TO it_fldcat.

*Release status
  CLEAR ls_fldcat.

  ls_fldcat-fieldname = 'ST7'.
  ls_fldcat-tabname   = 'IT_FINAL'.
  ls_fldcat-outputlen = 2.
  ls_fldcat-seltext_l = 'R7 St.'.
  ls_fldcat-just      = lc_l.
  ls_fldcat-no_out    = c_x.
  APPEND ls_fldcat TO it_fldcat.


*Release Code 8
  CLEAR ls_fldcat.
  ls_fldcat-fieldname = 'R8'.
  ls_fldcat-tabname   = 'IT_FINAL'.
  ls_fldcat-outputlen = 2.
  ls_fldcat-seltext_l = 'R8'.
  ls_fldcat-just      = lc_l.
  ls_fldcat-no_out    = c_x.
  APPEND ls_fldcat TO it_fldcat.

*Release Code Description
  CLEAR ls_fldcat.

  ls_fldcat-fieldname = 'DES8'.
  ls_fldcat-tabname   = 'IT_FINAL'.
  ls_fldcat-outputlen = 20.
  ls_fldcat-seltext_l = 'R8 Desc'.
  ls_fldcat-just      = lc_l.
  ls_fldcat-no_out    = c_x.
  APPEND ls_fldcat TO it_fldcat.

*Release status
  CLEAR ls_fldcat.

  ls_fldcat-fieldname = 'ST8'.
  ls_fldcat-tabname   = 'IT_FINAL'.
  ls_fldcat-outputlen = 2.
  ls_fldcat-seltext_l = 'R8 St.'.
  ls_fldcat-just      = lc_l.
  ls_fldcat-no_out    = c_x.
  APPEND ls_fldcat TO it_fldcat.

*Document type
  CLEAR ls_fldcat.

  ls_fldcat-fieldname = 'BSART'.
  ls_fldcat-tabname   = 'IT_FINAL'.
  ls_fldcat-outputlen = 4.
  ls_fldcat-seltext_l = 'Document Type'.
  ls_fldcat-just      = lc_l.
  ls_fldcat-no_out    = c_x.
  APPEND ls_fldcat TO it_fldcat.

*Processing state
  CLEAR ls_fldcat.

  ls_fldcat-fieldname = 'PROCSTAT'.
  ls_fldcat-tabname   = 'IT_FINAL'.
  ls_fldcat-outputlen = 2.
  ls_fldcat-seltext_l = 'Pro. State'.
  ls_fldcat-just      = lc_l.
  APPEND ls_fldcat TO it_fldcat.

*Processing state Description
  CLEAR ls_fldcat.

  ls_fldcat-fieldname = 'PRODES'.
  ls_fldcat-tabname   = 'IT_FINAL'.
  ls_fldcat-outputlen = 20.
  ls_fldcat-seltext_l = 'Pro. St. Desc'.
  ls_fldcat-just      = lc_l.
  APPEND ls_fldcat TO it_fldcat.

  gs_layout-zebra = 'X'.
  gs_layout-confirmation_prompt = 'X'.
  gs_layout-get_selinfos = 'X'.
  gs_layout-group_change_edit = 'X'.

  gs_layout-detail_popup = 'X'.
  gs_layout-detail_initial_lines = 'X'.
  gs_layout-reprep   = 'X'.
  gs_layout-detail_titlebar = 'Detail Window'.
  gs_layout-colwidth_optimize = 'X'.
  gs_layout-box_fieldname     = 'CHKBX'.

* Begin of P30K903020
* Fieldcategory items for display of PO Item Details
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = text-ds1
      i_bypassing_buffer     = 'X'
    CHANGING
      ct_fieldcat            = it_fldcat_det
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

* Set order of fields for PO Items
  UNASSIGN: <ls_fldcat_det>.

  LOOP AT it_fldcat_det ASSIGNING <ls_fldcat_det>.

    CASE <ls_fldcat_det>-fieldname.

      WHEN text-f01. "Purchasing Document Number

        <ls_fldcat_det>-col_pos = 1.
        <ls_fldcat_det>-key     = 'X'.

      WHEN text-f02. "Item Number of Purchasing Document

        <ls_fldcat_det>-col_pos = 2.
        <ls_fldcat_det>-key     = 'X'.

      WHEN text-f03. "Material Number

        <ls_fldcat_det>-col_pos = 3.

      WHEN text-f04. "Short Text

        <ls_fldcat_det>-col_pos = 4.

      WHEN text-f05. "Plant

        <ls_fldcat_det>-col_pos = 6.

      WHEN text-f06. "Purchase Order Quantity

        <ls_fldcat_det>-col_pos = 7.

      WHEN text-f07. "Purchase Order Unit of Measure

        <ls_fldcat_det>-col_pos = 8.

      WHEN text-f08. "Net Price in Purchasing Document (in Document Currency)

        <ls_fldcat_det>-col_pos = 9.

      WHEN text-f09. "Price Unit

        <ls_fldcat_det>-col_pos = 10.

      WHEN text-f10. "Net Order Value in PO Currency

        <ls_fldcat_det>-col_pos = 11.

      WHEN text-f11. "Order Price Unit (Purchasing)

        <ls_fldcat_det>-col_pos = 12.

      WHEN text-f33. "Account Assignment Category (KNTTP)

        <ls_fldcat_det>-col_pos = 13.

      WHEN text-f34. "Distribution Indicator for Multiple Account Assignment (VRTKZ)

        <ls_fldcat_det>-col_pos = 14.

      WHEN text-f35. "Icon - Account Assignemnts (ZICON_ACC)

        <ls_fldcat_det>-col_pos = 15.

      WHEN text-f37. "Cost Center (KOSTL)

        <ls_fldcat_det>-col_pos = 16.

      WHEN text-f38. "Cost Center Description (LTEXT)

        <ls_fldcat_det>-col_pos = 17.

      WHEN text-f39. "G/L Account (SAKTO)

        <ls_fldcat_det>-col_pos = 18.

      WHEN text-f40. "G/L Account Description (TXT50)

        <ls_fldcat_det>-col_pos = 19.

      WHEN text-f12. "Purchase Requisition Number

        <ls_fldcat_det>-col_pos = 20.

      WHEN text-f13. "Item Number of Purchase Requisition

        <ls_fldcat_det>-col_pos = 21.

      WHEN text-f14. "RFQ Number

        <ls_fldcat_det>-col_pos = 22.

      WHEN text-f15. "Item Number of RFQ

        <ls_fldcat_det>-col_pos = 23.

      WHEN text-f16. "Number of Principal Purchase Agreement

        <ls_fldcat_det>-col_pos = 25.

      WHEN text-f17. "Item Number of Principal Purchase Agreement

        <ls_fldcat_det>-col_pos = 26.

      WHEN text-f18. "Number of Purchasing Info Record

        <ls_fldcat_det>-col_pos = 28.

      WHEN text-f19. "Returns Item

        <ls_fldcat_det>-col_pos = 30.

      WHEN text-f20. "Material Description (Short Text)

        <ls_fldcat_det>-col_pos = 5.

      WHEN text-f21. "Purchasing Document Category

        <ls_fldcat_det>-no_out = 'X'.

      WHEN text-f22. "RFQ Documents? (Icon)

        <ls_fldcat_det>-col_pos = 24.

      WHEN text-f24. "AS Contracts? (Icon)

        <ls_fldcat_det>-col_pos = 27.

      WHEN text-f25. "Item Category in Purchasing Document

        <ls_fldcat_det>-no_out = 'X'.

      WHEN text-f26. "AS Info Records? (Icon)

        <ls_fldcat_det>-col_pos = 29.

      WHEN text-f27. "Vendor

        <ls_fldcat_det>-no_out = 'X'.

      WHEN text-f36. "Company Code (BUKRS)

        <ls_fldcat_det>-no_out = 'X'.

    ENDCASE.

  ENDLOOP.

* Set PO Item Layout Settings
  gs_layout_det-zebra = 'X'.
  gs_layout_det-colwidth_optimize = 'X'.
  gs_layout_det-window_titlebar = text-t01.

* Fieldcategory items for display of RFQ Purchase Documents
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = text-ds2
      i_bypassing_buffer     = 'X'
    CHANGING
      ct_fieldcat            = it_fldcat_rfq
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

* Set Order of Fields for RFQ Purchase Documents
  UNASSIGN: <ls_fldcat_rfq>.

  LOOP AT it_fldcat_rfq ASSIGNING <ls_fldcat_rfq>.

    CASE <ls_fldcat_rfq>-fieldname.

      WHEN text-f30. "Reference PO Number

        <ls_fldcat_rfq>-col_pos = 1.
        <ls_fldcat_rfq>-key     = 'X'.

      WHEN text-f31. "Reference PO Item

        <ls_fldcat_rfq>-col_pos = 2.
        <ls_fldcat_rfq>-key     = 'X'.

      WHEN text-f01. "Purchasing Document Number

        <ls_fldcat_rfq>-col_pos = 3.

      WHEN text-f02. "Item Number of Purchasing Document

        <ls_fldcat_rfq>-col_pos = 4.

      WHEN text-f33. "Date of Price Determination

        <ls_fldcat_rfq>-no_out = 'X'.

      WHEN text-f32. "RFQ = PO reference

        <ls_fldcat_rfq>-col_pos = 5.

      WHEN text-f12. "Purchase Requisition Number

        <ls_fldcat_rfq>-no_out = 'X'.

      WHEN text-f13. "Item Number of Purchase Requisition

        <ls_fldcat_rfq>-no_out = 'X'.

      WHEN text-f34. "Rate (condition amount or percentage) where no scale exists

        <ls_fldcat_rfq>-col_pos = 6.

      WHEN text-f35. "Rate unit (currency or percentage)

        <ls_fldcat_rfq>-col_pos = 7.

      WHEN text-f36. "Condition pricing unit

        <ls_fldcat_rfq>-col_pos = 8.

      WHEN text-f37. "Condition unit

        <ls_fldcat_rfq>-col_pos = 9.

    ENDCASE.

  ENDLOOP.

* Set RFQ Purchase Document Layout Settings
  gs_layout_rfq-zebra = 'X'.
  gs_layout_rfq-colwidth_optimize = 'X'.
  gs_layout_rfq-window_titlebar = text-t02.

* Set RFQ Sort Settings
  UNASSIGN: <ls_sort_rfq>.
  APPEND INITIAL LINE TO it_sort_rfq ASSIGNING <ls_sort_rfq>.
  <ls_sort_rfq>-spos      = 1.
  <ls_sort_rfq>-fieldname = text-f30.

  UNASSIGN: <ls_sort_rfq>.
  APPEND INITIAL LINE TO it_sort_rfq ASSIGNING <ls_sort_rfq>.
  <ls_sort_rfq>-spos      = 2.
  <ls_sort_rfq>-fieldname = text-f31.

* Fieldcategory items for display of Available Source Contracts
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = text-ds3
      i_bypassing_buffer     = 'X'
    CHANGING
      ct_fieldcat            = it_fldcat_asc
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

* Set Order of Fields for Available Source Contracts
  UNASSIGN: <ls_fldcat_asc>.

  LOOP AT it_fldcat_asc ASSIGNING <ls_fldcat_asc>.

    CASE <ls_fldcat_asc>-fieldname.

      WHEN text-f30. "Reference PO Number

        <ls_fldcat_asc>-col_pos = 1.
        <ls_fldcat_asc>-key     = 'X'.

      WHEN text-f31. "Reference PO Item

        <ls_fldcat_asc>-col_pos = 2.
        <ls_fldcat_asc>-key     = 'X'.

      WHEN text-f03. "Material Number

        <ls_fldcat_asc>-col_pos = 3.
        <ls_fldcat_asc>-key     = 'X'.

      WHEN text-f16. "Number of Principal Purchase Agreement

        <ls_fldcat_asc>-col_pos = 4.

      WHEN text-f17. "Item Number of Principal Purchase Agreement

        <ls_fldcat_asc>-col_pos = 5.

      WHEN text-f05. "Plant

        <ls_fldcat_asc>-no_out = 'X'.

      WHEN text-f33. "Date of Price Determination

        <ls_fldcat_asc>-no_out = 'X'.

      WHEN text-f32. "ASC = PO reference

        <ls_fldcat_asc>-col_pos = 6.

      WHEN text-f23. "Purchasing Organization

        <ls_fldcat_asc>-no_out = 'X'.

      WHEN text-f34. "Rate (condition amount or percentage) where no scale exists

        <ls_fldcat_asc>-col_pos = 7.

      WHEN text-f35. "Rate unit (currency or percentage)

        <ls_fldcat_asc>-col_pos = 8.

      WHEN text-f36. "Condition pricing unit

        <ls_fldcat_asc>-col_pos = 9.

      WHEN text-f37. "Condition unit

        <ls_fldcat_asc>-col_pos = 10.

    ENDCASE.

  ENDLOOP.

* Set Available Source Contracts Layout Settings
  gs_layout_asc-zebra = 'X'.
  gs_layout_asc-colwidth_optimize = 'X'.
  gs_layout_asc-window_titlebar = text-t03.

* Set ASC Sort Settings
  UNASSIGN: <ls_sort_asc>.
  APPEND INITIAL LINE TO it_sort_asc ASSIGNING <ls_sort_asc>.
  <ls_sort_asc>-spos      = 1.
  <ls_sort_asc>-fieldname = text-f30.

  UNASSIGN: <ls_sort_asc>.
  APPEND INITIAL LINE TO it_sort_asc ASSIGNING <ls_sort_asc>.
  <ls_sort_asc>-spos      = 2.
  <ls_sort_asc>-fieldname = text-f31.

  UNASSIGN: <ls_sort_asc>.
  APPEND INITIAL LINE TO it_sort_asc ASSIGNING <ls_sort_asc>.
  <ls_sort_asc>-spos      = 3.
  <ls_sort_asc>-fieldname = text-f03.

* Fieldcategory items for display of Available Source Info Records
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = text-ds4
      i_bypassing_buffer     = 'X'
    CHANGING
      ct_fieldcat            = it_fldcat_asi
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

* Set Order of Fields for Available Source Info Records
  UNASSIGN: <ls_fldcat_asi>.

  LOOP AT it_fldcat_asi ASSIGNING <ls_fldcat_asi>.

    CASE <ls_fldcat_asi>-fieldname.

      WHEN text-f30. "Reference PO Number

        <ls_fldcat_asi>-col_pos = 1.
        <ls_fldcat_asi>-key     = 'X'.

      WHEN text-f31. "Reference PO Item

        <ls_fldcat_asi>-col_pos = 2.
        <ls_fldcat_asi>-key     = 'X'.

      WHEN text-f03. "Material Number

        <ls_fldcat_asi>-col_pos = 3.
        <ls_fldcat_asi>-key     = 'X'.

      WHEN text-f18. "Number of Purchasing Info Record

        <ls_fldcat_asi>-col_pos = 4.

      WHEN text-f23. "Purchasing Organization

        <ls_fldcat_asi>-col_pos = 5.

      WHEN text-f05. "Plant

        <ls_fldcat_asi>-col_pos = 6.

      WHEN text-f33. "Price Valid Until

        <ls_fldcat_asi>-no_out = 'X'.

      WHEN text-f27. "Vendor Account Number

        <ls_fldcat_asi>-no_out = 'X'.

      WHEN text-f32. "ASI = PO reference

        <ls_fldcat_asi>-col_pos = 7.

      WHEN text-f29. "Flag (Consignment)

        <ls_fldcat_asi>-no_out = 'X'.

      WHEN text-f28. "Purchasing info record category

        <ls_fldcat_asi>-no_out = 'X'.

      WHEN text-f34. "Rate (condition amount or percentage) where no scale exists

        <ls_fldcat_asi>-col_pos = 8.

      WHEN text-f35. "Rate unit (currency or percentage)

        <ls_fldcat_asi>-col_pos = 9.

      WHEN text-f36. "Condition pricing unit

        <ls_fldcat_asi>-col_pos = 10.

      WHEN text-f37. "Condition unit

        <ls_fldcat_asi>-col_pos = 11.

    ENDCASE.

  ENDLOOP.

* Set Available Source Info Records Layout Settings
  gs_layout_asi-zebra = 'X'.
  gs_layout_asi-colwidth_optimize = 'X'.
  gs_layout_asi-window_titlebar = text-t04.

* Set Available Source Info Records Layout Settings
  gs_layout_asi-zebra = 'X'.
  gs_layout_asi-colwidth_optimize = 'X'.
  gs_layout_asi-window_titlebar = text-t04.

* Set ASI Sort Settings
  UNASSIGN: <ls_sort_asi>.
  APPEND INITIAL LINE TO it_sort_asi ASSIGNING <ls_sort_asi>.
  <ls_sort_asi>-spos      = 1.
  <ls_sort_asi>-fieldname = text-f30.

  UNASSIGN: <ls_sort_asi>.
  APPEND INITIAL LINE TO it_sort_asi ASSIGNING <ls_sort_asi>.
  <ls_sort_asi>-spos      = 2.
  <ls_sort_asi>-fieldname = text-f31.

  UNASSIGN: <ls_sort_asi>.
  APPEND INITIAL LINE TO it_sort_asi ASSIGNING <ls_sort_asi>.
  <ls_sort_asi>-spos      = 3.
  <ls_sort_asi>-fieldname = text-f03.
* End   of P30K903020

* Set ACC Account Assignment Layout Settings
  gs_layout_acc-zebra = 'X'.
  gs_layout_acc-colwidth_optimize = 'X'.
  gs_layout_acc-window_titlebar = text-t05.

* Fieldcategory items for display of Account Assignments
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = text-ds5
      i_bypassing_buffer     = 'X'
    CHANGING
      ct_fieldcat            = it_fldcat_acc
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  UNASSIGN: <ls_fldcat_acc>.
* Loop at Account Assginment FieldCategory
  LOOP AT it_fldcat_acc ASSIGNING <ls_fldcat_acc>.

    CASE <ls_fldcat_acc>-fieldname.

      WHEN text-f01. "PO (EBELN)

        <ls_fldcat_acc>-key = c_x. "Key Field

      WHEN text-f02. "PO Item (EBELP)

        <ls_fldcat_acc>-key = c_x. "Key Field

      WHEN text-f42. "Sequence Number (ZEKKN)

        <ls_fldcat_acc>-key = c_x. "Key Field

      WHEN text-f41. "Controlling Area (KOKRS)

        <ls_fldcat_acc>-no_out = c_x. "Do not Display

    ENDCASE.

  ENDLOOP.

ENDFORM.                    " FIELD_CATALOG
*&---------------------------------------------------------------------*
*&      Form  pf_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM pf_status USING extab TYPE slis_t_extab..
*&---------------------------------------------------------------------*
*&      Form  PF_STATUS
*&---------------------------------------------------------------------*
  SET PF-STATUS 'ZPOAPP' EXCLUDING extab..
ENDFORM.                    "pf_status
*&---------------------------------------------------------------------*
*&      Form  ALV_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM alv_display .
*Local Data
  DATA: lvc_s_glay TYPE lvc_s_glay,
        ls_variant TYPE disvariant.

  ls_variant-report = sy-repid.
  ls_variant-handle = 'FIRST'.

*Call function module to display ALV grid

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-cprog
      i_callback_pf_status_set = 'PF_STATUS'
      i_callback_user_command  = 'USR_COMM'
      i_grid_settings          = lvc_s_glay
      is_layout                = gs_layout
      it_fieldcat              = it_fldcat
      i_default                = c_x
      i_save                   = c_a
      is_variant               = ls_variant
    TABLES
      t_outtab                 = it_final.

ENDFORM.                    " ALV_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  FETCH_RELCODES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM fetch_relcodes .
*Local data declaration
  DATA : lt_ekko TYPE STANDARD TABLE OF ty_ekko.

  lt_ekko = it_ekko.
  SORT lt_ekko BY frggr frgsx.

  DELETE ADJACENT DUPLICATES FROM lt_ekko
                   COMPARING frggr frgsx.
*Fetch Release codes
  SELECT frggr
         frgsx
         frgc1
         frgc2
         frgc3
         frgc4
         frgc5
         frgc6
         frgc7
         frgc8
    FROM t16fs
    INTO TABLE it_t16fs
    FOR ALL ENTRIES IN lt_ekko
    WHERE frggr = lt_ekko-frggr
    AND   frgsx = lt_ekko-frgsx.                      "#EC CI_SGLSELECT

*Select all release code descriptions.

  SELECT frggr
         frgco
         frgct
    FROM t16fd
    INTO TABLE it_t16fd
    WHERE spras = sy-langu.                           "#EC CI_SGLSELECT

  SORT it_t16fd BY frggr frgco.

  REFRESH : lt_ekko.
ENDFORM.                    " FETCH_RELCODES
*&---------------------------------------------------------------------*
*&      Form  VENDOR_NAMES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM vendor_names .
*Local Data declaration
  DATA : lt_ekko TYPE STANDARD TABLE OF ty_ekko.

  lt_ekko = it_ekko.
  SORT lt_ekko BY lifnr.
  DELETE ADJACENT DUPLICATES FROM lt_ekko
  COMPARING lifnr.

*Fetch Vendor names.
  SELECT lifnr
         name1
    FROM lfa1
    INTO TABLE it_lfa1
    FOR ALL ENTRIES IN lt_ekko
    WHERE lifnr = lt_ekko-lifnr.
  IF sy-subrc EQ 0.
    SORT it_lfa1 BY lifnr.
  ENDIF.

  REFRESH lt_ekko.
ENDFORM.                    " VENDOR_NAMES
*&---------------------------------------------------------------------*
*&      Form  usr_comm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->IN_UCOMM     text
*      -->IN_SELFIELD  text
*----------------------------------------------------------------------*
FORM usr_comm USING  in_ucomm LIKE sy-ucomm
                             in_selfield TYPE slis_selfield.
*Local Data
  DATA : ls_final  TYPE ty_final,
         lt_return TYPE STANDARD TABLE OF bapireturn,
         ls_return TYPE bapireturn,
         lv_relst  TYPE bapimmpara-rel_status,
         lv_relind TYPE bapimmpara-po_rel_ind,
         lv_subrc  TYPE sy-subrc,
         lv_frgco  TYPE frgco,
         lv_ans    TYPE char1,
         ls_audit  TYPE ty_audit,
         lt_fldcat TYPE slis_t_fieldcat_alv.

* Begin of P30K903020
  FIELD-SYMBOLS: <ls_ekpo>  TYPE zzmmsg_ekpodet,
                 <ls_final> TYPE ty_final.
* End   of P30K903020

  CONSTANTS : lc_1 TYPE char1 VALUE '1',
              lc_2 TYPE char1 VALUE '2',
              lc_det(4)                VALUE 'DET',         "P30K903020
              lc_succ  TYPE c LENGTH 4  VALUE '@08@',
              lc_err   TYPE c LENGTH 4  VALUE '@0A@',
              lc_hsp   TYPE c LENGTH 4 VALUE '&IC1'.

*Refresh internal tables
  REFRESH : it_audit, lt_fldcat, lt_return.
  READ TABLE it_final INTO ls_final WITH KEY chkbx = c_x.
*Process the selected entries on the screen
  IF in_ucomm = c_app.
    IF  ls_final IS NOT INITIAL.
      CLEAR ls_final.
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          titlebar       = text-003
          text_question  = text-004
          text_button_1  = text-005
          text_button_2  = text-006
        IMPORTING
          answer         = lv_ans
        EXCEPTIONS
          text_not_found = 1
          OTHERS         = 2.
      IF sy-subrc EQ 0.
        IF lv_ans = lc_1. " If Yes
          LOOP AT it_final INTO ls_final WHERE chkbx = c_x.
*Exract the Release code which is relevant
            IF ls_final-st1 NE c_x.
              lv_frgco = ls_final-r1.
            ELSEIF ls_final-st2 NE c_x.
              lv_frgco = ls_final-r2.
            ELSEIF ls_final-st3 NE c_x.
              lv_frgco = ls_final-r3.
            ELSEIF ls_final-st4 NE c_x.
              lv_frgco = ls_final-r4.
            ELSEIF ls_final-st5 NE c_x.
              lv_frgco = ls_final-r5.
            ELSEIF ls_final-st6 NE c_x.
              lv_frgco = ls_final-r6.
            ELSEIF ls_final-st7 NE c_x.
              lv_frgco = ls_final-r7.
            ELSEIF ls_final-st8 NE c_x.
              lv_frgco = ls_final-r8.
            ENDIF.
*Call Bapi to release PO
            CALL FUNCTION 'BAPI_PO_RELEASE'
              EXPORTING
                purchaseorder          = ls_final-ebeln
                po_rel_code            = lv_frgco
                use_exceptions         = 'X'
              IMPORTING
                rel_status_new         = lv_relst
                rel_indicator_new      = lv_relind
                ret_code               = lv_subrc
              TABLES
                return                 = lt_return
              EXCEPTIONS
                authority_check_fail   = 1
                document_not_found     = 2
                enqueue_fail           = 3
                prerequisite_fail      = 4
                release_already_posted = 5
                responsibility_fail    = 6
                OTHERS                 = 7.
*Store Return Messages
            CLEAR ls_audit.
            LOOP AT lt_return INTO ls_return WHERE type = c_e.
              ls_audit-icon  = lc_err.
              ls_audit-ebeln = ls_final-ebeln.
              ls_audit-msg   = ls_return-message.
              APPEND ls_audit TO it_audit.
            ENDLOOP.
            IF sy-subrc NE 0. "Populate msg that PO has been released
              ls_audit-icon  = lc_succ.
              ls_audit-ebeln = ls_final-ebeln.
              ls_audit-msg   = text-008.
              APPEND ls_audit TO it_audit.
            ENDIF.
            REFRESH : lt_return.
            CLEAR ls_return.
          ENDLOOP.
*Populate Field Catalog
          PERFORM fldcat CHANGING lt_fldcat.
          PERFORM display_audit USING lt_fldcat.
        ENDIF.
      ENDIF.
    ELSE."Message that the user needs to select atleast one entry.
      MESSAGE text-007 TYPE c_s.
    ENDIF.
  ELSEIF in_ucomm = lc_hsp. "Display PO
    CLEAR ls_final.
    READ TABLE it_final INTO ls_final INDEX in_selfield-tabindex.
    IF sy-subrc EQ 0.
      SET PARAMETER ID: 'BES' FIELD ls_final-ebeln.
*Start of changes by Venkatesh<VEGOPALARATH> on 17-Jan-2011
*      CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
      CALL TRANSACTION 'ME29N' AND SKIP FIRST SCREEN.
*End of changes by Venkatesh<VEGOPALARATH> on 17-Jan-2011
    ENDIF.
  ELSEIF in_ucomm = '&F03'.
    LEAVE LIST-PROCESSING.
* Begin of P30K903020
  ELSEIF in_ucomm = lc_det.

    REFRESH: it_ekpo_det.

    UNASSIGN: <ls_final>.

*   Loop at selected header records
    LOOP AT it_final ASSIGNING <ls_final>
                     WHERE     chkbx = c_x.

*     Loop at PO Items
      UNASSIGN <ls_ekpo>.

      LOOP AT it_ekpo ASSIGNING <ls_ekpo>
                      WHERE     ebeln = <ls_final>-ebeln.

*       Populate relevant records based on selected PO
        APPEND <ls_ekpo> TO it_ekpo_det.

      ENDLOOP.

    ENDLOOP.

*   Display PO Item Screen
    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY' "#EC CI_FLDEXT_OK[2215424] P30K910038
      EXPORTING
        i_callback_program      = sy-cprog
        i_callback_user_command = 'UC_PO'
        is_layout               = gs_layout_det
        it_fieldcat             = it_fldcat_det
        i_default               = c_x
        i_save                  = c_a
        is_variant              = gs_variant_det
      TABLES
        t_outtab                = it_ekpo_det.
* End   of P30K903020

  ENDIF.
ENDFORM.                    "usr_comm
*&---------------------------------------------------------------------*
*&      Form  FLDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--LT_FLDCAT  text
*----------------------------------------------------------------------*
FORM fldcat  CHANGING lt_fldcat TYPE slis_t_fieldcat_alv.
*Local constants
  CONSTANTS : lc_audit(5) TYPE c VALUE 'IT_AUDIT',
              lc_icon(4)  TYPE c VALUE 'ICON',
              lc_ebeln(5) TYPE c VALUE 'EBELN',
              lc_msg(3)   TYPE c VALUE 'MSG',
              lc_c(1)     TYPE c VALUE 'C',
              lc_l(1)     TYPE c VALUE 'L',
              lc_r(1)     TYPE c VALUE 'R'.

  DATA : ls_fldcat TYPE slis_fieldcat_alv.

*Populate the contents for 'ICON'  field
  ls_fldcat-fieldname = lc_icon.
  ls_fldcat-tabname   = lc_audit.
  ls_fldcat-outputlen = 5.
  ls_fldcat-seltext_l = 'Status'.
  ls_fldcat-just      = lc_c.
  APPEND ls_fldcat TO lt_fldcat.

  CLEAR ls_fldcat.

*Populate contents for 'EBELN' field
  ls_fldcat-fieldname = lc_ebeln.
  ls_fldcat-tabname   = lc_audit.
  ls_fldcat-outputlen = 15.
  ls_fldcat-seltext_l = 'Purchase Order No.'.
  ls_fldcat-just      = lc_l.
  APPEND ls_fldcat TO lt_fldcat.

  CLEAR ls_fldcat.

*Populate contents for 'EBELN' field
  ls_fldcat-fieldname = lc_msg.
  ls_fldcat-tabname   = lc_audit.
  ls_fldcat-outputlen = 100.
  ls_fldcat-seltext_l = 'Success/Error Message'.
  ls_fldcat-just      = lc_c.
  APPEND ls_fldcat TO lt_fldcat.


ENDFORM.                    " FLDCAT
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_AUDIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LT_FLDAT  text
*----------------------------------------------------------------------*
FORM display_audit  USING lt_fldat TYPE slis_t_fieldcat_alv.
*Local Data
  DATA: lvc_s_glay TYPE lvc_s_glay,
        ls_variant TYPE disvariant.

  ls_variant-report = sy-repid.
  ls_variant-handle = 'SECOND'.

*Call function module to display ALV grid

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-cprog
      i_grid_settings    = lvc_s_glay
      i_grid_title       = text-009
      it_fieldcat        = lt_fldat
      i_default          = c_x
      i_save             = c_a
      is_variant         = ls_variant
    TABLES
      t_outtab           = it_audit.

  CLEAR lvc_s_glay.
ENDFORM.                    " DISPLAY_AUDIT

*Begin of P30K903020
*&---------------------------------------------------------------------*
*&      Form  FETCH_A016
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fetch_a016 .

  DATA: l_loevm_ko TYPE konp-loevm_ko.

  IF NOT it_rfq IS INITIAL.

    SELECT evrtn
           evrtp
           datbi
           datab
           knumh
      FROM a016
      APPENDING TABLE it_a016
       FOR ALL ENTRIES IN it_rfq
     WHERE evrtn =  it_rfq-ebeln AND
           evrtp =  it_rfq-ebelp AND
           datab <= it_rfq-prdat AND
           datbi >= it_rfq-prdat AND
           kappl =  c_m          AND
           kschl =  c_pb00.

  ENDIF.

  IF NOT it_asc IS INITIAL.

    SELECT evrtn
           evrtp
           datbi
           datab
           knumh
      FROM a016
      APPENDING TABLE it_a016
       FOR ALL ENTRIES IN it_asc
     WHERE evrtn =  it_asc-konnr AND
           evrtp =  it_asc-ktpnr AND
           datbi >= it_asc-prdat AND
           datab <= it_asc-prdat AND
           kappl =  c_m          AND
           kschl =  c_pb00.

  ENDIF.

  IF NOT it_a016 IS INITIAL.

    SORT it_a016 BY evrtn
                    evrtp.

    SELECT knumh
           konwa
           kpein
           kmein
           kbetr
      FROM konp
      APPENDING TABLE it_konp
       FOR ALL ENTRIES IN it_a016
     WHERE knumh    = it_a016-knumh AND
           kappl    = c_m           AND
           kschl    = c_pb00        AND
           loevm_ko = l_loevm_ko.

    IF sy-subrc = 0.

      SORT it_konp BY knumh.

    ENDIF.

  ENDIF.

ENDFORM.                    " FETCH_A016

*&---------------------------------------------------------------------*
*&      Form  FETCH_A017
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fetch_a017 .

  DATA: l_loevm_ko TYPE konp-loevm_ko,

        lt_asi     TYPE STANDARD TABLE OF zzmmsg_asidet.

  lt_asi[] = it_asi.

  DELETE lt_asi WHERE werks IS INITIAL.

  IF NOT lt_asi IS INITIAL.

    SELECT lifnr
           matnr
           ekorg
           werks
           esokz
           datbi
           datab
           knumh
      FROM a017
      INTO TABLE it_a017
       FOR ALL ENTRIES IN lt_asi
     WHERE lifnr =  lt_asi-lifnr AND
           matnr =  lt_asi-matnr AND
           ekorg =  lt_asi-ekorg AND
           werks =  lt_asi-werks AND
           esokz =  lt_asi-esokz AND
           datbi >= lt_asi-prdat AND
           datab <= lt_asi-prdat AND
           kappl =  c_m          AND
           kschl =  c_pb00.

    IF sy-subrc = 0.

      SORT it_a017 BY lifnr
                      matnr
                      ekorg
                      werks
                      esokz.

      SELECT knumh
             konwa
             kpein
             kmein
             kbetr
        FROM konp
        APPENDING TABLE it_konp
         FOR ALL ENTRIES IN it_a017
       WHERE knumh    = it_a017-knumh AND
             kappl    = c_m           AND
             kschl    = c_pb00        AND
             loevm_ko = l_loevm_ko.

      IF sy-subrc = 0.

        SORT it_konp BY knumh.

      ENDIF.

    ENDIF.

  ENDIF.

ENDFORM.                    " FETCH_A017

*&---------------------------------------------------------------------*
*&      Form  FETCH_A018
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fetch_a018 .

  DATA: l_loevm_ko TYPE konp-loevm_ko,

        lt_asi     TYPE STANDARD TABLE OF zzmmsg_asidet.

  lt_asi[] = it_asi.

  DELETE lt_asi WHERE NOT werks IS INITIAL.

  IF NOT lt_asi IS INITIAL.

    SELECT lifnr
           matnr
           ekorg
           esokz
           datbi
           datab
           knumh
      FROM a018
      INTO TABLE it_a018
       FOR ALL ENTRIES IN lt_asi
     WHERE lifnr =  lt_asi-lifnr AND
           matnr =  lt_asi-matnr AND
           ekorg =  lt_asi-ekorg AND
           esokz =  lt_asi-esokz AND
           datab <= lt_asi-prdat AND
           datbi >= lt_asi-prdat AND
           kappl =  c_m          AND
           kschl =  c_pb00.

    IF sy-subrc = 0.

      SORT it_a018 BY lifnr
                      matnr
                      ekorg
                      esokz.

      SELECT knumh
             konwa
             kpein
             kmein
             kbetr
        FROM konp
        APPENDING TABLE it_konp
         FOR ALL ENTRIES IN it_a018
       WHERE knumh    = it_a018-knumh AND
             kappl    = c_m           AND
             kschl    = c_pb00        AND
             loevm_ko = l_loevm_ko.

      IF sy-subrc = 0.

        SORT it_konp BY knumh.

      ENDIF.

    ENDIF.

  ENDIF.

ENDFORM.                    " FETCH_A018

*&---------------------------------------------------------------------*
*&      Form  FETCH_ACC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fetch_acc.

  DATA: lv_loekz.

  FIELD-SYMBOLS: <ls_acc>  TYPE zzmmsg_accdet,
                 <ls_cskt> TYPE cskt,
                 <ls_skat> TYPE skat.

  REFRESH: it_acc.

* If PO Items exist
  IF NOT it_ekpo[] IS INITIAL.

*   Get Account Assignments
    SELECT ebeln
           ebelp
           zekkn
           menge
           vproz
           netwr
           kokrs
           kostl
           sakto
      FROM ekkn
      INTO TABLE it_acc
       FOR ALL ENTRIES IN it_ekpo
     WHERE ebeln = it_ekpo-ebeln AND
           ebelp = it_ekpo-ebelp AND
           loekz = lv_loekz.

*   If successful
    IF sy-subrc = 0.

*     Get Cost Center Descriptions
      SELECT *
        FROM cskt
        INTO TABLE it_cskt
         FOR ALL ENTRIES IN it_acc
       WHERE spras = sy-langu     AND
             kokrs = it_acc-kokrs AND
             kostl = it_acc-kostl.

*     Get G/L Account Descriptions
      SELECT *
        FROM skat
        INTO TABLE it_skat
         FOR ALL ENTRIES IN it_acc
       WHERE spras = sy-langu     AND
             ktopl = c_ucoa       AND
             saknr = it_acc-sakto.

      break mmirasol.

      UNASSIGN: <ls_acc>.
*     Loop at Account Assignments
      LOOP AT it_acc ASSIGNING <ls_acc>.

        UNASSIGN: <ls_cskt>.
*       Get Cost Center Description
        READ TABLE it_cskt WITH KEY  kokrs = <ls_acc>-kokrs
                                     kostl = <ls_acc>-kostl
                           ASSIGNING <ls_cskt>.

*       If found
        IF sy-subrc = 0.

          <ls_acc>-ltext = <ls_cskt>-ltext. "Cost Center Description

        ENDIF.

        UNASSIGN: <ls_skat>.
*       Get G/L Account Description
        READ TABLE it_skat WITH KEY  ktopl = c_ucoa
                                     saknr = <ls_acc>-sakto
                           ASSIGNING <ls_skat>.

*       If found
        IF sy-subrc = 0.

          <ls_acc>-txt50 = <ls_skat>-txt50. "G/L Account Description

        ENDIF.

      ENDLOOP.

    ENDIF.

  ENDIF.

ENDFORM.                    " FETCH_ACC

*&---------------------------------------------------------------------*
*&      Form  FETCH_ASC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fetch_asc .

  DATA: l_loekz TYPE                   ekpo-loekz,

        lt_ekpo TYPE STANDARD TABLE OF zzmmsg_ekpodet.

  IF NOT it_ekpo IS INITIAL.

    REFRESH: it_asc.

*   Create temporary records
    lt_ekpo[] = it_ekpo[].

*   Delete temp records with empty materials
    DELETE: lt_ekpo WHERE matnr IS INITIAL,
            lt_ekpo WHERE pstyp =  c_2.

    IF NOT lt_ekpo[] IS INITIAL.

      SELECT ekpo~matnr
             ekpo~ebeln
             ekpo~ebelp
             ekpo~werks
             ekpo~prdat
             ekko~ekorg
        FROM ekko
        JOIN ekpo ON ekko~ebeln = ekpo~ebeln
        INTO TABLE it_asc
         FOR ALL ENTRIES IN lt_ekpo
       WHERE ekko~bstyp =  c_k           AND
             ekpo~matnr =  lt_ekpo-matnr AND
             ekpo~loekz =  l_loekz       AND
             ekko~kdatb <= lt_ekpo-bedat AND
             ekko~kdate >= lt_ekpo-bedat.

      IF sy-subrc = 0.

        SORT it_asc BY matnr
                       konnr
                       ktpnr.

      ENDIF.

    ENDIF.

  ENDIF.

ENDFORM.                    " FETCH_ASC

*&---------------------------------------------------------------------*
*&      Form  FETCH_ASI_CONN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fetch_asi_conn.

  IF NOT it_ekpo IS INITIAL.

    DATA: l_loekz TYPE eina-loekz,
          l_werks TYPE eine-werks,

          lt_ekpo TYPE STANDARD TABLE OF zzmmsg_ekpodet.

    REFRESH: it_asi_conn.

    lt_ekpo[] = it_ekpo[].

    DELETE: lt_ekpo WHERE matnr IS INITIAL,
            lt_ekpo WHERE pstyp = c_k.

    IF NOT lt_ekpo[] IS INITIAL.

      SELECT eina~matnr
             eina~infnr
             eine~ekorg
             eine~esokz
             eine~werks
             eina~lifnr
             eine~prdat
        FROM eina
        JOIN eine ON eina~infnr = eine~infnr
        INTO TABLE it_asi_conn
         FOR ALL ENTRIES IN lt_ekpo
       WHERE eina~matnr = lt_ekpo-matnr   AND
             eina~loekz = l_loekz         AND
             eine~loekz = l_loekz         AND
             eine~esokz = c_0             AND
           ( eine~werks = lt_ekpo-werks   OR
             eine~werks = l_werks       ).

      IF sy-subrc = 0.

        APPEND LINES OF it_asi_conn TO it_asi.

        SORT it_asi BY matnr
                       infnr
                       ekorg
                       esokz
                       werks.

      ENDIF.

    ENDIF.

  ENDIF.

ENDFORM.                    " FETCH_ASI_CONN

*&---------------------------------------------------------------------*
*&      Form  FETCH_ASI_CONY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fetch_asi_cony .

  IF NOT it_ekpo IS INITIAL.

    DATA: l_loekz      TYPE eina-loekz,
          l_werks      TYPE eine-werks,

          lt_ekpo      TYPE STANDARD TABLE OF zzmmsg_ekpodet,
          lt_asi_cony1 TYPE STANDARD TABLE OF zzmmsg_asidet,
          lt_asi_cony2 TYPE STANDARD TABLE OF zzmmsg_asidet.

    FIELD-SYMBOLS: <ls_asi_cony1> TYPE zzmmsg_asidet,
                   <ls_asi_cony2> TYPE zzmmsg_asidet.

    REFRESH: it_asi_cony.

    lt_ekpo[] = it_ekpo[].

    DELETE: lt_ekpo WHERE matnr IS INITIAL,
            lt_ekpo WHERE pstyp <> c_k.

    IF NOT lt_ekpo[] IS INITIAL.

*     Sequence 1
      SELECT eina~matnr
             eina~infnr
             eine~ekorg
             eine~esokz
             eine~werks
             eina~lifnr
             eine~prdat
        FROM eina
        JOIN eine ON eina~infnr = eine~infnr
        INTO TABLE lt_asi_cony1
         FOR ALL ENTRIES IN lt_ekpo
       WHERE eina~matnr = lt_ekpo-matnr AND
             eina~lifnr = lt_ekpo-lifnr AND
             eina~loekz = l_loekz       AND
             eine~loekz = l_loekz       AND
             eine~esokz = c_2           AND
             eine~werks = lt_ekpo-werks.

*     Sequence 2
      SELECT eina~matnr
             eina~infnr
             eine~ekorg
             eine~esokz
             eine~werks
             eina~lifnr
             eine~prdat
        FROM eina
        JOIN eine ON eina~infnr = eine~infnr
        INTO TABLE lt_asi_cony2
         FOR ALL ENTRIES IN lt_ekpo
       WHERE eina~matnr = lt_ekpo-matnr AND
             eina~lifnr = lt_ekpo-lifnr AND
             eina~loekz = l_loekz       AND
             eine~loekz = l_loekz       AND
             eine~esokz = c_2.

*     Delete records in Sequence 2 that were already found in Sequence 1
      UNASSIGN: <ls_asi_cony2>.

      LOOP AT lt_asi_cony2 ASSIGNING <ls_asi_cony2>.

        UNASSIGN: <ls_asi_cony1>.

        READ TABLE lt_asi_cony1 WITH KEY  infnr = <ls_asi_cony2>-infnr
                                          ekorg = <ls_asi_cony2>-ekorg
                                          esokz = <ls_asi_cony2>-esokz
                                          werks = <ls_asi_cony2>-werks
                                ASSIGNING <ls_asi_cony1>.

        IF sy-subrc = 0.

          DELETE lt_asi_cony2.

        ENDIF.

      ENDLOOP.

*     Aggregate all records
      APPEND LINES OF: lt_asi_cony1 TO it_asi_cony,
                       lt_asi_cony2 TO it_asi_cony.

      SORT it_asi_cony BY matnr
                          infnr
                          ekorg
                          esokz
                          werks.

      APPEND LINES OF it_asi_cony TO it_asi.

    ENDIF.

  ENDIF.

ENDFORM.                    " FETCH_ASI_CONY

*&---------------------------------------------------------------------*
*&      Form  FETCH_EIPA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fetch_eipa .

  DATA: l_loekz TYPE ekpo-loekz.

  IF NOT it_asi IS INITIAL.

    SELECT eipa~infnr
           eipa~ebeln
           eipa~ebelp
           eipa~esokz
           eipa~werks
           eipa~ekorg
           eipa~bedat
           eipa~preis
           eipa~peinh
           eipa~bprme
           eipa~bwaer
      FROM eipa
      JOIN ekpo ON eipa~ebeln = ekpo~ebeln AND
                   eipa~ebelp = ekpo~ebelp
      INTO TABLE it_eipa
       FOR ALL ENTRIES IN it_asi
     WHERE eipa~infnr = it_asi-infnr AND
           eipa~ekorg = it_asi-ekorg AND
           eipa~esokz = it_asi-esokz AND
           ekpo~loekz = l_loekz.

    IF sy-subrc = 0.

      SORT it_eipa BY infnr
                      ebeln DESCENDING
                      ebelp
                      esokz
                      werks
                      ekorg
                      bedat DESCENDING.

    ENDIF.

  ENDIF.

ENDFORM.                    " FETCH_EIPA

*&---------------------------------------------------------------------*
*&      Form  FETCH_T024W
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fetch_t024w .

  SELECT werks
         ekorg
    FROM t024w
    INTO TABLE it_t024w.

ENDFORM.                    " FETCH_T024W

*&---------------------------------------------------------------------*
*&      Form  SET_VARIANTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_variants .

* PO Header
  gs_variant-report = sy-cprog.
  gs_variant-handle = text-ha1.

* PO Item
  gs_variant_det-report = sy-cprog.
  gs_variant_det-handle = text-ha2.

* RFQ Purchase Documents
  gs_variant_rfq-report = sy-cprog.
  gs_variant_rfq-handle = text-ha3.

* Available Source Contracts
  gs_variant_asc-report = sy-cprog.
  gs_variant_asc-handle = text-ha4.

* Available Source Info Records
  gs_variant_asi-report = sy-cprog.
  gs_variant_asi-handle = text-ha5.

* Account Assignments
  gs_variant_acc-report = sy-cprog.
  gs_variant_acc-handle = text-ha6.

ENDFORM.                    " SET_VARIANTS

*&---------------------------------------------------------------------*
*&      Form  uc_asc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM uc_asc USING in_ucomm    LIKE sy-ucomm
                  in_selfield TYPE slis_selfield.

  FIELD-SYMBOLS: <ls_asc_det> TYPE zzmmsg_ascdet.

  CASE in_ucomm.

*        Double-click
    WHEN text-uc1.

      UNASSIGN: <ls_asc_det>.

*     Read Row Info
      READ TABLE it_asc_det INDEX     in_selfield-tabindex
                             ASSIGNING <ls_asc_det>.

      IF sy-subrc = 0.

*       Check Column Selected
        CASE in_selfield-fieldname.

          WHEN text-f30. "PO Number Reference

            SET PARAMETER ID: 'BES' FIELD <ls_asc_det>-ebeln_ref.

            CALL TRANSACTION 'ME29N' AND SKIP FIRST SCREEN.

          WHEN text-f16. "Number of Principal Purchase Agreement

            IF NOT <ls_asc_det>-konnr IS INITIAL.

              SET PARAMETER ID 'VRT' FIELD <ls_asc_det>-konnr.

              CALL TRANSACTION 'ME33' AND SKIP FIRST SCREEN.

            ENDIF.

        ENDCASE.

      ENDIF.

  ENDCASE.

ENDFORM.                    "uc_asc

*&---------------------------------------------------------------------*
*&      Form  uc_asi
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM uc_asi USING in_ucomm    LIKE sy-ucomm
                  in_selfield TYPE slis_selfield.

  DATA: lv_lifnr TYPE eina-lifnr,
        lv_matnr TYPE eina-matnr.

  FIELD-SYMBOLS: <ls_asi_det> TYPE zzmmsg_asidet.

  CASE in_ucomm.

*        Double-click
    WHEN text-uc1.

      UNASSIGN: <ls_asi_det>.

*     Read Row Info
      READ TABLE it_asi_det INDEX     in_selfield-tabindex
                            ASSIGNING <ls_asi_det>.

      IF sy-subrc = 0.

*       Check Column Selected
        CASE in_selfield-fieldname.

          WHEN text-f30. "PO Number Reference

            SET PARAMETER ID: 'BES' FIELD <ls_asi_det>-ebeln_ref.

            CALL TRANSACTION 'ME29N' AND SKIP FIRST SCREEN.

          WHEN text-f18. "Number of Purchasing Info Record

            IF NOT <ls_asi_det>-infnr IS INITIAL.

              REFRESH: bdcdata.

*                      1st Screen
              PERFORM: bdc_dynpro USING 'SAPMM06I' '0100',
                       bdc_field  USING 'BDC_OKCODE'
                                        '/00',
                       bdc_field  USING 'EINA-LIFNR'
                                        lv_lifnr,
                       bdc_field  USING 'EINA-MATNR' "#EC CI_FLDEXT_OK[2215424] P30K910038
                                        lv_matnr,
                       bdc_field  USING 'EINE-EKORG'
                                        <ls_asi_det>-ekorg.

              IF NOT <ls_asi_det>-werks IS INITIAL.

                PERFORM bdc_field  USING 'EINE-WERKS'
                                         <ls_asi_det>-werks.

              ENDIF.

              PERFORM bdc_field  USING 'EINA-INFNR'
                                       <ls_asi_det>-infnr.

              CASE <ls_asi_det>-esokz.

                WHEN c_0.

                  PERFORM bdc_field  USING 'RM06I-NORMB'
                                            'X'.

                WHEN c_2.

                  PERFORM bdc_field  USING 'RM06I-KONSI'
                                            'X'.

              ENDCASE.

*                      2nd Screen
              PERFORM: bdc_dynpro USING 'SAPMM06I' '0101',
                       bdc_field  USING 'BDC_OKCODE'
                                        '=EINE'.

              CALL TRANSACTION 'ME13' USING bdcdata
                                      MODE  'E'.

            ENDIF.

        ENDCASE.

      ENDIF.

  ENDCASE.

ENDFORM.                    "uc_asi

*&---------------------------------------------------------------------*
*&      Form  UC_PO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM uc_po USING in_ucomm    LIKE sy-ucomm
                 in_selfield TYPE slis_selfield.

  DATA: lv_lifnr TYPE eina-lifnr,
        lv_matnr TYPE eina-matnr,
        lv_tabix TYPE sy-tabix,
        lv_werks TYPE eine-werks,

        lt_eipa  TYPE STANDARD TABLE OF ty_eipa.

  FIELD-SYMBOLS: <ls_a016>     TYPE ty_a016,
                 <ls_a017>     TYPE ty_a017,
                 <ls_a018>     TYPE ty_a018,
                 <ls_acc>      TYPE zzmmsg_accdet,
                 <ls_acc_det>  TYPE zzmmsg_accdet,
                 <ls_asc>      TYPE zzmmsg_ascdet,
                 <ls_asc_det>  TYPE zzmmsg_ascdet,
                 <ls_asi>      TYPE zzmmsg_asidet,
                 <ls_asi_det>  TYPE zzmmsg_asidet,
                 <ls_asi_tmp>  TYPE zzmmsg_asidet,
                 <ls_eipa>     TYPE ty_eipa,
                 <ls_konp>     TYPE ty_konp,
                 <ls_rfq>      TYPE zzmmsg_rfqdet,
                 <ls_rfq_det>  TYPE zzmmsg_rfqdet,
                 <ls_ekpo_det> TYPE zzmmsg_ekpodet,
                 <ls_t024w>    TYPE ty_t024w.

  CASE in_ucomm.

*        Double-click
    WHEN text-uc1.

      UNASSIGN: <ls_ekpo_det>.

*     Read Row Info
      READ TABLE it_ekpo_det INDEX     in_selfield-tabindex
                             ASSIGNING <ls_ekpo_det>.

      IF sy-subrc = 0.

*       Check Column Selected
        CASE in_selfield-fieldname.

*              Purchasing Document Number
          WHEN text-f01.

            SET PARAMETER ID: 'BES' FIELD <ls_ekpo_det>-ebeln.

            CALL TRANSACTION 'ME29N' AND SKIP FIRST SCREEN.

*              Purchase Requisition Number
          WHEN text-f12.

            SET PARAMETER ID: 'BAN' FIELD <ls_ekpo_det>-banfn.

            CALL TRANSACTION 'ME53N' AND SKIP FIRST SCREEN.

*              RFQ Number
          WHEN text-f14.

            IF NOT <ls_ekpo_det>-anfnr IS INITIAL.

              SET PARAMETER ID 'ANF' FIELD <ls_ekpo_det>-anfnr.

              CALL TRANSACTION 'ME48' AND SKIP FIRST SCREEN.

            ENDIF.

*              Number of Principal Purchase Agreement
          WHEN text-f16.

            IF NOT <ls_ekpo_det>-konnr IS INITIAL.

              SET PARAMETER ID 'VRT' FIELD <ls_ekpo_det>-konnr.

              CALL TRANSACTION 'ME33' AND SKIP FIRST SCREEN.

            ENDIF.

*              Number of Purchasing Info Record
          WHEN text-f18.

            IF NOT <ls_ekpo_det>-infnr IS INITIAL.

              REFRESH: bdcdata.

*                      1st Screen
              PERFORM: bdc_dynpro USING 'SAPMM06I' '0100',
                       bdc_field  USING 'BDC_OKCODE'
                                        '/00',
                       bdc_field  USING 'EINA-LIFNR'
                                        lv_lifnr,
                       bdc_field  USING 'EINA-MATNR' "#EC CI_FLDEXT_OK[2215424] P30K910038
                                        lv_matnr,
                       bdc_field  USING 'EINE-EKORG'
                                        <ls_ekpo_det>-ekorg.

              IF NOT <ls_ekpo_det>-werks IS INITIAL.

                PERFORM bdc_field  USING 'EINE-WERKS'
                                         <ls_ekpo_det>-werks.

              ENDIF.

              PERFORM: bdc_field  USING 'EINA-INFNR'
                                        <ls_ekpo_det>-infnr.

              CASE <ls_ekpo_det>-pstyp.

                WHEN c_0.

                  PERFORM bdc_field  USING 'RM06I-NORMB'
                                            'X'.

                WHEN c_2.

                  PERFORM bdc_field  USING 'RM06I-KONSI'
                                            'X'.

              ENDCASE.

*                      2nd Screen
              PERFORM: bdc_dynpro USING 'SAPMM06I' '0101',
                       bdc_field  USING 'BDC_OKCODE'
                                        '=EINE'.

              CALL TRANSACTION 'ME13' USING bdcdata
                                      MODE  'E'.

            ENDIF.

*              Icon (ACC)
          WHEN text-f35. "Account Assignment (ZICON_ACC)

            break mmirasol.

*           Check Icon
            IF <ls_ekpo_det>-zicon_acc = text-ic1.

              REFRESH: it_acc_det.

              UNASSIGN: <ls_acc>.
*             Loop at Account Assignments for PO Item
              LOOP AT it_acc ASSIGNING <ls_acc>
                             WHERE     ebeln = <ls_ekpo_det>-ebeln AND
                                       ebelp = <ls_ekpo_det>-ebelp.

                UNASSIGN: <ls_acc_det>.
*               Populate Account Assignments
                APPEND INITIAL LINE TO it_acc_det ASSIGNING <ls_acc_det>.
                <ls_acc_det> = <ls_acc>.

              ENDLOOP.

*             Display RFQ Purchase Documents
              CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
                EXPORTING
                  i_callback_program = sy-cprog
                  is_layout          = gs_layout_acc
                  it_fieldcat        = it_fldcat_acc
                  i_default          = c_x
                  i_save             = c_a
                  is_variant         = gs_variant_acc
                TABLES
                  t_outtab           = it_acc_det.

            ENDIF.

*              Icon (RFQ)
          WHEN text-f22.

*           Check Icon
            IF <ls_ekpo_det>-zicon_rfq = text-ic1.

              REFRESH: it_rfq_det.

              UNASSIGN: <ls_rfq>.

              LOOP AT it_rfq ASSIGNING <ls_rfq>
                             WHERE     banfn = <ls_ekpo_det>-banfn AND
                                       bnfpo = <ls_ekpo_det>-bnfpo.

                UNASSIGN: <ls_a016>,
                          <ls_rfq_det>.

                APPEND INITIAL LINE TO it_rfq_det ASSIGNING <ls_rfq_det>.

                <ls_rfq_det>           = <ls_rfq>.
                <ls_rfq_det>-ebeln_ref = <ls_ekpo_det>-ebeln.
                <ls_rfq_det>-ebelp_ref = <ls_ekpo_det>-ebelp.

*               Check RFQ purchase doc and item is equal to the reference PO RFQ doc and item
                IF <ls_ekpo_det>-anfnr = <ls_rfq>-ebeln AND
                   <ls_ekpo_det>-anfps = <ls_rfq>-ebelp.

*                 Check Icon
                  <ls_rfq_det>-zicon = text-ic1.

                ENDIF.

                READ TABLE it_a016 WITH KEY  evrtn = <ls_rfq>-ebeln
                                             evrtp = <ls_rfq>-ebelp
                                   ASSIGNING <ls_a016>.

                IF sy-subrc = 0.

                  UNASSIGN: <ls_konp>.

                  READ TABLE it_konp WITH KEY  knumh = <ls_a016>-knumh
                                     ASSIGNING <ls_konp>.

                  IF sy-subrc = 0.

                    <ls_rfq_det>-kbetr = <ls_konp>-kbetr.
                    <ls_rfq_det>-konwa = <ls_konp>-konwa.
                    <ls_rfq_det>-kpein = <ls_konp>-kpein.
                    <ls_rfq_det>-kmein = <ls_konp>-kmein.

                  ENDIF.

                ENDIF.

              ENDLOOP.

*             Display RFQ Purchase Documents
              CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
                EXPORTING
                  i_callback_program      = sy-cprog
                  i_callback_user_command = 'UC_RFQ'
                  is_layout               = gs_layout_rfq
                  it_fieldcat             = it_fldcat_rfq
                  it_sort                 = it_sort_rfq
                  i_default               = c_x
                  i_save                  = c_a
                  is_variant              = gs_variant_rfq
                TABLES
                  t_outtab                = it_rfq_det.

            ENDIF.

*              Icon (ASC)
          WHEN text-f24.

*           Check Icon
            IF <ls_ekpo_det>-zicon_asc = text-ic1.

              REFRESH: it_asc_det.

              UNASSIGN: <ls_asc>.

              LOOP AT it_asc ASSIGNING <ls_asc>
                             WHERE     matnr = <ls_ekpo_det>-matnr.

                UNASSIGN: <ls_t024w>.

*               Check Purchase Org Assignments to Plants
                READ TABLE it_t024w WITH KEY  ekorg = <ls_asc>-ekorg
                                              werks = <ls_ekpo_det>-werks
                                    ASSIGNING <ls_t024w>.

                IF sy-subrc <> 0.

                  CONTINUE.

                ENDIF.

*               If Contract Plant is not empty
                IF NOT <ls_asc>-werks IS INITIAL.

                  IF <ls_ekpo_det>-werks <> <ls_asc>-werks.

                    CONTINUE.

                  ENDIF.

                ENDIF.

                UNASSIGN: <ls_a016>,
                          <ls_asc_det>.

                APPEND INITIAL LINE TO it_asc_det ASSIGNING <ls_asc_det>.

                <ls_asc_det>           = <ls_asc>.
                <ls_asc_det>-ebeln_ref = <ls_ekpo_det>-ebeln.
                <ls_asc_det>-ebelp_ref = <ls_ekpo_det>-ebelp.

*               If AS Contract and Item is equal to the PO Contract and Item
                IF <ls_ekpo_det>-konnr = <ls_asc>-konnr AND
                   <ls_ekpo_det>-ktpnr = <ls_asc>-ktpnr.

*                 Check Icon
                  <ls_asc_det>-zicon = text-ic1.

                ENDIF.

                READ TABLE it_a016 WITH KEY  evrtn = <ls_asc>-konnr
                                             evrtp = <ls_asc>-ktpnr
                                   ASSIGNING <ls_a016>.

                IF sy-subrc = 0.

                  UNASSIGN: <ls_konp>.

                  READ TABLE it_konp WITH KEY  knumh = <ls_a016>-knumh
                                     ASSIGNING <ls_konp>.

                  IF sy-subrc = 0.

                    <ls_asc_det>-kbetr = <ls_konp>-kbetr.
                    <ls_asc_det>-konwa = <ls_konp>-konwa.
                    <ls_asc_det>-kpein = <ls_konp>-kpein.
                    <ls_asc_det>-kmein = <ls_konp>-kmein.

                  ENDIF.

                ENDIF.

              ENDLOOP.

*             Display Available Source Contracts
              CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY' "#EC CI_FLDEXT_OK[2215424] P30K910038
                EXPORTING
                  i_callback_program      = sy-cprog
                  i_callback_user_command = 'UC_ASC'
                  is_layout               = gs_layout_asc
                  it_fieldcat             = it_fldcat_asc
                  it_sort                 = it_sort_asc
                  i_default               = c_x
                  i_save                  = c_a
                  is_variant              = gs_variant_asc
                TABLES
                  t_outtab                = it_asc_det.

            ENDIF.

*              Icon (ASI)
          WHEN text-f26.

*           Check Icon
            IF <ls_ekpo_det>-zicon_asi = text-ic1.

              REFRESH: it_asi_det.

              UNASSIGN: <ls_asi>.

              LOOP AT it_asi ASSIGNING <ls_asi>
                             WHERE     matnr = <ls_ekpo_det>-matnr AND
                                       esokz = <ls_ekpo_det>-pstyp.

                UNASSIGN: <ls_t024w>.

                READ TABLE it_t024w WITH KEY  ekorg = <ls_asi>-ekorg
                                              werks = <ls_ekpo_det>-werks
                                    ASSIGNING <ls_t024w>.

                IF sy-subrc <> 0.

                  CONTINUE.

                ENDIF.

                IF NOT <ls_asi>-werks IS INITIAL.

                  IF <ls_asi>-werks <> <ls_ekpo_det>-werks.

                    CONTINUE.

                  ENDIF.

                ENDIF.

                UNASSIGN: <ls_asi_det>.

                APPEND INITIAL LINE TO it_asi_det ASSIGNING <ls_asi_det>.

                <ls_asi_det>           = <ls_asi>.
                <ls_asi_det>-ebeln_ref = <ls_ekpo_det>-ebeln.
                <ls_asi_det>-ebelp_ref = <ls_ekpo_det>-ebelp.

*               If AS Info Record is equal to the PO Info Record
                IF <ls_ekpo_det>-infnr = <ls_asi>-infnr AND
                   <ls_ekpo_det>-ekorg = <ls_asi>-ekorg AND
                   <ls_ekpo_det>-werks = <ls_asi>-werks.

*                 Check Icon
                  <ls_asi_det>-zicon = text-ic1.

                ELSEIF <ls_ekpo_det>-infnr = <ls_asi>-infnr AND
                       <ls_ekpo_det>-ekorg = <ls_asi>-ekorg.

*                 Check Icon
                  <ls_asi_det>-zicon = text-ic1.

                ENDIF.

*               If ASI Plant is not empty
                IF NOT <ls_asi>-werks IS INITIAL.

                  UNASSIGN: <ls_a017>.

*                 Check Amounts from Material Info Record (Plant-Specific)
                  READ TABLE it_a017 WITH KEY  lifnr = <ls_asi>-lifnr
                                               matnr = <ls_asi>-matnr
                                               ekorg = <ls_asi>-ekorg
                                               werks = <ls_asi>-werks
                                               esokz = <ls_asi>-esokz
                                     ASSIGNING <ls_a017>.

*                 If they exist
                  IF sy-subrc = 0.

                    UNASSIGN: <ls_konp>.

                    READ TABLE it_konp WITH KEY  knumh = <ls_a017>-knumh
                                       ASSIGNING <ls_konp>.

                    IF sy-subrc = 0.

                      <ls_asi_det>-kbetr = <ls_konp>-kbetr.
                      <ls_asi_det>-konwa = <ls_konp>-konwa.
                      <ls_asi_det>-kpein = <ls_konp>-kpein.
                      <ls_asi_det>-kmein = <ls_konp>-kmein.

                    ELSE.

                      CLEAR: lv_tabix.

                      UNASSIGN: <ls_eipa>.

*                     Check Order Price History: Info Record
                      READ TABLE it_eipa WITH KEY  infnr = <ls_asi>-infnr
                                                   ebeln = <ls_asi_det>-ebeln_ref
                                                   ebelp = <ls_asi_det>-ebelp_ref
                                                   ekorg = <ls_asi>-ekorg
                                                   werks = <ls_asi>-werks
                                                   esokz = <ls_asi>-esokz
                                         ASSIGNING <ls_eipa>.

                      IF sy-subrc = 0.

*                       If AS Info Record is same as PO Info Record
                        IF <ls_asi_det>-zicon = text-ic1.

                          lv_tabix = sy-tabix + 1.

                          UNASSIGN: <ls_eipa>.

*                         Get record before that
                          READ TABLE it_eipa INDEX     lv_tabix
                                             ASSIGNING <ls_eipa>.

                          IF sy-subrc = 0.

                            IF <ls_eipa>-infnr = <ls_asi>-infnr AND
                               <ls_eipa>-ekorg = <ls_asi>-ekorg AND
                               <ls_eipa>-werks = <ls_asi>-werks AND
                               <ls_eipa>-esokz = <ls_asi>-esokz.

                              <ls_asi_det>-kbetr = <ls_eipa>-preis.
                              <ls_asi_det>-konwa = <ls_eipa>-bwaer.
                              <ls_asi_det>-kpein = <ls_eipa>-peinh.
                              <ls_asi_det>-kmein = <ls_eipa>-bprme.

                            ENDIF.

                          ENDIF.

                        ELSE.

                          <ls_asi_det>-kbetr = <ls_eipa>-preis.
                          <ls_asi_det>-konwa = <ls_eipa>-bwaer.
                          <ls_asi_det>-kpein = <ls_eipa>-peinh.
                          <ls_asi_det>-kmein = <ls_eipa>-bprme.

                        ENDIF.

                      ENDIF.

                    ENDIF.

*                 If not
                  ELSE.

                    UNASSIGN: <ls_eipa>.

*                   Check Order Price History: Info Record
                    READ TABLE it_eipa WITH KEY  infnr = <ls_asi>-infnr
                                                 ekorg = <ls_asi>-ekorg
                                                 werks = <ls_asi>-werks
                                                 esokz = <ls_asi>-esokz
                                       ASSIGNING <ls_eipa>.

                    IF sy-subrc = 0.

                      <ls_asi_det>-kbetr = <ls_eipa>-preis.
                      <ls_asi_det>-konwa = <ls_eipa>-bwaer.
                      <ls_asi_det>-kpein = <ls_eipa>-peinh.
                      <ls_asi_det>-kmein = <ls_eipa>-bprme.

                    ENDIF.

                  ENDIF.

*               If no plant exists
                ELSE.

                  UNASSIGN: <ls_a018>.

*                 Check Amounts from Material Info Record
                  READ TABLE it_a018 WITH KEY  lifnr = <ls_asi>-lifnr
                                               matnr = <ls_asi>-matnr
                                               ekorg = <ls_asi>-ekorg
                                               esokz = <ls_asi>-esokz
                                     ASSIGNING <ls_a018>.

*                 If they exist
                  IF sy-subrc = 0.

                    UNASSIGN: <ls_konp>.

                    READ TABLE it_konp WITH KEY  knumh = <ls_a018>-knumh
                                       ASSIGNING <ls_konp>.

                    IF sy-subrc = 0.

                      <ls_asi_det>-kbetr = <ls_konp>-kbetr.
                      <ls_asi_det>-konwa = <ls_konp>-konwa.
                      <ls_asi_det>-kpein = <ls_konp>-kpein.
                      <ls_asi_det>-kmein = <ls_konp>-kmein.

                    ENDIF.

*                 If not
                  ELSE.

                    UNASSIGN: <ls_asi_tmp>,
                              <ls_eipa>.

                    REFRESH: lt_eipa.

*                   Temporarily store Order Price History (Info Record)
                    lt_eipa[] = it_eipa.

                    SORT lt_eipa BY infnr
                                    bedat DESCENDING
                                    ebeln DESCENDING
                                    ebelp.

*                   Remove Prices that are Plant Specific
                    LOOP AT it_asi ASSIGNING <ls_asi_tmp>
                                   WHERE     matnr =  <ls_asi>-matnr AND
                                             infnr =  <ls_asi>-infnr AND
                                             ekorg =  <ls_asi>-ekorg AND
                                             esokz =  <ls_asi>-esokz AND
                                         NOT werks IS INITIAL.

                      DELETE lt_eipa WHERE infnr = <ls_asi_tmp>-infnr AND
                                           esokz = <ls_asi_tmp>-esokz AND
                                           werks = <ls_asi_tmp>-werks AND
                                           ekorg = <ls_asi_tmp>-ekorg.

                    ENDLOOP.

*                   Check Temporary Order Price History: Info Record
                    READ TABLE lt_eipa WITH KEY  infnr = <ls_asi>-infnr
                                                 ekorg = <ls_asi>-ekorg
                                                 esokz = <ls_asi>-esokz
                                       ASSIGNING <ls_eipa>.

                    IF sy-subrc = 0.

*                     If AS Info Record is same as PO Info Record
                      IF <ls_asi_det>-zicon = text-ic1.

                        CLEAR: lv_tabix.

                        UNASSIGN: <ls_eipa>.

                        lv_tabix = sy-tabix + 1.

*                       Get record before that
                        READ TABLE lt_eipa INDEX     lv_tabix
                                           ASSIGNING <ls_eipa>.

                        IF sy-subrc = 0.

                          IF <ls_eipa>-infnr = <ls_asi>-infnr AND
                             <ls_eipa>-ekorg = <ls_asi>-ekorg AND
                             <ls_eipa>-esokz = <ls_asi>-esokz.

                            <ls_asi_det>-kbetr = <ls_eipa>-preis.
                            <ls_asi_det>-konwa = <ls_eipa>-bwaer.
                            <ls_asi_det>-kpein = <ls_eipa>-peinh.
                            <ls_asi_det>-kmein = <ls_eipa>-bprme.

                          ENDIF.

                        ENDIF.

                      ELSE.

                        <ls_asi_det>-kbetr = <ls_eipa>-preis.
                        <ls_asi_det>-konwa = <ls_eipa>-bwaer.
                        <ls_asi_det>-kpein = <ls_eipa>-peinh.
                        <ls_asi_det>-kmein = <ls_eipa>-bprme.

                      ENDIF.

                    ENDIF.

                  ENDIF.

                ENDIF.

              ENDLOOP.

*             Display Available Source Contracts
              CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY' "#EC CI_FLDEXT_OK[2215424] P30K910038
                EXPORTING
                  i_callback_program      = sy-cprog
                  i_callback_user_command = 'UC_ASI'
                  is_layout               = gs_layout_asi
                  it_fieldcat             = it_fldcat_asi
                  it_sort                 = it_sort_asi
                  i_default               = c_x
                  i_save                  = c_a
                  is_variant              = gs_variant_asi
                TABLES
                  t_outtab                = it_asi_det.

            ENDIF.

        ENDCASE.

      ENDIF.

  ENDCASE.

ENDFORM.                    "uc_po

*&---------------------------------------------------------------------*
*&      Form  uc_rfq
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM uc_rfq USING in_ucomm    LIKE sy-ucomm
                  in_selfield TYPE slis_selfield.

  FIELD-SYMBOLS: <ls_rfq_det> TYPE zzmmsg_rfqdet.

  CASE in_ucomm.

*        Double-click
    WHEN text-uc1.

      UNASSIGN: <ls_rfq_det>.

*     Read Row Info
      READ TABLE it_rfq_det INDEX     in_selfield-tabindex
                            ASSIGNING <ls_rfq_det>.

      IF sy-subrc = 0.

*       Check Column Selected
        CASE in_selfield-fieldname.

          WHEN text-f30. "PO Number Reference

            SET PARAMETER ID: 'BES' FIELD <ls_rfq_det>-ebeln_ref.

            CALL TRANSACTION 'ME29N' AND SKIP FIRST SCREEN.

          WHEN text-f01. "Purchase Requisition Number

            IF NOT <ls_rfq_det>-ebeln IS INITIAL.

              SET PARAMETER ID 'ANF' FIELD <ls_rfq_det>-ebeln.

              CALL TRANSACTION 'ME48' AND SKIP FIRST SCREEN.

            ENDIF.

        ENDCASE.

      ENDIF.

  ENDCASE.

ENDFORM.                    "uc_rfq

*----------------------------------------------------------------------*
*        Start new screen                                              *
*----------------------------------------------------------------------*
FORM bdc_dynpro USING program dynpro.
  CLEAR bdcdata.
  bdcdata-program  = program.
  bdcdata-dynpro   = dynpro.
  bdcdata-dynbegin = 'X'.
  APPEND bdcdata.
ENDFORM.                    "BDC_DYNPRO

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM bdc_field USING fnam fval.
  CLEAR bdcdata.
  bdcdata-fnam = fnam.
  bdcdata-fval = fval. "#EC CI_FLDEXT_OK[2215424] P30K910038
  APPEND bdcdata.
ENDFORM.                    "BDC_FIELD
*End   of P30K903020
