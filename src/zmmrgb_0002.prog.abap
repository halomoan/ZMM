************************************************************************
*     REPORT RM07RVER   (Transaktionscode MBVR)                        *
************************************************************************
*     Reservierungen verwalten                                         *
************************************************************************

INCLUDE zrm07rved.
*INCLUDE:  RM07RVED,              " reportspezifische Datendefinitionen
INCLUDE zmm07mabc.
*          MM07MABC,              " Variablen zum Zeichensatz
INCLUDE zmdvmrese.
*          MDVMRESE,
INCLUDE zrm07musr.
*          RM07MUSR,              " Tastenbelegungen und Transkationen
INCLUDE zrm07mend.
*          RM07MEND,              " Anforderungsbild und Enderoutine
INCLUDE zrm07maut.
*          RM07MAUT,              " Berechtigungsprüfung
INCLUDE zrm07rvep.
*          RM07RVEP.              " reporteigene Parameter

************************ HAUPTPROGRAMM *********************************

*---------------- F4-Hilfe für Reportvariante -------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM f4_for_variant.

*----------- Prüfung der eingegebenen Selektionsparameter, ------------*
*---------------------- Berechtigungsprüfung --------------------------*
AT SELECTION-SCREEN.
  PERFORM eingaben_pruefen.

*------------------------ Initialisierung -----------------------------*
INITIALIZATION.
  PERFORM initialisierung.

*------------------------- Datenselektion -----------------------------*
START-OF-SELECTION.
  IF xtest IS INITIAL.
    SET PF-STATUS 'STANDARD'.
  ELSE.
    SET PF-STATUS 'TEST'.
    SET TITLEBAR  '001'.
  ENDIF.
  PERFORM reservierungskoepfe.
  PERFORM reservierungspositionen.

*-------------------------- Datenausgabe-------------------------------*
END-OF-SELECTION.
* perform selektion_ergaenzen.
  REFRESH belege[].
  LOOP AT xresb.
    MOVE-CORRESPONDING xresb TO belege.
    APPEND belege.
    CLEAR belege.
  ENDLOOP.
  DESCRIBE TABLE belege LINES index_z.

  IF NOT index_z IS INITIAL.
    PERFORM feldkatalog_aufbauen USING fieldcat[].
    PERFORM listausgabe.
  ELSE.
    MESSAGE s842.
*   Zu den vorgegebenen Daten ist kein Materialbeleg vorhanden
    PERFORM anforderungsbild.
  ENDIF.

*********************** Ende HAUPTPROGRAMM *****************************


************************** FORMROUTINEN ********************************

*---------------------------------------------------------------------*
*       FORM DATUM_PRUEFEN                                            *
*---------------------------------------------------------------------*
*       Das Datum wird je nach Vorgang ermittelt.                     *
*       Die Reservierungspositionen werden dagegen geprüft.           *
*---------------------------------------------------------------------*
FORM datum_pruefen USING param xokay.

  CLEAR xokay.
  READ TABLE kalender WITH KEY yresb-werks BINARY SEARCH.
  CALL FUNCTION 'DATE_CONVERT_TO_FACTORYDATE'
    EXPORTING
      factory_calendar_id          = kalender-fabkl
      date                         = yresb-bdter
    IMPORTING
      factorydate                  = fdayf1
    EXCEPTIONS
      date_after_range             = 01
      date_before_range            = 02
      date_invalid                 = 03
      factory_calendar_not_found   = 04
      correct_option_invalid       = 05
      calendar_buffer_not_loadable = 06.
  CASE sy-subrc.
    WHEN 1.
      MESSAGE e523 WITH yresb-bdter.
    WHEN 2.
      MESSAGE e524 WITH yresb-bdter.
    WHEN 3.
      MESSAGE e525 WITH yresb-bdter.
    WHEN 4.
      MESSAGE e526 WITH kalender-fabkl.
  ENDCASE.
  CASE param.
    WHEN b.
      IF kalender-dwaok IS INITIAL.
        CALL FUNCTION 'DATE_CONVERT_TO_FACTORYDATE'
          EXPORTING
            factory_calendar_id          = kalender-fabkl
            date                         = c_rsdat
          IMPORTING
            factorydate                  = fdayf2
          EXCEPTIONS
            date_after_range             = 01
            date_before_range            = 02
            date_invalid                 = 03
            factory_calendar_not_found   = 04
            correct_option_invalid       = 05
            calendar_buffer_not_loadable = 06.
        CASE sy-subrc.
          WHEN 1.
            MESSAGE e523 WITH c_rsdat.
          WHEN 2.
            MESSAGE e524 WITH c_rsdat.
          WHEN 3.
            MESSAGE e525 WITH c_rsdat.
          WHEN 4.
            MESSAGE e526 WITH kalender-fabkl.
        ENDCASE.
        kalender-dwaok = fdayf2 + kalender-twaok.
        MODIFY kalender INDEX kalender-cnt02.
      ENDIF.
      IF NOT kalender-dwaok IS INITIAL.
        IF fdayf1 <= kalender-dwaok.
          xokay = x.
        ENDIF.
      ENDIF.
    WHEN l.
      IF kalender-dloek IS INITIAL.
        CALL FUNCTION 'DATE_CONVERT_TO_FACTORYDATE'
          EXPORTING
            factory_calendar_id          = kalender-fabkl
            date                         = c_rsdat
          IMPORTING
            factorydate                  = fdayf2
          EXCEPTIONS
            date_after_range             = 01
            date_before_range            = 02
            date_invalid                 = 03
            factory_calendar_not_found   = 04
            correct_option_invalid       = 05
            calendar_buffer_not_loadable = 06.
        CASE sy-subrc.
          WHEN 1.
            MESSAGE e523 WITH c_rsdat.
          WHEN 2.
            MESSAGE e524 WITH c_rsdat.
          WHEN 3.
            MESSAGE e525 WITH c_rsdat.
          WHEN 4.
            MESSAGE e526 WITH kalender-fabkl.
        ENDCASE.
        kalender-dloek = fdayf2 - kalender-tloek.
        MODIFY kalender INDEX kalender-cnt02.
      ENDIF.
      IF NOT kalender-dloek IS INITIAL.
        IF fdayf1 <= kalender-dloek.
          xokay = x.
        ENDIF.
      ENDIF.
  ENDCASE.

ENDFORM.                    "DATUM_PRUEFEN

