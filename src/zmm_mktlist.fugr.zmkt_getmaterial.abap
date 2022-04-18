FUNCTION ZMKT_GETMATERIAL.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(KOSTL) TYPE  KOSTL
*"     VALUE(CURR_DATE) TYPE  DATUM
*"     VALUE(PLANT) TYPE  WERKS_D
*"  EXPORTING
*"     VALUE(LOCKSTATUS) TYPE  CHAR13
*"  TABLES
*"      MATERIAL_LIST STRUCTURE  ZMM_MKTLISTDETAIL OPTIONAL
*"----------------------------------------------------------------------

TYPES: BEGIN OF ty_mmlist.
          INCLUDE STRUCTURE ZMM_MKTLISTDETAIL.
TYPES:    NETPR_TMP TYPE NETPR,
       END OF ty_mmlist.

TYPES: BEGIN OF ty_marc,
          MATNR LIKE MARC-MATNR,
          MAKTX LIKE MAKT-MAKTX,
          MEINS TYPE MARA-MEINS, " Base UOM
          LIFNR TYPE ELIFN, "Vendor
          FLIFN TYPE FLIFN, "Default Vendor
          KAUTB TYPE KAUTB, "Material Auto PO
          KZAUT TYPE KZAUT, "Vendor Auto PO
          EKORG TYPE EKORG,
          OMEINS TYPE EINA-MEINS, "Order UOM
      END OF ty_marc.


TYPES:
      BEGIN OF ty_eina,
        EKORG LIKE EINE-EKORG,
        WERKS LIKE EINE-WERKS,
        MINBM LIKE EINE-MINBM, " Minimum Order Qty
        MEINS LIKE EINA-MEINS, " Minimm Order Unit
        MATNR LIKE EINA-MATNR,
        LIFNR LIKE EINA-LIFNR,
      END OF ty_eina,
      BEGIN OF ty_a018,
         EKORG LIKE EINE-EKORG,
         WERKS LIKE EINE-WERKS,
         LIFNR LIKE A018-LIFNR,
         MATNR LIKE A018-MATNR,
         KNUMH LIKE A018-KNUMH,
         DATBI LIKE A018-DATBI,
         ESOKZ LIKE A018-ESOKZ,
      END OF ty_a018,
      BEGIN OF ty_konp,
        KNUMH LIKE KONP-KNUMH,
        KBETR LIKE KONP-KBETR,
        KPEIN LIKE KONP-KPEIN,
        KMEIN LIKE KONP-KMEIN,
        LOEVM_KO LIKE KONP-LOEVM_KO,
      END OF ty_konp,
      BEGIN OF ty_T006,
        MSEHI LIKE T006-MSEHI,
        ANDEC LIKE T006-ANDEC,
      END OF ty_T006.


TYPES: BEGIN OF ty_preq_no,
          trxid TYPE char8,
          preq_no TYPE BANFN,
       END OF ty_preq_no.

TYPES: BEGIN OF ty_preq_mat,
          prid TYPE BNFPO,
          trxid TYPE datum,
          matid TYPE MATNR,
          qty TYPE BAMNG,
          unit TYPE MEINS,
          text_line TYPE TDLINE,
       END OF ty_preq_mat.


DATA: l_EKORG TYPE EKORG,
      l_tmplpreqno TYPE BANFN,
      l_currdate TYPE datum,
      l_counter TYPE i,
      l_idx TYPE i,
      l_toBaseUnit TYPE meins,
      l_country LIKE T001-LAND1,
      p_intval like wmto_s-amount,   "Internal Amount
      gd_disval  like wmto_s-amount, "Display Amount
      l_EBELN LIKE EBAN-EBELN,
      l_MATNR LIKE MARC-MATNR,
      l_MAKTX LIKE MAKT-MAKTX,
      l_WAERS LIKE EINE-WAERS,
      l_MENGE LIKE EKPO-MENGE,
      l_PRICEUNIT LIKE EINE-PEINH, "Price Unit
      l_BASEDUNIT LIKE MARA-MEINS. "Based Unit
      "l_ORDERPRICEUNIT LIKE MARA-MEINS. "Order Unit

DATA: lt_marc TYPE STANDARD TABLE OF ty_marc.

DATA: lt_auth_purchorg LIKE STANDARD TABLE OF usvalues,
      ls_auth_purchorg TYPE usvalues.

DATA: lt_auth_plant LIKE STANDARD TABLE OF usvalues,
      ls_auth_plant TYPE usvalues.


