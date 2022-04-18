*eject
*----------------------------------------------------------------------*
* Lieferantentabelle Banfpositionsbezogen initialisieren               *
*----------------------------------------------------------------------*
FORM ALF_INIT.

CLEAR: A-MAXIND, A-PAGIND, A-AKTIND, A-FIRSTIND.
*- ermitteln erster und letzter Lieferant zur Banfpos in ALF
LOOP AT ALF.
   IF ALF-BANFN EQ BAN-BANFN AND
      ALF-BESWK EQ BAN-BESWK AND " CCP
      ALF-BNFPO EQ BAN-BNFPO.
      IF A-FIRSTIND EQ 0.
         A-FIRSTIND = SY-TABIX.
      ENDIF.
      ALF-VSELK = ALF-SELKZ.
      MODIFY ALF INDEX SY-TABIX.
      A-MAXIND = SY-TABIX.
   ELSE.
      IF A-FIRSTIND NE 0.
         EXIT.
      ENDIF.
   ENDIF.
ENDLOOP.

*- keine Lieferanten in ALF -> Infosätze lesen
IF A-FIRSTIND EQ 0.
   PERFORM LESEN_INFO.
*- ermitteln erster und letzter Lieferant zur Pos in ALF
   LOOP AT ALF.
      IF ALF-BANFN EQ BAN-BANFN AND
         ALF-BNFPO EQ BAN-BNFPO.
         IF A-FIRSTIND EQ 0.
            A-FIRSTIND = SY-TABIX.
         ENDIF.
         A-MAXIND = SY-TABIX.
      ELSE.
         IF A-FIRSTIND NE 0.
            EXIT.
         ENDIF.
      ENDIF.
   ENDLOOP.
ENDIF.

IF A-FIRSTIND NE 0.
   A-AKTIND = A-FIRSTIND - 1.
ENDIF.

ENDFORM.
