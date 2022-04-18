REPORT zrm06w003 NO STANDARD PAGE HEADING MESSAGE-ID 06
      LINE-SIZE 90.
*ENHANCEMENT-POINT RM06W003_G4 SPOTS ES_RM06W003 STATIC.
*ENHANCEMENT-POINT RM06W003_G5 SPOTS ES_RM06W003.
*ENHANCEMENT-POINT RM06W003_G6 SPOTS ES_RM06W003 STATIC.
*ENHANCEMENT-POINT RM06W003_G7 SPOTS ES_RM06W003.
*----------------------------------------------------------------------*
* Generierung von Orderbucheinträgen                                   *
*----------------------------------------------------------------------*

*ENHANCEMENT-POINT RM06W003_01 SPOTS ES_RM06W003 STATIC.
*
*Start of insertion brianrabe P30K909966
INITIALIZATION.
*  IF cl_immpn_cust=>check_mpn_active( ) EQ abap_true.
    DATA: lt_sel_dtel TYPE  rsseldtel OCCURS 0,
          ls_sel_dtel TYPE  rsseldtel.

    ls_sel_dtel-name = 'W_MFRPN'.
    ls_sel_dtel-kind = 'S'.
    ls_sel_dtel-datenelment = 'MFRPN'.
    APPEND ls_sel_dtel TO lt_sel_dtel.

    CALL FUNCTION 'SELECTION_TEXTS_MODIFY_DTEL'
      EXPORTING
        program                     = sy-repid
      TABLES
        sel_dtel                    = lt_sel_dtel
      EXCEPTIONS
        program_not_found           = 1
        program_cannot_be_generated = 2
        OTHERS                      = 3.
    IF sy-subrc <> 0.
    ENDIF.
*  ENDIF.

  "{ End ENHO MGV_GENERATED_RM06W003001 IS-AD-MPN-MD AD_MPN }


  "{ Begin ENHO AD_MPN_MD_MPN_AND_IC_RM06W003 IS-AD-MPN-MD AD_MPN }
  TABLES: mara.
  "{ End ENHO AD_MPN_MD_MPN_AND_IC_RM06W003 IS-AD-MPN-MD AD_MPN }

*End of insertion brianrabe P30K909966

INCLUDE fm06it02.
INCLUDE fm06icom.

*----------------------------------------------------------------------*
* Selektionsbilder                 (Änderung: 30.03.98, Robert Fischer)*
*----------------------------------------------------------------------*
* range: material number, plant
INCLUDE fm06icw1.
** range: outline agreement                    "not yet supported
** include fm06icw9.                           "not yet supported

SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN BEGIN OF BLOCK bl4 WITH FRAME TITLE TEXT-007   "4.0C RB
                                   NO INTERVALS.                "4.0C RB
INCLUDE fm06icw6.                                               "4.0C RB
SELECTION-SCREEN END OF BLOCK bl4.                              "4.0C RB

SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-001
                                   NO INTERVALS.
* range: validity
INCLUDE fm06icw3.
* selection parameters: dispo flag        "4.0C RB
INCLUDE fm06icw7.                         "4.0C RB


SELECTION-SCREEN SKIP 1.
INCLUDE fm06icw8.                                             "4.0C RB
*Customized selection
PARAMETERS:  w_zero AS CHECKBOX.
PARAMETERS:  w_low AS CHECKBOX.
PARAMETER :  w_ekrg RADIOBUTTON GROUP gr1,
             w_wrks RADIOBUTTON GROUP gr1.
SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE TEXT-005.
 INCLUDE fm06icw5.
SELECTION-SCREEN END OF BLOCK bl2.
SELECTION-SCREEN SKIP 1.

INCLUDE fm06icwq.
SELECTION-SCREEN END OF BLOCK bl1.


INCLUDE fmmexdir.
IF sy-batch EQ space.
  vorgang = 'W3'.
ELSE.
* VORGANG = 'W5'.
  vorgang = 'W3'.
ENDIF.
*

