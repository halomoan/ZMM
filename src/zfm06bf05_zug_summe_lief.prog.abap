*eject
*----------------------------------------------------------------------*
*  Ausgeben Lieferantenzeile                                           *
*----------------------------------------------------------------------*
FORM zug_summe_lief.

  IF zug-reswk NE space.
    SELECT SINGLE * FROM t001w WHERE werks EQ zug-reswk.
    FORMAT COLOR COL_GROUP INTENSIFIED OFF.
    WRITE: /  sy-vline,
            2(14) text-064 COLOR COL_GROUP INTENSIFIED,
           17 zug-reswk,
           28(26) t001w-name1.
    IF zug-flief NE space.
      WRITE: 54(14) text-058 COLOR COL_GROUP INTENSIFIED,
             68 zug-flief.
    ENDIF.
    WRITE: 85 sy-vline.
  ELSE.
    IF zug-flief NE space.
      SELECT SINGLE * FROM lfa1 WHERE lifnr = zug-flief.
      FORMAT COLOR COL_GROUP INTENSIFIED OFF.
      WRITE: /  sy-vline,
              2(14) text-058 COLOR COL_GROUP INTENSIFIED,
             17 zug-flief,
             28 lfa1-name1,
             85 sy-vline.
* Begin CCP
    ELSEIF zug-beswk NE space.
      SELECT SINGLE * FROM t001w WHERE werks EQ zug-beswk.
      FORMAT COLOR COL_GROUP INTENSIFIED OFF.
      WRITE: /  sy-vline,
              2(14) text-cc4 COLOR COL_GROUP INTENSIFIED,
             17 zug-beswk,
             28(26) t001w-name1.
      WRITE: 85 sy-vline.
* End CCP
    ELSE.
      FORMAT COLOR COL_GROUP INTENSIFIED OFF.
      WRITE: /  sy-vline,
              2 text-059 COLOR COL_GROUP INTENSIFIED,
             85 sy-vline.
    ENDIF.
  ENDIF.
  lzeile = 'X'.

ENDFORM.                    "ZUG_SUMME_LIEF