DATA: lt_EINA TYPE STANDARD TABLE OF ty_eina,
      ls_EINA TYPE ty_eina,
      lt_KNUMH TYPE STANDARD TABLE OF ty_a018,
      ls_KNUMH LIKE LINE OF lt_KNUMH,
      lt_KONP TYPE STANDARD TABLE OF ty_konp,
      ls_konp LIKE LINE OF lt_KONP,
      lt_T006 TYPE STANDARD TABLE OF ty_T006,
      ls_T006 LIKE LINE OF lt_T006,
      ls_T024W TYPE T024W.

RANGES: ra_KNUMH FOR A018-KNUMH,
        ra_matnr FOR MARC-MATNR.

DATA: lt_preq_no TYPE STANDARD TABLE OF ty_preq_no,
      ls_preq_no TYPE ty_preq_no.

DATA: lt_preq_mat TYPE HASHED TABLE OF ty_preq_mat WITH UNIQUE KEY trxid matid unit,
      ls_preq_mat TYPE ty_preq_mat.

DATA: r_purchorg TYPE RANGE OF EINE-EKORG,
      wr_purchorg LIKE LINE OF r_purchorg,
      r_plant TYPE RANGE OF MARC-WERKS,
      wr_plant LIKE LINE OF r_plant,
      r_trxid TYPE RANGE OF sy-datum,
      wr_trxid LIKE LINE OF r_trxid,
      r_temp TYPE RANGE OF MARC-MATNR,
      wr_temp LIKE LINE OF r_temp,
      r_autopo TYPE RANGE OF char4.

DATA: PRITEM LIKE TABLE OF bapimereqitem WITH HEADER LINE,
      RETURN LIKE TABLE OF bapiret2 WITH HEADER LINE,
      PRITEMTEXT LIKE TABLE OF BAPIMEREQITEMTEXT WITH HEADER LINE.
*      PRACCOUNT LIKE TABLE OF BAPIMEREQACCOUNT WITH HEADER LINE,


DATA: lt_mmlist TYPE STANDARD TABLE OF ty_mmlist,
      ls_mmlist TYPE ty_mmlist.

FIELD-SYMBOLS: <ls_material> TYPE ty_mmlist,
               <ls_preq_mat> LIKE LINE OF lt_preq_mat,
               <ls_marc> LIKE LINE OF lt_marc.

CALL FUNCTION 'SUSR_USER_AUTH_FOR_OBJ_GET'
  EXPORTING
    USER_NAME                 = sy-uname
    SEL_OBJECT                = 'M_BANF_EKO'
  TABLES
    VALUES                    = lt_auth_purchorg
 EXCEPTIONS
   USER_NAME_NOT_EXIST       = 1
   NOT_AUTHORIZED            = 2
   INTERNAL_ERROR            = 3
   OTHERS                    = 4.

IF SY-SUBRC <> 0.
 EXIT.
ENDIF.

CALL FUNCTION 'SUSR_USER_AUTH_FOR_OBJ_GET'
  EXPORTING
    USER_NAME                 = sy-uname
    SEL_OBJECT                = 'M_BANF_WRK'
  TABLES
    VALUES                    = lt_auth_plant
 EXCEPTIONS
   USER_NAME_NOT_EXIST       = 1
   NOT_AUTHORIZED            = 2
   INTERNAL_ERROR            = 3
   OTHERS                    = 4.

IF SY-SUBRC <> 0.
 EXIT.
ENDIF.


CONCATENATE PLANT KOSTL+4 INTO l_tmplpreqno.

"DELETE lt_auth_purchorg WHERE FIELD <> 'EKORG'.
DELETE lt_auth_plant WHERE FIELD <> 'WERKS'.

l_EKORG = 'X'.

SELECT SINGLE * INTO ls_T024W FROM T024W WHERE WERKS = PLANT AND EKORG = 'C103'.
IF sy-subrc <> 0.
  SELECT SINGLE * INTO ls_T024W FROM T024W WHERE WERKS = PLANT AND EKORG = 'C108'.
  IF sy-subrc <> 0.
    SELECT SINGLE * INTO ls_T024W FROM T024W WHERE WERKS = PLANT AND EKORG LIKE 'P%'.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
  ELSE.
    l_EKORG = ls_T024W-EKORG.
  ENDIF.
ELSE.
  l_EKORG = ls_T024W-EKORG.
ENDIF.

READ TABLE lt_auth_purchorg INTO ls_auth_purchorg WITH KEY VON = ls_T024W-EKORG.
IF sy-subrc = 0.
        wr_purchorg-sign = 'I'.
        wr_purchorg-option = 'EQ'.
        wr_purchorg-low = ls_auth_purchorg-VON.
        APPEND wr_purchorg TO r_purchorg.
