class ZCL_ZUOLPO_ODATA_DPC_EXT definition
  public
  inheriting from ZCL_ZUOLPO_ODATA_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_EXPANDED_ENTITYSET
    redefinition .
protected section.
private section.

  methods PO_CREATE_DEEP_ENITTY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IO_DATA_PROVIDER type ref to /IWBEP/IF_MGW_ENTRY_PROVIDER
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IO_EXPAND type ref to /IWBEP/IF_MGW_ODATA_EXPAND
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_C
    exporting
      !ER_DEEP_ENTITY type ZCL_ZUOLPO_ODATA_MPC_EXT=>TS_DEEP
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
ENDCLASS.



CLASS ZCL_ZUOLPO_ODATA_DPC_EXT IMPLEMENTATION.


  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY.

  DATA: ls_deep_entity TYPE ZCL_ZUOLPO_ODATA_MPC_EXT=>TS_DEEP.

  CASE IV_ENTITY_SET_NAME.
    WHEN 'PORootSet'.
      CALL METHOD me->PO_CREATE_DEEP_ENITTY
        EXPORTING
          IV_ENTITY_NAME = IV_ENTITY_NAME
          IV_ENTITY_SET_NAME = IV_ENTITY_SET_NAME
          IV_SOURCE_NAME = IV_SOURCE_NAME
          IO_DATA_PROVIDER = IO_DATA_PROVIDER
          IT_KEY_TAB = IT_KEY_TAB
          IT_NAVIGATION_PATH = IT_NAVIGATION_PATH
          IO_EXPAND = IO_EXPAND
          IO_TECH_REQUEST_CONTEXT = IO_TECH_REQUEST_CONTEXT
         IMPORTING
           ER_DEEP_ENTITY = LS_DEEP_ENTITY.

      COPY_DATA_TO_REF(
        EXPORTING
         IS_DATA  = LS_DEEP_ENTITY
        CHANGING
          CR_DATA = ER_DEEP_ENTITY
      ).

  ENDCASE.
  endmethod.


  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_EXPANDED_ENTITYSET.


DATA: ls_deep_entity TYPE ZCL_ZUOLPO_ODATA_MPC_EXT=>TS_DEEP,
      lt_deep_entity LIKE TABLE OF ls_deep_entity.
DATA: ls_expanded_clause LIKE LINE OF ET_EXPANDED_TECH_CLAUSES.

DATA:
      ls_POHEADER LIKE LINE OF ls_deep_entity-POHEADERSET,
      ls_POITEM LIKE LINE OF ls_deep_entity-POITEMSET,
      ls_POSCHEDULE LIKE LINE OF ls_deep_entity-ITEMSCHEDULESET,
 	    ls_POACCOUNT LIKE LINE OF ls_deep_entity-ITEMACCOUNTSET,
 	    ls_POITEMTEXT LIKE LINE OF ls_deep_entity-POTEXTITEMSET.


ls_deep_entity-GUID = '1'.
ls_deep_entity-POMODE = 'XX'.
ls_deep_entity-TRXMODE = ''.

ls_POHEADER-GUID = '1'.
ls_POHEADER-COMP_CODE = '9130'.
ls_POHEADER-DOC_TYPE = 'NB'.
ls_POHEADER-VENDOR = '1000009184'.
ls_POHEADER-PUR_GROUP = '099'.
ls_POHEADER-PURCH_ORG = 'C103'.
ls_POHEADER-CURRENCY = 'SGD'.
ls_POHEADER-VAT_CNTRY = 'SG'.

APPEND ls_POHEADER TO ls_deep_entity-POHEADERSET.

ls_POITEM-GUID = '1'.
ls_POITEM-PO_ITEM = '0010'.
ls_POITEM-SHORT_TEXT = '2.AJ01, MARICH G-SPOT GSC35L LAMP SET'.
ls_POITEM-PLANT = 'PRMB'.
ls_POITEM-TRACKINGNO = 'PMBPO20082'.
ls_POITEM-MATL_GROUP = '1210260'.
ls_POITEM-QUANTITY = '16.00'.
ls_POITEM-PO_UNIT = 'LOT'.
ls_POITEM-NET_PRICE = '1500'.
ls_POITEM-PRICE_UNIT  = '1'.
ls_POITEM-ACCTASSCAT = 'A'.
ls_POITEM-TAX_CODE = 'P0'.