*---------------------------------------------------------------------*
*       FORM POSITIONEN_PRUEFEN                                       *
*---------------------------------------------------------------------*
*       Es wird geprüft, ob die ResPositionen entweder gelöscht oder  *
*       mit dem Kennzeichen für 'Bew. erlaubt' versehen werden können.*
*       Dies ist abhängig von der Parametereinstellung und            *
*       den Einstellungen in der Tabelle T159L.                       *
*---------------------------------------------------------------------*
FORM positionen_pruefen.

  CLEAR xresb. REFRESH xresb.
  CLEAR drkpf. REFRESH drkpf.
  LOOP AT lrkpf.
    REFRESH zresb.
    CLEAR: index_l, index_z.
    LOOP AT yresb WHERE rsnum = lrkpf-rsnum.
      CLEAR auth70.
      PERFORM werk_rs USING actvt70
                            yresb-werks.
      IF no_chance IS INITIAL.
        IF NOT auth70 IS INITIAL.
          no_chance = x.
        ENDIF.
      ENDIF.
      CLEAR auth65.
      PERFORM werk_rs USING actvt65
                            yresb-werks.
      IF no_chance IS INITIAL.
        IF NOT auth65 IS INITIAL.
          no_chance = x.
        ENDIF.
      ENDIF.
      index_z = index_z + 1.
      IF NOT xloek IS INITIAL.
        IF yresb-xloek IS INITIAL.
          CLEAR xdele.
          IF NOT xfert IS INITIAL.
            IF yresb-enmng => yresb-bdmng OR
               NOT yresb-kzear IS INITIAL.
              xdele = x.
            ENDIF.
          ELSE.
            xdele = x.
          ENDIF.
          IF xdele = x.
            PERFORM datum_pruefen USING l yresb-xloek.
            IF NOT yresb-xloek IS INITIAL.
              index_l = index_l + 1.
              zresb = yresb.
              APPEND zresb.
            ENDIF.
          ENDIF.
        ELSE.
          index_l = index_l + 1.
        ENDIF.
      ENDIF.
      IF NOT xwaok IS INITIAL AND yresb-xwaok IS INITIAL
         AND yresb-xloek IS INITIAL.
        PERFORM datum_pruefen USING b yresb-xwaok.
        IF NOT yresb-xwaok IS INITIAL.
          zresb = yresb.
          APPEND zresb.
        ENDIF.
      ENDIF.
    ENDLOOP.

*-- Alle Positionen haben ein Löschkennzeichen -> DELETE Reservierung
    IF index_l = index_z.
      CHECK auth65 IS INITIAL.
      drkpf-rsnum = lrkpf-rsnum.
      drkpf-rsdat = lrkpf-rsdat.
      drkpf-mandt = sy-mandt.
      APPEND drkpf.
      READ TABLE zresb INDEX 1.
      IF zresb-rsnum = drkpf-rsnum.
        REFRESH zresb.
      ENDIF.
    ENDIF.

*-- Die Reservierungspositionen, für die entweder XWAOK oder XLOEK zu
*   setzen ist (d. h. nicht die gesamte Reservierung ist löschfähig )
*   werden für den UPDATE vorgemerkt.
    LOOP AT zresb.
      CHECK auth70 IS INITIAL.
      xresb = zresb.
      APPEND xresb.
    ENDLOOP.
  ENDLOOP.

ENDFORM.                    "POSITIONEN_PRUEFEN

*---------------------------------------------------------------------*
*       FORM POSITIONEN_UEBERNEHMEN                                   *
*---------------------------------------------------------------------*
*       Markierte Positionen übernehmen und sperren                   *
*---------------------------------------------------------------------*
FORM positionen_uebernehmen USING alle.

* Wenn nicht alle Reservierungen zur Auswahl kommen
  IF alle IS INITIAL.
    IF sy-pfkey = 'POSITION'.
      LOOP AT yresb.
        READ TABLE position WITH KEY rsnum = yresb-rsnum
                                     rspos = yresb-rspos.
        IF sy-subrc IS INITIAL.
          MOVE position-box TO yresb-box.
          MODIFY yresb.
        ENDIF.
      ENDLOOP.
    ENDIF.
    LOOP AT drkpf.
      READ TABLE belege WITH KEY rsnum = drkpf-rsnum
                                 rsdat = drkpf-rsdat.
      IF belege-box NE x.
        DELETE drkpf.
      ENDIF.
    ENDLOOP.
    LOOP AT belege WHERE box EQ 'X'.
      DELETE belege.
    ENDLOOP.
  ENDIF.

*-- Reservierung sperren
*-- Reservierungen einzeln sperren
  IF NOT sin_enq IS INITIAL.
    LOOP AT drkpf.
      CALL FUNCTION 'ENQUEUE_EMRKPF'
        EXPORTING
          rsnum          = drkpf-rsnum
        EXCEPTIONS
          foreign_lock   = 2
          system_failure = 3.
      CASE sy-subrc.
        WHEN 2.
          IF sy-pfkey NE 'FEHLER'.
            SET PF-STATUS 'FEHLER'.
            MOVE 'STANDARD' TO pf_alt.
            MOVE x TO xfehler.
            DELETE drkpf.
          ENDIF.
*         xclose = x.
*         perform next_row using 2 space.
          WRITE 02 drkpf-rsnum.
        WHEN 3.
          MESSAGE e110.
      ENDCASE.
    ENDLOOP.
  ELSEIF NOT all_enq IS INITIAL.
*-- alle Reservierungen sperren (ein Sperreintrag)
    CALL FUNCTION 'ENQUEUE_EMRKPF'
      EXCEPTIONS
        foreign_lock   = 4
        system_failure = 8.
    CASE sy-subrc.
      WHEN 4.
        MESSAGE e545.
      WHEN 8.
        MESSAGE e110.
    ENDCASE.
  ENDIF.
* Wenn nicht alle Reservierungspositionen zur Auswahl kommen
  IF alle IS INITIAL.
    SORT yresb BY rsnum rspos.
    LOOP AT xresb.
      MOVE-CORRESPONDING xresb TO reskey.
      READ TABLE yresb WITH KEY reskey BINARY SEARCH.
      IF yresb-box NE x.
        DELETE xresb.
      ENDIF.
    ENDLOOP.
  ENDIF.

* Selektierte Resevierungspositionen sperren
  LOOP AT xresb.
    IF NOT sin_enq IS INITIAL.
      ON CHANGE OF xresb-rsnum.
        CALL FUNCTION 'ENQUEUE_EMRKPF'
          EXPORTING
            rsnum          = xresb-rsnum
          EXCEPTIONS
            foreign_lock   = 2
            system_failure = 3.
        CASE sy-subrc.
          WHEN 2.
            IF sy-pfkey NE 'FEHLER'.
              SET PF-STATUS 'FEHLER'.
              MOVE 'STANDARD' TO pf_alt.
              MOVE x TO xfehler.
            ENDIF.
*           write 2 xresb-rsnum.
*-------- Kennzeichen für XRESB
            MOVE x TO xdelete.
            MOVE xresb-rsnum TO del_rsnum.
          WHEN 3.
            MESSAGE e110.
        ENDCASE.
      ENDON.
    ENDIF.
*-- gesperrte Reservierungen löschen
    IF NOT xdelete IS INITIAL.
      IF xresb-rsnum EQ del_rsnum.
        DELETE xresb.
      ELSE.
        CLEAR: xdelete, del_rsnum.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "POSITIONEN_UEBERNEHMEN

*---------------------------------------------------------------------*
*       FORM PROTOKOLL_AUSGEBEN                                       *
*---------------------------------------------------------------------*
*       Sofern gewünscht wird ein Protokoll ausgegeben.               *
*---------------------------------------------------------------------*
FORM protokoll_ausgeben.

* Wenn keine kompletten Reservierungen zu löschen sind, werden direkt
* die Reservierungspositionen ausgegeben
  IF anzahl1 IS INITIAL AND sy-pfkey EQ 'TEST'.
    IF anzahl2 IS INITIAL.
      MESSAGE s841.
      PERFORM anforderungsbild.
    ELSEIF NOT xtest IS INITIAL.
      SET PF-STATUS 'POSITION'.
      SET TITLEBAR  '002'.
      sy-lsind = 0.
    ENDIF.
  ENDIF.