ELSE.
  READ TABLE lt_auth_purchorg INTO ls_auth_purchorg WITH KEY FIELD = 'EKORG' VON = '*'.
  IF sy-subrc = 0.
    wr_purchorg-sign = 'I'.
    wr_purchorg-option = 'EQ'.
    wr_purchorg-low = ls_T024W-EKORG.
    APPEND wr_purchorg TO r_purchorg.
  ENDIF.

ENDIF.



READ TABLE lt_auth_plant WITH KEY VON = PLANT TRANSPORTING NO FIELDS.
IF sy-subrc ne 0.
  READ TABLE lt_auth_plant WITH KEY VON = '*' TRANSPORTING NO FIELDS.
  IF sy-subrc ne 0.
    EXIT.
  ENDIF.
ENDIF.

SELECT SINGLE LAND1 INTO l_country FROM T001W WHERE WERKS = PLANT.
IF sy-subrc = 0.

  IF l_country = 'MM'.
    l_WAERS = 'MMK'.
  ELSE.
    SELECT SINGLE WAERS INTO l_WAERS FROM T001 WHERE LAND1 = l_country.
  ENDIF.
ENDIF.


SELECT SIGN OPTI LOW HIGH INTO TABLE r_autopo FROM tvarvc
  WHERE NAME = 'ZMARKETLIST_AUTOPO'
  AND TYPE = 'S'.

IF PLANT NOT IN r_autopo.

"Non Auto PO

SELECT MARC~MATNR, MAKT~MAKTX, MARA~MEINS
INTO TABLE @lt_marc
    from ( MARC
           inner join MARA
           on  MARA~MATNR = MARC~MATNR
           inner join MAKT
           on  MAKT~MATNR = MARC~MATNR
           inner join MBEW
           on MARC~MATNR = MBEW~MATNR AND MARC~WERKS = MBEW~BWKEY
           )
         where MARC~WERKS = @PLANT
       AND MARA~LABOR = '999'
           and MARA~MSTAE = ''
           and MARC~MMSTA = ''
       AND MARC~LVORM <> 'X'
           and MAKT~SPRAS = @sy-langu
       AND MAKT~MAKTX NOT LIKE 'ZZ%'
  ORDER BY MARC~MATNR.
 "GROUP BY MARC~MATNR,MAKT~MAKTX,MARA~MEINS.

ELSE.

"Auto PO

SELECT MARC~MATNR, MAKT~MAKTX, MARA~MEINS, EORD~LIFNR, EORD~FLIFN, MARC~KAUTB, LFM1~KZAUT,LFM1~EKORG, EORD~MEINS
INTO TABLE @lt_marc
    from ( ( MARC
           inner join MARA
           on  MARA~MATNR = MARC~MATNR
           inner join MAKT
           on  MAKT~MATNR = MARC~MATNR
           inner join MBEW
           on MARC~MATNR = MBEW~MATNR AND MARC~WERKS = MBEW~BWKEY
           ) left join EORD
           on MARC~MATNR = EORD~MATNR AND MARC~WERKS = EORD~WERKS AND EORD~VDATU LE @sy-datum AND EORD~BDATU GE @sy-datum )
           left join LFM1
           on EORD~LIFNR = LFM1~LIFNR
         where MARC~WERKS = @PLANT
       AND MARA~LABOR = '999'
           and MARA~MSTAE = ''
           and MARC~MMSTA = ''
       AND MARC~LVORM <> 'X'
           and MAKT~SPRAS = @sy-langu
       AND MAKT~MAKTX NOT LIKE 'ZZ%'

 ORDER BY MARC~MATNR ASCENDING, EORD~FLIFN DESCENDING, MARC~KAUTB DESCENDING, LFM1~KZAUT DESCENDING.

 "DELETE lt_marc WHERE MATNR <> '000000001000002445'.
 "REFRESH lt_marc.
 DELETE lt_marc WHERE LIFNR IS NOT INITIAL AND EKORG NOT IN r_purchorg.
 DELETE ADJACENT DUPLICATES FROM lt_marc COMPARING MATNR.

ENDIF.

IF lt_marc[] IS INITIAL.
  EXIT.
ENDIF.

REFRESH ra_matnr[].
LOOP AT lt_marc ASSIGNING <ls_marc>.
   ra_matnr-sign = 'I'.
   ra_matnr-option = 'EQ'.
   ra_matnr-low = <ls_marc>-MATNR.
   append ra_matnr.
ENDLOOP.


SELECT MSEHI ANDEC INTO TABLE lt_T006 FROM T006.





