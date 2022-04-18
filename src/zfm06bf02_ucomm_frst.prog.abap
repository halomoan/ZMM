*eject
*----------------------------------------------------------------------*
*        Anzeigen Freigabestrategie                                    *
*----------------------------------------------------------------------*
FORM UCOMM_FRST.

  CHECK LISTE EQ 'G'.
  LEERFLG = 'X'.

*- Suchen einer markierten Position -----------------------------------*
  LOOP AT BAN WHERE SELKZ EQ 'X'.
    IF NOT BAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
      LOOP AT BAN WHERE BANFN EQ BAN-BANFN.
        BAN-SELKZ = '*'.
        MODIFY BAN.
      ENDLOOP.
    ELSE.
      BAN-SELKZ = '*'.
      MODIFY BAN.
    ENDIF.
    CLEAR LEERFLG.
*- Freigabestrategie anzeigen -----------------------------------------*
    IF BAN-FRGST EQ SPACE.
      MESSAGE S297 WITH BAN-BNFPO.
      EXIT.
    ENDIF.
    IF BAN-FRGGR NE SPACE.
      IF BAN-GSFRG IS INITIAL OR GS_BANF IS INITIAL.
*... Positionsfreigabe ...............................................*
        HTITEL = TEXT-517.
        REPLACE '&1' WITH BAN-BANFN INTO HTITEL.
        REPLACE '&2' WITH BAN-BNFPO INTO HTITEL.
      ELSE.
*... Gesamtfreigabe ..................................................*
        HTITEL = TEXT-518.
        REPLACE '&1' WITH BAN-BANFN INTO HTITEL.
      ENDIF.
      CALL FUNCTION 'ME_REL_INFO'
           EXPORTING
                I_TITLE    = HTITEL
                I_FRGCO    = RM06B-FRGAB
                I_FRGKZ    = BAN-FRGKZ
                I_FRGGR    = BAN-FRGGR
                I_FRGST    = BAN-FRGST
                I_FRGZU    = BAN-FRGZU
                I_FRGOT    = '1'
           EXCEPTIONS
                NOT_ACTIVE = 01.
    ELSE.
      CALL FUNCTION 'ME_INFO_RELEASE'
           EXPORTING
                I_BNFPO = BAN-BNFPO
                I_FRGAB = RM06B-FRGAB
                I_FRGKZ = BAN-FRGKZ
                I_FRGST = BAN-FRGST
                I_FRGZU = BAN-FRGZU.
    ENDIF.
*- Selektionskennzeichen modifizieren ---------------------------------*
    PERFORM SEL_KENNZEICHNEN.
*- für eine Position ausgeführt - Schleife verlassen ------------------*
    EXIT.
  ENDLOOP.

  IF LEERFLG NE SPACE.
*- Keine markierte Zeile gefunden - Prüfen auf Line-Selection ---------*
    IF HIDE-INDEX NE 0.
      READ TABLE BAN INDEX HIDE-INDEX.
      IF BAN-FRGST EQ SPACE.
        MESSAGE S297 WITH BAN-BNFPO.
        EXIT.
      ENDIF.
      IF BAN-FRGGR NE SPACE.
        IF BAN-GSFRG IS INITIAL OR GS_BANF IS INITIAL.
*... Positionsfreigabe ...............................................*
          HTITEL = TEXT-517.
          REPLACE '&1' WITH BAN-BANFN INTO HTITEL.
          REPLACE '&2' WITH BAN-BNFPO INTO HTITEL.
        ELSE.
*... Gesamtfreigabe ..................................................*
          HTITEL = TEXT-518.
          REPLACE '&1' WITH BAN-BANFN INTO HTITEL.
        ENDIF.
        CALL FUNCTION 'ME_REL_INFO'
             EXPORTING
                  I_TITLE    = HTITEL
                  I_FRGCO    = COM-FRGAB
                  I_FRGKZ    = BAN-FRGKZ
                  I_FRGGR    = BAN-FRGGR
                  I_FRGST    = BAN-FRGST
                  I_FRGZU    = BAN-FRGZU
                  I_FRGOT    = '1'
             EXCEPTIONS
                  NOT_ACTIVE = 01.
      ELSE.
        CALL FUNCTION 'ME_INFO_RELEASE'
             EXPORTING
                  I_BNFPO = BAN-BNFPO
                  I_FRGAB = COM-FRGAB
                  I_FRGKZ = BAN-FRGKZ
                  I_FRGST = BAN-FRGST
                  I_FRGZU = BAN-FRGZU.
      ENDIF.
      IF BAN-GSFRG IS INITIAL OR GS_BANF IS INITIAL.
        BAN-SELKZ = '*'.
        MODIFY BAN INDEX HIDE-INDEX.
      ELSE.
        LOOP AT BAN WHERE BANFN EQ BAN-BANFN.
          BAN-SELKZ = '*'.
          MODIFY BAN.
        ENDLOOP.
      ENDIF.
*- falls auch zusätzlich angekreuzt - Stern setzen --------------------*
      PERFORM SEL_KENNZEICHNEN.
    ELSE.
*- Funktion konnte für keine Zeile ausgeführt werden - vorher markieren*
      MESSAGE S222.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.
