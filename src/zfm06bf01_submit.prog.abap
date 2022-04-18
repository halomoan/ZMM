*eject
*----------------------------------------------------------------------*
*        Listausgabereport aufrufen                                    *
*----------------------------------------------------------------------*
FORM submit USING hucomm.

* generic reporting: call framework
  IF NOT gf_factory IS INITIAL.

    IF com-gpfkey EQ 'ZUOR' OR com-gpfkey EQ 'BEAR' OR com-gpfkey EQ 'GBST'.

      TYPE-POOLS: mmpur.
      DATA: ls_initiator TYPE mepo_initiator.
      CASE com-gpfkey.
*        WHEN 'ZUOR'. ls_initiator-initiator = mmpur_me56.
        WHEN 'ZUOR'. ls_initiator-initiator = 'ZME56'.
        WHEN 'BEAR'. ls_initiator-initiator = mmpur_me57.
        WHEN 'GBST'. ls_initiator-initiator = mmpur_me58.
      ENDCASE.

      CLEAR: ban[].

      CALL FUNCTION 'MEGUI_ASSIGN_AND_PROCESS_REQS'
        EXPORTING
          im_table_manager = gf_factory
          im_initiator     = ls_initiator.

    ELSE.

      DATA: lt_options TYPE mepo_initiator_options,
            ls_option  LIKE LINE OF lt_options.

      IF com-gpfkey EQ 'FREI' OR com-gpfkey EQ 'FRER'.

        IF com-gpfkey EQ 'FREI'.
          ls_option-property = 'FRGAB'.
          ls_option-value = com-frgab.
          APPEND ls_option TO lt_options.
        ENDIF.
      ENDIF.

      CLEAR: ban[].

      CALL FUNCTION 'ME_REP_START_VIA_TABLE_MANAGER'
        EXPORTING
          im_table_manager = gf_factory
          im_options       = lt_options.

    ENDIF.
    EXIT.
  ENDIF.

  DATA: params LIKE pri_params.
  DATA: arcparams LIKE arc_params.                          "HW 202820

  EXPORT ban com TO MEMORY ID 'ZYX'. "#EC CI_FLDEXT_OK[2215424] P30K909996
  IF sy-binpt EQ space.                                   "<--- h91102
    IF hucomm EQ 'PRIN' OR sy-batch NE space.

      CALL FUNCTION 'GET_PRINT_PARAMETERS'
        EXPORTING
          mode                   = 'CURRENT'
          no_dialog              = 'X'
        IMPORTING
          out_archive_parameters = arcparams                "HW 202820
          out_parameters         = params
        EXCEPTIONS
          archive_info_not_found = 1
          invalid_print_params   = 2
          invalid_archive_params = 3
          OTHERS                 = 4.

*      SUBMIT rm06bl00 TO SAP-SPOOL WITHOUT SPOOL DYNPRO
      SUBMIT zmm_rm06bl00 TO SAP-SPOOL WITHOUT SPOOL DYNPRO
                          ARCHIVE PARAMETERS arcparams      "HW 202820
                          SPOOL PARAMETERS params AND RETURN.
    ELSE. " hucomm NE 'PRIN' AND sy-batch EQ space
* it's not printing and not background
      IF hucomm <> 'EXT_CALL'.
*        SUBMIT rm06bl00 AND RETURN.
        SUBMIT zmm_rm06bl00 AND RETURN.
      ENDIF.
    ENDIF.
  ELSE. " sy-binpt NE space                               "<--- insert
* it's batch input
*    SUBMIT rm06bl00 AND RETURN.                           "<--- insert
    SUBMIT zmm_rm06bl00 AND RETURN.
  ENDIF.                                                  "<--- insert
ENDFORM.                    "SUBMIT