APPEND ls_POITEM TO ls_deep_entity-POITEMSET.

ls_POSCHEDULE-GUID = '1'.
ls_POSCHEDULE-PO_ITEM = '0010'.
ls_POSCHEDULE-DELIVERY_DATE = '20210916'.


APPEND ls_POSCHEDULE TO ls_deep_entity-ITEMSCHEDULESET.

ls_POACCOUNT-GUID = '1'.
ls_POACCOUNT-PO_ITEM = '0010'.
ls_POACCOUNT-GL_ACCOUNT = '0000394999'.
ls_POACCOUNT-ASSET_NO = '000000630015'.
ls_POACCOUNT-SUB_NUMBER = '0000'.
ls_POACCOUNT-ORDERID = '9130MIGRATED'.
ls_POACCOUNT-GR_RCPT = 'MR. GOH'.
ls_POACCOUNT-UNLOAD_PT = 'ENG'.
ls_POACCOUNT-CO_AREA = '1000'.
ls_POACCOUNT-PROFIT_CTR = '0003010920'.
ls_POACCOUNT-COSTCENTER = '9130010100001'.



APPEND ls_POACCOUNT TO ls_deep_entity-ITEMACCOUNTSET.

ls_POITEMTEXT-GUID = '1'.
ls_POITEMTEXT-PO_ITEM = '0010'.
ls_POITEMTEXT-TEXT_ID = 'F01'.
ls_POITEMTEXT-TEXT_LINE = 'REMOTE SHARED DALI (SPECTRUM DIMMABLE).'.

APPEND ls_POITEMTEXT TO ls_deep_entity-POTEXTITEMSET.


APPEND ls_deep_entity TO lt_deep_entity.

    CASE IV_ENTITY_SET_NAME.
      WHEN 'PORootSet'.


        ls_expanded_clause = 'POHeaderSet'.
        APPEND ls_expanded_clause TO ET_EXPANDED_TECH_CLAUSES.
        ls_expanded_clause = 'POItemSet'.
        APPEND ls_expanded_clause TO ET_EXPANDED_TECH_CLAUSES.
        ls_expanded_clause = 'ItemScheduleSet'.
        APPEND ls_expanded_clause TO ET_EXPANDED_TECH_CLAUSES.
        ls_expanded_clause = 'ItemAccountSet'.
        APPEND ls_expanded_clause TO ET_EXPANDED_TECH_CLAUSES.
        ls_expanded_clause = 'PotextitemSet'.
        APPEND ls_expanded_clause TO ET_EXPANDED_TECH_CLAUSES.

        COPY_DATA_TO_REF(
          EXPORTING
            IS_DATA = lt_deep_entity
          CHANGING
            CR_DATA = er_entityset
        ).

    ENDCASE.
  endmethod.


  method PO_CREATE_DEEP_ENITTY.

    DATA: lr_deep_entity TYPE ZCL_ZUOLPO_ODATA_MPC_EXT=>TS_DEEP,
          LS_POROOT TYPE ZCL_ZUOLPO_ODATA_MPC_EXT=>TS_POROOT,
          "LS_POHEADER     TYPE ZCL_ZUOLPO_ODATA_MPC_EXT=>TS_POHEADER,
          "LT_POHEADER         TYPE ZCL_ZUOLPO_ODATA_MPC_EXT=>TT_POHEADER,
          LS_POITEM     TYPE ZCL_ZUOLPO_ODATA_MPC_EXT=>TS_POITEM,
          LT_POITEM     TYPE ZCL_ZUOLPO_ODATA_MPC_EXT=>TT_POITEM,
          LS_ITEMACCOUNT    TYPE ZCL_ZUOLPO_ODATA_MPC_EXT=>TS_ITEMACCOUNT,
          LT_ITEMACCOUNT    TYPE ZCL_ZUOLPO_ODATA_MPC_EXT=>TT_ITEMACCOUNT,
          LS_ITEMSCHEDULE   TYPE ZCL_ZUOLPO_ODATA_MPC_EXT=>TS_ITEMSCHEDULE,
          LT_ITEMSCHEDULE   TYPE ZCL_ZUOLPO_ODATA_MPC_EXT=>TT_ITEMSCHEDULE,
          LS_POTEXTITEM   TYPE ZCL_ZUOLPO_ODATA_MPC_EXT=>TS_POTEXTITEM,
          LT_POTEXTITEM   TYPE ZCL_ZUOLPO_ODATA_MPC_EXT=>TT_POTEXTITEM.

    DATA: l_PONUMBER TYPE BAPIMEPOHEADER-PO_NUMBER.
    DATA: l_MESSAGE TYPE STRING.


    DATA: ls_BAPIPOHEADER TYPE BAPIMEPOHEADER,
          ls_BAPIPOHEADERX TYPE BAPIMEPOHEADERX.
    DATA: lt_BAPIPOITEM TYPE STANDARD TABLE OF BAPIMEPOITEM,
    ls_BAPIPOITEM LIKE LINE OF lt_BAPIPOITEM,
      lt_BAPIPOITEMX TYPE STANDARD TABLE OF BAPIMEPOITEMX,
    ls_BAPIPOITEMX LIKE LINE OF lt_BAPIPOITEMX,
       lt_BAPIPOSCHEDULE TYPE STANDARD TABLE OF BAPIMEPOSCHEDULE,
 	  ls_BAPIPOSCHEDULE LIKE LINE OF lt_BAPIPOSCHEDULE,
       lt_BAPIPOSCHEDULEX TYPE STANDARD TABLE OF BAPIMEPOSCHEDULX,
 	  ls_BAPIPOSCHEDULEX LIKE LINE OF lt_BAPIPOSCHEDULEX,
       lt_BAPIPOACCOUNT TYPE STANDARD TABLE OF BAPIMEPOACCOUNT,
 	  ls_BAPIPOACCOUNT LIKE LINE OF lt_BAPIPOACCOUNT,
       lt_BAPIPOACCOUNTX TYPE STANDARD TABLE OF BAPIMEPOACCOUNTX,
 	  ls_BAPIPOACCOUNTX LIKE LINE OF lt_BAPIPOACCOUNTX,
       lt_BAPIPOITEMTEXT TYPE STANDARD TABLE OF BAPIMEPOTEXT,
 	  ls_BAPIPOITEMTEXT LIKE LINE OF lt_BAPIPOITEMTEXT,
      lt_BAPIreturn TYPE STANDARD TABLE OF BAPIRET2.

   DATA: lt_errors TYPE STANDARD TABLE OF BAPIRET2.


