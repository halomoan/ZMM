*&---------------------------------------------------------------------*
*&  Include           ZXVVFU08
*&---------------------------------------------------------------------*


DATA: wa_vbak TYPE VBAK,
      wa_qmih TYPE QMIH,
      wa_iloa TYPE ILOA,
      wa_iflotx TYPE IFLOTX,

      fl_desc TYPE pltxt.      "Functional Location description


DATA: TEMP_LINES TYPE TABLE OF TLINE WITH HEADER LINE,
      LINES TYPE TABLE OF TLINE WITH HEADER LINE,
      THEAD TYPE THEAD,
      IT_XACCIT TYPE TABLE OF ACCIT WITH HEADER LINE.

DATA: BEGIN OF IT_UNITNO OCCURS 0,
        aubel TYPE VBELN_VA,          "Sales Doc
        pltxt TYPE PLTXT,             "Description of functional location
      END OF IT_UNITNO.


* Step 001 START
* GET FIRST's FREE TEXT of SALES ORER On BILLING DOCUMENTS
LOOP AT cvbrp.

  REFRESH: TEMP_LINES[].

  "Concatenate Sales Order No and Sales Order item
  CONCATENATE cvbrp-aubel cvbrp-aupos INTO THEAD-TDNAME.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
*     CLIENT                        = SY-MANDT
      id                            = '0001'
      language                      = sy-langu
      name                          = THEAD-TDNAME
      object                        = 'VBBP'
*     ARCHIVE_HANDLE                = 0
*     LOCAL_CAT                     = ' '
*   IMPORTING
*     HEADER                        =
    tables
      lines                         = TEMP_LINES
   EXCEPTIONS
     ID                            = 1
     LANGUAGE                      = 2
     NAME                          = 3
     NOT_FOUND                     = 4
     OBJECT                        = 5
     REFERENCE_CHECK               = 6
     WRONG_ACCESS_TO_ARCHIVE       = 7
     OTHERS                        = 8
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  IF NOT TEMP_LINES[] IS INITIAL.
    APPEND LINES OF TEMP_LINES TO LINES.
    EXIT.
  ENDIF.

ENDLOOP.
* Step 001 END



* Step 002 START
* GET FUNCTION LOCATION as #UNIT No FROM SERVICE NOTIFICATION
REFRESH: IT_UNITNO[].
CLEAR  : fl_desc.
* Loop over billing doc items to get Sales Doc
LOOP AT cvbrp WHERE aubel IS NOT INITIAL.

    CLEAR: IT_UNITNO.

*    Get sales order data
    SELECT SINGLE * FROM vbak INTO wa_vbak WHERE vbeln = cvbrp-aubel.

    IF sy-subrc = 0.

*      Get Service Notification data
      SELECT SINGLE * FROM qmih INTO wa_qmih WHERE qmnum = wa_vbak-qmnum.

      IF sy-subrc = 0.

*        Get PM Object Location
        SELECT SINGLE * FROM iloa into wa_iloa WHERE iloan = wa_qmih-iloan.

        IF sy-subrc = 0.

*          Get Functional Location description
          SELECT SINGLE * FROM iflotx into wa_iflotx WHERE tplnr = wa_iloa-tplnr
                                                       AND spras = sy-langu.

          IF sy-subrc = 0.

            IT_UNITNO-aubel = cvbrp-aubel.

             IF NOT wa_iflotx-pltxu IS INITIAL.
               IT_UNITNO-pltxt = wa_iflotx-pltxu.
             ELSE.
               IT_UNITNO-pltxt = wa_iflotx-pltxt.
             ENDIF.

             IF fl_desc IS INITIAL.
               fl_desc = IT_UNITNO-pltxt.
             ENDIF.

             COLLECT IT_UNITNO.

          ENDIF.
        ENDIF.

      ENDIF.

    ENDIF.

ENDLOOP.
* Step 002 END



* Step 003 START
* UPDATE FI LINE ITEMS

IT_XACCIT[] = XACCIT[].

LOOP AT XACCIT.

    IF NOT XACCIT-KUNNR IS INITIAL.           "Process Cust lines with Plant and first sales order text

    XACCIT-XREF3 = fl_desc.                   "Update Ref key 3 with Functional Loc / #Unit No.

    LOOP AT IT_XACCIT WHERE NOT WERKS IS INITIAL.
      EXIT.
    ENDLOOP.

    IF sy-subrc = 0.
      XACCIT-XREF2 = IT_XACCIT-WERKS.       "Update Ref key 2 with Plant information
    ENDIF.

    CLEAR: LINES.
    READ TABLE LINES INDEX 1.
*    CONCATENATE fl_desc lines-tdline INTO XACCIT-SGTXT SEPARATED BY SPACE.
    XACCIT-SGTXT = lines-tdline.


  ELSEIF XACCIT-BSCHL = '40' OR XACCIT-BSCHL = '50'.              "Process GL lines with respective sales order text

     CLEAR  : THEAD, IT_UNITNO.
     REFRESH: TEMP_LINES[].

     CONCATENATE xaccit-aubel xaccit-aupos INTO THEAD-TDNAME.

     CALL FUNCTION 'READ_TEXT'
       EXPORTING
*        CLIENT                        = SY-MANDT
         id                            = '0001'
         language                      = sy-langu
         name                          = THEAD-TDNAME
         object                        = 'VBBP'
*        ARCHIVE_HANDLE                = 0
*        LOCAL_CAT                     = ' '
*      IMPORTING
*        HEADER                        =
       tables
         lines                         = TEMP_LINES
      EXCEPTIONS
        ID                            = 1
        LANGUAGE                      = 2
        NAME                          = 3
        NOT_FOUND                     = 4
        OBJECT                        = 5
        REFERENCE_CHECK               = 6
        WRONG_ACCESS_TO_ARCHIVE       = 7
        OTHERS                        = 8
               .
     IF sy-subrc <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ENDIF.

     IF NOT TEMP_LINES[] IS INITIAL.
       READ TABLE TEMP_LINES INDEX 1.
     ENDIF.

     READ TABLE IT_UNITNO WITH KEY aubel = xaccit-aubel.

*     XACCIT-SGTXT = TEMP_LINES-TDLINE.
     CONCATENATE IT_UNITNO-pltxt TEMP_LINES-TDLINE INTO XACCIT-SGTXT SEPARATED BY SPACE.

  ENDIF.


  "Finally update back to internal table
  MODIFY XACCIT.

ENDLOOP.

* Step 003 END
