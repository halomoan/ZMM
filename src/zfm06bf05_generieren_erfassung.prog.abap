*EJECT
*----------------------------------------------------------------------*
*        Generieren Erfassungsblatt zur Rahmenbestellung               *
*----------------------------------------------------------------------*
FORM GENERIEREN_ERFASSUNGSBLATT.

DATA: HEBAN LIKE EBAN OCCURS 0
      WITH HEADER LINE.

EBAN = BAT.

* Nur zur Rahmenbestellung
CHECK NOT EBAN-FORDN IS INITIAL AND
      NOT EBAN-FORDP IS INITIAL.

* Rahmenbestellung lesen/pruefen
PERFORM DIEN_READ_PO USING EBAN-FORDN EBAN-FORDP.

* Erfblaetter aus Banfliste erstellen
REFRESH: HEBAN.
LOOP AT BAT WHERE LBLNI IS INITIAL
            AND   BSMNG IS INITIAL.
  HEBAN = BAT.
  APPEND HEBAN.
ENDLOOP.

DESCRIBE TABLE HEBAN LINES SY-TFILL.
IF SY-TFILL > 0.
  CALL FUNCTION 'MS_BANF_LIST'
       EXPORTING
            I_EKKO  = EKKO
            I_EKPO  = EKPO
       TABLES
            XEBAN   = HEBAN.
ELSE.
  MESSAGE S132.
ENDIF.

* Bestellung entsperren
PERFORM ENTSPERREN_EKKO(SAPFMMEX) USING EKKO-EBELN.

* Update ban-Tabellen
CLEAR BATU.
REFRESH BATU.
LOOP AT HEBAN
     WHERE NOT LBLNI IS INITIAL.
  BATU = HEBAN.
  BATU-OBSMG = 0.
  APPEND BATU.
ENDLOOP.
IF SY-SUBRC NE 0.
  EXIT.
ENDIF.

PERFORM BAN_UPDATE USING 'E'.
PERFORM ZUG_MODIF_ZEILE USING TEXT-124.

ENDFORM.
