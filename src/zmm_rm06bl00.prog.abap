************************************************************************
*        Listanzeige Bestellanforderungen                              *
************************************************************************
* FRICE#     : MMGBE_013
* Title      : PR Source Determination
* Author     : Ellen H. Lagmay
* Date       : 11.10.2010
* Specification Given By: Audrey Chui
* Purpose	 : For PR - To assign the source automatically based on the
*            lowest price deteremined when there are multiple sources.
*---------------------------------------------------------------------*
* Modification Log
* Date         Author   Num Description
*
* -----------  -------  ---  -----------------------------------------*
*----------------------------------------------------------------------*
REPORT rm06bl00 MESSAGE-ID me
       NO STANDARD PAGE HEADING.

*ENHANCEMENT-POINT RM06BL00_01 SPOTS ES_RM06BL00.
*----------------------------------------------------------------------*
*        Tabellen                                                      *
*----------------------------------------------------------------------*
TABLES: eban, *eban,
        ekko,
        t16lb,
        t16ll,
        t160d,                                              "600269
        rm06b.

DATA: feldname(7).

*----------------------------------------------------------------------*
*        Select-options und Parameter                                  *
*----------------------------------------------------------------------*
*INCLUDE FM06BCS1.
*NCLUDE FM06BCS2.
INCLUDE zfm06bcd1.
*INCLUDE FM06BCD1.
*PERFORM START(SAPFM06B).               "Liste ausgeben
PERFORM start(zmm_sapfm06b).               "Liste ausgeben
*----------------------------------------------------------------------*
*        OK-code-Eingabe auswerten                                     *
*----------------------------------------------------------------------*
AT USER-COMMAND.
*  PERFORM USER_COMMAND(SAPFM06B).
  PERFORM user_command(zmm_sapfm06b).
  CLEAR sy-ucomm.

*----------------------------------------------------------------------*
*        Übersschrift                                                  *
*----------------------------------------------------------------------*
TOP-OF-PAGE.
*  PERFORM top(sapfm06b).
  PERFORM top(zmm_sapfm06b).

TOP-OF-PAGE DURING LINE-SELECTION.
*  PERFORM top(sapfm06b).
  PERFORM top(zmm_sapfm06b).

  INCLUDE zrm06bz0m.
*  INCLUDE RM06BZ0M.

************************************************************************
*        PBO-MODULE für POP-UPs                                        *
************************************************************************
*----------------------------------------------------------------------*
*        Ersten Eintrag in der Tabelle ALF bestimmen                   *
*----------------------------------------------------------------------*
MODULE alf_first OUTPUT.

*  PERFORM alf_first(sapfm06b).
  PERFORM alf_first(zmm_sapfm06b).

ENDMODULE.                    "ALF_FIRST OUTPUT

*----------------------------------------------------------------------*
*        Lesen bereits zugeordnete Lieferanten                         *
*----------------------------------------------------------------------*
MODULE alf_lesen OUTPUT.

*  PERFORM alf_lesen(sapfm06b).
  PERFORM alf_lesen(zmm_sapfm06b).

ENDMODULE.                    "ALF_LESEN OUTPUT

*----------------------------------------------------------------------*
*        Feldauswahl setzen für mehrere Lieferanten bei Anfrage        *
*----------------------------------------------------------------------*
MODULE modify_screen OUTPUT.

*  PERFORM modify_screen(sapfm06b).
  PERFORM modify_screen(zmm_sapfm06b).

ENDMODULE.                    "MODIFY_SCREEN OUTPUT

*----------------------------------------------------------------------*
*        Feldauswahl setzen für Bezugsquellensubscreen 403             *
*----------------------------------------------------------------------*
MODULE modify_screen_list OUTPUT.

  DATA: lf_ccp_active TYPE c. " CCP

*- Modifizieren Eingabebereitsschaft Felder ---------------------------*
  LOOP AT SCREEN.
    IF pfkeyp NE 'BEAR' AND
       pfkeyp NE 'BDET' AND
       screen-input EQ 1.
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.
*- Banf gelöscht - keine Felder eingabebereit -------------------------*
    IF eban-loekz NE space AND
       screen-input EQ 1.
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.
*- Dienstleistungsposition - Menge nicht eingabebereit ----------------*
    IF eban-pstyp EQ '9' AND
       screen-group3 EQ '001'.
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.
*- Rahmenbestellung nur bei Dien-pos aus PM anzeigen ------------------*
    IF screen-group2 EQ '009'.
      IF eban-pstyp NE '9' OR
         eban-estkz NE 'F'.
        screen-invisible = 1.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
