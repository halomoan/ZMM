*eject
*----------------------------------------------------------------------*
*        Ausgabe der Liste fuer Umsetzung Banf in Erfassungsblatt      *
*----------------------------------------------------------------------*
FORM DIEN_LISTE.

 CHECK LISTE EQ 'Z'.

 IF S-FIRSTIND EQ 0.
   MESSAGE S201.
   EXIT.
 ENDIF.

 PERFORM LISTE_MERKEN USING 'X'.
 LISTE = 'G'.
 COM-SRTKZ = '9'.

 READ TABLE BAN INDEX S-FIRSTIND.
*set pf-status 'GERF' excluding excl.
*set titlebar  '015'.

 CLEAR DET.
 DET-UPDKZ = BAN-UPDK1.
 DET-BSART = BAN-BSART.
 DET-UPDKZ = 'XX'.
 DET-EKORG = BAN-EKORG.
 DET-SLIEF = BAN-SLIEF.
 DET-RESWK = BAN-RESWK.
 DET-KONNR = BAN-KONNR.
 DET-FORDN = BAN-FORDN.
 DET-BUKRS = BAN-BUKRS.

 SY-LSIND = 0.
 PERFORM ZUG_CLEAR.
 PERFORM BAN_SORT.
 IF T16LB-DYNPR EQ 0.
   PERFORM BAN_ZEILEN.
 ELSE.
   PERFORM BAN_DYNP_CALL.
 ENDIF.

ENDFORM.
