*eject
*----------------------------------------------------------------------*
* Materialstamm mit View MA61V lesen - Prefetch vorbereiten
*----------------------------------------------------------------------*
FORM BAN_DATEN_PR1_001.

CHECK BAN-MATNR NE SPACE.
CHECK BAN-WERKS NE SPACE.
XPRE01-MATNR = BAN-MATNR.
XPRE01-WERKS = BAN-WERKS.
READ TABLE XPRE01 BINARY SEARCH.
CASE SY-SUBRC.
   WHEN 4.
      IF SY-TABIX EQ 0.
         SY-TABIX = 1.
      ENDIF.
      INSERT XPRE01 INDEX SY-TABIX.
   WHEN 8.
      APPEND XPRE01.
ENDCASE.

ENDFORM.
