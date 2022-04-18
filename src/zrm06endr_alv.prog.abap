REPORT zrm06endr_alv MESSAGE-ID me.
* offene Punkte:
* 1.
* 2.


TABLES: ekpo,           nast,            t000md,
        ekko,             addr1_val,      ekek,           marc,
        t185,             t185f,          t185v,          t160,
        t685b,            t161n,          flaber.           "352785

*ENHANCEMENT-POINT RM06ENDR_ALV_01 SPOTS ES_RM06ENDR_ALV STATIC.
TYPE-POOLS:   slis.

INCLUDE <icon>.
INCLUDE <symbol>.

DATA: BEGIN OF xheader OCCURS 0,
        ebeln LIKE ekko-ebeln,
        lifnr LIKE ekko-lifnr,
        name1 LIKE lfa1-name1,
        bsart LIKE ekko-bsart,
        bstyp LIKE ekko-bstyp,
        ernam LIKE ekko-ernam,                              "ADD CREATED BY FIELD_19032012
        ekgrp LIKE ekko-ekgrp,
        bedat LIKE ekko-bedat,
        adrnr LIKE ekko-adrnr,                              "199775
        spras LIKE ekko-spras,                              "408560
      END OF xheader.


DATA: BEGIN OF xitem OCCURS 0,
        box    LIKE dm07i-xselz,
        symbol(30) TYPE c,
        ebeln  LIKE ekko-ebeln.
*ENHANCEMENT-POINT RM06ENDR_ALV_13 SPOTS ES_RM06ENDR_ALV STATIC.

"$$
"$$
"$$
"$$
"$$
"$$
        INCLUDE STRUCTURE nast.
DATA: END OF xitem.

DATA: BEGIN OF gt_outtab_grid OCCURS 0.
        INCLUDE STRUCTURE xitem.
DATA:   lifnr LIKE ekko-lifnr,
        name1 LIKE lfa1-name1,
        bsart LIKE ekko-bsart,
        bstyp LIKE ekko-bstyp,
        ekgrp LIKE ekko-ekgrp,
        bedat LIKE ekko-bedat,
        ernam LIKE ekko-ernam,                                "added_19032012
*        adrnr LIKE ekko-adrnr,
*        spras LIKE ekko-spras,
 END OF gt_outtab_grid,
      gf_use_grid.

DATA: gf_icon_checked(30) TYPE c,
      gf_icon_incomplete(30) TYPE c.

DATA: BEGIN OF ekpo_short OCCURS 0,
        ebeln LIKE ekpo-ebeln,
        ebelp LIKE ekpo-ebelp,
        bstyp LIKE ekpo-bstyp,                             "1386395
        werks LIKE ekpo-werks,                             "1386395
        abart LIKE ekek-abart,
        abruf LIKE ekek-abruf,
        objky LIKE nast-objky,
        ekorg LIKE ekko-ekorg,                             "1386395
        ekgrp LIKE ekko-ekgrp,                             "1386395
        bsart LIKE ekko-bsart,                             "1386395
        bukrs LIKE ekko-bukrs,
        lifnr LIKE ekko-lifnr,
        ernam LIKE ekko-ernam,                                "added_19032012
        reswk LIKE ekko-reswk,
        bsakz LIKE ekko-bsakz,
        spras LIKE ekko-spras,
        kunnr LIKE ekko-kunnr,
        adrnr LIKE ekko-adrnr,
      END OF ekpo_short.

* Structure for generating EKPO_SHORT-OBJKY                 "216665
DATA:  BEGIN OF g_objky,                                    "216665
            ebeln LIKE ekpo-ebeln,                          "216665
            ebelp LIKE ekpo-ebelp,                          "216665
            abart LIKE ekek-abart,                          "216665
            abruf LIKE ekek-abruf,                          "216665
       END OF g_objky.                                      "216665

DATA: part       LIKE  msgpa  OCCURS 0     WITH HEADER LINE,
      xnast      LIKE  vnast  OCCURS 0     WITH HEADER LINE,
      ynast      LIKE  nast   OCCURS 0     WITH HEADER LINE,
      mess_sel   LIKE  nast-objky OCCURS 0 WITH HEADER LINE,
      xekkona    LIKE  zv_ekkona OCCURS 0   WITH HEADER LINE.
DATA: flag,                            "KEnnzeichen
      updat,                           "Nachrichtenfortschreibung
      subrc   LIKE sy-subrc,
      tmp_ebelp LIKE ekpo-ebelp,
      gf_count  TYPE i.                                        "846864
DATA: xauth.                                                "HW 308546
*-------------------- FELDER FÜR LISTVIEWER ---------------------------*
DATA: g_repid          LIKE sy-repid,
      g_fieldcat       TYPE slis_t_fieldcat_alv,
      g_it_sort        TYPE slis_t_sortinfo_alv,
      g_layout         TYPE slis_layout_alv,
      g_tabname_header TYPE slis_tabname,
      g_tabname_item   TYPE slis_tabname,
      g_tabname_grid   TYPE slis_tabname,
      g_keyinfo        TYPE slis_keyinfo_alv,
      g_variant        LIKE disvariant," Anzeigevariante
      i_slis_exit_by_user TYPE slis_exit_by_user.

*ENHANCEMENT-POINT RM06ENDR_ALV_02 SPOTS ES_RM06ENDR_ALV STATIC.
*----------------------------------------------------------------------*
*  Parameter und Select-Options                                        *
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK po_document WITH FRAME TITLE text-001.
SELECT-OPTIONS:
            s_ebeln FOR ekko-ebeln MATCHCODE OBJECT mekk,
            s_lifnr FOR ekko-lifnr MATCHCODE OBJECT kred,
            s_ekorg FOR ekko-ekorg MEMORY ID eko,
            s_ekgrp FOR ekko-ekgrp MEMORY ID ekg,
            s_bsart FOR ekko-bsart,
            s_bedat FOR ekko-bedat,
            s_ernam FOR ekko-ernam.             "ADDED_19032012
SELECTION-SCREEN END OF BLOCK po_document.

SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN BEGIN OF BLOCK release WITH FRAME TITLE text-003.
PARAMETERS :    p_werks LIKE ekpo-werks MODIF ID rel.
SELECT-OPTIONS: s_berid FOR ekpo-berid  MODIF ID ber,
                s_dispo FOR marc-dispo  MODIF ID rel.
PARAMETERS :    p_abart LIKE ekek-abart MODIF ID rel,
                p_reduc TYPE me_reduc   MODIF ID rel,
                p_norel TYPE me_norel   MODIF ID rel.
*ENHANCEMENT-POINT RM06ENDR_ALV_03 SPOTS ES_RM06ENDR_ALV STATIC.
SELECTION-SCREEN END OF BLOCK release.

SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN BEGIN OF BLOCK message WITH FRAME TITLE text-002.
PARAMETERS :     p_kappl LIKE t681a-kappl MODIF ID apl.
SELECT-OPTIONS:  s_kschl FOR t685b-kschl.
PARAMETERS:      p_vsztp LIKE nast-vsztp,
                 p_vstat LIKE nast-vstat DEFAULT '0',
                 p_erdat LIKE nast-erdat,
                 p_eruhr LIKE nast-eruhr.
SELECTION-SCREEN END OF BLOCK message.