IF l_EKORG IN r_purchorg.
"Purch. Org Specific

SELECT EINE~EKORG EINE~WERKS EINE~MINBM EINA~MEINS EINA~MATNR EINA~LIFNR INTO TABLE lt_EINA FROM EINA INNER JOIN EINE
  ON EINA~INFNR = EINE~INFNR AND EINE~EKORG = ls_T024W-EKORG
  WHERE
  EINA~LOEKZ = '' AND EINE~LOEKZ = ''
  AND EINE~EKORG = l_EKORG AND EINE~WERKS = '' AND
  EINA~MATNR in ra_matnr
  ORDER BY EINA~MATNR EINA~LIFNR EINE~MINBM DESCENDING .

SELECT EKORG LIFNR MATNR KNUMH DATBI ESOKZ INTO CORRESPONDING FIELDS OF TABLE lt_KNUMH FROM A018
 WHERE
   A018~EKORG IN r_purchorg
   AND A018~MATNR in ra_matnr
   AND A018~DATBI >= sy-datum
   AND A018~ESOKZ = '0'.

REFRESH ra_KNUMH[].
LOOP AT lt_KNUMH INTO ls_KNUMH.
     "READ TABLE lt_EINA WITH KEY EKORG = ls_KNUMH-EKORG WERKS = ls_KNUMH-WERKS  MATNR = ls_KNUMH-MATNR LIFNR = ls_KNUMH-LIFNR TRANSPORTING NO FIELDS.
     READ TABLE lt_EINA WITH KEY EKORG = ls_KNUMH-EKORG MATNR = ls_KNUMH-MATNR LIFNR = ls_KNUMH-LIFNR TRANSPORTING NO FIELDS.
     "IF sy-subrc ne 0.
     IF sy-subrc eq 0.
       ra_KNUMH-sign = 'I'.
       ra_KNUMH-option = 'EQ'.
       ra_KNUMH-low = ls_KNUMH-KNUMH.
       append ra_KNUMH.
     ENDIF.
ENDLOOP.

ELSE.
* Plant Specific Price
SELECT EKORG WERKS LIFNR MATNR KNUMH DATBI ESOKZ APPENDING TABLE lt_KNUMH FROM A017
 WHERE
   A017~EKORG IN r_purchorg
   AND A017~WERKS = PLANT
   AND A017~MATNR in ra_matnr
   AND A017~DATBI >= sy-datum
   AND A017~ESOKZ = '0'.

SELECT EINE~EKORG EINE~WERKS EINE~MINBM EINA~MEINS EINA~MATNR EINA~LIFNR INTO TABLE lt_EINA FROM EINA INNER JOIN EINE
  ON EINA~INFNR = EINE~INFNR AND EINE~EKORG = ls_T024W-EKORG
  WHERE
  EINA~LOEKZ = '' AND EINE~LOEKZ = ''
  AND EINE~WERKS = PLANT AND
  EINA~MATNR in ra_matnr
  ORDER BY EINA~MATNR EINA~LIFNR EINE~MINBM DESCENDING .

REFRESH ra_KNUMH[].
LOOP AT lt_KNUMH INTO ls_KNUMH.
     READ TABLE lt_EINA WITH KEY EKORG = ls_KNUMH-EKORG WERKS = ls_KNUMH-WERKS  MATNR = ls_KNUMH-MATNR LIFNR = ls_KNUMH-LIFNR TRANSPORTING NO FIELDS.
     "READ TABLE lt_EINA WITH KEY EKORG = ls_KNUMH-EKORG MATNR = ls_KNUMH-MATNR LIFNR = ls_KNUMH-LIFNR TRANSPORTING NO FIELDS.
     "IF sy-subrc ne 0.
     IF sy-subrc eq 0.
       ra_KNUMH-sign = 'I'.
       ra_KNUMH-option = 'EQ'.
       ra_KNUMH-low = ls_KNUMH-KNUMH.
       append ra_KNUMH.
     ENDIF.
ENDLOOP.
ENDIF.


DATA: l_UNITOFPRICE TYPE MEINS.


SELECT KONP~KNUMH KONP~KBETR KONP~KPEIN KONP~KMEIN KONP~LOEVM_KO
      INTO TABLE lt_KONP
      FROM KONP
      WHERE KONP~KNUMH IN ra_KNUMH
      AND KONP~KBETR > 0
      AND KONP~LOEVM_KO = ''

      ORDER BY KONP~KNUMH KONP~KBETR ASCENDING.

DELETE ADJACENT DUPLICATES FROM lt_KONP COMPARING KNUMH KBETR.

