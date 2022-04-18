*eject
*----------------------------------------------------------------------*
* Infosatz/Rahmenvertrag lesen
*----------------------------------------------------------------------*
FORM BAN_DATEN_003.

CLEAR: EINA, EINE.
CLEAR: EKKO, EKPO.
IF EBAN-INFNR NE SPACE.
   MEICO-INFNR = EBAN-INFNR.
   MEICO-EKORG = EBAN-EKORG.
   MEICO-WERKS = EBAN-WERKS.
   IF EBAN-PSTYP EQ PSTYP-LOHN.
      MEICO-ESOKZ = EBAN-PSTYP.
   ELSEIF EBAN-PSTYP EQ PSTYP-KONS.                       "172737
      MEICO-ESOKZ = EBAN-PSTYP.                           "172737
   ELSE.                                                  "172737
      MEICO-ESOKZ = PSTYP-LAGM.                           "172737
   ENDIF.
   CALL FUNCTION 'ME_READ_INFORECORD'
        EXPORTING
             INCOM = MEICO
*         INPREISSIM = E02
        IMPORTING
*         DATEN = I01
             EINADATEN = EINA
             EINEDATEN = EINE
*         EXCOM = I04
*         EXPREISSIM = I05
        EXCEPTIONS
             OTHERS = 01.
ELSE.
   IF EBAN-KONNR NE SPACE.
      SELECT SINGLE * FROM EKKO WHERE EBELN EQ EBAN-KONNR.
      SELECT SINGLE * FROM EKPO WHERE EBELN EQ EBAN-KONNR
                                  AND EBELP EQ EBAN-KTPNR.
   ENDIF.
ENDIF.

ENDFORM.
