*&---------------------------------------------------------------------*
*& Report  ZMMIGB_0008
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
*---------------------------------------------------------------------*
* Program    : ZMMIGB_0008
* FRICE#     :
* Title      : Quotation Upload Program
* Author     : Andryanto
* Date       : 24.03.2011
* Specification Given By: Eka
* Purpose	   : Quatation Upload Program
* Program will download quotation to excel template and then upload
* updated file using same template after receiving vendor quotation
*---------------------------------------------------------------------*
* Modification Log
* Date         Author          Num  Transport Req no. Description
* -----------  -------         --------------------- ----------------*
* 24.03.2011   Andryanto       P30K902356             1st create
* 05.05.2011   Andryanto       P30K902948
* Correction only display result with has pricing only
* Call transaction ME48 when double click from report
* 10.06.2011   Andryanto       P30K903206
* Add wording dd.mm.yyyy at field valid from and valid to
* Add remarks in excel file taken from RFQ item long text
* Maintain quotation without material master (using short text)
*       => sample in 220 RFQ number 6000000033
* Ticket T003412
*
*---------------------------------------------------------------------*

REPORT  ZMMIGB_0008 NO STANDARD PAGE HEADING.

*----------------------------------------------------------------------*
* I N C L U D E S
*----------------------------------------------------------------------*
INCLUDE: ZMMIGB_0008_TOP,    " Global Data
         ZMMIGB_0008_S01,    " Screen
         ZMMIGB_0008_M01,    " Macros
         ZMMIGB_0008_O01,    " PBO-Modules
         ZMMIGB_0008_I01,    " PAI-Modules
         ZMMIGB_0008_F01.    " FORM-Routines

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
