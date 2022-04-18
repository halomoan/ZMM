*eject
*----------------------------------------------------------------------*
*        Sortkennzeichen setzen                                        *
*----------------------------------------------------------------------*
FORM UCOMM_SORT.

  CHECK LISTE EQ 'G'.

  CASE SY-UCOMM.
    WHEN 'SRT1'.
      CHECK COM-SRTKZ NE 1.
      COM-SRTKZ = 1.                   "nach Banfn/Bnfpo/Matnr/Lfdat
    WHEN 'SRT2'.
      CHECK COM-SRTKZ NE 2.
      COM-SRTKZ = 2.                   "nach Ekgrp/Matnr/Werks
    WHEN 'SRT3'.
      CHECK COM-SRTKZ NE 3.
      COM-SRTKZ = 3.                   "nach Bednr/Ekgrp/Werks
    WHEN 'SRT4'.
      CHECK COM-SRTKZ NE 4.
      COM-SRTKZ = 4.                   "nach Frgdt
    WHEN 'SRT5'.
      CHECK COM-SRTKZ NE 5.
      COM-SRTKZ = 5.                   "nach Matkl
    WHEN 'SRT6'.
      CHECK COM-SRTKZ NE 6.
      COM-SRTKZ = 6.                   "nach Werks/Dispo
    WHEN 'SRT7'.
      CHECK COM-SRTKZ NE 7.
      COM-SRTKZ = 7.                   "nach Material
    WHEN 'SRT8'.
      CHECK COM-SRTKZ NE 8.
      COM-SRTKZ = 8.                   "nach Kontierung
    WHEN 'SRT9'.
      CHECK COM-SRTKZ NE 9.
      COM-SRTKZ = 9.                   "nach Bezugsquelle
    WHEN OTHERS.
*ENHANCEMENT-SECTION     FM06BF02_UCOMM_SORT_01 SPOTS ES_SAPFM06B.
      EXIT.
*END-ENHANCEMENT-SECTION.
  ENDCASE.

  SY-LSIND = 0.
  PERFORM BAN_SORT.
  IF T16LB-DYNPR EQ 0.
    PERFORM BAN_ZEILEN.
  ELSE.
    CLEAR: B-AKTIND, B-LOPIND, B-MAXIND, B-PAGIND, B-LESIND.
    DESCRIBE TABLE BAN LINES B-MAXIND.
    IF xcalld EQ 'X'.
      xcalld = 'Y'.
    ENDIF.
    PERFORM ban_dynp_call.
  ENDIF.

ENDFORM.