*- Funktionsberechtigung: kein Infosatz -------------------------------*
    IF screen-group4 EQ '003'.                              "600269
      IF t160d-ebzin EQ space.
        screen-input = '0'.
        MODIFY SCREEN.
      ELSE.
        IF t160d-ebzom EQ space AND eban-matnr EQ space.
          screen-input = '0'.
          MODIFY SCREEN.
        ENDIF.
      ENDIF.
    ENDIF.
*- Funktionsberechtigung: kein Vertrag -------------------------------*
    IF screen-group4 EQ '005'.                              "600269
      IF t160d-ebzka EQ space.
        screen-input = '0'.
        MODIFY SCREEN.
      ELSE.
        IF t160d-ebzom EQ space AND eban-matnr EQ space.
          screen-input = '0'.
          MODIFY SCREEN.
        ENDIF.
      ENDIF.
    ENDIF.

* Begin CCP
    IF sy-dynnr EQ '0403' AND
       screen-name EQ 'EBAN-BESWK'.

      CALL FUNCTION 'ME_CCP_ACTIVE_CHECK'
        IMPORTING
          ef_ccp_active = lf_ccp_active.

      IF lf_ccp_active IS INITIAL.
        screen-input = '0'.
        screen-invisible = '1'.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
* End CCP

  ENDLOOP.

ENDMODULE.                    "MODIFY_SCREEN_LIST OUTPUT
*----------------------------------------------------------------------*
*        Setzen Cursor auf 'JA'-Option
*----------------------------------------------------------------------*
MODULE set_cursor OUTPUT.

  feldname = 'OPTION1'.
  SET CURSOR FIELD feldname.

ENDMODULE.                    "SET_CURSOR OUTPUT

*----------------------------------------------------------------------*
*        Setzen PF-Status für POP-UP Generieren Bestellung/Anfrage     *
*----------------------------------------------------------------------*
MODULE set_pfstatus_pop OUTPUT.

  pfkeyp = sy-pfkey.
  CASE sy-dyngr.
*- Generieren Bestellung - Titel setzen -------------------------------*
    WHEN 'POPF'.
      SET PF-STATUS 'POPA'.
      SET TITLEBAR '005'.
*- Generieren Anfrage - Titel setzen ----------------------------------*
    WHEN 'POPA'.
      SET PF-STATUS 'POPA'.
      SET TITLEBAR '006'.
*- Vormerken für Anfrage - Wunschlieferant vorhanden ------------------*
    WHEN 'POPV'.
      SET PF-STATUS '    '.
      SET TITLEBAR '007'.
      SET CURSOR FIELD 'OPTION1'.
*- Vormerken für Anfrage - bei mehreren Lieferanten -------------------*
    WHEN 'POPM'.
      SET PF-STATUS 'POPM'.
      SET TITLEBAR '007'.
*- Bezugsquelle manuell zuordnen --------------------------------------*
    WHEN 'POPB'.
      SET PF-STATUS 'POPB'.
      SET TITLEBAR '008'.
*- Listumfang ändern --------------------------------------------------*
    WHEN 'POPL'.
      SET PF-STATUS 'POPA'.
      SET TITLEBAR '009'.

*- Detailbild ---------------------------------------------------------*
    WHEN 'POPD'.
      CASE pfkeyp.
        WHEN 'BEAR'. SET PF-STATUS 'DBEA'.
        WHEN 'BDET'. SET PF-STATUS 'DBDE'.
        WHEN 'ZUOR'. SET PF-STATUS 'DZUO'.
        WHEN OTHERS. SET PF-STATUS 'DLIS'.
      ENDCASE.
      SET TITLEBAR '200' WITH eban-banfn eban-bnfpo.

*- Modifizieren Eingabebereitsschaft Felder ---------------------------*
      LOOP AT SCREEN.
        IF pfkeyp NE 'BEAR' AND
           pfkeyp NE 'BDET' AND
           screen-input EQ 1.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.
*- Banf gelöscht - keine Felder eingabebereit -------------------------*
        IF eban-loekz NE space AND
           screen-input EQ 1.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.
*- Dienstleistungsposition - Menge nicht eingabebereit ----------------*
        IF eban-pstyp EQ '9' AND
           screen-group3 EQ '001'.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.
