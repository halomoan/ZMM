*eject
*----------------------------------------------------------------------*
*        Bezugsquelle manuell zuordnen                                 *
*----------------------------------------------------------------------*
FORM ucomm_ordm.

  CHECK sy-pfkey EQ 'BEAR' OR
        sy-pfkey EQ 'ZUOR' OR
        sy-pfkey EQ 'DBEA' OR
        sy-pfkey EQ 'DZUO'.

  leerflg = 'X'.
  CLEAR reject.
  CLEAR eban.                                               "161369
*-SUCHEN EINER MARKIERTEN POSITION ------------------------------------*
  LOOP AT ban WHERE selkz EQ 'X'.
    CLEAR leerflg.
    CLEAR reject.
    index_ban = sy-tabix.
* das Füllen der BAN-Felder nicht mehr mit den Eingaben aus Dynpro 0104
* erfolgt in FORM BEZUGSQUELLE_MANUELL
* Position neu durchlaufen.                                 "161369
*   IF EBAN-MATKL EQ BAN-MATKL OR                           "161369
*      EBAN-MATNR EQ BAN-MATNR.                             "161369
*     IF EBAN-KONNR NE SPACE OR                             "161369
*        EBAN-FLIEF NE SPACE OR                             "161369
*        EBAN-INFNR NE SPACE OR                             "161369
*        EBAN-RESWK NE SPACE.                               "161369
*       BAN-KONNR = EBAN-KONNR.                             "161369
*       BAN-KTPNR = EBAN-KTPNR.                             "161369
*       BAN-FLIEF = EBAN-FLIEF.                             "161369
*       BAN-INFNR = EBAN-INFNR.                             "161369
*       BAN-EKORG = EBAN-EKORG.                             "161369
*       IF BAN-PSTYP EQ PSTYP-UMLG.                         "161369
*         BAN-RESWK = EBAN-RESWK.                           "161369
*       ENDIF.                                              "161369
*     ENDIF.                                                "161369
*   ENDIF.                                                  "161369
    PERFORM bezugsquelle_manuell.
*- Sonderzeile in Liste aufbauen --------------------------------------*
    CHECK reject EQ space.
    PERFORM ban_update_ordr.
  ENDLOOP.

  IF leerflg NE space.
*- Keine markierte Zeile gefunden - Prüfen auf Line-Selection ---------*
    IF hide-index NE 0.
      READ TABLE ban INDEX hide-index.
      index_ban = hide-index.
      PERFORM bezugsquelle_manuell.
*- Sonderzeile in Liste aufbauen --------------------------------------*
      CHECK reject EQ space.
      PERFORM ban_update_ordr.
    ELSE.
*- Funktion konnte für keine Zeile ausgeführt werden - vorher markieren*
      MESSAGE s222.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.                    "UCOMM_ORDM
*&---------------------------------------------------------------------*
*&      Form  UCOMM_ZICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM ucomm_zick .
  DATA: msg_flag,
        l_ucomm(20).

  CHECK sy-pfkey EQ 'BEAR' OR
        sy-pfkey EQ 'ZUOR' OR
        sy-pfkey EQ 'DBEA' OR
        sy-pfkey EQ 'DZUO'.

  leerflg = 'X'.
  l_ucomm = sy-ucomm.
  EXPORT l_ucomm TO MEMORY ID 'ZSDL' .

*- Suchen einer markierten Position -----------------------------------*
  LOOP AT ban WHERE selkz EQ 'X'.
    CLEAR leerflg.
    index_ban = sy-tabix.
*- Suchen einer gültigen Bezugsquelle ---------------------------------*
    PERFORM bezugsquelle_3.
    IF msg_flag EQ space AND ban-reswk EQ space AND ban-flief EQ space
       AND ban-beswk EQ space " CCP
       AND ban-konnr EQ space.
*      MESSAGE s577(06).                "nicht zu allen was gefunden
*      msg_flag = 'X'.
    ENDIF.
    PERFORM ban_update_ordr.
  ENDLOOP.

  IF leerflg NE space.
*- Keine markierte Zeile gefunden - Prüfen auf Line-Selection ---------*
    IF hide-index NE 0.
      READ TABLE ban INDEX hide-index.
      index_ban = sy-tabix.
*- Suchen einer gültigen Bezugsquelle ---------------------------------*
      PERFORM bezugsquelle_3.
      PERFORM ban_update_ordr.
      IF not_all_ordb NE space.
        MESSAGE s553(06).
      ENDIF.
    ELSE.
*- Funktion konnte für keine Zeile ausgeführt werden - vorher markieren*
      MESSAGE s222.
      EXIT.
    ENDIF.
  ELSE.
    IF not_all_ordb NE space.
      MESSAGE s551(06).
    ENDIF.
  ENDIF.

  CLEAR not_all_ordb.
ENDFORM.                    " UCOMM_ZICK