* Reservierungen
  IF sy-pfkey = 'TEST' OR pf_alt = 'TEST' OR
     sy-pfkey = 'STANDARD' OR sy-pfkey = 'FEHLER'.
    CLEAR: xhead.
    IF sy-pfkey = 'STANDARD' OR pf_alt = 'STANDARD'.
      IF NOT anzahl1 IS INITIAL.
        xhead = 1.
      ENDIF.
    ELSEIF anzahl1 IS INITIAL.
      MESSAGE s131.
*     Es sind keine Positionen auswählbar
    ENDIF.
    SORT drkpf BY mandt rsnum.
    reskkey-mandt = sy-mandt.
    CLEAR: xtabix, xmark.
    REFRESH belege.
    LOOP AT lrkpf.
      reskkey-rsnum = lrkpf-rsnum.
      READ TABLE drkpf WITH KEY reskkey BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        IF sy-pfkey EQ 'OVERVIEW'.
          CHECK NOT lrkpf-box IS INITIAL.
        ENDIF.
        MOVE-CORRESPONDING lrkpf TO belege.
        MOVE 'X' TO belege-kennz.
        APPEND belege.
      ENDIF.
    ENDLOOP.
  ENDIF.

* Reservierungspositionen
  IF sy-pfkey = 'POSITION' OR pf_alt = 'POSITION' OR
     sy-pfkey = 'STANDARD' OR sy-pfkey = 'FEHLER'.
    CLEAR: xhead.
    IF sy-pfkey = 'STANDARD' OR pf_alt = 'STANDARD'.
      IF NOT anzahl2 IS INITIAL.
        xhead = 2.
      ENDIF.
    ELSEIF anzahl2 IS INITIAL.
      MESSAGE s131.
*     Es sind keine Positionen auswählbar
    ENDIF.
    SORT xresb BY rsnum rspos.
    SORT yresb BY rsnum rspos.
    REFRESH position.
    LOOP AT yresb.
      MOVE-CORRESPONDING yresb TO reskey.
      READ TABLE xresb WITH KEY reskey BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        IF sy-pfkey EQ 'OVERVIEW'.
          CHECK NOT yresb-box IS INITIAL.
        ENDIF.
        MOVE-CORRESPONDING yresb TO position.
        MOVE yresb-xwaok TO position-xwaok_alt.
        MOVE yresb-xloek TO position-xloek_alt.
        MOVE xresb-xwaok TO position-xwaok_neu.
        MOVE xresb-xloek TO position-xloek_neu.
        MOVE 'X' TO position-kennz.
        APPEND position.
      ENDIF.
    ENDLOOP.
    PERFORM feldkatalog_position USING fieldcat_p[].
    PERFORM listausgabe_position.
  ENDIF.

ENDFORM.                    "PROTOKOLL_AUSGEBEN

*---------------------------------------------------------------------*
*       FORM UPDATE_AUSFUEHREN                                        *
*---------------------------------------------------------------------*
*       Sofern gewünscht wird ein Protokoll ausgegeben.               *
*---------------------------------------------------------------------*
FORM update_ausfuehren.

* Note 917963 Begin
*  FIELD-SYMBOLS <FS_DRKPF> LIKE DRKPF.
  FIELD-SYMBOLS <fs_resb> LIKE xresb.
* Note 917963 End

* Zu löschende Indexeinträge REUL bestimmen
* Index für Umlagerungsreservierung aufbauen
* Einlesen der Indexdatei
  SELECT * FROM reul APPENDING TABLE xreul.
  SORT xreul BY mandt matnr umwrk rsnum rspos rsart.
  LOOP AT xresb WHERE umwrk NE '    '.
    MOVE-CORRESPONDING xresb TO reul_key.
    READ TABLE xreul WITH KEY reul_key BINARY SEARCH.
*-- Zu löschende Sätze zwischenspeichern
    IF sy-subrc IS INITIAL.
      dreul = reul_key.
      APPEND dreul.
    ENDIF.
  ENDLOOP.

* Aufbauen PREFETCH-Tabelle für Materialstamm lesen
  LOOP AT drkpf.
    LOOP AT yresb WHERE rsnum = drkpf-rsnum.
      MOVE-CORRESPONDING yresb TO dresb.
      APPEND dresb.
      MOVE-CORRESPONDING yresb TO altreserv.
      yresb-xloek = x.
      MOVE-CORRESPONDING yresb TO neureserv.
      IF altreserv NE neureserv.
        IF NOT altreserv-kzear IS INITIAL AND
           NOT neureserv-xloek IS INITIAL.
        ELSE.
          MOVE-CORRESPONDING yresb TO prefetch02.
          COLLECT prefetch02.
          MOVE-CORRESPONDING yresb TO disp.
          APPEND disp.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
  SORT xresb BY rsnum rspos.
  LOOP AT yresb.
    MOVE-CORRESPONDING yresb TO reskey.
    READ TABLE xresb WITH KEY reskey BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      IF yresb-xloek IS INITIAL AND NOT xresb-xloek IS INITIAL.
        MOVE-CORRESPONDING xresb TO prefetch02.
        COLLECT prefetch02.
        MOVE-CORRESPONDING yresb TO dis.
        APPEND dis.
      ENDIF.
    ENDIF.
  ENDLOOP.
  READ TABLE prefetch02 INDEX 1.
  IF sy-subrc IS INITIAL.
    CALL FUNCTION 'MATERIAL_PRE_READ_MBERE'
      EXPORTING
        kzspr  = space
      TABLES
        ipre02 = prefetch02.
  ENDIF.

* Dispsäzte aufgrund komplett gelöschter Reservierungen
  READ TABLE disp INDEX 1.
  IF sy-subrc IS INITIAL.
    LOOP AT disp.
      mtcom-kenng = 'MBERE'.
      mtcom-matnr = disp-matnr.
      mtcom-werks = disp-werks.
      mtcom-pstat = b.
      mtcom-nomus = x.
      CALL FUNCTION 'MATERIAL_READ' "#EC CI_FLDEXT_OK[2215424] P30K910013
        EXPORTING
          schluessel = mtcom
        IMPORTING
          matdaten   = mbere
        TABLES
          seqmat01   = dummy.
      disp-disst = mbere-disst.
      disp-dismm = mbere-dismm.
      MODIFY disp.
    ENDLOOP.
  ENDIF.

*- Dispsätze aufgrund dem gesetzten Löschkennzeichen
  READ TABLE dis INDEX 1.
  IF sy-subrc IS INITIAL.
    LOOP AT dis.
      mtcom-kenng = 'MBERE'.
      mtcom-matnr = dis-matnr.
      mtcom-werks = dis-werks.
      mtcom-pstat = b.
      mtcom-nomus = x.
      CALL FUNCTION 'MATERIAL_READ' "#EC CI_FLDEXT_OK[2215424] P30K910013
        EXPORTING
          schluessel = mtcom
        IMPORTING
          matdaten   = mbere
        TABLES
          seqmat01   = dummy.
      dis-disst = mbere-disst.
      dis-dismm = mbere-dismm.
      MODIFY dis.
    ENDLOOP.
  ENDIF.

* Löschen der Reservierungen (alle Positionen)
  DESCRIBE TABLE drkpf LINES anzahl1.
  IF NOT anzahl1 IS INITIAL.

