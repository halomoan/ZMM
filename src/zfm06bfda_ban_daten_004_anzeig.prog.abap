*eject
*----------------------------------------------------------------------*
* Verbräuche anzeigen
*----------------------------------------------------------------------*
FORM BAN_DATEN_004_ANZEIGEN.

IF VINDEX EQ 0.
   EXIT FROM STEP-LOOP.
ENDIF.
READ TABLE MVERB INDEX VINDEX.
   IF SY-SUBRC NE 0 OR
      MVERB-MATNR NE EBAN-MATNR OR
      MVERB-WERKS NE EBAN-WERKS OR
      MVERB-PRIOD EQ SPACE.
      CLEAR IVERB.
      EXIT FROM STEP-LOOP.
   ELSE.
      MOVE-CORRESPONDING MVERB TO IVERB.
      MOVE MT61D-PERKZ TO MAPRF-PERKZ.
      VINDEX = VINDEX + 1.
   ENDIF.
ENDFORM.
