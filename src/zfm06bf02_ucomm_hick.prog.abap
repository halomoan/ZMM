*eject
*----------------------------------------------------------------------*
*        Anzeigen Banf                                                 *
*----------------------------------------------------------------------*
FORM ucomm_hick.

  DATA: l_display_only TYPE c VALUE ' '.
  CHECK liste EQ 'G'.
  leerflg = 'X'.

  IF com-gpfkey EQ 'ZUOR' OR     "ME56
     com-gpfkey EQ 'BEAR' OR     "ME57
     com-gpfkey EQ 'FREI'.       "ME55
    l_display_only = 'X'.
  ENDIF.

*- Suchen einer markierten Position -----------------------------------*
  LOOP AT ban WHERE selkz EQ 'X'.
    IF NOT ban-gsfrg IS INITIAL AND NOT gs_banf IS INITIAL.
      LOOP AT ban WHERE banfn EQ ban-banfn.
        ban-selkz = '*'.
        MODIFY ban.
      ENDLOOP.
*... Bei Gesamtfreigabe die Positionsübersicht anzeigen ..............*
      CALL FUNCTION 'MMPUR_REQUISITION_DISPLAY'
           EXPORTING
                im_banfn     = ban-banfn
                im_display_only = l_display_only
           EXCEPTIONS
                no_authority = 1
                OTHERS       = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ELSE.
      ban-selkz = '*'.
      MODIFY ban.
*... Bei Positionsfreigabe die Banf-Position anzeigen ................*
      CALL FUNCTION 'MMPUR_REQUISITION_DISPLAY'
           EXPORTING
                im_banfn     = ban-banfn
                im_bnfpo     = ban-bnfpo
                im_display_only = l_display_only
           EXCEPTIONS
                no_authority = 1
                OTHERS       = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
    CLEAR leerflg.
*- Selektionskennzeichen modifizieren ---------------------------------*
    PERFORM sel_kennzeichnen.
*- für eine Position ausgeführt - Schleife verlassen ------------------*
    EXIT.
  ENDLOOP.

  IF leerflg NE space.
*- Keine markierte Zeile gefunden - Prüfen auf Line-Selection ---------*
    IF hide-index NE 0.
      READ TABLE ban INDEX hide-index.
      IF ban-gsfrg IS INITIAL OR hide-gsfrg IS INITIAL.
*... Bei Positionsfreigabe die Banf-Position anzeigen ................*
        CALL FUNCTION 'MMPUR_REQUISITION_DISPLAY'
             EXPORTING
                  im_banfn     = ban-banfn
                  im_bnfpo     = ban-bnfpo
                  im_display_only = l_display_only
             EXCEPTIONS
                  no_authority = 1
                  OTHERS       = 2.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
        ban-selkz = '*'.
        MODIFY ban INDEX hide-index.
      ELSE.
*... Bei Gesamtfreigabe die Positionsübersicht anzeigen ..............*
        CALL FUNCTION 'MMPUR_REQUISITION_DISPLAY'
             EXPORTING
                  im_banfn     = ban-banfn
                  im_display_only = l_display_only
             EXCEPTIONS
                  no_authority = 1
                  OTHERS       = 2.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
        LOOP AT ban WHERE banfn EQ ban-banfn.
          ban-selkz = '*'.
          MODIFY ban.
        ENDLOOP.
      ENDIF.
*- falls auch zusätzlich angekreuzt - Stern setzen --------------------*
      PERFORM sel_kennzeichnen.
    ELSE.
*- Funktion konnte für keine Zeile ausgeführt werden - vorher markieren*
      MESSAGE s222.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.
