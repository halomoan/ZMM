*&---------------------------------------------------------------------*
*& Report  ZMMRGB_0009
*&---------------------------------------------------------------------*
* Title      : Ariba Sourcing Event ID Report
* Author     : Allan Taufiq
* Date       : 20.09.2016
* Purpose	   : List Down PR for Ariba Integration Report
*----------------------------------------------------------------------*
* Modification Log
* Date         Author   Num Transport Req no.  Description
* -----------  -------  ---------------------  ------------------------*
* 20.09.2016   ALLANT   P30K908461             Initial creation
*----------------------------------------------------------------------*
REPORT zmmrgb_0009.

INCLUDE: zmmrgb_0009_top,
         zmmrgb_0009_f01.

INITIALIZATION.
*  PERFORM f_initialize.

START-OF-SELECTION.
  break zdevams.
  PERFORM: f_initialize_itab,
           f_get_data,
           f_process_data.

END-OF-SELECTION.
  PERFORM f_display_alv.
