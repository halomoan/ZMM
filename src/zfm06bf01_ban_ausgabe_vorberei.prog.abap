************************************************************************
*        Unterroutinen Listanzeige Banf                                *
************************************************************************
*  82362  3.1I  10.10.1997  CF
*  91102        17.12.1997  SM ME56 nicht batchinputfähig
*eject
*----------------------------------------------------------------------*
*        Felder für BAN-Ausgabe vorbereiten                            *
*----------------------------------------------------------------------*
FORM BAN_AUSGABE_VORBEREITEN USING BAV_LFLAG.

*- Zusätzliche Daten bereitstellen ------------------------------------*
  PERFORM BAN_DATEN USING BAV_LFLAG.

*- Datum in Ausgabeformat bringen -------------------------------------*
  CALL FUNCTION 'PERIOD_AND_DATE_CONVERT_OUTPUT'
       EXPORTING
            INTERNAL_DATE   = EBAN-LFDAT
            INTERNAL_PERIOD = EBAN-LPEIN
       IMPORTING
            EXTERNAL_DATE   = RM06B-EEIND
            EXTERNAL_PERIOD = RM06B-LPEIN.

*- Positionstyp in Ausgabeformat bringen ------------------------------*
  CALL FUNCTION 'ME_ITEM_CATEGORY_OUTPUT'
       EXPORTING
            PSTYP = EBAN-PSTYP
       IMPORTING
            EPSTP = RM06B-EPSTP.
*- Zuordnungsinformation ----------------------------------------------*
  IF XZLTYP NE SPACE.
    PERFORM BAN_ZUORD USING SPACE.
  ENDIF.
ENDFORM.