*-- Funtionsbaustein zum löschen per Array
    MOVE x TO xupdate.
    CALL FUNCTION 'MB_DELETE_RESERVATION_ARRAY' IN UPDATE TASK
      TABLES
        drkpf = drkpf
        dresb = dresb
        dreul = dreul.
    READ TABLE disp INDEX 1.
    IF sy-subrc IS INITIAL.
      CALL FUNCTION 'MB_CREATE_MRPRECORD' IN UPDATE TASK
        TABLES
          dis = disp.
    ENDIF.
* Note 917963 Begin
* Update kanban status to wait and delete the link to the reservation
*    LOOP AT DRKPF ASSIGNING <FS_DRKPF>.
    LOOP AT dresb ASSIGNING <fs_resb> WHERE kbnkz EQ 'X'.
      CALL FUNCTION 'PK_REPLENISHMENT_REVERSAL'
        EXPORTING
          post_on_commit = 'X'
          rsnum          = <fs_resb>-rsnum
        EXCEPTIONS
          no_kanban      = 1
          see_message    = 2
          OTHERS         = 3.
    ENDLOOP.
* Note 917963 End
  ENDIF.

* Ändern der Reservierungspositionen
  DESCRIBE TABLE xresb LINES anzahl2.
  IF NOT anzahl2 IS INITIAL.

*   Copy YRESB to YRESB_HELP to ensure that there are no         "621291
*   fields that are not defined in ZRESB when calling            "621291
*   MB_CHANGE_RESERVATION_ARRAY.                                 "621291
    yresb_help[] = yresb[].                                 "621291

*-- Funtionsbaustein zum ändern per Array
    MOVE x TO xupdate.
    CALL FUNCTION 'MB_CHANGE_RESERVATION_ARRAY' IN UPDATE TASK
      TABLES
        dis   = dis
        xresb = xresb
        zresb = yresb_help.                                 "621291
* Note 917963 Begin
* Update kanban status to wait and delete the link to the reservation
    LOOP AT xresb ASSIGNING <fs_resb> WHERE kbnkz EQ 'X'
                                        AND xloek EQ 'X'.
      CALL FUNCTION 'PK_REPLENISHMENT_REVERSAL'
        EXPORTING
          post_on_commit = 'X'
          rsnum          = <fs_resb>-rsnum
        EXCEPTIONS
          no_kanban      = 1
          see_message    = 2
          OTHERS         = 3.
    ENDLOOP.
* Note 917963 End
  ENDIF.

  COMMIT WORK.

  IF xupdate IS INITIAL.
    MESSAGE s724.
*   Es wurden keine Daten verändert
  ELSE.
    MESSAGE s863.
*   Die Änderungen wurden durchgeführt
  ENDIF.

ENDFORM.                    "UPDATE_AUSFUEHREN

*&---------------------------------------------------------------------*
*&      Form  F4_FOR_VARIANT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f4_for_variant.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
       EXPORTING
            is_variant          = variante
            i_save              = variant_save
*           it_default_fieldcat =
       IMPORTING
            e_exit              = variant_exit
            es_variant          = def_variante
       EXCEPTIONS
            not_found = 2.
  IF sy-subrc = 2.
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    IF variant_exit = space.
      p_vari = def_variante-variant.
    ENDIF.
  ENDIF.

ENDFORM.                    " F4_FOR_VARIANT

*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND                                             *
*&---------------------------------------------------------------------*
FORM user_command USING r_ucomm LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.

  CASE r_ucomm.

    WHEN '9B23'.                                " Reservierung anzeigen
      CASE sy-pfkey.
        WHEN 'TEST' OR 'STANDARD'.
          READ TABLE belege INDEX rs_selfield-tabindex.
        WHEN 'OVERVIEW'.
          READ TABLE detail INDEX rs_selfield-tabindex.
          belege-rsnum = detail-rsnum.
          belege-rspos = detail-rspos.
        WHEN 'POSITION'.
          READ TABLE position INDEX rs_selfield-tabindex.
          belege-rsnum = position-rsnum.
          belege-rspos = position-rspos.
      ENDCASE.
      IF sy-subrc IS INITIAL.
        SET PARAMETER ID 'RES' FIELD belege-rsnum.
        SET PARAMETER ID 'RPO' FIELD belege-rspos.
        CALL TRANSACTION 'MB23' AND SKIP FIRST SCREEN.
*     if not lrkpf-rsnum is initial.
*       move lrkpf-rsnum to resb-rsnum.
*     elseif not yresb-rsnum is initial.
*       move yresb-rsnum to resb-rsnum.
*       move yresb-rspos to resb-rspos.
      ELSE.
        MESSAGE i847 WITH text-007.
*       Bitte den Cursor auf & positionieren
*       Text-007: eine Reservierungsnummer
      ENDIF.
      CLEAR: belege-rsnum,
             belege-rspos,
             r_ucomm.

    WHEN '9SRV'.
      CLEAR detail. REFRESH detail.
      IF sy-pfkey = 'TEST'.
        SET TITLEBAR  '003'.
        LOOP AT belege WHERE box = 'X'.
          MOVE-CORRESPONDING belege TO detail.
          APPEND detail.
        ENDLOOP.
      ELSEIF sy-pfkey = 'POSITION'.
        SET TITLEBAR  '004'.
        LOOP AT position WHERE box = 'X'.
          MOVE-CORRESPONDING position TO detail.
          APPEND detail.
        ENDLOOP.
      ENDIF.
      READ TABLE detail INDEX 1.
      IF NOT sy-subrc IS INITIAL.
        MESSAGE i744 WITH text-006.
*       & Position(en) markiert
*       Text-006: Keine
      ELSE.
        pf_alt = sy-pfkey.
        SET PF-STATUS 'OVERVIEW'.
        CLEAR layout.
        IF pf_alt = 'TEST'.
          REFRESH fieldcat.
          PERFORM feldkatalog_aufbauen USING fieldcat[].
          PERFORM listausgabe1.
        ELSEIF pf_alt = 'POSITION'.
          REFRESH fieldcat_p.
          PERFORM feldkatalog_position USING fieldcat_p[].
          PERFORM listausgabe_p1.
        ENDIF.
      ENDIF.

    WHEN '9SCH'.
      PERFORM positionen_uebernehmen USING blank.
      PERFORM update_ausfuehren.
      IF sy-pfkey NE 'FEHLER'.
        LEAVE TO TRANSACTION sy-tcode.
      ENDIF.

    WHEN '9CHG'.
      IF anzahl2 IS INITIAL.
        MESSAGE e848.
* Zu den vorgegebenen Daten sind keine Reservierungspositionen vorhanden
      ENDIF.
      SET PF-STATUS 'POSITION'.
      SET TITLEBAR  '002'.
      PERFORM protokoll_ausgeben.

    WHEN 'SM12'.
      CALL TRANSACTION 'SM12'.

  ENDCASE.

ENDFORM.                               " USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  INITIALISIERUNG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM initialisierung.

*  SELECT SINGLE * FROM T159B WHERE REPID = SY-REPID.
*  IF SY-SUBRC IS INITIAL.
*    XPROT  = T159B-XPROT.
*    XTEST  = T159B-BATIN.
*  ELSE.
  xprot  = x.
  xtest  = x.
*  ENDIF.

  repid = sy-repid.

  variant_save = 'A'.
  CLEAR variante.
  variante-report = repid.
