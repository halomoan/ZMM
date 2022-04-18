*&---------------------------------------------------------------------*
*&  Include           ZXM08U16
*&---------------------------------------------------------------------*
*DATA : it_lfbk TYPE STANDARD TABLE OF lfbk.
*DATA : rcount TYPE sy-tabix.
*INCLUDE mm_messages_mac.
*CLEAR: it_lfbk[],rcount.
*SELECT * INTO TABLE it_lfbk FROM lfbk WHERE lifnr = e_trbkpv-lifnr.
*DESCRIBE TABLE it_lfbk LINES rcount.
**if multiple bank details are maintained for Vendor/Supplier then turn Partner bank type to mandatory
*IF rcount > 1 AND e_trbkpv-bvtyp IS INITIAL.
*  mmpur_message_forced 'E' 'ZMM' '000' 'Please Select & enter ' 'partner bank type' '' ''.
*ENDIF.
