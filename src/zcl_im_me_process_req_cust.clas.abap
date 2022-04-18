class ZCL_IM_ME_PROCESS_REQ_CUST definition
  public
  final
  create public .

*"* public components of class ZCL_IM_ME_PROCESS_REQ_CUST
*"* do not include other source files here!!!
public section.

  interfaces IF_EX_ME_PROCESS_REQ_CUST .
protected section.
*"* protected components of class ZCL_IM_ME_PROCESS_REQ_CUST
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_IM_ME_PROCESS_REQ_CUST
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_IM_ME_PROCESS_REQ_CUST IMPLEMENTATION.


METHOD if_ex_me_process_req_cust~check.

  INCLUDE: mm_messages_mac. "For Displaying Messages

  TYPE-POOLS: isoc.

  DATA: l_gswrt      TYPE gswrt,                   "Total Value of Item
        l_gswrtc(15),                              "Total Value of Item (Character based)
        l_waers      TYPE waers,                   "Currency Key

        ls_header    TYPE mereq_header,            "Purchase Requisition Header
        ls_item      TYPE mereq_item,              "Purchase Requisition Item

        lt_item      TYPE mmpur_requisition_items,
        l_mat_labor  TYPE mara-labor,

        l_date_allowed TYPE c.                     "Boolean for creation date

  FIELD-SYMBOLS: <ls_item> TYPE mmpur_requisition_item.

  CONSTANTS: c_000 TYPE sy-msgno   VALUE '000', "Message Number
             c_s   TYPE sy-msgty   VALUE 'S',   "Message Type (Status)
             c_zml TYPE eban-bsart VALUE 'ZML', "Market List
             c_zmm TYPE sy-msgid   VALUE 'ZMM', "Message ID (MM)
             c_labor TYPE mara-labor VALUE '999'.   "Material Market List

  break mmirasol.

* Get Header Data
  CALL METHOD im_header->get_data
    RECEIVING
      re_data = ls_header.

* If Header Data is not blank
  IF NOT ls_header IS INITIAL.

*   If PR Type is Market Lizt
    IF ls_header-bsart = c_zml.

*     Get Header's Items
      CALL METHOD im_header->get_items
        RECEIVING
          re_items = lt_item.

*     If Items exist
      IF NOT lt_item[] IS INITIAL.

        UNASSIGN: <ls_item>.

*       Loop at Items
        LOOP AT lt_item ASSIGNING <ls_item>.

          CLEAR: ls_item.

          CALL METHOD <ls_item>-item->get_data
            RECEIVING
              re_data = ls_item.

*         If record is not deleted
          IF ls_item-loekz IS INITIAL.

*           Compute Total Unit Price
            l_gswrt = ls_item-gswrt +
                      l_gswrt.
            l_waers = ls_item-waers.

          ENDIF.

        ENDLOOP.

*       Check Currency
        IF l_waers = text-w01. "Vietnamese Dong

          WRITE l_gswrt TO       l_gswrtc
                        CURRENCY l_waers.

*         Display Message
          mmpur_message_forced c_s
                               c_zmm
                               c_000
                               text-ms1
                               l_gswrtc
                               l_waers
                               space.

        ELSE. "Other currencies

*         Display Message
          mmpur_message_forced c_s
                               c_zmm
                               c_000
                               text-ms1
                               l_gswrt
                               l_waers
                               space.

        ENDIF.

*Start -- checking material market list (LAB/OFFICE = '999')
        CLEAR: l_date_allowed.

        LOOP AT lt_item ASSIGNING <ls_item>.
          CLEAR: ls_item.

          CALL METHOD <ls_item>-item->get_data
            RECEIVING
              re_data = ls_item.

          IF NOT ls_item-badat IS INITIAL
             AND ls_item-badat GT '20140613'.      "This shouldn't impact previously created PR/PO.

              l_date_allowed = 'X'.
              EXIT.

          ENDIF.
        ENDLOOP.

        CHECK NOT l_date_allowed IS INITIAL.

        LOOP AT lt_item ASSIGNING <ls_item>.

          CLEAR: ls_item,
                 l_mat_labor.

          CALL METHOD <ls_item>-item->get_data
            RECEIVING
              re_data = ls_item.

*         If record is not deleted
          IF ls_item-loekz IS INITIAL.


            IF ls_item-matnr IS NOT INITIAL.

                SELECT SINGLE labor FROM mara INTO l_mat_labor
                 WHERE matnr = ls_item-matnr.

                IF l_mat_labor NE c_labor.
*                   Display Message
                    mmpur_message_forced 'E'
                                         c_zmm
                                         c_000
                                         'Material'
                                         ls_item-matnr
                                         'is not Market List type material'
                                         space.
                    CH_FAILED = 'X'.                "Prevent PR from being saved
*                    EXIT.
                ENDIF.

            ELSE.           "Free Text Material

*               Display Message
                mmpur_message_forced 'E'
                                     c_zmm
                                     c_000
                                     'Item' ls_item-BNFPO
                                     'Free text material is not allowed'
                                     'on Market List type PR'.
                CH_FAILED = 'X'.                "Prevent PR from being saved
*                EXIT.

            ENDIF.

          ENDIF.

        ENDLOOP.
*End -- checking material market list (LAB/OFFICE = '999')


      ENDIF.

    ENDIF.

  ENDIF.

ENDMETHOD.


method IF_EX_ME_PROCESS_REQ_CUST~CLOSE.
endmethod.


method IF_EX_ME_PROCESS_REQ_CUST~FIELDSELECTION_HEADER.
endmethod.


method IF_EX_ME_PROCESS_REQ_CUST~FIELDSELECTION_HEADER_REFKEYS.
endmethod.


method IF_EX_ME_PROCESS_REQ_CUST~FIELDSELECTION_ITEM.
endmethod.


method IF_EX_ME_PROCESS_REQ_CUST~FIELDSELECTION_ITEM_REFKEYS.
endmethod.


method IF_EX_ME_PROCESS_REQ_CUST~INITIALIZE.
endmethod.


method IF_EX_ME_PROCESS_REQ_CUST~OPEN.
endmethod.


method IF_EX_ME_PROCESS_REQ_CUST~POST.




endmethod.


method IF_EX_ME_PROCESS_REQ_CUST~PROCESS_ACCOUNT.
endmethod.


method IF_EX_ME_PROCESS_REQ_CUST~PROCESS_HEADER.
endmethod.


method IF_EX_ME_PROCESS_REQ_CUST~PROCESS_ITEM.

*  break zdevams.

  DATA: lwa_mereqitem      TYPE mereq_item,
        lwa_mereqitemx     TYPE mereq_itemx,
        lv_txz01           TYPE TXZ01.

    lwa_mereqitem = im_item->get_data( ).

    CHECK lwa_mereqitem-MATNR IS NOT INITIAL.

    SELECT SINGLE maktx FROM makt
      INTO lv_txz01
     WHERE matnr = lwa_mereqitem-MATNR
       AND spras = sy-langu.

    IF sy-subrc = 0.

      lwa_mereqitem-TXZ01  = lv_txz01.
      lwa_mereqitemx-TXZ01 = 'X'.

      im_item->set_datax( EXPORTING im_datax = lwa_mereqitemx ).
      im_item->set_data( EXPORTING im_data = lwa_mereqitem ).

*      INCLUDE mm_messages_mac.
*      mmpur_message_forced 'I' 'ZMM' '000' 'Short text has been replaced' '' '' ''.

    ENDIF.

endmethod.
ENDCLASS.
