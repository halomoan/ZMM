*eject
*----------------------------------------------------------------------*
*        Ändern Bestellanforderungen                                   *
*----------------------------------------------------------------------*
FORM banf_aendern USING bae_compl.

*-- Schlusspruefung im Fall der Gesamtfreigabe ------------------------*
  DATA: l_xeban  LIKE xeban,
        l_ban    LIKE ban,
        l_lines  LIKE sy-tabix.
  READ TABLE xeban INTO l_xeban INDEX 1.
  CHECK sy-subrc IS INITIAL.
  IF gpfkey EQ 'FREI' AND l_xeban-gsfrg EQ 'X' AND gs_banf EQ 'X'.
* Pruefen auf Vollstaendigkeit
    DESCRIBE TABLE xeban LINES l_lines.
    READ TABLE ban INTO l_ban WITH KEY banfn = l_xeban-banfn
                                       bnfpo = l_xeban-bnfpo.
    IF l_ban-az_pos NE l_lines.
      CLEAR: xeban, yeban.
      REFRESH: xeban, yeban.
      DELETE bat WHERE banfn EQ l_xeban-banfn.
      zsich = zsich + l_lines - l_ban-az_pos.
      EXIT.
    ENDIF.
  ENDIF.

*-- Note 739690
*-- Commitment Interface-----------------------------------------------*
  DATA: fmeban LIKE eban OCCURS 0 WITH HEADER LINE,
        fmebkn LIKE ebkn OCCURS 0 WITH HEADER LINE.

  DATA: l_badi                TYPE REF TO me_commtmnt_req_rele,
        l_badi_cust           TYPE REF TO me_commtmnt_req_re_c,
        lo_context            TYPE REF TO cl_ex_me_commtmnt_req_rele,
        lo_context_cust       TYPE REF TO cl_ex_me_commtmnt_req_re_c.

  STATICS : l_internal_badi_act TYPE i,
            l_cust_badi_active  TYPE i.

  IF l_internal_badi_act IS INITIAL AND
     l_cust_badi_active  IS INITIAL.

    CREATE OBJECT lo_context.
    TRY.
        GET BADI l_badi
          CONTEXT
            lo_context.
        l_internal_badi_act = 2.
      CATCH cx_badi_not_implemented.
        l_internal_badi_act = 1.
    ENDTRY.

    CREATE OBJECT lo_context_cust.
    TRY.
        GET BADI l_badi_cust
          CONTEXT
            lo_context_cust.
        l_cust_badi_active = 2.
      CATCH cx_badi_not_implemented.
        l_cust_badi_active = 1.
    ENDTRY.
  ENDIF.

  IF ( l_internal_badi_act = 2 OR
       l_cust_badi_active  = 2 ) AND
     gpfkey = 'FREI'.
    REFRESH : fmeban,
              fmebkn.
    CLEAR : fmebkn,
            fmeban.

    APPEND LINES OF xeban TO fmeban.
    SELECT * FROM ebkn APPENDING TABLE fmebkn
                       WHERE banfn = xeban-banfn.

*-- Prepare the message handler for new update
    CALL FUNCTION 'MESSAGES_INITIALIZE'.

    CALL FUNCTION 'ME_STATISTICS_EBAN_RKO'
      EXPORTING
        i_avc_pruefen = 'X'
        i_first_call  = 'X'
      TABLES
        t_eban        = fmeban
        t_ebkn        = fmebkn.

    CLEAR t_mesg.
    REFRESH t_mesg.
    CALL FUNCTION 'MESSAGES_STOP'
      EXCEPTIONS
        a_message         = 1
        e_message         = 2
        w_message         = 3
        i_message         = 4
        s_message         = 5
        deactivated_by_md = 6
        OTHERS            = 7.

*-- Get all messages issued by updating interface
    CALL FUNCTION 'MESSAGES_GIVE'
      TABLES
        t_mesg = t_mesg.

