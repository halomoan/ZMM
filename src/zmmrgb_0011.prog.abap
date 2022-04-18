*&---------------------------------------------------------------------*
*& Report ZMMRGB_0011
*&---------------------------------------------------------------------*
*& Requestor: Sun, Wu
*&---------------------------------------------------------------------*
*& Description:
*&   - ZMMRGB_0011 Reservation printout (TCode ZMM_0033)
*&---------------------------------------------------------------------*
*& Related object:
*&   - ZMMRGB_0003 Reservation program (TCode ZMM_0003)
*&---------------------------------------------------------------------*
*& NO    DATE        TR           DEVELOPER
*& 0001  2021.10.26  P30K914115   Adhimas (asetianegara@deloitte.com)
*&   - Initial version
*&---------------------------------------------------------------------*
REPORT zmmrgb_0011.

TABLES: resb.
DATA: gt_reservation TYPE zmmty_reservation_prn.

SELECT-OPTIONS:
  s_rsnum FOR resb-rsnum OBLIGATORY.

START-OF-SELECTION.
  PERFORM f_select.
  PERFORM f_preview.


FORM f_select.
  "-- core data
  SELECT rsnum, umlgo, kostl, bwart, usnam, rsdat
    FROM rkpf
    WHERE rsnum IN @s_rsnum
    INTO TABLE @DATA(lt_header).

  IF lt_header IS INITIAL.
    MESSAGE 'Reservations not found' TYPE 'E'.
  ENDIF.

  SORT lt_header BY rsnum.

  SELECT rsnum, rspos, werks, matnr, meins, bdmng, bdter, lgort, enmng, ablad, sgtxt
    FROM resb
    WHERE rsnum IN @s_rsnum
      AND xwaok NE @space         "approved?
      AND enmng EQ 0              "any quantity has been transferred/issued?
      AND xloek EQ @abap_false    "deleted?
    INTO TABLE @DATA(lt_detail).

  IF lt_detail IS INITIAL.
    MESSAGE 'Reservations can''t be printed' TYPE 'E'.
  ENDIF.

  SORT lt_detail BY rsnum rspos.

  "-- supporting data
  SELECT werks, name1
    FROM t001w
    FOR ALL ENTRIES IN @lt_detail
    WHERE werks = @lt_detail-werks
    INTO TABLE @DATA(lt_plant).

  SORT lt_plant BY werks.

  SELECT kostl, ktext
    FROM cskt
    FOR ALL ENTRIES IN @lt_header
    WHERE spras = @sy-langu
      AND kokrs = '1000'
      AND kostl = @lt_header-kostl
    INTO TABLE @DATA(lt_costcenter).

  SORT lt_costcenter BY kostl.

  SELECT matnr, maktx
    FROM makt
    FOR ALL ENTRIES IN @lt_detail
    WHERE matnr = @lt_detail-matnr
      AND spras = @sy-langu
    INTO TABLE @DATA(lt_material).

  SORT lt_material BY matnr.

  SELECT DISTINCT bwart, btext
    FROM t156t
    FOR ALL ENTRIES IN @lt_header
    WHERE spras = @sy-langu
      AND bwart = @lt_header-bwart
    INTO TABLE @DATA(lt_mv_type).

  SORT lt_mv_type BY bwart.

  DATA lwa_reservation TYPE zmm_reservation_prn.
  DATA lwa_reservation_itm TYPE zmm_reservation_itm.

  REFRESH gt_reservation.

  LOOP AT lt_header INTO DATA(lwa_hdr).
    LOOP AT lt_detail INTO DATA(lwa_itm) WHERE rsnum = lwa_hdr-rsnum.
      MOVE-CORRESPONDING lwa_itm TO lwa_reservation_itm.
      READ TABLE:
        lt_material INTO DATA(lwa_material) WITH KEY matnr = lwa_itm-matnr BINARY SEARCH.

      lwa_reservation_itm-maktx = lwa_material-maktx.
      APPEND lwa_reservation_itm TO lwa_reservation-items.

      CLEAR: lwa_material.
    ENDLOOP.

    IF sy-subrc EQ 0.
      MOVE-CORRESPONDING lwa_hdr TO lwa_reservation.
      READ TABLE:
        lt_plant INTO DATA(lwa_plant) WITH KEY werks = lwa_itm-werks BINARY SEARCH,             "plant is taken from last item
        lt_costcenter INTO DATA(lwa_costcenter) WITH KEY kostl = lwa_hdr-kostl BINARY SEARCH,
        lt_mv_type INTO DATA(lwa_mv_type) WITH KEY bwart = lwa_hdr-bwart BINARY SEARCH.

      lwa_reservation-name1 = lwa_plant-name1.
      lwa_reservation-ktext = lwa_costcenter-ktext.
      lwa_reservation-btext = lwa_mv_type-btext.
      lwa_reservation-requestedby_usnam = lwa_hdr-usnam.
      lwa_reservation-requestedby_budat = lwa_hdr-rsdat.
      lwa_reservation-approvedby_usnam = lwa_itm-ablad.       "approver name is taken from last item
      lwa_reservation-approvedby_budat = lwa_itm-sgtxt(8).    "approved date is taken from last item
      APPEND lwa_reservation TO gt_reservation.
    ENDIF.

    CLEAR: lwa_plant, lwa_costcenter, lwa_mv_type, lwa_reservation, lwa_itm.
  ENDLOOP.

ENDFORM.


FORM f_preview.
  CONSTANTS lc_form_name TYPE tdsfname VALUE 'ZMMRGB_RESERVATION'.
  DATA lv_fm_name TYPE rs38l_fnam.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname = lc_form_name
    IMPORTING
      fm_name  = lv_fm_name
*   EXCEPTIONS
*     NO_FORM  = 1
*     NO_FUNCTION_MODULE       = 2
*     OTHERS   = 3
    .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  DATA lv_page_count TYPE i.
  DATA lv_page_number TYPE i.
  DATA lwa_opt TYPE ssfcompop.
  DATA lwa_ctrl TYPE ssfctrlop.
  DATA lv_record_count TYPE i.

  lv_page_count = lines( gt_reservation ).
  lwa_ctrl-no_open = abap_false.

  LOOP AT gt_reservation INTO DATA(lwa_reservation).
    lv_page_number = sy-tabix.
    lwa_ctrl-no_close = COND #(
      WHEN lv_page_number EQ lv_page_count THEN abap_false
      ELSE abap_true ).

    CALL FUNCTION lv_fm_name
      EXPORTING
        control_parameters = lwa_ctrl
        output_options     = lwa_opt
        i_reservation      = lwa_reservation
        i_page_number      = lv_page_number
        i_page_count       = lv_page_count.

    lwa_ctrl-no_open = abap_true.
  ENDLOOP.

ENDFORM.
