"Name: \PR:SAPMM06E\EX:MM06EO0M_MODIFY_SCREEN_01\EI
ENHANCEMENT 0 ZEN_MM06EO0M_RFQ.

*&---------------------------------------------------------------------*
* Enhancement for Upload RFQ (Program ZMMC_RFQ)
*&---------------------------------------------------------------------*
*& Author : Denny Ivan (Deloitte)
*& Date : 27/09/2016
*&---------------------------------------------------------------------*
  DATA lv_bdc.
  IF screen-name = 'EKKO-SUBMI' or
     screen-name = 'EKKO-KDATB' or
     screen-name = 'EKKO-KDATE'.
    IMPORT lv_bdc FROM MEMORY ID 'UPLOADRFQ'.
    IF sy-subrc = 0 AND lv_bdc = 'X'.
*      break zdevams.
      screen-required = '0'.
    ENDIF.
  ENDIF.

ENDENHANCEMENT.
