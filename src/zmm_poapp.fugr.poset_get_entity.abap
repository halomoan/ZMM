FUNCTION POSET_GET_ENTITY.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PONUMBER) TYPE  EBELN
*"     VALUE(USERID) TYPE  XUBNAME OPTIONAL
*"  EXPORTING
*"     VALUE(FM_ENTITY) TYPE  ZTS_PURCHASEORDER
*"  TABLES
*"      POSTATUS STRUCTURE  ZTS_POSTATUS
*"----------------------------------------------------------------------
*TYPES:  BEGIN OF ty_ebeln_status,
*             ebeln TYPE ebeln,
*             PROCSTAT TYPE MEPROCSTATE,
*        END OF ty_ebeln_status.



DATA: lx_po   type ref to z_mm_po,
      it_zpogr TYPE STANDARD TABLE OF zzpogrp,
      postr TYPE STRING,
      hashstr TYPE STRING,
      r_ebeln TYPE RANGE OF ebeln,
      r_ebeln_line LIKE LINE OF r_ebeln,
      lt_po_status TYPE STANDARD TABLE OF ZTS_POSTATUS.
*      lt_ebeln_status TYPE STANDARD TABLE OF ty_ebeln_status.

FIELD-SYMBOLS: <ls_zpogr> TYPE zzpogrp,
               <ls_po_status> TYPE ZTS_POSTATUS.
*                <ls_ebeln_status> TYPE ty_ebeln_status.

IF PONUMBER eq '1'.
  CALL FUNCTION 'Z_PORELGRP'
          EXPORTING
            uname              = sy-uname
          TABLES
            it_ekpo            = it_zpogr
          EXCEPTIONS
            rel_code_not_found = 1
            rel_grp_not_found  = 2
          OTHERS             = 3.
   IF sy-subrc = 0.
      CLEAR postr.

      LOOP AT it_zpogr ASSIGNING <ls_zpogr>.
        r_ebeln_line-sign   = 'I'.
        r_ebeln_line-option = 'EQ'.
        SELECT SINGLE EBELN INTO r_ebeln_line-low FROM EKPO WHERE ebeln = <ls_zpogr>-ebeln AND LOEKZ = ''.
        IF sy-subrc = 0.
             APPEND r_ebeln_line TO r_ebeln.
        ENDIF.
      ENDLOOP.

      IF LINES( r_ebeln ) > 0.
        SELECT EBELN PROCSTAT FROM EKKO INTO TABLE lt_po_status WHERE ebeln IN r_ebeln ORDER BY EBELN DESCENDING.
      ENDIF.

      IF sy-subrc eq 0.
        LOOP AT lt_po_status ASSIGNING <ls_po_status>.
          IF <ls_po_status>-STATUS = '03'.
                     CONCATENATE <ls_po_status>-ponumber 'P' postr INTO postr.
          ELSEIF <ls_po_status>-STATUS = '08'.
                    CONCATENATE <ls_po_status>-ponumber 'R' postr INTO postr.
          ENDIF.
        ENDLOOP.


         CALL FUNCTION 'CALCULATE_HASH_FOR_CHAR'
         EXPORTING
                 ALG                  = 'MD5'
                 DATA                 = postr
*                LENGTH               = 0
         IMPORTING
*                HASH                 =
*                HASHLEN              =
*                HASHX                =
*                HASHXLEN             =
                HASHSTRING           = hashstr
*                HASHXSTRING          =
*                HASHB64STRING        =
         EXCEPTIONS
                UNKNOWN_ALG          = 1
                PARAM_ERROR          = 2
                INTERNAL_ERROR       = 3
                OTHERS               = 4
                       .
          IF SY-SUBRC eq 0.
                FM_ENTITY-purchaseorderid = hashstr.
          ENDIF.
     ELSE.
           FM_ENTITY-purchaseorderid = 'ERROR'.
     ENDIF.
   ENDIF.
ELSEIF  PONUMBER eq '2'.
    IF USERID IS INITIAL.
*      CALL FUNCTION 'Z_PORELGRP'
*          EXPORTING
*            uname              = sy-uname
*          TABLES
*            it_ekpo            = it_zpogr
*          EXCEPTIONS
*            rel_code_not_found = 1
*            rel_grp_not_found  = 2
*          OTHERS             = 3.
    ELSE.
      SELECT SINGLE BNAME INTO USERID FROM USR02 WHERE BNAME = USERID AND UFLAG = '0'.
      IF sy-subrc = 0.
        CALL FUNCTION 'Z_PORELGRP'
            EXPORTING
              uname              = USERID
            TABLES
              it_ekpo            = it_zpogr
            EXCEPTIONS
              rel_code_not_found = 1
              rel_grp_not_found  = 2
            OTHERS             = 3.

        IF sy-subrc = 0.
          CLEAR postr.
          LOOP AT it_zpogr ASSIGNING <ls_zpogr>.
           r_ebeln_line-sign   = 'I'.
           r_ebeln_line-option = 'EQ'.
           SELECT SINGLE EBELN INTO r_ebeln_line-low FROM EKPO WHERE ebeln = <ls_zpogr>-ebeln AND LOEKZ = ''.
           IF sy-subrc = 0.
             APPEND r_ebeln_line TO r_ebeln.
           ENDIF.
          ENDLOOP.

          IF LINES( r_ebeln ) > 0.
            SELECT EBELN PROCSTAT FROM EKKO INTO TABLE POSTATUS WHERE ebeln IN r_ebeln ORDER BY EBELN DESCENDING.
          ENDIF.

        ENDIF.
      ENDIF.
    ENDIF.



ELSE.
     create object lx_po
          exporting
            i_ponumber = PONUMBER.
       " Fill the entity data to be returned.
        FM_ENTITY-purchaseorderid = lx_po->po_number.
        FM_ENTITY-destinationplant = lx_po->get_dest_plant_text( ).
        FM_ENTITY-purchasegroup = lx_po->get_pgroup_text( ).
        FM_ENTITY-previousapprovalcomments = lx_po->comments.
        FM_ENTITY-totalvalue = lx_po->total_value.
        FM_ENTITY-advancepercentage = lx_po->advance_percentage.
        FM_ENTITY-incoterms = lx_po->incoterms.
        FM_ENTITY-currency = lx_po->currency.
        FM_ENTITY-paymentterms = lx_po->get_payment_term_text( ).
        FM_ENTITY-createdby = lx_po->get_created_by( ).
        FM_ENTITY-date = lx_po->creation_date.
        FM_ENTITY-status = lx_po->get_status( ).

ENDIF.



ENDFUNCTION.
