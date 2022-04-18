*EJECT
*----------------------------------------------------------------------*
*        Generieren Anfragen                                           *
*----------------------------------------------------------------------*
FORM generieren_anfrage.

  PERFORM pruefen_freigabe_anf.
  READ TABLE bat INDEX 1.                                   "92334
  rm06e-anfdt = sy-datlo.
  ekko-ekgrp = bat-ekgrp.
  ekko-ekorg = bat-ekorg.
  IF ekko-ekorg EQ space.
    GET PARAMETER ID 'EKO' FIELD ekko-ekorg.
  ENDIF.
  SELECT SINGLE * FROM t160 WHERE tcode EQ 'ME41'.
  rm06e-asart = t160-bsart.
  IF ekko-lifnr NE space.                                   "70908
    SELECT SINGLE spras INTO rm06e-spras FROM lfa1          "70908
         WHERE lifnr = ekko-lifnr.                          "70908
  ELSE.                                                     "70908
    rm06e-spras = sy-langu.
  ENDIF.                                                    "70908
  ekko-bstyp = 'A'.
  CLEAR reject.
  CALL SCREEN 101 STARTING AT 9  9
                  ENDING   AT 43 17.
  CHECK reject EQ space.
  CLEAR call_updkz.
  CLEAR batu.
  REFRESH batu.
  auto = 'X'.

  IF 1 = 1.

    DATA: lt_eban TYPE mereq_t_eban_mem,
          ls_eban LIKE LINE OF lt_eban,
          lt_eban_upd TYPE mereq_t_eban_mem,
          ls_eban_upd LIKE LINE OF lt_eban_upd.

    LOOP AT bat.
      MOVE-CORRESPONDING bat TO ls_eban.
      APPEND ls_eban TO lt_eban.
    ENDLOOP.
    ekko-bedat = rm06e-anfdt.
    ekko-ebeln = rm06e-anfnr.
    ekko-bsart = rm06e-asart.
    ekko-spras = rm06e-spras.
    ekko-bstyp = 'A'.

    CALL FUNCTION 'ME_PROCESS_REQUISITIONS'  "#EC CI_USAGE_OK[2438110] P30K909996
      EXPORTING
        i_ekko                          = ekko
        i_auto                          = auto
        i_enqueue                       = ' '
        i_requisitions                  = lt_eban
*  i_requisition_accountings       =
      IMPORTING
        e_requisitions                  = lt_eban_upd
        e_updkz                         = call_updkz
      EXCEPTIONS
        no_authority                    = 1
        invalid_call                    = 2
        OTHERS                          = 3.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CLEAR: batu, batu[].
    LOOP AT lt_eban_upd INTO ls_eban_upd where updkz ne space.
      MOVE-CORRESPONDING ls_eban_upd TO batu.
      APPEND batu.
    ENDLOOP.

  ELSE.

*-- Bereitstellen der erforderlichen Daten im Memory ------------------*
    SORT bat BY banfn bnfpo.
    EXPORT bat rm06e-asart rm06e-anfdt rm06e-anfnr rm06e-spras "#EC CI_FLDEXT_OK[2215424] P30K909996
           ekko-lifnr ekko-ekorg ekko-ekgrp ekko-angdt auto call_updkz
    TO MEMORY ID 'BAT'.

*-- Aufruf ME41 - hier per 'CALL TRANSACTION' wegen COMMIT ------------
*CALL TRANSACTION 'ME41' AND SKIP FIRST SCREEN.                  "82801
    CALL TRANSACTION 'ME41'.                                "82801

*-- Holen der erforderlichen Daten aus dem Memory ---------------------
    IMPORT batu call_updkz FROM MEMORY ID 'BATU'. "#EC CI_FLDEXT_OK[2215424] P30K909996

*-- Anfrage nicht gebucht - keine Fortschreibung der Banfs ------------*
    IF call_updkz EQ space.
      REFRESH batu.
      CLEAR batu.
    ENDIF.
  ENDIF.

  PERFORM ban_update USING 'A'.
  PERFORM zug_modif_zeile USING text-119.

ENDFORM.