* Default-Variante holen:
  def_variante = variante.
  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
    EXPORTING
      i_save     = variant_save
    CHANGING
      cs_variant = def_variante
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc = 0.
    p_vari = def_variante-variant.
  ENDIF.

  print-no_print_listinfos = 'X'.
ENDFORM.                    " INITIALISIERUNG

*&---------------------------------------------------------------------*
*&      Form  SELEKTION_ERGAENZEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM selektion_ergaenzen.

* loop at irkpf.
  CLEAR auth70.
  PERFORM bewegungsart_rs USING actvt70 yrkpf-bwart.
  IF no_chance IS INITIAL.
    IF NOT auth70 IS INITIAL.
      no_chance = x.
    ENDIF.
  ENDIF.
  CLEAR auth65.
  PERFORM bewegungsart_rs USING actvt65 yrkpf-bwart.
  IF no_chance IS INITIAL.
    IF NOT auth65 IS INITIAL.
      no_chance = x.
    ENDIF.
  ENDIF.
  MOVE-CORRESPONDING yrkpf TO lrkpf.
  APPEND lrkpf.
* endloop.

* loop at irkpf.
*   if not rsdat is initial and rsdat < m-rsdat.
*     delete irkpf.
*     continue.
*   endif.
*   if not rsnum-low is initial.
*     if m-rsnum lt rsnum-low or m-rsnum gt rsnum-high.
*       delete irkpf.
*       continue.
*     endif.
*   endif.
* endloop.




  IF NOT no_chance IS INITIAL.
    MESSAGE s124.
  ENDIF.
  READ TABLE lrkpf INDEX 1.
  IF NOT sy-subrc IS INITIAL.
    MESSAGE s841.
  ELSE.

    irsnum-sign = 'I'.
    irsnum-option = 'EQ'.
    DESCRIBE TABLE lrkpf LINES index_t.
    LOOP AT lrkpf.
      irsnum-low = lrkpf-rsnum.
      APPEND irsnum.
      zaehler = zaehler + 1.
      max_zaehler = max_zaehler + 1.
      IF zaehler = rmax.
        SELECT * FROM resb APPENDING TABLE yresb WHERE rsnum IN irsnum
                                                   AND werks IN s_werks.
        REFRESH irsnum.
        CLEAR zaehler.
        IF max_zaehler = index_t.
          CLEAR max_zaehler.
          CLEAR index_t.
          EXIT.
        ENDIF.
      ENDIF.
      IF max_zaehler = index_t.
        SELECT * FROM resb APPENDING TABLE yresb WHERE rsnum IN irsnum
                                                   AND werks IN s_werks.
        REFRESH irsnum.
        CLEAR zaehler.
        CLEAR max_zaehler.
        CLEAR index_t.
        EXIT.
      ENDIF.
    ENDLOOP.

    LOOP AT yresb.
      CLEAR yresb-box.
      MODIFY yresb.
    ENDLOOP.
*  Die für die spätere Datumsprüfungen relevanten Informationen
*  werden aus den Tabellen T001W und T159L ermittelt und in
*  die interne Tabelle KALENDER gestellt.
    SELECT * FROM t159l APPENDING TABLE x159l ORDER BY werks. "N1063799
    LOOP AT x159l.
      SELECT SINGLE * FROM t001w WHERE werks = x159l-werks.
      IF sy-subrc IS INITIAL.
        kalender-werks = x159l-werks.
        kalender-fabkl = t001w-fabkl.
        kalender-twaok = x159l-twaok.
        kalender-tloek = x159l-tloek.
        kalender-cnt02 = kalender-cnt02 + 1.
        APPEND kalender.
      ENDIF.
    ENDLOOP.
    PERFORM positionen_pruefen.
    DESCRIBE TABLE drkpf LINES anzahl1.
    DESCRIBE TABLE xresb LINES anzahl2.
    IF xtest IS INITIAL.
      PERFORM positionen_uebernehmen USING x.
      PERFORM update_ausfuehren.
      IF xprot IS INITIAL.
        IF xfehler IS INITIAL.
          PERFORM anforderungsbild.
        ENDIF.
      ELSE.
        PERFORM protokoll_ausgeben.
      ENDIF.
    ELSE.
      PERFORM protokoll_ausgeben.
    ENDIF.
  ENDIF.

ENDFORM.                    " SELEKTION_ERGAENZEN

*&---------------------------------------------------------------------*
*&      Form  FELDKATALOG_AUFBAUEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FIELDCAT[]  text                                           *
*----------------------------------------------------------------------*
FORM feldkatalog_aufbauen USING p_fieldcat TYPE slis_t_fieldcat_alv.

  DATA: fieldcat TYPE slis_fieldcat_alv.

  IF sy-pfkey NE 'OVERVIEW'.
    CLEAR fieldcat.
    fieldcat-fieldname     = 'BOX'.
    fieldcat-tabname       = 'BELEGE'.
    fieldcat-ref_tabname   = 'RKPF'.
    fieldcat-col_pos       = '1'.
    APPEND fieldcat TO p_fieldcat.
  ENDIF.
  CLEAR fieldcat.
  fieldcat-fieldname     = 'RSNUM'.          "
  fieldcat-tabname       = 'BELEGE'.
  fieldcat-ref_tabname   = 'RKPF'.
  fieldcat-key           = 'X'.
  fieldcat-col_pos       = '2'.
  APPEND fieldcat TO p_fieldcat.
  CLEAR fieldcat.
*  fieldcat-fieldname     = 'RSDAT'.          "
*  fieldcat-tabname       = 'BELEGE'.
*  fieldcat-ref_tabname   = 'RKPF'.
*  fieldcat-col_pos       = '3'.
*  APPEND fieldcat TO p_fieldcat.
*  CLEAR fieldcat.
*  fieldcat-fieldname     = 'KENNZ'.          "
*  fieldcat-tabname       = 'BELEGE'.
*  fieldcat-seltext_l     = text-061.
*  fieldcat-seltext_m     = text-061.
*  fieldcat-seltext_s     = text-061.
*  fieldcat-just          = 'C'.
*  fieldcat-col_pos       = '3'.
*  APPEND fieldcat TO p_fieldcat.
  fieldcat-fieldname     = 'MATNR'.          "
  fieldcat-tabname       = 'BELEGE'.
  fieldcat-ref_tabname   = 'RESB'.
  fieldcat-col_pos       = '3'.
  APPEND fieldcat TO p_fieldcat.
  CLEAR fieldcat.
  fieldcat-fieldname     = 'WERKS'.          "
  fieldcat-tabname       = 'BELEGE'.
  fieldcat-ref_tabname   = 'RESB'.
  fieldcat-col_pos       = '5'.
  APPEND fieldcat TO p_fieldcat.
  CLEAR fieldcat.
  fieldcat-fieldname     = 'LGORT'.          "
  fieldcat-tabname       = 'BELEGE'.
  fieldcat-ref_tabname   = 'RESB'.
  fieldcat-col_pos       = '6'.
  APPEND fieldcat TO p_fieldcat.
  CLEAR fieldcat.
  fieldcat-fieldname     = 'BDMNG'.          "
  fieldcat-tabname       = 'BELEGE'.
  fieldcat-ref_tabname   = 'RESB'.
  fieldcat-col_pos       = '7'.
  APPEND fieldcat TO p_fieldcat.
  CLEAR fieldcat.
  fieldcat-fieldname     = 'MEINS'.          "
  fieldcat-tabname       = 'BELEGE'.
  fieldcat-ref_tabname   = 'RESB'.
  fieldcat-col_pos       = '8'.
  APPEND fieldcat TO p_fieldcat.
  CLEAR fieldcat.

