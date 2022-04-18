*eject
*----------------------------------------------------------------------*
* Materialstamm mit View MA61V lesen - Prefetch durchführen
*----------------------------------------------------------------------*
FORM BAN_DATEN_PR2_001.

READ TABLE XPRE01 INDEX 1.
IF SY-SUBRC EQ 0.
   CALL FUNCTION 'MATERIAL_PRE_READ_MA61V'
        EXPORTING
             KZRFB = 'X'
        TABLES
             MA61V_KEYTAB = XPRE01.
ENDIF.

ENDFORM.
