*&---------------------------------------------------------------------*
*& Subroutine Pool  ZMMNGB_0001
*&---------------------------------------------------------------------*
* FRICE#     : 100930
* Title      : PO & RFQ printing
* Author     : Ellen H. Lagmay
* Date       : 05.10.2010
* Specification Given By: Tambunan, Yanti Roselynn
* Purpose	 : Print PO & RFQ
*---------------------------------------------------------------------*
* Modification Log
* Date         Author   Num Description
*
* -----------  -------  ---  -----------------------------------------*

PROGRAM  zmmngb_0001.

*_data declarations
TABLES: ekko, lfa1, adrc, usr01, t001w, t024, zbcgb_logo, erev, nast.

DATA: BEGIN OF it_ekpo OCCURS 0,
        ebeln TYPE ebeln,
        ebelp TYPE ebelp,
        txz01 TYPE txz01,
        matnr TYPE matnr,
        ematn TYPE ematn,
        bukrs TYPE bukrs,
        werks TYPE werks_d,
        menge TYPE bstmg,
        meins TYPE bstme,
        netpr TYPE bprei,
        netwr TYPE wertv8,"amount
        eindt TYPE datum,
        banfn TYPE banfn,
        kawrt TYPE kawrt,"net price
        kbetr TYPE kbetr,"unit price
        disc TYPE kbetr, "discount
        remarks(255),
        totalamt TYPE wertv8, "total amt without tax
    END OF it_ekpo,
*Start of replace brianrabe P30K909968
*    BEGIN OF it_konv OCCURS 0,
*       knumv  TYPE knumv,
*       kposn  TYPE kposn,
*       kschl  TYPE kschl,
*       kawrt  TYPE kawrt,
*       kbetr  TYPE kbetr,
*    END OF it_konv,
   it_konv LIKE konv OCCURS 0 WITH HEADER LINE,
*End of replace brianrabe P30K909968
   it_lines LIKE tline OCCURS 0 WITH HEADER LINE.
DATA : BEGIN OF it_itcpo.
        INCLUDE STRUCTURE itcpo.
DATA : END OF it_itcpo.

DATA: l_name LIKE thead-tdname,
      l_totalamt TYPE wertv8,
      l_end,
      l_xscreen(1) TYPE c.

*&---------------------------------------------------------------------*
*&      Form  entry_neu
*&---------------------------------------------------------------------*

FORM entry_neu USING ent_retco ent_screen.

  DATA: l_retcode LIKE sy-subrc.
  BREAK elagmay.
  CLEAR: l_retcode,  ent_retco.
  l_xscreen = ent_screen.

  PERFORM data_selection USING l_retcode.

*  IF l_retcode NE 0 .
*    ent_retco = 1.
*  ELSE.
*    ent_retco = 0.
*  ENDIF.

ENDFORM.                    "entry_neu

*&---------------------------------------------------------------------*
*&      Form  DATA_SELECTION
*&---------------------------------------------------------------------*
FORM data_selection  USING    p_l_retcode.
*___A. get po details
*_ge PO header
  CLEAR ekko.
  SELECT SINGLE * FROM ekko INTO ekko
  WHERE ebeln = nast-objky.

  IF sy-subrc = 0.
*_get vendor details
    CLEAR lfa1.
    SELECT SINGLE * FROM lfa1 INTO lfa1
      WHERE lifnr = ekko-lifnr.
*_get delivery address
    IF sy-subrc = 0.
      CLEAR adrc.
      SELECT SINGLE * FROM adrc INTO adrc
       WHERE addrnumber = lfa1-adrnr.
    ENDIF.
*_get PO items & delivery date
    CLEAR it_ekpo[].
    SELECT a~ebeln a~ebelp a~txz01 a~matnr
           a~ematn a~bukrs a~werks a~menge
           a~meins a~netpr a~netwr
           b~eindt b~banfn
    FROM ekpo AS a INNER JOIN eket AS b
              ON  a~ebeln = b~ebeln
              AND a~ebelp = b~ebelp
    INTO TABLE it_ekpo
    WHERE a~ebeln = ekko-ebeln
    AND   a~loekz = space.
    IF sy-subrc = 0.
*_get plant name (business name-header)
      CLEAR t001w.
      READ TABLE it_ekpo INDEX 1.
      SELECT SINGLE * FROM t001w
        WHERE werks = it_ekpo-werks.
*_get discount per item
*Start of replace brianrabe P30K909968
      CLEAR it_konv[].