*- Übergabetabellen für Select-Options ---------------------------------
RANGES:        r_objky FOR nast-objky,
               r_kappl FOR t685b-kappl,
               r_abart FOR ekek-abart,
               r_vstat FOR nast-vstat,
               r_vsztp FOR nast-vsztp,
               r_erdat FOR nast-erdat,
               r_eruhr FOR nast-eruhr,
               r_nacha FOR nast-nacha,
               r_bstyp FOR ekko-bstyp,
               r_werks FOR ekpo-werks.

*----------------------------------------------------------------------*
*  Initialization: set last document number and application            *
*----------------------------------------------------------------------*
INITIALIZATION.

*ENHANCEMENT-POINT RM06ENDR_ALV_15 SPOTS ES_RM06ENDR_ALV STATIC .

  IF t160 IS INITIAL.
    SELECT SINGLE * FROM  t160  WHERE  tcode = sy-tcode  .
    IF sy-subrc EQ 0.
      CASE t160-bstyp.
        WHEN 'F'.                      "Bestellung
          GET PARAMETER ID 'BES' FIELD s_ebeln-low.
          p_kappl = 'EF'.
          r_bstyp-low = 'F'.
        WHEN 'A'.                      "Anfrage
          GET PARAMETER ID 'ANF' FIELD s_ebeln-low.
          p_kappl = 'EA'.
          r_bstyp-low = 'A'.
        WHEN 'K'.                      "Kontrakt
          GET PARAMETER ID 'CTR' FIELD s_ebeln-low.
          IF s_ebeln-low IS INITIAL.
            GET PARAMETER ID 'VRT' FIELD s_ebeln-low.
          ENDIF.
          p_kappl = 'EV'.
          r_bstyp-low = 'K'.
        WHEN 'L'.                      "Lieferplan
          GET PARAMETER ID 'SAG' FIELD s_ebeln-low.
          IF s_ebeln-low IS INITIAL.
            GET PARAMETER ID 'VRT' FIELD s_ebeln-low.
          ENDIF.
          r_bstyp-low = 'L'.
          CASE t160-vorga.
            WHEN 'K'.                  "Lieferplanrahmen
              p_kappl = 'EV'.
            WHEN 'LE'.                 "Lieferplanabruf
              p_kappl = 'EL'.
          ENDCASE.
      ENDCASE.
      IF NOT s_ebeln-low IS INITIAL.
        s_ebeln-sign = 'I'.
        s_ebeln-option = 'EQ'.
        APPEND s_ebeln.
      ENDIF.
    ENDIF.
  ENDIF.
* determine message type
  GET PARAMETER ID 'NAC' FIELD s_kschl-low.                 "611742
  IF NOT s_kschl-low IS INITIAL.
    s_kschl-sign = 'I'.
    s_kschl-option = 'EQ'.
    APPEND s_kschl.
  ENDIF.
* determine whether Grid Control should be used
  CALL FUNCTION 'GET_ACCESSIBILITY_MODE'
    IMPORTING
      accessibility = gf_use_grid
    EXCEPTIONS
      OTHERS        = 0.
  IF gf_use_grid IS INITIAL.
    GET PARAMETER ID 'ME_USE_GRID' FIELD gf_use_grid.
  ENDIF.

AT SELECTION-SCREEN OUTPUT.
  SELECT SINGLE * FROM t000md.         " WHERE DISFG EQ 'X'.
*ENHANCEMENT-POINT RM06ENDR_ALV_04 SPOTS ES_RM06ENDR_ALV STATIC.


*ENHANCEMENT-POINT RM06ENDR_ALV_05 SPOTS ES_RM06ENDR_ALV.

  LOOP AT SCREEN.
    CASE screen-group1.
      WHEN 'REL'.
        IF p_kappl NE 'EL' AND p_kappl NE space.
          screen-input = '0'.
          screen-required = '0'.
          screen-invisible = '1'.
        ELSE.
          IF screen-name EQ 'P_WERKS'.
*           screen-required = '1'.
          ENDIF.
        ENDIF.
        MODIFY SCREEN.
      WHEN 'BER'.
        IF t000md-disfg IS INITIAL OR
           ( p_kappl NE 'EL' AND p_kappl NE space ).
          screen-active    = 0.
          screen-invisible = 1.
          MODIFY SCREEN.
        ENDIF.
    ENDCASE.
*ENHANCEMENT-POINT RM06ENDR_ALV_06 SPOTS ES_RM06ENDR_ALV.
  ENDLOOP.

*----------------------------------------------------------------------*
*  F4 help on the selection screen
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_kschl-low.
  CALL FUNCTION 'HELP_VALUES_KSCHL_PREPARE'
    EXPORTING
      program = sy-cprog
      dynnr   = sy-dynnr
    IMPORTING
      kschl   = s_kschl-low
    EXCEPTIONS
      OTHERS  = 1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_kschl-high.
  CALL FUNCTION 'HELP_VALUES_KSCHL_PREPARE'
    EXPORTING
      program = sy-cprog
      dynnr   = sy-dynnr
    IMPORTING
      kschl   = s_kschl-high
    EXCEPTIONS
      OTHERS  = 1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_kappl.
  CALL FUNCTION 'HELP_VALUES_KAPPL'
    IMPORTING
      kappl  = p_kappl
    EXCEPTIONS
      OTHERS = 1.



*----------------------------------------------------------------------*
*  Beginn der Selektion                                                *
*----------------------------------------------------------------------*
START-OF-SELECTION.

  CALL FUNCTION 'RV_MESSAGES_REFRESH'.
  PERFORM aktivitaet_setzen(sapfm06d) USING '04'.
  PERFORM ranges_fuellen.
  PERFORM daten_selektieren.
  IF sy-batch IS INITIAL.
    IF gf_use_grid EQ space.
      PERFORM variante_ermitteln.
      PERFORM fieldcat_init USING g_fieldcat[].
      PERFORM listausgabe.
    ELSE.
      PERFORM variante_ermitteln_grid.
      PERFORM fieldcat_init_grid USING g_fieldcat[].
      PERFORM listausgabe_grid.
    ENDIF.
  ELSE.
*ENHANCEMENT-SECTION     RM06ENDR_ALV_07 SPOTS ES_RM06ENDR_ALV.
    CLEAR gf_count.                                              "846864
    LOOP AT xitem.
      IF xitem-vstat = '0'.
        CLEAR: flag, tmp_ebelp.
        MOVE-CORRESPONDING xitem TO nast.
        IF xitem-kappl EQ 'EL' AND xitem-objky+10(5) NE '00000'.
          tmp_ebelp = xitem-objky+10(5).
          PERFORM position_sperren USING
                                   xitem-ebeln
                                   tmp_ebelp
                                   flag.
        ELSE.
          PERFORM beleg_sperren USING xitem-ebeln flag.
        ENDIF.
        IF NOT flag IS INITIAL. CONTINUE. ENDIF.
*       PERFORM EINZELNACHRICHT(RSNAST00) USING SUBRC.      " 361179
        CALL FUNCTION 'WFMC_MESSAGE_SINGLE'                 " 361179
          EXPORTING                                         " 361179
            pi_nast        = nast                           " 361179
          IMPORTING                                         " 361179
            pe_rcode       = subrc.                         " 361179
        IF xitem-kappl EQ 'EL' AND xitem-objky+10(5) NE '00000'."455903
          tmp_ebelp = xitem-objky+10(5).
          PERFORM position_entsperren USING
                                   xitem-ebeln
                                   tmp_ebelp.
        ELSE.
          PERFORM beleg_entsperren USING xitem-ebeln.
        ENDIF.
      ENDIF.
      IF gf_count > 50.                                          "846864
        COMMIT WORK.
        CLEAR gf_count.
      ELSE.
        gf_count = gf_count + 1.
      ENDIF.
    ENDLOOP.
