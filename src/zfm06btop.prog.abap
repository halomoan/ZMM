************************************************************************
*        Listanzeige Bestellanforderungen                              *
************************************************************************
REPORT sapfm06b MESSAGE-ID me.

*----------------------------------------------------------------------*
*        Tabellen                                                      *
*----------------------------------------------------------------------*
TABLES: t001w,                         "Werkstabelle
        t001k,
        t001,
        eban,
       *eban,
        ebkn,
        ekko,
        ekpo,
       *ekko,
        eord,
        lfa1,
        lfm1,
        meico,
        eina,
        eine,
        essr,
        rm06e,
        rm06b,
        mt06e,
        mtcom,
        mtcor,
        mt06k,
        mt61d, *mt61d,
        maprf, *maprf,
        propf,
        prowf,
        mara,
        mt61b,
        mdsta, *mdsta,
        mdkp,
        cm61x,
        cm61m,
        cm61w,
        iverb, *iverb,
        mdbs,
        bqpim,   "Bezugsquelle Export
        bqpex,   "Bezugsquelle Import
        t002,
        t006,
        t024e,
        t160,
        t160m,
        t160d, t160v,
        t161,
        t161t,
        t161a,
        t161s,
        t161u,
        t16ft,
        t024w,   "Lieferantenbeurteilung 'Ermitteln Ekorg's pro Werk'
        t16la,
       *t16la,
        t16lb,
        t16ld,
        t16lh,
        t16li,
        t16ll,
        t399d,
        t438a,
        t438m,
        tmppf,                          "HTN-Abwicklung 4.0
        tcurm.                          "Konsi-Abwicklung 4.0

*... Ikonen ..........................................................*
INCLUDE <icon>.
DATA: icon_field LIKE icon_red_light.

*----------------------------------------------------------------------*
*        Interne Tabellen                                              *
*----------------------------------------------------------------------*
*-- Tabelle der selektierten Banfs ------------------------------------*
ENHANCEMENT-SECTION     FM06BTOP_02 SPOTS ES_SAPFM06B STATIC .
DATA: BEGIN OF ban OCCURS 100.
        INCLUDE STRUCTURE eban.
DATA:    updk1 LIKE t16la-updkz,     "Status der Zuordnung
         updk2 LIKE t16la-updkz,     "Status der Zuordnung (alt)
         updk3 LIKE t16la-updkz,     "Sicherungsstatus
         selkf(2) TYPE p,            "Kz. für Sammelfreigabe
         selkz,                      "Selektiert ja/nein
         szeil LIKE sy-curow,        "Zeilennr. des Selektionskz.
         zeile LIKE sy-curow,        "Zeilennr. der Zuordnungsinfo
         page  LIKE sy-pagno,        "Seite
         aenda,                      "Kz. Berecht. für Änderungsbeleg
         bukrs LIKE ekko-bukrs,      "Buchungskreis für Buchungskreisüb.
         slief LIKE eban-flief,      "Lieferant für Sortierung
         bkmkz,                      "Art der Kontierung      "4.0C
         kont1(24),                  "Kontierungsfeld 1       "4.0C
         kont2(8),                   "Kontierungsfeld 2
         bkuml,                      "Kz. Bukrs-übergreifende Umlagerung
         az_pos TYPE i,              "Anzahl Pos. pro Banf
         sl_pos TYPE i,              "Anzahl selektierter Pos. pro Banf
         arch_date LIKE sy-datlo,    "Archivierungsdatum "TK 4.0B EURO
      END OF ban.
END-ENHANCEMENT-SECTION.
*... Banf-Tabelle zum Sortieren bei Gesamtbanfen .....................*
DATA: BEGIN OF ban_gs OCCURS 100.
        INCLUDE STRUCTURE eban.
