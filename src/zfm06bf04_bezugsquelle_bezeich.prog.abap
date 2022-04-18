*eject
*---------------------------------------------------------------------*
*  Lieferantenname und Bezeichnung Ekorg lesen                        *
*---------------------------------------------------------------------*
FORM BEZUGSQUELLE_BEZEICHN.

  CLEAR: LFA1, T024E.
*- Lieferantennummer ins richtige Format bringen ---------------------*
  IF EBAN-FLIEF NE SPACE.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
         EXPORTING
              INPUT  = EBAN-FLIEF
         IMPORTING
              OUTPUT = EBAN-FLIEF.
*- Lieferantennamen besorgen -----------------------------------------*
* ALRK021854 begin insert
    CALL FUNCTION 'WY_LFA1_GET_NAME'
         EXPORTING
              PI_LIFNR         = EBAN-FLIEF
         IMPORTING
              PO_NAME1         = LFA1-NAME1
         EXCEPTIONS
              NO_RECORDS_FOUND = 1
              OTHERS           = 2.
* ALRK021854 end insert - begin delete
*  call function 'ME_GET_SUPPLIER'
*       exporting
*            supplier = eban-flief
*       importing
*            name = lfa1-name1.
* ALRK021854 end delete
  ENDIF.

*- Bezeichnung Einkaufsorganisation lesen ----------------------------*
  IF EBAN-EKORG NE SPACE.
    SELECT SINGLE * FROM T024E WHERE EKORG EQ EBAN-EKORG.
  ENDIF.

ENDFORM.
