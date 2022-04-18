************************************************************************
*        Allgemeine Unterroutinen zur Listanzeige Banfs                *
************************************************************************
* 76800 11.06.1997 3.1H GT : RM06BZ10 bringt ME 146 und ME 149
* 92105 08.01.1998 4.0C KB : SD-Banfen können teilbestellt werden
* 94637 04.02.1998 3.1I SM : RV-Banfen kein Lieferdatum - Probl.in ME5a
* 96790 03.03.1998 4.0C SM : ME56/ME57 Bezugsquellenzuordnung ->ME149
*eject
*----------------------------------------------------------------------*
*        Ändern vom Detailbild                                         *
*----------------------------------------------------------------------*
FORM AEND_DETA.

*- Quotierungsdaten neu ermitteln -------------------------------------*
*- erfolgt bei Bezugsquellenänderung im entsprechenden Subscreen ------*
  IF ( EBAN-MENGE NE *EBAN-MENGE OR
       EBAN-LFDAT NE *EBAN-LFDAT ) AND
     EBAN-FLIEF EQ *EBAN-FLIEF AND
     EBAN-EKORG EQ *EBAN-EKORG AND
     EBAN-KONNR EQ *EBAN-KONNR AND
     EBAN-KTPNR EQ *EBAN-KTPNR AND
     EBAN-INFNR EQ *EBAN-INFNR.
    PERFORM AEND_BEZUG.
  ENDIF.
  read table bde index 1 transporting no fields.
  IF EBAN NE *EBAN AND HIDE-INDEX > 0 AND sy-subrc = 0.      "85554
    MOVE-CORRESPONDING EBAN TO BAN.
    BAN-UPDK1 = AEND.
    MODIFY BAN INDEX HIDE-INDEX.
  ENDIF.

ENDFORM.




