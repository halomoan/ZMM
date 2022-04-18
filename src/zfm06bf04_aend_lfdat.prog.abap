*----------------------------------------------------------------------*
*        Lieferdatum Ändern                                            *
*----------------------------------------------------------------------*
FORM AEND_LFDAT.

  IF NOT ( RM06B-EEIND IS INITIAL ).                        "H94637
    CALL FUNCTION 'PERIOD_AND_DATE_CONVERT_INPUT'
         EXPORTING
              DIALOG_DATE_IS_IN_THE_PAST = SPACE
              EXTERNAL_DATE              = RM06B-EEIND
              EXTERNAL_PERIOD            = RM06B-LPEIN
         IMPORTING
              INTERNAL_DATE              = EBAN-LFDAT
              INTERNAL_PERIOD            = EBAN-LPEIN.
    IF EBAN-LFDAT NE *EBAN-LFDAT OR
       EBAN-LPEIN NE *EBAN-LPEIN.
      EBAN-LFDAT = *EBAN-LFDAT.
      EBAN-LPEIN = *EBAN-LPEIN.
      PERFORM EBAN-LFDAT(SAPFMMEX) USING RM06B-EEIND RM06B-LPEIN SPACE
                                        T001W
                                        MT06E
                                        *EBAN
                                        AKTYP
                                  CHANGING EBAN RM06B.

      IF *EBAN-ESTKZ EQ 'B' OR *EBAN-ESTKZ EQ 'U'.          "116583
        EBAN-FIXKZ = 'X'.                                   "116583
      ENDIF.                                                "116583
* Anpassung Freigabedatum
      IF EBAN-PLIFZ IS INITIAL.
        DATA: L_MT06E LIKE MT06E,
              L_MTCOM LIKE MTCOM.
        IF EBAN-EMATN IS INITIAL.
          L_MTCOM-MATNR = EBAN-MATNR.
        ELSE.
          L_MTCOM-MATNR = EBAN-EMATN.
        ENDIF.
        L_MTCOM-WERKS = EBAN-WERKS.
        L_MTCOM-SPRAS = SY-LANGU.
        IF EBAN-PSTYP EQ PSTYP-UMLG.
          L_MTCOM-PSTAT = 'D '.
        ELSE.
          L_MTCOM-PSTAT = 'ED'.
        ENDIF.
        L_MTCOM-KZMPN = 'X'.
        CALL FUNCTION 'MATERIAL_READ' "#EC CI_FLDEXT_OK[2215424] P30K909996
             EXPORTING
                  SCHLUESSEL = L_MTCOM
             IMPORTING
                  MATDATEN   = L_MT06E
             EXCEPTIONS
                  OTHERS     = 1.
      ENDIF.
      PERFORM ERMITTELN_FREIGABEDATUM(SAPFMMEX) USING T001W L_MT06E
                                                CHANGING RM06B EBAN.
    ENDIF.
  ENDIF.                                                    "H94637

ENDFORM.
