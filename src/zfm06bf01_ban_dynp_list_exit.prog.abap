*eject
*----------------------------------------------------------------------*
*        Dynpro für Banf-Bearbeitung PAI nach Loop.                   *
*----------------------------------------------------------------------*
FORM BAN_DYNP_LIST_EXIT USING BDL_OK.
  CASE BDL_OK.
    WHEN 'XIT'.
      LOOPEXIT = '1'.
    WHEN 'XIL'.
      LOOPEXIT = '2'.
      CLEAR BDL_OK.
  ENDCASE.
ENDFORM.
