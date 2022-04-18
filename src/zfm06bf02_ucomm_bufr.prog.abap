*eject
*----------------------------------------------------------------------*
*        Buchen Freigabe                                               *
*----------------------------------------------------------------------*
FORM UCOMM_BUFR.

  CHECK SY-PFKEY EQ 'FREI'.
  LEERFLG = 'X'.
  CLEAR INDEX_BAN.
  CLEAR ZFREI.
  REFRESH BAT.

*- Suchen einer markierten Position -----------------------------------*
  LOOP AT BAN WHERE SELKZ EQ 'X'.
*- Keine Freigabe möglich ---------------------------------------------*
*... weil schon freigegeben bzw. nicht freigebbar ....................*
*... oder bei Gesamtfreigabe aus ME55, falls nicht alle Positionen ...*
*... für die Liste selektiert wurden in diesem Fall ist selkf initial *
    IF BAN-SELKF EQ 0 AND NOT BAN-UPDK3 IS INITIAL.
      ZFREI = ZFREI + 1.
      IF NOT BAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
        LOOP AT BAN WHERE BANFN EQ BAN-BANFN.
          BAN-SELKZ = '*'.
          MODIFY BAN.
        ENDLOOP.
      ELSE.
        BAN-SELKZ = '*'.
        MODIFY BAN.
      ENDIF.
      PERFORM SEL_KENNZEICHNEN.
    ELSE.
      CLEAR LEERFLG.
      PERFORM FREIGABE_SETZEN.
    ENDIF.
  ENDLOOP.

*- Keine markierte Zeile gefunden - Prüfen auf Line-Selection ---------*
  IF LEERFLG NE SPACE.
*- Alle Markierten sind schon freigebenen -----------------------------*
    IF ZFREI NE 0.
      MESSAGE S234.
      EXIT.
    ENDIF.
    IF HIDE-INDEX NE 0.
      READ TABLE BAN INDEX HIDE-INDEX.
      IF BAN-SELKF EQ 0.
        CASE BAN-UPDK3.
*- Banf ist schon freigegeben -----------------------------------------*
          WHEN FRES.
            MESSAGE S232.
            CLEAR HIDE-INDEX.
            EXIT.
*- Banf ist per Einzelfreigabe bearbeitet worden ----------------------*
          WHEN FREE.
            MESSAGE S276.
            CLEAR HIDE-INDEX.
            EXIT.
*- Bei dieser Banf fehlt die Freigabevoraussetzung --------------------*
          WHEN OTHERS.
            MESSAGE S233.
            CLEAR HIDE-INDEX.
            EXIT.
        ENDCASE.
      ENDIF.
      IF BAN-GSFRG IS INITIAL OR GS_BANF IS INITIAL.
        BAN-SELKZ = 'X'.
        MODIFY BAN INDEX HIDE-INDEX.
        PERFORM FREIGABE_SETZEN.
      ELSE.
        LOOP AT BAN WHERE BANFN EQ BAN-BANFN.
          BAN-SELKZ = 'X'.
          MODIFY BAN.
          PERFORM FREIGABE_SETZEN.
        ENDLOOP.
      ENDIF.
    ELSE.
*- Funktion konnte für keine Zeile ausgeführt werden - vorher markieren*
      MESSAGE S222.
      EXIT.
    ENDIF.
  ENDIF.

  READ TABLE BAT INDEX 1.
  CHECK SY-SUBRC EQ 0.
  SORT BAT BY BANFN BNFPO.
  SORT OBA BY BANFN BNFPO.
  CLEAR: ZSICH, ZENQU, ZAEND, ZBERE, ZNOUP.
  PERFORM AENDERN_BANFS.

*- Tabelle BAN mit erfolgreichen updates fortschreiben ----------------*
  LOOP AT BAN WHERE SELKZ EQ 'X'.
    MOVE-CORRESPONDING BAN TO BANKEY.
    READ TABLE BAT WITH KEY BANKEY BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      BAN-SELKZ = '*'.
      BAN-SELKF = 0.
      BAN-UPDK3 = FRES.
      BAN-FRGZU = BAT-FRGZU.
      BAN-FRGKZ = BAT-FRGKZ.
      MODIFY BAN.
      PERFORM BAN_MODIF_ZEILE USING SPACE.
    ELSE.
*     if ban-gsfrg is initial or gs_banf is initial.
      BAN-SELKZ = '*'.
      MODIFY BAN.
*     else.
*       loop at ban where banfn eq ban-banfn.
*         ban-selkz = '*'.
*         modify ban.
*       endloop.
*     endif.
      PERFORM SEL_KENNZEICHNEN.
    ENDIF.
  ENDLOOP.

ENDFORM.