FIELD-SYMBOLS: <FS_POHEADER> TYPE ZCL_ZUOLPO_ODATA_MPC_EXT=>TS_POHEADER.

DATA(lr_msg_cont) = /iwbep/cl_mgw_msg_container=>get_mgw_msg_container( ).

    io_data_provider->read_entry_data(
   	  IMPORTING
   	    es_data = lr_deep_entity ).



   MOVE-CORRESPONDING lr_deep_entity TO LS_POROOT.



   LT_POITEM = lr_deep_entity-POITEMSET.
   LT_ITEMACCOUNT = lr_deep_entity-ITEMACCOUNTSET.
   LT_ITEMSCHEDULE = lr_deep_entity-ITEMSCHEDULESET.
   LT_POTEXTITEM = lr_deep_entity-POTEXTITEMSET.


  ls_BAPIPOHEADERX-COMP_CODE = 'X'.
  ls_BAPIPOHEADERX-DOC_TYPE = 'X'.
  ls_BAPIPOHEADERX-VENDOR = 'X'.
  ls_BAPIPOHEADERX-PUR_GROUP = 'X'.
  ls_BAPIPOHEADERX-PURCH_ORG = 'X'.
  ls_BAPIPOHEADERX-CURRENCY = 'X'.


   LOOP AT lr_deep_entity-POHEADERSET ASSIGNING <FS_POHEADER> WHERE GUID = LS_POROOT-GUID .
     MOVE-CORRESPONDING <FS_POHEADER> TO LS_BAPIPOHEADER.

     SHIFT <FS_POHEADER>-PO_NUMBER LEFT DELETING LEADING '0'.

     CLEAR lt_BAPIPOITEMX.
     LOOP AT LT_POITEM INTO LS_POITEM WHERE GUID = LS_POROOT-GUID AND PO_NUMBER = <FS_POHEADER>-PO_NUMBER.
       MOVE-CORRESPONDING LS_POITEM TO ls_BAPIPOITEM.
       APPEND ls_BAPIPOITEM TO lt_BAPIPOITEM.

        ls_BAPIPOITEMX-PO_ITEM = ls_POITEM-PO_ITEM.
        ls_BAPIPOITEMX-PO_ITEMX = 'X'.
        ls_BAPIPOITEMX-SHORT_TEXT = 'X'.
        ls_BAPIPOITEMX-PLANT = 'X'.
        ls_BAPIPOITEMX-TRACKINGNO = 'X'.
        ls_BAPIPOITEMX-MATL_GROUP = 'X'.
        ls_BAPIPOITEMX-QUANTITY = 'X'.
        ls_BAPIPOITEMX-PO_UNIT = 'X'.
        ls_BAPIPOITEMX-NET_PRICE = 'X'.
        ls_BAPIPOITEMX-PRICE_UNIT  = 'X'.
        ls_BAPIPOITEMX-ACCTASSCAT = 'X'.
        ls_BAPIPOITEMX-TAX_CODE = 'X'.

        APPEND ls_BAPIPOITEMX TO lt_BAPIPOITEMX.
     ENDLOOP.

    CLEAR lt_BAPIPOACCOUNTX.

    LOOP AT LT_ITEMACCOUNT INTO LS_ITEMACCOUNT WHERE GUID = LS_POROOT-GUID AND PO_NUMBER = <FS_POHEADER>-PO_NUMBER.
       MOVE-CORRESPONDING LS_ITEMACCOUNT TO ls_BAPIPOACCOUNT.
       APPEND ls_BAPIPOACCOUNT TO lt_BAPIPOACCOUNT.

      ls_BAPIPOACCOUNTX-PO_ITEM = LS_ITEMACCOUNT-PO_ITEM.
      ls_BAPIPOACCOUNTX-PO_ITEMX = 'X'.
      ls_BAPIPOACCOUNTX-GL_ACCOUNT = 'X'.
      ls_BAPIPOACCOUNTX-ASSET_NO = 'X'.
      ls_BAPIPOACCOUNTX-SUB_NUMBER = 'X'.
      ls_BAPIPOACCOUNTX-ORDERID = 'X'.
      ls_BAPIPOACCOUNTX-GR_RCPT = 'X'.
      ls_BAPIPOACCOUNTX-UNLOAD_PT = 'X'.
      ls_BAPIPOACCOUNTX-CO_AREA = 'X'.
      ls_BAPIPOACCOUNTX-COSTCENTER = 'X'.

      APPEND ls_BAPIPOACCOUNTX TO lt_BAPIPOACCOUNTX.
     ENDLOOP.

     CLEAR lt_BAPIPOSCHEDULEX.
     LOOP AT LT_ITEMSCHEDULE INTO LS_ITEMSCHEDULE WHERE GUID = LS_POROOT-GUID AND PO_NUMBER = <FS_POHEADER>-PO_NUMBER.
         MOVE-CORRESPONDING LS_ITEMSCHEDULE TO ls_BAPIPOSCHEDULE.
         APPEND ls_BAPIPOSCHEDULE TO lt_BAPIPOSCHEDULE.

          ls_BAPIPOSCHEDULEX-PO_ITEM = LS_ITEMSCHEDULE-PO_ITEM.
          ls_BAPIPOSCHEDULEX-PO_ITEMX = 'X'.
          ls_BAPIPOSCHEDULEX-DELIVERY_DATE = 'X'.
          APPEND ls_BAPIPOSCHEDULEX TO lt_BAPIPOSCHEDULEX.
     ENDLOOP.

    CLEAR lt_BAPIPOITEMTEXT.
    LOOP AT LT_POTEXTITEM INTO LS_POTEXTITEM WHERE GUID = LS_POROOT-GUID AND PO_NUMBER = <FS_POHEADER>-PO_NUMBER.
       MOVE-CORRESPONDING LS_POTEXTITEM TO ls_BAPIPOITEMTEXT.
       APPEND ls_BAPIPOITEMTEXT TO lt_BAPIPOITEMTEXT.
     ENDLOOP.

    CLEAR lt_bapireturn.

    CALL FUNCTION 'BAPI_PO_CREATE1'
      EXPORTING
        POHEADER                     = ls_BAPIPOHEADER
        POHEADERX                    = ls_BAPIPOHEADERX
