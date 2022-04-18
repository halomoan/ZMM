FUNCTION ZFM_GET_USER_ID_DONOTREPLY.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     REFERENCE(EX_UNAME) TYPE  UNAME
*"----------------------------------------------------------------------
   if gv_uname is not INITIAL.
   ex_uname = gv_uname .
   clear  gv_uname.
   endif.

ENDFUNCTION.
