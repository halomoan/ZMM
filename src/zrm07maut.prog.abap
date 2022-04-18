*---- Datenfelder für Authority Check --------------------------------*
DATA: ACTVT      LIKE TACT-ACTVT,      " Aktivitaet
      AUTH02     TYPE C,               " Berechtigung 02 Ändern
      AUTH03     TYPE C,               " Berechtigung 03 Anzeigen
      AUTH04     TYPE C,               " Berechtigung 04 Drucken
      AUTH06     TYPE C,               " Berechtigung 06 Löschen
      AUTH65     TYPE C,               " Berechtigung 65 Reorganisieren
      AUTH70     TYPE C,               " Berechtigung 70 Verwalten
      NO_CHANCE  TYPE C.               " Keine Berechtigung

DATA: VGART-WE   LIKE T158-VGART VALUE 'WE'.

*---------------------------------------------------------------------*
*       FORM BEWEGUNGSART_RS                                          *
*---------------------------------------------------------------------*
*       Prüfen Bewegungsartenberechtigung bei Reservierungen.         *
*---------------------------------------------------------------------*
FORM BEWEGUNGSART_RS USING A-ACTVT
                           A-BWART.

  AUTHORITY-CHECK OBJECT 'M_MRES_BWA'
                  ID 'ACTVT' FIELD A-ACTVT
                  ID 'BWART' FIELD A-BWART.
  CASE A-ACTVT.
    WHEN '02'.
      IF NOT SY-SUBRC IS INITIAL.
        AUTH02 = X.
      ENDIF.
    WHEN '03'.
      IF NOT SY-SUBRC IS INITIAL.
        AUTH03 = X.
      ENDIF.
    WHEN '06'.
      IF NOT SY-SUBRC IS INITIAL.
        AUTH06 = X.
      ENDIF.
    WHEN '65'.
      IF NOT SY-SUBRC IS INITIAL.
        AUTH65 = X.
      ENDIF.
    WHEN '70'.
      IF NOT SY-SUBRC IS INITIAL.
        AUTH70 = X.
      ENDIF.
  ENDCASE.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM BEWEGUNGSART_WA                                          *
*---------------------------------------------------------------------*
*       Prüfen Bewegungsartenberechtigung bei WA-Belegen.             *
*---------------------------------------------------------------------*
FORM BEWEGUNGSART_WA USING A-ACTVT
                           A-BWART.
  AUTHORITY-CHECK OBJECT 'M_MSEG_BWA'
                  ID 'ACTVT' FIELD A-ACTVT
                  ID 'BWART' FIELD A-BWART.
  IF NOT SY-SUBRC IS INITIAL.
    AUTH03 = X.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM BEWEGUNGSART_WA_DRUCK                                    *
*---------------------------------------------------------------------*
*       Prüfen Druckberechtigung für Bewegungsart bei WA-Belegen.     *
*---------------------------------------------------------------------*
FORM BEWEGUNGSART_WA_DRUCK USING A-ACTVT
                                 A-BWART.
  AUTHORITY-CHECK OBJECT 'M_MSEG_BWA'
                  ID 'ACTVT' FIELD A-ACTVT
                  ID 'BWART' FIELD A-BWART.
  IF NOT SY-SUBRC IS INITIAL.
    AUTH04 = X.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM BEWEGUNGSART_WE                                          *
*---------------------------------------------------------------------*
*       Prüfen Bewegungsartenberechtigung bei WE-Belegen.             *
*---------------------------------------------------------------------*
FORM BEWEGUNGSART_WE USING A-ACTVT
                           A-BWART.
  AUTHORITY-CHECK OBJECT 'M_MSEG_BWE'
                  ID 'ACTVT' FIELD A-ACTVT
                  ID 'BWART' FIELD A-BWART.
  IF NOT SY-SUBRC IS INITIAL.
    AUTH03 = X.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM BEWEGUNGSART_WE_DRUCK                                    *