*       POADDRVENDOR                 =
        TESTRUN                      = 'X'
*       MEMORY_UNCOMPLETE            =
*       MEMORY_COMPLETE              =
*       POEXPIMPHEADER               =
*       POEXPIMPHEADERX              =
*       VERSIONS                     =
*       NO_MESSAGING                 =
*       NO_MESSAGE_REQ               =
*       NO_AUTHORITY                 =
*       NO_PRICE_FROM_PO             =
*       PARK_COMPLETE                =
*       PARK_UNCOMPLETE              =
     IMPORTING
       EXPPURCHASEORDER             = l_PONUMBER
*       EXPHEADER                    =
*       EXPPOEXPIMPHEADER            =
     TABLES
       RETURN                       = lt_bapireturn
       POITEM                       = lt_bapipoitem
       POITEMX                      = lt_bapipoitemx
*       POADDRDELIVERY               =
       POSCHEDULE                   = lt_BAPIPOSCHEDULE
       POSCHEDULEX                  = lt_BAPIPOSCHEDULEX
       POACCOUNT                    = lt_BAPIPOACCOUNT
*       POACCOUNTPROFITSEGMENT       =
       POACCOUNTX                   = lt_BAPIPOACCOUNTX
*       POCONDHEADER                 =
*       POCONDHEADERX                =
*       POCOND                       =
*       POCONDX                      =
*       POLIMITS                     =
*       POCONTRACTLIMITS             =
*       POSERVICES                   =
*       POSRVACCESSVALUES            =
*       POSERVICESTEXT               =
*       EXTENSIONIN                  =
*       EXTENSIONOUT                 =
*       POEXPIMPITEM                 =
*       POEXPIMPITEMX                =
*       POTEXTHEADER                 =
        POTEXTITEM                   = lt_BAPIPOITEMTEXT