*-- If there is an error or abort message save the errors for log
    LOOP AT t_mesg WHERE msgty = 'E'
                      OR msgty = 'A'.
      t_excluded-banfn = xeban-banfn.
      t_excluded-msgty = t_mesg-msgty.
      t_excluded-text  = t_mesg-text.
      t_excluded-arbgb = t_mesg-arbgb.
      t_excluded-txtnr = t_mesg-txtnr.
      t_excluded-msgv1 = t_mesg-msgv1.
      t_excluded-msgv2 = t_mesg-msgv2.
      t_excluded-msgv3 = t_mesg-msgv3.
      t_excluded-msgv4 = t_mesg-msgv4.
      APPEND t_excluded.
    ENDLOOP.
    IF sy-subrc = 0.
      CALL FUNCTION 'ME_STATISTICS_EBAN_RKO'
        EXPORTING
          i_refresh    = ' '
          i_initialize = 'X'
        TABLES
          t_eban       = fmeban
          t_ebkn       = fmebkn.

      DESCRIBE TABLE xeban LINES l_lines.
      DELETE bat WHERE banfn EQ xeban-banfn.
      DELETE xeban WHERE banfn EQ xeban-banfn.
      zsich = zsich - l_lines.
      zacce = zacce + l_lines.
      EXIT.
    ENDIF.
  ENDIF.
*-- Note 739690

*-- Verbuchen Änderungsbeleg ------------------------------------------*
  objectid(10) = xeban-banfn.
  tcode        = sy-tcode.
  utime        = sy-uzeit.
  udate        = sy-datum.
  username     = sy-uname.
  upd_icdtxt_banf   = 'U'.
  upd_eban     = 'U'.
  PERFORM cd_call_banf.

  IF gpfkey EQ 'FREI'.
*-- Verbuchen freigaberelevante Felder --------------------------------*
    CALL FUNCTION 'ME_UPDATE_REQUISITION_RELEASE' IN UPDATE TASK
      TABLES
        xeban = xeban
        yeban = yeban.                                      "#124738

* DCM: Revisions
    CALL FUNCTION 'MEDCMM_POST_REVISIONS'
      EXPORTING
        im_number = xeban-banfn
      EXCEPTIONS
        OTHERS    = 0.

* DCM: Workflows
    DATA: lt_xeban TYPE mereq_t_eban,
          lt_yeban TYPE mereq_t_eban,
          lt_wfc   TYPE merel_t_wfc.
    lt_xeban[] = xeban[].
    lt_yeban[] = yeban[].
    CALL FUNCTION 'MEREL_PREPARE_WFC_EBAN'
      EXPORTING
        im_number   = xeban-banfn
        im_eban_new = lt_xeban
        im_eban_old = lt_yeban
      CHANGING
        ch_wfc      = lt_wfc.

    CALL FUNCTION 'ME_PREPARE_WFC_BUYER'
      EXPORTING
        im_eban_new = lt_xeban
        im_eban_old = lt_yeban
      CHANGING
        ch_wfc      = lt_wfc.
    IF NOT lt_wfc IS INITIAL.
      CALL FUNCTION 'MEREL_POST_WFC' IN UPDATE TASK
        EXPORTING
          im_wfc = lt_wfc.
    ENDIF.

  ELSE.
    IF bae_compl NE space.
*-- Disp-Satz-Erstellung ----------------------------------------------*
*      IF NOT DIS[] IS INITIAL.                                "201395
      CALL FUNCTION 'ME_CREATE_MRPRECORD_REQ' IN UPDATE TASK
        TABLES
          dis   = dis
          xeban = xeban
          yeban = yeban.
*      ENDIF.                                                  "201395
*-- Komplett-Verbuchung Banf bei Mengen/Termin-Änderung ---------------*
      CALL FUNCTION 'ME_UPDATE_REQUISITION' IN UPDATE TASK
        TABLES
          xeban = xeban
          xebkn = xebkn
          yeban = yeban
          yebkn = yebkn.
    ELSE.
*-- Verbuchung Felder aus Zuordnung (sources of supply) ---------------*
      CALL FUNCTION 'ME_UPDATE_REQUISITION_SOS' IN UPDATE TASK
        TABLES
          xeban = xeban
          yeban = yeban.                                    "#124738
*- Update Quota                                                "361414
      CALL FUNCTION 'ME_UPDATE_QUOTA_FROM_REQ' IN UPDATE TASK
        TABLES
          xeban = xeban
          yeban = yeban.
    ENDIF.
* LB-Positionen: Mengen-/Terminänderung an Komponenten weitergeben
    DATA: l_eban LIKE eban,
          l_eban_old LIKE eban,
          l_ebkn LIKE ebkn,
          l_mdlb LIKE mdlb,
          l_vorga TYPE c,                                   "500635
          l_mdpa LIKE mdpa,
          l_mdpa_old LIKE mdpa,
          lt_mdlb LIKE mdlb OCCURS 0.
    CALL FUNCTION 'ME_COMPONENTS_REFRESH'.
    LOOP AT xeban WHERE pstyp EQ pstyp-lohn.
      MOVE-CORRESPONDING xeban TO l_eban.
      CLEAR l_ebkn.
      CLEAR l_vorga.                                        "500635
