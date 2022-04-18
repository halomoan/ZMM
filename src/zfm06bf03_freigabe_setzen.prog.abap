*eject
*----------------------------------------------------------------------*
*        Freigabe für die selektierten Banfs setzen                    *
*----------------------------------------------------------------------*
FORM FREIGABE_SETZEN.

  CHECK BAN-SELKF GT 0.
  MOVE BAN TO OBA.
  APPEND OBA.
  MOVE BAN TO BAT.
  BAN-SELKF = BAN-SELKF - 1.
  WRITE 'X' TO BAT-FRGZU+BAN-SELKF(1).
  CALL FUNCTION 'ME_REL_FRGKZ'
    EXPORTING
      I_FRGOT = '1'
      I_FRGGR = BAT-FRGGR
      I_FRGST = BAT-FRGST
      I_FRGKZ = BAT-FRGKZ
      I_FRGRL = BAT-FRGRL
      I_FRGZU = BAT-FRGZU
    IMPORTING
      E_FRGRL = BAT-FRGRL
      E_FRGKZ = BAT-FRGKZ.

* DCM adapter
  data: l_Eban      type eban,
        l_Eban_old  type eban,
        lt_ebkn     type mereq_t_Ebkn,                      "605263
        lt_ebkn_old type mereq_t_ebkn.                      "605263


  move bat to l_Eban.
  move ban to l_Eban_old.
  CALL FUNCTION 'MEDI_REQ_RELEASE'
    EXPORTING
      im_eban       = l_eban
      im_eban_old   = l_eban_old
      im_activity   = ver
      IM_PERSISTENT = 'X'
    IMPORTING
      EX_BANPR      = l_eban-banpr
      EX_RLWRT      = l_eban-rlwrt
    EXCEPTIONS
      error_message = 1
      OTHERS        = 2.

  CALL FUNCTION 'MEDI_REQ_BUYER_APPROVAL'
    EXPORTING
      im_eban       = l_eban
      im_eban_old   = l_eban_old
      im_ebkn       = lt_Ebkn
      im_ebkn_old   = lt_ebkn_old
      im_activity   = ver
      IM_PERSISTENT = 'X'
    IMPORTING
      EX_BANPR      = l_eban-banpr
    EXCEPTIONS
      error_message = 1
      OTHERS        = 2.

  bat-banpr = l_eban-banpr.
  bat-rlwrt = l_eban-rlwrt.

  APPEND BAT.

ENDFORM.                    "FREIGABE_SETZEN