*      SELECT knumv kposn kschl kawrt kbetr
*      INTO TABLE it_konv
*      FROM konv
*      WHERE knumv = ekko-knumv
*      AND   kschl IN ('PBXX','RA00' , 'RA01' , 'RB00').
*TRY.
* cl_prc_result_factory=>get_instance( )->get_prc_result( )->get_price_element_db_by_key(
*  EXPORTING
*    iv_knumv                      = ekko-knumv
*  IMPORTING
*    et_prc_element_classic_format = it_konv[] ).
* CATCH cx_prc_result ##NO_HANDLER. "implement suitable error handling
*ENDTRY.
*
*DELETE it_konv WHERE ( kschl NE 'PBXX'
*                  OR kschl NE 'RA00'
*                  OR kschl NE 'RA01'
*                  OR kschl NE 'RB00' ).
TRY.
 cl_prc_result_factory=>get_instance( )->get_prc_result( )->get_price_element_db(
 EXPORTING
   it_selection_attribute = VALUE #( ( fieldname = 'KNUMV' value =  ekko-knumv )
                                     ( fieldname = 'KSCHL' value = 'PBXX' )
                                     ( fieldname = 'KSCHL' value = 'RA00' )
                                     ( fieldname = 'KSCHL' value = 'RA01' )
                                     ( fieldname = 'KSCHL' value = 'RB00' ) )
 IMPORTING
   et_prc_element_classic_format = it_konv[] ).
 CATCH cx_prc_result ##NO_HANDLER. "implement suitable error handling
ENDTRY.
*End of replace brianrabe P30K909968
*_read PO Header remarks( SPECIAL INSTRUCTIONS / REMARKS:)
      CLEAR: l_name, it_lines[].
      l_name = it_ekpo-ebeln.
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          id                      = 'F01'
          language                = sy-langu
          name                    = l_name
          object                  = 'EKKO'
        TABLES
          lines                   = it_lines
        EXCEPTIONS
          id                      = 1
          language                = 2
          name                    = 3
          not_found               = 4
          object                  = 5
          reference_check         = 6
          wrong_access_to_archive = 7
          OTHERS                  = 8.
      CLEAR ekko-description.
      IF sy-subrc = 0.
        READ TABLE it_lines INDEX 1.
        IF sy-subrc = 0.
          CONCATENATE ekko-description it_lines-tdline
          INTO ekko-description SEPARATED BY space.
        ENDIF.
        READ TABLE it_lines INDEX 2.
        IF sy-subrc = 0.
          CONCATENATE ekko-description it_lines-tdline
          INTO ekko-description SEPARATED BY space.
        ENDIF.
      ENDIF.

*_ fill other table entries
      LOOP AT it_ekpo.
* fill unit price and net price before discount
        READ TABLE it_konv WITH KEY kposn = it_ekpo-ebelp
                                    kschl = 'PBXX'.
        IF sy-subrc = 0.
          it_ekpo-kawrt = it_konv-kawrt.
          it_ekpo-kbetr = it_konv-kbetr.
          DELETE it_konv INDEX sy-tabix.
        ENDIF.
* fill discount value
        READ TABLE it_konv WITH KEY kposn = it_ekpo-ebelp."discount
        IF sy-subrc = 0.
          it_ekpo-disc = ( it_konv-kbetr / 10 ).
        ENDIF.
*read PO Item remarks
        CLEAR: l_name, it_lines[].
        CONCATENATE it_ekpo-ebeln it_ekpo-ebelp INTO l_name.
        CALL FUNCTION 'READ_TEXT'
          EXPORTING
            id                      = 'F01'
            language                = sy-langu
            name                    = l_name
            object                  = 'EKPO'
          TABLES
            lines                   = it_lines
          EXCEPTIONS
            id                      = 1
            language                = 2
            name                    = 3
            not_found               = 4
            object                  = 5
            reference_check         = 6
            wrong_access_to_archive = 7
            OTHERS                  = 8.
        IF sy-subrc = 0.
          READ TABLE it_lines INDEX 1.
          IF sy-subrc = 0.
            CONCATENATE 'Remarks:' it_ekpo-remarks it_lines-tdline
            INTO it_ekpo-remarks SEPARATED BY space.
          ENDIF.
          READ TABLE it_lines INDEX 2.
          IF sy-subrc = 0.
            CONCATENATE it_ekpo-remarks it_lines-tdline
            INTO it_ekpo-remarks SEPARATED BY space.
          ENDIF.
        ENDIF.
        l_totalamt = l_totalamt + it_ekpo-netwr.
        AT LAST.
          l_end = 'X'.
        ENDAT.
        IF l_end = 'X'.
          it_ekpo-totalamt = l_totalamt.
        ENDIF.
        MODIFY it_ekpo.
      ENDLOOP.
    ENDIF.
