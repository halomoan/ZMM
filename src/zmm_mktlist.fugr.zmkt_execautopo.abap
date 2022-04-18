FUNCTION ZMKT_EXECAUTOPO.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(WERKS) TYPE  WERKS_D
*"     VALUE(BANFN) TYPE  BANFN
*"  EXPORTING
*"     VALUE(E_MESSAGE) TYPE  CHAR255
*"----------------------------------------------------------------------
DATA:
    preq_no LIKE BAPIMEREQHEADER-PREQ_NO,
    DPRITEM LIKE TABLE OF bapimereqitem WITH HEADER LINE,
    prheader TYPE bapimereqheader,
    prheaderx TYPE bapimereqheaderx,
    return LIKE TABLE OF bapiret2 WITH HEADER LINE,
    pritem LIKE TABLE OF bapimereqitemimp WITH HEADER LINE,
    pritemx LIKE TABLE OF bapimereqitemx WITH HEADER LINE,
    praccount LIKE TABLE OF BAPIMEREQACCOUNT WITH HEADER LINE,
    praccountx LIKE TABLE OF bapimereqaccountx WITH HEADER LINE.

DATA: l_MESSAGE TYPE STRING,
      l_ERROR TYPE C LENGTH 1,
      r_autopo TYPE RANGE OF char4,
      l_EBELN TYPE BSTNR.

SELECT SIGN OPTI LOW HIGH INTO TABLE r_autopo FROM tvarvc
  WHERE NAME = 'ZMARKETLIST_AUTOPO'
  AND TYPE = 'S'.


IF WERKS NOT IN r_autopo.
  E_MESSAGE = '(Auto) Create PO is not allowed for this Plant.'.
  EXIT.
ENDIF.

preq_no = BANFN.
CONDENSE preq_no.

IF PREQ_NO IS INITIAL.
  E_MESSAGE = 'Error: Purchase Requisition doesn''t exist.'.
  EXIT.
ENDIF.

SELECT SINGLE EBELN INTO l_EBELN FROM EBAN WHERE BANFN = preq_no AND EBELN <> ''.
IF sy-subrc = 0.
  E_MESSAGE = 'Error: Purchase Order had been created for this order. Recreate PO is not allowed.'.
  EXIT.
ENDIF.

CALL FUNCTION 'BAPI_PR_GETDETAIL'
  EXPORTING
   NUMBER                      = preq_no
   ACCOUNT_ASSIGNMENT          = ' '

  IMPORTING
    PRHEADER                   = PRHEADER
 TABLES
   RETURN                      = RETURN
   PRITEM                      = DPRITEM

 EXCEPTIONS
   OTHERS                      = 1.

IF sy-subrc eq 0.

  IF DPRITEM[] IS INITIAL.
    E_MESSAGE = 'Warning! There is no materials in the Purchase Requisition'.
    EXIT.
  ENDIF.

MOVE-CORRESPONDING DPRITEM[] TO PRITEM[].

 LOOP AT PRITEM.
   pritemx-PREQ_ITEM = pritem-PREQ_ITEM.
   pritem-trackingno = 'AUTO'.
   pritemx-trackingno = 'X'.
   MODIFY PRITEM FROM PRITEM.
   APPEND pritemx.
 ENDLOOP.



 CALL FUNCTION 'BAPI_PR_CHANGE'
                  EXPORTING
                    NUMBER                       = preq_no
                    "PRHEADER                     = PRHEADER
                    "PRHEADERX                    = PRHEADERX
                    TESTRUN                      = ' '
                  TABLES
                    RETURN                       = RETURN
                    PRITEM                       = PRITEM
                    PRITEMX                      = PRITEMX.
                    "PRACCOUNT                    = PRACCOUNT
                    "PRACCOUNTX                   = PRACCOUNTX.


CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
  EXPORTING
  wait = 'X'.

ELSE.

  E_MESSAGE = 'Error: There is problem to access the Purchase Requisition. (Lock?)'.

ENDIF.

LOOP AT RETURN WHERE type = 'E' OR type = 'A'.

     E_MESSAGE = 'Error: '.



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
                     msg       = l_MESSAGE
                   EXCEPTIONS
                     not_found = 1
                     OTHERS    = 2.

     CONCATENATE E_MESSAGE CL_ABAP_CHAR_UTILITIES=>CR_LF l_MESSAGE INTO E_MESSAGE.

     l_ERROR = 'X'.

ENDLOOP.


IF l_ERROR ne 'X'.
  CALL FUNCTION 'BP_EVENT_RAISE'
    EXPORTING
      eventid                     = 'ZMARKETLIST_AUTOPORUN'
      EVENTPARM                   = WERKS
   EXCEPTIONS
     BAD_EVENTID                  = 1
     EVENTID_DOES_NOT_EXIST       = 2
     EVENTID_MISSING              = 3
     RAISE_FAILED                 = 4
     OTHERS                       = 5
            .
  IF sy-subrc <> 0.
   E_MESSAGE = 'Event failed to trigger'.
  else.
   E_MESSAGE = 'Event triggered'.
  ENDIF.
ENDIF.

ENDFUNCTION.
