*&---------------------------------------------------------------------*
* Program    : YMMCGB_0001
* FRICE#     :
* Title      :
* Author     : Ellen H. Lagmay
* Date       : 29.09.2010
* Specification Given By: Functional Consultant Name
* Purpose	 : Program details
*---------------------------------------------------------------------*
* Modification Log
* Date         Author   Num Description
* -----------  -------  ---  -----------------------------------------*
* 29.10.2010   Ellen   001
*
*---------------------------------------------------------------------*


REPORT  ymmcgb_0001.

INCLUDE ymmcgb_0001_global_data.

SELECTION-SCREEN BEGIN OF BLOCK main WITH FRAME TITLE text-024.
SELECTION-SCREEN SKIP 1.
PARAMETERS: p_srv   RADIOBUTTON GROUP rad1, "service contract
            p_nonsv RADIOBUTTON GROUP rad1. "non-service contract
SELECTION-SCREEN SKIP 1.
PARAMETERS: p_fname LIKE rlgrap-filename OBLIGATORY.
SELECTION-SCREEN END OF BLOCK main.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_fname.
  PERFORM open_file_dialog.

START-OF-SELECTION.
  PERFORM upload_data.
  PERFORM validate_data.

END-OF-SELECTION.
  PERFORM create_contract.
  PERFORM display_message.

*-----------------------------------------------------------------------
* Definition
*-----------------------------------------------------------------------
  DEFINE def_fieldcat.
    clear it_fieldcat.
    it_fieldcat-fieldname    = &1.
    it_fieldcat-reptext_ddic = &2.
    it_fieldcat-seltext_l    = &2.
    it_fieldcat-ddictxt      = 'M'.
    append it_fieldcat.
  END-OF-DEFINITION.

  INCLUDE ymmcgb_0001_f01.
