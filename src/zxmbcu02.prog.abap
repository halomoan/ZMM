*&---------------------------------------------------------------------*
*&  Include           ZXMBCU02
*&---------------------------------------------------------------------*
IF sy-tcode+0(4) = 'MIGO'.
  e_sgtxt = i_mseg-sgtxt.
ELSE.
  IF e_sgtxt IS INITIAL.
    SELECT SINGLE maktx INTO e_sgtxt FROM makt WHERE matnr = i_mseg-matnr
                                                 AND spras = sy-langu.
  ELSE.
    e_sgtxt = i_mseg-sgtxt.
  ENDIF.
ENDIF.
