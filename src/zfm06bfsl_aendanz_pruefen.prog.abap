*eject
*----------------------------------------------------------------------*
*        Berechtigung Anzeigen Änderungen prüfen                       *
*----------------------------------------------------------------------*
FORM aendanz_pruefen.
* define local data object
  DATA: lo_auth       TYPE REF TO cl_auth_buf_mm,           "1364838
        lf_ccp_active TYPE c.
  aendanz = 'X'.

  lo_auth = cl_auth_buf_mm=>get_instance( ).                "1364838
*- Belegart -----------------------------------------------------------*
  IF lo_auth->execute( im_object = mmpur_auth_banf_bsa
                       im_actvt  = '08'
                       im_id1    = mmpur_bsart
                       im_val1   = eban-bsart ) NE 0.
    CLEAR aendanz.
    EXIT.
  ENDIF.

*- Einkaufsorganisation -----------------------------------------------*
  IF eban-ekorg NE space.
    IF lo_auth->execute( im_object = mmpur_auth_banf_eko    "1364838
                         im_actvt  = '08'
                         im_id1    = mmpur_ekorg
                         im_val1   = eban-ekorg ) NE 0.
      CLEAR aendanz.
      EXIT.
    ENDIF.
  ENDIF.

*- Einkäufergruppe ----------------------------------------------------*
  IF eban-ekgrp NE space.
    IF lo_auth->execute( im_object = mmpur_auth_banf_ekg    "1364838
                         im_actvt  = '08'
                         im_id1    = mmpur_ekgrp
                         im_val1   = eban-ekgrp ) NE 0.
      CLEAR aendanz.
      EXIT.
    ENDIF.
  ENDIF.

*- WERK ---------------------------------------------------------------*
  IF eban-werks NE space.
    IF lo_auth->execute( im_object = mmpur_auth_banf_wrk    "1364838
                         im_actvt  = '08'
                         im_id1    = 'WERKS'
                         im_val1   = eban-werks ) NE 0.
      CLEAR aendanz.
      EXIT.
    ENDIF.
  ENDIF.

* Begin CCP
  DATA: lf_auth LIKE sy-subrc.
*- Beschaffendes Werk -------------------------------------------------*
  IF NOT eban-beswk IS INITIAL.

    CALL FUNCTION 'ME_CPP_AUTH_CHECK_BESWK'
      EXPORTING
        if_plant    = eban-beswk
        if_activity = '08'
      IMPORTING
        ef_auth     = lf_auth.
    IF NOT lf_auth IS INITIAL.
      CLEAR aendanz.
      EXIT.
    ENDIF.
  ENDIF.
* End CCP

ENDFORM.                    "AENDANZ_PRUEFEN
