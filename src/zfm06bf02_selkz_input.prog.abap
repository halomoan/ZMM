*eject
*----------------------------------------------------------------------*
* Explizite Eingabe des Selektionskennezeichens übernehmen             *
*----------------------------------------------------------------------*
FORM SELKZ_INPUT.

  DATA: SHIDE-INDEX LIKE SY-TABIX.
  DATA: SHIDE-GSFRG LIKE BAN-GSFRG.
  CHECK LISTE EQ 'G'.
  CHECK T16LB-DYNPR EQ 0.
  CHECK XSZTYP NE SPACE.
  CHECK T16LH-XMKEX NE SPACE.

*... Hide-Felder der Cursorposition sichern, da sogleich ein .........*
*... 'read line ...' folgt ! .........................................*
  SHIDE-INDEX = HIDE-INDEX.
  SHIDE-GSFRG = HIDE-GSFRG.

  CLEAR: SAVE_BANF, SAVE_SELKZ.
  LOOP AT BAN.
    IF BAN-BANFN EQ SAVE_BANF AND
       SAVE_SELKZ NE BAN-SELKZ AND NOT GS_BANF IS INITIAL.
*... Bei Gesamtbanf alle Positionen markieren ........................*
      BAN-SELKZ = SAVE_SELKZ.
      MODIFY BAN.
    ELSE.
      READ LINE BAN-SZEIL OF PAGE BAN-PAGE INDEX LSIND.
      CHECK SY-SUBRC EQ 0.
      PERFORM DET_CHECK.
      CHECK SY-SUBRC EQ 0.
      IF SY-LISEL+1(1) NE BAN-SELKZ.
        BAN-SELKZ = SY-LISEL+1(1).
        MODIFY BAN.
        IF NOT BAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
*... Bei Gesamtbanf alle Positionen markieren ........................*
          SAVE_BANF = BAN-BANFN.
          SAVE_SELKZ = SY-LISEL+1(1).
        ELSE.
          CLEAR: SAVE_BANF, SAVE_SELKZ.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
*... Hide-Felder der Cursor-Position wieder setzen ...................*
  HIDE-INDEX = SHIDE-INDEX.
  HIDE-GSFRG = SHIDE-GSFRG.
  LI_STARO = SY-STARO.

ENDFORM.
