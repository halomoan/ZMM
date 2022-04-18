*eject
*----------------------------------------------------------------------*
* Lieferantentabelle lesen                                             *
* Eintrag wird in LFM1 (Loopzeile) uebertragen.                        *
*----------------------------------------------------------------------*
FORM ALF_LESEN.

A-AKTIND = A-AKTIND + 1.
READ TABLE ALF INDEX A-AKTIND.
IF SY-SUBRC  EQ 0 AND
   ALF-BANFN EQ BAN-BANFN AND
   ALF-BNFPO EQ BAN-BNFPO.
   MOVE-CORRESPONDING ALF TO LFM1.
   RM06B-SELKZ = ALF-VSELK.
   SELECT SINGLE * FROM LFA1 WHERE LIFNR EQ LFM1-LIFNR.
   A-PAGIND = A-PAGIND + 1.
ELSE.
   A-AKTIND = A-AKTIND - 1.
   CLEAR LFM1.
ENDIF.

ENDFORM.
