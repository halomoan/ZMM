*
* Pop a Message to specific SAP users
*
* How to get a list of all the currently logged on users?
* How to popup an instant message on a user's monitor?
* How to get a specific user's details?
* Usage of 'POPUP_GET_VALUES' function module to get data from user
* without having to write GUI code
*
* Submitted by : SAP Basis, ABAP Programming and Other IMG Stuff
*                http://www.sap-img.com
*
REPORT ZPOPUP NO STANDARD PAGE HEADING.
INCLUDE <ICON>.

DATA:       BEGIN OF USR_TABL OCCURS 0.
                INCLUDE STRUCTURE UINFO.
DATA:       END OF USR_TABL.

DATA:       L_LENGTH        TYPE I,
            T_ABAPLIST      LIKE ABAPLIST OCCURS 0 WITH HEADER LINE,
            BEGIN OF T_USER OCCURS 0,
                COUNTER     TYPE I,
                SELECTION   TYPE C,
                MANDT       LIKE SY-MANDT,
                BNAME       LIKE SY-UNAME,
                NAME_FIRST  LIKE V_ADRP_CP-NAME_FIRST,
                NAME_LAST   LIKE V_ADRP_CP-NAME_LAST,
                DEPARTMENT  LIKE V_ADRP_CP-DEPARTMENT,
                TEL_NUMBER  LIKE V_ADRP_CP-TEL_NUMBER,
            END OF T_USER,
            L_CLIENT        LIKE SY-MANDT,
            L_USERID        LIKE UINFO-BNAME,
            L_OPCODE        TYPE X,
            L_FUNCT_CODE(1) TYPE C,
            L_TEST(200)     TYPE C.

L_OPCODE = 2.
CALL 'ThUsrInfo' ID 'OPCODE' FIELD L_OPCODE
    ID 'TAB' FIELD USR_TABL-*SYS*.

CLEAR T_USER. REFRESH T_USER.
LOOP AT USR_TABL.
    T_USER-MANDT = USR_TABL-MANDT.
    T_USER-BNAME = USR_TABL-BNAME.
    APPEND T_USER.
ENDLOOP.

SORT T_USER.
DELETE ADJACENT DUPLICATES FROM T_USER.
LOOP AT T_USER.
    T_USER-COUNTER = SY-TABIX.
    SELECT V~NAME_FIRST

           V~NAME_LAST
           V~DEPARTMENT
           V~TEL_NUMBER
        INTO (T_USER-NAME_FIRST,
              T_USER-NAME_LAST,
              T_USER-DEPARTMENT,
              T_USER-TEL_NUMBER)
        FROM USR21 AS U
            JOIN V_ADRP_CP AS V
              ON U~PERSNUMBER = V~PERSNUMBER AND
                 U~ADDRNUMBER = V~ADDRNUMBER
        WHERE U~BNAME = T_USER-BNAME.
    ENDSELECT.
    MODIFY T_USER.
ENDLOOP.
SORT T_USER BY NAME_LAST NAME_FIRST.
PERFORM DISPLAY_LIST.

TOP-OF-PAGE.
    PERFORM DISPLAY_MENU.
* End of top-of-page

TOP-OF-PAGE DURING LINE-SELECTION.
    PERFORM DISPLAY_MENU.
* End of top-of-page during line-selection


AT LINE-SELECTION.
  IF SY-CUROW = 2.
    IF SY-CUCOL < 19.
        T_USER-SELECTION = 'X'.
        MODIFY T_USER TRANSPORTING SELECTION WHERE SELECTION = ''.
        PERFORM DISPLAY_LIST.
    ELSEIF SY-CUCOL < 36.
        CLEAR T_USER-SELECTION.
        MODIFY T_USER TRANSPORTING SELECTION WHERE SELECTION = 'X'.
        PERFORM DISPLAY_LIST.
    ELSEIF SY-CUCOL < 50.
        PERFORM TRANSFER_SELECTION.
        PERFORM POPUP_MSG.
    ELSEIF SY-CUCOL < 67.
        PERFORM TRANSFER_SELECTION.
        SORT T_USER BY NAME_LAST.
        PERFORM DISPLAY_LIST.
    ELSEIF SY-CUCOL < 81.
        PERFORM TRANSFER_SELECTION.
        SORT T_USER BY NAME_FIRST.
        PERFORM DISPLAY_LIST.
    ELSEIF SY-CUCOL < 93.
        PERFORM TRANSFER_SELECTION.
        SORT T_USER BY MANDT.
        PERFORM DISPLAY_LIST.
    ENDIF.
  ENDIF.
* End of line-selection

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_LIST
*&---------------------------------------------------------------------*
FORM DISPLAY_LIST.
SY-LSIND = 0.
FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
LOOP AT T_USER.
    WRITE: / SY-VLINE, T_USER-SELECTION AS CHECKBOX,
             SY-VLINE, T_USER-MANDT,
             SY-VLINE, T_USER-BNAME,
             SY-VLINE, T_USER-NAME_FIRST(15),
             SY-VLINE, T_USER-NAME_LAST(15),
             SY-VLINE, T_USER-DEPARTMENT(20),
             SY-VLINE, T_USER-TEL_NUMBER(20), SY-VLINE.
    HIDE: T_USER-COUNTER, T_USER-SELECTION.