*.. disporelevante Felder nicht aenderbar bei Banfen aus dem PPS und SD
        IF screen-group3 EQ '001' OR                        "129791
           screen-group3 EQ '002'.                          "129791
          IF eban-estkz EQ 'F' OR                           "129791
             eban-estkz EQ 'V'.                             "129791
            screen-required = '0'.                          "129791
            screen-input = '0'.                             "129791
            screen-output = '1'.                            "129791
            MODIFY SCREEN.                                  "129791
          ENDIF.                                            "129791
        ENDIF.                                              "129791
      ENDLOOP.
  ENDCASE.

ENDMODULE.                    "SET_PFSTATUS_POP OUTPUT

************************************************************************
*        PAI-MODULE für POP-UPs                                        *
************************************************************************
*----------------------------------------------------------------------*
*        In Tabelle ALF Blättern                                       *
*----------------------------------------------------------------------*
MODULE alf_blaettern.

*  PERFORM alf_blaettern(sapfm06b).
  PERFORM alf_blaettern(zmm_sapfm06b).

ENDMODULE.                    "ALF_BLAETTERN

*----------------------------------------------------------------------*
*        Tabelle ALF füllen - Lieferanten für Anfrage merken           *
*----------------------------------------------------------------------*
MODULE alf_fuellen.

*  PERFORM alf_fuellen(sapfm06b).
  PERFORM alf_fuellen(zmm_sapfm06b).

ENDMODULE.                    "ALF_FUELLEN

*----------------------------------------------------------------------*
*        Manuell eingegebene Bezugsquelle prüfen                       *
*----------------------------------------------------------------------*
MODULE bezugsquelle.

*  PERFORM bezugsquelle(sapfm06b).
  PERFORM bezugsquelle(zmm_sapfm06b).

ENDMODULE.                    "BEZUGSQUELLE

*----------------------------------------------------------------------*
*        EXIT-Modul für POP-UPs Generieren Bestellung/Anfrage          *
*----------------------------------------------------------------------*
MODULE exit.

  SET PF-STATUS pfkeyp.
  reject = 'X'.
  SET SCREEN 0.
  LEAVE SCREEN.

ENDMODULE.                    "EXIT

*----------------------------------------------------------------------*
*        F4-Hilfe bei Belegnummer                                      *
*----------------------------------------------------------------------*
MODULE help_ebeln.

  DATA: feld(11).
  GET CURSOR FIELD feld.

*  PERFORM help_ebeln(sapfm06b) USING feld.
  PERFORM help_ebeln(zmm_sapfm06b) USING feld.

ENDMODULE.                    "HELP_EBELN

*eject
*----------------------------------------------------------------------*
*  Lieferdatum
*----------------------------------------------------------------------*
MODULE help_eeind.

  DATA: h_stepl LIKE sy-stepl,
        h_eeind LIKE rm06b-eeind,
        h_lpeih LIKE rm06b-lpein.
  CLEAR h_stepl.

  CALL FUNCTION 'ME_VALUES_EEIND'
       EXPORTING
*            I_PROGN = 'RM06BL00'
            i_progn = 'ZMM_RM06BL00'
            i_dynpn = sy-dynnr
            i_stepl = h_stepl
            i_field = 'RM06B-LPEIN'
       IMPORTING
            e_eeind = h_eeind
            e_lpein = h_lpeih.
  IF h_eeind NE space.
    rm06b-eeind = h_eeind.
  ENDIF.
  IF h_lpeih NE space.
    rm06b-lpein = h_lpeih.
  ENDIF.

ENDMODULE.                    "HELP_EEIND

*eject
*----------------------------------------------------------------------*
*  Datumstypen Lieferdatum
*----------------------------------------------------------------------*
MODULE help_lpein.

  DATA: h_lpein LIKE rm06b-lpein.

  CALL FUNCTION 'ME_VALUES_TPRG'
    IMPORTING
      e_lpein = h_lpein.

  IF h_lpein NE space.
    rm06b-lpein = h_lpein.
  ENDIF.

ENDMODULE.                    "HELP_LPEIN

*----------------------------------------------------------------------*
*        Auswerten OK-Code bei POP-UP 'Vormerken Anfrage' einfach      *
*----------------------------------------------------------------------*
MODULE ok_code.

  CLEAR: feldname, answer.
  SET PF-STATUS pfkeyp.
  CASE ok-code.
*- Abbrechen ----------------------------------------------------------
    WHEN 'EXIT'.
      reject = 'X'.
