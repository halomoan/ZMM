*eject
*----------------------------------------------------------------------*
*     Lieferantenbeurteilung zum Material oder zur Materialklasse
*----------------------------------------------------------------------*
FORM UCOMM_LIBE.

  CHECK LISTE EQ 'G'.

  LEERFLG = 'X'.
  CLEAR: LIBE, LIBE_EKO, INDEX_BAN, EXITFLAG.
  REFRESH: LIBE_EKO.
*- Suchen einer markierten Position -----------------------------------*
  LOOP AT BAN WHERE SELKZ EQ 'X'.
    CLEAR LEERFLG.
    IF LIBE-MATNR NE SPACE.
*- Daten nicht gleich - Meldung ---------------------------------------*
      IF BAN-MATNR NE LIBE-MATNR.
        MESSAGE S225.
        EXITFLAG = 'X'.
        EXIT.
      ENDIF.
    ELSE.
      IF LIBE-MATKL NE SPACE.
        IF BAN-MATKL NE LIBE-MATKL.
          MESSAGE S225.
          EXITFLAG = 'X'.
          EXIT.
        ENDIF.
      ENDIF.
    ENDIF.
*- Daten gleich - ok. -------------------------------------------------*
    MOVE-CORRESPONDING BAN TO LIBE.
*
    IF NOT BAN-MATNR IS INITIAL.       "4.0C
*... Lagermaterial ...................................................*
*... Falls HTN-Abwicklung aktiv ist und die EK-Statistik auf dem HTN .*
*... fortgeschreiben wird, muß hier mit dem HTN (ematn) gearbeitet.werd.
      CALL FUNCTION 'MB_READ_TMPPF'    "4.0C
           EXPORTING                   "4.0C
                PROFILE        = BAN-MPROF                   "4.0C
           IMPORTING                   "4.0C
                MPN_PARAMETERS = TMPPF "4.0C
           EXCEPTIONS                  "4.0C
                NO_ENTRY       = 1     "4.0C
                OTHERS         = 2.    "4.0C
      IF NOT TMPPF-MPLIS IS INITIAL AND"4.0C
         NOT BAN-EMATN IS INITIAL.     "4.0C
*... HTN-Abwicklung und Statistik auf HTN ............................*
        LIBE-MATNR     = BAN-EMATN.    "4.0C
      ENDIF.                           "4.0C
    ENDIF.                             "4.0C
*
    INDEX_BAN = SY-TABIX.
*... Ermitteln der beteiligten Einkaufsorganisationen ................*
    CALL FUNCTION 'ME_SELECT_EKORG_FOR_PLANT'                  "4.0C
         EXPORTING                     "4.0C
              I_WERKS                    = BAN-WERKS           "4.0C
              I_STANDARD                 = 'X'                 "4.0C
         IMPORTING                     "4.0C
              E_EKORG                    = LIBE_EKO-EKORG      "4.0C
     exceptions                                            "4.0C
          more_than_one_organization = 1                   "4.0C
          no_entry_found             = 2                   "4.0C
          no_default_found           = 3.                  "4.0C
    LIBE-EKORG = LIBE_EKO-EKORG.
  ENDLOOP.
*- Verlassen Routine, wenn Fehler aufgetreten -------------------------*
  CHECK EXITFLAG EQ SPACE.

  IF LEERFLG NE SPACE.
*- Keine markierten Zeilen gefunden - Prüfen auf Line-Selection -------*
    IF HIDE-INDEX NE 0.
      PERFORM VALID_LINE.
      CHECK EXITFLAG EQ SPACE.
      READ TABLE BAN INDEX HIDE-INDEX.
      INDEX_BAN = SY-TABIX.
*- Aufruf Report ------------------------------------------------------*
      PERFORM AUFRUF_LIBE.
      CHECK EXITFLAG EQ SPACE.
*- Modifizieren Banf-Tabelle mit Zuordnungsdaten ----------------------*
      INDEX_BAN = SY-TABIX.
*- Sonderzeile in Liste aufbauen --------------------------------------*
      PERFORM BAN_UPDATE_LINF.
      EXIT.
*- Keine markierten Zeilen gefunden - bitte zuerst markieren ----------*
    ELSE.
      MESSAGE S222.
      EXIT.
    ENDIF.
  ENDIF.
*- Aufruf Report ------------------------------------------------------*
  READ TABLE BAN INDEX INDEX_BAN.
  PERFORM AUFRUF_LIBE.
  CHECK EXITFLAG EQ SPACE.
*- Modifizieren der Listzeilen mit zugeordnetem Rahmenvertrag ---------*
  LOOP AT BAN WHERE SELKZ EQ 'X'.
    INDEX_BAN = SY-TABIX.
*- Sonderzeile in Liste aufbauen --------------------------------------*
    PERFORM BAN_UPDATE_LINF.
  ENDLOOP.
  CLEAR HIDE-INDEX.
ENDFORM.