*END-ENHANCEMENT-SECTION.
    COMMIT WORK.
  ENDIF.

*&---------------------------------------------------------------------*
*& Beginn der Unterroutinen
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  LISTAUSGABE
*&---------------------------------------------------------------------*
FORM ranges_fuellen.
*- Daten selektieren
  REFRESH: r_objky, r_vstat, r_vsztp, r_erdat, r_eruhr, r_kappl,
           r_bstyp, r_abart, r_werks.
  CLEAR  : r_objky, r_vstat, r_vsztp, r_erdat, r_eruhr, r_kappl,
           r_abart, r_werks.
  IF NOT r_bstyp-low IS INITIAL.
    r_bstyp-sign = 'I'.
    r_bstyp-option = 'EQ'.
    APPEND r_bstyp.
  ENDIF.
  LOOP AT s_ebeln.
    r_objky-sign = s_ebeln-sign.
    r_objky-option = s_ebeln-option.
    r_objky-low = s_ebeln-low.
    r_objky-high = s_ebeln-high.
    APPEND r_objky.
  ENDLOOP.
  IF NOT p_vstat IS INITIAL.
    r_vstat-sign   = 'I'.
    r_vstat-option = 'EQ'.
    r_vstat-low    = p_vstat.
    APPEND r_vstat.
  ENDIF.
  IF NOT p_vsztp IS INITIAL.
    r_vsztp-sign   = 'I'.
    r_vsztp-option = 'EQ'.
    r_vsztp-low    = p_vsztp.
    APPEND r_vsztp.
  ENDIF.
  IF NOT p_erdat IS INITIAL.
    r_erdat-sign   = 'I'.
    r_erdat-option = 'GE'.
    r_erdat-low    = p_erdat.
    APPEND r_erdat.
  ENDIF.
  IF NOT p_eruhr IS INITIAL.
    r_eruhr-sign   = 'I'.
    r_eruhr-option = 'GE'.
    r_eruhr-low    = p_eruhr.
    APPEND r_eruhr.
  ENDIF.
  IF NOT p_kappl IS INITIAL.
    r_kappl-sign = 'I'.
    r_kappl-option = 'EQ'.
    r_kappl-low    = p_kappl.
    APPEND r_kappl.
  ELSE.
    r_kappl-sign = 'I'.
    r_kappl-option = 'EQ'.
    r_kappl-low    = 'EA'. APPEND r_kappl.
    r_kappl-low    = 'EF'. APPEND r_kappl.
    r_kappl-low    = 'EV'. APPEND r_kappl.
    r_kappl-low    = 'EL'. APPEND r_kappl.
  ENDIF.
  IF NOT p_abart IS INITIAL.
    r_abart-sign   = 'I'.
    r_abart-option = 'EQ'.
    r_abart-low    = p_abart.
    APPEND r_abart.
  ELSE.
    r_abart-sign   = 'I'.
    r_abart-option = 'EQ'.
    r_abart-low    = '1'. APPEND r_abart.
    r_abart-low    = '2'. APPEND r_abart.
  ENDIF.
  IF NOT p_werks IS INITIAL.
    r_werks-sign   = 'I'.
    r_werks-option = 'EQ'.
    r_werks-low    = p_werks.
    APPEND r_werks.
  ENDIF.

ENDFORM.                    "ranges_fuellen

*&---------------------------------------------------------------------*
*&      Form  LISTAUSGABE
*&---------------------------------------------------------------------*
FORM listausgabe.

  g_layout-box_fieldname = 'BOX'.
  g_layout-box_tabname   = g_tabname_item.
  g_layout-zebra         = 'X'.
  g_layout-f2code        = '9NDE'.

  CLEAR g_keyinfo.
  g_keyinfo-header01 = 'EBELN'.
  g_keyinfo-item01   = 'EBELN'.


  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name                  = icon_checked
      info                  = text-010
    IMPORTING
      RESULT                = gf_icon_checked
    EXCEPTIONS
      icon_not_found        = 1
      outputfield_too_short = 2
      OTHERS                = 3.
  IF sy-subrc <> 0.
    gf_icon_checked = icon_checked.
  ENDIF.

  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name                  = icon_incomplete
      info                  = text-011
    IMPORTING
      RESULT                = gf_icon_incomplete
    EXCEPTIONS
      icon_not_found        = 1
      outputfield_too_short = 2
      OTHERS                = 3.
  IF sy-subrc <> 0.
    gf_icon_incomplete = icon_incomplete.
  ENDIF.


  LOOP AT xitem.
    IF xitem-vstat EQ '1'.
      xitem-symbol = gf_icon_checked.
      MODIFY xitem.
    ELSEIF xitem-vstat EQ '2'.
      xitem-symbol = gf_icon_incomplete.
      MODIFY xitem.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
       EXPORTING
*           I_INTERFACE_CHECK        = ' '
            i_callback_program       = g_repid
            i_callback_pf_status_set = 'STATUS'
            i_callback_user_command  = 'USER_COMMAND'
            is_layout                = g_layout
            it_fieldcat              = g_fieldcat[]
*           IT_EXCLUDING             =
*           IT_SPECIAL_GROUPS        =
*           it_sort                  = g_it_sort[]
*           IT_FILTER                =
*           IS_SEL_HIDE              =
*           i_default                = 'X'
            i_save                   = 'A'
            is_variant               = g_variant
            i_tabname_header         = g_tabname_header
            i_tabname_item           = g_tabname_item
*           IT_EVENTS                =
*           IT_EVENT_EXIT            =
*           IS_PRINT                 =
            is_keyinfo               = g_keyinfo
*           I_SCREEN_START_COLUMN    = 0
*           I_SCREEN_START_LINE      = 0
*           I_SCREEN_END_COLUMN      = 0
*           I_SCREEN_END_LINE        = 0
       IMPORTING
*           E_EXIT_CAUSED_BY_CALLER  =
            es_exit_caused_by_user   = i_slis_exit_by_user
       TABLES
            t_outtab_header          = xheader
            t_outtab_item            = xitem
       EXCEPTIONS
*           program_error            = 1
            OTHERS                   = 2.

  IF i_slis_exit_by_user-exit NE space OR
     i_slis_exit_by_user-back NE space OR
     i_slis_exit_by_user-cancel NE space.
    IF updat NE space.                 " wird nicht mehr verwendet
      CALL FUNCTION 'RV_MESSAGES_UPDATE'
        EXPORTING
          msg_no_update_task = 'X'.
    ENDIF.
    COMMIT WORK.
    IF sy-calld EQ space.
      LEAVE TO TRANSACTION sy-tcode.
    ELSE.
      LEAVE.
    ENDIF.
  ENDIF.

ENDFORM.                               " LISTAUSGABE


*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND                                             *
*&---------------------------------------------------------------------*
FORM user_command USING r_ucomm LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.
  DATA: retco LIKE sy-subrc,
        lf_flag,
        flag1, tmp_ebelp LIKE ekpo-ebelp.

  IF gf_use_grid NE space.
