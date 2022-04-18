*eject
*----------------------------------------------------------------------*
*  Vorschlagen Listumfang                                             *
*----------------------------------------------------------------------*
FORM vorschlagen_lstub USING vol_lstub.

  SELECT SINGLE * FROM t16lh WHERE tcode EQ sy-tcode.
  IF sy-subrc EQ 0.
    vol_lstub = t16lh-lstub.
  ENDIF.
*-- Note 739690
  REFRESH t_excluded.
*-- Note 739690
ENDFORM.                    "VORSCHLAGEN_LSTUB
