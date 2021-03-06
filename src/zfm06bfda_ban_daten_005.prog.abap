*eject
*----------------------------------------------------------------------*
* Materialbestände
*----------------------------------------------------------------------*
FORM BAN_DATEN_005.

CLEAR MDSTA.
CLEAR MMDSA.
CHECK EBAN-MATNR NE SPACE.
CHECK EBAN-WERKS NE SPACE.

*- Bestände schon gelesen ? -------------------------------------------*
MATKEY-MATNR = EBAN-MATNR.
MATKEY-WERKS = EBAN-WERKS.
READ TABLE MMDSA WITH KEY MATKEY BINARY SEARCH.
MINDEX = SY-TABIX.
MSUBRC = SY-SUBRC.

*- Bestände lesen -----------------------------------------------------*
IF MSUBRC NE 0 OR
   MMDSA-RBSTD EQ SPACE.
   REFRESH XMT61B.
   CLEAR MTCOM.
   MTCOM-KENNG = 'MT61B'.
   MTCOM-MATNR = EBAN-MATNR.
   MTCOM-WERKS = EBAN-WERKS.
   CALL FUNCTION 'MATERIAL_READ' "#EC CI_FLDEXT_OK[2215424] P30K909996
        EXPORTING
             SCHLUESSEL = MTCOM
        IMPORTING
             MATDATEN = MT61B
        TABLES
             SEQMAT01 = XMT61B.
  LOOP AT XMT61B.
     MMDSA-LABST = MMDSA-LABST + XMT61B-LABST.
     MMDSA-EINME = MMDSA-EINME + XMT61B-EINME.
     MMDSA-SPEME = MMDSA-SPEME + XMT61B-SPEME.
*    MMDSA-RETME = MMDSA-RETME + XMT61B-RETME.
     MMDSA-KLABS = MMDSA-KLABS + XMT61B-KLABS.
*    MMDSA-KEINM = MMDSA-KEINM + XMT61B-KEINM.
*    MMDSA-KSPEM = MMDSA-KSPEM + XMT61B-KSPEM.
     MMDSA-INSME = MMDSA-INSME + XMT61B-INSME.
     MMDSA-KINSM = MMDSA-KINSM + XMT61B-KINSM.
  ENDLOOP.
  MMDSA-SUM01 = MMDSA-LABST + MMDSA-KLABS.
  MMDSA-MATNR = EBAN-MATNR.
  MMDSA-WERKS = EBAN-WERKS.
  MMDSA-RBSTD = 'X'.
  IF MSUBRC EQ 0.
     MODIFY MMDSA INDEX MINDEX.
  ELSE.
     INSERT MMDSA INDEX MINDEX.
  ENDIF.
ENDIF.
MOVE-CORRESPONDING MMDSA TO MDSTA.

ENDFORM.
