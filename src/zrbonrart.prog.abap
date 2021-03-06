*---------------------------------------------------------------------*
* Die allgemeine Objektnummer setzt sich zusammen aus einer           *
* 2-stelligen Objektart und einer Objekt-ID.                          *
* In diesem Include sind die verfuegbaren Objektarten aufgelistet.    *
*---------------------------------------------------------------------*

CONSTANTS:
      OBJEKTART_AN LIKE IONR-OBART VALUE 'AN', "Anlage
      OBJEKTART_AO LIKE IONR-OBART VALUE 'AO', "Abstimmobjekt
      OBJEKTART_B1 LIKE IONR-OBART VALUE 'B1', "Wertpapierbestaende
      OBJEKTART_B2 LIKE IONR-OBART VALUE 'B2', "Unverzinsl. Bestaende
      OBJEKTART_B3 LIKE IONR-OBART VALUE 'B3', "Dienstleistung
      OBJEKTART_B4 LIKE IONR-OBART VALUE 'B4', "Sammelobjekt (MeWe)
      OBJEKTART_B5 LIKE IONR-OBART VALUE 'B5', "Wechsel (MeWe)
      OBJEKTART_B6 LIKE IONR-OBART VALUE 'B6', "Avale/Buergschaften (MW)
      OBJEKTART_BA LIKE IONR-OBART VALUE 'BA', "BKK - Bankkonto
      OBJEKTART_BH LIKE IONR-OBART VALUE 'BH', "Geschaeftsprozess-Knoten
      OBJEKTART_BL LIKE IONR-OBART VALUE 'BL', "Geschaeftsstandort
      OBJEKTART_BP LIKE IONR-OBART VALUE 'BP', "Geschaeftsprozess
      OBJEKTART_CD LIKE IONR-OBART VALUE 'CD', "Aenderungsdienst
      OBJEKTART_CL LIKE IONR-OBART VALUE 'CL', "Class
      OBJEKTART_DO LIKE IONR-OBART VALUE 'DO', "Document
      OBJEKTART_EC LIKE IONR-OBART VALUE 'EC', "ECP Easy-Cost-Planning
      OBJEKTART_EK LIKE IONR-OBART VALUE 'EK', "Erzeugniskalkulation
      OBJEKTART_EO LIKE IONR-OBART VALUE 'EO', "Ergebnisobjekt
      OBJEKTART_FK LIKE IONR-OBART VALUE 'FK', "Finanzkreis
      OBJEKTART_FM LIKE IONR-OBART VALUE 'FM', "Finanzmittelrechnung
      OBJEKTART_FS LIKE IONR-OBART VALUE 'FS', "Finanzstelle
      OBJEKTART_HI LIKE IONR-OBART VALUE 'HI', "Hierarchieknoten
      OBJEKTART_HP LIKE IONR-OBART VALUE 'HP', "Hierarchie Prozessfert.
      OBJEKTART_IA LIKE IONR-OBART VALUE 'IA', "Abrechnungseinheit
      OBJEKTART_IB LIKE IONR-OBART VALUE 'IB', "Gebaeude
      OBJEKTART_IC LIKE IONR-OBART VALUE 'IC', "Verwaltungsvertrag
      OBJEKTART_ID LIKE IONR-OBART VALUE 'ID', "InvProgrammdefinition
      OBJEKTART_IE LIKE IONR-OBART VALUE 'IE', "Equipment
      OBJEKTART_IF LIKE IONR-OBART VALUE 'IF', "Technischer Platz
      OBJEKTART_IG LIKE IONR-OBART VALUE 'IG', "Grundstueck
      OBJEKTART_IH LIKE IONR-OBART VALUE 'IH', "Installation
      OBJEKTART_II LIKE IONR-OBART VALUE 'II', "Instance
      OBJEKTART_IM LIKE IONR-OBART VALUE 'IM', "Mieteinheit
      OBJEKTART_IN LIKE IONR-OBART VALUE 'IN', "Objektverbindung
      OBJEKTART_IO LIKE IONR-OBART VALUE 'IO', "InvAnforderungsvariante
      OBJEKTART_IP LIKE IONR-OBART VALUE 'IP', "InvProgrammposition
      OBJEKTART_IQ LIKE IONR-OBART VALUE 'IQ', "InvAnforderung
      OBJEKTART_IR LIKE IONR-OBART VALUE 'IR', "Techn. Referenzplatz
      OBJEKTART_IS LIKE IONR-OBART VALUE 'IS', "Allg. Immobilienvertrag
      OBJEKTART_IV LIKE IONR-OBART VALUE 'IV', "Mietvertrag
      OBJEKTART_IW LIKE IONR-OBART VALUE 'IW', "Wirtschaftseinheit
      OBJEKTART_I1 LIKE IONR-OBART VALUE 'I1', "Abrechnungseinheit
      OBJEKTART_KL LIKE IONR-OBART VALUE 'KL', "Kostenst./Leistungsart
      OBJEKTART_KS LIKE IONR-OBART VALUE 'KS', "Kostenstelle
      OBJEKTART_MA LIKE IONR-OBART VALUE 'MA', "Material
      OBJEKTART_MS LIKE IONR-OBART VALUE 'MS', "Musterleistungsverz.
      OBJEKTART_NF LIKE IONR-OBART VALUE 'NF', "Fall (IS-H)
      OBJEKTART_NP LIKE IONR-OBART VALUE 'NP', "Netzplan
      OBJEKTART_NR LIKE IONR-OBART VALUE 'NR', "Anordnungsbeziehung
      OBJEKTART_NV LIKE IONR-OBART VALUE 'NV', "Netzplanvorgang
      OBJEKTART_O1 LIKE IONR-OBART VALUE 'O1', "Planauftragsvorgang
      OBJEKTART_O2 LIKE IONR-OBART VALUE 'O2', "Kapazitaetsbedarf
      OBJEKTART_OF LIKE IONR-OBART VALUE 'OF', "Fertigungshilfsmittel
      OBJEKTART_OK LIKE IONR-OBART VALUE 'OK', "Materialkomp/Reservierng
      OBJEKTART_OP LIKE IONR-OBART VALUE 'OP', "Auftragsposition
      OBJEKTART_OR LIKE IONR-OBART VALUE 'OR', "Auftrag
      OBJEKTART_OS LIKE IONR-OBART VALUE 'OS', "Auftragsarbeitsfolge
      OBJEKTART_OV LIKE IONR-OBART VALUE 'OV', "Arbeitsvorgang
      OBJEKTART_PC LIKE IONR-OBART VALUE 'PC', "Profit-Center
      OBJEKTART_PD LIKE IONR-OBART VALUE 'PD', "Projekt
      OBJEKTART_PK LIKE IONR-OBART VALUE 'PK', "Produktkostensammler
      OBJEKTART_PO LIKE IONR-OBART VALUE 'PO', "Purchase order
      OBJEKTART_PR LIKE IONR-OBART VALUE 'PR', "Projektstrukturelement
      OBJEKTART_PS LIKE IONR-OBART VALUE 'PS', "Standardprojekt
      OBJEKTART_PT LIKE IONR-OBART VALUE 'PT', "Standard-PSP-Element
      OBJEKTART_QA LIKE IONR-OBART VALUE 'QA', "Qual.meld. - Massnahmen
      OBJEKTART_QB LIKE IONR-OBART VALUE 'QB', "Qual.meld. - Sofortmass.
      OBJEKTART_QC LIKE IONR-OBART VALUE 'QC', "Zeugnisvorlage
      OBJEKTART_QI LIKE IONR-OBART VALUE 'QI', "QM-Informationssatz
      OBJEKTART_QL LIKE IONR-OBART VALUE 'QL', "Prueflos
      OBJEKTART_QM LIKE IONR-OBART VALUE 'QM', "Qualitaetsmeldung
      OBJEKTART_QP LIKE IONR-OBART VALUE 'QP', "Physische Probe
      OBJEKTART_QT LIKE IONR-OBART VALUE 'QT', "Teillos
      OBJEKTART_R1 LIKE IONR-OBART VALUE 'R1', "Erw. Risikotr??ger
      OBJEKTART_R2 LIKE IONR-OBART VALUE 'R2', "Ext. Risikotr??ger
      OBJEKTART_R3 LIKE IONR-OBART VALUE 'R3', "Bestand Risikotr??ger
      OBJEKTART_RS LIKE IONR-OBART VALUE 'RS', "Serienauftrag
      OBJEKTART_RU LIKE IONR-OBART VALUE 'RU', "Auftragsrueckmeldung
      OBJEKTART_SK LIKE IONR-OBART VALUE 'SK', "Sachkonto
      OBJEKTART_SL LIKE IONR-OBART VALUE 'SL', "Sachkonto (Preisdiffer.)
      OBJEKTART_T1 LIKE IONR-OBART VALUE 'T1', "Treasury - Darlehen
      OBJEKTART_T2 LIKE IONR-OBART VALUE 'T2', "Treasury - Wertpapier
      OBJEKTART_T4 LIKE IONR-OBART VALUE 'T4', "Treasury - Devisen
      OBJEKTART_T5 LIKE IONR-OBART VALUE 'T5', "Treasury - Geldhandel
      OBJEKTART_T6 LIKE IONR-OBART VALUE 'T6', "Treasury - Derivate
      OBJEKTART_T7 LIKE IONR-OBART VALUE 'T7', "Treasury - Kontokorrentg
      OBJEKTART_T8 LIKE IONR-OBART VALUE 'T8', "Treasury - Wertpap.Best.
      OBJEKTART_TL LIKE IONR-OBART VALUE 'TL', "Arbeitsplan
      OBJEKTART_TM LIKE IONR-OBART VALUE 'TM', "Temporaere Objektnummer
      OBJEKTART_V1 LIKE IONR-OBART VALUE 'V1', "Version Projektdefinit.
      OBJEKTART_V2 LIKE IONR-OBART VALUE 'V2', "Version PSP-Elemente
      OBJEKTART_V3 LIKE IONR-OBART VALUE 'V3', "Version Netzplan
      OBJEKTART_V4 LIKE IONR-OBART VALUE 'V4', "Version Netzplanvorgang
      OBJEKTART_V5 LIKE IONR-OBART VALUE 'V5', "Version Reservierung
      OBJEKTART_V6 LIKE IONR-OBART VALUE 'V6', "Version Anordnungsbez.
      OBJEKTART_V7 LIKE IONR-OBART VALUE 'V7', "Version Kapazitaetsbed.
      OBJEKTART_V8 LIKE IONR-OBART VALUE 'V8', "Version Auftr.arb.folge
      OBJEKTART_V9 LIKE IONR-OBART VALUE 'V9', "Version Auftragsposition
      OBJEKTART_VA LIKE IONR-OBART VALUE 'VA', "Version Auftrag
      OBJEKTART_VB LIKE IONR-OBART VALUE 'VB', "Verkaufsbelegposition
      OBJEKTART_VD LIKE IONR-OBART VALUE 'VD', "Verdichtungsobjekt
      OBJEKTART_VK LIKE IONR-OBART VALUE 'VK', "Verkaufsbelegkopf
      OBJEKTART_VV LIKE IONR-OBART VALUE 'VV', "Version Vorgang
      OBJEKTART_WO LIKE IONR-OBART VALUE 'WO', "Wartungsplan
      OBJEKTART_WP LIKE IONR-OBART VALUE 'WP'. "Wartungsposition
************************************************************ W C M *****
CONSTANTS:
      OBJEKTART_WW LIKE IONR-OBART VALUE 'WW', "WCM: Arbeitsgenehmigung
      OBJEKTART_WA LIKE IONR-OBART VALUE 'WA', "WCM: Anforderung
      OBJEKTART_WD LIKE IONR-OBART VALUE 'WD', "WCM: Freischaltliste
      OBJEKTART_WI LIKE IONR-OBART VALUE 'WI'. "WCM: Position FSL
************************************************************ W C M *****
