FUNCTION ZMKT_UPDMRKTLIST.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     VALUE(E_NUMBER) TYPE  BANFN
*"  TABLES
*"      MKTLIST_EH STRUCTURE  ZMM_MKTLIST_EH
*"      MKTLIST_ED STRUCTURE  ZMM_MKTLIST_S
*"      MESSAGE STRUCTURE  ZMM_MKTMESSAGE
*"----------------------------------------------------------------------

FIELD-SYMBOLS:
               <ls_MKTLIST_ED> TYPE ZMM_MKTLIST_S,
               <ls_pritems> TYPE BAPIEBAN,
               <ls_old> TYPE BAPIEBANV,
               <ls_new> TYPE BAPIEBANV,
               <ls_delete> TYPE BAPIEBAND.

DATA: l_BUKRS TYPE BUKRS,
      l_EBELN TYPE EBELN.


DATA: l_authorized TYPE CHAR1.

DATA:
      prheader TYPE bapimereqheader,
      prheaderx TYPE bapimereqheaderx,
      PRITEMEXP LIKE TABLE OF BAPIMEREQITEM WITH HEADER LINE,
      return LIKE TABLE OF bapiret2 WITH HEADER LINE,
      pritem LIKE TABLE OF bapimereqitemimp WITH HEADER LINE,
      pritemx LIKE TABLE OF bapimereqitemx WITH HEADER LINE,
      PRITEMTEXT LIKE TABLE OF BAPIMEREQITEMTEXT WITH HEADER LINE,
      praccount LIKE TABLE OF BAPIMEREQACCOUNT WITH HEADER LINE,
      praccountx LIKE TABLE OF bapimereqaccountx WITH HEADER LINE.

DATA:
      preq_item TYPE eban-bnfpo,
      latest_prid TYPE eban-bnfpo,
      preq_no LIKE BAPIMEREQHEADER-PREQ_NO,
      ls_MKTLIST_EH TYPE ZMM_MKTLIST_EH,
      run_mode TYPE CHAR3,
      r_autopo TYPE RANGE OF char4.


l_authorized = ''.

LOOP AT MKTLIST_EH INTO ls_MKTLIST_EH.


  SELECT SINGLE T001K~BUKRS INTO l_BUKRS FROM T001K
    WHERE T001K~BWKEY  = ls_MKTLIST_EH-WERKS.
  IF SY-SUBRC = 0.


  AUTHORITY-CHECK OBJECT 'M_BANF_WRK'
             ID 'ACTVT' FIELD '03'
             ID 'WERKS' FIELD ls_MKTLIST_EH-WERKS.
  IF SY-SUBRC <> 0.
    l_authorized = ''.
    EXIT.
  ELSE.
    l_authorized = 'X'.
  ENDIF.


  ls_MKTLIST_EH-BUKRS = l_BUKRS.
  ls_MKTLIST_EH-ERNAM = sy-uname.

  MODIFY MKTLIST_EH FROM ls_MKTLIST_EH.



  ENDIF.
ENDLOOP.

IF l_authorized = 'X'.

"Auto PO
SELECT SIGN OPTI LOW HIGH INTO TABLE r_autopo FROM tvarvc
  WHERE NAME = 'ZMARKETLIST_AUTOPO'
  AND TYPE = 'S'.


  CLEAR preq_item.

  READ TABLE MKTLIST_EH INTO ls_MKTLIST_EH INDEX 1.
  IF sy-subrc = 0.

    CLEAR prheader.
    CLEAR prheaderx.
    prheader-pr_type = 'ZML'.
    prheaderx-pr_type = 'X'.

    IF ls_MKTLIST_EH-WERKS in r_autopo.
      prheader-AUTO_SOURCE = 'X'.
      prheaderx-AUTO_SOURCE = 'X'.
    ENDIF.

    CONCATENATE ls_MKTLIST_EH-WERKS ls_MKTLIST_EH-KOSTL+4 INTO prheader-PREQ_NO.
    PREQ_NO = prheader-PREQ_NO.

    CLEAR latest_prid.

    SORT MKTLIST_ED BY TEMPLTPRID DESCENDING.
    READ TABLE MKTLIST_ED ASSIGNING <ls_MKTLIST_ED> INDEX 1.
    IF sy-subrc = 0.
      IF <ls_MKTLIST_ED>-INTEMPLT = 'Y' OR <ls_MKTLIST_ED>-INTEMPLT = 'X'.
          latest_prid = <ls_MKTLIST_ED>-TEMPLTPRID.
      ENDIF.
    ENDIF.

    LOOP AT MKTLIST_ED ASSIGNING <ls_MKTLIST_ED> WHERE INTEMPLT = 'Y' OR INTEMPLT = 'X'.

        CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
        EXPORTING
            INPUT              = <ls_MKTLIST_ED>-MATNR
        IMPORTING
            OUTPUT             = <ls_MKTLIST_ED>-MATNR
        EXCEPTIONS
            LENGTH_ERROR       = 1
            OTHERS             = 2.

        IF <ls_MKTLIST_ED>-TEMPLTPRID IS INITIAL.
            ADD 10 TO latest_prid.
            preq_item = latest_prid.
            <ls_MKTLIST_ED>-TEMPLTPRID = preq_item.
        ELSE.
            preq_item = <ls_MKTLIST_ED>-TEMPLTPRID.
        ENDIF.

        CLEAR pritem.
        pritem-preq_item = preq_item.
        pritem-material = <ls_MKTLIST_ED>-MATNR.
