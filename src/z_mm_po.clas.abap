class Z_MM_PO definition
  public
  final
  create public .

public section.

  data ADVANCE_PERCENTAGE type INT4 .
  data COMMENTS type STRING .
  data CREATION_DATE type DATUM .
  data CURRENCY type WAERS .
  data INCOTERMS type TEXT20 .
  data PO_NUMBER type EBELN .
  data TOTAL_VALUE type NETWR .

  methods CONSTRUCTOR
    importing
      !I_PONUMBER type EBELN .
  methods GET_CREATED_BY
    returning
      value(RETURN) type TEXT40 .
  methods GET_DEST_PLANT_TEXT
    returning
      value(RETURN) type STRING .
  methods GET_ITEMS
    returning
      value(RETURN) type ZMM_POITEMS .
  methods GET_PAYMENT_TERM_TEXT
    returning
      value(RETURN) type STRING .
  class-methods GET_PENDING_APPROVAL
    returning
      value(RETURN) type ZMM_POS .
  methods GET_PGROUP_TEXT
    returning
      value(RETURN) type STRING .
  methods GET_STATUS
    returning
      value(RETURN) type CHAR2 .
  methods GET_SUPPLIER
    returning
      value(RETURN) type ref to Z_MM_SUPPLIER .
  methods SET_APPROVAL
    returning
      value(RETURN) type BAPIRET2 .
  methods SET_REJECTED
    returning
      value(RETURN) type BAPIRET2 .
protected section.
private section.

  types ITEMS type ref to Z_MM_POITEM .

  data COMPANY type BUKRS .
  data CREATED_BY type UNAME .
  data DESTINATION_PLANT type WERKS_D .
  data PAYMENT_TERMS type DZTERM .
  data PURCHASING_GROUP type EKORG .
  data STATUS type CHAR2 .

  methods GET_RELEASE_CODE
    returning
      value(RETURN) type FRGCO .
ENDCLASS.



CLASS Z_MM_PO IMPLEMENTATION.


method CONSTRUCTOR.
   data: lw_ekko type ekko,
          lv_inco1 type inco1,
          lv_inco2 type inco2,
          lt_werks type table of werks_d,
          lv_werks type werks_d,
          lv_lines type int4.

    select single k~ebeln k~dpamt k~ekgrp k~waers k~bukrs k~inco1 k~inco2 k~aedat k~zterm k~ernam sum( p~netwr )
            from ekko as k inner join ekpo as p
            on k~ebeln = p~ebeln
            into (me->po_number, me->advance_percentage, me->purchasing_group, me->currency,
                  me->company, lv_inco1, lv_inco2, me->creation_date, me->payment_terms, me->created_by, me->total_value)
           where k~ebeln = i_ponumber and p~LOEKZ = ''
           group by k~ebeln k~dpamt k~ekgrp k~waers k~bukrs k~inco1 k~inco2 k~aedat k~zterm k~ernam.

    check sy-subrc = 0.
    concatenate lv_inco1 lv_inco2 into me->incoterms separated by space.

    select DISTINCT werks from ekpo into table lt_werks where ebeln = i_ponumber.

    DESCRIBE TABLE lt_werks lines lv_lines.
    if lv_lines = 1. "If there is only one plant, fill the attribute.
      read table lt_werks into lv_werks index 1.
      me->destination_plant = lv_werks.
    endif.

    CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
      EXPORTING
        CURRENCY              = me->currency
        AMOUNT_INTERNAL       = me->total_value
      IMPORTING
        AMOUNT_DISPLAY        = me->total_value
     EXCEPTIONS
       INTERNAL_ERROR        = 1
       OTHERS                = 2
              .
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.

    me->comments = '....'. " You must change this according to your own text schema.
endmethod.


method GET_CREATED_BY.
   select single p~name_text from usr21 as k inner join adrp as p
              on k~persnumber = p~persnumber
             into return
            where k~bname = me->created_by.

endmethod.


method GET_DEST_PLANT_TEXT.
  return = me->destination_plant.
endmethod.


method GET_ITEMS.
  data: lv_ebeln type ebeln, lv_ebelp type ebelp,
          lx_poitem type ref to z_mm_poitem.

    select ebeln ebelp from ekpo into (lv_ebeln, lv_ebelp)
              where ebeln = me->po_number and LOEKZ = ''.
      create object lx_poitem
        exporting
          i_ponumber = lv_ebeln
          i_poitem = lv_ebelp.
      append lx_poitem to return.
    endselect.

endmethod.


method GET_PAYMENT_TERM_TEXT.
  return = me->payment_terms.
endmethod.


method GET_PENDING_APPROVAL.
* This method uses an authorization based filter, to stop the user
* from having to input a specific release code. The system just checks
* for every release code the current user can use, and retrieves the POs that can
* be actionable with those release codes.

