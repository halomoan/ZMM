*EJECT
*----------------------------------------------------------------------*
*        Generieren Umlagerungsbestellungen                            *
*----------------------------------------------------------------------*
FORM generieren_umlagbestellung.

  PERFORM pruefen_freigabe_best.
  PERFORM pruefen_estkz.               "92105/4.0C
  SELECT SINGLE * FROM t160 WHERE tcode EQ 'ME27'.
  READ TABLE bat INDEX 1.                                   "92334
  rm06e-bedat = sy-datlo.
  ekko-ekgrp = bat-ekgrp.
  ekko-ekorg = bat-ekorg.
  rm06e-bsart = t160-bsart.
  ekko-bstyp = 'F'.
  CLEAR reject.
  CALL SCREEN 100 STARTING AT 9  9
                  ENDING   AT 43 15.
  CHECK reject EQ space.

  auto = 'X'.

  CLEAR call_updkz.
  CLEAR batu.
  REFRESH batu.

  IF 1 = 1.

    DATA: lt_eban TYPE mereq_t_eban_mem,
          ls_eban LIKE LINE OF lt_eban,
          lt_eban_upd TYPE mereq_t_eban_mem,
          ls_eban_upd LIKE LINE OF lt_eban_upd.

    LOOP AT bat.
      MOVE-CORRESPONDING bat TO ls_eban.
      APPEND ls_eban TO lt_eban.
    ENDLOOP.
    ekko-bedat = rm06e-bedat.
    ekko-ebeln = rm06e-bstnr.
    ekko-bsart = rm06e-bsart.
    ekko-bstyp = 'F'.
    ekko-bsakz = 'T'.

    CALL FUNCTION 'ME_PROCESS_REQUISITIONS'
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

* ab 3.0D über CALL TRANSACTION
    SORT bat BY banfn bnfpo.
    EXPORT bat rm06e-bedat rm06e-bstnr rm06e-bsart  "#EC CI_FLDEXT_OK[2215424] P30K909996
           ekko-ekgrp ekko-ekorg auto call_updkz TO MEMORY ID 'BAT'.
    CALL TRANSACTION 'ME27' AND SKIP FIRST SCREEN. "#EC CI_USAGE_OK[144081] P30K909996
    IMPORT batu call_updkz FROM MEMORY ID 'BATU'. "#EC CI_FLDEXT_OK[2215424] P30K909996
    IF call_updkz EQ space.
      REFRESH batu.
      CLEAR batu.
    ENDIF.
  ENDIF.

  PERFORM ban_update USING 'E'.
  PERFORM oba_update_best.
  PERFORM zug_modif_zeile USING text-116.

ENDFORM.
