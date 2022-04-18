*eject
*----------------------------------------------------------------------*
*  Blaettern                                                           *
*----------------------------------------------------------------------*
FORM ALF_BLAETTERN.

CASE OK-CODE.
*- eine Seite weiter blättern -----------------------------------------*
   WHEN 'VW'.
      IF A-AKTIND = A-MAXIND.
         A-AKTIND = A-AKTIND - A-PAGIND.
      ENDIF.
      CLEAR OK-CODE.
*- eine Seite zurück blättern -----------------------------------------*
   WHEN 'RW'.
      A-AKTIND = A-AKTIND - A-PAGIND - 5.
      CLEAR OK-CODE.
*- auf letzte Seite blättern ------------------------------------------*
   WHEN 'VS'.
      A-AKTIND = A-MAXIND - 5.
      CLEAR OK-CODE.
*- auf erste Seite blättern -------------------------------------------*
   WHEN 'RS'.
      A-AKTIND = A-FIRSTIND - 1.
      CLEAR OK-CODE.
*- auf Bild stehenbleiben ---------------------------------------------*
   WHEN 'ENTE'.
      A-AKTIND = A-AKTIND - A-PAGIND.
*- Loop-Zeilen für weitere Lieferanteneingaben anbieten ---------------*
   WHEN 'WLIF'.
      A-AKTIND = A-AKTIND - A-PAGIND + 5.
*- Selektierte Lieferanten übernehmen und Bild verlassen --------------*
   WHEN 'ANFM'.
      LEERFLG  = 'X'.
      LOOP AT ALF WHERE BANFN EQ BAN-BANFN
                    AND BNFPO EQ BAN-BNFPO.
         ALF-SELKZ = ALF-VSELK.
         CLEAR ALF-VSELK.
         IF ALF-SELKZ NE SPACE.
            CLEAR LEERFLG.
         ENDIF.
         MODIFY ALF INDEX SY-TABIX.
      ENDLOOP.
      IF LEERFLG  EQ SPACE.
         SET PF-STATUS PFKEYP.
         SET SCREEN 0.
         LEAVE SCREEN.
      ELSE.
         A-AKTIND = A-AKTIND - A-PAGIND.
         MESSAGE S269.
      ENDIF.
ENDCASE.

IF A-AKTIND LT A-FIRSTIND.
   A-AKTIND = A-FIRSTIND - 1.
ENDIF.

ENDFORM.
