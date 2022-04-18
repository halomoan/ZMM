*&---------------------------------------------------------------------*
*& Report  ZUPDATE_TADIR
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zupdate_tadir.

**** Type declaration
TYPES: trwbo_charflag(1) TYPE c.

TYPES: BEGIN OF trwbo_request_header.
INCLUDE   STRUCTURE e070.
TYPES:    as4text        LIKE e07t-as4text,
          as4text_filled TYPE trwbo_charflag,
          client         LIKE e070c-client,
          tarclient      LIKE e070c-tarclient,
          clients_filled TYPE trwbo_charflag,
          tardevcl       LIKE e070m-tardevcl,
          devclass       LIKE e070m-devclass,
          tarlayer       LIKE e070m-tarlayer,
          e070m_filled   TYPE trwbo_charflag,
       END OF   trwbo_request_header.

**** Data declaration
DATA: lt_tadir       TYPE TABLE OF tadir,
      lt_tadir_tab   TYPE TABLE OF tadir,
      lt_tadir_temp  TYPE TABLE OF tadir,
      lw_tadir       TYPE tadir,
      lv_records(10) TYPE n,
      lv_output      TYPE string,
      lv_answer      TYPE c,
      lt_e071        TYPE TABLE OF e071,
      lw_e071        TYPE e071,
      lt_error_tab   TYPE TABLE OF e071k,
      lv_trkorr      TYPE trkorr,
      lw_req_header  TYPE trwbo_request_header,
      lv_systemid    TYPE sy-sysid.

SELECTION-SCREEN: BEGIN OF BLOCK blk WITH FRAME TITLE text-001.

PARAMETERS: p_test AS CHECKBOX  DEFAULT 'X'.

SELECTION-SCREEN: END OF BLOCK blk.

START-OF-SELECTION.

  SELECT *
      FROM tadir
      INTO TABLE lt_tadir BYPASSING BUFFER
     WHERE ( obj_name LIKE '%/ARBA/%'  OR
           obj_name = '/ARB' )
       AND devclass NOT LIKE '$%'
       AND delflag <> 'X'.
  IF sy-subrc = 0.

    DESCRIBE TABLE lt_tadir LINES lv_records.
    SHIFT lv_records LEFT DELETING LEADING '0'.
    CONCATENATE lv_records 'Number of Object will be updated' INTO lv_output SEPARATED BY space.

  ENDIF.

  IF p_test = 'X'.
**** Test run
    WRITE: lv_output.

  ELSE.
**** Create for POP-UP for confirmation
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar              = 'Confirm'
        text_question         = lv_output
        text_button_1         = 'Yes'(002)
        text_button_2         = 'No'(003)
        default_button        = '1'
        display_cancel_button = ' '
      IMPORTING
        answer                = lv_answer
      EXCEPTIONS
        text_not_found        = 1
        OTHERS                = 2.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CASE lv_answer.
      WHEN '1'.
        CLEAR lw_tadir.
**** Getting the system id
        CALL FUNCTION 'MSS_GET_SY_SYSID'
          IMPORTING
            sapsysid = lv_systemid.

        LOOP AT lt_tadir INTO lw_tadir.
          lw_tadir-srcsystem = lv_systemid.
**** Modifying source system field of the internal table with blank
          MODIFY lt_tadir FROM lw_tadir TRANSPORTING srcsystem.
          CLEAR lw_tadir.
        ENDLOOP.
        IF lt_tadir[] IS NOT INITIAL.
**** Update TADIR table
          UPDATE tadir FROM TABLE lt_tadir.
          IF sy-subrc = 0.
            WRITE: 'TADIR', 'Records updated successfully'.
          ENDIF.

        ENDIF.

      WHEN '2'.
**** Modification stoped
        RETURN.
      WHEN 'A'.
**** Terminate the program
        RETURN.
    ENDCASE.

  ENDIF.
