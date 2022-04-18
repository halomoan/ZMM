*eject
*----------------------------------------------------------------------*
*        Warnung, wenn schon bearbeitet                                *
*----------------------------------------------------------------------*
FORM WARNING_UPDK3.

  CASE BAN-UPDK3.
    WHEN BUBE.
      MESSAGE I290 WITH BAN-BANFN BAN-BNFPO.
    WHEN BUBA.
      MESSAGE I288 WITH BAN-BANFN BAN-BNFPO.
    WHEN BUAN.
      MESSAGE I289 WITH BAN-BANFN BAN-BNFPO.
  ENDCASE.

ENDFORM.
