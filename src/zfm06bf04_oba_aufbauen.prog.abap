*----------------------------------------------------------------------*
*  Gelesenen Stand der Banfs sichern                                  *
*----------------------------------------------------------------------*
FORM OBA_AUFBAUEN.
  LOOP AT BAN.
    MOVE BAN TO OBA.
    APPEND OBA.
  ENDLOOP.
  SORT OBA BY BANFN BNFPO.
ENDFORM.
