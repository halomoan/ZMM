*EJECT
*----------------------------------------------------------------------*
*        Verzweigen in Einzelfreigabe                                  *
*----------------------------------------------------------------------*
FORM aufruf_einzelfreigabe.

  DATA: lt_requisitions TYPE mereq_t_eban_mem,
        ls_requisition  LIKE LINE OF lt_requisitions,
        l_bnfpo         TYPE eban-bnfpo.

*-- Füllen Übergabefelder ---------------------------------------------*
  REFRESH bat.
  CLEAR bat.
  CLEAR call_updkz.

  IF ban-gsfrg IS INITIAL.
* requisition subject to item release: navigate to the item detail
    l_bnfpo = ban-bnfpo.
  ELSE.
    CLEAR l_bnfpo.
  ENDIF.
  CALL FUNCTION 'ME_RELEASE_REQUISITION'
    EXPORTING
      im_banfn        = ban-banfn
      im_bnfpo        = l_bnfpo
      im_frgco        = com-frgab
      im_wf           = space
    IMPORTING
      ex_requisitions = lt_requisitions
      ex_updkz        = call_updkz
    EXCEPTIONS
      no_authority    = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    EXIT.
  ENDIF.
  IF call_updkz EQ space.
    EXIT.
  ELSE.
    LOOP AT lt_requisitions INTO ls_requisition.
      MOVE-CORRESPONDING ls_requisition TO bat.
      APPEND bat.
    ENDLOOP.
  ENDIF.

*-- Zeilen bei den freigegeben Positionen modifizieren ----------------*
  LOOP AT bat.
    LOOP AT ban WHERE banfn EQ bat-banfn
                AND   bnfpo EQ bat-bnfpo.
*-- Banf wurde über Einzelfreigabe geändert ---------------------------*
      IF bat-updkz EQ 'V'.
        IF bat-frggr NE ban-frggr OR
           bat-frgst NE ban-frgst OR
           bat-frgzu NE ban-frgzu.
          ban-selkf = 0.
        ENDIF.
        MOVE-CORRESPONDING bat TO ban.
        ban-selkz = '*'.
        ban-updk3 = scha.
        MODIFY ban INDEX sy-tabix.
        PERFORM ban_modif_zeile USING space.
*-- Banf wurde über Einzelfreigabe freigegeben
      ELSE.
        IF bat-updkz EQ 'F'.
          MOVE-CORRESPONDING bat TO ban.
          ban-selkf = 0.
          ban-selkz = '*'.
          ban-updk3 = free.
          MODIFY ban INDEX sy-tabix.
          PERFORM ban_modif_zeile USING space.
        ELSE.
          MOVE-CORRESPONDING bat TO ban.
          ban-selkf = 0.
          ban-selkz = '*'.
          ban-updk3 = nfre.
          MODIFY ban INDEX sy-tabix.
          PERFORM ban_modif_zeile USING space.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

ENDFORM.                    "aufruf_einzelfreigabe
