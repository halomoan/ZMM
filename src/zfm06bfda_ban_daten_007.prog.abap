*eject
*----------------------------------------------------------------------*
* Aktuelle Bestands/Bedarfs-Situation                                  *
*----------------------------------------------------------------------*
FORM BAN_DATEN_007.

CLEAR MMDSA.
CLEAR MDSTA.
CLEAR MDKP.
CHECK EBAN-MATNR NE SPACE.
CHECK EBAN-WERKS NE SPACE.

*- Schon gelesen ? ----------------------------------------------------*
MATKEY-MATNR = EBAN-MATNR.
MATKEY-WERKS = EBAN-WERKS.
READ TABLE MMDSA WITH KEY MATKEY BINARY SEARCH.
MINDEX = SY-TABIX.
MSUBRC = SY-SUBRC.

*- Bestands-/Bedarfssituation ermitteln -------------------------------*
IF SY-SUBRC NE 0 OR
   MMDSA-RBEDA EQ SPACE.
*- Materialstamm lesen ------------------------------------------------*
   PERFORM BAN_DATEN_001.
*- Parameter setzen ---------------------------------------------------*
   CLEAR CM61X.
   CM61X-PLOBJ = 'B'.
   CM61X-PLAUF = 'B4'.
   CM61X-PLAKT = 'A'.
   CM61X-DISPD = SY-DATLO.

   CALL FUNCTION 'MD_READ_PLANT'
        EXPORTING  EWERKS = EBAN-WERKS
        IMPORTING  ICM61W = CM61W
                   IT399D = T399D
        EXCEPTIONS ERROR  = 01.
  IF SY-SUBRC > 0.
    MESSAGE ID SY-MSGID TYPE 'A' NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

*- Bestands-/Bedarfszeilen aufbauen -----------------------------------*
   CALL FUNCTION 'AUFBAUEN_MDPSX_ANZEIGEN' "#EC CI_USAGE_OK[2227579] P30K909996
        EXPORTING
             ECM61W = CM61W
             ECM61X = CM61X
             EMT61D = MT61D
             ET399D = T399D
        IMPORTING
             ICM61M = CM61M
             IMDSTA = MDSTA
        TABLES
             MDPSX  = XMDPS
        EXCEPTIONS
             ERROR  = 01.
   IF SY-SUBRC EQ 0.
      MOVE : MDSTA-LABST TO *MDSTA-LABST,
             MDSTA-EINME TO *MDSTA-EINME,
             MDSTA-SPEME TO *MDSTA-SPEME,
             MDSTA-RETME TO *MDSTA-RETME,
             MDSTA-KLABS TO *MDSTA-KLABS,
             MDSTA-KEINM TO *MDSTA-KEINM,
             MDSTA-KSPEM TO *MDSTA-KSPEM,
             MDSTA-INSME TO *MDSTA-INSME,
             MDSTA-KINSM TO *MDSTA-KINSM.
*- Bestands-/Bedarfszeilen kumulieren ---------------------------------*
      CALL FUNCTION 'MDSTA_AUFBAUEN'
           EXPORTING
                EMDSTA = MDSTA
                EINITF = 'X'
           IMPORTING
                IMDSTA = MDSTA
           TABLES
                MDPSX  = XMDPS.
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
   ENDIF.
*- Bestands-/Bedarfssituation merken ----------------------------------*
   MMDSA-MATNR = EBAN-MATNR.
   MMDSA-WERKS = EBAN-WERKS.
   MOVE-CORRESPONDING MDSTA TO MMDSA.
   MMDSA-DSDAT = SY-DATLO.
   MMDSA-RBEST = 'X'.
   MMDSA-RBSTD = 'X'.
   MMDSA-RBEDA = 'X'.
   MMDSA-RDISP = SPACE.
   IF MSUBRC EQ 0.
      MODIFY MMDSA INDEX MINDEX.
   ELSE.
      INSERT MMDSA INDEX MINDEX.
   ENDIF.
ENDIF.
MOVE-CORRESPONDING MMDSA TO MDSTA.
MDKP-DSDAT = MMDSA-DSDAT.

ENDFORM.