LOOP AT lt_marc ASSIGNING <ls_marc>.

 CLEAR ls_mmlist.
 ls_mmlist-MATNR = <ls_marc>-MATNR.
 ls_mmlist-MAKTX = <ls_marc>-MAKTX.
 ls_mmlist-WAERS = l_WAERS.
 ls_mmlist-LMEIN = <ls_marc>-MEINS.

 READ TABLE lt_EINA WITH KEY MATNR = <ls_marc>-MATNR LIFNR = <ls_marc>-LIFNR INTO ls_EINA .
 IF sy-subrc = 0.
     ls_mmlist-MINBM = ls_EINA-MINBM.
     l_UNITOFPRICE = ls_EINA-MEINS.
 ELSE.
   READ TABLE lt_EINA WITH KEY MATNR = <ls_marc>-MATNR INTO ls_EINA .
   IF sy-subrc = 0.
     ls_mmlist-MINBM = ls_EINA-MINBM.
     l_UNITOFPRICE = ls_EINA-MEINS.
   ENDIF.
 ENDIF.


 IF <ls_marc>-OMEINS IS NOT INITIAL.
    ls_mmlist-OMEIN = <ls_marc>-OMEINS.
 ENDIF.


   REFRESH ra_KNUMH[].

   IF PLANT IN r_autopo.
     ls_mmlist-LOCKED = 'X'.
   ENDIF.

   IF <ls_marc>-FLIFN = 'X'.

     LOOP AT lt_KNUMH INTO ls_KNUMH WHERE MATNR = <ls_marc>-MATNR AND LIFNR = <ls_marc>-LIFNR.
      ra_KNUMH-sign = 'I'.
      ra_KNUMH-option = 'EQ'.
      ra_KNUMH-low = ls_KNUMH-KNUMH.
      append ra_KNUMH.
     ENDLOOP.

   ELSE.
      LOOP AT lt_KNUMH INTO ls_KNUMH WHERE MATNR = <ls_marc>-MATNR.
        ra_KNUMH-sign = 'I'.
        ra_KNUMH-option = 'EQ'.
        ra_KNUMH-low = ls_KNUMH-KNUMH.
        append ra_KNUMH.
      ENDLOOP.
   ENDIF.

   IF sy-subrc eq 0.
      "CLEAR l_ORDERPRICEUNIT.
      CLEAR l_MENGE.
      CLEAR l_PRICEUNIT.

      ls_mmlist-NETPR = 0.
      LOOP AT lt_KONP INTO ls_KONP WHERE KNUMH IN ra_KNUMH.

        IF ls_mmlist-NETPR = 0 OR ls_KONP-KBETR < ls_mmlist-NETPR.
          ls_mmlist-NETPR = ls_KONP-KBETR.
          ls_mmlist-WAERS = l_WAERS.
          l_PRICEUNIT = ls_KONP-KPEIN.
          "l_ORDERPRICEUNIT = ls_KONP-KMEIN.

          IF ls_mmlist-OMEIN IS INITIAL.
            ls_mmlist-OMEIN = ls_KONP-KMEIN.
          ENDIF.

          IF PLANT IN r_autopo.
            IF ( <ls_marc>-FLIFN = 'X' AND <ls_marc>-KAUTB = 'X' AND <ls_marc>-KZAUT = 'X' AND ls_mmlist-NETPR > 0 ).
              ls_mmlist-LOCKED = ''.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF ls_mmlist-OMEIN IS INITIAL.
        ls_mmlist-OMEIN = ls_mmlist-LMEIN.
      ENDIF.

      "IF l_ORDERPRICEUNIT ne ls_mmlist-LMEIN.
