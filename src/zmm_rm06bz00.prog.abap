*  87734  15.12.1997  3.1I  CF   Hintergrund: Falsche Listenüberschrift
************************************************************************
*        Listanzeige Bestellanforderungen zur Zuordnung                *
************************************************************************
* FRICE#     : MMGBE_013
* Title      : PR Source Determination
* Author     : Ellen H. Lagmay
* Date       : 08.10.2010
* Specification Given By: Audrey Chui
* Purpose	 : For PR - To assign the source automatically based on the
*            lowest price deteremined when there are multiple sources.
*---------------------------------------------------------------------*
* Modification Log
* Date         Author   Num Description
*
* -----------  -------  ---  -----------------------------------------*
*----------------------------------------------------------------------*

REPORT rm06bz00 MESSAGE-ID me
       NO STANDARD PAGE HEADING.
ENHANCEMENT-POINT RM06BZ00_G4 SPOTS ES_RM06BZ00 STATIC.
ENHANCEMENT-POINT RM06BZ00_G5 SPOTS ES_RM06BZ00.
ENHANCEMENT-POINT RM06BZ00_G6 SPOTS ES_RM06BZ00 STATIC.
ENHANCEMENT-POINT RM06BZ00_G7 SPOTS ES_RM06BZ00.

*----------------------------------------------------------------------*
*        Tabellen                                                      *
*----------------------------------------------------------------------*
TABLES: eban,
        ebkn,
        prps,
        resb,
        rm06b.
*ENHANCEMENT-POINT RM06BZ00_01 SPOTS ES_RM06BZ00 STATIC.
DATA: feldname(7).

DATA: l_alv(10).


*----------------------------------------------------------------------*
*        Select-options und Parameter                                  *
*----------------------------------------------------------------------*
INCLUDE zfm06bcs1.
INCLUDE zfm06bcs2.
INCLUDE zfm06bcs3.
INCLUDE zfm06bcs4.
INCLUDE zfm06bcd1.
INCLUDE zfm06lcim.
INCLUDE zselopt_cnt_call.                             "new for ERP 1.0 PA

* Begin CCP
*----------------------------------------------------------------------*
*          Make field BESWK invisible if CCP process is not active     *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  DATA: lf_ccp_active.
  CALL FUNCTION 'ME_CCP_ACTIVE_CHECK'
    IMPORTING
      ef_ccp_active = lf_ccp_active.
  IF lf_ccp_active IS INITIAL.
    LOOP AT SCREEN.
      SEARCH screen-name FOR 'S_BESWK'.
      IF sy-subrc EQ 0.
        screen-active = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
* End CCP

* integration RealEstate REFX                       "953041
  PERFORM re_modif_selection_screen.


AT SELECTION-SCREEN.
  sucomm = sy-ucomm.
  CALL FUNCTION 'ME_ITEM_CATEGORY_SELOPT_INPUT'
    TABLES
      ext_pstyp = s_pstyp
      int_pstyp = r_pstyp.

*    Sortierkennzeichen
  IF p_srtkz CN '012345679'.
    MESSAGE e309.
  ENDIF.

*... Banfen zur Gesamtfreigabe und/oder zur Positionsfreigabe ? ......*
  IF p_selgs IS INITIAL AND p_selpo IS INITIAL.
    MESSAGE e501.
  ENDIF.


AT SELECTION-SCREEN ON p_lstub.
*  PERFORM pruefen_lstub(sapfm06b) USING p_lstub.
*_ force ALV to display
  IF sy-tcode = 'ZME56'.
    l_alv  = p_lstub.
    DELETE FROM MEMORY ID 'ZALV'.
    EXPORT l_alv  TO MEMORY ID 'ZALV'.
  ENDIF.
  PERFORM pruefen_lstub(zmm_sapfm06b) USING p_lstub.


*----------------------------------------------------------------------*
*  F4 auf dem Selektionsbild / F4 on the selection screen              *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_pstyp-low.

  CALL FUNCTION 'HELP_VALUES_EPSTP'
       EXPORTING
            program = sy-cprog
            dynnr   = sy-dynnr
            fieldname = 'S_PSTYP-LOW'
*            BSART   =
*            BSTYP   =
       IMPORTING
            epstp   = s_pstyp-low
       EXCEPTIONS
            OTHERS  = 1.

START-OF-SELECTION.