* get the selection from the grid control and update xitem
    FIELD-SYMBOLS: <xitem> LIKE LINE OF xitem.
    LOOP AT gt_outtab_grid WHERE box = 'X'.
      READ TABLE xitem ASSIGNING <xitem>
                       WITH KEY kappl = gt_outtab_grid-kappl
                                objky = gt_outtab_grid-objky
                                kschl = gt_outtab_grid-kschl
                                spras = gt_outtab_grid-spras
                                parnr = gt_outtab_grid-parnr
                                parvw = gt_outtab_grid-parvw
                                erdat = gt_outtab_grid-erdat
                                eruhr = gt_outtab_grid-eruhr.
      IF sy-subrc IS INITIAL.
        <xitem>-box = gt_outtab_grid-box.
      ENDIF.
    ENDLOOP.
  ENDIF.

  rs_selfield-refresh = 'X'.
  CASE r_ucomm.

    WHEN '9DET'.
*- da man den Fcode zum Verlassen der Anzeige nicht kennt, bzw.
*- analysieren kann, kann man nicht entscheiden, ob die Anzeige
*- abgebrochen werden soll.
      LOOP AT xitem WHERE box = 'X'.
        CLEAR xitem-box.
        MODIFY xitem.
        CALL FUNCTION 'ME_DISPLAY_PURCHASE_DOCUMENT'
          EXPORTING
            i_ebeln        = xitem-ebeln
            i_display_only = 'X'
            i_enjoy        = 'X'
          EXCEPTIONS
            OTHERS         = 4.

        IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.
        EXIT.
      ENDLOOP.

    WHEN '9AUS'.                       "Nachrichten ausgeben
      LOOP AT xitem WHERE box = 'X'.
        IF xitem-vstat NE '0'.
          CLEAR xitem-box.
          MODIFY xitem.
          MESSAGE s845 WITH space xitem-datvr xitem-uhrvr.
          EXIT.                        "continue.
        ENDIF.
        CLEAR xitem-box.
        IF xitem-kappl EQ 'EL' AND xitem-objky+10(5) NE '00000'.
          tmp_ebelp = xitem-objky+10(5).
          PERFORM position_sperren USING
                                   xitem-ebeln
                                   tmp_ebelp
                                   flag1.
        ELSE.
          PERFORM beleg_sperren USING xitem-ebeln flag1.
        ENDIF.
        IF NOT flag1 IS INITIAL.
          MODIFY xitem.
          CHECK 1 = 2.                                     "note 399088
        ENDIF.
*------ Nast nachlesen und übernehmen
        MOVE-CORRESPONDING xitem TO nast.
        SELECT SINGLE * FROM  nast
           WHERE  kappl       = nast-kappl
           AND    objky       = nast-objky
           AND    kschl       = nast-kschl
           AND    spras       = nast-spras
           AND    parnr       = nast-parnr
           AND    parvw       = nast-parvw
           AND    erdat       = nast-erdat
           AND    eruhr       = nast-eruhr.
        IF sy-subrc EQ 0.
          MOVE-CORRESPONDING nast TO xitem.
          IF nast-vstat NE '0'.
            xitem-symbol = gf_icon_checked.
            MODIFY xitem.
            MESSAGE s845 WITH space xitem-datvr xitem-uhrvr.
            EXIT.                      "message w175(me).
          ENDIF.
        ENDIF.
*       move-corresponding xitem to nast.
        CLEAR nast-sndex.                                   "196293
*       PERFORM EINZELNACHRICHT(RSNAST00) USING RETCO.      " 361179
        CALL FUNCTION 'WFMC_MESSAGE_SINGLE'                 " 361179
          EXPORTING                                         " 361179
            pi_nast        = nast                           " 361179
          IMPORTING                                         " 361179
            pe_rcode       = retco.                         " 361179
        IF xitem-kappl EQ 'EL' AND xitem-objky+10(5) NE '00000'."455903
          tmp_ebelp = xitem-objky+10(5).
          PERFORM position_entsperren USING
                                   xitem-ebeln
                                   tmp_ebelp.
        ELSE.
          PERFORM beleg_entsperren USING xitem-ebeln.
        ENDIF.
        IF retco EQ 0 OR retco EQ 2.
          xitem-vstat = '1'.
          xitem-datvr = nast-datvr.
          xitem-uhrvr = nast-uhrvr.
          xitem-symbol = gf_icon_checked.
        ELSEIF retco NE 3.
          xitem-vstat = '2'.
          xitem-symbol = gf_icon_incomplete.
        ENDIF.
        MODIFY xitem.
      ENDLOOP.
      COMMIT WORK.                     " note 353318

    WHEN '9DPR'.                       "Nachrichten ausgeben Probedruck
      LOOP AT xitem WHERE box = 'X'.
        CLEAR xitem-box.
        MODIFY xitem.                                       "196996
        IF xitem-nacha NE '1' AND                           "196996
           xitem-nacha NE '2' AND                           "196996
           xitem-nacha NE '3' AND                           "196996
*           xitem-nacha NE '4'.                              "196996
           xitem-nacha NE '4' AND                           "547724
           xitem-nacha NE '5'.                              "547724
          MESSAGE e254 WITH xitem-nacha.                    "196996
          CONTINUE.                                         "196996
        ENDIF.                                              "196996
        IF xitem-vstat = '0'.
          MOVE-CORRESPONDING xitem TO nast.
          nast-tdarmod = '1'.                               "#168591
          nast-anzal = '1'.                                 "180648
          nast-sndex = 'X'.                                 "196293
*         PERFORM EINZELNACHRICHT_OHNE_UPDATE(RSNAST00) USING RETCO.
          CALL FUNCTION 'WFMC_MESSAGE_SINGLE_NO_UPDATE'     " 361179
            EXPORTING                                       " 361179
              pi_nast        = nast                         " 361179
            IMPORTING                                       " 361179
              pe_rcode       = retco.                       " 361179
*          if retco eq 0 or retco eq 2.          "154920
*           xitem-vstat = '1'.                   "154920
*            xitem-symbol = icon_checked.        "154920
*          elseif retco ne 3.                    "154920
*           xitem-vstat = '2'.                   "154920
*            xitem-symbol = icon_incomplete.     "154920
*          endif.                                "154920
        ENDIF.
        MODIFY xitem.
      ENDLOOP.

    WHEN '9ANZ'.                       "Nachrichten anzeigen
      LOOP AT xitem WHERE box = 'X'.
        CLEAR  xitem-box.
        MODIFY xitem.
        IF xitem-nacha NE '1' AND
           xitem-nacha NE '2' AND
           xitem-nacha NE '3' AND
*           xitem-nacha NE '4'.
           xitem-nacha NE '4' AND                           "547724
           xitem-nacha NE '5'.                              "547724
          MESSAGE e255 WITH xitem-nacha.
          CONTINUE.
        ENDIF.
        MOVE-CORRESPONDING xitem TO nast.
        IF xitem-nacha NE '5'.                              "547724
          nast-tcode = 'XTST'.
        ENDIF.                                              "547724
