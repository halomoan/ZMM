*eject
*----------------------------------------------------------------------*
* Lieferantentabelle loeschen                                          *
* Bei Rücksetzen Zuordnung oder anderweitiger Zuordnung der Banf       *
*----------------------------------------------------------------------*
FORM ALF_LOESCHEN.

LOOP AT ALF WHERE BANFN EQ BAN-BANFN
            AND   BNFPO EQ BAN-BNFPO.
   CLEAR ALF-SELKZ.
   MODIFY ALF.
ENDLOOP.

ENDFORM.
