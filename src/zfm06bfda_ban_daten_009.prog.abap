*eject
*----------------------------------------------------------------------*
* Prognosedaten                                                        *
*----------------------------------------------------------------------*
FORM BAN_DATEN_009.

DATA ZINDEX.
DATA STARTD LIKE SY-DATUM.
DATA STARTW LIKE SCAL-WEEK.
CLEAR ZINDEX.
CLEAR PINDEX.
CHECK EBAN-MATNR NE SPACE.
CHECK EBAN-WERKS NE SPACE.

*- Prognose schon gelesen ? -------------------------------------------*
MATKEY-MATNR = EBAN-MATNR.
MATKEY-WERKS = EBAN-WERKS.
READ TABLE MPROG WITH KEY MATKEY BINARY SEARCH.
MINDEX = SY-TABIX.
PINDEX = SY-TABIX.
IF SY-SUBRC NE 0.
*- Materialstamm nachlesen --------------------------------------------*
   PERFORM BAN_DATEN_001.

*- Prognosedaten lesen ------------------------------------------------*
   MAPRF-MATNR = EBAN-MATNR.
   MAPRF-WERKS = EBAN-WERKS.
   MAPRF-PERKZ = MT61D-PERKZ.
   MAPRF-PERIV = MT61D-PERIV.
   REFRESH XPROWF.
   CALL FUNCTION 'LESEN_PROGNOSE'
        EXPORTING
             IMAPRF = MAPRF
        IMPORTING
             EPROPF = PROPF
        TABLES
             TPROWF = XPROWF
        EXCEPTIONS
             OTHERS = 01.
*- Startdatum für Prognose bestimmen ----------------------------------*
   CASE MT61D-PERKZ.
      WHEN 'P'.
      IF NOT XPROWF IS INITIAL.                        "426379
        CALL FUNCTION 'PROGNOSEPERIODEN_ERMITTELN'
             EXPORTING
                  EANZPR = 1
                  EDATUM = XPROWF-ERTAG
                  EPERIV = MT61D-PERIV
             TABLES
                  PPERX = XPPER.
        READ TABLE XPPER INDEX 1.
        STARTD = XPPER-VONTG.
      ENDIF.                                           "426379
     WHEN 'M'.
        STARTD = SY-DATLO.
        STARTD+6(2) = '01'.
     WHEN 'W'.
        CALL FUNCTION 'DATE_GET_WEEK'
             EXPORTING
                  DATE = SY-DATLO
             IMPORTING
                  WEEK = STARTW
             EXCEPTIONS
                  DATE_INVALID = 01.
        CALL FUNCTION 'WEEK_GET_FIRST_DAY'
             EXPORTING
                  WEEK = STARTW
             IMPORTING
                  DATE = STARTD
             EXCEPTIONS
                  WEEK_INVALID = 01.
     WHEN 'T'.
        STARTD = SY-DATLO.
   ENDCASE.
*- Prognosedaten aufbereiten ------------------------------------------*
   LOOP AT XPROWF.
      IF XPROWF-ERTAG GE STARTD.
         CLEAR MPROG.
         MPROG-MATNR = EBAN-MATNR.
         MPROG-WERKS = EBAN-WERKS.
         MOVE-CORRESPONDING XPROWF TO MPROG.
         CASE MT61D-PERKZ.
            WHEN 'P'.
              CALL FUNCTION 'PROGNOSEPERIODEN_ERMITTELN'
                   EXPORTING
                        EANZPR = 1
                        EDATUM = XPROWF-ERTAG
                        EPERIV = MT61D-PERIV
                   TABLES
                        PPERX = XPPER.
              READ TABLE XPPER INDEX 1.
              MOVE XPPER-PRPER+4(2)  TO MPROG-PRIOD.
              MOVE '/'               TO MPROG-PRIOD+2.
              MOVE XPPER-PRPER(4)    TO MPROG-PRIOD+3.
           WHEN 'M'.
              CALL FUNCTION 'DATUMSAUFBEREITUNG'
                   EXPORTING
                        FLAGM = 'X'
                        IDATE = XPROWF-ERTAG
                   IMPORTING
                        MDAT6 = MPROG-PRIOD
                   EXCEPTIONS
                        OTHERS = 01.
           WHEN 'W'.
              CALL FUNCTION 'DATUMSAUFBEREITUNG'
                   EXPORTING
                        FLAGW = 'X'
                        IDATE = XPROWF-ERTAG
                   IMPORTING
                        WDAT6 = MPROG-PRIOD
                   EXCEPTIONS
                        OTHERS = 01.
           WHEN 'T'.
              CALL FUNCTION 'DATUMSAUFBEREITUNG'
                   EXPORTING
                        IDATE = XPROWF-ERTAG
                   IMPORTING
                        TDAT8 = MPROG-PRIOD
                   EXCEPTIONS
                        OTHERS = 01.
         ENDCASE.
         INSERT MPROG INDEX MINDEX.
         MINDEX = MINDEX + 1.
         ZINDEX = ZINDEX + 1.
         IF ZINDEX GE 3.
            EXIT.
         ENDIF.
      ENDIF.
   ENDLOOP.
*- Leerer Satz, keine Prognose vorhanden ------------------------------*
   IF ZINDEX EQ 0.
      CLEAR MPROG.
      MPROG-MATNR = EBAN-MATNR.
      MPROG-WERKS = EBAN-WERKS.
      INSERT MPROG INDEX MINDEX.
   ENDIF.
ENDIF.

ENDFORM.
