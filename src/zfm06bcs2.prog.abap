************************************************************************
*        Common-Part Listanzeigen Bestellanforderungen  Teil 1         *
************************************************************************

DATA: BEGIN OF COMMON PART FM06BCS2.

*----------------------------------------------------------------------*
*        Parameters                                                    *
*----------------------------------------------------------------------*
PARAMETERS:
   P_ZUGBA LIKE RM06A-P_ZUGEORDN DEFAULT 'X',
   P_ERLBA LIKE RM06A-P_ERLEDIGT,
   P_BSTBA LIKE RM06A-P_TEILBEST DEFAULT 'X',
   P_FREIG LIKE RM06A-P_FREIGABE DEFAULT ' ',
   P_SELGS LIKE RM06A-P_SELGS DEFAULT 'X',
   P_SELPO LIKE RM06A-P_SELPO DEFAULT 'X'.

DATA: END OF COMMON PART FM06BCS2.
