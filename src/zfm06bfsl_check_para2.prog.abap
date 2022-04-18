*eject
*----------------------------------------------------------------------*
*        Pruefen Zusatzparameter                                       *
*----------------------------------------------------------------------*
FORM CHECK_PARA2.

  REJECT = 'X'.
*------- Pruefen bereits zugeordnete Banfs ----------------------------*
  IF P_ZUGBA EQ SPACE.
    CHECK EBAN-ZUGBA EQ SPACE.
    IF EBAN-FLIEF NE SPACE.
      CHECK EBAN-EKORG EQ SPACE.
    ENDIF.
    IF EBAN-RESWK NE SPACE.
      CHECK EBAN-EKORG EQ SPACE.
    ENDIF.
  ENDIF.

*------- Pruefen offene Banfs -----------------------------------------*
  IF P_ERLBA EQ SPACE.
    CHECK EBAN-LOEKZ EQ SPACE.
    CHECK EBAN-EBAKZ EQ SPACE.
*    CHECK eban-bsmng < eban-menge.                        "121920
    IF eban-bsakz EQ 'R'.              "88504/KB
      CHECK eban-statu NE 'K'.         "88504/KB
      CHECK eban-statu NE 'L'.         "88504/KB
    ELSE.
      CHECK eban-bsmng LT eban-menge OR                     "121920
      eban-pstyp EQ pstyp-wagr.                             "121920
    ENDIF.                                                 "88504/KB
  ENDIF.

*------- Pruefen teilbestellte Banfs ----------------------------------*
  IF P_BSTBA EQ SPACE.
    IF EBAN-LOEKZ EQ SPACE AND
       EBAN-EBAKZ EQ SPACE AND
       EBAN-BSMNG < EBAN-MENGE.
      CHECK EBAN-BSMNG = 0.
    ENDIF.
  ENDIF.

*------- Pruefen Freigabe Banfs ---------------------------------------*
  IF P_FREIG NE SPACE.
    CHECK EBAN-FRGRL EQ SPACE.
* inclomplete PR´s (hold/park) should not be taken into account
    CHECK EBAN-MEMORY IS INITIAL.                          "1449698
  ENDIF.

*... Pruefen der Selektion von Bestellanforderungen zur Gesamtfreigabe
*... bzw. Bestellanforderungen zur Positionsfreigabe .................*
  IF NOT P_SELGS IS INITIAL AND P_SELPO IS INITIAL.
    CHECK NOT EBAN-GSFRG IS INITIAL.
  ELSEIF P_SELGS IS INITIAL AND NOT P_SELPO IS INITIAL.
    CHECK EBAN-GSFRG IS INITIAL.
  ENDIF.

  CLEAR REJECT.

ENDFORM.
