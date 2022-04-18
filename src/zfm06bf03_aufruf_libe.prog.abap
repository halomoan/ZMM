*eject
*----------------------------------------------------------------------*
*     Aufruf der Lieferantenbeurteilung
*----------------------------------------------------------------------*
FORM AUFRUF_LIBE.
  CHECK EXITFLAG EQ SPACE.
  CLEAR EXITFLAG.
*- Export Übergabestruktur für Zuordnung ------------------------------*
  CLEAR BUEB.
  BUEB-NRCFD = 'X'.
  IF ( SY-PFKEY EQ 'ZUOR' OR
       SY-PFKEY EQ 'BEAR' ) AND
     T160D-EBZIN NE SPACE.
    BUEB-CALKZ = 'X'.
  ENDIF.
  SET PARAMETER ID 'EKO' FIELD LIBE_EKO-EKORG.
  EXPORT BUEB TO MEMORY ID 'BUEB'. "#EC CI_FLDEXT_OK[2215424] P30K909996
  IF BAN-MATNR NE SPACE.
*- Aufruf Report: Anzeigen Lieferantenbeurteilungen zum Material ------*
    SUBMIT RM06LB00 AND RETURN
           WITH P_EKORG EQ LIBE_EKO-EKORG
           WITH P_MATNR EQ BAN-MATNR
           WITH P_LISUM EQ SPACE.
  ELSE.
*- Aufruf Report: Anzeigen Lieferantenbeurteilungen zur Materialklasse
    SUBMIT RM06LB00 AND RETURN
           WITH P_EKORG EQ LIBE_EKO-EKORG
           WITH P_MATKL EQ BAN-MATKL
           WITH P_LISUM EQ SPACE.
  ENDIF.
*- Holen Übergabestruktur aus Memory ----------------------------------*
  IMPORT BUEB FROM MEMORY ID 'BUEB'. "#EC CI_FLDEXT_OK[2215424] P30K909996
*- Keine Beurteilung gefunden  ----------------------------------------*
  IF BUEB-NRCFD NE SPACE.
    MESSAGE ID 'ML' TYPE 'E' NUMBER '053'.
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
