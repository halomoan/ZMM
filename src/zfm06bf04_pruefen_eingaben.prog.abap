*eject
*----------------------------------------------------------------------*
*        Eingaben auf POP-UPs prüfen                                   *
*----------------------------------------------------------------------*
FORM PRUEFEN_EINGABEN.

  DATA: I_T024 LIKE T024.

  CASE SY-DYNGR.
*- POP-UP: Generieren Bestellung --------------------------------------*
    WHEN 'POPF'.
*- Prüfen Bestellart --------------------------------------------------*
      EKKO-BSTYP = 'F'.
*     PERFORM BSART(SAPFMMEX) USING RM06E-BSART EKKO-BSTYP EKKO-BSAKZ
*                             CHANGING T161 T161T.

      CALL FUNCTION 'MEXF_BSART'
           EXPORTING
                I_BSART = RM06E-BSART
                I_BSTYP = EKKO-BSTYP
           IMPORTING
                E_BSAKZ = EKKO-BSAKZ
                E_T161  = T161
                E_T161T = T161T
           EXCEPTIONS
                OTHERS  = 1.

*- Prüfen Bestelldatum ------------------------------------------------*
      IF RM06E-BEDAT NE 0.
        IF RM06E-BEDAT < SY-DATLO.
          MESSAGE W214.
        ENDIF.
      ELSE.
        MESSAGE E220.
      ENDIF.
*- Prüfen externe Nummer ----------------------------------------------*
      IF RM06E-BSTNR NE SPACE.
        PERFORM PRUEFEN_NUMMER(SAPFMMEX) USING RM06E-BSTNR SPACE T161.
      ENDIF.

*- POP-UP: Generieren Anfrage -----------------------------------------*
    WHEN 'POPA'.
*- Prüfen Anfrageart --------------------------------------------------*
      EKKO-BSTYP = 'A'.
*     PERFORM BSART(SAPFMMEX) USING RM06E-ASART EKKO-BSTYP EKKO-BSAKZ
*                             CHANGING T161 T161T.
      CALL FUNCTION 'MEXF_BSART'
           EXPORTING
                I_BSART = RM06E-ASART
                I_BSTYP = EKKO-BSTYP
           IMPORTING
                E_BSAKZ = EKKO-BSAKZ
                E_T161  = T161
                E_T161T = T161T
           EXCEPTIONS
                OTHERS  = 1.
*- Prüfen Anfragedatum ------------------------------------------------*
      IF RM06E-ANFDT NE 0.
        IF RM06E-ANFDT < SY-DATLO.
          MESSAGE W216.
        ENDIF.
      ELSE.
        MESSAGE E219.
      ENDIF.
*- Prüfen Angebotsdatum -----------------------------------------------*
      IF EKKO-ANGDT < SY-DATLO.
        MESSAGE W215.
      ENDIF.
*- Prüfen externe Anfragenummer ---------------------------------------*
      IF RM06E-ANFNR NE SPACE.
        PERFORM PRUEFEN_NUMMER(SAPFMMEX) USING RM06E-ANFNR SPACE T161.
      ENDIF.
*- Prüfen Sprache - Fremdschlüssel noch nicht aktiviert ---------------*
      SELECT SINGLE * FROM T002 WHERE SPRAS EQ RM06E-SPRAS.
      IF SY-SUBRC NE 0.
        MESSAGE E221.                  "WITH RM06E-SPRAS.
      ENDIF.
*- Prüfen Lieferant ---------------------------------------------------*
      IF EKKO-LIFNR NE SPACE.
        DATA: LS_LFM1 LIKE LFM1,
              LS_LFA1 LIKE LFA1.                                "682995
        CALL FUNCTION 'VENDOR_MASTER_DATA_SELECT_00'
             EXPORTING
                  I_LFA1_LIFNR               = EKKO-LIFNR
                  I_LFM1_EKORG               = EKKO-EKORG
                  I_DATA                     = 'X'
             IMPORTING
                  A_LFA1                     = ls_lfa1           "682995
                  A_LFM1                     = ls_lfm1
             EXCEPTIONS
                  VENDOR_NOT_FOUND           = 01
                  OTHERS                     = 02.
*      PERFORM LFM1_LESEN(SAPFMMEX) USING EKKO-LIFNR EKKO-EKORG
*                                   CHANGING *LFM1.
        IF SY-SUBRC NE 0.
          MESSAGE E321(06) WITH EKKO-LIFNR EKKO-EKORG.
        ENDIF.
*         Supplier blocked or deleted: Same behaviuor like with ME41
        IF LS_LFA1-SPERM NE SPACE.                              "682995
          MESSAGE E022 WITH LS_LFA1-LIFNR.
        Endif.
        IF LS_LFA1-lOEVM NE SPACE.
          PERFORM ENACO(SAPFMMEX) USING 'ME' '024'.
          CASE SY-SUBRC.
          WHEN 1.
            MESSAGE W024 WITH LS_LFA1-LIFNR.
          WHEN 2.
            MESSAGE E024 WITH LS_LFA1-LIFNR.
          ENDCASE.
        ENDIF.
        IF LS_LFM1-SPERM NE SPACE.
          MESSAGE E023 WITH LS_LFM1-LIFNR LS_LFM1-EKORG.
        ENDIF.
        IF LS_LFM1-lOEVM NE SPACE.
          PERFORM ENACO(SAPFMMEX) USING 'ME' '025'.
          CASE SY-SUBRC.
          WHEN 1.
            MESSAGE W025 WITH LS_LFM1-LIFNR LS_LFM1-EKORG.
          WHEN 2.
            MESSAGE E025 WITH LS_LFM1-LIFNR LS_LFM1-EKORG.
          ENDCASE.

        ENDIF.                                                  "682995

        IF EKKO-LIFNR NE LS_LFM1-LIFNR.
          CLEAR LS_LFM1.
          MESSAGE E027(06) WITH EKKO-LIFNR EKKO-EKORG.
        ENDIF.
      ENDIF.
  ENDCASE.

*- Prüfen Einkaufsgruppe ----------------------------------------------*
  PERFORM EKGRP(SAPFMMEX) USING EKKO-EKGRP
                          CHANGING I_T024.
*- Prüfen Einkaufsorganisation ----------------------------------------*
  PERFORM EKORG_CHECK(SAPFMMEX) USING EKKO-EKORG
                                CHANGING T024E.

ENDFORM.