DATA:    updk1 LIKE t16la-updkz,     "Status der Zuordnung
         updk2 LIKE t16la-updkz,     "Status der Zuordnung (alt)
         updk3 LIKE t16la-updkz,     "Sicherungsstatus
         selkf(2) TYPE p,            "Kz. für Sammelfreigabe
         selkz,                      "Selektiert ja/nein
         szeil LIKE sy-curow,        "Zeilennr. des Selektionskz.
         zeile LIKE sy-curow,        "Zeilennr. der Zuordnungsinfo
         page  LIKE sy-pagno,        "Seite
         aenda,                      "Kz. Berecht. für Änderungsbeleg
         bukrs LIKE ekko-bukrs,      "Buchungskreis für Buchungskreisüb.
         slief LIKE eban-flief,      "Lieferant für Sortierung
         bkmkz,                      "Art der Kontierung        "4.0C
         kont1(24),                  "Kontierungsfeld 1         "4.0C
         kont2(8),                   "Kontierungsfeld 2
         bkuml,                      "Kz. Bukrs-übergreifende Umlagerung
         az_pos TYPE i,              "Anzahl Pos. pro Banf
         sl_pos TYPE i,              "Anzahl selektierter Pos. pro Banf
         arch_date LIKE sy-datlo,    "Archivierungsdatum "TK 4.0B EURO
      END OF ban_gs.
DATA: BEGIN OF ban2.
        INCLUDE STRUCTURE eban.
DATA:    updk1 LIKE t16la-updkz,     "Status der Zuordnung
         updk2 LIKE t16la-updkz,     "Status der Zuordnung (alt)
         updk3 LIKE t16la-updkz,     "Sicherungsstatus
         selkf(2) TYPE p,            "Kz. für Sammelfreigabe
         selkz,                      "Selektiert ja/nein
         szeil LIKE sy-curow,        "Zeilennr. des Selektionskz.
         zeile LIKE sy-curow,        "Zeilennr. der Zuordnungsinfo
         page  LIKE sy-pagno,        "Seite
         aenda,                      "Kz. Berecht. für Änderungsbeleg
         slief LIKE eban-flief,      "Lieferant für Sortierung
         bkmkz,                      "Art der Kontierung        "4.0C
         kont1(24),                  "Kontierungsfeld 1         "4.0C
         kont2(8),                   "Kontierungsfeld 2
         bkuml,                      "Kz. Bukrs-übergreifende Umlagerung
         az_pos TYPE i,              "Anzahl Pos. pro Banf
         sl_pos TYPE i,              "Anzahl selektierter Pos. pro Banf
         arch_date LIKE sy-datlo,    "Archivierungsdatum "TK 4.0B EURO
      END OF ban2.
DATA: archive_date LIKE sy-datlo.   "TK 4.0B EURO

*-- Direktwerte für UPDK1, UPDK2, UPDK3 -------------------------------*
DATA: znix(2) VALUE '00',          "keine Zuordnung
      znew(2) VALUE '01',          "neue Bezugsquellenzuordnung
      zold(2) VALUE '02',          "bestehende Bezugsquellenzuordnung
      zres(2) VALUE '03',          "zurückgestzte Zuordnung
      aend(2) VALUE '04',          "allgemeine Änderung
      zner(2) VALUE '05',          "Lieferwerk geändert
      anfr(2) VALUE '11',          "Anfragezuordnung
      alif(2) VALUE '12',          "Anfragezuordnung mit Lieferant
      aman(2) VALUE '13',          "Anfragezuordnung mehrere Lieferanten
      fres(2) VALUE '31',          "Freigabe durchgeführt
      free(2) VALUE '32',          "Einzelfreigabe durcchgeführt
      bube(2) VALUE '33',          "Bestellung angelegt
      buan(2) VALUE '34',          "Anfrage angelegt
      buba(2) VALUE '35',          "Banf gesichert
      scha(2) VALUE '36',    "Einzelfreigabe - nur geändert
      nfre(2) VALUE '37'.    "Freigabe wurde zurückgesetz


*-- Indices zu BAN ----------------------------------------------------*
DATA: b-aktind LIKE sy-tabix,
      b-lopind LIKE sy-tabix,
      b-maxind LIKE sy-tabix,
      b-pagind LIKE sy-tabix,
      b-lesind LIKE sy-tabix.

*-- Indices zu BAN bei Zuordnungsübersicht ----------------------------*
DATA: s-firstind LIKE sy-tabix,
      s-maxind   LIKE sy-tabix,
      s-aktind   LIKE sy-tabix.

*-- Key zum Lesen BAN -------------------------------------------------*
DATA: BEGIN OF bankey,
        mandt LIKE eban-mandt,
        banfn LIKE eban-banfn,
        bnfpo LIKE eban-bnfpo,
      END OF bankey.

*-- Tabelle der Indices der Banfs zur Zuordnung -----------------------*
DATA: BEGIN OF bdt OCCURS 20,
         index LIKE sy-tabix,
      END OF bdt.

