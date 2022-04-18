*eject
*----------------------------------------------------------------------*
* Zeile: Wunschlieferant                                               *
*----------------------------------------------------------------------*
FORM BAN_ZEILE_005.
  IF NOT EBAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
*... Bei Gesamtfreigabe werden die Positionen nur ausgegeben, wenn dies
*... im Listumfang explizit angegeben wurde ..........................*
    CHECK NOT T16LB-GSPOS IS INITIAL.
  ENDIF.

  IF EBAN-LIFNR NE SPACE.
    CLEAR LFA1.
* ALRK021852 begin inser
    CALL FUNCTION 'WY_LFA1_GET_NAME'
         EXPORTING
              PI_LIFNR         = EBAN-LIFNR
         IMPORTING
              PO_NAME1         = LFA1-NAME1
         EXCEPTIONS
              NO_RECORDS_FOUND = 1
              OTHERS           = 2.
* ALRK021852 end insert - begin delete
*  call function 'ME_GET_SUPPLIER'
*       exporting
*         supplier   = eban-lifnr
*       importing
*         name       = lfa1-name1
*       exceptions
*            error_message = 01.
* ALRK021852 end delete
*ENHANCEMENT-SECTION     FM06BFLI_BAN_ZEILE_005_01 SPOTS ES_SAPFM06B.
    WRITE: /  SY-VLINE,
            4 TEXT-049,
           23 EBAN-LIFNR,
           34 LFA1-NAME1,
           81 SY-VLINE.
*END-ENHANCEMENT-SECTION.
    HIDE EBAN-PACKNO.
  ENDIF.

ENDFORM.