ENDFORM.                    " FELDKATALOG_AUFBAUEN

*&---------------------------------------------------------------------*
*&      Form  LISTAUSGABE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM listausgabe.

  layout-box_fieldname = 'BOX'.
  layout-box_tabname   = 'BELEGE'.
  layout-coltab_fieldname = 'FARBE'.
  layout-f2code = '9PRB'.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY' "#EC CI_FLDEXT_OK[2215424] P30K910013
       EXPORTING
*           I_INTERFACE_CHECK        = ' '
            i_callback_program       = repid
            i_callback_pf_status_set = 'STATUS'
            i_callback_user_command  = 'USER_COMMAND'
*           I_STRUCTURE_NAME         =
            is_layout                = layout
            it_fieldcat              = fieldcat[]
*           IT_EXCLUDING             =
*           IT_SPECIAL_GROUPS        =
*           IT_SORT                  =
*           IT_FILTER                =
*           IS_SEL_HIDE              =
            i_default                = 'X'
            i_save                   = 'A'
            is_variant               = variante
*           IT_EVENTS                =
*           IT_EVENT_EXIT            =
            is_print                 = print
*           I_SCREEN_START_COLUMN    = 0
*           I_SCREEN_START_LINE      = 0
*           I_SCREEN_END_COLUMN      = 0
*           I_SCREEN_END_LINE        = 0
*      IMPORTING
*           E_EXIT_CAUSED_BY_CALLER  =
*           ES_EXIT_CAUSED_BY_USER   =
       TABLES
            t_outtab                 = belege.
*      exceptions
*           program_error            = 1
*           others                   = 2.

ENDFORM.                    " LISTAUSGABE

*&---------------------------------------------------------------------*
*&      Form  EINGABEN_PRUEFEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM eingaben_pruefen.

  IF NOT p_vari IS INITIAL.
    MOVE variante TO def_variante.
    MOVE p_vari TO def_variante-variant.
    CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
      EXPORTING
        i_save     = variant_save
      CHANGING
        cs_variant = def_variante.
    variante = def_variante.
  ELSE.
    CLEAR variante.
    variante-report = repid.
  ENDIF.

ENDFORM.                    " EINGABEN_PRUEFEN

*&---------------------------------------------------------------------*
*&      Form  RESERVIERUNGSKOEPFE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM reservierungskoepfe.

  IF NOT rsdat IS INITIAL.                                  "note 204361
    IF kostl[] IS INITIAL AND aufnr[] IS INITIAL AND        "819190
       projn[] IS INITIAL AND nplnr[] IS INITIAL AND        "819190
       kdauf[] IS INITIAL AND anln1[] IS INITIAL AND        "819190
       umwrk[] IS INITIAL AND umlgo[] IS INITIAL AND        "819190
       xkont   IS INITIAL.                                  "819190
*ENHANCEMENT-SECTION     RESERVIERUNGSKOEPFE_01 SPOTS ES_RM07RVER.
      SELECT * FROM rkpf INTO CORRESPONDING FIELDS OF TABLE lrkpf
                                            WHERE rsnum IN rsnum
                                            AND   rsdat LE rsdat
                                            AND   kzver EQ space
                                            AND   bwart IN s_bwart.
*END-ENHANCEMENT-SECTION.
    ELSE.
      IF NOT xkont IS INITIAL.
*ENHANCEMENT-SECTION     RESERVIERUNGSKOEPFE_02 SPOTS ES_RM07RVER.
        SELECT * FROM rkpf INTO CORRESPONDING FIELDS OF TABLE lrkpf
                                              WHERE rsnum IN rsnum
                                              AND   rsdat LE rsdat
                                              AND   kzver EQ space
                                              AND   kostl EQ space
                                              AND   aufnr EQ space
                                              AND   ps_psp_pnr EQ space
                                              AND   nplnr EQ space
                                              AND   kdauf EQ space
                                              AND   anln1 EQ space
                                              AND   umlgo EQ space
                                              AND   umwrk EQ space
                                              AND   bwart IN s_bwart
                                              ORDER BY PRIMARY KEY.
*END-ENHANCEMENT-SECTION.
      ELSEIF xkont IS INITIAL.
*ENHANCEMENT-SECTION     RESERVIERUNGSKOEPFE_03 SPOTS ES_RM07RVER.
        SELECT * FROM rkpf INTO CORRESPONDING FIELDS OF TABLE lrkpf
                                              WHERE rsnum IN rsnum
                                              AND   rsdat LE rsdat
                                              AND   kzver EQ space
                                              AND   kostl IN kostl
                                              AND   aufnr IN aufnr
                                              AND   ps_psp_pnr IN projn
                                              AND   nplnr IN nplnr
                                              AND   kdauf IN kdauf
                                              AND   anln1 IN anln1
                                              AND   umlgo IN umlgo
                                              AND   umwrk IN umwrk
                                              AND   bwart IN s_bwart
                                              ORDER BY PRIMARY KEY.
*END-ENHANCEMENT-SECTION.
      ENDIF.
    ENDIF.
  ELSE.                                               "begin note 204361
    IF kostl[] IS INITIAL AND aufnr[] IS INITIAL AND        "819190
       projn[] IS INITIAL AND nplnr[] IS INITIAL AND        "819190
       kdauf[] IS INITIAL AND anln1[] IS INITIAL AND        "819190
       umwrk[] IS INITIAL AND umlgo[] IS INITIAL AND        "819190
       xkont   IS INITIAL.                                  "819190
*ENHANCEMENT-SECTION     RESERVIERUNGSKOEPFE_04 SPOTS ES_RM07RVER.
      SELECT * FROM rkpf INTO CORRESPONDING FIELDS OF TABLE lrkpf
                                            WHERE rsnum IN rsnum
                                            AND   kzver EQ space
                                            AND   bwart IN s_bwart.
*END-ENHANCEMENT-SECTION.
    ELSE.
      IF NOT xkont IS INITIAL.
        SELECT * FROM rkpf INTO CORRESPONDING FIELDS OF TABLE lrkpf
                                              WHERE rsnum IN rsnum
                                              AND   kzver EQ space
                                              AND   kostl EQ space
                                              AND   aufnr EQ space
                                              AND   ps_psp_pnr EQ space
                                              AND   nplnr EQ space
                                              AND   kdauf EQ space
                                              AND   anln1 EQ space
                                              AND   umlgo EQ space
                                              AND   umwrk EQ space
                                              AND   bwart IN s_bwart
                                              ORDER BY PRIMARY KEY.
      ELSEIF xkont IS INITIAL.
*ENHANCEMENT-SECTION     RESERVIERUNGSKOEPFE_05 SPOTS ES_RM07RVER.
        SELECT * FROM rkpf INTO CORRESPONDING FIELDS OF TABLE lrkpf
                                              WHERE rsnum IN rsnum
                                            AND   kzver EQ space
                                            AND   kostl IN kostl
                                            AND   aufnr IN aufnr
                                            AND   ps_psp_pnr IN projn
                                            AND   nplnr IN nplnr
                                            AND   kdauf IN kdauf
                                            AND   anln1 IN anln1
                                            AND   umlgo IN umlgo
                                            AND   umwrk IN umwrk
                                            AND   bwart IN s_bwart
                                            ORDER BY PRIMARY KEY.