* Begin of UPG Retrofit Chermaine
        pritem-material_long = <ls_MKTLIST_ED>-MATNR.
* End of UPG Retrofit Chermaine
        pritem-plant = <ls_MKTLIST_ED>-WERKS.
        pritem-quantity = 1.

        IF <ls_MKTLIST_ED>-UMREZ > 0.
          pritem-PRICE_UNIT = <ls_MKTLIST_ED>-UMREZ.
          pritem-preq_price = <ls_MKTLIST_ED>-NETPR.
        ELSE.
          pritem-PRICE_UNIT = 0.
          pritem-preq_price = 0.
        ENDIF.
        pritem-currency = <ls_MKTLIST_ED>-WAERS.
        pritem-pur_group = '037'.
        pritem-MRP_CTRLER = '999'.
        pritem-acctasscat = 'K'.
        pritem-DEL_DATCAT_EXT = '1'.
        pritem-trackingno = ls_MKTLIST_EH-TRACKINGNO.
        pritem-PREQ_NAME = ls_MKTLIST_EH-PREQ_NAME.


       CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
            EXPORTING
              input          = <ls_MKTLIST_ED>-LMEIN
              language       = sy-langu
            IMPORTING
              output         = pritem-unit
            EXCEPTIONS
              unit_not_found = 1
              OTHERS         = 2.

        SELECT SINGLE MATKL INTO pritem-MATL_GROUP FROM MARA WHERE MATNR = <ls_MKTLIST_ED>-MATNR.

        IF <ls_MKTLIST_ED>-INTEMPLT = 'X'.
          pritem-DELETE_IND = 'X'.
        ELSE.
          pritem-DELETE_IND = ' '.
        ENDIF.

        APPEND pritem.

        CLEAR pritemx.
        pritemx-PREQ_ITEM = preq_item.
        pritemx-preq_itemX = 'X'.
        pritemx-material = 'X'.
* Begin of UPG Retrofit Chermaine
        pritemx-material_long = 'X'.
* End of UPG Retrofit Chermaine
        pritemx-plant = 'X'.
        pritemx-pur_group = 'X'.
        pritemx-preq_price = 'X'.
        pritemx-MRP_CTRLER = 'X'.
        pritemx-currency = 'X'.
        pritemx-acctasscat = 'X'.
        pritemx-price_unit = 'X'.
        pritemx-del_datcat_ext = 'X'.
        pritemx-trackingno = 'X'.
        pritemx-DELETE_IND = 'X'.
        pritemx-PREQ_NAME = 'X'.
        pritemx-SHORT_TEXT = 'X'.
        pritemx-quantity = 'X'.
        pritemx-unit = 'X'.
        APPEND pritemx.

        CLEAR praccount.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              input  = ls_MKTLIST_EH-KOSTL
            IMPORTING
              output = praccount-COSTCENTER.

        praccount-preq_item = preq_item.
        praccount-serial_no = '01'.
        "praccount-gl_account = '0000706011'.
        praccount-quantity = <ls_MKTLIST_ED>-MENGE.
        praccount-unload_pt = ls_MKTLIST_EH-ABLAD.
        praccount-gr_rcpt = ls_MKTLIST_EH-WEMPF.



        APPEND praccount.
        praccountx-preq_item = preq_item.
        praccountx-serial_no = '01'.
        praccountx-preq_itemx = 'X'.
        "praccountx-gl_account = 'X'.
        praccountx-serial_nox = 'X'.

        praccountx-quantity = 'X'.
        praccountx-unload_pt = 'X'.
        praccountx-gr_rcpt = 'X'.
        praccountx-COSTCENTER  = 'X'.

        APPEND praccountx.

    ENDLOOP.

    IF preq_item IS NOT INITIAL.

        SELECT SINGLE BANFN INTO PREQ_NO FROM EBAN WHERE BANFN = PREQ_NO.
        IF sy-subrc ne 0.
          CALL FUNCTION 'BAPI_PR_CREATE'
               EXPORTING
                 PRHEADER                     = PRHEADER
                 PRHEADERX                    = PRHEADERX
                 TESTRUN                      = ' '
               IMPORTING
                 NUMBER                       = preq_no
                TABLES
                  RETURN     =  RETURN
                  pritem     =  PRITEM
                  PRITEMX     =  PRITEMX
                  praccount = praccount
                  praccountx = praccountx
                  PRITEMTEXT  = PRITEMTEXT.


              CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                wait = 'X'.
           ELSE.
              CALL FUNCTION 'BAPI_PR_CHANGE'
                  EXPORTING
                    NUMBER                       = preq_no
                    PRHEADER                     = PRHEADER
                    PRHEADERX                    = PRHEADERX
                    TESTRUN                      = ' '
