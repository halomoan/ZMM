*eject
*----------------------------------------------------------------------*
*        Aufruf Anzeigen Infosätze                                     *
*----------------------------------------------------------------------*
FORM AUFRUF_INFOSAETZE.

  DATA: H_PSTYP LIKE T163Y-EPSTP.

*- Export Übergabestruktur für Zuordnung ------------------------------*
  CLEAR BUEB.
  BUEB-NRCFD = 'X'.
  IF ( SY-PFKEY EQ 'ZUOR' OR
       SY-PFKEY EQ 'BEAR' ) AND
     T160D-EBZIN NE SPACE.
    BUEB-CALKZ = 'X'.
    IF BAN-MATNR EQ SPACE AND
       T160D-EBZOM EQ SPACE.
      CLEAR BUEB-CALKZ.
    ENDIF.
  ENDIF.
  BUEB-MENGE = BAN-MENGE.              "für Preissimulation
  BUEB-MEINS = BAN-MEINS.
  BUEB-DATUM = BAN-FRGDT.
  EXPORT BUEB TO MEMORY ID 'BUEB'. "#EC CI_FLDEXT_OK[2215424] P30K909996

*- Setzen des Infotyps
  IF BAN-PSTYP EQ PSTYP-LOHN.
    H_PSTYP = PSTYP-LOHN.
  ELSEIF BAN-PSTYP = PSTYP-KONS.
    H_PSTYP = PSTYP-KONS.                 "Konsi 4.0
  ELSE.
    H_PSTYP = PSTYP-LAGM.
  ENDIF.

  IF BAN-MATNR NE SPACE.
*- Aufruf Report: Anzeigen Infosätze zum Material ---------------------*
    RANGES: H_MATERIALS FOR EINA-MATNR.
    CLEAR   H_MATERIALS.
    H_MATERIALS-LOW = BAN-MATNR.
    H_MATERIALS-SIGN = 'I'.
    H_MATERIALS-OPTION = 'EQ'.
    APPEND H_MATERIALS.
    IF BAN-SATNR NE SPACE AND BAN-SATNR NE BAN-MATNR AND
       BAN-ATTYP EQ ATTYP-VAR.
*  auch Infosätze für Sammelartikel der Variante
      H_MATERIALS-LOW = BAN-SATNR.
      H_MATERIALS-SIGN = 'I'.
      H_MATERIALS-OPTION = 'EQ'.
      APPEND H_MATERIALS.
    ENDIF.
    SUBMIT RM06IM00 AND RETURN
           WITH IF_MATNR IN H_MATERIALS"EQ BAN-MATNR
           WITH I_WERKS  EQ BAN-WERKS
           WITH I_ESOKZ  EQ H_PSTYP
           WITH P_RELEV  EQ 'X'.
  ELSE.
*- Aufruf Report: Anzeigen Infosätze zur Materialklasse ---------------*
    SUBMIT RM06IW00 AND RETURN
           WITH IF_MATKL EQ BAN-MATKL
           WITH I_WERKS  EQ BAN-WERKS
           WITH I_ESOKZ  EQ H_PSTYP
           WITH P_RELEV  EQ 'X'.
  ENDIF.

*- Holen Übergabestruktur aus Memory ----------------------------------*
  IMPORT BUEB FROM MEMORY ID 'BUEB'. "#EC CI_FLDEXT_OK[2215424] P30K909996
*- Kein Rahmenvertrag gefunden ----------------------------------------*
  IF BUEB-NRCFD NE SPACE.
    MESSAGE S228.
    EXITFLAG = 'X'.
  ELSE.
    IF BUEB-FLIEF NE SPACE.
*- Festen Lieferanten überprüfen --------------------------------------
      CLEAR SY-UCOMM.                  "nützt leider nichts
      PERFORM BEZUGSQUELLE_1 USING SPACE.
      PERFORM BEZUGSQUELLE_2.
    ENDIF.
  ENDIF.

ENDFORM.
