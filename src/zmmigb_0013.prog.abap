*&---------------------------------------------------------------------*
*& Report  ZMMIGB_0013
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
*---------------------------------------------------------------------*
* Program    : ZMMIGB_0013
* FRICE#     :
* Title      : Quotation Upload Program
* Author     : HH - Deloitte
* Date       : 16.08.2021
* Purpose	   : Quatation Upload Program
* Program will download quotation to excel template and then upload
* updated file using same template after receiving vendor quotation
* Copied from ZMMIGB_0008
*---------------------------------------------------------------------*
* Modification Log
* Date         Author          Num  Transport Req no. Description
* -----------  -------         --------------------- ----------------*
* 16.08.2021   HH              P30K913844             1st create

*---------------------------------------------------------------------*

REPORT  ZMMIGB_0013 NO STANDARD PAGE HEADING.

*----------------------------------------------------------------------*
* I N C L U D E S
*----------------------------------------------------------------------*
INCLUDE ZMMIGB_0013_TOP.
INCLUDE ZMMIGB_0013_S01.
INCLUDE ZMMIGB_0013_M01.
INCLUDE ZMMIGB_0013_F01.

*----------------------------------------------------------------------*
* INITIALIZATION
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM INIT_DATA.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN                                                  *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  IF P_BTCUR1 = 'X' OR
     P_BTCUR2 = 'X'.
*    PERFORM f_browse CHANGING p_file.
    PERFORM f_get_pcdir.
  ELSE.
    PERFORM f_get_pcdir.
  ENDIF.

AT SELECTION-SCREEN.
  PERFORM check_screen.

*----------------------------------------------------------------------*
* S T A R T   O F   S E L E C T I O N
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM CHECK_AUTHORISATION.
  CHECK g_error eq space.
  IF P_FILE = SPACE.
    MESSAGE I398(00) WITH TEXT-E01.
    EXIT.
  ENDIF.
  PERFORM retrieve_data.
END-OF-SELECTION.