*      IF ls_mmlist-OMEIN ne ls_mmlist-LMEIN.
*          CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
*              EXPORTING
*                I_MATNR                    = ls_mmlist-MATNR
*                I_IN_ME                    = ls_mmlist-OMEIN
*                I_OUT_ME                   = ls_mmlist-LMEIN
*                I_MENGE                    = 1
*             IMPORTING
*               E_MENGE                    =  l_MENGE
*             EXCEPTIONS
*               ERROR_IN_APPLICATION       = 1
*               ERROR                      = 2
*               OTHERS                     = 3
*                      .
*            IF SY-SUBRC <> 0.
*               l_MENGE = ls_KONP-KPEIN.
*            ENDIF.
*            ls_mmlist-UMREZ = l_MENGE.
*       ELSE.
*          IF l_UNITOFPRICE ne ls_mmlist-OMEIN.
*            CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
*              EXPORTING
*                I_MATNR                    = ls_mmlist-MATNR
*                I_IN_ME                    = l_UNITOFPRICE
*                I_OUT_ME                   = ls_mmlist-OMEIN
*                I_MENGE                    = 1
*             IMPORTING
*               E_MENGE                    =  l_MENGE
*             EXCEPTIONS
*               ERROR_IN_APPLICATION       = 1
*               ERROR                      = 2
*               OTHERS                     = 3
*                      .
*            IF SY-SUBRC <> 0.
*               l_MENGE = ls_KONP-KPEIN.
*            ENDIF.
*            ls_mmlist-UMREZ = l_MENGE.
*          ELSE.
*            l_MENGE = ls_KONP-KPEIN.
*          ENDIF.
*       ENDIF.


       IF ls_KONP-KMEIN ne ls_mmlist-LMEIN.
          CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
              EXPORTING
                I_MATNR                    = ls_mmlist-MATNR
                I_IN_ME                    = ls_KONP-KMEIN
                I_OUT_ME                   = ls_mmlist-LMEIN
                I_MENGE                    = 1
             IMPORTING
               E_MENGE                    =  l_MENGE
             EXCEPTIONS
               ERROR_IN_APPLICATION       = 1
               ERROR                      = 2
               OTHERS                     = 3
                      .
            IF SY-SUBRC <> 0.
              l_MENGE = ls_KONP-KPEIN.
            ENDIF.
       ELSE.
          l_MENGE = ls_KONP-KPEIN.
       ENDIF.

       "ls_mmlist-PEINH = l_MENGE * l_PRICEUNIT.
       ls_mmlist-PEINH = l_MENGE.

       IF ls_mmlist-OMEIN ne ls_mmlist-LMEIN.
          CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
              EXPORTING
                I_MATNR                    = ls_mmlist-MATNR
                I_IN_ME                    = ls_mmlist-OMEIN
                I_OUT_ME                   = ls_mmlist-LMEIN
                I_MENGE                    = 1
             IMPORTING
               E_MENGE                    =  l_MENGE
             EXCEPTIONS
               ERROR_IN_APPLICATION       = 1
               ERROR                      = 2
               OTHERS                     = 3
                      .
            IF SY-SUBRC <> 0.
               l_MENGE = 1.
            ENDIF.
       ELSE.
           l_MENGE = 1.
       ENDIF.
       ls_mmlist-UMREZ = l_MENGE.
  ELSE.
    ls_mmlist-PEINH = 1.
    ls_mmlist-WAERS = l_WAERS.
    IF ls_mmlist-OMEIN IS INITIAL.
        ls_mmlist-OMEIN = ls_mmlist-LMEIN.
    ENDIF.
  ENDIF.

  READ TABLE lt_T006 WITH KEY MSEHI = ls_mmlist-OMEIN INTO ls_T006.
  IF sy-subrc = 0.
    IF ls_T006-ANDEC ne 0.
      ls_mmlist-ALLOWDEC = 'Y'.
    ENDIF.
  ENDIF.


 APPEND ls_mmlist TO lt_mmlist.

ENDLOOP.

REFRESH lt_marc.
REFRESH lt_EINA.
REFRESH lt_KONP.
REFRESH lt_KNUMH.
FREE lt_marc.
FREE lt_EINA.
FREE lt_KONP.
FREE lt_KNUMH.

CLEAR r_trxid.
l_currdate = CURR_DATE.

"Next Week
DO 7 TIMES.
  wr_trxid-sign = 'I'.
  wr_trxid-option = 'EQ'.
  wr_trxid-low = l_currdate.
  APPEND wr_trxid TO r_trxid.
  l_currdate = l_currdate + 1.
ENDDO.

l_currdate = CURR_DATE - 1.

"Prev Week
DO 7 TIMES.
  wr_trxid-sign = 'I'.
  wr_trxid-option = 'EQ'.
  wr_trxid-low = l_currdate.
  APPEND wr_trxid TO r_trxid.
  l_currdate = l_currdate - 1.
ENDDO.


SELECT TRXID PREQ_NO INTO TABLE lt_preq_no FROM ZMM_MKTLIST_EH WHERE
    TRXID IN r_trxid AND WERKS IN r_plant AND KOSTL = KOSTL ORDER BY TRXID.

ASSIGN ls_preq_mat TO <ls_preq_mat>.

LOCKSTATUS = 'N:N:N:N:N:N:N'.
l_counter = 0.

