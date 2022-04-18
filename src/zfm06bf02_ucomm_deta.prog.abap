*eject
*----------------------------------------------------------------------*
*     Banf-Detail-Bearbeitung
*----------------------------------------------------------------------*
FORM UCOMM_DETA.

  CHECK LISTE EQ 'G'.
  LEERFLG = 'X'.
  REFRESH BDE.

  LOOP AT BAN WHERE SELKZ EQ 'X'.
    IF NOT BAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
*... Suchen einer markierten Position nur für Banfen mit Positions- ..*
*... freigabe möglich und sinnvoll, da bei Gesamtbanfen nur auf 'Kopf-*
*... ebene selektiert werden kann und da eine Detailanzeige keinen ...*
*... Sinn macht ......................................................*
      MESSAGE S198.
      EXIT.
    ELSE.
      CLEAR LEERFLG.
      BDE-INDEX = SY-TABIX.
      APPEND BDE.
      BAN-SELKZ = '*'.
      MODIFY BAN.
*- Selektionskennzeichen modifizieren ---------------------------------*
      PERFORM SEL_KENNZEICHNEN.
    ENDIF.
  ENDLOOP.

  IF LEERFLG NE SPACE.
*- Line-Selektion -----------------------------------------------------*
    IF HIDE-INDEX NE 0 AND HIDE-GSFRG IS INITIAL.
      BDE-INDEX = HIDE-INDEX.
      APPEND BDE.
    ELSEIF NOT HIDE-GSFRG IS INITIAL.
*... Für Gesamtbanfen auf 'Kopfzeile' kein Detail möglich ............*
      MESSAGE S198.
      EXIT.
    ELSE.
*- Funktion konnte für keine Zeile ausgeführt werden - vorher markieren*
      MESSAGE S222.
      EXIT.
    ENDIF.
  ENDIF.
*- Bearbeiten selektierte ---------------------------------------------*
  LOOP AT BDE.
    DO.
*- Dynpro aufrufen ----------------------------------------------------*
      READ TABLE BAN INDEX BDE-INDEX.
      HIDE-INDEX = BDE-INDEX.
      MOVE BAN TO EBAN.
      MOVE EBAN TO *EBAN.
      PERFORM BAN_AUSGABE_VORBEREITEN USING 'D'.
      CLEAR SY-UCOMM.
      CALL SCREEN 300 STARTING AT 1 1.
      IF OK-CODE NE 'XIT' AND
        ( BAN-UPDK1 = AEND OR
          BAN-UPDK1 = ZNER OR
          BAN-UPDK1 = ZNEW ).
        PERFORM BAN_MODIF_ZEILE USING SPACE.
      ENDIF.
*- Nächste Banf -> nächster Eintrag BDE--------------------------------*
      CLEAR REJECT.
      CASE OK-CODE.
        WHEN SPACE.
          EXIT.
        WHEN 'NEXD'.
          CLEAR OK-CODE.
          EXIT.
*- Abbrechen -> zurück in Grundliste ----------------------------------*
        WHEN 'XIT'.
          EXIT.
*- Andere Funktion -> Funktion ausführen und zurück aufs Dynpro -------*
        WHEN OTHERS.
          SY-UCOMM = OK-CODE.
          CLEAR OK-CODE.
          PERFORM USER_COMMAND.
      ENDCASE.
    ENDDO.
    IF OK-CODE EQ 'XIT'.
      REFRESH BDE.
      CLEAR OK-CODE.
      EXIT.
    ENDIF.
  ENDLOOP.

ENDFORM.