*-- Tabelle der Indices der für Detailbearbeitung selektierten Banfs---*
DATA: BEGIN OF bde OCCURS 20,
         index LIKE sy-tabix,
      END OF bde.

*-- Tabelle der selektierten Banfs - Stand der Datenbank --------------*
DATA: BEGIN OF oba OCCURS 100.
        INCLUDE STRUCTURE eban.
DATA: END OF oba.

*-- Tabelle der zu bearbeitenden Banfs --------------------------------*
DATA: BEGIN OF bat OCCURS 10.
        INCLUDE STRUCTURE eban.
DATA:   updkz.
DATA: END OF bat.

*-- Struktur zum Abgleich der Banfstände ------------------------------*
*data: begin of sbat.
*        include structure eban.
*data: end of sbat.

*-- Dummytabellen für Banf-Verbuchung ---------------------------------*
DATA: BEGIN OF dis OCCURS 0.
        INCLUDE STRUCTURE edisp.
DATA: END OF dis.

*--- Tabelle der upgedateten Banfs durch Bestellung oder Einteilung ---*
DATA:    BEGIN OF batu OCCURS 20.
        INCLUDE STRUCTURE eban.
DATA:      obsmg LIKE eban-bsmng,
         END OF batu.

*-- Tabelle der Orderbuchsätze ----------------------------------------*
*-- Tabelle der Konsilieferanten --------------------------------------*
DATA: BEGIN OF kon OCCURS 10.
        INCLUDE STRUCTURE mt06k.
DATA: END OF kon.

*-- Tabellen fuer Select-options---------------------------------------*
RANGES: sel_bsart FOR eban-bsart,
        sel_pstyp FOR eban-pstyp,
        sel_knttp FOR eban-knttp,
        sel_werks FOR eban-werks,
        sel_matnr FOR eban-matnr,
        sel_matkl FOR eban-matkl.

*-- Tabelle der Lieferanten bei Anfragezuordnung - Übergabestruktur ---*
DATA: BEGIN OF alfu OCCURS 5,
        lifnr LIKE eban-lifnr,
        ekorg LIKE eban-ekorg,
      END OF alfu.

*-- Tabelle der Lieferanten bei Anfragezuordnung - automatische -------*
DATA: BEGIN OF alf OCCURS 5,
        banfn LIKE eban-banfn,
        bnfpo LIKE eban-bnfpo,
        lifnr LIKE eban-lifnr,
        ekorg LIKE eban-ekorg,
        selkz LIKE rm06b-selkz,
        vselk LIKE rm06b-selkz,
        beswk LIKE eban-beswk, " CCP
      END OF alf.
*-- Key für Lieferantentabelle ----------------------------------------*
DATA: BEGIN OF alfkey,
        banfn LIKE eban-banfn,
        bnfpo LIKE eban-bnfpo,
        lifnr LIKE eban-lifnr,
        ekorg LIKE eban-ekorg,
      END OF alfkey.
*------- Indices bei Tabellenbearbeitung Tabelle ALF ------------------*
DATA:   a-firstind(3) TYPE p,         "erster Index
        a-aktind(3)   TYPE p,         "aktueller Index
        a-maxind(3)   TYPE p,         "maximaler Index
        a-pagind(3)   TYPE p.         "aktueller Index der Seite

*-- Tabelle für Material-Pre-Fetch ------------------------------------*
DATA: BEGIN OF xpre01 OCCURS 20.
        INCLUDE STRUCTURE pre01.
DATA: END OF xpre01.

*-- Tabelle der Listaufbereitungsroutinen -----------------------------*
DATA: BEGIN OF xt16ld OCCURS 10.
        INCLUDE STRUCTURE t16ld.
DATA:    statz LIKE t16ll-statz.
DATA: END OF xt16ld.

*-- Tabelle der Datenbeschaffungssroutinen ----------------------------*
DATA: BEGIN OF xt16li OCCURS 10.
        INCLUDE STRUCTURE t16li.
DATA: END OF xt16li.

*------ EXCL ( Tabelle für GUI-PF-STATUS  )  --------------------------*
DATA:    BEGIN OF excl OCCURS 1,
           funktion(4),
         END OF excl.

