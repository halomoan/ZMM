*eject
*----------------------------------------------------------------------*
*  Zugeordnet über Orderbuch                                           *
*----------------------------------------------------------------------*
FORM BAN_UPDATE_ORDR.

  BAN-SELKZ = '*'.
*ENHANCEMENT-POINT FM06BF03_BAN_UPDATE_ORDR_01 SPOTS ES_SAPFM06B.
  MODIFY BAN INDEX INDEX_BAN.
  PERFORM BAN_MODIF_ZEILE USING BQPEX-FESKZ.
  PERFORM ALF_LOESCHEN.

ENDFORM.