*---------------------------------------------------------------------*
*       Prüfen Druckberechtigung für Bewegungsart bei WE-Belegen.     *
*---------------------------------------------------------------------*
FORM BEWEGUNGSART_WE_DRUCK USING A-ACTVT
                                 A-BWART.
  AUTHORITY-CHECK OBJECT 'M_MSEG_BWE'
                  ID 'ACTVT' FIELD ACTVT04
                  ID 'BWART' FIELD A-BWART.
  IF NOT SY-SUBRC IS INITIAL.
    AUTH04 = X.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM BKPF_BLA                                                 *
*---------------------------------------------------------------------*
*       Prüfen Berechtigung Belegart                                  *
*---------------------------------------------------------------------*
FORM BKPF_BLA USING A-ACTVT
                    BRGRU.
  CHECK NOT BRGRU IS INITIAL.
  AUTHORITY-CHECK OBJECT 'F_BKPF_BLA'
                  ID 'ACTVT' FIELD A-ACTVT
                  ID 'BRGRU' FIELD BRGRU.
  IF NOT SY-SUBRC IS INITIAL.
    AUTH03 = X.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM BKPF_BUK                                                 *
*---------------------------------------------------------------------*
*       Prüfen Berechtigung Buchungskreis                             *
*---------------------------------------------------------------------*
FORM BKPF_BUK USING A-ACTVT
                    BUKRS.
  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
                  ID 'ACTVT' FIELD A-ACTVT
                  ID 'BUKRS' FIELD BUKRS.
  IF NOT SY-SUBRC IS INITIAL.
    AUTH03 = X.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM INVENTUR_DB                                              *
*---------------------------------------------------------------------*
*       Prüfen Berechtigung zum anzeigen der Differenzenliste.         *
*       - RM07IDIF                                                    *
*---------------------------------------------------------------------*
FORM INVENTUR_DB USING A-ACTVT
                       A-WERKS.
  AUTHORITY-CHECK OBJECT 'M_ISEG_WDB'
                  ID 'ACTVT' FIELD A-ACTVT
                  ID 'WERKS' FIELD A-WERKS.
  IF NOT SY-SUBRC IS INITIAL.
    AUTH03 = X.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM INVENTUR_DB_DRUCK                                        *
*---------------------------------------------------------------------*
*       Prüfen Berechtigung zum Drucken der Differenzenliste.         *
*       - RM07IDIF                                                    *
*---------------------------------------------------------------------*
FORM INVENTUR_DB_DRUCK USING A-ACTVT
                             A-WERKS.
  AUTHORITY-CHECK OBJECT 'M_ISEG_WDB'
                  ID 'ACTVT' FIELD A-ACTVT
                  ID 'WERKS' FIELD A-WERKS.
  IF NOT SY-SUBRC IS INITIAL.
    AUTH04 = X.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM INVENTUR_IB                                              *
*---------------------------------------------------------------------*
*       Prüfen Berechtigung zum anzeigen von Inventurbelegen.         *
*       - RM07IMAT                                                    *
*---------------------------------------------------------------------*
FORM INVENTUR_IB USING A-ACTVT
                       A-WERKS.
  AUTHORITY-CHECK OBJECT 'M_ISEG_WIB'
                  ID 'ACTVT' FIELD A-ACTVT
                  ID 'WERKS' FIELD A-WERKS.
  IF NOT SY-SUBRC IS INITIAL.
    AUTH03 = X.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM INVENTUR_IB_DRUCK                                        *
*---------------------------------------------------------------------*
*       Prüfen Berechtigung zum Drucken von Inventurbelegen.          *
*       - RM07IDRU                                                    *
*---------------------------------------------------------------------*
FORM INVENTUR_IB_DRUCK USING A-ACTVT
                             A-WERKS.
  AUTHORITY-CHECK OBJECT 'M_ISEG_WIB'
                  ID 'ACTVT' FIELD A-ACTVT
                  ID 'WERKS' FIELD A-WERKS.
  IF NOT SY-SUBRC IS INITIAL.
    AUTH04 = X.
  ENDIF.
ENDFORM.
*---------------------------------------------------------------------*
*       FORM WERK_MAT                                                 *
*---------------------------------------------------------------------*
*       Prüfen Werksberechtigung bei Bestandsanzeige                  *
*---------------------------------------------------------------------*
FORM WERK_MAT USING A-ACTVT
                   A-WERKS.
  AUTHORITY-CHECK OBJECT 'M_MATE_WRK'
                  ID 'ACTVT' FIELD A-ACTVT
                  ID 'WERKS' FIELD A-WERKS.
  IF NOT SY-SUBRC IS INITIAL.
    AUTH03 = X.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM WERK_MB                                                  *
