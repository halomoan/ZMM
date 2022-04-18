*eject
*----------------------------------------------------------------------*
* Zeile: div. Kennzeichen, Positionswert, Freigabedatum ect.           *
*----------------------------------------------------------------------*
FORM BAN_ZEILE_011.

  IF NOT EBAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
*... Bei Gesamtfreigabe werden die Positionen nur ausgegeben, wenn dies
*... im Listumfang explizit angegeben wurde ..........................*
    CHECK NOT T16LB-GSPOS IS INITIAL.
  ENDIF.
*--- Gesamtwert der Position berechnen --------------------------------*
  IF EBAN-PEINH NE 0.
    REFE1 = EBAN-PREIS * EBAN-MENGE / 1000 / EBAN-PEINH.
  ELSE.
    REFE1 = 0.
  ENDIF.
  IF REFE1 LE MAXWERT.
    RM06B-GSWRT = REFE1.
  ELSE.
    RM06B-GSWRT = MAXWERT.
  ENDIF.

  IF EBAN-WERKS NE T001W-WERKS.
    SELECT SINGLE * FROM T001W WHERE WERKS EQ EBAN-WERKS.
  ENDIF.
  IF T001K-BWKEY NE T001W-BWKEY.
    SELECT SINGLE * FROM T001K WHERE BWKEY EQ T001W-BWKEY.
  ENDIF.
  IF T001K-BUKRS NE T001-BUKRS.
    SELECT SINGLE * FROM T001 WHERE BUKRS EQ T001K-BUKRS. "#EC CI_DB_OPERATION_OK[2431747] P30K909996
  ENDIF.

  WRITE: /  SY-VLINE,
          4  EBAN-STATU,
             EBAN-ESTKZ,
             EBAN-FRGKZ,
             EBAN-BSART,
             RM06B-EPSTP,
             EBAN-KNTTP.
  IF NOT ( EBAN-WAERS IS INITIAL ).
    WRITE:   22(17) RM06B-GSWRT CURRENCY EBAN-WAERS NO-SIGN,
             40 EBAN-WAERS.
  ELSE.
    IF NOT BAN-ARCH_DATE IS INITIAL.   "TK 4.0B EURO
* die zum Zeitpunkt der Archivierung gültige Hauswährung besorgen
      DATA: L_WAERS LIKE T001-WAERS.
      CALL FUNCTION 'EWU_GET_CUKEY_ORG'
           EXPORTING
                WAEHRUNGSURSPRUNG   = '10'
                AUSPRAEGUNG         = T001-BUKRS
                GUELTIGKEITSDATUM   = BAN-ARCH_DATE
           IMPORTING
                WAEHRUNGSSCHLUESSEL = L_WAERS
           EXCEPTIONS
                OTHERS              = 1.
      IF SY-SUBRC EQ 0 AND L_WAERS NE SPACE.
        T001-WAERS = L_WAERS.
      ELSE.
*  ??????? da gibt's wohl ein Problem
      ENDIF.
    ENDIF.                             "TK 4.0B EURO
    WRITE:   22(17) RM06B-GSWRT CURRENCY T001-WAERS NO-SIGN,
             40 T001-WAERS.
  ENDIF.
*ENHANCEMENT-SECTION     FM06BFLI_BAN_ZEILE_011_01 SPOTS ES_SAPFM06B.
  WRITE:  46 EBAN-FRGDT DD/MM/YYYY,
             EBAN-BEDNR,
          71 EBAN-RESWK,
             EBAN-DISPO,
          81 SY-VLINE.
*END-ENHANCEMENT-SECTION.
ENDFORM.