*                 IMPORTING
*                   PRHEADEREXP                  =
                  TABLES
                    RETURN                       = RETURN
                    PRITEM                       = PRITEM
                    PRITEMX                      = PRITEMX
                    PRACCOUNT                    = PRACCOUNT
                    PRACCOUNTX                   = PRACCOUNTX
                    PRITEMTEXT                   = PRITEMTEXT

                          .
                CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                  EXPORTING
                    wait = 'X'.
            ENDIF.
    ENDIF.
  ENDIF.

  CLEAR PREQ_NO.
  CLEAR prheader.
  CLEAR prheaderx.
  CLEAR latest_prid.
  prheader-pr_type = 'ZML'.
  prheaderx-pr_type = 'X'.


  LOOP AT MKTLIST_EH INTO ls_MKTLIST_EH.

     CLEAR preq_item.
     REFRESH pritem.
     REFRESH pritemx.
     REFRESH praccount.
     REFRESH praccountx.
     REFRESH PRITEMTEXT.
     REFRESH RETURN.

    IF ls_MKTLIST_EH-WERKS in r_autopo.
      prheader-AUTO_SOURCE = 'X'.
      prheaderx-AUTO_SOURCE = 'X'.
    ENDIF.

    SORT MKTLIST_ED BY TRXID ASCENDING PRID DESCENDING.

    LOOP AT MKTLIST_ED ASSIGNING <ls_MKTLIST_ED> WHERE TRXID = ls_MKTLIST_EH-TRXID AND MENGE <> 0.

         "<ls_MKTLIST_ED>-TRXID = l_TRXID.

         AT NEW TRXID.
           IF <ls_MKTLIST_ED>-PRID IS NOT INITIAL.
             latest_prid = <ls_MKTLIST_ED>-PRID.
           ELSE.
             CLEAR latest_prid.
           ENDIF.
         ENDAT.


         CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
          EXPORTING
            INPUT              = <ls_MKTLIST_ED>-MATNR
         IMPORTING
           OUTPUT              = <ls_MKTLIST_ED>-MATNR
         EXCEPTIONS
           LENGTH_ERROR       = 1
           OTHERS             = 2
                  .
        IF SY-SUBRC <> 0.
*       Implement suitable error handling here
        ENDIF.

        IF <ls_MKTLIST_ED>-PRID IS INITIAL.
            ADD 10 TO latest_prid.
            preq_item = latest_prid.
            <ls_MKTLIST_ED>-PRID = preq_item.
        ELSE.
            preq_item = <ls_MKTLIST_ED>-PRID.
        ENDIF.

        CLEAR pritem.

        IF <ls_MKTLIST_ED>-DELETE_IND = 'X'.
          pritem-DELETE_IND = 'X'.
        ELSE.
          pritem-DELETE_IND = ' '.
        ENDIF.

        pritem-preq_item = preq_item.
        pritem-material = <ls_MKTLIST_ED>-MATNR.
* Begin of UPG Retrofit Chermaine
        pritem-material_long = <ls_MKTLIST_ED>-MATNR.
