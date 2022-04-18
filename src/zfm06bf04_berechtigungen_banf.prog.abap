*eject
*----------------------------------------------------------------------*
* Berechtigungen prüfen Banf                                           *
*----------------------------------------------------------------------*
FORM berechtigungen_banf USING beb_ekorg beb_ekgrp beb_werks beb_bsart.

*- Belegart -----------------------------------------------------------*
  AUTHORITY-CHECK OBJECT 'M_BANF_BSA'
       ID 'ACTVT' FIELD '02'
       ID 'BSART' FIELD beb_bsart.
  IF sy-subrc NE 0.
    xauth = 'X'.
    EXIT.
  ENDIF.

*- Einkaufsorganisation -----------------------------------------------*
  PERFORM berechtigungen_banf_ekorg USING beb_ekorg.
  IF sy-subrc NE 0.
    EXIT.
  ENDIF.

*- Einkäufergruppe ----------------------------------------------------*
  IF beb_ekgrp NE space.
    AUTHORITY-CHECK OBJECT 'M_BANF_EKG'
         ID 'ACTVT' FIELD '02'
         ID 'EKGRP' FIELD beb_ekgrp.
    IF sy-subrc NE 0.
      xauth = 'X'.
      EXIT.
    ENDIF.
  ENDIF.

*- WERK ---------------------------------------------------------------*
  IF beb_werks NE space.
    AUTHORITY-CHECK OBJECT 'M_BANF_WRK'
         ID 'ACTVT' FIELD '02'
         ID 'WERKS' FIELD beb_werks.
    IF sy-subrc NE 0.
      xauth = 'X'.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM berechtigungen_banf_ekorg                                *
*---------------------------------------------------------------------*
FORM berechtigungen_banf_ekorg USING im_ekorg LIKE eban-ekorg.

  IF im_ekorg NE space.
    AUTHORITY-CHECK OBJECT 'M_BANF_EKO'
         ID 'ACTVT' FIELD '02'
         ID 'EKORG' FIELD im_ekorg.
    IF sy-subrc NE 0.
      xauth = 'X'.
    ENDIF.
  ENDIF.

ENDFORM.
