************************************************************************
*        Übergabestruktur für Auswählen Bestellanforderungen           *
************************************************************************

DATA: BEGIN OF COMMON PART FM06BU02.

DATA: BEGIN OF CUEB,
        CALKZ,
        NRCFD,
        BANFN LIKE EBAN-BANFN,
        BNFPO LIKE EBAN-BNFPO,
      END OF CUEB.

DATA: END OF COMMON PART.