*  PERFORM force_alv(sapfm06b) USING p_alv. "new for ERP 1.0 PA
  PERFORM force_alv(zmm_sapfm06b) USING p_alv.           "new for ERP 1.0 PA
  PERFORM get_re_sel_options.
  PERFORM selopt_bam_1.
  PERFORM selopt_bam_2 USING p_erlba p_zugba.
  PERFORM selopt_bam_3.
  PERFORM selopt_bam_4 USING p_cntlmt.               "new for ERP 1.0 PA

  CASE sy-tcode.
*    WHEN 'ME56'.
    WHEN 'ZME56'.
*     PERFORM AKTIVITAET_SETZEN(SAPFM06D) USING '02'.        "175227
      com-gpfkey = 'ZUOR'.
      com-gfmkey = '001'.
      com-zpfkey = 'ZBUB'.
      com-zfmkey = '102'.
    WHEN 'ME57' OR 'ME5J'.                                  "786504
      com-gpfkey = 'BEAR'.
      com-gfmkey = '002'.
      com-zpfkey = 'ZALL'.
      com-zfmkey = '102'.
    WHEN OTHERS.                                            "87734
      com-gpfkey = 'ZUOR'.                                  "87734
      com-gfmkey = '001'.                                   "87734
      com-zpfkey = 'ZBUB'.                                  "87734
      com-zfmkey = '102'.                                   "87734
  ENDCASE.

* When called from frontend behave like ME57         new with ERP 1.0 PA
  IF sy-tcode = 'METAL' OR NOT p_wlmem = space.
    com-gpfkey = 'BEAR'.
    com-gfmkey = '002'.
    com-zpfkey = 'ZALL'.
    com-zfmkey = '102'.
  ENDIF.

  not_found = 'X'.

*----------------------------------------------------------------------*
*        Lesen Bestellanforderungen                                    *
*----------------------------------------------------------------------*
GET eban.
*  PERFORM check_para1(sapfm06b).
  PERFORM check_para1(zmm_sapfm06b).
  CHECK reject EQ space.
*  PERFORM check_para2(sapfm06b).
  PERFORM check_para2(zmm_sapfm06b).
  CHECK reject EQ space.
*- Keine RV-Banfs -----------------------------------------------------*
  CHECK eban-bsakz NE 'R'.
*- Teilbestellte Banfs aus Vertriebsbeleg werden nicht gebracht -------*
*- beim zuordnen und bearbeiten Banfs ---------------------------------*
  IF eban-estkz EQ 'V' AND
     com-gpfkey EQ 'BEAR'.
    CHECK eban-bsmng EQ 0.
  ENDIF.
*- Requisition marked for external procurement ? ----------------------*
  CHECK eban-eprofile IS INITIAL.

*  PERFORM ban_aufbauen(sapfm06b).
  PERFORM ban_aufbauen(zmm_sapfm06b).
*----------------------------------------------------------------------*
*        Initialisierung                                               *
*----------------------------------------------------------------------*
INITIALIZATION.
*ENHANCEMENT-POINT RM06BZ00_G8 SPOTS ES_RM06BZ00 STATIC .

  p_zugba = space.

  IF sy-slset IS INITIAL AND "von außen wurde keine Variante gesetzt
     sy-batch IS INITIAL AND "beim Batchlauf wird keine Variante gesetzt
     sy-binpt IS INITIAL AND NOT  "CALL TRANSACTION USING/BATCH-INPUT
     sy-calld = 'X'.         " kein SUBMIT/ CALL DIALOG/ CALL TRANSACT.
*- Selektionsvariante für Immobilienfelder setzen -*
*    DATA: l_report  LIKE rsvar-report   VALUE 'RM06BZ00'.
    DATA: l_report  LIKE rsvar-report   VALUE 'ZMM_RM06BZ00'.
*    DATA: l_action  LIKE esdus_s-action VALUE 'RM06BZ00'.
    DATA: l_action  LIKE esdus_s-action VALUE 'ZMM_RM06BZ00'.
    DATA: l_variant LIKE rsvar-variant  VALUE 'SAP&STANDARD'.

    CALL FUNCTION 'ME_SET_REPORT_USERVARIANT'
      EXPORTING
        im_report           = l_report
        im_esdus_action     = l_action
        im_standard_variant = l_variant.
  ENDIF.

  CASE sy-tcode.
*    WHEN 'ME56'.
    WHEN 'ZME56'.
      SET TITLEBAR '001'.
    WHEN 'ME57'.
      SET TITLEBAR '002'.
  ENDCASE.
