class Z_MM_POITEM definition
  public
  final
  create public .

public section.

  data BOX_CONVERSION type UMREZ .
  data DELIVERY_DATE type DATUM .
  data DELIVERY_PLANT type WERKS_D .
  data LAST_NET_PRICE type NETPR .
  data LAST_ORDER_DATE type DATUM .
  data MATERIAL type TXZ01 .
  data NET_PRICE type NETPR .
  data NET_VALUE type NETWR .
  data PO_ITEM type EBELP .
  data PO_NUMBER type EBELN .
  data QUANTITY type MENGE_D .
  data UNIT type MEINS .
  data ITEMTEXT type STRING .
  data MATERIAL_ID type MATNR .

  methods CONSTRUCTOR
    importing
      !I_PONUMBER type EBELN
      !I_POITEM type EBELP .
protected section.
private section.
ENDCLASS.



CLASS Z_MM_POITEM IMPLEMENTATION.


method CONSTRUCTOR.
    DATA: lv_matid TYPE TDOBNAME,
          lv_string TYPE STRING.
    DATA: LINES TYPE STANDARD TABLE OF TLINE.

    FIELD-SYMBOLS: <ls_lines> TYPE TLINE.

    me->po_number = i_ponumber.
    me->po_item = i_poitem.

    select single Matnr TXZ01 menge meins umrez netpr netwr werks
            from ekpo
            into (me->material_id, me->material, me->quantity, me->unit, me->box_conversion, me->net_price, me->net_value, me->delivery_plant)
            where ebeln = i_ponumber and
                  ebelp = i_poitem.

    check sy-subrc = 0.
    select single EINDT from eket into me->delivery_date where ebeln = i_ponumber and ebelp = i_poitem.

    CONCATENATE i_ponumber i_poitem INTO lv_matid.

    CALL FUNCTION 'READ_TEXT'
      EXPORTING
*       CLIENT                        = SY-MANDT
        ID                            = 'F01'
        LANGUAGE                      = sy-langu
        NAME                          =  lv_matid
        OBJECT                        = 'EKPO'
*       ARCHIVE_HANDLE                = 0
*       LOCAL_CAT                     = ' '
*     IMPORTING
*       HEADER                        =
*       OLD_LINE_COUNTER              =
      TABLES
        LINES                         = LINES
     EXCEPTIONS
       ID                            = 1
       LANGUAGE                      = 2
       NAME                          = 3
       NOT_FOUND                     = 4
       OBJECT                        = 5
       REFERENCE_CHECK               = 6
       WRONG_ACCESS_TO_ARCHIVE       = 7
       OTHERS                        = 8.
    IF SY-SUBRC eq 0.

      CLEAR lv_string.
      LOOP AT LINES ASSIGNING <ls_lines>.
          CONCATENATE lv_string  <ls_lines> INTO lv_string SEPARATED BY space.
      ENDLOOP.

      me->itemtext = lv_string.
    ENDIF.

endmethod.
ENDCLASS.
