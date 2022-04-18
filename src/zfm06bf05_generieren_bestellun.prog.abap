*EJECT
*----------------------------------------------------------------------*
*        Generieren Bestellungen und Kontraktabrufe                    *
*----------------------------------------------------------------------*
FORM generieren_bestellung.

  PERFORM pruefen_freigabe_best.
  PERFORM pruefen_estkz.                                    "92105/4.0C
  READ TABLE bat INDEX 1.                                   "92334
  rm06e-bedat = sy-datlo.
  ekko-ekgrp = bat-ekgrp.
  ekko-ekorg = bat-ekorg.
  SELECT SINGLE * FROM t160 WHERE tcode EQ sy-tcode.        "125969
  IF sy-subrc EQ 0 AND NOT t160-bsart IS INITIAL.           "125969
    rm06e-bsart = t160-bsart.                               "125969
  ELSE.                                                     "125969
    SELECT SINGLE * FROM t160 WHERE tcode EQ 'ME21N'.       "740981
    IF sy-subrc EQ 0 AND NOT t160-bsart IS INITIAL.
      rm06e-bsart = t160-bsart.
    ELSE.
      SELECT SINGLE * FROM t160 WHERE tcode EQ 'ME21'.      "125969
    IF sy-subrc EQ 0 AND NOT t160-bsart IS INITIAL.         "125969
      rm06e-bsart = t160-bsart.                             "125969
    ELSE.                                                   "125969
      rm06e-bsart = bat-bsart.                              "125969
    ENDIF.                                                  "125969
    ENDIF.                                                  "740981
  ENDIF.                                                    "125969
  ekko-bstyp = 'F'.
*ENHANCEMENT-POINT FM06BF05_GENERIEREN_BESTELL_01 SPOTS ES_SAPFM06B.
  CLEAR reject.
  CALL SCREEN 100 STARTING AT 9  9
                  ENDING   AT 43 15.
  CHECK reject EQ space.

  auto = 'X'.

  CLEAR call_updkz.
  CLEAR batu.
  REFRESH batu.

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

  CALL FUNCTION 'ME_PROCESS_REQUISITIONS' "#EC CI_USAGE_OK[2438110] P30K909996
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
  LOOP AT lt_eban_upd INTO ls_eban_upd WHERE updkz NE space.
    MOVE-CORRESPONDING ls_eban_upd TO batu.
    APPEND batu.
  ENDLOOP.

  PERFORM ban_update USING 'E'.
  PERFORM oba_update_best.
  PERFORM zug_modif_zeile USING text-116.

ENDFORM.                    "generieren_bestellung
