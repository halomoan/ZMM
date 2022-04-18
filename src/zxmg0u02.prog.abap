*&---------------------------------------------------------------------*
*&  Include           ZXMG0U02
*&---------------------------------------------------------------------*

DATA lv_t023_bklas TYPE t023-bklas.

*IF sy-tcode EQ 'MM01' AND wmbew-bklas IS INITIAL.
*  "Skip
*ELSE.
*CHECK wmbew-bklas IS NOT INITIAL.
CHECK wmbew IS NOT INITIAL.
SELECT SINGLE bklas FROM t023 INTO lv_t023_bklas
  WHERE matkl = wmara-matkl.
IF sy-subrc EQ 0.
  IF wmbew-bklas NE lv_t023_bklas.
    MESSAGE w398(00) WITH 'Invalid valuation class' wmbew-bklas space.
    RAISE application_error.
  ENDIF.
ENDIF.
*ENDIF.