*END-ENHANCEMENT-SECTION.
      ENDIF.
    ENDIF.
  ENDIF.                                                "end note 204361

  lrsnum-sign = 'I'.
  lrsnum-option = 'EQ'.
  DESCRIBE TABLE lrkpf LINES index_t.
  LOOP AT lrkpf.
    lrsnum-low = lrkpf-rsnum.
    APPEND lrsnum.
    zaehler = zaehler + 1.
    max_zaehler = max_zaehler + 1.
    IF zaehler = rmax.
      SELECT * FROM rkpf APPENDING TABLE yrkpf WHERE rsnum IN lrsnum AND bwart IN s_bwart.
      REFRESH lrsnum.
      CLEAR zaehler.
      IF max_zaehler = index_t.
        CLEAR max_zaehler.
        CLEAR index_t.
        EXIT.
      ENDIF.
    ENDIF.
    IF max_zaehler = index_t.
      SELECT * FROM rkpf APPENDING TABLE yrkpf WHERE rsnum IN lrsnum AND bwart IN s_bwart.
      REFRESH lrsnum.
      CLEAR zaehler.
      CLEAR max_zaehler.
      CLEAR index_t.
      EXIT.
    ENDIF.
  ENDLOOP.
  REFRESH lrkpf.

  LOOP AT yrkpf.
*-- Nur wenn Reservierungsverursacher initial ist, kann Position
*   über diesen Report verwaltet werden (Rel. 2.1)
    CHECK yrkpf-kzver IS INITIAL.
    IF NOT rsdat IS INITIAL.
      CHECK yrkpf-rsdat <= rsdat.
    ENDIF.
    CLEAR auth02.
    PERFORM bewegungsart_rs USING actvt02
                                  yrkpf-bwart.
    IF no_chance IS INITIAL.
      IF NOT auth02 IS INITIAL.
        no_chance = x.
      ENDIF.
    ENDIF.
    CLEAR auth06.
    PERFORM bewegungsart_rs USING actvt06
                                  yrkpf-bwart.
    IF no_chance IS INITIAL.
      IF NOT auth06 IS INITIAL.
        no_chance = x.
      ENDIF.
    ENDIF.
    MOVE-CORRESPONDING yrkpf TO lrkpf.
    APPEND lrkpf.
  ENDLOOP.
  FREE yrkpf.

  IF rsdat IS INITIAL.
    rsdat = sy-datlo.
  ENDIF.
  c_rsdat = rsdat.

ENDFORM.                    " RESERVIERUNGSKOEPFE

*&---------------------------------------------------------------------*
*&      Form  RESERVIERUNGSPOSITIONEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM reservierungspositionen.

  IF NOT no_chance IS INITIAL.
    MESSAGE s124.
  ENDIF.
  READ TABLE lrkpf INDEX 1.
  IF NOT sy-subrc IS INITIAL.
    MESSAGE s841.
  ELSE.
    PERFORM positionen_lesen_array.
    LOOP AT yresb.
      CLEAR yresb-box.
      MODIFY yresb.
    ENDLOOP.
    PERFORM datum_pruefen_vorbereiten.
    PERFORM positionen_pruefen.
    DESCRIBE TABLE drkpf LINES anzahl1.
    DESCRIBE TABLE xresb LINES anzahl2.
    IF xtest IS INITIAL.
      PERFORM positionen_uebernehmen USING x.
      PERFORM update_ausfuehren.
      IF xprot IS INITIAL.
        IF xfehler IS INITIAL.
          PERFORM anforderungsbild.
        ENDIF.
      ELSE.
        PERFORM protokoll_ausgeben.
      ENDIF.
    ELSE.
      PERFORM protokoll_ausgeben.
    ENDIF.
  ENDIF.

ENDFORM.                    " RESERVIERUNGSPOSITIONEN

*&---------------------------------------------------------------------*
*&      Form  STATUS
*&---------------------------------------------------------------------*
FORM status USING extab TYPE slis_t_extab.

  IF xtest IS INITIAL.
    SET PF-STATUS 'STANDARD'.
  ELSE.
    SET PF-STATUS 'TEST'.
    SET TITLEBAR  '001'.
  ENDIF.

ENDFORM.                    " STATUS

*&---------------------------------------------------------------------*
*&      Form  POSITIONEN_LESEN_ARRAY
*&---------------------------------------------------------------------*
*       Lesen der Positionen zu den selektierten Reservierungsköpfen
*----------------------------------------------------------------------*
FORM positionen_lesen_array.

  irsnum-sign = 'I'.
  irsnum-option = 'EQ'.
  DESCRIBE TABLE lrkpf LINES index_t.
  LOOP AT lrkpf.
    irsnum-low = lrkpf-rsnum.
    APPEND irsnum.
    zaehler = zaehler + 1.
    max_zaehler = max_zaehler + 1.
    IF zaehler = rmax.
      SELECT * FROM resb APPENDING TABLE yresb WHERE rsnum IN irsnum
                                                 AND werks IN s_werks.
      REFRESH irsnum.
      CLEAR zaehler.
      IF max_zaehler = index_t.
        CLEAR max_zaehler.
        CLEAR index_t.
        EXIT.
      ENDIF.
    ENDIF.
    IF max_zaehler = index_t.
      SELECT * FROM resb APPENDING TABLE yresb WHERE rsnum IN irsnum
                                                 AND werks IN s_werks.
      REFRESH irsnum.
      CLEAR zaehler.
      CLEAR max_zaehler.
      CLEAR index_t.
      EXIT.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " POSITIONEN_LESEN_ARRAY

*&---------------------------------------------------------------------*
*&      Form  DATUM_PRUEFEN_VORBEREITEN
*&---------------------------------------------------------------------*
*       Die für die spätere Datumsprüfungen relevanten Informationen   *
*       werden aus den Tabellen T001W und T159L ermittelt.             *
*----------------------------------------------------------------------*
FORM datum_pruefen_vorbereiten.

  SELECT * FROM t159l APPENDING TABLE x159l ORDER BY werks. "N1063799
  LOOP AT x159l.
    SELECT SINGLE * FROM t001w WHERE werks = x159l-werks.
    IF sy-subrc IS INITIAL.
      kalender-werks = x159l-werks.
      kalender-fabkl = t001w-fabkl.
      kalender-twaok = x159l-twaok.
      kalender-tloek = x159l-tloek.
      kalender-cnt02 = kalender-cnt02 + 1.
      APPEND kalender.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " DATUM_PRUEFEN_VORBEREITEN

*&---------------------------------------------------------------------*
*&      Form  LISTAUSGABE1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM listausgabe1.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY' "#EC CI_FLDEXT_OK[2215424] P30K910013
       EXPORTING
*           I_INTERFACE_CHECK        = ' '
            i_callback_program       = repid
            i_callback_pf_status_set = 'OVERVIEW'
            i_callback_user_command  = 'USER_COMMAND'
*           I_STRUCTURE_NAME         =
            is_layout                = layout
            it_fieldcat              = fieldcat[]
*           IT_EXCLUDING             =
*           IT_SPECIAL_GROUPS        =
*           IT_SORT                  =
*           IT_FILTER                =
*           IS_SEL_HIDE              =
            i_default                = 'X'
            i_save                   = 'A'
            is_variant               = variante
