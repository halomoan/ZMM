*eject
*----------------------------------------------------------------------*
* Prognosedaten anzeigen
*----------------------------------------------------------------------*
FORM BAN_DATEN_009_ANZEIGEN.

IF PINDEX EQ 0.
   EXIT FROM STEP-LOOP.
ENDIF.
READ TABLE MPROG INDEX PINDEX.
   IF SY-SUBRC NE 0 OR
      MPROG-MATNR NE EBAN-MATNR OR
      MPROG-WERKS NE EBAN-WERKS OR
      MPROG-PRIOD EQ SPACE.
      CLEAR MPROG.
      EXIT FROM STEP-LOOP.
   ELSE.
      MOVE-CORRESPONDING MPROG TO PROWF.
      MOVE MPROG-PRIOD TO *IVERB-PRIOD.
      MOVE MT61D-PERKZ TO *MAPRF-PERKZ.
      PINDEX = PINDEX + 1.
   ENDIF.
ENDFORM.
