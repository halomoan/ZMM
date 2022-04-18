*----------------------------------------------------------------------*
***INCLUDE ZMMRGB_0005_TOP .
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
* Program    : ZMMRGB_0005_TOP
* FRICE#     : MMGBE_016
* Title      : PO Approval Report
* Author     : Venkatesh Gopalarathnam
* Date       : 28.12.2010
* Specification Given By:
* Purpose	   : To generate display POs for approval and enable user to
*              approve POs relevant to the user.
*---------------------------------------------------------------------*
* Modification Log
* Date         Author          Num  Transport Req no. Description
* -----------  -------         ---  ---------------------------------*
* 28.12.2010   VEGOPALARATH    001              Initial creation
* 10.01.2011   VEGOPALARATH    002  P30K901537  Addition of doc type
* 16.05.2011   MMIRASOL        003  P30K903020    1. Added 'Details Button
*                                                    to Header Screen
*                                                 2. Adjusted computation of
*                                                    PO Value based on
*                                                    "returned item" status
*                                                 3. Added a "PO Items
*                                                    Details" Screen
*                                                 4. Added a "RFQ Details"
*                                                    Screen
*                                                 5. Added a "Available
*                                                    Source Contracts
*                                                    Screen"
*                                                 6. Added a "Available
*                                                    Source Info Records/
*                                                    Purchase Org/Plant"
*                                                    Screen
*---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*           T Y P E - P O O L S    D E C L A R A T I O N               *
*----------------------------------------------------------------------*
TYPE-POOLS slis.

*----------------------------------------------------------------------*
* TYPES
*----------------------------------------------------------------------*
TYPES : BEGIN OF ty_ekko,
         ebeln TYPE ekko-ebeln,
*Start of changes by Venkatesh <VEGOPALARATH> on 10-Jan-11
*Addition of Purchasing document type to O.P
         bsart TYPE ekko-ebeln,
*End of changes by Venkatesh <VEGOPALARATH> on 10-Jan-11
         aedat TYPE ekko-aedat,
         ernam TYPE ekko-ernam,
         lifnr TYPE ekko-lifnr,
         ekorg TYPE ekko-ekorg,
         ekgrp TYPE ekko-ekgrp,
         waers TYPE ekko-waers,
         frgzu TYPE ekko-frgzu,
         frggr TYPE ekko-frggr, " Release grp
         frgsx TYPE ekko-frgsx, " Release strategy
         procstat TYPE ekko-procstat,"Processing state
         werks TYPE werks_d,    "Plant from EKPO
         name1 TYPE name1,      "Plant name
         netwr TYPE ekpo-netwr, "Total NETWR from EKPO
        END OF ty_ekko,

*        BEGIN OF ty_ekpo,
*          ebeln TYPE ekpo-ebeln,
*          ebelp TYPE ekpo-ebelp,
*          werks TYPE ekpo-werks,
*          netwr TYPE ekpo-netwr,
*          retpo TYPE ekpo-retpo, "P30K903020
*        END OF ty_ekpo,

