************************************************************************
*          Direktwerte                                                 *
************************************************************************
SET EXTENDED CHECK OFF.
CONSTANTS:
* Werte zu Trtyp und Aktyp:
  hin        VALUE 'H',             "Hinzufuegen
  ver        VALUE 'V',             "Veraendern
  anz        VALUE 'A',             "Anzeigen
  erw        VALUE 'E',             "Bestellerweiterung

* BSTYP
  bstyp-info VALUE 'I',
  bstyp-ordr VALUE 'W',
  bstyp-banf VALUE 'B',
  bstyp-best VALUE 'F',
  bstyp-anfr VALUE 'A',
  bstyp-kont VALUE 'K',
  bstyp-lfpl VALUE 'L',
  bstyp-lerf VALUE 'Q',

* BSAKZ
  bsakz-norm VALUE ' ',
  bsakz-tran VALUE 'T',
  bsakz-rahm VALUE 'R',

* PSTYP
  pstyp-lagm VALUE '0',
  pstyp-blnk VALUE '1',
  pstyp-kons VALUE '2',
  pstyp-lohn VALUE '3',
  pstyp-munb VALUE '4',
  pstyp-stre VALUE '5',
  pstyp-text VALUE '6',
  pstyp-umlg VALUE '7',
  pstyp-wagr VALUE '8',
  pstyp-dien VALUE '9',

* Kzvbr
  kzvbr-anla VALUE 'A',
  kzvbr-unbe VALUE 'U',
  kzvbr-verb VALUE 'V',
  kzvbr-einz VALUE 'E',
  kzvbr-proj VALUE 'P',

* ESOKZ
  esokz-pipe  VALUE 'P',
  esokz-lohn  VALUE '3',
  esokz-konsi VALUE '2',               "konsi
  esokz-charg VALUE '1',               "sc-jp
  esokz-norm  VALUE '0'.


*ENHANCEMENT-POINT fmmexdir_02 SPOTS es_fmmexdir STATIC INCLUDE BOUND.
CONSTANTS:
* Handling von Unterpositionsdaten
  sihan-nix  VALUE ' ',      "keine eigenen Daten
  sihan-anz  VALUE '1',      "Daten aus Hauptposition kopiert, nicht änd
  sihan-kop  VALUE '2',      "Daten aus Hauptposition kopiert, aber ände
  sihan-eig  VALUE '3',      "eigene Daten (nicht aus Hauptposition kopi

* Unterpositionstypen
  uptyp-hpo VALUE ' ',       "Hauptposition
  uptyp-var VALUE '1',       "Variante
  uptyp-nri VALUE '2',       "Naturalrabatt Inklusive (=Dreingabe)
  uptyp-ler VALUE '3',       "Leergut
  uptyp-nre VALUE '4',       "Naturalrabatt Exklusive (=Draufgabe)
  uptyp-lot VALUE '5',       "Lot Position
  uptyp-dis VALUE '6',       "Display Position
  uptyp-vks VALUE '7',       "VK-Set Position
  uptyp-mpn VALUE '8',       "Austauschposition (A&D)
  uptyp-sls VALUE '9',       "Vorkommisionierungsposition (retail)
  uptyp-fwe VALUE 'F',       "Forward Exchange (A&D) ERP2007
  uptyp-gth VALUE 'H',       "Global Trade Header           "622794
  uptyp-gti VALUE 'I',       "Global Trade Item             "622794
  uptyp_pic VALUE 'P',       "APO Produktaustausch (Umlagerung)
  uptyp-div VALUE 'X',       "HP hat UP's mit verschiedenen Typen
  uptyp-sus VALUE 'S',       "TPOP supersession sub item type
  uptyp-hir VALUE 'A',       "SRM deep hierarchies          "WP145920
  uptyp-uid VALUE 'U',       "IUID Embedded items        "EHP603 IUID

* Artikeltypen
  attyp-sam(2) VALUE '01',   "Sammelartikel
  attyp-var(2) VALUE '02',   "Variante
  attyp-we1(2) VALUE '20',   "Wertartikel
  attyp-we2(2) VALUE '21',   "Wertartikel
  attyp-we3(2) VALUE '22',   "Wertartikel
  attyp-vks(2) VALUE '10',   "VK-Set
  attyp-lot(2) VALUE '11',   "Lot-Artikel
  attyp-dis(2) VALUE '12',   "Display

* Konfigurationsherkunft
  kzkfg-fre VALUE ' ',       "Konfiguration sonst woher
  kzkfg-kan VALUE '1',       "noch nicht konfiguriert
  kzkfg-eig VALUE '2',       "Eigene Konfiguration

* Ja, Nein
  c_ja   TYPE c VALUE 'X',
  c_nein TYPE c VALUE ' ',

* Vorgangsart, welche Anwendung den Fkt-Baustein aufruft
  cva_ab(1) VALUE 'B',     "Automatische bestellung (aus banfen)
  cva_we(1) VALUE 'C',     "Wareneingang
  cva_bu(1) VALUE 'D',     "Übernahme bestellungen aus fremdsystem
  cva_au(1) VALUE 'E',     "Aufteiler
  cva_kb(1) VALUE 'F',     "Kanban
  cva_fa(1) VALUE 'G',     "Filialauftrag
  cva_dr(1) VALUE 'H',     "DRP
  cva_re(1) VALUE 'R',     "Rescheduling
  cva_en(1) VALUE '9',     "Enjoy
  cva_ap(1) VALUE '1',     "APO
  cva_ed(1) VALUE 'T',     "EDI-Eingang Auftragsbestätigung Update Preis

