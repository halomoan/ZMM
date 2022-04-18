*EJECT
*----------------------------------------------------------------------*
*        Generieren Lieferplaneinteilungen                             *
*----------------------------------------------------------------------*
FORM generieren_einteilung.

  PERFORM pruefen_freigabe_best.
  PERFORM pruefen_estkz.               "92105/4.0C
  auto = 'X'.
  CLEAR call_updkz.
  CLEAR batu.
  REFRESH batu.
  SET PARAMETER ID 'BSP' FIELD '00000'.

  IF 1 = 1.

    DATA: lt_eban TYPE mereq_t_eban_mem,
          ls_eban LIKE LINE OF lt_eban,
          lt_eban_upd TYPE mereq_t_eban_mem,
          ls_eban_upd LIKE LINE OF lt_eban_upd.

    LOOP AT bat.
      MOVE-CORRESPONDING bat TO ls_eban.
      APPEND ls_eban TO lt_eban.
    ENDLOOP.
    ekko-bstyp = 'L'.

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
    LOOP AT lt_eban_upd INTO ls_eban_upd where updkz ne space.
      MOVE-CORRESPONDING ls_eban_upd TO batu.
      APPEND batu.
    ENDLOOP.

  ELSE.

*-- ab 3.0D über CALL TRANSACTION
    SORT bat BY banfn bnfpo.
    EXPORT bat auto call_updkz TO MEMORY ID 'BAT'. "#EC CI_FLDEXT_OK[2215424] P30K909996
    CALL TRANSACTION 'ME38' AND SKIP FIRST SCREEN.
    IMPORT    batu call_updkz FROM MEMORY ID 'BATU'. "#EC CI_FLDEXT_OK[2215424] P30K909996
*-- Einteilung nicht gebucht - keine Fortschreibung der Banfs ---------*
    IF call_updkz EQ space.
      REFRESH batu.
      CLEAR batu.
    ENDIF.
  ENDIF.

  PERFORM ban_update USING 'E'.
  PERFORM oba_update_best.
  PERFORM zug_modif_zeile USING text-118.

ENDFORM.