*       Begin of P30K903020
        BEGIN OF ty_a016,

          evrtn TYPE a016-evrtn,
          evrtp TYPE a016-evrtp,
          datbi TYPE a016-datbi,
          datab TYPE a016-datab,
          knumh TYPE a016-knumh,

        END   OF ty_a016,

        BEGIN OF ty_a017,

          lifnr TYPE a017-lifnr,
          matnr TYPE a017-matnr,
          ekorg TYPE a017-ekorg,
          werks TYPE a017-werks,
          esokz TYPE a017-esokz,
          datbi TYPE a017-datbi,
          datab TYPE a017-datab,
          knumh TYPE a017-knumh,

        END   OF ty_a017,

        BEGIN OF ty_a018,

          lifnr TYPE a018-lifnr,
          matnr TYPE a018-matnr,
          ekorg TYPE a018-ekorg,
          esokz TYPE a018-esokz,
          datbi TYPE a018-datbi,
          datab TYPE a018-datab,
          knumh TYPE a018-knumh,

        END   OF ty_a018,

        BEGIN OF ty_eipa,

          infnr TYPE eipa-infnr,
          ebeln TYPE eipa-ebeln,
          ebelp TYPE eipa-ebelp,
          esokz TYPE eipa-esokz,
          werks TYPE eipa-werks,
          ekorg TYPE eipa-ekorg,
          bedat TYPE eipa-bedat,
          preis TYPE eipa-preis,
          peinh TYPE eipa-peinh,
          bprme TYPE eipa-bprme,
          bwaer TYPE eipa-bwaer,

        END   OF ty_eipa,

        BEGIN OF ty_konp,

          knumh TYPE konp-knumh,
          konwa TYPE konp-konwa,
          kpein TYPE konp-kpein,
          kmein TYPE konp-kmein,
          kbetr TYPE konp-kbetr,

        END   OF ty_konp,

        BEGIN OF ty_makt,

          matnr TYPE makt-matnr,
          maktx TYPE makt-maktx,

        END   OF ty_makt,

        BEGIN OF ty_t024w,

          werks TYPE t024w-werks,
          ekorg TYPE t024w-ekorg,

        END   OF ty_t024w,
*       End   of P30K903020

        BEGIN OF ty_t001w,
          werks TYPE werks_d,
          name1 TYPE name1,
        END OF ty_t001w,

        BEGIN OF ty_t16fh, "Release Grp desc
          frggr TYPE frggr,
          frggt TYPE frggt,
        END OF ty_t16fh,

        BEGIN OF ty_t16ft, "Release Strategy desc
         frggr TYPE frggr,
         frgsx TYPE frgsx,
         frgxt TYPE frgxt,
        END OF ty_t16ft,

        BEGIN OF ty_t16fs,
         frggr TYPE frggr,
         frgsx TYPE frgsx,
         frgc1 TYPE frgco,
         frgc2 TYPE frgco,
         frgc3 TYPE frgco,
         frgc4 TYPE frgco,
         frgc5 TYPE frgco,
         frgc6 TYPE frgco,
         frgc7 TYPE frgco,
         frgc8 TYPE frgco,
        END OF ty_t16fs,

        BEGIN OF ty_t16fd,
          frggr TYPE frggr,
          frgco TYPE frgco,
          frgct TYPE frgct,
        END OF ty_t16fd,

        BEGIN OF ty_lfa1,
          lifnr TYPE lifnr,
          name1 TYPE name1_gp,
        END OF ty_lfa1,

        BEGIN OF ty_t024,
          ekgrp TYPE ekgrp,
          eknam TYPE eknam,
        END OF ty_t024,

        BEGIN OF ty_final,
          chkbx TYPE char1,
          ebeln TYPE ekko-ebeln,
          werks TYPE ekpo-werks,
          name1 TYPE name1,
          lifnr TYPE ekko-lifnr,
          vname TYPE name1,
          netwr TYPE ekpo-netwr,
          waers TYPE ekko-waers,
          ernam TYPE ekko-ernam,
          ekgrp TYPE ekko-ekgrp,
          name_txt TYPE adrp-name_text,
          frggr TYPE ekko-frggr,
          frggt  TYPE t16fh-frggt,
          frgsx TYPE ekko-frgsx,
          r1    TYPE t16fs-frgc1,
          des1  TYPE t16fd-frgct,
          st1   TYPE char1,
          r2    TYPE t16fs-frgc1,
          des2  TYPE t16fd-frgct,
          st2   TYPE char1,
          r3    TYPE t16fs-frgc1,
          des3  TYPE t16fd-frgct,
          st3   TYPE char1,
          r4    TYPE t16fs-frgc1,
          des4  TYPE t16fd-frgct,
          st4   TYPE char1,
          r5    TYPE t16fs-frgc1,
          des5  TYPE t16fd-frgct,
          st5   TYPE char1,
          r6    TYPE t16fs-frgc1,
          des6  TYPE t16fd-frgct,
          st6   TYPE char1,
          r7    TYPE t16fs-frgc1,
          des7  TYPE t16fd-frgct,
          st7   TYPE char1,
          r8    TYPE t16fs-frgc1,
          des8  TYPE t16fd-frgct,
          st8   TYPE char1,
          frgzu TYPE ekko-frgzu,
          eknam(22) TYPE c,
          bsart TYPE ekko-bsart,
          procstat TYPE ekko-procstat,
          prodes TYPE char20,
        END OF ty_final,

        BEGIN OF ty_audit,
          icon  TYPE char4,
          ebeln TYPE ebeln,
          msg   TYPE string,
        END OF ty_audit.

