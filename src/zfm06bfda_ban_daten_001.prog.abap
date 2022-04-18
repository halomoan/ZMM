*eject
*----------------------------------------------------------------------*
* Materialstamm mit View MT61D lesen
*----------------------------------------------------------------------*
FORM BAN_DATEN_001.

IF EBAN-MATNR EQ SPACE OR
   EBAN-WERKS EQ SPACE.
   CLEAR MT61D.
   EXIT.
ENDIF.
IF EBAN-MATNR NE MT61D-MATNR OR
   EBAN-WERKS NE MT61D-WERKS.
   CLEAR MT61D.
   CLEAR MTCOM.
   MTCOM-KENNG = 'MT61D'.
   MTCOM-NOVOR = 'X'.
   MTCOM-MATNR = EBAN-MATNR.
   MTCOM-WERKS = EBAN-WERKS.
   CALL FUNCTION 'MATERIAL_READ' "#EC CI_FLDEXT_OK[2215424] P30K909996
        EXPORTING
             SCHLUESSEL = MTCOM
        IMPORTING
             MATDATEN = MT61D
        TABLES
             SEQMAT01 = KON.
ENDIF.

ENDFORM.
