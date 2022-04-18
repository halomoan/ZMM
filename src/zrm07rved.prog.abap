*----------------------------------------------------------------------*
*   INCLUDE RM07RVED                                                   *
*----------------------------------------------------------------------*
*   Datendefinitionen zum Report RM07RVER                              *
*----------------------------------------------------------------------*
REPORT RM07RVER MESSAGE-ID M7 NO STANDARD PAGE HEADING.

*------------------------ DATENTYPEN ----------------------------------*

TYPE-POOLS:  IMREP,                   " Typen Bestandsführungsreporting
             SLIS.                    " Typen Listviewer

*ypes: begin of rkpf_typ.
*        include structure rkpf.
*ypes: end of rkpf_typ.

TYPES: BEGIN OF RESB_TYP,
         RSNUM LIKE RKPF-RSNUM,
         RSDAT LIKE RKPF-RSDAT,
         BWART LIKE RKPF-BWART,
         BTEXT LIKE T156T-BTEXT,
         USNAM LIKE RKPF-USNAM,
         RSPOS LIKE RESB-RSPOS,
         SHKZG LIKE RESB-SHKZG,
         WERKS LIKE RESB-WERKS,
         lgort like resb-lgort,
         BDTER LIKE RESB-BDTER,
         MATNR LIKE RESB-MATNR,
         OMENG LIKE RESB-BDMNG,
         BDMNG LIKE RESB-BDMNG,
         ENMNG LIKE RESB-BDMNG,
         MEINS LIKE RESB-MEINS,
         XWAOK LIKE RESB-XWAOK,
         XWAOK_ALT LIKE RESB-XWAOK,
         XWAOK_NEU LIKE RESB-XWAOK,
         KZEAR LIKE RESB-KZEAR,
         XLOEK LIKE RESB-XLOEK,
         XLOEK_ALT LIKE RESB-XLOEK,
         XLOEK_NEU LIKE RESB-XLOEK,
         SPLKZ LIKE RESB-SPLKZ,
         RSTYP TYPE C.
TYPES: END OF RESB_TYP.

TYPES: BEGIN OF BELEGE_TYP,
         BOX LIKE DM07I-XSELZ.
         INCLUDE TYPE RESB_TYP.
TYPES:   KENNZ TYPE C,
         FARBE TYPE SLIS_T_SPECIALCOL_ALV.
TYPES: END OF BELEGE_TYP.


*------------------------- TABELLEN -----------------------------------*

TABLES: MBERE,
        MTCOM,
        RESB,
        RKPF,
        REUL,
        T001W,
        T159B,
        T159L.

*--------------------- DATENDEKLARATIONEN -----------------------------*

*ata: irkpf  type rkpf_typ     occurs 0 with header line.
DATA: BELEGE TYPE BELEGE_TYP   OCCURS 0 WITH HEADER LINE.
DATA: DETAIL TYPE RESB_TYP     OCCURS 0 WITH HEADER LINE.
DATA: POSITION TYPE BELEGE_TYP OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF LRKPF OCCURS 100,
        RSNUM LIKE RKPF-RSNUM,
        RSDAT LIKE RKPF-RSDAT,
        BOX LIKE DM07I-XSELZ.
DATA: END OF LRKPF.

DATA:   BEGIN OF DIS OCCURS 5.
        INCLUDE STRUCTURE MDISP.
DATA:   END OF DIS.

DATA:   BEGIN OF DISP OCCURS 5.
        INCLUDE STRUCTURE MDISP.
DATA:   END OF DISP.

DATA:   BEGIN OF DUMMY OCCURS 1,
          DUMMY,
        END OF DUMMY.

DATA:   BEGIN OF DRKPF OCCURS 100.
        INCLUDE STRUCTURE RKPF.
DATA:   END OF DRKPF.

DATA:   BEGIN OF DRESB OCCURS 100.
        INCLUDE STRUCTURE RESB.
DATA:   END OF DRESB.

*------ Indexdatei für Umlagerungsreservierung (zu löschende Sätze)
DATA:   BEGIN OF DREUL OCCURS 100.
        INCLUDE STRUCTURE REUL.
DATA:   END OF DREUL.

*------ Indexdatei für Umlagerungsreservierung (vorhanden Sätze)
DATA:   BEGIN OF XREUL OCCURS 100.
        INCLUDE STRUCTURE REUL.
DATA:   END OF XREUL.

*------ KEY-Struktur zum Lesen von XREUL
DATA:   BEGIN OF REUL_KEY.
        INCLUDE STRUCTURE REUL.
DATA:   END OF REUL_KEY.

DATA:   BEGIN OF PREFETCH02 OCCURS 20.
        INCLUDE STRUCTURE PRE02.
DATA:   END OF PREFETCH02.

