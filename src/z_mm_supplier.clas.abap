class Z_MM_SUPPLIER definition
  public
  final
  create public .

public section.

  data ADDRESS type STRING .
  data EMAIL type STRING .
  data NAME type NAME1_GP .
  data SUPPLIER_ID type LIFNR .
  data TELEPHONE type STRING .

  methods CONSTRUCTOR
    importing
      !ID type LIFNR .
protected section.
private section.
ENDCLASS.



CLASS Z_MM_SUPPLIER IMPLEMENTATION.


method CONSTRUCTOR.
    data: lv_ADRNR type ADRNR,
          lv_city  type AD_CITY1,
          lv_street type AD_STREET,
          lv_number type AD_TLNMBR1,
          lv_email type AD_SMTPADR.

    me->supplier_id = id.
    select single name1 stras ADRNR from lfa1 into (me->name, lv_street, lv_ADRNR) where lifnr = id.

    select single city1 tel_number into (lv_city, lv_number)
            from ADRC
            where ADDRNUMBER = lv_adrnr and
                 date_from < sy-datum and
                 date_to > sy-datum.

    if sy-subrc = 0.
      CONCATENATE lv_street ',' lv_city into me->address.
      me->telephone = lv_number.
    endif.

    select single SMTP_ADDR from ADR6 into (lv_email)
        where ADDRNUMBER = lv_adrnr.
    If sy-subrc = 0.
      me->email = lv_email.
    endif.
endmethod.
ENDCLASS.
