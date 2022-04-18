*&---------------------------------------------------------------------*
*& PROGRAM      : ZMM_ME01_VL_UPDATE
*& DATE WRITTEN : 20200225
*& MODULE       : MM
*& TYPE         : Enhancement
*& CREATED BY   : Michelle Guillermo-Santiago
*& REQUESTED BY : Joey Heng
*& REQUEST#     : UOL Ticket INC-409
*&---------------------------------------------------------------------*
*& TITLE  : Modify Source List to Fix Vendor
*& TCODE  : ZMM_ME01_VL_UPD
*& TR#    : P30K912044
*& FUNCTIONALITY :
*&  - Modify Source List to Fix Vendor (ME01)
*&---------------------------------------------------------------------*
*& MODIFICATION HISTORY
*& No.  NAME       Date      Description / SR#
*&---------------------------------------------------------------------*
*&
*&=====================================================================*
REPORT zmm_me01_vl_update.


*&---------------------------------------------------------------------*
*&      GLOBAL DATA DECLARATIONS                                       *
*&---------------------------------------------------------------------*
INCLUDE zmm_me01_vl_update_top.
INCLUDE zmm_me01_vl_update_c01.


*----------------------------------------------------------------------*
*       EVENTS                                                         *
*----------------------------------------------------------------------*
INITIALIZATION.
  DATA(go_data) = NEW lcl_data( ).


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  p_file = go_data->f4_filename( rb_xlsx ).


START-OF-SELECTION.
  TRY.
      go_data->begin_process( ).
    CATCH zcx_excp_msg INTO DATA(lx_msg).
      MESSAGE lx_msg->get_text( )
         TYPE 'S'
      DISPLAY LIKE lx_msg->msgty.
      LEAVE LIST-PROCESSING.
  ENDTRY.
