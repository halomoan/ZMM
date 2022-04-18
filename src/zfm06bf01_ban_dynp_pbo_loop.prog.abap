*eject
*----------------------------------------------------------------------*
*        Dynpro für Banf-Bearbeitung PBO im  Loop.                     *
*----------------------------------------------------------------------*
FORM BAN_DYNP_PBO_LOOP.

  B-LOPIND = SY-LOOPC.
  DO.
    B-AKTIND = B-AKTIND + 1.
    CLEAR EBAN.
    IF DET NE SPACE.
      CLEAR BDT.
      READ TABLE BDT INDEX B-AKTIND.
      READ TABLE BAN INDEX BDT-INDEX.
    ELSE.
      READ TABLE BAN INDEX B-AKTIND.
    ENDIF.

    IF SY-SUBRC EQ 0.
      EBAN = BAN.
      RM06B-SELKZ = BAN-SELKZ.
      PERFORM BAN_AUSGABE_VORBEREITEN USING 'G'.
      B-PAGIND = B-PAGIND + 1.
      EXIT.
    ELSE.
      B-AKTIND = B-AKTIND - 1.
      EXIT FROM STEP-LOOP.
    ENDIF.
  ENDDO.

*- Modifizieren Eingabebereitsschaft Felder ---------------------------*
  LOOP AT SCREEN.
*- Banf gelöscht - keine Felder eingabebereit -------------------------*
    IF EBAN-LOEKZ NE SPACE AND
       SCREEN-INPUT EQ 1.
      SCREEN-INPUT = 0.
      MODIFY SCREEN.
    ENDIF.
*- Dienstleistungsposition - Menge nicht eingabebereit ----------------*
    IF EBAN-PSTYP EQ '9' AND
       SCREEN-GROUP3 EQ '001'.
      SCREEN-INPUT = 0.
      MODIFY SCREEN.
    ENDIF.
*- DCM check blocking authority against ME52N/ME52NB authority of user
    if screen-name eq 'EBAN-BLCKT'
    or screen-name eq 'EBAN-BLCKD'.
      if not eban-blckd is initial.
        data: l_tcode type tstc-tcode.
        if eban-blckd eq '1'.
          l_tcode = 'ME52N'.  "originator block
        else.
          l_tcode = 'ME52NB'. "buyer block
        endif.
*......authority check
        CALL FUNCTION 'AUTHORITY_CHECK_TCODE'
          EXPORTING
            tcode  = l_tcode
          EXCEPTIONS
            ok     = 0
            not_ok = 1
            OTHERS = 2.
        IF sy-subrc NE 0.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        endif.
      endif.
    endif.

  ENDLOOP.

ENDFORM.                    "BAN_DYNP_PBO_LOOP
