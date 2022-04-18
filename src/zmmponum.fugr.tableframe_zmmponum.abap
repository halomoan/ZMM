*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZMMPONUM
*   generation date: 28.09.2010 at 11:51:38 by user SURJSINGH
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZMMPONUM           .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
