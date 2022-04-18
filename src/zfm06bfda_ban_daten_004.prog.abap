*eject
*----------------------------------------------------------------------*
* Materialverbräuche
*----------------------------------------------------------------------*
FORM BAN_DATEN_004.

CLEAR VINDEX.
CHECK EBAN-MATNR NE SPACE.
CHECK EBAN-WERKS NE SPACE.

*- Verbräuche schon gelesen ? -----------------------------------------*
MATKEY-MATNR = EBAN-MATNR.
MATKEY-WERKS = EBAN-WERKS.
READ TABLE MVERB WITH KEY MATKEY BINARY SEARCH.
MINDEX = SY-TABIX.
VINDEX = SY-TABIX.
IF SY-SUBRC NE 0.
*- Materialstamm nachlesen --------------------------------------------*
   IF MT61D-MATNR NE EBAN-MATNR OR
      MT61D-WERKS NE EBAN-WERKS.
      PERFORM BAN_DATEN_001.
   ENDIF.
   REFRESH GVERB.
   CALL FUNCTION 'VERBRAUCH_LESEN'
        EXPORTING
*         ABDATUM                  = '19000101'
             ANZAHL                   = 4
*         BISDATUM                 = SY-DATUM
*         FLAG_MATSTAMM            = ' '
*         KZGEK                    = ' '
             KZGES                    = 'X'
*         KZUNG                    = ' '
*         KZUNK                    = ' '
             MATNR                    = EBAN-MATNR
             PERIV                    = MT61D-PERIV
             PERKZ                    = MT61D-PERKZ
             WERKS                    = EBAN-WERKS
        TABLES
             GES_VERB                 = GVERB
             GES_VERB_KOR             = XVERB
             UNG_VERB                 = XVERB
             UNG_VERB_KOR             = XVERB
        EXCEPTIONS
             OTHERS = 01.
   CLEAR MVERB.
   MVERB-MATNR = EBAN-MATNR.
   MVERB-WERKS = EBAN-WERKS.
   IF SY-SUBRC EQ 0.
      LOOP AT GVERB.
         CHECK SY-TABIX LE 4.
         MOVE-CORRESPONDING GVERB TO MVERB.
         INSERT MVERB INDEX MINDEX.
         MINDEX = MINDEX + 1.
      ENDLOOP.
   ELSE.
      INSERT MVERB INDEX VINDEX.
   ENDIF.

ENDIF.

ENDFORM.