*       PERFORM EINZELNACHRICHT_SCREEN(RSNAST00) USING RETCO." 361179
        CALL FUNCTION 'WFMC_MESSAGE_SINGLE_SCREEN'          " 361179
          EXPORTING                                         " 361179
            pi_nast        = nast                           " 361179
          IMPORTING                                         " 361179
            pe_rcode       = retco.                         " 361179
        IF retco EQ 1.                                      " 383479
          IF sy-msgty = 'W'.                                "450617
            sy-msgty = 'I'.                                 "450617
          ENDIF.                                            "450617
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno " 383479
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4. " 383479
*          EXIT.                                            " 383479
          CONTINUE.                                         "450617
        ENDIF.                                              " 383479

*---    bei 'Abbrechen' keine nachfolgenden Belege anzeigen
        IF retco EQ 9.
          EXIT.
        ENDIF.
      ENDLOOP.

    WHEN '9NDE'.                       "Nachrichtendetailfunktion
      LOOP AT xitem WHERE box = 'X'.
        CLEAR xitem-box.
        MODIFY xitem.
        IF xitem-kappl EQ 'EL' AND xitem-objky+10(5) NE '00000'.
          tmp_ebelp = xitem-objky+10(5).
          PERFORM position_sperren USING
                                   xitem-ebeln
                                   tmp_ebelp
                                   flag1.
        ELSE.
          PERFORM beleg_sperren USING xitem-ebeln flag1.
        ENDIF.
        IF NOT flag1 IS INITIAL.
          MODIFY xitem.
          EXIT.
        ENDIF.
*------ Nast nachlesen und übernehmen
        MOVE-CORRESPONDING xitem TO nast.
        SELECT SINGLE * FROM  nast
           WHERE  kappl       = nast-kappl
           AND    objky       = nast-objky
           AND    kschl       = nast-kschl
           AND    spras       = nast-spras
           AND    parnr       = nast-parnr
           AND    parvw       = nast-parvw
           AND    erdat       = nast-erdat
           AND    eruhr       = nast-eruhr.
        IF sy-subrc EQ 0.
          MOVE-CORRESPONDING nast TO xitem.
          IF nast-vstat EQ '1'.                             " 390537
            xitem-symbol = gf_icon_checked.                 " 390537
            MODIFY xitem.                                   " 390537
          ELSEIF nast-vstat EQ '2'.                         " 390537
            xitem-symbol = gf_icon_incomplete.              " 390537
            MODIFY xitem.                                   " 390537
          ENDIF.                                            " 390537
        ENDIF.
        CLEAR ekko.                                         "199775
        READ TABLE xheader WITH KEY ebeln = xitem-ebeln.
        IF sy-subrc EQ 0.
          MOVE-CORRESPONDING xheader TO ekko.
        ENDIF.
        PERFORM nachricht_detail USING ekko nast            " 424036
                               CHANGING lf_flag.            " 424036
        IF NOT lf_flag IS INITIAL.                          " 424036
          EXIT.                                             " 424036
        ENDIF.                                              " 424036
        IF xitem-kappl EQ 'EL' AND xitem-objky+10(5) NE '00000'."455903
          tmp_ebelp = xitem-objky+10(5).
          PERFORM position_entsperren USING
                                   xitem-ebeln
                                   tmp_ebelp.
        ELSE.
          PERFORM beleg_entsperren USING xitem-ebeln.
        ENDIF.
      ENDLOOP.
  ENDCASE.

  IF gf_use_grid NE space.
* update grid output table
    LOOP AT gt_outtab_grid WHERE box NE space.
      READ TABLE xitem ASSIGNING <xitem>
                   WITH KEY kappl = gt_outtab_grid-kappl
                            objky = gt_outtab_grid-objky
                            kschl = gt_outtab_grid-kschl
                            spras = gt_outtab_grid-spras
                            parnr = gt_outtab_grid-parnr
                            parvw = gt_outtab_grid-parvw
                            erdat = gt_outtab_grid-erdat
                            eruhr = gt_outtab_grid-eruhr.
      IF sy-subrc IS INITIAL.
        MOVE-CORRESPONDING <xitem> TO gt_outtab_grid.
        MODIFY gt_outtab_grid.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                               " USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  STATUS
*&---------------------------------------------------------------------*
FORM status USING extab TYPE slis_t_extab.

  SET PF-STATUS 'STANDARD' EXCLUDING extab.

ENDFORM.                               " STATUS

*&---------------------------------------------------------------------*
*&      Form  STATUS
*&---------------------------------------------------------------------*
FORM nachricht_detail USING l_ekko STRUCTURE ekko
                            l_nast STRUCTURE nast
                   CHANGING ef_flag TYPE c.                 " 424036
  DATA: beltext LIKE dv70a-btext,
        vorga LIKE t160-vorga,
        fdpos LIKE sy-fdpos,
        business_object LIKE nast-objtype,
        fcode(4),
        answer,
        nupdat,
        bildtext(40).

  CALL FUNCTION 'RV_MESSAGES_PURGE'
    EXPORTING
      msg_objky = l_nast-objky.

  RANGES: t_objky FOR nast-objky.
* read table mess_sel with key l_nast-objky.
*  if sy-subrc ne 0.
* append l_nast-objky to mess_sel.
  CLEAR t_objky. REFRESH t_objky.
  t_objky-sign = 'I'.
  t_objky-option = 'EQ'.
  t_objky-low = l_nast-objky.
  APPEND t_objky.

  DATA:  lf_vstat LIKE nast-vstat.                          "425545

  IF p_vstat = '0'.                                         "425545
    lf_vstat = p_vstat.                                     "425545
  ELSE.                                                     "425545
    lf_vstat = ' '.                                         "425545
  ENDIF.                                                    "425545

  CALL FUNCTION 'RV_MESSAGES_SELECT'
       EXPORTING
            msg_erdat = p_erdat
            msg_eruhr = p_eruhr
*            msg_vstat = p_vstat                             "425545
            msg_vstat = lf_vstat                            "425545
            msg_vsztp = p_vsztp
       TABLES
            s_kschl   = s_kschl
            s_nacha   = r_nacha
            s_objky   = t_objky
            s_kappl   = r_kappl.
*  endif.

*-- Füllen Bildtext und Nachrichtenapplikation ------------------------*
  CLEAR beltext.
  CASE l_ekko-bstyp.
    WHEN 'F'.  beltext = text-004.  business_object = 'BUS2012'.
    WHEN 'A'.  beltext = text-005.  business_object = 'BUS2010'.
    WHEN 'L'.  beltext = text-006.  business_object = 'BUS2013'.
    WHEN 'K'.  beltext = text-007.  business_object = 'BUS2014'.
  ENDCASE.

  fdpos = strlen( beltext ).
  WRITE '....................' TO beltext+fdpos(19).
  WRITE space      TO beltext+20(1).
  WRITE l_ekko-ebeln TO beltext+21.
  bildtext = text-008.

*-- Partnertabelle für Übergabe an Nachrichtensteuerung füllen --------*
  CLEAR t161n.
  SELECT SINGLE * FROM t161n WHERE kvewe EQ 'B'
                             AND kappl EQ l_nast-kappl.
  CLEAR vorga.
  IF l_nast-kappl EQ 'EL'.
    vorga = 'LE'. business_object = 'BUS2013002'.
  ELSEIF l_nast-kappl EQ 'EV'.
    vorga = 'K'.
  ENDIF.

  CALL FUNCTION 'MM_REFRESH_PARTNERS'.

  CALL FUNCTION 'MM_PARTNERS_FOR_MESSAGING'
    EXPORTING
      application = 'P'
      vorga       = vorga
      neupr       = t161n-neupr
      iekko       = l_ekko
    TABLES
      part        = part
    EXCEPTIONS
      OTHERS      = 1.

  CLEAR: t185, t185f, t185v.
  t185-panel = 'NUEB'.
  t185-bldgr = 'N0  '.
  t185f-fcode = 'ENT1'.
  t185f-trtyp = 'V'.

