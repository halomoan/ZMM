************************************************************************
*        Common-Part Listanzeigen Bestellanforderungen  Teil 1         *
************************************************************************

DATA: BEGIN OF COMMON PART FM06BCD1.

DATA: FLAG_SELK(2) TYPE P,
      PFKEYP LIKE SY-PFKEY,            "PF-Status vor POP-UPs
      REJECT,
      ANSWER,
      GS_BANF,          "Eigene Listaufbereitung für Gesamtbanfen
      AZ_POS TYPE I,    "Anzahl Positionen zur Banf f. Gesamtfreigabe
      NOT_FOUND,
      SUCOMM LIKE SY-UCOMM,
      OK-CODE(4).
*------- Struktur für Übergabe Selektion an Listaufbereitung ----------*
DATA: BEGIN OF COM,
         FRGAB LIKE RM06B-FRGAB,
         SRTKZ,
         BKMKZ,
         LSTUB LIKE T16LL-LSTUB,
         ZPFKEY LIKE SY-PFKEY,
         ZFMKEY(3),
         GPFKEY LIKE SY-PFKEY,
         GFMKEY(3),
         CALLD LIKE SY-CALLD,
      END OF COM.

ENHANCEMENT-POINT FM06BCD1_01 SPOTS ES_FM06BCD1 STATIC INCLUDE BOUND.
DATA: END OF COMMON PART FM06BCD1.