******************* ZEITPUNKTE *****************************************
INITIALIZATION.
*----------------------------------------------------------------------*
  wq_simul = 'X'.
  w_genr2  = 'X'.
  w_datab  = sy-datlo.
  w_datbi  = '29991231'.
  w_genr5  = 'X'.                                      "4.0C RB

*Customized selection
  %_w_low_%_app_%-text = |Select only the lowest price|.
  %_w_zero_%_app_%-text = |Ignore zero|.
  %_w_ekrg_%_app_%-text = |Purchasing Org.|.
  %_w_wrks_%_app_%-text = |Plant|.

*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
*----------------------------------------------------------------------*
  IF w_datab IS INITIAL.          "338998
    w_datab  = sy-datlo.          "338998
  ENDIF.                          "338998
  IF sy-batch EQ space.
    PERFORM at_selection_screen(sapfm06i) USING 'W3'.
  ELSE.
* PERFORM AT_SELECTION_SCREEN(SAPFM06I) USING 'W5'.
    PERFORM at_selection_screen(sapfm06i) USING 'W3'.
  ENDIF.

*----------------------------------------------------------------------*
START-OF-SELECTION.
*----------------------------------------------------------------------*
  PERFORM pf_status(sapfm06i) USING vorgang.
  PERFORM daten_selektion(sapfm06i).


*----------------------------------------------------------------------*
END-OF-SELECTION.
*----------------------------------------------------------------------*
  PERFORM liste_anzeigen(sapfm06i).
  PERFORM buchen_w3_batch(sapfm06i).   "3.1G

*----------------------------------------------------------------------*
TOP-OF-PAGE.
*----------------------------------------------------------------------*
  PERFORM top_of_page(sapfm06i).


*----------------------------------------------------------------------*
TOP-OF-PAGE DURING LINE-SELECTION.
*----------------------------------------------------------------------*
  PERFORM top_of_page(sapfm06i).

*----------------------------------------------------------------------*
AT USER-COMMAND.
*----------------------------------------------------------------------*
  PERFORM user_command(sapfm06i).
AT SELECTION-SCREEN OUTPUT.

*ENHANCEMENT-POINT RM06W003_02 SPOTS ES_RM06W003.
*----------------------------------------------------------------------*
*Start of insertion brianrabe P30K909966
  IF cl_immpn_cust=>check_mpn_active( ) EQ abap_false.
    LOOP AT SCREEN.
      IF screen-name EQ 'W_MFRPN-LOW' OR
         screen-name EQ 'W_MFRPN-HIGH' OR
         screen-name EQ '%_W_MFRPN_%_APP_%-TEXT' OR
         screen-name EQ '%_W_MFRPN_%_APP_%-OPTI_PUSH' OR
         screen-name EQ '%_W_MFRPN_%_APP_%-TO_TEXT' OR
         screen-name EQ '%_W_MFRPN_%_APP_%-VALU_PUSH'.
        screen-invisible = 1.
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

  "{ End ENHO AD_MPN_MD_RM06W003 IS-AD-MPN-MD AD_MPN }

*  at selection-screen output.
    LOOP AT SCREEN.
      CASE screen-name.
        WHEN 'W_EKRG' OR 'W_WRKS' OR 'W_LOW' OR 'W_ZERO'.
          IF sy-tcode EQ 'ZME05'.
            screen-active = 1.
            screen-invisible = 0.
          ELSE.
            screen-active = 0.
            screen-invisible = 1.
          ENDIF.
          MODIFY SCREEN.
      ENDCASE.
    ENDLOOP.

  INITIALIZATION.
    IF sy-tcode EQ 'ZME05'.
      %_w_low_%_app_%-text = |Select only the lowest price|.
      %_w_zero_%_app_%-text = |Ignore zero|.
      %_w_ekrg_%_app_%-text = |Purchasing Org.|.
      %_w_wrks_%_app_%-text = |Plant|.
    ENDIF.

*End of insertion brianrabe P30K909966
