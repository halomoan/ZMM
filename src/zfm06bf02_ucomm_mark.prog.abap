*eject
*----------------------------------------------------------------------*
*        Einzelzeile markieren                                         *
*----------------------------------------------------------------------*
FORM ucomm_mark.

  CHECK liste EQ 'G'.

  PERFORM valid_line.
  CHECK exitflag EQ space.

  READ TABLE ban INDEX hide-index.
  IF sy-subrc EQ 0.
    IF ban-gsfrg IS INITIAL OR gs_banf IS INITIAL.             "157619
      IF ban-selkz NE 'X'.
        ban-selkz = 'X'.
      ELSE.
        ban-selkz = space.
      ENDIF.
      MODIFY ban INDEX hide-index.
    ELSE.                                                      "157619
      LOOP AT ban WHERE banfn EQ ban-banfn.                    "157619
        IF ban-selkz NE 'X'.                                   "157619
          ban-selkz = 'X'.                                     "157619
        ELSE.                                                  "157619
          ban-selkz = space.                                   "157619
        ENDIF.                                                 "157619
        MODIFY ban.                                            "157619
      ENDLOOP.                                                 "157619
    ENDIF.                                                     "157619
  ENDIF.

*- Selektionskennzeichen modifizieren ---------------------------------*
  PERFORM sel_kennzeichnen.

ENDFORM.                    "ucomm_mark
*-- Note 739690
*&---------------------------------------------------------------------*
*&      Form  UCOMM_LOG1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ucomm_log1 .
  TYPE-POOLS : slis.
  DATA       : l_t_fieldcat_alv TYPE slis_t_fieldcat_alv,
               l_s_fieldcat_alv TYPE slis_fieldcat_alv.

  CLEAR l_s_fieldcat_alv.
  l_s_fieldcat_alv-fieldname     = 'BANFN'.
  l_s_fieldcat_alv-ref_fieldname = 'BANFN'.
  l_s_fieldcat_alv-ref_tabname   = 'EBAN'.
  l_s_fieldcat_alv-key           = 'X'.
  l_s_fieldcat_alv-hotspot       = ' '.
  APPEND l_s_fieldcat_alv TO l_t_fieldcat_alv.

  CLEAR l_s_fieldcat_alv.
  l_s_fieldcat_alv-fieldname     = 'ARBGB'.
  l_s_fieldcat_alv-ref_fieldname = 'ARBGB'.
  l_s_fieldcat_alv-ref_tabname   = 'MESG'.
  l_s_fieldcat_alv-key           = ' '.
  l_s_fieldcat_alv-hotspot       = ' '.
  APPEND l_s_fieldcat_alv TO l_t_fieldcat_alv.

  CLEAR l_s_fieldcat_alv.
  l_s_fieldcat_alv-fieldname     = 'MSGTY'.
  l_s_fieldcat_alv-ref_fieldname = 'MSGTY'.
  l_s_fieldcat_alv-ref_tabname   = 'MESG'.
  l_s_fieldcat_alv-key           = ' '.
  l_s_fieldcat_alv-hotspot       = ' '.
  APPEND l_s_fieldcat_alv TO l_t_fieldcat_alv.

  CLEAR l_s_fieldcat_alv.
  l_s_fieldcat_alv-fieldname     = 'TXTNR'.
  l_s_fieldcat_alv-ref_fieldname = 'TXTNR'.
  l_s_fieldcat_alv-ref_tabname   = 'MESG'.
  l_s_fieldcat_alv-key           = ' '.
  l_s_fieldcat_alv-hotspot       = ' '.
  APPEND l_s_fieldcat_alv TO l_t_fieldcat_alv.

  CLEAR l_s_fieldcat_alv.
  l_s_fieldcat_alv-fieldname     = 'TEXT'.
  l_s_fieldcat_alv-ref_fieldname = 'TEXT'.
  l_s_fieldcat_alv-ref_tabname   = 'MESG'.
  l_s_fieldcat_alv-key           = ' '.
  l_s_fieldcat_alv-hotspot       = ' '.
  APPEND l_s_fieldcat_alv TO l_t_fieldcat_alv.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program    = sy-repid
      it_fieldcat           = l_t_fieldcat_alv
      i_screen_start_column = '10'
      i_screen_start_line   = '10'
      i_screen_end_column   = '100'
      i_screen_end_line     = '50'
    TABLES
      t_outtab              = t_excluded
    EXCEPTIONS
      program_error         = 1
      OTHERS                = 2.

ENDFORM.                    " UCOMM_LOG1
*-- Note 739690
