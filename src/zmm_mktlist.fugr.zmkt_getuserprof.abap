FUNCTION ZMKT_GETUSERPROF.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      USERPROFILE STRUCTURE  ZMM_MKTUSRPROF OPTIONAL
*"----------------------------------------------------------------------

TYPES: BEGIN OF ty_coplant,
        BUKRS TYPE BUKRS,
        WERKS TYPE WERKS_D,
        NAME1 TYPE NAME1,
       END OF ty_coplant.

TYPES: BEGIN OF ty_costctr,
        KOSTL TYPE KOSTL,
        KTEXT TYPE KTEXT,
       END OF ty_costctr.


DATA: ls_coplant TYPE ty_coplant,
      ls_costctr TYPE ty_costctr.

DATA: l_cocostctr1_wildcard TYPE STRING,
      l_cocostctr2_wildcard TYPE STRING,
      l_index TYPE i.

DATA: lt_auth_plant LIKE STANDARD TABLE OF usvalues,
      ls_auth_plant TYPE usvalues.

DATA: r_plant TYPE RANGE OF MARC-WERKS,
      wr_plant LIKE LINE OF r_plant.

DATA: r_trxid TYPE RANGE OF sy-datum,
      wr_trxid LIKE LINE OF r_trxid,
      l_date TYPE datum.

DATA: lt_ZMM_MKTLIST_EH TYPE STANDARD TABLE OF ZMM_MKTLIST_EH.

FIELD-SYMBOLS: <fs_ZMM_MKTLIST_EH> TYPE ZMM_MKTLIST_EH.



DATA: ls_mmuserprof TYPE ZMM_MKTUSRPROF.

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

DELETE lt_auth_plant WHERE FIELD <> 'WERKS'.
DELETE ADJACENT DUPLICATES FROM lt_auth_plant COMPARING VON.

LOOP AT lt_auth_plant INTO ls_auth_plant.
  IF ls_auth_plant-FIELD = 'WERKS'.
    IF ls_auth_plant-VON = '*'.
      wr_plant-sign = 'I'.
      wr_plant-option = 'CP'.
      wr_plant-low = '*'.
      APPEND wr_plant TO r_plant.
    ELSE.
      wr_plant-sign = 'I'.
      wr_plant-option = 'EQ'.
      wr_plant-low = ls_auth_plant-VON.
      APPEND wr_plant TO r_plant.
    ENDIF.
  ENDIF.
ENDLOOP.



l_date = sy-datum + 1.

DO 7 TIMES.
   wr_trxid-sign = 'I'.
   wr_trxid-option = 'EQ'.
   wr_trxid-low = l_date.
   APPEND wr_trxid TO r_trxid.
   l_date = l_date + 1.
ENDDO.

l_date = sy-datum.

DO 7 TIMES.
   wr_trxid-sign = 'I'.
   wr_trxid-option = 'EQ'.
   wr_trxid-low = l_date.
   APPEND wr_trxid TO r_trxid.
   l_date = l_date - 1.
ENDDO.



SELECT * INTO TABLE lt_ZMM_MKTLIST_EH FROM ZMM_MKTLIST_EH WHERE TRXID IN r_trxid AND WERKS IN r_plant ORDER BY WERKS TRXID.


SELECT T001K~BUKRS T001K~BWKEY as WERKS T001W~NAME1 INTO ls_coplant FROM
    T001K INNER JOIN T001W ON T001K~BWKEY = T001W~WERKS
    WHERE T001K~BWKEY IN r_plant.
    CONCATENATE ls_coplant-BUKRS '301%' INTO l_cocostctr1_wildcard.
    CONCATENATE ls_coplant-BUKRS '220%' INTO l_cocostctr2_wildcard.

    SELECT CSKS~KOSTL CSKT~KTEXT INTO ls_costctr FROM CSKS INNER JOIN CSKT ON CSKS~KOSTL = CSKT~KOSTL WHERE BUKRS = ls_coplant-BUKRS AND CSKT~SPRAS = 'E' AND CSKS~KOSTL LIKE l_cocostctr1_wildcard OR CSKS~KOSTL LIKE l_cocostctr2_wildcard.

       CLEAR ls_mmuserprof.
       ls_mmuserprof-WERKS = ls_coplant-WERKS.
       ls_mmuserprof-NAME1 = ls_coplant-NAME1.
       ls_mmuserprof-KOSTL = ls_costctr-KOSTL.
       ls_mmuserprof-KTEXT = ls_costctr-KTEXT.

       l_index = 0.
       LOOP AT r_trxid INTO wr_trxid.
         l_index = l_index + 1.
         READ TABLE lt_ZMM_MKTLIST_EH ASSIGNING <fs_ZMM_MKTLIST_EH> WITH KEY TRXID = wr_trxid-low BUKRS = ls_coplant-BUKRS WERKS = ls_coplant-WERKS KOSTL = ls_costctr-KOSTL.
         IF sy-subrc = 0.
           CASE l_index.
              WHEN 1.
                 ls_mmuserprof-DAYN1 = <fs_ZMM_MKTLIST_EH>-PREQ_NO.
              WHEN 2.
                ls_mmuserprof-DAYN2 = <fs_ZMM_MKTLIST_EH>-PREQ_NO.
              WHEN 3.
                ls_mmuserprof-DAYN3 = <fs_ZMM_MKTLIST_EH>-PREQ_NO.
              WHEN 4.
                ls_mmuserprof-DAYN4 = <fs_ZMM_MKTLIST_EH>-PREQ_NO.
              WHEN 5.
                ls_mmuserprof-DAYN5 = <fs_ZMM_MKTLIST_EH>-PREQ_NO.
              WHEN 6.
                ls_mmuserprof-DAYN6 = <fs_ZMM_MKTLIST_EH>-PREQ_NO.
              WHEN 7.
                ls_mmuserprof-DAYN7 = <fs_ZMM_MKTLIST_EH>-PREQ_NO.
              WHEN 8.
                ls_mmuserprof-DAYP1 = <fs_ZMM_MKTLIST_EH>-PREQ_NO.
              WHEN 9.
                ls_mmuserprof-DAYP2 = <fs_ZMM_MKTLIST_EH>-PREQ_NO.
              WHEN 10.
                ls_mmuserprof-DAYP3 = <fs_ZMM_MKTLIST_EH>-PREQ_NO.
              WHEN 11.
                ls_mmuserprof-DAYP4 = <fs_ZMM_MKTLIST_EH>-PREQ_NO.
              WHEN 12.
                ls_mmuserprof-DAYP5 = <fs_ZMM_MKTLIST_EH>-PREQ_NO.
              WHEN 13.
                ls_mmuserprof-DAYP6 = <fs_ZMM_MKTLIST_EH>-PREQ_NO.
              WHEN 14.
                ls_mmuserprof-DAYP7 = <fs_ZMM_MKTLIST_EH>-PREQ_NO.
            ENDCASE.
         ENDIF.
       ENDLOOP.

       APPEND ls_mmuserprof TO USERPROFILE.
    ENDSELECT.
ENDSELECT.



ENDFUNCTION.
