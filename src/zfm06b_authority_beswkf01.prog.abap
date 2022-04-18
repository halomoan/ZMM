*----------------------------------------------------------------------*
***INCLUDE FM06B_AUTHORITY_BESWKF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  authority_beswk
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_EBAN  text
*      -->P_LS_EBAN_OLD  text
*----------------------------------------------------------------------*
FORM authority_beswk USING value(is_eban_new) TYPE eban
                           value(is_eban_old) TYPE eban.

  DATA: lf_ccp_active TYPE c,
        lf_auth       LIKE sy-subrc.

  CALL FUNCTION 'ME_CCP_ACTIVE_CHECK'
    IMPORTING
      ef_ccp_active = lf_ccp_active.
  CHECK NOT lf_ccp_active IS INITIAL.

  CHECK NOT ( is_eban_new-beswk IS INITIAL AND
              is_eban_old-beswk IS INITIAL ).

  IF is_eban_old-beswk IS INITIAL.         " new proc. plant

    CALL FUNCTION 'ME_CPP_AUTH_CHECK_BESWK'
      EXPORTING
        if_plant    = is_eban_new-beswk
        if_activity = '01'
      IMPORTING
        ef_auth     = lf_auth.
    IF NOT lf_auth IS INITIAL.
*    AUTHORITY-CHECK OBJECT 'M_BANF_BWK'
*          ID 'ACTVT' FIELD '01'
*          ID 'WERKS' FIELD is_eban_new-beswk.
*    IF sy-subrc NE 0.
      MESSAGE e208(mepo) WITH is_eban_new-beswk text-c01.
    ENDIF.
  ELSEIF is_eban_new-beswk IS INITIAL.   "delete proc plant

    CALL FUNCTION 'ME_CPP_AUTH_CHECK_BESWK'
      EXPORTING
        if_plant    = is_eban_old-beswk
        if_activity = '06'
      IMPORTING
        ef_auth     = lf_auth.
    IF NOT lf_auth IS INITIAL.
*    AUTHORITY-CHECK OBJECT 'M_BANF_BWK'
*          ID 'ACTVT' FIELD '06'
*          ID 'WERKS' FIELD is_eban_old-beswk.
*    IF sy-subrc NE 0.
      MESSAGE e208(mepo) WITH is_eban_old-beswk text-c06.
    ENDIF.

  ELSEIF is_eban_old-beswk NE eban-beswk.  "change

    CALL FUNCTION 'ME_CPP_AUTH_CHECK_BESWK'
      EXPORTING
        if_plant    = is_eban_new-beswk
        if_activity = '02'
      IMPORTING
        ef_auth     = lf_auth.
    IF NOT lf_auth IS INITIAL.
*    AUTHORITY-CHECK OBJECT 'M_BANF_BWK'
*          ID 'ACTVT' FIELD '02'
*          ID 'WERKS' FIELD is_eban_new-beswk.
*    IF sy-subrc NE 0.
      MESSAGE e208(mepo) WITH is_eban_new-beswk text-c02.
    ENDIF.
  ELSEIF is_eban_old-beswk EQ is_eban_new-beswk AND
    ( is_eban_new-flief NE is_eban_old-flief  OR
      is_eban_new-ekorg NE is_eban_old-ekorg  OR
      is_eban_new-infnr NE is_eban_old-infnr  OR
      is_eban_new-konnr NE is_eban_old-konnr  OR
      is_eban_new-ktpnr NE is_eban_old-ktpnr  OR
      is_eban_new-reswk NE is_eban_old-reswk ).

    CALL FUNCTION 'ME_CPP_AUTH_CHECK_BESWK'
      EXPORTING
        if_plant    = is_eban_new-beswk
        if_activity = '22'
      IMPORTING
        ef_auth     = lf_auth.
    IF NOT lf_auth IS INITIAL.
*    AUTHORITY-CHECK OBJECT 'M_BANF_BWK'
*          ID 'ACTVT' FIELD '22'
*          ID 'WERKS' FIELD is_eban_new-beswk.
*    IF sy-subrc NE 0.
      MESSAGE e207(mepo) WITH is_eban_new-beswk.
    ENDIF.
  ENDIF.


ENDFORM.                    " authority_beswk