*------ Tabelle der Bestellungen --------------------------------------*
DATA BEGIN OF xmdbs OCCURS 10.
        INCLUDE STRUCTURE mdbs.
DATA END OF xmdbs.
*------ Tabelle der Bestände ------------------------------------------*
DATA BEGIN OF xmt61b OCCURS 10.
        INCLUDE STRUCTURE mt61b.
DATA END OF xmt61b.

*------ Tabelle der Verbräuche ----------------------------------------*
DATA BEGIN OF gverb OCCURS 10.
        INCLUDE STRUCTURE iverb.
DATA END OF gverb.
DATA BEGIN OF xverb OCCURS 0.
        INCLUDE STRUCTURE iverb.
DATA END OF xverb.
*------ Tabelle der Verbräuche zum Material ---------------------------*
DATA: BEGIN OF mverb OCCURS 20,
         matnr LIKE eban-matnr,
         werks LIKE eban-werks.
        INCLUDE STRUCTURE iverb.
DATA: END OF mverb.
*------ Tabelle der Prognosen zum Material ----------------------------*
DATA: BEGIN OF mprog OCCURS 20,
         matnr LIKE eban-matnr,
         werks LIKE eban-werks,
         priod LIKE iverb-priod.
        INCLUDE STRUCTURE prowf.
DATA: END OF mprog.
*------ Prognoseperioden ----------------------------------------------*
DATA:  BEGIN OF xpper OCCURS 2.
        INCLUDE STRUCTURE pper.
DATA:  END OF xpper.
*------ Porgnosewerte für ein Material --------------------------------*
DATA:  BEGIN OF xprowf OCCURS 12.
        INCLUDE STRUCTURE prowf.
DATA:  END OF xprowf.
*------ Tabelle der Kumulierten Bestände/Bedarfe zum Material ---------*
DATA: BEGIN OF mmdsa OCCURS 20,
         matnr LIKE eban-matnr,
         werks LIKE eban-werks.
        INCLUDE STRUCTURE mdsta.
DATA:    dsdat LIKE mdkp-dsdat,
         rbest,
         rbstd,
         rbeda,
         rdisp,
      END OF mmdsa.
*------ Tabelle der Bedarfselementzeilen ------------------------------*
DATA BEGIN OF xmdps OCCURS 50.
        INCLUDE STRUCTURE mdps.
DATA END OF xmdps.

DATA: vindex LIKE sy-tabix.
DATA: pindex LIKE sy-tabix.
*------ Key zum Lesen der Material-Tabellen ---------------------------*
DATA: BEGIN OF matkey,
        matnr LIKE eban-matnr,
        werks LIKE eban-werks,
      END OF matkey.
DATA: mindex LIKE sy-tabix,
      msubrc LIKE sy-subrc.

*----------------------------------------------------------------------*
*        Feldleisten                                                   *
*----------------------------------------------------------------------*
*-- Feldleiste für Anzeigen Rahmenverträge zur Materialklasse ---------*
DATA: BEGIN OF kla,
        matkl LIKE eban-matkl,
        bsart LIKE eban-bsart,
        pstyp LIKE eban-pstyp,
        knttp LIKE eban-knttp,
        werks LIKE eban-werks,
      END OF kla.

*-- Feldleiste für Anzeigen Konsilieferanten --------------------------*
DATA: BEGIN OF kns,
        matnr LIKE eban-matnr,
        werks LIKE eban-werks,
      END OF kns.

*-- Feldleiste für Anzeigen Rahmenverträge zum Material ---------------*
DATA: BEGIN OF mat,
        matnr LIKE eban-matnr,
        bsart LIKE eban-bsart,
        pstyp LIKE eban-pstyp,
        knttp LIKE eban-knttp,
        werks LIKE eban-werks,
      END OF mat.

*-- Indizes zum Markieren Intervall -----------------------------------*
DATA: BEGIN OF mint,
        beg LIKE sy-index,
        end LIKE sy-index,
        act LIKE sy-index,
      END OF mint.

*-- Feldleiste für Anzeigen Infosätze ---------------------------------*
DATA: BEGIN OF inf,
        matnr LIKE eban-matnr,
        matkl LIKE eban-matkl,
        werks LIKE eban-werks,
      END OF inf.

*--- Hilfsfelder Lieferantenbeurteilung ------------------------------*
DATA: BEGIN OF libe,
         ekorg LIKE eban-ekorg,
         matnr LIKE eban-matnr,
         matkl LIKE eban-matkl,
      END OF libe.