*     IF l_eban-sobkz EQ sobkz-kdein OR
*        l_eban-sobkz EQ sobkz-prein.
      IF NOT l_eban-knttp IS INITIAL.                       "499632
        SELECT SINGLE * FROM  ebkn INTO l_ebkn
               WHERE  banfn  = l_eban-banfn
               AND    bnfpo  = l_eban-bnfpo
               AND    zebkn  = 01.
      ENDIF.
      CALL FUNCTION 'ME_FILL_MDPA_FROM_EBAN'
        EXPORTING
          im_eban = l_eban
          im_ebkn = l_ebkn
        IMPORTING
          ex_mdpa = l_mdpa.
      CLEAR l_eban_old.
      READ TABLE yeban WITH KEY banfn = xeban-banfn
                                bnfpo = xeban-bnfpo.
      MOVE-CORRESPONDING yeban TO l_eban_old.
      CALL FUNCTION 'ME_FILL_MDPA_FROM_EBAN'
        EXPORTING
          im_eban = l_eban_old
          im_ebkn = l_ebkn
        IMPORTING
          ex_mdpa = l_mdpa_old.
      CALL FUNCTION 'ME_COMPONENTS_MAINTAIN'
        EXPORTING
          i_ebelp    = l_eban-bnfpo
          i_mdpa     = l_mdpa
          i_mdpa_old = l_mdpa_old
          i_txz01    = l_eban-txz01
          i_vorga    = 'C'.
      IF l_eban-ebakz EQ space AND                          "500635
         l_eban_old-ebakz NE space.
        l_vorga = 'E'.
      ENDIF.
      IF l_eban-ebakz NE space AND
         l_eban_old-ebakz EQ space.
        l_vorga = 'L'.
      ENDIF.
      IF NOT l_vorga IS INITIAL.
        CALL FUNCTION 'ME_COMPONENTS_MAINTAIN'
          EXPORTING
            i_ebelp    = l_eban-bnfpo
            i_mdpa     = l_mdpa
            i_mdpa_old = l_mdpa_old
            i_txz01    = l_eban-txz01
            i_vorga    = l_vorga.
      ENDIF.                                                "500635
      CALL FUNCTION 'ME_FILL_MDLB_FROM_EBAN'
        EXPORTING
          im_eban = l_eban
          im_ebkn = l_ebkn
        IMPORTING
          ex_mdlb = l_mdlb.
      APPEND l_mdlb TO lt_mdlb.
    ENDLOOP.
    IF NOT l_eban-banfn IS INITIAL.
* Verbuchung der Komponenten
      CALL FUNCTION 'ME_COMPONENTS_UPDATE_PREPARE'
        EXPORTING
          i_number = l_eban-banfn
        TABLES
          t_mdlb   = lt_mdlb.
    ENDIF.
  ENDIF.

*- BAdI ME_REQ_POSTED
  CLASS cl_badi_mm DEFINITION LOAD.
  DATA: badi_req_inst   TYPE REF TO if_ex_me_req_posted.
  badi_req_inst ?= cl_badi_mm=>get_instance( 'ME_REQ_POSTED' ).

  IF NOT badi_req_inst IS INITIAL.
    DATA: lt_ueban     TYPE mereq_t_ueban,
          lt_ueban_old TYPE mereq_t_ueban,
          lt_uebkn     TYPE mereq_t_uebkn,
          lt_uebkn_old TYPE mereq_t_uebkn.
    lt_ueban[]     = xeban[].
    lt_ueban_old[] = yeban[].
    lt_uebkn[]     = xebkn[].
    lt_uebkn_old[] = yebkn[].
    CALL METHOD badi_req_inst->posted
      EXPORTING
        im_eban     = lt_ueban
        im_eban_old = lt_ueban_old
        im_ebkn     = lt_uebkn
        im_ebkn_old = lt_uebkn_old
      EXCEPTIONS
        OTHERS      = 0.
  ENDIF.

  COMMIT WORK.
  REFRESH: xeban, yeban.
  CLEAR:   xeban, yeban.

ENDFORM.                    "banf_aendern
