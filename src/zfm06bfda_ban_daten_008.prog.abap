*eject
*----------------------------------------------------------------------*
* Bestands-/Bedarfs-Situation aus Dispoliste                           *
*----------------------------------------------------------------------*
FORM BAN_DATEN_008.

CLEAR MMDSA.
CLEAR MDSTA.
CLEAR MDKP.
CHECK EBAN-MATNR NE SPACE.
CHECK EBAN-WERKS NE SPACE.

*- schon gelesen ? ----------------------------------------------------*
MATKEY-MATNR = EBAN-MATNR.
MATKEY-WERKS = EBAN-WERKS.
READ TABLE MMDSA WITH KEY MATKEY BINARY SEARCH.
MINDEX = SY-TABIX.
MSUBRC = SY-SUBRC.
*- Bestands-/Bedarfssituation ermitteln -------------------------------*
IF MSUBRC NE 0 OR
   MMDSA-RDISP EQ SPACE.
   IF MMDSA-RBEDA EQ SPACE.
*- Bestände retten ----------------------------------------------------*
      MOVE-CORRESPONDING MMDSA TO MDSTA.
      MOVE : MDSTA-LABST TO *MDSTA-LABST,
             MDSTA-EINME TO *MDSTA-EINME,
             MDSTA-SPEME TO *MDSTA-SPEME,
             MDSTA-RETME TO *MDSTA-RETME,
             MDSTA-KLABS TO *MDSTA-KLABS,
             MDSTA-KEINM TO *MDSTA-KEINM,
             MDSTA-KSPEM TO *MDSTA-KSPEM,
             MDSTA-INSME TO *MDSTA-INSME,
             MDSTA-KINSM TO *MDSTA-KINSM,
             MDSTA-SUM01 TO *MDSTA-SUM01,
             MDSTA-BEBST TO *MDSTA-BEBST,
             MDSTA-BEBSK TO *MDSTA-BEBSK.
*- Materialstamm lesen ------------------------------------------------*
      PERFORM BAN_DATEN_001.

*- Dispoliste lesen ---------------------------------------------------*
      SELECT SINGLE * FROM MDKP WHERE DTART = 'MD'
                                  AND MATNR = EBAN-MATNR
                                  AND PLWRK = EBAN-WERKS
                                  AND PLSCN = '000'.

      IF SY-SUBRC EQ 0.
         CALL FUNCTION 'DISPOBELEG_LESEN'
              EXPORTING
                   DTNUM   = MDKP-DTNUM
                   CFLAG   = MDKP-CFLAG
                   MANDT   = SY-MANDT
              TABLES
                   MDPSX   = XMDPS.
         IF SY-SUBRC EQ 0.
*- Bestands-/Bedarfszeilen kumulieren ---------------------------------*
            CALL FUNCTION 'MDSTA_AUFBAUEN'
                 EXPORTING
                      EMDSTA = MDSTA
                      EINITF = 'X'
                 IMPORTING
                      IMDSTA = MDSTA
                 TABLES
                      MDPSX  = XMDPS.
         ENDIF.
      ENDIF.
*- Bestände rückladen -------------------------------------------------*
      MOVE : *MDSTA-LABST TO MDSTA-LABST,
             *MDSTA-EINME TO MDSTA-EINME,
             *MDSTA-SPEME TO MDSTA-SPEME,
             *MDSTA-RETME TO MDSTA-RETME,
             *MDSTA-KLABS TO MDSTA-KLABS,
             *MDSTA-KEINM TO MDSTA-KEINM,
             *MDSTA-KSPEM TO MDSTA-KSPEM,
             *MDSTA-INSME TO MDSTA-INSME,
             *MDSTA-KINSM TO MDSTA-KINSM.
      MDSTA-SUM01 = MDSTA-LABST + MDSTA-KLABS.
      IF MMDSA-RBEST NE SPACE.
         MOVE : *MDSTA-BEBST TO MDSTA-BEBST,
                *MDSTA-BEBSK TO MDSTA-BEBSK.
      ENDIF.
*- Dispoliste merken --------------------------------------------------*
      MMDSA-MATNR = EBAN-MATNR.
      MMDSA-WERKS = EBAN-WERKS.
      MOVE-CORRESPONDING MDSTA TO MMDSA.
      MMDSA-DSDAT = MDKP-DSDAT.
      MMDSA-RDISP = 'X'.
      IF MSUBRC EQ 0.
         MODIFY MMDSA INDEX MINDEX.
      ELSE.
         INSERT MMDSA INDEX MINDEX.
      ENDIF.
   ENDIF.
ENDIF.
MOVE-CORRESPONDING MMDSA TO MDSTA.
MDKP-DSDAT = MMDSA-DSDAT.

ENDFORM.
