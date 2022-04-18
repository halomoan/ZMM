************************************************************************
*        Usercommands                                                  *
************************************************************************
*eject
*----------------------------------------------------------------------*
*        Arbeitsvorrat aktualisieren                                   *
*----------------------------------------------------------------------*
FORM ucomm_aakt.

  IF liste EQ 'G'.
    CHECK det EQ space.
  ENDIF.
  LOOP AT ban WHERE updk3 NE space.
    IF ban-updk3 EQ bube.
      CHECK ban-bsmng GE ban-menge OR
            ban-ebakz NE space.
    ENDIF.
* Don't delete the PReq if the assignment is canceled and
* the document is not yet updated.
    IF ban-updk1 EQ zres.                                   "359179
      CHECK ban-updk3 EQ buba.
    ENDIF.
    DELETE ban.
  ENDLOOP.

  sy-lsind = 0.
  IF liste EQ 'G'.
    PERFORM ban_sort.
    IF t16lb-dynpr EQ 0.
      PERFORM ban_zeilen.
    ELSE.
      CLEAR: b-aktind, b-lopind, b-maxind, b-pagind, b-lesind.
      DESCRIBE TABLE ban LINES b-maxind.
    ENDIF.
  ELSE.
    PERFORM zug_zeilen.
  ENDIF.

ENDFORM.                    "ucomm_aakt
