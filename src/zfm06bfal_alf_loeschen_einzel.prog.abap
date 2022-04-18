*eject
*----------------------------------------------------------------------*
* Einzelnen Lieferant aus ALF loeschen                                 *
*----------------------------------------------------------------------*
FORM ALF_LOESCHEN_EINZEL.

LOOP AT ALF WHERE BANFN EQ BAN-BANFN
            AND   BNFPO EQ BAN-BNFPO
            AND   LIFNR EQ BAN-SLIEF
            AND   EKORG EQ BAN-EKORG.
   CLEAR ALF-SELKZ.
   MODIFY ALF.
ENDLOOP.

ENDFORM.
