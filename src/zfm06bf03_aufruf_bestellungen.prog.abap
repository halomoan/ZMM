*eject
*----------------------------------------------------------------------*
*        Aufruf Anzeigen Bestellungen                                  *
*----------------------------------------------------------------------*
FORM AUFRUF_BESTELLUNGEN.

  CLEAR EXITFLAG.
*- Sind überhaupt Bestellungen vorhanden? -----------------------------*
  IF BAN-BSMNG EQ 0.
    MESSAGE S229 WITH BAN-BNFPO.
    EXITFLAG = 'X'.
    EXIT.
  ENDIF.
*- Aufruf Report ------------------------------------------------------*
  IF NOT BAN-GSFRG IS INITIAL AND
     NOT GS_BANF IS INITIAL   AND
     NOT HIDE-GSFRG IS INITIAL.
*... Auf das Positionsübersichtsbild verzweigen, falls die ...........*
*... 'Kopfzeile' selektiert wurde ....................................*
    SUBMIT RM06EE00 AND RETURN
           WITH P_BANFN = BAN-BANFN.
  ELSE.
    SUBMIT RM06EE00 AND RETURN
           WITH P_BANFN = BAN-BANFN
           WITH P_BNFPO = BAN-BNFPO.
  ENDIF.
ENDFORM.