*  PERFORM vorschlagen_lstub(sapfm06b) USING p_lstub.
  PERFORM vorschlagen_lstub(zmm_sapfm06b) USING p_lstub.

* Include für Verbindung zur log. Datenbank BAM -----------------------*
  INCLUDE zdbbamrse.

*----------------------------------------------------------------------*
*        Ende der Selektion                                            *
*----------------------------------------------------------------------*
END-OF-SELECTION.

* save user variant
  DATA: my_esduscom LIKE esduscom OCCURS 0 WITH HEADER LINE.
  REFRESH my_esduscom.
  MOVE l_action      TO my_esduscom-action.
  MOVE 'USERVARIANT' TO my_esduscom-element.
  MOVE sy-slset      TO my_esduscom-active.
  APPEND my_esduscom.
  CALL FUNCTION 'ES_APPEND_USER_SETTINGS'
       EXPORTING
*          IACTION  =
*          IELEMENT =
*          IACTIVE  =
             iuname   = sy-uname
             isave    = 'X'
       TABLES
            iesdus   = my_esduscom
            .
* Count workload and EXPORT it TO MEMORY to frontend (only in count
* mode)                                              new with ERP 1.0 PA
*  PERFORM count_workload(sapfm06b) USING not_found p_wlmem.
  PERFORM count_workload(zmm_sapfm06b) USING not_found p_wlmem.
  IF not_found NE space.
    MESSAGE s261.
    IF sy-calld NE space.
      LEAVE.
    ELSE.
      LEAVE TO TRANSACTION sy-tcode.
    ENDIF.
  ENDIF.
  CLEAR com-frgab.
  com-srtkz = p_srtkz.
  com-lstub = p_lstub.
  IF sy-calld NE space.
    com-calld = sy-calld.
  ENDIF.
*  PERFORM submit(sapfm06b) USING sucomm.  "Liste ausgeben

  PERFORM submit(zmm_sapfm06b) USING sucomm.
  CLEAR sucomm.

*&---------------------------------------------------------------------*
*&      Form  GET_RE_SEL_OPTIONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_re_sel_options.

  CHECK NOT s_swenr[]  IS INITIAL OR
        NOT s_sgenr[]  IS INITIAL OR
        NOT s_sgrnr[]  IS INITIAL OR
        NOT s_smenr[]  IS INITIAL OR
        NOT s_smive[]  IS INITIAL OR
        NOT s_svwnr[]  IS INITIAL OR
        NOT s_snksl[]  IS INITIAL OR
        NOT s_sempsl[] IS INITIAL OR
        NOT s_recnnr[] IS INITIAL OR
        NOT s_obart[]  IS INITIAL OR
        NOT p_dvon     IS INITIAL OR
        NOT p_dbis     IS INITIAL.

  CALL FUNCTION 'REMD_GET_IMKEY_FOR_SELECT_OPT'
       EXPORTING
            i_bukrs  = i_bukrs
            i_dstich = p_stich
*            I_DVON   = P_DVON
*            I_DBIS   = P_DBIS
       TABLES
            s_swenr  = s_swenr
            s_sgenr  = s_sgenr
            s_sgrnr  = s_sgrnr
            s_smenr  = s_smenr
            s_smive  = s_smive
            s_svwnr  = s_svwnr
            s_snksl  = s_snksl
            s_empsl  = s_sempsl
            s_recnnr = s_recnnr
            s_obart  = s_obart
            s_vonbis = s_vonbis
            e_imkeys = t_imkeys.

* vorläufig
  DELETE t_imkeys WHERE imkey = space.

ENDFORM.                               " GET_RE_SEL_OPTIONS

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_pstyp-high.      " 953826

  CALL FUNCTION 'HELP_VALUES_EPSTP'
       EXPORTING
            program = sy-cprog
            dynnr   = sy-dynnr
            fieldname = 'S_PSTYP-HIGH'
*            BSART   =
*            BSTYP   =
       IMPORTING
            epstp   = s_pstyp-high
       EXCEPTIONS
            OTHERS  = 1.

* Anschluß Immobilienverwaltung 4.6A
* F4-Hilfe für Feld Objektart bei Feldern für Immobilienverwaltung
* AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_obart-low.
  INCLUDE zifviimslf4.

*----------------------------------------------------------------------*
*        Beginn der Selektion                                          *
*----------------------------------------------------------------------*
