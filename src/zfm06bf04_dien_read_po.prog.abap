*&---------------------------------------------------------------------*
*&      Form  DIEN_READ_PO
*&---------------------------------------------------------------------*
*       Bestellung lesen/pruefen/sperren fuer Erstellen ErfBlatt
*----------------------------------------------------------------------*
FORM DIEN_READ_PO USING I_EBELN I_EBELP.

* Bestellung lesen
  SELECT SINGLE * FROM EKKO WHERE EBELN EQ I_EBELN.
  IF SY-SUBRC NE 0 or ekko-memory ne space or ekko-loekz ne space.
    MESSAGE E505(SE) WITH EKKO-EBELN.
  ENDIF.

* Pruefen ob noch freizugeben
  IF EKKO-FRGRL NE SPACE.
    SELECT SINGLE * FROM T160M WHERE MSGVS = '00'
                               AND   ARBGB = 'SE'
                               AND   MSGNR = '529'.
    IF SY-SUBRC = 0 AND
       T160M-MSGTP = 'E'.
      MESSAGE E529(SE).
    ENDIF.
  ENDIF.

* Bestellposition lesen
  IF EKPO-EBELN NE I_EBELN OR
     EKPO-EBELP NE I_EBELP.
    SELECT SINGLE * FROM EKPO
           WHERE EBELN EQ I_EBELN
           AND   EBELP EQ I_EBELP
           AND   PSTYP EQ '9'
           AND   LOEKZ EQ SPACE.
    IF SY-SUBRC NE 0.
      MESSAGE E506(SE).
    ENDIF.
  ENDIF.

* Bestellung sperren
  CALL FUNCTION 'MM_ENQUEUE_DOCUMENT'
       EXPORTING
            I_EBELN = I_EBELN
            I_BSTYP = BSTYP-BEST.

ENDFORM.                               " DIEN_READ_PO
