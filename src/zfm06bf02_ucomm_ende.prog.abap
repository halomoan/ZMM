*eject
*----------------------------------------------------------------------*
*        Beenden                                                       *
*----------------------------------------------------------------------*
FORM UCOMM_ENDE.

  CLEAR BAN.
*- Prüfen, ob Bezugsquellen geändert wurden ---------------------------
  LOOP AT BAN WHERE UPDK1 EQ ZNEW OR
                    UPDK1 EQ ZNER OR
                    UPDK1 EQ ZRES OR
                    UPDK1 EQ AEND.
    EXIT.
  ENDLOOP.

*- Wenn ja, Sicherungs-POP-UP senden ----------------------------------
  IF SY-SUBRC EQ 0.
    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
         EXPORTING
              TEXTLINE1 = TEXT-201
              TEXTLINE2 = TEXT-202
              TITEL     = TEXT-200
         IMPORTING
              ANSWER    = ANSWER.
    CASE ANSWER.
      WHEN 'A'.
        EXIT.
      WHEN 'J'.
        PERFORM BAN_AENDERN.
    ENDCASE.
  ENDIF.

  CLEAR BAN.
*- Prüfen, ob Anfragezuordnung vorgenommen ----------------------------
  LOOP AT BAN WHERE UPDK1 EQ ANFR OR
                    UPDK1 EQ ALIF OR
                    UPDK1 EQ AMAN.
    EXIT.
  ENDLOOP.

*- Wenn ja, Sicherungs-POP-UP senden ----------------------------------
  IF SY-SUBRC EQ 0.
    CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
         EXPORTING
              DEFAULTOPTION = 'N'
              DIAGNOSETEXT1 = TEXT-203
              DIAGNOSETEXT2 = TEXT-204
              TEXTLINE1     = TEXT-205
              TEXTLINE2     = TEXT-206
              TITEL         = TEXT-200
         IMPORTING
              ANSWER        = ANSWER.

    CASE ANSWER.
      WHEN 'A'.
        EXIT.
      WHEN 'N'.
        EXIT.
    ENDCASE.
  ENDIF.

  PERFORM VERLASSEN_LISTE.

ENDFORM.
