*eject
*----------------------------------------------------------------------*
*        Dynpro für Banf-Bearbeitung PAI nach Loop.                   *
*----------------------------------------------------------------------*
FORM BAN_DYNP_PAI USING BDP_OK.

  CLEAR LOOPEXIT.
  CASE BDP_OK.
    WHEN 'P+'.                         "eine Seite weiter
      IF B-AKTIND = B-MAXIND.
        B-AKTIND = B-AKTIND - B-PAGIND.
      ENDIF.
      CLEAR BDP_OK.
    WHEN 'P-'.                         "eine Seite zurueck
      B-AKTIND = B-AKTIND - B-PAGIND - B-LOPIND.
      CLEAR BDP_OK.
    WHEN 'P++'.                        "auf letzte Seite
      B-AKTIND = B-MAXIND - B-LOPIND.
      CLEAR BDP_OK.
    WHEN 'P--'.                        "auf erste Seite
      B-AKTIND = 0.
      CLEAR BDP_OK.
    WHEN OTHERS.
      B-AKTIND = B-AKTIND - B-PAGIND.
      SY-UCOMM = BDP_OK.
      CLEAR BDP_OK.
      PERFORM USER_COMMAND.
  ENDCASE.

  IF B-AKTIND LT 0.
    B-AKTIND = 0.
  ENDIF.
ENDFORM.
