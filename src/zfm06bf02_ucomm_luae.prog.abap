*eject
*----------------------------------------------------------------------*
*     Ändern Listumfang
*----------------------------------------------------------------------*
FORM UCOMM_LUAE.
  DATA: SLSTUB LIKE T16LB-LSTUB.
  DATA: SDYNPR LIKE T16LB-DYNPR.
  CHECK LISTE EQ 'G'.
  SLSTUB = COM-LSTUB.
  SDYNPR = T16LB-DYNPR.
  T16LL-LSTUB = COM-LSTUB.
  CLEAR REJECT.
  CALL SCREEN 105 STARTING AT 5 6
                  ENDING   AT 35 8.
  IF REJECT NE SPACE.
    COM-LSTUB = SLSTUB.
    EXIT.
  ENDIF.
  IF COM-LSTUB NE SLSTUB.
    PERFORM XT16LL_AUFBAUEN.
    SY-LSIND = 0.
    IF T16LB-DYNPR EQ 0.
      PERFORM BAN_ZEILEN.
    ELSE.
*- Listumfang mehrfach geändert ---------------------------------------*
      IF XCALLD EQ 'X'.
        IF SDYNPR EQ 0.
          XCALLD = 'Z'.
        ELSE.
          XCALLD = 'Y'.
        ENDIF.
      ENDIF.
      PERFORM BAN_DYNP_CALL.
    ENDIF.
  ENDIF.
ENDFORM.