*----------------------------------------------------------------------*
* V A R I A B L E S
*----------------------------------------------------------------------*
DATA : v_ebeln TYPE ekko-ebeln,
       v_aedat TYPE erdat,
       v_ernam TYPE ernam,
       v_lifnr TYPE lifnr,
       v_ekorg TYPE ekorg,
       v_ekgrp TYPE ekgrp,
       v_bukrs TYPE bukrs,
       v_werks TYPE werks_d,
       v_bstyp TYPE ebstyp,
       v_frgrl TYPE frgrl,
       v_frgco TYPE frgco,
       v_frggr TYPE frggr,
       v_frgke TYPE frgke.

*----------------------------------------------------------------------*
* C O N S T A N T S
*----------------------------------------------------------------------*
CONSTANTS : c_x TYPE char1 VALUE 'X',
            c_a TYPE char1 VALUE 'A',
            c_e TYPE char1 VALUE 'E',
            c_k            VALUE 'K',                       "P30K903020
            c_m            VALUE 'M',                       "P30K903020
            c_0            VALUE '0',                       "P30K903020
            c_2            VALUE '2',                       "P30K903020
            c_s TYPE char1 VALUE 'S',
            c_f TYPE char1 VALUE 'F',
            c_i(1)  TYPE c VALUE 'I',
            c_eq(2) TYPE c VALUE 'EQ',
            c_app(4) TYPE c VALUE '&APP',
            c_pb00 TYPE a016-kschl VALUE 'PB00',            "P30K903020
            c_ucoa TYPE t001-ktopl VALUE 'UCOA'.

