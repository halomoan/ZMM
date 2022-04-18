*eject
*----------------------------------------------------------------------*
*        Markieren Intervall (Block markieren)                         *
*----------------------------------------------------------------------*
FORM UCOMM_MINT.

  CHECK LISTE EQ 'G'.

*- prüfen gültige Zeile -----------------------------------------------*
  PERFORM VALID_LINE.
  CHECK EXITFLAG EQ SPACE.
  CLEAR MINT-ACT.

*- Blockende ----------------------------------------------------------*
  IF MINT-BEG NE 0.
*- Blockanfang und -ende vertauschen, wenn Hide-Index kleiner Interv-Ind
    IF HIDE-INDEX LT MINT-BEG.
      MINT-ACT = MINT-BEG.
      MINT-BEG = HIDE-INDEX.
      MINT-END = MINT-ACT.
    ELSE.
      MINT-END = HIDE-INDEX.
    ENDIF.
    MINT-ACT = MINT-BEG.
    DO.
      IF MINT-ACT LE MINT-END.
        READ TABLE BAN INDEX MINT-ACT.
        PERFORM DET_CHECK.
        IF SY-SUBRC EQ 0.
          BAN-SELKZ = 'X'.
          MODIFY BAN INDEX SY-TABIX.
          PERFORM SEL_KENNZEICHNEN.
        ENDIF.
        MINT-ACT = MINT-ACT + 1.
      ELSE.
        CLEAR MINT.
        EXIT.
      ENDIF.
    ENDDO.
  ELSE.
*- Blockanfang - Blockende markieren ----------------------------------*
    MINT-BEG = HIDE-INDEX.
    MESSAGE S213.
  ENDIF.
  CLEAR HIDE-INDEX.

ENDFORM.