LOOP AT lt_preq_no INTO ls_preq_no.

    IF ls_preq_no-trxid > sy-datum.
      "CHECK IF THERE IS PO CREATED FOR THIS PR
      l_counter = l_counter + 1.
      SELECT SINGLE EBELN INTO l_EBELN FROM EBAN WHERE BANFN = ls_preq_no-preq_no AND EBELN <> ''.
      IF sy-subrc eq 0.
         l_idx = ( l_counter - 1 ) * 2.
         LOCKSTATUS+l_idx(1) = 'Y'.
      ENDIF.
    ENDIF.

    "GET PR DETAIL
    CALL FUNCTION 'BAPI_PR_GETDETAIL'
      EXPORTING
       NUMBER                      = ls_preq_no-preq_no
       ACCOUNT_ASSIGNMENT          = ' '
       ITEM_TEXT                   = 'X'
*     IMPORTING
*       PRHEADER                    = PRHEADER
     TABLES
       RETURN                      = RETURN
       PRITEM                      = PRITEM
*       PRACCOUNT                   = PRACCOUNT
       PRITEMTEXT                  = PRITEMTEXT
     EXCEPTIONS
       OTHERS                      = 1.

    IF sy-subrc eq 0.

        LOOP AT PRITEM.
          IF PRITEM-DELETE_IND ne  'X'.
* Begin of UPG Retrofit Chermaine
            IF pritem-material_long IS INITIAL.
              pritem-material_long = pritem-material.
            ENDIF.
* End of UPG Retrofit Chermaine
            <ls_preq_mat>-trxid = ls_preq_no-trxid.
            <ls_preq_mat>-prid = pritem-preq_item.
* Begin of UPG Retrofit Chermaine
*            <ls_preq_mat>-matid = pritem-material.
            <ls_preq_mat>-matid = pritem-material_long.
* End of UPG Retrofit Chermaine
            <ls_preq_mat>-qty = pritem-quantity.
            <ls_preq_mat>-unit = pritem-unit.

            CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
            EXPORTING
                 INPUT                = pritem-unit
                 LANGUAGE             = SY-LANGU
            IMPORTING
                 OUTPUT               = <ls_preq_mat>-unit
            EXCEPTIONS
                 UNIT_NOT_FOUND       = 1
                 OTHERS               = 2.



              READ TABLE pritemtext WITH KEY PREQ_NO = ls_preq_no-preq_no PREQ_ITEM = pritem-PREQ_ITEM.
              IF sy-subrc = 0.
                   <ls_preq_mat>-text_line = pritemtext-text_line.
              ELSE.
                CLEAR <ls_preq_mat>-text_line.
              ENDIF.


            INSERT <ls_preq_mat> INTO TABLE lt_preq_mat.
          ENDIF.
        ENDLOOP.
    ENDIF.
ENDLOOP.


 "GET PR TEMPLATE
    CALL FUNCTION 'BAPI_PR_GETDETAIL'
      EXPORTING
       NUMBER                      = l_tmplpreqno
       ACCOUNT_ASSIGNMENT          = ' '
       ITEM_TEXT                   = ' '
*     IMPORTING
*       PRHEADER                    = PRHEADER
     TABLES
       RETURN                      = RETURN
       PRITEM                      = PRITEM
*       PRACCOUNT                   = PRACCOUNT
*       PRITEMTEXT                  = PRITEMTEXT
     EXCEPTIONS
       OTHERS                      = 1.

    IF sy-subrc ne 0.
      CLEAR PRITEM.
    ENDIF.


LOOP AT lt_mmlist ASSIGNING <ls_material>.

  "Check If Is Part Of Template
* Begin of UPG Retrofit Chermaine
*  READ TABLE PRITEM WITH KEY MATERIAL = <ls_material>-MATNR TRANSPORTING PREQ_ITEM DELETE_IND.
  READ TABLE PRITEM WITH KEY MATERIAL_LONG = <ls_material>-MATNR TRANSPORTING PREQ_ITEM DELETE_IND.