DATA:   BEGIN OF XRESB OCCURS 100.
        INCLUDE STRUCTURE RESB.
DATA:   END OF XRESB.

DATA:   BEGIN OF YRESB OCCURS 100.
        INCLUDE STRUCTURE RESB.
DATA:     FABKL LIKE T001W-FABKL,
          BOX LIKE DM07I-XSELZ.        "für Markierungsfunktion
DATA:   END OF YRESB.

* needed for calling MB_CHANGE_RESERVATION_ARRAY.                "621291
DATA:   BEGIN OF YRESB_HELP OCCURS 100.                          "621291
          INCLUDE STRUCTURE RESB.                                "621291
DATA:   END OF YRESB_HELP.                                       "621291

DATA:   BEGIN OF ZRESB OCCURS 100.
        INCLUDE STRUCTURE RESB.
DATA:   END OF ZRESB.

DATA: BEGIN OF YRKPF OCCURS 50.
        INCLUDE STRUCTURE RKPF.
DATA: END OF YRKPF.

*-- Datendefinition für Kalenderprüfungen
DATA:   BEGIN OF KALENDER OCCURS 10,
          WERKS LIKE T001W-WERKS,
          CNT02 TYPE I,
          FABKL LIKE T001W-FABKL,
          TWAOK LIKE SCAL-FACDATE,
          DWAOK LIKE SCAL-FACDATE,
          TLOEK LIKE SCAL-FACDATE,
          DLOEK LIKE SCAL-FACDATE,
        END OF KALENDER.

DATA:   BEGIN OF X159L OCCURS 100.
        INCLUDE STRUCTURE T159L.
DATA:   END OF X159L.

DATA:   BEGIN OF RESKKEY,
          MANDT LIKE RESB-MANDT,
          RSNUM LIKE RESB-RSNUM,
        END OF RESKKEY.

DATA:   BEGIN OF RESKEY,
          MANDT LIKE RESB-MANDT,
          RSNUM LIKE RESB-RSNUM,
          RSPOS LIKE RESB-RSPOS,
        END OF RESKEY.

*a:   begin of rkpfkey,
*         rsnum like rkpf-rsnum,
*         rsdat like rkpf-rsdat,
*       end of rkpfkey.

DATA:   FDAYF1 LIKE SCAL-FACDATE,
        FDAYF2 LIKE SCAL-FACDATE,
        FDAYF3 LIKE SCAL-FACDATE,
        FDAYF4 LIKE SCAL-FACDATE,
        FDAYFP LIKE SCAL-FACDATE.


RANGES: LRSNUM FOR RKPF-RSNUM,
        IRSNUM FOR RESB-RSNUM.

*------------------------- HILFSFELDER --------------------------------*

DATA: INDEX_Z LIKE SY-TABIX.

DATA:   ALLES_LESEN TYPE C,
        INDEX_L     TYPE I,
        INDEX_T     TYPE I,
        MAX_ZAEHLER TYPE I,
        C_RSDAT     LIKE SCAL-DATE,
        PF_ALT      LIKE SY-PFKEY,
        DEL_RSNUM   LIKE RKPF-RSNUM,
        XDELE       TYPE C,
        XUPDATE     TYPE C,
        XDELETE     TYPE C,
        XFEHLER     TYPE C,
        XEXIT       TYPE C,
        ZAEHLER     TYPE I,
        ANZAHL1     TYPE I,
        ANZAHL2     TYPE I,
        XMODIF      TYPE C,
        XHEAD       TYPE C,
        XTABIX      LIKE SY-TABIX,
        XMARK       TYPE C,
        BLANK       TYPE C.

DATA:   RMAX  TYPE I VALUE '50'.

*-------------------- FELDER FÜR LISTVIEWER ---------------------------*

DATA: REPID      LIKE SY-REPID.
DATA: FIELDCAT   TYPE SLIS_T_FIELDCAT_ALV.
DATA: FIELDCAT_P TYPE SLIS_T_FIELDCAT_ALV.
DATA: XHEADER    TYPE SLIS_T_LISTHEADER WITH HEADER LINE.
DATA: KEYINFO    TYPE SLIS_KEYINFO_ALV.
DATA: COLOR      TYPE SLIS_T_SPECIALCOL_ALV WITH HEADER LINE.
DATA: LAYOUT     TYPE SLIS_LAYOUT_ALV.
DATA: PRINT      TYPE SLIS_PRINT_ALV.

* Listanzeigevarianten
DATA: VARIANTE        LIKE DISVARIANT,                " Anzeigevariante
      DEF_VARIANTE    LIKE DISVARIANT,                " Defaultvariante
      VARIANT_EXIT(1) TYPE C,
      VARIANT_SAVE(1) TYPE C,
      VARIANT_DEF(1)  TYPE C.