*- Ja ------------------------------------------------------------------
    WHEN 'JA  '.
      answer = 'Y'.
*- Nein ---------------------------------------------------------------
    WHEN 'NEIN'.
      answer = 'N'.
  ENDCASE.
  SET SCREEN 0.
  LEAVE SCREEN.

ENDMODULE.                    "OK_CODE
*----------------------------------------------------------------------*
*        Eingaben prüfen auf den POP-UPs                               *
*----------------------------------------------------------------------*
MODULE pruefen_eingaben.

*  PERFORM pruefen_eingaben(sapfm06b).
  PERFORM pruefen_eingaben(zmm_sapfm06b).

ENDMODULE.                    "PRUEFEN_EINGABEN

*----------------------------------------------------------------------*
*  Prüfen Listumfang                                                  *
*----------------------------------------------------------------------*
MODULE pruefen_lstub.

*  PERFORM pruefen_lstub(sapfm06b) USING t16ll-lstub.
  PERFORM pruefen_lstub(zmm_sapfm06b) USING t16ll-lstub.
  com-lstub = t16ll-lstub.

ENDMODULE.                    "PRUEFEN_LSTUB

*----------------------------------------------------------------------*
*  Prüfen Eingaben Detailbild.                                        *
*----------------------------------------------------------------------*
MODULE pruefen_d0300.
*
*  PERFORM aend_lfdat(sapfm06b).
*  PERFORM aend_menge(sapfm06b).
*  PERFORM aend_deta(sapfm06b).
  PERFORM aend_lfdat(zmm_sapfm06b).
  PERFORM aend_menge(zmm_sapfm06b).
  PERFORM aend_deta(zmm_sapfm06b).

ENDMODULE.                    "PRUEFEN_D0300
*----------------------------------------------------------------------*
*  Prüfen Eingaben Detailbild.                                        *
*----------------------------------------------------------------------*
MODULE pruefen_d0403.

  IF eban-flief NE *eban-flief OR
     eban-ekorg NE *eban-ekorg OR
     eban-konnr NE *eban-konnr OR
     eban-beswk NE *eban-beswk OR " CCP
     eban-ktpnr NE *eban-ktpnr OR
     eban-infnr NE *eban-infnr.
* Begin CCP
    IF NOT eban-beswk IS INITIAL OR
       NOT *eban-beswk IS INITIAL.
*      PERFORM authority_beswk IN PROGRAM sapfm06b
      PERFORM authority_beswk IN PROGRAM zmm_sapfm06b
         USING eban *eban.
    ENDIF.
* End CCP
*    PERFORM aend_bezug(sapfm06b).
    PERFORM aend_bezug(zmm_sapfm06b).
  ENDIF.

ENDMODULE.                    "PRUEFEN_D0403
*eject
*----------------------------------------------------------------------*
*  Lesen interne Tabelle der Verbräuche                                *
*----------------------------------------------------------------------*
MODULE lesen_loop_d0407_v OUTPUT.

*  PERFORM ban_daten_004_anzeigen(sapfm06b).
  PERFORM ban_daten_004_anzeigen(zmm_sapfm06b).

ENDMODULE.                    "LESEN_LOOP_D0407_V OUTPUT

*eject
*----------------------------------------------------------------------*
*  Lesen interne Tabelle der Prognosen                                 *
*----------------------------------------------------------------------*
MODULE lesen_loop_d0407_p OUTPUT.

*  PERFORM ban_daten_009_anzeigen(sapfm06b).
  PERFORM ban_daten_009_anzeigen(zmm_sapfm06b).

ENDMODULE.                    "LESEN_LOOP_D0407_P OUTPUT

*---------------------------------------------------------------------*
*       MODULE MESSAGE                                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE message.

  MESSAGE w039.

ENDMODULE.                    "MESSAGE

*&---------------------------------------------------------------------*
*&      Module  CHECK_INPUT_0104  INPUT
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
MODULE check_input_0104 INPUT.

  IF eban-flief EQ space AND eban-infnr EQ space AND
     eban-konnr EQ space AND eban-reswk EQ space.
    MESSAGE e312.
  ENDIF.
  IF eban-ekorg IS INITIAL.
    MESSAGE e100(06).
  ENDIF.
*  PERFORM bezugsquelle_bezeichn(sapfm06b).
  PERFORM bezugsquelle_bezeichn(zmm_sapfm06b).

ENDMODULE.                             " CHECK_INPUT_0104  INPUT