* The code used to retrieve the relevant POs is inspired by ME28.


DATA: it_zpogr TYPE STANDARD TABLE OF zzpogrp,
      lx_po    type ref to z_mm_po.

FIELD-SYMBOLS: <ls_line> TYPE zzpogrp.

CALL FUNCTION 'Z_PORELGRP'
EXPORTING
  uname              = sy-uname
TABLES
  it_ekpo            = it_zpogr
EXCEPTIONS
  rel_code_not_found = 1
  rel_grp_not_found  = 2
OTHERS             = 3.


IF sy-subrc EQ 0.
*Populate POs to S_EBELN
    LOOP AT it_zpogr ASSIGNING <ls_line>.
      create object lx_po
            exporting
              i_ponumber = <ls_line>-ebeln.
       "append lx_po to return.
       insert lx_po into return index 1.
    ENDLOOP.
ENDIF.
endmethod.


method GET_PGROUP_TEXT.
  select single EKNAM from T024 into return where ekgrp = me->purchasing_group.
endmethod.


method GET_RELEASE_CODE.
* This method uses an authorization based filter, to figure out which release code
* the current user would use if he was releasing the document in ME28. It assumes that at
* a given point, a user would only have one release code available for each PO, which makes
* sense for non-power users.

* The code used to retrieve the release code is inspired by ME28.
TYPES: BEGIN OF ty_ekko,
        ebeln TYPE ekko-ebeln,
        frgzu TYPE ekko-frgzu, "Release status
        frggr TYPE ekko-frggr, " Release grp
        frgsx TYPE ekko-frgsx,  "Release Strategy
      END OF ty_ekko,
      BEGIN OF ty_t16fs,
         frggr TYPE frggr,
         frgsx TYPE frgsx,
         frgc1 TYPE frgco,
         frgc2 TYPE frgco,
         frgc3 TYPE frgco,
         frgc4 TYPE frgco,
         frgc5 TYPE frgco,
         frgc6 TYPE frgco,
         frgc7 TYPE frgco,
         frgc8 TYPE frgco,
        END OF ty_t16fs,
        BEGIN OF ty_release,
          r1    TYPE t16fs-frgc1,
          st1   TYPE char1,
          r2    TYPE t16fs-frgc1,
          st2   TYPE char1,
          r3    TYPE t16fs-frgc1,
          st3   TYPE char1,
          r4    TYPE t16fs-frgc1,
          st4   TYPE char1,
          r5    TYPE t16fs-frgc1,
          st5   TYPE char1,
          r6    TYPE t16fs-frgc1,
          st6   TYPE char1,
          r7    TYPE t16fs-frgc1,
          st7   TYPE char1,
          r8    TYPE t16fs-frgc1,
          st8   TYPE char1,
        END OF ty_release.

DATA: ls_ekko TYPE ty_ekko,
      ls_t16fs TYPE ty_t16fs,
      ls_release TYPE ty_release,
      ls_relcode TYPE frgco.

SELECT SINGLE ebeln frgzu frggr frgsx INTO ls_ekko FROM ekko WHERE ebeln = po_number.

*Fetch Release codes
SELECT SINGLE frggr
         frgsx
         frgc1
         frgc2
         frgc3
         frgc4
         frgc5
         frgc6
         frgc7
         frgc8
   FROM t16fs
   INTO ls_t16fs
   WHERE frggr = ls_ekko-frggr
   AND   frgsx = ls_ekko-frgsx.

IF sy-subrc = 0.
*Check for appropriate levels and populate in the work area
*R1
      IF ls_t16fs-frgc1 IS NOT INITIAL.
*Store release code
        ls_release-r1 = ls_t16fs-frgc1.
*Store release status
        ls_release-st1 = ls_ekko-frgzu+0(1).
        IF ls_release-st1 ne 'X'.
          ls_relcode = ls_release-r1.
          CLEAR ls_t16fs.
        ENDIF.
      ENDIF.
*R2
      IF ls_t16fs-frgc2 IS NOT INITIAL.
*Store release code
        ls_release-r2 = ls_t16fs-frgc2.
*Store release status
        ls_release-st2 = ls_ekko-frgzu+1(1).
        IF ls_release-st2 ne 'X'.
          ls_relcode = ls_release-r2.
          CLEAR ls_t16fs.
        ENDIF.
      ENDIF.

*R3
      IF ls_t16fs-frgc3 IS NOT INITIAL.
*Store release code
        ls_release-r3 = ls_t16fs-frgc3.
*Store release status
        ls_release-st3 = ls_ekko-frgzu+2(1).
        IF ls_release-st3 ne 'X'.
          ls_relcode = ls_release-r3.
          CLEAR ls_t16fs.
        ENDIF.
      ENDIF.

*R4
      IF ls_t16fs-frgc4 IS NOT INITIAL.