ENDLOOP.
FORMAT COLOR OFF.
WRITE: /(108) SY-ULINE.
ENDFORM.                    " DISPLAY_LIST

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_MENU
*&---------------------------------------------------------------------*
FORM DISPLAY_MENU.
    FORMAT COLOR COL_HEADING HOTSPOT.
    WRITE:   (91) SY-ULINE,
       / SY-VLINE NO-GAP, (4) ICON_SELECT_ALL NO-GAP,    'Select All',
         SY-VLINE NO-GAP, (4) ICON_DESELECT_ALL NO-GAP,  'Deselect All',
         SY-VLINE NO-GAP, (4) ICON_SHORT_MESSAGE NO-GAP, 'Send Popup',
         SY-VLINE NO-GAP, (4) ICON_SORT_UP NO-GAP, 'Last Name' NO-GAP,
         SY-VLINE NO-GAP, (4) ICON_SORT_UP NO-GAP, 'First Name' NO-GAP,
         SY-VLINE NO-GAP, (4) ICON_SORT_UP NO-GAP, 'Client' NO-GAP,
         SY-VLINE,
       /(91) SY-ULINE,
       /(108) SY-ULINE.
   FORMAT HOTSPOT OFF.

   WRITE: / SY-VLINE, ' ',
            SY-VLINE, 'Cli',
            SY-VLINE, 'User        ',
            SY-VLINE, 'First Name     ',
            SY-VLINE, 'Last Name      ',
            SY-VLINE, 'Department          ',
            SY-VLINE, 'Telephone           ',
            SY-VLINE,
          /(108) SY-ULINE.
    FORMAT COLOR OFF.
ENDFORM.                    " DISPLAY_MENU

*&---------------------------------------------------------------------*
*&      Form  TRANSFER_SELECTION
*&---------------------------------------------------------------------*
FORM TRANSFER_SELECTION.
    DO.
        READ LINE SY-INDEX FIELD VALUE T_USER-SELECTION.
        IF SY-SUBRC <> 0.
            EXIT.
        ENDIF.
        MODIFY T_USER TRANSPORTING SELECTION
               WHERE COUNTER = T_USER-COUNTER.
    ENDDO.
    CLEAR T_USER.
ENDFORM.                    " TRANSFER_SELECTION

*&---------------------------------------------------------------------*
*&      Form  POPUP_MSG
*&---------------------------------------------------------------------*
FORM POPUP_MSG.
    DATA: L_MSG      LIKE SM04DIC-POPUPMSG VALUE 'Experimental Message',
          L_LEN      TYPE I,
          L_RET      TYPE C.

    LOOP AT T_USER WHERE SELECTION = 'X'.
        PERFORM GET_MESSAGE CHANGING L_MSG L_RET.
        EXIT.
    ENDLOOP.
    IF L_RET = 'A'.            "User cancelled the message
        EXIT.
    ENDIF.
*   Get the message text
    L_LEN = STRLEN( L_MSG ).
    LOOP AT T_USER WHERE SELECTION = 'X'.
            CALL FUNCTION 'TH_POPUP'
                 EXPORTING
                      CLIENT         = T_USER-MANDT
                      USER           = T_USER-BNAME
                      MESSAGE        = L_MSG
                      MESSAGE_LEN    = L_LENGTH
*                     CUT_BLANKS     = ' '
                 EXCEPTIONS
                      USER_NOT_FOUND = 1
                      OTHERS         = 2.
            IF SY-SUBRC <> 0.
                WRITE: 'User ', T_USER-BNAME, 'not found.'.
            ENDIF.
    ENDLOOP.
    IF SY-SUBRC <> 0.
*       Big error! No user has been selected.
        MESSAGE ID 'AT' TYPE 'E' NUMBER '315' WITH
              'No user selected!'.
        EXIT.
    ENDIF.
ENDFORM.                    " POPUP_MSG

*&---------------------------------------------------------------------*
*&      Form  GET_MESSAGE
*&---------------------------------------------------------------------*
FORM GET_MESSAGE CHANGING P_L_MSG LIKE SM04DIC-POPUPMSG
                          P_RETURNCODE TYPE C.
DATA: BEGIN OF FIELDS OCCURS 1.
        INCLUDE STRUCTURE SVAL.
DATA: END OF FIELDS,
      RETURNCODE TYPE C.

    FIELDS-TABNAME = 'SM04DIC'.
    FIELDS-FIELDNAME = 'POPUPMSG'.
    FIELDS-FIELDTEXT = 'Message :'.
    CONCATENATE ' - Msg from' SY-UNAME '.' INTO FIELDS-VALUE SEPARATED
            BY ' '.
    APPEND FIELDS.

    CALL FUNCTION 'POPUP_GET_VALUES'
        EXPORTING POPUP_TITLE     = 'Internal Messaging Service'

        IMPORTING RETURNCODE      = P_RETURNCODE
        TABLES    FIELDS          = FIELDS.

    IF P_RETURNCODE = 'A'.
        EXIT.
    ELSE.
        READ TABLE FIELDS INDEX 1.
        P_L_MSG = FIELDS-VALUE.
    ENDIF.
ENDFORM.                    " GET_MESSAGE

*-- End of Program
