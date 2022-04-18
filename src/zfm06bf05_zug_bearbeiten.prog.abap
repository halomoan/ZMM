*eject
*----------------------------------------------------------------------*
*    Bearbeiten Zuordnung
*----------------------------------------------------------------------*
FORM ZUG_BEARBEITEN.

  DATA: lf_dirty LIKE sy-subrc.
*-- Fuellen Banf-Übergabetabelle --------------------------------------*
  PERFORM bat_aufbauen CHANGING lf_dirty.
  IF NOT lf_dirty IS INITIAL.
    MESSAGE i688(me).
    EXIT.
  ENDIF.
READ TABLE BAT INDEX 1.
IF SY-SUBRC NE 0.
   MESSAGE I204.
   EXIT.
ENDIF.

*-- Banfs bearbeiten --------------------------------------------------*
CASE ZUG-UPDKZ.
*-- Generieren Anfragen ohne Lieferant --------------------------------*
   WHEN ANFR.
      CLEAR EKKO-LIFNR.
      PERFORM GENERIEREN_ANFRAGE.
*-- Generieren Anfragen mit Lieferant ---------------------------------*
   WHEN ALIF.
      EKKO-LIFNR = BAN-SLIEF.
      PERFORM GENERIEREN_ANFRAGE.
*-- Bestellung/Lieferplaneinteilung/Erfassungsblatt -------------------*
   WHEN ZOLD.
*-- Kontrakt sperren, falls im Spiel ----------------------------------*
*     IF BAT-KONNR NE SPACE AND BAT-VRTYP EQ 'K'.
*        PERFORM SPERREN_EKKO(SAPFMMEX) USING BAT-KONNR 'K' SPACE.
*        XENQUEUE = 'X'.
*     ENDIF.
      IF BAT-VRTYP NE 'L'.
*-- Generieren Umlagerungsbestellungen --------------------------------*
         IF BAT-PSTYP EQ PSTYP-UMLG AND
            BAT-RESWK NE SPACE AND
            BAT-FLIEF EQ SPACE.
            PERFORM GENERIEREN_UMLAGBESTELLUNG.
*-- Liste fuer generieren Erfassungsblatt -----------------------------*
         ELSEIF BAT-PSTYP = '9' AND
                NOT BAT-FORDN IS INITIAL.
            PERFORM GENERIEREN_ERFASSUNGSBLATT.
*-- Generieren Bestellungen -------------------------------------------*
         ELSE.
            PERFORM GENERIEREN_BESTELLUNG.
         ENDIF.
      ELSE.
*-- Generieren Lieferplaneinteilungen ---------------------------------*
         PERFORM GENERIEREN_EINTEILUNG.
      ENDIF.
ENDCASE.

ENDFORM.
