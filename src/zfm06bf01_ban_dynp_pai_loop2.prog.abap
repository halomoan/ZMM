*eject
*----------------------------------------------------------------------*
*        Dynpro für Banf-Bearbeitung PAI im Loop.                     *
*----------------------------------------------------------------------*
FORM BAN_DYNP_PAI_LOOP2.

  DATA: FELD(20),
        ZEILE LIKE SY-LINNO.

*- EXIT-Command berücksichtigen ---------------------------------------*
  CASE LOOPEXIT.
    WHEN '1'.
      EXIT.
    WHEN '2'.
      CLEAR LOOPEXIT.
      EXIT.
  ENDCASE.

*- Nur definierte Felder übernehmen -----------------------------------*
  MOVE EBAN TO *EBAN.
  MOVE BAN TO EBAN.
  EBAN-MENGE = *EBAN-MENGE.
  EBAN-FLIEF = *EBAN-FLIEF.
  EBAN-EKORG = *EBAN-EKORG.
  EBAN-KONNR = *EBAN-KONNR.
  EBAN-KTPNR = *EBAN-KTPNR.
  EBAN-INFNR = *EBAN-INFNR.

*DCM blocking fields
  data: l_tcode type tstc-tcode.
  if eban-blckd ne *eban-blckd.
    if *eban-blckd eq '2'
    or ( *eban-blckd is initial and eban-blckd eq '2' ).
      l_tcode = 'ME52NB'.
    else.
      l_tcode = 'ME52N'.
    endif.
*...authority check
    CALL FUNCTION 'AUTHORITY_CHECK_TCODE'
      EXPORTING
        tcode  = l_tcode
      EXCEPTIONS
        ok     = 0
        not_ok = 1
        OTHERS = 2.
    IF sy-subrc NE 0.
*...blocking not allowed
      if l_tcode eq 'ME52NB'.
        message i015(MEDCM).
      else.
        message i016(medcm).
      endif.
    else.
      eban-blckd = *eban-blckd.
    endif.
  endif.
  if eban-blckd is initial.
    clear eban-blckt.
  else.
    eban-blckt = *eban-blckt.
    if eban-blckt is initial.
      perform enaco(sapfmmex) using 'MEDCM' '024'.
      CASE sy-subrc.
        WHEN 02.  message e024(MEDCM).
        WHEN 01.  message W024(MEDCM).
      ENDCASE.
    endif.
  endif.

  MOVE BAN TO *EBAN.

*- Lieferdatum prüfen -------------------------------------------------*
  PERFORM AEND_LFDAT.
  PERFORM AEND_MENGE.
  IF EBAN-MENGE NE *EBAN-MENGE OR
     EBAN-LFDAT NE *EBAN-LFDAT OR
     EBAN-FLIEF NE *EBAN-FLIEF OR
     EBAN-EKORG NE *EBAN-EKORG OR
     EBAN-KONNR NE *EBAN-KONNR OR
     EBAN-KTPNR NE *EBAN-KTPNR OR
     EBAN-BESWK NE *EBAN-BESWK OR
     EBAN-INFNR NE *EBAN-INFNR.
    MOVE-CORRESPONDING EBAN TO BAN.
    PERFORM AEND_BEZUG.
  ENDIF.
  IF EBAN NE *EBAN.
    MOVE-CORRESPONDING EBAN TO BAN.
    BAN-SELKZ = RM06B-SELKZ.
    BAN-UPDK1 = AEND.
    MODIFY BAN INDEX B-LESIND.
  ELSE.
    IF RM06B-SELKZ NE BAN-SELKZ.
      BAN-SELKZ = RM06B-SELKZ.
      MODIFY BAN INDEX B-LESIND.
    ENDIF.
  ENDIF.
  GET CURSOR FIELD FELD LINE ZEILE.
  IF SY-STEPL EQ ZEILE.
    HIDE-INDEX = B-LESIND.
  ENDIF.

ENDFORM.                    "BAN_DYNP_PAI_LOOP2
