*eject
*----------------------------------------------------------------------*
*   Verlassen Liste nach Zurück oder Beenden
*----------------------------------------------------------------------*
FORM VERLASSEN_LISTE.

  IF COM-CALLD NE SPACE.
    LEAVE.
  ELSE.
    IF SY-UCOMM EQ 'EN  '.
      LEAVE PROGRAM.
    ELSE.
      IF sy-binpt IS INITIAL AND                            "783620
         sy-tcode(4) NE 'SART' AND
         sy-tcode(4) NE 'SERP'.
        LEAVE TO TRANSACTION sy-tcode.
      ELSE.
        LEAVE PROGRAM.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    "VERLASSEN_LISTE
