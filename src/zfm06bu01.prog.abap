************************************************************************
*        Übergabestruktur für Zuordnung Bestellanforderungen           *
************************************************************************

DATA: BEGIN OF COMMON PART fm06bu01.

DATA: BEGIN OF bueb,
        calkz,
        nrcfd,
        flief LIKE eban-flief,
        ekorg LIKE eban-ekorg,
        konnr LIKE eban-konnr,
        ktpnr LIKE eban-ktpnr,
        vrtyp LIKE eban-vrtyp,
        infnr LIKE eban-infnr,
        menge LIKE eban-menge,
        meins LIKE eban-meins,
        datum LIKE eban-frgdt,
        reswk LIKE eban-reswk,
        ematn LIKE eban-ematn,
        mfrnr LIKE eban-mfrnr,
        mfrpn LIKE eban-mfrpn,
        emnfr LIKE eban-emnfr,
        beswk LIKE eban-beswk, " CCP
      END OF bueb.

DATA: END OF COMMON PART.