* Begin of Note 784213.
* For Building XNAST Before BASIS SCREEN IS CALLED.

  CALL FUNCTION 'RV_MESSAGES_READ'
       EXPORTING
            msg_kappl    = l_nast-kappl
            msg_objky    = l_nast-objky" voher ekko-ebeln.
            msg_objky_to = l_nast-objky.


  CALL FUNCTION 'RV_MESSAGES_GET'
       EXPORTING
            msg_kappl      = l_nast-kappl
            msg_objky_from =
               l_nast-objky            "wegen externer Nummernvergabe
            msg_objky_to   = l_nast-objky
       TABLES
            tab_xnast      = xnast
            tab_ynast      = ynast.

* End of Note 784213.

  CALL FUNCTION 'RV_MESSAGES_MAINTENANCE'
    EXPORTING
      min_btext    = beltext
      min_cua_text = bildtext
      min_kappl    = l_nast-kappl
      min_kalsm    = t161n-kalsm
      min_objky    = l_nast-objky
      min_t185     = t185
      min_t185f    = t185f
      min_t185v    = t185v
      pi_objtype   = business_object
    IMPORTING
      mex_fcode    = fcode
      mex_t185f    = t185f
      mex_t185v    = t185v
      mex_updat    = nupdat
      cancelled    = ef_flag                                " 424036
    TABLES
      mtb_part     = part.
  IF nupdat NE space AND fcode NE 'SICH'.
    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
      EXPORTING
        textline1 = text-301
        textline2 = text-302
        titel     = text-300
      IMPORTING
        answer    = answer.
    CASE answer.
      WHEN 'J'.
        fcode = 'SICH'.
    ENDCASE.
  ENDIF.
  IF nupdat NE space AND fcode EQ 'SICH'.
    CALL FUNCTION 'RV_MESSAGES_GET'
      EXPORTING
        msg_kappl      = l_nast-kappl
        msg_objky_from = l_nast-objky
        msg_objky_to   = l_nast-objky
      TABLES
        tab_xnast      = xnast
        tab_ynast      = ynast.
    IF fcode EQ 'SICH'.
      CALL FUNCTION 'RV_MESSAGES_UPDATE'
        EXPORTING
          msg_no_update_task = ' '.                         "183440
    ENDIF.
    COMMIT WORK AND WAIT.                                   "183440

* Begin of Note 784213.
* Sort the table before building XITEM.

SORT xnast BY objky kschl spras parnr parvw erdat eruhr aktiv DESCENDING.

* End of Note 784213.

    LOOP AT xnast WHERE objky EQ l_nast-objky.
      IF NOT xnast-updat IS INITIAL OR
             xnast-aktiv NE space.
        DELETE xitem WHERE objky EQ xnast-objky
                    AND   kschl EQ xnast-kschl
                    AND   spras EQ xnast-spras
                    AND   parnr EQ xnast-parnr
                    AND   parvw EQ xnast-parvw
                    AND   erdat EQ xnast-erdat
                    AND   eruhr EQ xnast-eruhr.
        CONTINUE.
      ENDIF.
      LOOP AT xitem WHERE objky EQ xnast-objky
                    AND   kschl EQ xnast-kschl
                    AND   spras EQ xnast-spras
                    AND   parnr EQ xnast-parnr
                    AND   parvw EQ xnast-parvw
                    AND   erdat EQ xnast-erdat
                    AND   eruhr EQ xnast-eruhr.
        MOVE-CORRESPONDING xnast TO xitem.
        MODIFY xitem.
      ENDLOOP.
      IF sy-subrc NE 0.
        CHECK xnast-vstat IN r_vstat.
        CHECK xnast-vsztp IN r_vsztp.
        CHECK xnast-erdat IN r_erdat.
        CHECK xnast-eruhr IN r_eruhr.
        MOVE-CORRESPONDING xnast TO xitem.
        CLEAR xitem-symbol.            "bei vsztp 4 nicht aktuell
        MOVE xnast-objky(10) TO xitem-ebeln.
        APPEND xitem.
      ENDIF.
    ENDLOOP.
    MESSAGE s224.
  ENDIF.
  CALL FUNCTION 'RV_MESSAGES_PURGE'
    EXPORTING
      msg_objky = l_nast-objky.
ENDFORM.                    "nachricht_detail

* ---------------------------------------------------------------------*
*&      Form  STATUS
*&---------------------------------------------------------------------*
FORM beleg_sperren USING xebeln LIKE ekko-ebeln
                         l_flag.
*- immer prüfen, ob Beleg nicht gerade geändert wird ------------------*
*- wegen Änderung der Nachrichtenparameter und Druckstatus ------------*

  CALL FUNCTION 'ENQUEUE_EMEKKOE'
    EXPORTING
      ebeln          = xebeln
    EXCEPTIONS
      foreign_lock   = 1
      system_failure = 2
      OTHERS         = 3.
  CASE sy-subrc.
    WHEN '0000'.                    "note 399088
      CLEAR l_flag.                 "note 399088
    WHEN '0001'.
      l_flag = 'X'.
      MESSAGE s006 WITH sy-msgv1 text-009 xebeln  space.
    WHEN '0002'.
      l_flag = 'X'.
      MESSAGE s007 WITH text-009 xebeln.
  ENDCASE.
ENDFORM.                    "beleg_sperren

*---------------------------------------------------------------------*
*       FORM BELEG_ENTSPERREN                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  XEBELN                                                        *
*---------------------------------------------------------------------*
FORM beleg_entsperren USING xebeln LIKE ekko-ebeln.
*- immer prüfen, ob Beleg nicht gerade geändert wird ------------------*
*- wegen Änderung der Nachrichtenparameter und Druckstatus ------------*

  CALL FUNCTION 'DEQUEUE_EMEKKOE'
    EXPORTING
      ebeln = xebeln.
ENDFORM.                    "beleg_entsperren
*&---------------------------------------------------------------------*
*&      Form  VARIANTE_ERMITTELN
*&---------------------------------------------------------------------*
FORM variante_ermitteln.
  CLEAR g_variant.
  g_repid = sy-repid.
  g_variant-report = g_repid.
  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
    EXPORTING
      i_save     = 'A'
    CHANGING
      cs_variant = g_variant
    EXCEPTIONS
      not_found  = 2
      OTHERS     = 4.
*  IF sy-subrc <> 0.
*    CLEAR g_variant.
*  ENDIF.
ENDFORM.                               " VARIANTE_ERMITTELN

*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_INIT
*&---------------------------------------------------------------------*
FORM fieldcat_init USING  l_fieldcat TYPE slis_t_fieldcat_alv.
  DATA: fieldcat TYPE slis_fieldcat_alv.

  g_tabname_header = 'XHEADER'.
  g_tabname_item   = 'XITEM'.

*- Liste aus NAST automat. erzeugen
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_internal_tabname     = g_tabname_item
      i_structure_name       = 'NAST'
      i_client_never_display = 'X'
    CHANGING
      ct_fieldcat            = l_fieldcat
    EXCEPTIONS
      OTHERS                 = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