*Store release code
        ls_release-r4 = ls_t16fs-frgc4.
*Store release status
        ls_release-st4 = ls_ekko-frgzu+3(1).
        IF ls_release-st4 ne 'X'.
          ls_relcode = ls_release-r4.
          CLEAR ls_t16fs.
        ENDIF.
      ENDIF.

*R5
      IF ls_t16fs-frgc5 IS NOT INITIAL.
*Store release code
        ls_release-r5 = ls_t16fs-frgc5.
*Store release status
        ls_release-st5 = ls_ekko-frgzu+4(1).
        IF ls_release-st5 ne 'X'.
          ls_relcode = ls_release-r5.
          CLEAR ls_t16fs.
        ENDIF.
      ENDIF.

*R6
      IF ls_t16fs-frgc6 IS NOT INITIAL.
*Store release code
        ls_release-r6 = ls_t16fs-frgc6.
*Store release status
        ls_release-st6 = ls_ekko-frgzu+5(1).
        IF ls_release-st6 ne 'X'.
          ls_relcode = ls_release-r6.
          CLEAR ls_t16fs.
        ENDIF.
      ENDIF.

*R7
      IF ls_t16fs-frgc7 IS NOT INITIAL.
*Store release code
        ls_release-r7 = ls_t16fs-frgc7.
*Store release status
        ls_release-st7 = ls_ekko-frgzu+6(1).
        IF ls_release-st7 ne 'X'.
          ls_relcode = ls_release-r7.
          CLEAR ls_t16fs.
        ENDIF.
      ENDIF.
*R8
      IF ls_t16fs-frgc8 IS NOT INITIAL.
*Store release code
        ls_release-r8 = ls_t16fs-frgc8.
*Store release status
        ls_release-st8 = ls_ekko-frgzu+7(1).
        ls_relcode = ls_release-r8.
        CLEAR ls_t16fs.
      ENDIF.

  RETURN = ls_relcode.
ENDIF.

endmethod.


method GET_STATUS.
   DATA: lv_status TYPE MEPROCSTATE.

   SELECT SINGLE PROCSTAT INTO lv_status FROM EKKO WHERE EBELN = po_number.
   IF sy-subrc = 0.
     IF lv_status = '03'.
       return = 'P'.
     ELSEIF lv_status = '08'.
       return = 'R'.
     ENDIF.
   ENDIF.
endmethod.


method GET_SUPPLIER.
  data: lv_lifnr type lifnr.

    select single lifnr from ekko into lv_lifnr where ebeln = po_number.
    create object return
     EXPORTING
       id = lv_lifnr.
endmethod.


method SET_APPROVAL.
   data: lt_return type table of bapireturn,
          lw_return type bapireturn,
          l_rel_code TYPE FRGCO.

    l_rel_code = me->get_release_code( ).

    call function 'BAPI_PO_RELEASE'
      exporting
        purchaseorder          = me->po_number
        po_rel_code            = l_rel_code
        use_exceptions         = 'X'
      tables
        return                 = lt_return
      exceptions
        authority_check_fail   = 1
        document_not_found     = 2
        enqueue_fail           = 3
        prerequisite_fail      = 4
        release_already_posted = 5
        responsibility_fail    = 6
        others                 = 7.
    loop at lt_return into lw_return where type = 'E'.
      return = lw_return-message.
    endloop.
    commit work and wait.
endmethod.


method SET_REJECTED.
     data: lc_po       type ref to cl_po_header_handle_mm,
          ls_document type mepo_document.

*  prepare creation of PO instance
    ls_document-doc_type    = 'F'.
    ls_document-process     = mmpur_po_process.
    ls_document-trtyp       = 'V'.
    ls_document-doc_key(10) = me->po_number.
    ls_document-initiator-initiator = mmpur_initiator_rel.

*  object creation and initialization
    create object lc_po.
    lc_po->for_bapi = 'X'.
    call method lc_po->po_initialize( im_document = ls_document ).
    call method lc_po->set_po_number( im_po_number = me->po_number ).
    call method lc_po->set_state( cl_po_header_handle_mm=>c_available ).

*  read purchase order from database
    call method lc_po->po_read
      exporting
        im_tcode     = 'ME29N'
        im_trtyp     = ls_document-trtyp
        im_aktyp     = ls_document-trtyp
        im_po_number = po_number
        im_document  = ls_document.

    if lc_po->if_releasable_mm~is_rejection_allowed( ) = 'X'.
      call method lc_po->if_releasable_mm~reject
        exporting
          im_reset = space
        exceptions
          failed   = 1
          others   = 2.
      if sy-subrc <> 0.
        return-type = 'E'.
        return.
      endif.
    endif.

    call method lc_po->po_post
      exceptions
        failure = 1
        others  = 2.
endmethod.
ENDCLASS.