DATA: l TYPE p.
DATA: BEGIN OF libe_eko OCCURS 2.
        INCLUDE STRUCTURE t024w.
DATA: END OF libe_eko.

*-- Feldleiste der Zuordnung ------------------------------------------*
DATA: BEGIN OF zug,
        ekorg LIKE eban-ekorg,
        bsart LIKE eban-bsart,
        flief LIKE eban-flief,
        reswk LIKE eban-reswk,
        beswk LIKE eban-beswk, " CCP
        konnr LIKE eban-konnr,
        fordn LIKE eban-fordn,
        bukrs LIKE ekko-bukrs,
        updkz LIKE t16la-updkz,
      END OF zug.

*-- Tabelle der Zuordnungen  ------------------------------------------*
DATA: BEGIN OF zug_tab OCCURS 20,
        ekorg LIKE eban-ekorg,
        bsart LIKE eban-bsart,
        slief LIKE eban-flief,
        reswk LIKE eban-reswk,
        beswk LIKE eban-beswk, " CCP
        konnr LIKE eban-konnr,
        bukrs LIKE ekko-bukrs,
        a_zaehler LIKE sy-tfill,
        b_zaehler LIKE sy-tfill,
      END OF zug_tab.

*------- Feldleiste für Banf-Liste aus Zuordnungsübersicht-------------*
DATA: BEGIN OF det,
        ekorg LIKE eban-ekorg,
        bsart LIKE eban-bsart,
        slief LIKE eban-flief,
        reswk LIKE eban-reswk,
        beswk LIKE eban-beswk, " CCP
        konnr LIKE eban-konnr,
        fordn LIKE eban-fordn,
        bukrs LIKE ekko-bukrs,
        updkz LIKE t16la-updkz,
      END OF det.
*------- Feldleiste für Banf-Liste aus Zuordnungsübersicht (save) -----*
DATA: BEGIN OF s1det,
        ekorg LIKE eban-ekorg,
        bsart LIKE eban-bsart,
        slief LIKE eban-flief,
        reswk LIKE eban-reswk,
        beswk LIKE eban-beswk, " CCP
        konnr LIKE eban-konnr,
        bukrs LIKE ekko-bukrs,
        updkz LIKE t16la-updkz,
      END OF s1det.

*------- Feldleiste für Preisaufbereitung -----------------------------*
DATA: BEGIN OF apreis,
        netpr(14),
        spac1,
        waers LIKE eine-waers,
        strich,
        peinh(6),
        bprme LIKE eine-bprme,
      END OF apreis.

*----------------------------------------------------------------------*
*  Hilfsfelder                                                         *
*----------------------------------------------------------------------*
*-- Hildfelder für Listaufbereitungsroutinen --------------------------*
DATA: hroutn(30),
      xszeil LIKE sy-tabix,
      xzeile LIKE sy-tabix,
      gs_szeil LIKE sy-tabix,    "Gesamtfreigabe
      gs_zeile LIKE sy-tabix,    "Gesamtfreigabe
      xzltyp,
      xsztyp.

*-- Hidebereich -------------------------------------------------------*
DATA: hide-index LIKE sy-tabix,
      hide-zeile LIKE sy-curow,
      hide-gsfrg LIKE eban-gsfrg,
      hide-page  LIKE sy-pagno,
      hide-koind LIKE sy-tabix.

*------- Zähler für Update-Protokoll ----------------------------------*
DATA: zsich LIKE sy-tabix,             "gesichert
      zenqu LIKE sy-tabix,             "gesperrt durch anderen Benutzer
      zaend LIKE sy-tabix,             "geändert durch anderen Benutzer
      zbere LIKE sy-tabix,             "Keine Berechitigung
      znoup LIKE sy-tabix,             "Keine Änderung nötig
      zfrei LIKE sy-tabix,             "Freigabe bereits erfolgt
*-- Note 739690
      zacce LIKE sy-tabix.             "Accounting errors

*------- Data declaration for Application log
DATA: t_mesg LIKE mesg OCCURS 0 WITH HEADER LINE,
      BEGIN OF t_excluded OCCURS 10,
         banfn TYPE eban-banfn.
        INCLUDE STRUCTURE t_mesg.
DATA: END OF t_excluded.
*-- Note 739690

