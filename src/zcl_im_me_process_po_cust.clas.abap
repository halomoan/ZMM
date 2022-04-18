class ZCL_IM_ME_PROCESS_PO_CUST definition
  public
  final
  create public .

*"* public components of class ZCL_IM_ME_PROCESS_PO_CUST
*"* do not include other source files here!!!
public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_ME_PROCESS_PO_CUST .
protected section.
*"* protected components of class ZCL_IM_ME_PROCESS_PO_CUST
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_IM_ME_PROCESS_PO_CUST
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_IM_ME_PROCESS_PO_CUST IMPLEMENTATION.


method IF_EX_ME_PROCESS_PO_CUST~CHECK.

  INCLUDE: mm_messages_mac. "For Displaying Messages

  TYPE-POOLS: isoc.

  CONSTANTS: c_000 TYPE sy-msgno   VALUE '000', "Message Number
             c_s   TYPE sy-msgty   VALUE 'S',   "Message Type (Status)
             c_e   TYPE sy-msgty   VALUE 'E',   "Message Type (Error)
             c_zml TYPE eban-bsart VALUE 'ZML', "Market List
             c_zmm TYPE sy-msgid   VALUE 'ZMM', "Message ID (MM)
             c_labor TYPE mara-labor VALUE '999'.   "Material Market List

  DATA: wa_mepoheader TYPE mepoheader,
        it_mepoitem   TYPE PURCHASE_ORDER_ITEMS,
        wa_mepoitem   TYPE PURCHASE_ORDER_ITEM,
        item          TYPE mepoitem,
        l_mat_labor  TYPE mara-labor.



  wa_mepoheader = im_header->get_data( ).

  CHECK wa_mepoheader-bsart EQ c_zml
    AND wa_mepoheader-aedat GT '20140613'.      "This shouldn't impact previously created PR/PO

  it_mepoitem   = im_header->get_items( ).

  LOOP AT it_mepoitem INTO wa_mepoitem.

    CLEAR: item,
           l_mat_labor.

    item = wa_mepoitem-item->get_data( ).

*   If record is not deleted
    IF item-loekz IS INITIAL.

      IF item-matnr IS NOT INITIAL.

        SELECT SINGLE labor FROM mara INTO l_mat_labor
         WHERE matnr = item-matnr.

        IF l_mat_labor NE c_labor.
            mmpur_message_forced 'E'
                                 c_zmm
                                 c_000
                                 'Material'
                                 item-matnr
                                 'is not Market List type material'
                                 space.

            CH_FAILED = 'X'.                "Prevent PO from being saved
*            EXIT.


        ENDIF.

      ELSE.       "Free Text Material

*           Display Message
            mmpur_message_forced 'E'
                                 c_zmm
                                 c_000
                                 'Item' item-EBELP
                                 'Free text material is not allowed'
                                 'on Market List type PR'.
            CH_FAILED = 'X'.                "Prevent PO from being saved
*            EXIT.

      ENDIF.

    ENDIF.

  ENDLOOP.

endmethod.


method IF_EX_ME_PROCESS_PO_CUST~CLOSE.
endmethod.


method IF_EX_ME_PROCESS_PO_CUST~FIELDSELECTION_HEADER.
endmethod.


method IF_EX_ME_PROCESS_PO_CUST~FIELDSELECTION_HEADER_REFKEYS.
endmethod.


method IF_EX_ME_PROCESS_PO_CUST~FIELDSELECTION_ITEM.
*  break zdevams.
*
*  FIELD-SYMBOLS: <fs> LIKE LINE OF CH_FIELDSELECTION.
*
*  LOOP AT CH_FIELDSELECTION ASSIGNING <fs>.
*    <fs>-fieldstatus = '.'.
*  ENDLOOP.

endmethod.


method IF_EX_ME_PROCESS_PO_CUST~FIELDSELECTION_ITEM_REFKEYS.
endmethod.


method IF_EX_ME_PROCESS_PO_CUST~INITIALIZE.
endmethod.


method IF_EX_ME_PROCESS_PO_CUST~OPEN.
endmethod.


method IF_EX_ME_PROCESS_PO_CUST~POST.
endmethod.


method IF_EX_ME_PROCESS_PO_CUST~PROCESS_ACCOUNT.
endmethod.


method IF_EX_ME_PROCESS_PO_CUST~PROCESS_HEADER.
endmethod.


method IF_EX_ME_PROCESS_PO_CUST~PROCESS_ITEM.
*>>> CR #20 - Enhancement to force Short Text (Master data description) on screen ME22N.
*    Created by Ramses on 11.09.2013  - START   P30K905872

*  break zdevams.

  DATA: lwa_mepoitem      TYPE mepoitem,
        lv_txz01          TYPE TXZ01.
*        lwa_mepoitemx     TYPE mepoitemx.

    "Get PO item data
    lwa_mepoitem = im_item->get_data( ).

    "Overwrite value only if item has Material Number
    CHECK lwa_mepoitem-MATNR IS NOT INITIAL.

    "Lookup Material Text from Material master
    SELECT SINGLE maktx FROM makt
      INTO lv_txz01
     WHERE matnr = lwa_mepoitem-MATNR
       AND spras = sy-langu.

    IF sy-subrc = 0.

      IF lv_txz01 NE lwa_mepoitem-TXZ01.

*       lwa_mepoitemx-TXZ01 = 'X'.

*       im_item->set_datax( EXPORTING im_datax = lwa_mepoitemx ).

       "Set updated data
       lwa_mepoitem-TXZ01 = lv_txz01.
       im_item->set_data( EXPORTING im_data = lwa_mepoitem ).

       "Log notification message
       INCLUDE mm_messages_mac.
       mmpur_message_forced 'I' 'ZMM' '000' 'Short text has been replaced' '' '' ''.

      ENDIF.

    ENDIF.

*<<< End of Enhancement -   End
endmethod.


method IF_EX_ME_PROCESS_PO_CUST~PROCESS_SCHEDULE.
endmethod.
ENDCLASS.
