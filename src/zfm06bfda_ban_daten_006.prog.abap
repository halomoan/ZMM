*eject
*----------------------------------------------------------------------*
* offene Bestellungen
*----------------------------------------------------------------------*
FORM BAN_DATEN_006.

DATA: F1 TYPE F.
CLEAR MDSTA.
CLEAR MMDSA.
CHECK EBAN-MATNR NE SPACE.
CHECK EBAN-WERKS NE SPACE.

*- Bestellungen schon gelesen ?----------------------------------------*
MATKEY-MATNR = EBAN-MATNR.
MATKEY-WERKS = EBAN-WERKS.
READ TABLE MMDSA WITH KEY MATKEY BINARY SEARCH.
MINDEX = SY-TABIX.
MSUBRC = SY-SUBRC.

*- Bestellungen lesen -------------------------------------------------*
IF SY-SUBRC NE 0 OR
   MMDSA-RBEST EQ SPACE.
   REFRESH XMDBS.
   SELECT * FROM MDBS APPENDING TABLE XMDBS
                      WHERE MATNR EQ EBAN-MATNR
                        AND WERKS EQ EBAN-WERKS
                        AND LOEKZ EQ SPACE
                        AND ELIKZ EQ SPACE
                        AND KNTTP EQ SPACE
                        AND ( BSTYP EQ 'F'
                            OR BSTYP EQ 'L' ).
   LOOP AT XMDBS.
      IF XMDBS-WEMNG LT XMDBS-MENGE.
         F1 = XMDBS-MENGE - XMDBS-WEMNG.
         F1 = F1 * XMDBS-UMREZ / XMDBS-UMREN.
         IF XMDBS-SOBKZ EQ 'K'.
            MMDSA-BEBSK = MMDSA-BEBSK + F1.
         ELSE.
            MMDSA-BEBST = MMDSA-BEBST + F1.
         ENDIF.
      ENDIF.
   ENDLOOP.
   MMDSA-MATNR = EBAN-MATNR.
   MMDSA-WERKS = EBAN-WERKS.
   MMDSA-RBEST = 'X'.
   IF MSUBRC EQ 0.
      MODIFY MMDSA INDEX MINDEX.
   ELSE.
      INSERT MMDSA INDEX MINDEX.
   ENDIF.
ENDIF.
MOVE-CORRESPONDING MMDSA TO MDSTA.

ENDFORM.
