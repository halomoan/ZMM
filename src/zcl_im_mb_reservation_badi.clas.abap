class ZCL_IM_MB_RESERVATION_BADI definition
  public
  final
  create public .

*"* public components of class ZCL_IM_MB_RESERVATION_BADI
*"* do not include other source files here!!!
public section.

  interfaces IF_EX_MB_RESERVATION_BADI .
protected section.
*"* protected components of class ZCL_IM_MB_RESERVATION_BADI
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_IM_MB_RESERVATION_BADI
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_IM_MB_RESERVATION_BADI IMPLEMENTATION.


METHOD if_ex_mb_reservation_badi~data_check.
  DATA : v_xwaok TYPE resb-xwaok,
         v_wempf TYPE rkpf-wempf,
         wa_resb TYPE resb.
  CLEAR : v_xwaok,v_wempf,wa_resb.

  CHECK is_resb-xloek <> 'X'.
  CHECK is_resb-kzear <> 'X'. "P30K903126
  IF sy-tcode = 'MB22'.
    SELECT SINGLE * INTO wa_resb FROM resb WHERE rsnum = is_rkpf-rsnum
                                             AND rspos = is_resb-rspos.
    IF wa_resb = is_resb.
      EXIT.
    ELSE.
*Allow Text changes only when no change in qty
      IF wa_resb-sgtxt <> is_resb-sgtxt.
        IF wa_resb-erfmg = is_resb-erfmg.
          EXIT.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

*If Reservation is not rejected
  SELECT SINGLE wempf INTO v_wempf FROM rkpf WHERE rsnum = is_rkpf-rsnum.
  IF v_wempf = 'REJ'.
*if not approved yet then check authorisation to approve
    IF is_resb-xwaok = 'X'.
      AUTHORITY-CHECK OBJECT 'ZMOV_CNTRL' ID 'ACTVT' DUMMY.
      IF sy-subrc = 0.
      ELSE.
*if no authorisation then raise error
        MESSAGE e002(zmm) RAISING external_message.
      ENDIF.
    ENDIF.
  ELSE.
    SELECT SINGLE xwaok INTO v_xwaok FROM resb WHERE rsnum = is_rkpf-rsnum
                                                 AND xwaok <> space.
*                                                 AND rspos = is_resb-rspos.
*if already approved then raise error message
    IF v_xwaok = 'X'.
      MESSAGE e003(zmm) RAISING external_message.
    ENDIF.

*Check if already approved
    IF sy-tcode <> 'MB21'.
      IF i_new_item = 'X' AND v_xwaok = 'X'.
        MESSAGE e004(zmm) RAISING external_message.
      ENDIF.
    ENDIF.

*if not approved yet then check authorisation to approve
    IF is_resb-xwaok = 'X'.
      AUTHORITY-CHECK OBJECT 'ZMOV_CNTRL' ID 'ACTVT' DUMMY.
      IF sy-subrc = 0.
      ELSE.
*if no authorisation then raise error
        MESSAGE e002(zmm) RAISING external_message.
      ENDIF.
    ENDIF.
  ENDIF.


ENDMETHOD.


method IF_EX_MB_RESERVATION_BADI~DATA_MODIFY.

endmethod.
ENDCLASS.
