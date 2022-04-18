*&---------------------------------------------------------------------*
*& Report  ZMMRGB_0008
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZMMRGB_0008 MESSAGE-ID zmm NO STANDARD PAGE HEADING.

INCLUDE: ZMMRGB_0008_top,    " Global Data
         ZMMRGB_0008_s01,    " Screen
         ZMMRGB_0008_f01.    " FORM-Routines


*----------------------------------------------------------------------*
* I N I T I A L I Z A T I O N
*----------------------------------------------------------------------*
INITIALIZATION.


*----------------------------------------------------------------------*
* A T  S E L E C T I O N - S C R E E N  O U T P U T
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.

  PERFORM: set_screen.


*----------------------------------------------------------------------*
* A T  S E L E C T I O N  S C R E E N
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.

  PERFORM: check_bukrs_and_werks.


*----------------------------------------------------------------------*
* S T A R T  O F  S E L E C T I O N
*----------------------------------------------------------------------*
START-OF-SELECTION.


  PERFORM: validate_date,
           validate_hits_value,
           get_general_data,           "For company code currency, vendor name, etc

           get_data.


*----------------------------------------------------------------------*
* E N D  O F  S E L E C T I O N
*----------------------------------------------------------------------*
END-OF-SELECTION.

  PERFORM: prepare_report,
           display_report.
