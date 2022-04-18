*eject
*----------------------------------------------------------------------*
*   Selektionskennzeichen auf Liste modifizieren
*----------------------------------------------------------------------*
FORM SEL_KENNZEICHNEN.

  IF XSZTYP NE SPACE.
    IF NOT BAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
*... Bei Gesamtbanfen auf erste Position gehen .......................*
      READ TABLE BAN WITH KEY BANFN = BAN-BANFN.
    ENDIF.
    READ LINE BAN-SZEIL OF PAGE BAN-PAGE INDEX LSIND.
    SY-LISEL+1(1) = BAN-SELKZ.
    MODIFY LINE BAN-SZEIL OF PAGE BAN-PAGE INDEX LSIND.
  ENDIF.

ENDFORM.