*------- Hilfsfelder für Liststufenbearbeitung ------------------------*
DATA: liste,                           "G/Z Grundliste/Zuordnungen
      listkz,
      s0liste,
      s0srtkz,
      s1liste,
      s1srtkz,
      zpfkey LIKE sy-pfkey,
      zfmkey(3),
      gpfkey LIKE sy-pfkey,
      gfmkey(3).

*------- Direktwert zur Pruefung von Nettowertueberlaeufen ------------*
DATA: maxwert LIKE rm06b-gswrt VALUE '9999999999999'.
DATA: refe1(16) TYPE p.

*-- sonstige Hilfsfelder ----------------------------------------------*
ENHANCEMENT-SECTION     FM06BTOP_03 SPOTS ES_SAPFM06B STATIC .
DATA:
      not_all_ordb,                    "nicht alle wurden zugeordnet
      o-datum LIKE ban-frgdt,          "Hilfsfeld Datum f. Orderb.zuord.
      index LIKE sy-tabix,             "Hilfsfeld Tabellenindex
      index_ban LIKE hide-index,       "Tabellenindex in Banftabelle
      lsind LIKE sy-lsind,             "Hilfsfeld Liststufe
      leerflg,                         "Kennz. Funktion ausgeführt
      call_updkz,                      "Kennz. Verbuchung erfolgt
      izaehl TYPE i,                   "Zaehler
      bzaehl TYPE i,                   "Zaehler
      s-zaehler(5),                    "Zähler selektierte Banfs
      b-zaehler(5),                    "Zähler bestellte Banfs
      lzeile,                          "Kz. Lieferantenzeile gedruckt
      auto,                            "Kz. automatische Bearbeitung
      exitflag,                        "Kennzeichen Routine verlassen
      loopexit,                        "Kennzeichen Routine verlassen
      retco,                           "Returncode
      xauth,                           "Kz. fehlende Berechtigung
      aendanz,                         "Kz. Änderungen anzeigbar
      efube LIKE t160d-efubu,          "Funktionsberechtigung
      evopa LIKE t160v-evopa,          "Vorschlagswerte
      counta LIKE sy-tabix,            "Anzahl Tabelleneinträge alt
      countn LIKE sy-tabix,            "Anzahl Tabelleneinträge neu
      uebknt2(60),                     "Überschrift Kontierung
      hkont1(24),                      "Kontierung 1        "4.0C
      hkont2(8),                       "Kontierung 2
      hnplnr LIKE ebkn-nplnr,          "Hilfsfeld Netzplan
      hvornr LIKE cobl-vornr,          "Hilfsfeld Netzplan
      colflag,                         "Flag für Streifenmuster
      hline(80),                       "Hilfsfeld für Sonderzeile
      fline(80),                       "Hilfsfeld für Sonderzeile
      htitel(30),                      "Titel Freigabepopup
      xcalld,                          "Flag Step-Loop-Bild gecalled
      merk LIKE ban-updk1.             "Merker für Updk1
END-ENHANCEMENT-SECTION.

*... Felder für Gesamtfreigabe .......................................*
DATA: sl_pos TYPE i.      "Anzahl selektierter Pos. pro Banf

*------- Feldsymbole für Kontierungswechsel --------------------------*
FIELD-SYMBOLS: <skf1>, <skf2>,
               <akf1>, <akf2>.
DATA: dummy.
DATA: save_banf LIKE eban-banfn,
      save_selkz LIKE ban-selkz.

* ehemalige FMMEXCOM-Felder
DATA: bimukont, cattkz, aktyp.

ENHANCEMENT-POINT FM06BTOP_01 SPOTS ES_SAPFM06B STATIC.
* generic reporting: instances and factories
DATA: gf_factory TYPE REF TO if_table_manager_mm,
      gf_tab     TYPE REF TO if_any_table_mm.

INCLUDE zfm06bcd1.

INCLUDE zfm06bcdf.
INCLUDE zfm06bcdv.   "kb
INCLUDE zfm06bcdc.   "kb
*NCLUDE ZM06BCDV.    "kb
*NCLUDE ZM06BCDC.    "kb
INCLUDE zfm06bu01.
INCLUDE zfm06bu02.
INCLUDE zfm06lccd.
INCLUDE zfmmexdir.
INCLUDE zfm06lcim.                                           "4.6A CF