*- Ergebnisse modifizieren
  LOOP AT l_fieldcat INTO fieldcat.
    CASE fieldcat-fieldname.
      WHEN 'KAPPL'.
        CLEAR fieldcat-key.
        fieldcat-no_out = 'X'.
      WHEN 'OBJKY'.
        CLEAR fieldcat-key.
        fieldcat-no_out = 'X'.
      WHEN 'KSCHL'.
        CLEAR fieldcat-key.
        fieldcat-emphasize = 'X'.
      WHEN 'SPRAS'.
        CLEAR fieldcat-key.
      WHEN 'PARNR'.
        CLEAR fieldcat-key.
      WHEN 'PARVW'.
        CLEAR fieldcat-key.
      WHEN 'ERDAT'.
        CLEAR fieldcat-key.
      WHEN 'ERUHR'.
        CLEAR fieldcat-key.
      WHEN 'VSZTP'.
      WHEN 'MANUE'.
      WHEN 'ERNAM'.
      WHEN 'USNAM'.
      WHEN 'LDEST'.
      WHEN 'DSNAM'.
      WHEN 'TELFX'.
      WHEN 'AENDE'.
      WHEN OTHERS.
        fieldcat-no_out = 'X'.
    ENDCASE.
    MODIFY l_fieldcat FROM fieldcat.
  ENDLOOP.
* Belegnummer
  CLEAR fieldcat.
  fieldcat-fieldname    = 'EBELN'.
  fieldcat-tabname      =  g_tabname_header.
  fieldcat-ref_tabname  = 'EKKO'.
  APPEND fieldcat TO l_fieldcat.
* Lieferant
  CLEAR fieldcat.
  fieldcat-fieldname    = 'LIFNR'.
  fieldcat-tabname      =  g_tabname_header.
  fieldcat-ref_tabname  = 'EKKO'.
  APPEND fieldcat TO l_fieldcat.
* Lieferantenname
  CLEAR fieldcat.
  fieldcat-fieldname    = 'NAME1'.
  fieldcat-tabname      =  g_tabname_header.
  fieldcat-ref_tabname  = 'LFA1'.
  APPEND fieldcat TO l_fieldcat.
* Einkäufergruppe
  CLEAR fieldcat.
  fieldcat-fieldname    = 'EKGRP'.
  fieldcat-tabname      =  g_tabname_header.
  fieldcat-ref_tabname  = 'EKKO'.
  APPEND fieldcat TO l_fieldcat.
* Belegdatum
  CLEAR fieldcat.
  fieldcat-fieldname    = 'BEDAT'.
  fieldcat-tabname      =  g_tabname_header.
  fieldcat-ref_tabname  = 'EKKO'.
  APPEND fieldcat TO l_fieldcat.
* CREATED BY
  CLEAR fieldcat.
  fieldcat-fieldname    = 'ERNAM'.
  fieldcat-tabname      =  g_tabname_header.
  fieldcat-ref_tabname  = 'EKKO'.
  APPEND fieldcat TO l_fieldcat.


* Belegdatum
  CLEAR fieldcat.
  fieldcat-fieldname    = 'SYMBOL'.
  fieldcat-tabname      =  g_tabname_item.
  fieldcat-icon         = 'X'.
  fieldcat-col_pos      = 0.
  fieldcat-outputlen    = 2.
  APPEND fieldcat TO l_fieldcat.


ENDFORM.                               " FIELDCAT_INIT
*&---------------------------------------------------------------------*
*&      Form  DATEN_SELEKTIEREN
*&---------------------------------------------------------------------*
FORM daten_selektieren.
  DATA xebeln LIKE ekko-ebeln.
*ENHANCEMENT-POINT RM06ENDR_ALV_08 SPOTS ES_RM06ENDR_ALV STATIC.
*- zuerst Nachrichten auf Kopfebene ermitteln
  REFRESH: xheader, xitem.
  IF p_reduc EQ space.
    REFRESH xekkona.
    IF r_werks IS INITIAL.             "Begin of 555807
      SELECT * FROM zv_ekkona INTO TABLE xekkona
             WHERE ebeln IN r_objky        AND kappl IN r_kappl
               AND lifnr IN s_lifnr        AND kschl IN s_kschl
               AND ekorg IN s_ekorg        AND erdat IN r_erdat
               AND ekgrp IN s_ekgrp        AND eruhr IN r_eruhr
               AND bedat IN s_bedat        AND vsztp IN r_vsztp
               AND bsart IN s_bsart        AND vstat IN r_vstat
               AND ernam IN s_ernam
               AND bstyp IN r_bstyp        AND aktiv EQ space
               AND loekz EQ space          AND snddr EQ space
      ORDER BY kappl ebeln kschl erdat.
    ELSE.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE xekkona
             FROM ekpo AS p INNER JOIN zv_ekkona AS k
             ON p~ebeln = k~ebeln
             WHERE k~ebeln IN r_objky        AND k~kappl IN r_kappl
               AND k~lifnr IN s_lifnr        AND k~kschl IN s_kschl
               AND k~ekorg IN s_ekorg        AND k~erdat IN r_erdat
               AND k~ekgrp IN s_ekgrp        AND k~eruhr IN r_eruhr
               AND k~bedat IN s_bedat        AND k~vsztp IN r_vsztp
               AND k~bsart IN s_bsart        AND k~vstat IN r_vstat
               AND k~bstyp IN r_bstyp        AND k~aktiv EQ space
               AND k~loekz EQ space          AND k~snddr EQ space
               AND p~werks IN r_werks
      ORDER BY K~KAPPL k~ebeln K~KSCHL k~erdat.
*     Remove all double entries caused by several items         581531
      DELETE ADJACENT DUPLICATES FROM xekkona.              "581531
    ENDIF.                             "End of 555807

*- Daten in Kopf- und Positionstabelle teilen
    LOOP AT xekkona.
      CLEAR: xitem, xheader.
      MOVE-CORRESPONDING xekkona TO xitem.
      MOVE-CORRESPONDING xekkona TO ekko.
      MOVE xekkona-ekspras TO ekko-spras.
      MOVE xekkona-ekadrnr TO ekko-adrnr.
      xitem-ebeln = xekkona-ebeln.
      PERFORM berechtigungen_kopf(sapfm06d).                "HW 308546
      IF sy-subrc NE 0.                                     "HW 308546
        xauth = 'X'.                                        "HW 308546
        CONTINUE.                                           "HW 308546
      ENDIF.                                                "HW 308546
*     Check Disponent                                          "352785
      IF NOT s_dispo IS INITIAL.                            "352785
        SELECT SINGLE * FROM flaber WHERE ebeln = xitem-ebeln"352785
                                      AND dispo IN s_dispo. "352785
        IF sy-subrc NE 0.                                   "352785
          CONTINUE.                                         "352785
        ENDIF.                                              "352785
      ENDIF.                                                "352785
      APPEND xitem.
      AT NEW ebeln.
*ENHANCEMENT-POINT RM06ENDR_ALV_09 SPOTS ES_RM06ENDR_ALV.
        MOVE-CORRESPONDING ekko TO xheader.
