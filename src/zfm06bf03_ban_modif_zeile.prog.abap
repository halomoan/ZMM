*eject
*----------------------------------------------------------------------*
*  Zeile in Grundliste modifizieren                                    *
*----------------------------------------------------------------------*
FORM BAN_MODIF_ZEILE USING BMZ_FLAG.

  IF XZLTYP NE SPACE.
    PERFORM BAN_ZUORD USING BMZ_FLAG.
    READ LINE BAN-ZEILE OF PAGE BAN-PAGE INDEX LSIND.
    IF SY-PFKEY EQ 'FREI'.
      HLINE = FLINE.
      T16LA = *T16LA.
    ENDIF.
    CASE XZLTYP.
      WHEN '1'.
        MOVE HLINE TO SY-LISEL+3(77).
        MODIFY LINE BAN-ZEILE OF PAGE BAN-PAGE INDEX LSIND
               LINE FORMAT COLOR COL_POSITIVE.
        IF NOT ICON_FIELD IS INITIAL AND                   "96597
           BAN-GSFRG NE SPACE.                                  "122700
          READ LINE BAN-SZEIL OF PAGE BAN-PAGE INDEX LSIND.
*         WRITE icon_field TO sy-lisel+53 AS ICON.
          WRITE ICON_FIELD+1(2) TO SY-LISEL+53(2).              "122700
          MODIFY LINE BAN-SZEIL OF PAGE BAN-PAGE INDEX LSIND.
        ENDIF.                                              "96597
      WHEN '2'.
        MOVE T16LA-UPDT2 TO SY-LISEL+70(10).
        MODIFY LINE BAN-ZEILE OF PAGE BAN-PAGE INDEX LSIND.
      WHEN '3'.
        MOVE T16LA-UPDT1 TO SY-LISEL+76(4).
        MODIFY LINE BAN-ZEILE OF PAGE BAN-PAGE INDEX LSIND.
    ENDCASE.
  ENDIF.

  PERFORM SEL_KENNZEICHNEN.

ENDFORM.
