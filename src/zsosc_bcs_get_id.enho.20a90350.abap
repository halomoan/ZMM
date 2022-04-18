"Name: \TY:CL_SAPUSER_BCS\ME:GET_SAPUSER\SE:END\EI
ENHANCEMENT 0 ZSOSC_BCS_GET_ID.
"get the ID from function module SO_RECIPIENTS_FOR_SEND_GET enhancement ZSOSC_BCS.
data lv_id type sy-uname.
CALL FUNCTION 'ZFM_GET_USER_ID_DONOTREPLY'
 IMPORTING
   EX_UNAME       = lv_id.
if lv_id is not INITIAL.
   result =  lv_id.
endif.

ENDENHANCEMENT.