*           IT_EVENTS                =
*           IT_EVENT_EXIT            =
            is_print                 = print
*           I_SCREEN_START_COLUMN    = 0
*           I_SCREEN_START_LINE      = 0
*           I_SCREEN_END_COLUMN      = 0
*           I_SCREEN_END_LINE        = 0
*      IMPORTING
*           E_EXIT_CAUSED_BY_CALLER  =
*           ES_EXIT_CAUSED_BY_USER   =
       TABLES
            t_outtab                 = detail.
*      exceptions
*           program_error            = 1
*           others                   = 2.

ENDFORM.                    " LISTAUSGABE1

*&---------------------------------------------------------------------*
*&      Form  FELDKATALOG_POSITION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FIELDCAT[]  text                                           *
*----------------------------------------------------------------------*
FORM feldkatalog_position USING p_fieldcat TYPE slis_t_fieldcat_alv.

  DATA: fieldcat TYPE slis_fieldcat_alv.

  REFRESH p_fieldcat.
  IF sy-pfkey NE 'OVERVIEW'.
    CLEAR fieldcat.
    fieldcat-fieldname     = 'BOX'.
    fieldcat-tabname       = 'POSITION'.
    fieldcat-ref_tabname   = 'RESB'.
    fieldcat-col_pos       = '1'.
    APPEND fieldcat TO p_fieldcat.
  ENDIF.
  CLEAR fieldcat.
  fieldcat-fieldname     = 'RSNUM'.          "
  fieldcat-tabname       = 'POSITION'.
  fieldcat-ref_tabname   = 'RESB'.
  fieldcat-key           = 'X'.
  fieldcat-col_pos       = '2'.
  APPEND fieldcat TO p_fieldcat.
  CLEAR fieldcat.
  fieldcat-fieldname     = 'RSPOS'.          "
  fieldcat-tabname       = 'POSITION'.
  fieldcat-ref_tabname   = 'RESB'.
  fieldcat-key           = 'X'.
  fieldcat-col_pos       = '3'.
  APPEND fieldcat TO p_fieldcat.
  CLEAR fieldcat.
  fieldcat-fieldname     = 'BDTER'.          "
  fieldcat-tabname       = 'POSITION'.
  fieldcat-ref_tabname   = 'RESB'.
  fieldcat-col_pos       = '4'.
  APPEND fieldcat TO p_fieldcat.
  CLEAR fieldcat.
  fieldcat-fieldname     = 'XWAOK_ALT'.          "
  fieldcat-tabname       = 'POSITION'.
  fieldcat-ref_tabname   = 'RESB'.
  fieldcat-col_pos       = '5'.
  fieldcat-seltext_l     = text-041.
  fieldcat-seltext_m     = text-041.
  fieldcat-seltext_s     = text-041.
  fieldcat-just          = 'C'.
  APPEND fieldcat TO p_fieldcat.
  CLEAR fieldcat.
  fieldcat-fieldname     = 'XWAOK_NEU'.          "
  fieldcat-tabname       = 'POSITION'.
  fieldcat-ref_tabname   = 'RESB'.
  fieldcat-col_pos       = '6'.
  fieldcat-seltext_l     = text-042.
  fieldcat-seltext_m     = text-042.
  fieldcat-seltext_s     = text-042.
  fieldcat-just          = 'C'.
  APPEND fieldcat TO p_fieldcat.
  CLEAR fieldcat.
  fieldcat-fieldname     = 'XLOEK_ALT'.          "
  fieldcat-tabname       = 'POSITION'.
  fieldcat-ref_tabname   = 'RESB'.
  fieldcat-col_pos       = '7'.
  fieldcat-seltext_l     = text-043.
  fieldcat-seltext_m     = text-043.
  fieldcat-seltext_s     = text-043.
  fieldcat-just          = 'C'.
  APPEND fieldcat TO p_fieldcat.
  CLEAR fieldcat.
  fieldcat-fieldname     = 'XLOEK_NEU'.          "
  fieldcat-tabname       = 'POSITION'.
  fieldcat-ref_tabname   = 'RESB'.
  fieldcat-col_pos       = '8'.
  fieldcat-seltext_l     = text-044.
  fieldcat-seltext_m     = text-044.
  fieldcat-seltext_s     = text-044.
  fieldcat-just          = 'C'.
  APPEND fieldcat TO p_fieldcat.

ENDFORM.                    " FELDKATALOG_POSITION

*&---------------------------------------------------------------------*
*&      Form  LISTAUSGABE_POSITION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM listausgabe_position.

  layout-box_fieldname = 'BOX'.
  layout-box_tabname   = 'POSITION'.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY' "#EC CI_FLDEXT_OK[2215424] P30K910013
       EXPORTING
*           I_INTERFACE_CHECK        = ' '
            i_callback_program       = repid
            i_callback_pf_status_set = 'POSITION'
            i_callback_user_command  = 'USER_COMMAND'
*           I_STRUCTURE_NAME         =
            is_layout                = layout
            it_fieldcat              = fieldcat_p[]
*           IT_EXCLUDING             =
*           IT_SPECIAL_GROUPS        =
*           IT_SORT                  =
*           IT_FILTER                =
*           IS_SEL_HIDE              =
            i_default                = 'X'
            i_save                   = 'A'
            is_variant               = variante
*           IT_EVENTS                =
*           IT_EVENT_EXIT            =
            is_print                 = print
*           I_SCREEN_START_COLUMN    = 0
*           I_SCREEN_START_LINE      = 0
*           I_SCREEN_END_COLUMN      = 0
*           I_SCREEN_END_LINE        = 0
*      IMPORTING
*           E_EXIT_CAUSED_BY_CALLER  =
*           ES_EXIT_CAUSED_BY_USER   =
       TABLES
            t_outtab                 = position.
*      exceptions
*           program_error            = 1
*           others                   = 2.
ENDFORM.                    " LISTAUSGABE_POSITION

*&---------------------------------------------------------------------*
*&      Form  LISTAUSGABE_P1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM listausgabe_p1.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY' "#EC CI_FLDEXT_OK[2215424] P30K910013
       EXPORTING
*           I_INTERFACE_CHECK        = ' '
            i_callback_program       = repid
            i_callback_pf_status_set = 'OVERVIEW'
            i_callback_user_command  = 'USER_COMMAND'
*           I_STRUCTURE_NAME         =
            is_layout                = layout
            it_fieldcat              = fieldcat_p[]
*           IT_EXCLUDING             =
*           IT_SPECIAL_GROUPS        =
*           IT_SORT                  =
*           IT_FILTER                =
*           IS_SEL_HIDE              =
            i_default                = 'X'
            i_save                   = 'A'
            is_variant               = variante
*           IT_EVENTS                =
*           IT_EVENT_EXIT            =
            is_print                 = print
*           I_SCREEN_START_COLUMN    = 0
*           I_SCREEN_START_LINE      = 0
*           I_SCREEN_END_COLUMN      = 0
*           I_SCREEN_END_LINE        = 0
*      IMPORTING
*           E_EXIT_CAUSED_BY_CALLER  =
*           ES_EXIT_CAUSED_BY_USER   =
       TABLES
            t_outtab                 = detail.
*      exceptions
*           program_error            = 1
*           others                   = 2.

ENDFORM.                    " LISTAUSGABE_P1
