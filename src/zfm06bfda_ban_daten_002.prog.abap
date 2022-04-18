*eject
*----------------------------------------------------------------------*
* Lieferantenstamm lesen
*----------------------------------------------------------------------*
FORM BAN_DATEN_002.
CLEAR: LFA1, LFM1.
CHECK EBAN-FLIEF NE SPACE.
SELECT SINGLE * FROM LFA1 WHERE LIFNR EQ EBAN-FLIEF.
CHECK EBAN-EKORG NE SPACE.
* Beginn \BE
*SELECT SINGLE * FROM LFM1 WHERE LIFNR EQ EBAN-FLIEF
*                            AND EKORG EQ EBAN-EKORG.
CALL FUNCTION 'VENDOR_MASTER_DATA_SELECT_12'
     EXPORTING
          PI_LIFNR       =  EBAN-FLIEF
          PI_EKORG       =  EBAN-EKORG
     IMPORTING
          PE_LFM1        =  LFM1
*         PE_EKORZ       =
     EXCEPTIONS
          NO_ENTRY_FOUND = 1
          OTHERS         = 2.
* Ende \BE

ENDFORM.
