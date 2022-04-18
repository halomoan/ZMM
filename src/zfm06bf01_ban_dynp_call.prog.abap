*eject
*----------------------------------------------------------------------*
*        Dynpro für Banfbearbeitung aufrufen                           *
*----------------------------------------------------------------------*
FORM BAN_DYNP_CALL.

  CLEAR: B-AKTIND, B-LOPIND, B-MAXIND, B-PAGIND, B-LESIND.
  REFRESH BDT.
  DESCRIBE TABLE BAN LINES B-MAXIND.
*- Indextabelle bei Detailanzeige aufbauen ----------------------------*
  IF DET NE SPACE.
    CLEAR B-MAXIND.
    LOOP AT BAN.
      PERFORM DET_CHECK.
      CHECK SY-SUBRC EQ 0.
      BDT-INDEX = SY-TABIX.
      APPEND BDT.
      B-MAXIND = B-MAXIND + 1.
    ENDLOOP.
  ENDIF.

  CASE XCALLD.
*- Liste -> Loop oder Start mit Loop ----------------------------------*
    WHEN SPACE.
      XCALLD = 'X'.
      CALL SCREEN T16LB-DYNPR.
*- Loop  -> Loop ------------------------------------------------------*
    WHEN 'Y'.
      XCALLD = 'X'.
      SET SCREEN T16LB-DYNPR.
*- Loop  -> Liste -> gleiches Loop-Dynpro -----------------------------*
    WHEN 'X'.
      LEAVE.
*- Loop  -> Liste -> anderes Loop-Dynpro ------------------------------*
    WHEN 'Z'.
      XCALLD = 'X'.
      SET SCREEN T16LB-DYNPR.
      LEAVE.
  ENDCASE.

ENDFORM.