*---------------------------------------------------------------------*
*       Prüfen Werksberechtigung bei Materialbelegen                  *
*---------------------------------------------------------------------*
FORM WERK_MB USING A-ACTVT
                   A-WERKS.
  AUTHORITY-CHECK OBJECT 'M_MSEG_WMB'
                  ID 'ACTVT' FIELD A-ACTVT
                  ID 'WERKS' FIELD A-WERKS.
  IF NOT SY-SUBRC IS INITIAL.
    AUTH03 = X.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM WERK_RS                                                  *
*---------------------------------------------------------------------*
*       Prüfen Werksberechtigung bei Reservierungen.                  *
*---------------------------------------------------------------------*
FORM WERK_RS USING A-ACTVT
                   A-WERKS.
  AUTHORITY-CHECK OBJECT 'M_MRES_WWA'
                  ID 'ACTVT' FIELD A-ACTVT
                  ID 'WERKS' FIELD A-WERKS.
  CASE A-ACTVT.
    WHEN '02'.
      IF NOT SY-SUBRC IS INITIAL.
        AUTH02 = X.
      ENDIF.
    WHEN '03'.
      IF NOT SY-SUBRC IS INITIAL.
        AUTH03 = X.
      ENDIF.
    WHEN '06'.
      IF NOT SY-SUBRC IS INITIAL.
        AUTH06 = X.
      ENDIF.
    WHEN '65'.
      IF NOT SY-SUBRC IS INITIAL.
        AUTH65 = X.
      ENDIF.
    WHEN '70'.
      IF NOT SY-SUBRC IS INITIAL.
        AUTH70 = X.
      ENDIF.
  ENDCASE.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM WERK_WA                                                  *
*---------------------------------------------------------------------*
*       Prüfen Werksberechtigung bei WA-Belegen.                      *
*---------------------------------------------------------------------*
FORM WERK_WA USING A-ACTVT
                   A-WERKS.
  AUTHORITY-CHECK OBJECT 'M_MSEG_WWA'
                  ID 'ACTVT' FIELD A-ACTVT
                  ID 'WERKS' FIELD A-WERKS.
  IF NOT SY-SUBRC IS INITIAL.
    AUTH03 = X.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM WERK_WA_DRUCK                                            *
*---------------------------------------------------------------------*
*       Prüfen Werksberechtigung bei WA-Belegen.                      *
*---------------------------------------------------------------------*
FORM WERK_WA_DRUCK USING A-ACTVT
                         A-WERKS.
  AUTHORITY-CHECK OBJECT 'M_MSEG_WWA'
                  ID 'ACTVT' FIELD A-ACTVT
                  ID 'WERKS' FIELD A-WERKS.
  IF NOT SY-SUBRC IS INITIAL.
    AUTH04 = X.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM WERK_WE                                                  *
*---------------------------------------------------------------------*
*       Prüfen Werksberechtigung bei WE-Belegen.                      *
*---------------------------------------------------------------------*
FORM WERK_WE USING A-ACTVT
                   A-WERKS.
  AUTHORITY-CHECK OBJECT 'M_MSEG_WWE'
                  ID 'ACTVT' FIELD A-ACTVT
                  ID 'WERKS' FIELD A-WERKS.
  IF NOT SY-SUBRC IS INITIAL.
    AUTH03 = X.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM WERK_WE_DRUCK                                            *
*---------------------------------------------------------------------*
*       Prüfen Druckberechtigung bei WE-Belegen.                      *
*---------------------------------------------------------------------*
FORM WERK_WE_DRUCK USING A-ACTVT
                         A-WERKS.
  AUTHORITY-CHECK OBJECT 'M_MSEG_WWE'
                  ID 'ACTVT' FIELD A-ACTVT
                  ID 'WERKS' FIELD A-WERKS.
  IF NOT SY-SUBRC IS INITIAL.
    AUTH04 = X.
  ENDIF.
ENDFORM.
*eject
