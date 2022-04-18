************************************************************************
*   Unterroutinen für die interaktive Bearbeitung der Grundliste       *
************************************************************************
* 17.12.97 SM H91102  ME56 nicht batchinputfähig
* 12.01.98 SM H92315  call transaction
* 24.02.98 SM H96482  Änderungen aus Einzelfreigabe
* 96597 25.02.98 40B PH Warengruppe wurde initialisiert nach Zuordnung
*eject
*----------------------------------------------------------------------*
*        Aufruf Anzeigen Änderungen                                    *
*----------------------------------------------------------------------*
FORM AUFRUF_AENDERUNGEN.

*- Zurücksetzen Änderungstabellen -------------------------------------*
  REFRESH: ICDHDR, AUSG, EDIT.
  CLEAR:   ICDHDR, AUSG, EDIT.

*- DCM  call ALV list
  IF NOT GS_BANF IS INITIAL AND
     NOT BAN-GSFRG IS INITIAL AND
     NOT HIDE-GSFRG IS INITIAL.
*...Bei Gesamtbanf alle Änderungen zur Banf anzeigen, falls die .....*
*...'Kopfzeile' selektiert wurde ....................................*
    CALL FUNCTION 'ME_CHANGEDOC_SHOW'
      EXPORTING
        i_document_category = 'B'
        i_document_number   = ban-banfn
        I_ALL_ITEMS         = 'X'.
  ELSE.
    CALL FUNCTION 'ME_CHANGEDOC_SHOW'
      EXPORTING
        i_document_category = 'B'
        i_document_number   = ban-banfn
        i_document_item     = ban-bnfpo.
  ENDIF.

ENDFORM.                    "AUFRUF_AENDERUNGEN
