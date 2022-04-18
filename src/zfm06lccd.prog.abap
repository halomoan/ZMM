*eject
*--------------------------------------------------------------------*
*        COMMON DATA                                                 *
*--------------------------------------------------------------------*
*        Datenfelder fuer die Bearbeitung der Änderungsdoku          *
*--------------------------------------------------------------------*

DATA:    BEGIN OF COMMON PART FM06LCCD.

*------- Tabelle der Änderunsbelegzeilen (temporär) -------------------*
DATA: BEGIN OF EDIT OCCURS 50.             "Änderungsbelegzeilen temp.
        INCLUDE STRUCTURE CDSHW.
DATA: END OF EDIT.

DATA: BEGIN OF EDITD OCCURS 50.             "Änderungsbelegzeilen temp.
        INCLUDE STRUCTURE CDSHW.            "für Dienstleistungen
DATA: END OF EDITD.


*------- Tabelle der Änderunsbelegzeilen (Ausgabeform) ----------------*
DATA: BEGIN OF AUSG OCCURS 50.             "Änderungsbelegzeilen
        INCLUDE STRUCTURE CDSHW.
DATA:   CHANGENR LIKE CDHDR-CHANGENR,
        UDATE    LIKE CDHDR-UDATE,
        UTIME    LIKE CDHDR-UTIME,
      END OF AUSG.

*------- Tabelle der Änderunsbelegköpfe -------------------------------*
DATA: BEGIN OF ICDHDR OCCURS 50.           "Änderungbelegköpfe
        INCLUDE STRUCTURE CDHDR.
DATA: END OF ICDHDR.

*------- Key Tabelle der Änderunsbelegköpfe --------------------------*
DATA: BEGIN OF HKEY,                       "Key für ICDHDR
        MANDT LIKE CDHDR-MANDANT,
        OBJCL LIKE CDHDR-OBJECTCLAS,
        OBJID LIKE CDHDR-OBJECTID,
        CHANG LIKE CDHDR-CHANGENR,
      END OF HKEY.

*------- Key der geänderten Tabelle für Ausgabe ----------------------*
DATA: BEGIN OF EKKEY,                    "Tabellenkeyausgabe
        EBELN LIKE EKKO-EBELN,
        EBELP LIKE EKPO-EBELP,
        ZEKKN LIKE EKKN-ZEKKN,
        ETENR LIKE EKET-ETENR,
        ABRUF LIKE EKEK-ABRUF,
        EKORG LIKE EKPA-EKORG,           "Änderungsbelege Partner
        LTSNR LIKE EKPA-LTSNR,           "Änderungsbelege Partner
        WERKS LIKE EKPA-WERKS,           "Änderungsbelege Partner
        PARVW LIKE EKPA-PARVW,           "Änderungsbelege Partner
        PARZA LIKE EKPA-PARZA,           "Änderungsbelege Partner
        CONSNUMBER LIKE ADR2-CONSNUMBER, "Änderungsbelege Adressen
        COMM_TYPE  LIKE ADRT-COMM_TYPE,  "Änderungsbelege Adressen
      END OF EKKEY.

DATA:    END OF COMMON PART.