*----------------------------------------------------------------------*
*  W O R K  A R E A S
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*  I  N T E R N A L   T A B L E S
*----------------------------------------------------------------------*
DATA : it_ekko  TYPE STANDARD TABLE OF ty_ekko,
       it_a016     TYPE STANDARD TABLE OF ty_a016,          "P30K903020
       it_a017     TYPE STANDARD TABLE OF ty_a017,          "P30K903020
       it_a018     TYPE STANDARD TABLE OF ty_a018,          "P30K903020
       it_acc      TYPE STANDARD TABLE OF zzmmsg_accdet,
       it_asc      TYPE STANDARD TABLE OF zzmmsg_ascdet,    "P30K903020
       it_asi      TYPE STANDARD TABLE OF zzmmsg_asidet,    "P30K903020
       it_asi_conn TYPE STANDARD TABLE OF zzmmsg_asidet,    "P30K903020
       it_asi_cony TYPE STANDARD TABLE OF zzmmsg_asidet,    "P30K903020
       it_cskt     TYPE STANDARD TABLE OF cskt,
       it_eipa     TYPE STANDARD TABLE OF ty_eipa,          "P30K903020
       it_ekpo     TYPE STANDARD TABLE OF zzmmsg_ekpodet,   "P30K903020
       it_ekpo_det TYPE STANDARD TABLE OF zzmmsg_ekpodet,   "P30K903020
       it_rfq      TYPE STANDARD TABLE OF zzmmsg_rfqdet,    "P30K903020
       it_acc_det  TYPE STANDARD TABLE OF zzmmsg_accdet,
       it_rfq_det  TYPE STANDARD TABLE OF zzmmsg_rfqdet,    "P30K903020
       it_asc_det  TYPE STANDARD TABLE OF zzmmsg_ascdet,    "P30K903020
       it_asi_det  TYPE STANDARD TABLE OF zzmmsg_asidet,    "P30K903020
       it_konp     TYPE STANDARD TABLE OF ty_konp,          "P30K903020
       it_makt     TYPE STANDARD TABLE OF ty_makt,          "P30K903020
       it_skat     TYPE STANDARD TABLE OF skat,
       it_t001w TYPE STANDARD TABLE OF ty_t001w,
       it_t16fh TYPE STANDARD TABLE OF ty_t16fh,
       it_t16fs TYPE STANDARD TABLE OF ty_t16fs,
       it_t16fd TYPE STANDARD TABLE OF ty_t16fd,
       it_lfa1  TYPE STANDARD TABLE OF  ty_lfa1,
       it_final TYPE STANDARD TABLE OF ty_final,
       it_fldcat TYPE STANDARD TABLE OF slis_fieldcat_alv,
       it_fldcat_acc TYPE STANDARD TABLE OF slis_fieldcat_alv,
       it_fldcat_asc TYPE STANDARD TABLE OF slis_fieldcat_alv, "P30K903020
       it_fldcat_asi TYPE STANDARD TABLE OF slis_fieldcat_alv, "P30K903020
       it_fldcat_det TYPE STANDARD TABLE OF slis_fieldcat_alv, "P30K903020
       it_fldcat_rfq TYPE STANDARD TABLE OF slis_fieldcat_alv, "P30K903020
       it_sort_rfq TYPE                     slis_t_sortinfo_alv, "P30K903020
       it_sort_asc TYPE                     slis_t_sortinfo_alv, "P30K903020
       it_sort_asi TYPE                     slis_t_sortinfo_alv, "P30K903020
       it_zpogr TYPE STANDARD TABLE OF zzpogrp,
       gs_zpogr TYPE zzpogrp,
       it_t024  TYPE STANDARD TABLE OF ty_t024,
       it_t024w TYPE STANDARD TABLE OF ty_t024w,            "P30K903020
       it_audit TYPE STANDARD TABLE OF ty_audit,
       bdcdata LIKE bdcdata    OCCURS 0 WITH HEADER LINE,   "P30K903020
*Begin of P30K903020
*----------------------------------------------------------------------*
*  S T R U C T U R E S
*----------------------------------------------------------------------*
       gs_variant     TYPE disvariant,
       gs_variant_acc TYPE disvariant,
       gs_variant_asc TYPE disvariant,
       gs_variant_asi TYPE disvariant,
       gs_variant_det TYPE disvariant,
       gs_variant_rfq TYPE disvariant,
       gs_layout      TYPE slis_layout_alv,
       gs_layout_acc  TYPE slis_layout_alv,
       gs_layout_asc  TYPE slis_layout_alv,
       gs_layout_asi  TYPE slis_layout_alv,
       gs_layout_det  TYPE slis_layout_alv,
       gs_layout_rfq  TYPE slis_layout_alv.
*End   of P30K903020

*----------------------------------------------------------------------*
*  P A R A M E T E R S  &  S E L E C T - O P T I O N S
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE text-001.
SELECT-OPTIONS : s_ebeln FOR v_ebeln NO-DISPLAY,
                 s_lifnr FOR v_lifnr NO-DISPLAY,
                 s_ekorg FOR v_ekorg MATCHCODE OBJECT h_t024e NO-DISPLAY,
                 s_ekgrp FOR v_ekgrp MATCHCODE OBJECT h_t024 NO-DISPLAY,
                 s_bukrs FOR v_bukrs NO-DISPLAY,
                 s_werks FOR v_werks NO-DISPLAY,
                 s_bstyp FOR v_bstyp DEFAULT c_f NO-DISPLAY,
                 s_aedat FOR v_aedat NO-DISPLAY,
                 s_ernam FOR v_ernam NO-DISPLAY,
                 s_frgrl FOR v_frgrl DEFAULT c_x NO-DISPLAY,
                 s_frgco FOR v_frgco NO-DISPLAY,
                 s_frggr FOR v_frggr NO-DISPLAY,
                 s_frgke FOR v_frgke NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK blk1.