* End of UPG Retrofit Chermaine
        pritem-plant = <ls_MKTLIST_ED>-WERKS.
        pritem-quantity = <ls_MKTLIST_ED>-MENGE.

        IF <ls_MKTLIST_ED>-UMREZ > 0.
          pritem-PRICE_UNIT = <ls_MKTLIST_ED>-UMREZ.
          pritem-preq_price = <ls_MKTLIST_ED>-NETPR.
        ELSE.
          pritem-PRICE_UNIT = 0.
          pritem-preq_price = 0.
        ENDIF.
        pritem-currency = <ls_MKTLIST_ED>-WAERS.
        pritem-pur_group = '037'.
        pritem-MRP_CTRLER = '999'.
        pritem-acctasscat = 'K'.
        pritem-DEL_DATCAT_EXT = '1'.
        pritem-deliv_date = ls_MKTLIST_EH-EEIND.
        pritem-trackingno = ls_MKTLIST_EH-TRACKINGNO.
        pritem-PREQ_NAME = ls_MKTLIST_EH-PREQ_NAME.



         CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
            EXPORTING
              input          = <ls_MKTLIST_ED>-LMEIN
              language       = sy-langu
            IMPORTING
              output         = pritem-unit
            EXCEPTIONS
              unit_not_found = 1
              OTHERS         = 2.

        SELECT SINGLE MATKL INTO pritem-MATL_GROUP FROM MARA WHERE MATNR = <ls_MKTLIST_ED>-MATNR.

        APPEND pritem.

        CLEAR pritemx.
        pritemx-PREQ_ITEM = preq_item.
        pritemx-preq_itemX = 'X'.
        pritemx-material = 'X'.
* Begin of UPG Retrofit Chermaine
        pritemx-material_long = 'X'.
* End of UPG Retrofit Chermaine
        pritemx-plant = 'X'.
        pritemx-pur_group = 'X'.
        pritemx-preq_price = 'X'.
        pritemx-MRP_CTRLER = 'X'.
        pritemx-currency = 'X'.
        pritemx-acctasscat = 'X'.
        pritemx-DELETE_IND = 'X'.
        pritemx-price_unit = 'X'.
        pritemx-del_datcat_ext = 'X'.
        pritemx-deliv_date = 'X'.
        pritemx-trackingno = 'X'.
        pritemx-PREQ_NAME = 'X'.
        pritemx-SHORT_TEXT = 'X'.
        pritemx-quantity = 'X'.
        pritemx-unit = 'X'.
        APPEND pritemx.

*    Account Assignment

        CLEAR praccount.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              input  = ls_MKTLIST_EH-KOSTL
            IMPORTING
              output = praccount-COSTCENTER.

        praccount-preq_item = preq_item.
        praccount-serial_no = '01'.
        "praccount-gl_account = '0000706011'.
        praccount-quantity = <ls_MKTLIST_ED>-MENGE.
        praccount-unload_pt = ls_MKTLIST_EH-ABLAD.
        praccount-gr_rcpt = ls_MKTLIST_EH-WEMPF.



        APPEND praccount.
        praccountx-preq_item = preq_item.
        praccountx-serial_no = '01'.
        praccountx-preq_itemx = 'X'.
        "praccountx-gl_account = 'X'.
        praccountx-serial_nox = 'X'.

        praccountx-quantity = 'X'.
        praccountx-unload_pt = 'X'.
        praccountx-gr_rcpt = 'X'.
        praccountx-COSTCENTER  = 'X'.

        APPEND praccountx.

*    Item text


        PRITEMTEXT-PREQ_ITEM = preq_item.
        PRITEMTEXT-TEXT_ID = 'B01'.
        PRITEMTEXT-TEXT_LINE = <ls_MKTLIST_ED>-TEXT_LINE.
        append PRITEMTEXT.

      ENDLOOP.

      IF PRITEM[] IS NOT INITIAL.
          CLEAR preq_no.
          SELECT SINGLE PREQ_NO INTO preq_no FROM ZMM_MKTLIST_EH WHERE TRXID = ls_MKTLIST_EH-TRXID AND BUKRS = ls_MKTLIST_EH-BUKRS AND WERKS = ls_MKTLIST_EH-WERKS AND KOSTL = ls_MKTLIST_EH-KOSTL.
          IF sy-subrc ne 0.
              "CREATE NEW PR
              run_mode = 'CRT'.
              CALL FUNCTION 'BAPI_PR_CREATE'
               EXPORTING
                 PRHEADER                     = PRHEADER
                 PRHEADERX                    = PRHEADERX
                 TESTRUN                      = ' '
               IMPORTING
                 NUMBER                       = preq_no
                TABLES
                  RETURN     =  RETURN
                  pritem     =  PRITEM
                  PRITEMX     =  PRITEMX
                  praccount = praccount
                  praccountx = praccountx
                  PRITEMTEXT  = PRITEMTEXT.


              CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                wait = 'X'.
          ELSE.
            "EDIT CURRENT PR
            run_mode = 'CHG'.

            "CHECK IF THERE IS PO CREATED FOR THIS PR
            SELECT SINGLE EBELN INTO l_EBELN FROM EBAN WHERE BANFN = preq_no AND EBELN <> ''.
            IF sy-subrc = 0.
               CLEAR RETURN.
               RETURN-TYPE = 'E'.
               RETURN-ID = 'BL'.
               RETURN-NUMBER = '001'.
               RETURN-MESSAGE_V1 = 'PR: ['.
               RETURN-MESSAGE_V2 = preq_no.
               RETURN-MESSAGE_V3 = '] has been locked. Please contact Purchasing Dept.'.
               APPEND RETURN.
            ELSE.
              DO 2 TIMES.
                CALL FUNCTION 'BAPI_PR_CHANGE'
                  EXPORTING
                    NUMBER                       = preq_no
                    PRHEADER                     = PRHEADER
                    PRHEADERX                    = PRHEADERX
                    TESTRUN                      = ' '