*       ALLVERSIONS                  =
*       POPARTNER                    =
*       POCOMPONENTS                 =
*       POCOMPONENTSX                =
*       POSHIPPING                   =
*       POSHIPPINGX                  =
*       POSHIPPINGEXP                =
*       SERIALNUMBER                 =
*       SERIALNUMBERX                =
*       INVPLANHEADER                =
*       INVPLANHEADERX               =
*       INVPLANITEM                  =
*       INVPLANITEMX                 =
*       NFMETALLITMS                 =
              .
      IF sy-subrc eq 0.
        COMMIT WORK AND WAIT.
      ELSE.
        ROLLBACK WORK.
      ENDIF.



      CLEAR l_MESSAGE.

      <FS_POHEADER>-TRXSTATUS = 'S'.


      LOOP AT lt_bapireturn ASSIGNING FIELD-SYMBOL(<fs_return>) WHERE type = 'E'.
        CONCATENATE <FS_RETURN>-MESSAGE cl_abap_char_utilities=>cr_lf l_MESSAGE INTO l_MESSAGE.
        <FS_POHEADER>-TRXSTATUS = 'E'.
      ENDLOOP.

*      LOOP AT lt_bapireturn ASSIGNING FIELD-SYMBOL(<fs_return>) WHERE type = 'E'.
*       APPEND <fs_return> TO lt_errors.
*      ENDLOOP.

*      IF lt_errors IS NOT INITIAL.
*
*           lr_msg_cont->add_messages_from_bapi(
*             EXPORTING
*               it_bapi_messages          = lt_errors    " Return parameter table
*               IV_ADD_TO_RESPONSE_HEADER = abap_true
*           ).
*
*           <FS_POHEADER>-TRXSTATUS = 'E'.
*           <FS_POHEADER>-TRXMSG = <fs_return>-MESSAGE.
*      ELSE.
*           <FS_POHEADER>-TRXSTATUS = 'S'.
*           CONCATENATE 'Generated PO Number: ' L_PONUMBER INTO <FS_POHEADER>-TRXMSG.
*      ENDIF.

      IF <FS_POHEADER>-TRXSTATUS = 'E'.
         <FS_POHEADER>-TRXMSG = l_MESSAGE.
      ELSE.
         CONCATENATE 'Generated PO Number: ' L_PONUMBER INTO <FS_POHEADER>-TRXMSG.
      ENDIF.
      <FS_POHEADER>-PO_NUMBER = L_PONUMBER.

   ENDLOOP."POHEADER


   IF <FS_POHEADER> IS NOT ASSIGNED.
      CALL METHOD lr_msg_cont->add_message_text_only
        EXPORTING
          iv_msg_type               =  'E'
          iv_msg_text               =  'Incorrect Data Package Were Submitted. PO Creation Was Insuccessful...'
          .
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message_container = lr_msg_cont.
   ENDIF.

   er_deep_entity = lr_deep_entity.

  endmethod.
ENDCLASS.
