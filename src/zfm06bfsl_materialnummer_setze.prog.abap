*&---------------------------------------------------------------------*
*&      Form  MATERIALNUMMER_SETZEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_BAN_MATNR  text                                            *
*      -->P_BAN_EMATN  text                                            *
*      -->P_BAN_MPROF  text                                            *
*      -->P_SEL_MATNR  text                                            *
*----------------------------------------------------------------------*
FORM MATERIALNUMMER_SETZEN USING    P_BAN_MATNR
                                    P_BAN_EMATN
                                    P_BAN_MPROF
                                    P_SEL_MATNR.

 IF P_BAN_MPROF IS INITIAL.
*.. keine mpn-abwicklung für dieses material aktiv ..................*
   P_SEL_MATNR = P_BAN_MATNR.
 ELSE.
   CALL FUNCTION 'MB_READ_TMPPF'
        EXPORTING
             PROFILE        = P_BAN_MPROF
        IMPORTING
             MPN_PARAMETERS = TMPPF
        EXCEPTIONS
             OTHERS         = 0.
   IF TMPPF-MPINF IS INITIAL.
     P_SEL_MATNR = P_BAN_MATNR.
   ELSEIF NOT P_BAN_EMATN IS INITIAL.
     P_SEL_MATNR = P_BAN_EMATN.
   ELSE.
*.. alle mpn's zum internen Material ermitteln und die Infosätze ....*
*. bereitstellen ...................................................*
     CLEAR P_SEL_MATNR.
   ENDIF.
 ENDIF.

ENDFORM.                    " MATERIALNUMMER_SETZEN