*------ Lieferantennamen besorgen ------------------------------*
        CALL FUNCTION 'MM_ADDRESS_GET'
          EXPORTING
            i_ekko  = ekko
          IMPORTING
            e_name1 = addr1_val-name1
          EXCEPTIONS
            OTHERS  = 1.
        MOVE addr1_val-name1 TO xheader-name1.         "offset???
        APPEND xheader.
      ENDAT.
    ENDLOOP.
  ENDIF.
*- Falls Applikation 'EL', dann auch auf Abrufebene suchen
  IF ( p_kappl EQ 'EL' OR p_kappl IS INITIAL ) AND p_norel IS INITIAL.
    REFRESH: ekpo_short, xnast.
    SELECT * FROM v_ekkopo
      INTO CORRESPONDING FIELDS OF TABLE ekpo_short
         WHERE ebeln IN s_ebeln       AND lphis NE space
           AND lifnr IN s_lifnr       AND werks IN r_werks
           AND ekorg IN s_ekorg       AND abart IN r_abart
           AND ekgrp IN s_ekgrp       AND berid IN s_berid
           AND bedat IN s_bedat       AND dispo IN s_dispo
           AND bsart IN s_bsart
           AND bstyp IN r_bstyp
   ORDER BY EBELN.
    LOOP AT ekpo_short.                                   "1288416
      move-corresponding ekpo_short to ekko.              "1386395
      PERFORM berechtigungen_kopf(sapfm06d).
      IF sy-subrc NE 0.
        xauth = 'X'.
        DELETE ekpo_short.
        CONTINUE.
      ENDIF.
      move-corresponding ekpo_short to ekpo.              "1386395
      PERFORM berechtigungen_pos(sapfm06d).               "1386395
      IF sy-subrc NE 0.                                   "1386395
        xauth = 'X'.                                      "1386395
        DELETE ekpo_short.                                "1386395
        CONTINUE.                                         "1386395
      ENDIF.                                              "1386395
        MOVE:       ekpo_short-ebeln TO g_objky-ebeln,
                    ekpo_short-ebelp TO g_objky-ebelp,
                    ekpo_short-abart TO g_objky-abart,
                    ekpo_short-abruf TO g_objky-abruf,
                    g_objky TO ekpo_short-objky.
        MODIFY ekpo_short.
      ENDLOOP.
    IF NOT ekpo_short[] IS INITIAL.
      SELECT * FROM nast INTO TABLE xnast FOR ALL ENTRIES IN ekpo_short
          WHERE objky EQ ekpo_short-objky
            AND kappl IN r_kappl
            AND kschl IN s_kschl
            AND erdat IN r_erdat
            AND eruhr IN r_eruhr
            AND vsztp IN r_vsztp
            AND vstat IN r_vstat
            AND snddr EQ space
            AND aktiv EQ space.
*- xheader und xitem erweitern
      CLEAR xebeln.
*ENHANCEMENT-SECTION     RM06ENDR_ALV_10 SPOTS ES_RM06ENDR_ALV.
      LOOP AT xnast.
        CLEAR: xitem, xheader.
        MOVE-CORRESPONDING xnast TO xitem.
        MOVE xnast-objky(10) TO xitem-ebeln.
        APPEND xitem.
        IF xitem-ebeln NE xebeln.
          READ TABLE xheader WITH KEY ebeln = xitem-ebeln.
"$$
"$$
"$$
"$$
"$$
"$$
"$$
"$$
"$$
"$$
"$$
"$$
"$$
"$$
"$$
          IF sy-subrc NE 0.
            READ TABLE ekpo_short WITH KEY ebeln = xitem-ebeln.
"$$
"$$
            IF sy-subrc EQ 0.
              CLEAR ekko.
              MOVE-CORRESPONDING ekpo_short TO xheader.
              MOVE-CORRESPONDING ekpo_short TO ekko.
*------ Lieferantennamen besorgen ------------------------------*
              CALL FUNCTION 'MM_ADDRESS_GET'
                EXPORTING
                  i_ekko  = ekko
                IMPORTING
                  e_name1 = addr1_val-name1
                EXCEPTIONS
                  OTHERS  = 1.
              MOVE addr1_val-name1 TO xheader-name1.      "offset???
              APPEND xheader.
"$$
"$$
"$$
"$$
"$$
"$$
            ENDIF.
          ENDIF.
        ENDIF.
"$$
"$$
      ENDLOOP.
*END-ENHANCEMENT-SECTION.
    ENDIF.
    SORT xnast BY kappl objky kschl erdat.
  ENDIF.
*- Kein Einkaufsbeleg zum Ausgeben - raus -----------------------------*
*ENHANCEMENT-SECTION     RM06ENDR_ALV_11 SPOTS ES_RM06ENDR_ALV.
  IF xheader[] IS INITIAL.
"$$
"$$
"$$
"$$
"$$
    IF xauth EQ space.                                      "HW 308546
      MESSAGE s260.
    ELSE.                                                   "HW 308546
      MESSAGE s236.                                         "HW 308546
    ENDIF.                                                  "HW 308546
    IF sy-calld NE space.
      LEAVE.
    ELSE.
      LEAVE TO TRANSACTION sy-tcode.
    ENDIF.
    EXIT.
  ENDIF.
*END-ENHANCEMENT-SECTION.
  IF xauth NE space.                                        "HW 308546
    MESSAGE s235(me).                                       "HW 308546
  ENDIF.                                                    "HW 308546
ENDFORM.                               " DATEN_SELEKTIEREN
"$$
"$$
"$$
"$$
"$$
"$$
"$$
"$$
"$$
"$$
"$$
"$$
"$$
"$$
"$$
"$$
"$$
"$$
"$$
"$$
"$$
"$$
*ENHANCEMENT-POINT RM06ENDR_ALV_12 SPOTS ES_RM06ENDR_ALV STATIC.
*&---------------------------------------------------------------------*
*&      Form  POSITION_SPERREN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_XITEM_OBJKY(10)  text
*      -->P_XITEM_OBJKY+10(5)  text
*      -->P_FLAG1  text
*----------------------------------------------------------------------*
FORM position_sperren USING    ebeln LIKE ekpo-ebeln
                               ebelp LIKE ekpo-ebelp
                               l_flag.
  CALL FUNCTION 'ENQUEUE_EMEKPOE'
    EXPORTING
      ebeln          = ebeln
      ebelp          = ebelp
    EXCEPTIONS
      foreign_lock   = 2
      system_failure = 3.
  CASE sy-subrc.
    WHEN '0000'.                      "note 399088
      CLEAR l_flag.                   "note 399088
    WHEN '0002'.                                                 "625331
      l_flag = 'X'.
      MESSAGE s006 WITH sy-msgv1 text-009 ebeln  space.
    WHEN '0003'.                                                 "625331
      l_flag = 'X'.
      MESSAGE s007 WITH text-009 ebeln.
  ENDCASE.
ENDFORM.                    " POSITION_SPERREN
*&---------------------------------------------------------------------*
*&      Form  position_entsperren
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_XITEM_EBELN  text
*      -->P_TMP_EBELP  text
*----------------------------------------------------------------------*
FORM position_entsperren  USING    ebeln
                                   ebelp.
  CALL FUNCTION 'DEQUEUE_EMEKPOE'
    EXPORTING
      ebeln = ebeln
      ebelp = ebelp.

ENDFORM.                    " position_entsperren

* Grid control routines
INCLUDE zrm06endr_alv_grid.