*)_get purchasing grp name
    CLEAR t024.
    SELECT SINGLE * FROM t024
     WHERE ekgrp = ekko-ekgrp.

*_ get logo per company code
    CLEAR zbcgb_logo.
    SELECT SINGLE * FROM zbcgb_logo
      WHERE bukrs = ekko-bukrs.
*_ get PO version
    CLEAR erev.
    SELECT MAX( revno ) FROM erev
      INTO erev-revno
      WHERE edokn = ekko-ebeln.
    IF ( sy-subrc = 0  AND erev-revno = 00000000 ) OR
       sy-subrc <> 0.
      erev-revno = 1.
    ENDIF.

    PERFORM po_printing.

  ENDIF.
ENDFORM.                    " DATA_SELECTION
*&---------------------------------------------------------------------*
*&      Form  PO_PRINTING
*&---------------------------------------------------------------------*
FORM po_printing.

*___B. Print Form (call script)
  CLEAR usr01.
  SELECT SINGLE * FROM usr01 WHERE bname = sy-uname.


  it_itcpo-tddest    = 'LOCL'.  "usr01-spld. "Output device (printer)
*  it_itcpo-tdimmed   = 'X'.               "Print immediately
  it_itcpo-tdpreview  = 'X'.
  it_itcpo-tddelete  = 'X'.               "Delete after printing
  it_itcpo-tdprogram = 'ZMMRGB_0001'.      "Program Name

  CALL FUNCTION 'OPEN_FORM'
    EXPORTING
      application = 'TX'
      device      = 'PRINTER'
      dialog      = ' '
      form        = 'ZMMGB_POFORM'
      language    = sy-langu
      options     = it_itcpo
    IMPORTING
      language    = sy-langu
    EXCEPTIONS
      OTHERS      = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'LOGO'
      window  = 'LOGO'
    EXCEPTIONS
      element = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'PO_NO'
      window  = 'PO_NO'
    EXCEPTIONS
      element = 2.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'BUS_HDR'
      window  = 'BUS_HDR'
    EXCEPTIONS
      element = 3.


  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'VERSION'
      window  = 'VERSION'
    EXCEPTIONS
      element = 4.


  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'PO_TITLE'
      window  = 'PO_TITLE'
    EXCEPTIONS
      element = 5.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'ADDRESS'
      window  = 'ADDRESS'
    EXCEPTIONS
      element = 6.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'CONSGNEE'
      window  = 'CONSGNEE'
    EXCEPTIONS
      element = 7.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'INFO'
      window  = 'INFO'
    EXCEPTIONS
      element = 7.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'ITEM_TITLE'
      window  = 'MAIN'
    EXCEPTIONS
      element = 1.

  LOOP AT it_ekpo.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'ITEM_DATA'
        window  = 'MAIN'
      EXCEPTIONS
        element = 2.
    l_totalamt = it_ekpo-totalamt.
    AT LAST.
      it_ekpo-totalamt = l_totalamt.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'ITEM_TOTAL'
          window  = 'MAIN'
        EXCEPTIONS
          element = 3.

      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'SPECIAL_INSTRUCTIONS'
          window  = 'MAIN'
        EXCEPTIONS
          element = 4.

      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'CONDITIONS'
          window  = 'MAIN'
        EXCEPTIONS
          element = 5.
    ENDAT.
  ENDLOOP.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'PAGE'
      window  = 'PAGE'
    EXCEPTIONS
      element = 3.


  CALL FUNCTION 'CLOSE_FORM'
    EXCEPTIONS
      unopened = 1
      OTHERS   = 2.

  IF sy-subrc = 0.
    PERFORM protocol_update.
  ENDIF.
ENDFORM.                    " PO_PRINTING
*&---------------------------------------------------------------------*
*&      Form  PROTOCOL_UPDATE
*&---------------------------------------------------------------------*
FORM protocol_update .
  CHECK l_xscreen = space.
  CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
    EXPORTING
      msg_arbgb = syst-msgid
      msg_nr    = syst-msgno
      msg_ty    = syst-msgty
      msg_v1    = syst-msgv1
      msg_v2    = syst-msgv2
      msg_v3    = syst-msgv3
      msg_v4    = syst-msgv4
    EXCEPTIONS
      OTHERS    = 1.

ENDFORM.                    " PROTOCOL_UPDATE