* End of UPG Retrofit Chermaine
  IF sy-subrc = 0.
    IF PRITEM-DELETE_IND = 'X'.
      <ls_material>-INTEMPLT = ''.
      <ls_material>-TEMPLTPRID = PRITEM-PREQ_ITEM.
    ELSE.
      <ls_material>-INTEMPLT = 'Y'.
      <ls_material>-TEMPLTPRID = PRITEM-PREQ_ITEM.
    ENDIF.
  ELSE.
    <ls_material>-INTEMPLT = ''.
  ENDIF.


  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
    EXPORTING
     INPUT                = <ls_material>-LMEIN
     LANGUAGE             = SY-LANGU
   IMPORTING
     OUTPUT               = <ls_material>-LMEIN
   EXCEPTIONS
     UNIT_NOT_FOUND       = 1
     OTHERS               = 2.

  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
    EXPORTING
     INPUT                = <ls_material>-OMEIN
     LANGUAGE             = SY-LANGU
   IMPORTING
     OUTPUT               = <ls_material>-OMEIN
   EXCEPTIONS
     UNIT_NOT_FOUND       = 1
     OTHERS               = 2.

  IF <ls_material>-PEINH ne 0.
    <ls_material>-NETPR_TMP = <ls_material>-NETPR / <ls_material>-PEINH.
  ELSE.
    <ls_material>-NETPR_TMP = 0.
  ENDIF.

  p_intval = <ls_material>-NETPR.

  CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
     EXPORTING
        CURRENCY              = <ls_material>-WAERS
        AMOUNT_INTERNAL       = p_intval
      IMPORTING
        AMOUNT_DISPLAY        = gd_disval
     EXCEPTIONS
       INTERNAL_ERROR        = 1
       OTHERS                = 2
              .
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

  <ls_material>-NETPR = gd_disval.


  l_counter = 0.
  LOOP AT r_trxid INTO wr_trxid.
    l_counter = l_counter + 1.
    READ TABLE lt_preq_mat ASSIGNING <ls_preq_mat> WITH TABLE KEY TRXID = wr_trxid-low MATID = <ls_material>-MATNR UNIT = <ls_material>-LMEIN.
    IF sy-subrc = 0.
       CASE l_counter.
          WHEN 1.
            "Today
            <ls_material>-DAYN1 = <ls_preq_mat>-qty.
            <ls_material>-TEXT_N1 = <ls_preq_mat>-TEXT_LINE.
            <ls_material>-PRID_N1 = <ls_preq_mat>-prid.
          WHEN 2.
            "Next 1
            <ls_material>-DAYN2 = <ls_preq_mat>-qty.
            <ls_material>-TEXT_N2 = <ls_preq_mat>-TEXT_LINE.
            <ls_material>-PRID_N2 = <ls_preq_mat>-prid.
          WHEN 3.
            "Next 2
            <ls_material>-DAYN3 = <ls_preq_mat>-qty.
            <ls_material>-TEXT_N3 = <ls_preq_mat>-TEXT_LINE.
            <ls_material>-PRID_N3 = <ls_preq_mat>-prid.
          WHEN 4.
            "Next 3
            <ls_material>-DAYN4 = <ls_preq_mat>-qty.
            <ls_material>-TEXT_N4 = <ls_preq_mat>-TEXT_LINE.
            <ls_material>-PRID_N4 = <ls_preq_mat>-prid.
          WHEN 5.
            "Next 4
            <ls_material>-DAYN5 = <ls_preq_mat>-qty.
            <ls_material>-TEXT_N5 = <ls_preq_mat>-TEXT_LINE.
            <ls_material>-PRID_N5 = <ls_preq_mat>-prid.
          WHEN 6.
            "Next 5
            <ls_material>-DAYN6 = <ls_preq_mat>-qty.
            <ls_material>-TEXT_N6 = <ls_preq_mat>-TEXT_LINE.
            <ls_material>-PRID_N6 = <ls_preq_mat>-prid.
          WHEN 7.
            "Next 6
            <ls_material>-DAYN7 = <ls_preq_mat>-qty.
            <ls_material>-TEXT_N7 = <ls_preq_mat>-TEXT_LINE.
            <ls_material>-PRID_N7 = <ls_preq_mat>-prid.
          WHEN 8.
            "Prev 1
            <ls_material>-DAYP1 = <ls_preq_mat>-qty.
          WHEN 9.
            "Prev 2
            <ls_material>-DAYP2 = <ls_preq_mat>-qty.
          WHEN 10.
            "Prev 3
            <ls_material>-DAYP3 = <ls_preq_mat>-qty.
          WHEN 11.
            "Prev 4
            <ls_material>-DAYP4 = <ls_preq_mat>-qty.
          WHEN 12.
            "Prev 5
            <ls_material>-DAYP5 = <ls_preq_mat>-qty.
          WHEN 13.
            "Prev 6
            <ls_material>-DAYP6 = <ls_preq_mat>-qty.
          WHEN 14.
            "Prev 6
            <ls_material>-DAYP7 = <ls_preq_mat>-qty.
       ENDCASE.

    ENDIF.
  ENDLOOP.
ENDLOOP.

SORT lt_mmlist BY MAKTX LMEIN NETPR_TMP ASCENDING.
DELETE ADJACENT DUPLICATES FROM lt_mmlist COMPARING MATNR LMEIN.

APPEND LINES OF lt_mmlist TO MATERIAL_LIST.



ENDFUNCTION.
