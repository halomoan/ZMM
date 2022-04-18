*&---------------------------------------------------------------------*
*& Report  ZMM_MKTLIST_MAPUPLOAD
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT ZMM_MKTLIST_MAPUPLOAD.

TYPES: BEGIN OF ty_tab,
        rec TYPE STRING,
       END OF ty_tab,
       BEGIN OF ty_map,
         PLANT TYPE WERKS_D,
         KOSTL TYPE KOSTL,
         ABLAD TYPE ABLAD,
         STATUS TYPE C LENGTH 6,
         TEMPLTID TYPE C LENGTH 10,
         MAXITEMCOST TYPE N LENGTH 10,
         SHOWVENDOR TYPE C LENGTH 1,
       END OF ty_map.


DATA: lv_filename TYPE STRING.
DATA: lv_totalrec TYPE INT2,
      lv_rejected TYPE INT2,
      lv_submitted TYPE INT2.

DATA: lt_itab TYPE STANDARD TABLE OF ty_tab,
      ls_itab TYPE ty_tab.
DATA: ls_rec TYPE ty_map.
DATA: lt_marketlist TYPE STANDARD TABLE OF ty_map.


SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE  txttitle.
SELECTION-SCREEN BEGIN OF LINE.
  SELECTION-SCREEN COMMENT (25) txtfilep.
  PARAMETERS: lp_file TYPE localfile.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : rupl RADIOBUTTON  GROUP UPD DEFAULT 'X' MODIF ID m1.
SELECTION-SCREEN COMMENT (70) txtupl MODIF ID m1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : rdown RADIOBUTTON  GROUP UPD MODIF ID m2.
SELECTION-SCREEN COMMENT (70) txtdown MODIF ID m2.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE  txtopts.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : cb_hdr AS CHECKBOX  DEFAULT 'X' MODIF ID m1.
SELECTION-SCREEN COMMENT (70) txtskip MODIF ID m1.
PARAMETERS : cb_clear AS CHECKBOX  DEFAULT '' MODIF ID m1.
SELECTION-SCREEN COMMENT (70) txtclear MODIF ID m1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b2.



INITIALIZATION.

txttitle = 'MARKETLIST Mapping'.
txtfilep = 'File Path '.
txtopts  = 'Upload Options'.
txtupl = 'Upload'.
txtdown = 'Download'.
txtclear = 'Clear Table Before Upload'.
txtskip = 'Skip Header'.



AT SELECTION-SCREEN ON VALUE-REQUEST FOR lp_file.
CALL FUNCTION 'KD_GET_FILENAME_ON_F4'
EXPORTING
static    = 'X'
CHANGING
file_name = lp_file.

START-OF-SELECTION.

IF rupl = 'X'.
lv_filename = lp_file.

CALL FUNCTION 'GUI_UPLOAD'
EXPORTING
  filename                = lv_filename
TABLES
  data_tab                = lt_itab
EXCEPTIONS
  file_open_error         = 1
  file_read_error         = 2
  no_batch                = 3
  gui_refuse_filetransfer = 4
  invalid_type            = 5
  no_authority            = 6
  unknown_error           = 7
  bad_data_format         = 8
  header_not_allowed      = 9
  separator_not_allowed   = 10
  header_too_long         = 11
  unknown_dp_error        = 12
  access_denied           = 13
  dp_out_of_memory        = 14
  disk_full               = 15
  dp_timeout              = 16
OTHERS                    = 17.

IF sy-subrc <> 0.
  MESSAGE 'File could not be uploaded' TYPE 'E'.
ENDIF.

DESCRIBE TABLE lt_itab LINES lv_totalrec.
lv_rejected = 0.
lv_submitted = 0.

IF lt_itab[] IS NOT INITIAL.


  IF cb_clear = 'X'.
    DELETE FROM ZMM_MKTLIST_MAP.
  ENDIF.

  LOOP AT lt_itab INTO ls_itab.

      IF sy-tabix eq 1.
          IF cb_hdr eq 'X'.
            CONTINUE.
        ENDIF.
      ENDIF.

      SPLIT ls_itab-rec AT CL_ABAP_CHAR_UTILITIES=>HORIZONTAL_TAB INTO ls_rec-PLANT ls_rec-KOSTL ls_rec-ABLAD ls_rec-STATUS ls_rec-TEMPLTID.

      IF ls_rec-PLANT IS INITIAL OR ls_rec-KOSTL IS INITIAL OR ls_rec-ABLAD IS INITIAL.
          lv_rejected = lv_rejected + 1.
          CONTINUE.
      ENDIF.

      CASE ls_rec-STATUS.
          WHEN 'D'.
              DELETE ZMM_MKTLIST_MAP FROM ls_rec.
          WHEN OTHERS.
              MODIFY ZMM_MKTLIST_MAP FROM ls_rec.
      ENDCASE.

      lv_submitted = lv_submitted + 1.

  ENDLOOP.
  IF sy-subrc = 0.
       MESSAGE 'Successfully Uploaded' TYPE 'I'.
     ELSE.
       MESSAGE 'Failed To Upload' TYPE 'E'.
  ENDIF.


ENDIF.

ELSE.
  "Download
  lv_filename = lp_file.

  SELECT * INTO TABLE lt_marketlist FROM ZMM_MKTLIST_MAP.
  IF sy-subrc = 0.

    ls_rec-PLANT = 'PLANT'.
    ls_rec-KOSTL = 'KOSTL'.
    ls_rec-ABLAD = 'ABLAD'.
    ls_rec-STATUS = 'STATUS'.
    ls_rec-TEMPLTID = 'TEMPLATE'.
    INSERT ls_rec INTO lt_marketlist INDEX 1.

    CALL METHOD cl_gui_frontend_services=>gui_download
    EXPORTING
      filename = lv_filename
      WRITE_FIELD_SEPARATOR = CL_ABAP_CHAR_UTILITIES=>HORIZONTAL_TAB
    CHANGING
      data_tab = lt_marketlist
    EXCEPTIONS
      OTHERS   = 1.

     IF sy-subrc = 0.
       MESSAGE 'Successfully Downloaded' TYPE 'I'.
     ELSE.
       MESSAGE 'Failed To Downloaded' TYPE 'E'.
     ENDIF.
  ELSE.
    ls_rec-PLANT = 'PLANT'.
    ls_rec-KOSTL = 'KOSTL'.
    ls_rec-ABLAD = 'ABLAD'.
    ls_rec-STATUS = 'STATUS'.
    ls_rec-TEMPLTID = 'TEMPLATE'.
    APPEND ls_rec TO lt_marketlist.

    ls_rec-PLANT = '<Plant>'.
    ls_rec-KOSTL = '<Cost Center>'.
    ls_rec-ABLAD = '<Unloading Point>'.
    ls_rec-STATUS = '<D = Delete>'.
    ls_rec-TEMPLTID = '<Template ID>'.

    APPEND ls_rec TO lt_marketlist.
    CALL METHOD cl_gui_frontend_services=>gui_download
    EXPORTING
      filename = lv_filename
      WRITE_FIELD_SEPARATOR = CL_ABAP_CHAR_UTILITIES=>HORIZONTAL_TAB
    CHANGING
      data_tab = lt_marketlist
    EXCEPTIONS
      OTHERS   = 1.

     IF sy-subrc = 0.
       MESSAGE 'Successfully Downloaded' TYPE 'I'.
     ELSE.
       MESSAGE 'Failed To Downloaded' TYPE 'E'.
     ENDIF.

  ENDIF.
ENDIF.