*                 IMPORTING
*                   PRHEADEREXP                  =
                  TABLES
                    RETURN                       = RETURN
                    PRITEM                       = PRITEM
                    PRITEMX                      = PRITEMX
*                   PRITEMEXP                    =
*                   PRITEMSOURCE                 =
                    PRACCOUNT                    = PRACCOUNT
*                   PRACCOUNTPROITSEGMENT        =
                    PRACCOUNTX                   = PRACCOUNTX
*                   PRADDRDELIVERY               =
                    PRITEMTEXT                   = PRITEMTEXT
*                   PRHEADERTEXT                 =
*                   EXTENSIONIN                  =
*                   EXTENSIONOUT                 =
*                   PRVERSION                    =
*                   PRVERSIONX                   =
*                   ALLVERSIONS                  =
*                   PRCOMPONENTS                 =
*                   PRCOMPONENTSX                =
*                   SERVICEOUTLINE               =
*                   SERVICEOUTLINEX              =
*                   SERVICELINES                 =
*                   SERVICELINESX                =
*                   SERVICELIMIT                 =
*                   SERVICELIMITX                =
*                   SERVICECONTRACTLIMITS        =
*                   SERVICECONTRACTLIMITSX       =
*                   SERVICEACCOUNT               =
*                   SERVICEACCOUNTX              =
*                   SERVICELONGTEXTS             =
*                   SERIALNUMBER                 =
*                   SERIALNUMBERX                =
                          .
                CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                  EXPORTING
                    wait = 'X'.
                ENDDO.
            ENDIF.
          ENDIF.
          FREE PRITEMTEXT.
          CLEAR MESSAGE.

          LOOP AT RETURN WHERE type = 'E' OR type = 'A'.

                 MESSAGE-TRXID = ls_MKTLIST_EH-TRXID.
                 MESSAGE-MSGTYPE = RETURN-TYPE.

                 CALL FUNCTION 'FORMAT_MESSAGE'
                   EXPORTING
                     id        = RETURN-id
                     lang      = sy-langu
                     no        = RETURN-number
                     v1        = RETURN-message_v1
                     v2        = RETURN-message_v2
                     v3        = RETURN-message_v3
                     v4        = RETURN-message_v4
                   IMPORTING
                     msg       = MESSAGE-MESSAGE
                   EXCEPTIONS
                     not_found = 1
                     OTHERS    = 2.

                 APPEND MESSAGE.
          ENDLOOP.

          IF MESSAGE IS INITIAL.
              IF run_mode = 'CRT'.
                MESSAGE-TRXID = ls_MKTLIST_EH-TRXID.
                MESSAGE-MSGTYPE = 'I'.
                CONCATENATE 'PR no.: [' preq_no '] created for plant' ls_MKTLIST_EH-WERKS INTO MESSAGE-MESSAGE SEPARATED BY space.
                APPEND MESSAGE.
                ls_MKTLIST_EH-PREQ_NO = preq_no.
                MODIFY ZMM_MKTLIST_EH FROM ls_MKTLIST_EH.
                E_NUMBER = preq_no.
              ELSE.
                MESSAGE-TRXID = ls_MKTLIST_EH-TRXID.
                MESSAGE-MSGTYPE = 'I'.
                CONCATENATE 'PR no.: [' preq_no '] updated in ERP' INTO MESSAGE-MESSAGE SEPARATED BY space.
                APPEND MESSAGE.
              ENDIF.
          ENDIF.
      ENDIF.

   ENDLOOP.
ENDIF.




ENDFUNCTION.
