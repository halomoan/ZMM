************************************************************************
*        Common-Part Listanzeigen Bestellanforderungen  Teil 1         *
************************************************************************

DATA: BEGIN OF COMMON PART FM06BCS1.

*----------------------------------------------------------------------*
*        Parameters                                                    *
*----------------------------------------------------------------------*
PARAMETERS:
   P_LSTUB LIKE T16LL-LSTUB DEFAULT 'A'.         "Listumfang
*----------------------------------------------------------------------*
*        Select-Options                                                *
*----------------------------------------------------------------------*
SELECT-OPTIONS:
   S_WERKS FOR EBAN-WERKS MEMORY ID WRK,                 "Werk
   S_BSART FOR EBAN-BSART,                      "Bestellart
   S_PSTYP FOR RM06B-EPSTP,                     "Positionstyp
   S_KNTTP FOR EBAN-KNTTP,                      "Kontierungstyp
   S_LFDAT FOR EBAN-LFDAT,                      "Lieferdatum
   S_FRGDT FOR EBAN-FRGDT,                      "Freigabedatum
   S_DISPO FOR EBAN-DISPO,                      "Disponent
   S_STATU FOR EBAN-STATU,                      "Bearbeitungsstatus
   S_FLIEF FOR EBAN-FLIEF MATCHCODE OBJECT KRED,

   S_BESWK FOR EBAN-beswk MEMORY ID besw,       "CCP Besch. Werk
   s_banpr for eban-banpr,                      "DCM Bearb.zustand
   s_blckd for eban-blckd.                      "DCM Sperr-Kz
*

*----------------------------------------------------------------------*
*        Parameters                                                    *
*----------------------------------------------------------------------*
PARAMETERS:
   P_AFNAM LIKE EBAN-AFNAM,            "Anforderer
   P_TXZ01 LIKE EBAN-TXZ01,            "Kurztext
   P_SRTKZ LIKE RM06A-P_SORTKZ DEFAULT '1'.      "Sortierkennzeichen

*- für Positionstyp im internen Format --------------------------------*
RANGES: R_PSTYP FOR EBAN-PSTYP.

DATA: END OF COMMON PART FM06BCS1.
