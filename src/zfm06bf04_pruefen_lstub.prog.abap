*----------------------------------------------------------------------*
*  Prüfen Listumfang                                                  *
*----------------------------------------------------------------------*
FORM pruefen_lstub USING prl_lstub.

  SELECT SINGLE * FROM t16lb WHERE lstub EQ prl_lstub.
  IF sy-subrc NE 0.
    MESSAGE e287 WITH prl_lstub.
  ENDIF.
  IF t16lb-dynpr EQ 0 AND t16lb-alvgr EQ space.
    SELECT * FROM t16ll WHERE lstub EQ prl_lstub.
      EXIT.
    ENDSELECT.
    IF sy-subrc NE 0.
      MESSAGE e287 WITH prl_lstub.
    ENDIF.
  ENDIF.

* check whether generic reporting should be used ( hooks )
  DATA: l_scope TYPE string40.
  IF gpfkey NE space AND t16lb-alvgr NE space.
* the report was started in the conventional mode and the user
* decided to change lstub to the enjoy version: not possible
    MESSAGE e287 WITH prl_lstub.
  ELSE.
    l_scope = prl_lstub.
    CALL FUNCTION 'ZMM_ME_REP_GET_TABLE_MANAGER'
      EXPORTING
        im_scope   = l_scope
      IMPORTING
        ex_manager = gf_factory.
  ENDIF.

ENDFORM.                    "PRUEFEN_LSTUB

*----------------------------------------------------------------------*
*  FORCE_ALV: Forces ALV grid for output             new with ERP 1.0 PA
*----------------------------------------------------------------------*

FORM force_alv USING im_p_alv TYPE c.

  CHECK NOT im_p_alv IS INITIAL.
  CHECK gf_factory IS INITIAL.

  CALL FUNCTION 'ZMM_ME_REP_GET_TABLE_MANAGER'
    IMPORTING
      ex_manager = gf_factory.

ENDFORM.                    "force_alv

*----------------------------------------------------------------------*
*  COUNT_WORKLOAD: Count workload for purchasing agent
*                                                    new with ERP 1.0 PA
*----------------------------------------------------------------------*

FORM count_workload USING im_not_found TYPE c
                          im_p_wlmem   TYPE memory_id.

  CHECK NOT im_p_wlmem IS INITIAL.                "only in count mode

  DATA: lf_count           TYPE workload.

  IF im_not_found IS INITIAL.
    lf_count = LINES( ban[] ).                      "count workload
  ENDIF.

  EXPORT wl = lf_count TO MEMORY ID im_p_wlmem.
  LEAVE PROGRAM.

ENDFORM.                    "COUNT_WORKLOAD