* Status des Einkaufsbeleges (EKKO-STATU)
  cks_ag(1) VALUE 'A',     "Angebot vorhanden für Anfrage
  cks_ab(1) VALUE 'B',     "Automatische Bestellung (aus Banfen) ME59
  cks_we(1) VALUE 'C',     "Bestellung aus Wareneingang
  cks_bu(1) VALUE 'D',     "Bestellung aus Datenübernahme
  cks_au(1) VALUE 'E',     "Bestellung aus Aufteiler (IS-Retail)
  cks_kb(1) VALUE 'F',     "Bestellung aus Kanban
  cks_fa(1) VALUE 'G',     "Bestellung aus Filialauftrag (IS-Retail)
  cks_dr(1) VALUE 'H',     "Bestellung aus DRP
  cks_ba(1) VALUE 'I',     "Bestellung aus BAPI
  cks_al(1) VALUE 'J',     "Bestellung aus ALE-Szenario
  cks_sb(1) VALUE 'S',     "Sammelbestellung (IS-Retail)
  cks_ap(1) VALUE '1',     "APO
  cks_en(1) VALUE '9',     "Enjoy Bestellung
  cks_fb(1) VALUE 'X',     "Bestellung aus Funktionsbaustein
  cks_crm LIKE ekko-statu VALUE 'L',   "Lieferplan aus CRM

* Status der Einkaufsbelegposition (ekpo-status)
  cps_ccp LIKE ekpo-status VALUE 'C',  "Bestellpos. aus CrossCompProc

* Vorgang aus T160
  vorga-angb(2) VALUE 'AG',   "Angebot zur Anfrage    ME47, ME48
  vorga-lpet(2) VALUE 'LE',   "Lieferplaneinteilung   ME38, ME39
  vorga-frge(2) VALUE 'EF',   "Einkaufsbelegfreigabe  ME28, ME35, ME45
  vorga-frgs(2) VALUE 'ES',   "Einzelfreigabe
  vorga-frgb(2) VALUE 'BF',   "Banffreigabe           ME54, ME55
  vorga-bgen(2) VALUE 'BB',   "Best. Lief.unbekannt   ME25
  vorga-anha(2) VALUE 'FT',   "Textanhang             ME24, ME26,...
  vorga-banf(2) VALUE 'B ',   "Banf                   ME51, ME52, ME53
  vorga-anfr(2) VALUE 'A ',   "Anfrage                ME41, ME42, ME43
  vorga-best(2) VALUE 'F ',   "Bestellung             ME21, ME22, ME23
  vorga-kont(2) VALUE 'K ',   "Kontrakt               ME31, ME32, ME33
  vorga-lfpl(2) VALUE 'L ',   "Lieferplan             ME31, ME32, ME33
  vorga-mahn(2) VALUE 'MA',   "Liefermahnung          ME91
  vorga-aufb(2) VALUE 'AB'.   "Bestätigungsmahnung    ME92

* Felder für Feldauswahl (früher FMMEXCOM)
DATA: endmaske(210) TYPE c,
      kmaske(140) TYPE c,
      auswahl0 TYPE brefn,
      auswahl1 TYPE brefn,
      auswahl2 TYPE brefn,
      auswahl3 TYPE brefn,
      auswahl4 TYPE brefn,
      auswahl5 TYPE brefn,
      auswahl6 TYPE brefn.

* Sonderbestandskennzeichen
CONSTANTS:
  sobkz-kdein VALUE 'E',               "Kundeneinzel
  sobkz-prein VALUE 'Q',               "Projekteinzel
  sobkz-lohnb VALUE 'O'.               "Lohnbearbeiterbeistell
*ENHANCEMENT-POINT fmmexdir_03 SPOTS es_fmmexdir STATIC INCLUDE BOUND.

* Min-/Maxwerte für Datenelemente
CONSTANTS:
* offener Rechnungseingangswert / Feldlänge: 13 / Dezimalstellen: 2
  c_max_orewr       LIKE rm06a-orewr  VALUE '99999999999.99',
  c_max_orewr_f     TYPE f            VALUE '9999999999999.99',
  c_max_orewr_x(15) TYPE c            VALUE '**************',

  c_max_proz_p(3)   TYPE p DECIMALS 2 VALUE '999.99',
  c_max_proz_x(6)   TYPE c            VALUE '******',

  c_max_menge       LIKE ekpo-menge   VALUE '9999999999.999',
  c_max_menge_f     TYPE f            VALUE '9999999999.999',

  c_max_netwr       LIKE ekpo-netwr   VALUE '99999999999.99',
  c_max_netwr_f     TYPE f            VALUE '99999999999.99',

* Status des Einkaufsbeleges (EKKO-STATU)
  cks_bbp LIKE ekko-statu VALUE 'K',  "Bestellung über BBP
  cks_es  LIKE ekko-statu VALUE 'M',  "CTR/SA from ES "n_1329712

* Distribution Indicator Account assignment
  c_dist_ind-single   VALUE ' ',      "no multiple = single
  c_dist_ind-quantity VALUE '1',      "quantity distribution
  c_dist_ind-percent  VALUE '2',      "percentag
  c_dist_ind-amount   VALUE '3'.      "amount based distribution

SET EXTENDED CHECK ON.
