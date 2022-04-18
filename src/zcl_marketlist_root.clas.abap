class ZCL_MARKETLIST_ROOT definition
  public
  final
  create public
  shared memory enabled .

public section.

  interfaces IF_SHM_BUILD_INSTANCE .

  methods GET_MKLISTDETAIL
    importing
      !KOSTL type KOSTL
      !PLANT type WERKS_D
      !ABLAD type ABLAD
    exporting
      !E_TABLE type ZMM_TMKTLISTDETAIL .
  methods SET_MKLISTDETAIL
    importing
      !KOSTL type KOSTL
      !PLANT type WERKS_D
      !ABLAD type ABLAD .
protected section.
private section.

  types:
    BEGIN OF TY_MKTLISTDETAIL.
       TYPES:
          KOSTL type KOSTL,
          PLANT type WERKS_D,
          ABLAD type ABLAD.
      INCLUDE TYPE  ZMM_MKTLISTDETAIL.
    TYPES  END OF TY_MKTLISTDETAIL .

  data:
    MKLISTDETAIL type STANDARD TABLE OF TY_MKTLISTDETAIL .
ENDCLASS.



CLASS ZCL_MARKETLIST_ROOT IMPLEMENTATION.


  method GET_MKLISTDETAIL.

    SELECT * FROM @MKLISTDETAIL as MATERIAL_LIST
      WHERE KOSTL = @KOSTL AND PLANT = @PLANT AND ABLAD = @ABLAD
      INTO CORRESPONDING FIELDS OF TABLE @E_TABLE.

  endmethod.


  method IF_SHM_BUILD_INSTANCE~BUILD.

    DATA: area TYPE REF TO ZCL_MARKETLIST_AREA,
          root TYPE REF TO ZCL_MARKETLIST_ROOT,
          excep TYPE REF TO CX_ROOT.

    TRY.
      area = ZCL_MARKETLIST_AREA=>ATTACH_FOR_WRITE( ).
    CATCH cx_shm_error INTO excep.
      RAISE EXCEPTION TYPE cx_shm_build_failed
        EXPORTING
          previous = excep.
    ENDTRY.

    CREATE OBJECT root AREA HANDLE area.

    area->set_root( root ).
    area->detach_commit( ).

  endmethod.


  method SET_MKLISTDETAIL.
    types:
    begin of ty_eord,
      matnr type eord-matnr,
      lifnr type eord-lifnr,
      vdatu type eord-vdatu,
      bdatu type eord-bdatu,
    end of ty_eord,
    begin of ty_eina,
      matnr type eina-matnr,
      lifnr type eina-lifnr,
      ekorg type eine-ekorg,
      werks type eine-werks,
      minbm type eine-minbm, " Minimum Order Qty
      meins type eina-meins, " Minimm Order Unit
    end of ty_eina,
    begin of ty_a018,
      ekorg type eine-ekorg,
      werks type eine-werks,
      lifnr type a018-lifnr,
      matnr type a018-matnr,
      knumh type a018-knumh,
      datbi type a018-datbi,
      esokz type a018-esokz,
    end of ty_a018,
    begin of ty_konp,
      knumh    type konp-knumh,
      kbetr    type konp-kbetr,
      kpein    type konp-kpein,
      kmein    type konp-kmein,
      loevm_ko type konp-loevm_ko,
    end of ty_konp,
    begin of ty_T006,
      msehi  type t006-msehi,
      andec  type t006-andec,
    end of ty_T006.

  data:
    l_tmplpreqno     type banfn,
    l_showvendor     type c length 1,
    l_date           type datum,
    l_startdate      type datum,
    l_enddate        type datum,
    l_counter        type i,
    l_toBaseUnit     type meins,
    l_country        type t001-land1,
    p_intval         type wmto_s-amount,   "Internal Amount
    gd_disval        type wmto_s-amount, "Display Amount
    l_EBELN          type eban-ebeln,
    l_MATNR          type marc-matnr,
    l_MAKTX          type makt-maktx,
    l_WAERS          type eine-waers,
    l_MENGE          type ekpo-menge,
    l_PRICEUNIT      type eine-peinh, "Price Unit
    l_BASEDUNIT      type mara-meins, "Based Unit
    l_ORDERPRICEUNIT type mara-meins, "Order Unit
    l_UNITOFPRICE    type meins.

  data: lt_marc type  zmm_tmktmaterial.

  data: lt_auth_purchorg type standard table of usvalues,
        ls_auth_purchorg type usvalues.

  data: lt_auth_plant type standard table of usvalues,
        ls_auth_plant type usvalues.


  data: lt_EORD  type standard table of ty_eord with default key,
        ls_EORD  like line of lt_EORD,
        lt_EINA  TYPE SORTED TABLE OF  ty_eina WITH NON-UNIQUE KEY matnr lifnr,
        ls_EINA  like line of lt_EINA,
        lt_KNUMH type standard table of ty_a018 with default key,
        ls_KNUMH like line of lt_KNUMH,
        lt_KONP  TYPE SORTED TABLE OF ty_konp WITH NON-UNIQUE KEY KNUMH KBETR,
        ls_konp  like line of lt_KONP,
        lt_T006  type standard table of ty_T006,
        ls_T006  like line of lt_T006,
        ls_T024W type t024w.

  data:   ra_LIFNR type range of eord-lifnr,
          rs_LIFNR like line of ra_lifnr,
          ra_KNUMH type range of a018-knumh,
          rs_KNUMH like line of ra_knumh,
          ra_matnr type range of marc-matnr,
          rs_matnr like line of ra_matnr.

  data: r_purchorg  type range of eine-ekorg,
        wr_purchorg like line of r_purchorg,
        r_trxid     type range of sy-datum,
        wr_trxid    like line of r_trxid,
        r_autopo    type range of char4.



   data: ls_mmlist type zmm_mktlistdetail,
         ls_MKLISTDETAIL TYPE TY_MKTLISTDETAIL.



  field-symbols: <ls_material> type zmm_mktlistdetail,
                 <ls_marc>     like line of lt_marc,
                 <l_field>     type any.

  call function 'SUSR_USER_AUTH_FOR_OBJ_GET'
    exporting
      user_name           = sy-uname
      sel_object          = 'M_BANF_EKO'
    tables
      values              = lt_auth_purchorg
    exceptions
      user_name_not_exist = 1
      not_authorized      = 2
      internal_error      = 3
      others              = 4.

  if sy-subrc <> 0.
    exit.
  endif.

  call function 'SUSR_USER_AUTH_FOR_OBJ_GET'
    exporting
      user_name           = sy-uname
      sel_object          = 'M_BANF_WRK'
    tables
      values              = lt_auth_plant
    exceptions
      user_name_not_exist = 1
      not_authorized      = 2
      internal_error      = 3
      others              = 4.

  if sy-subrc <> 0.
    exit.
  endif.

  clear r_trxid.

  select msehi andec into table lt_T006 from t006.


  select single templtid, showvendor into ( @l_tmplpreqno, @l_showvendor ) from zmm_mktlist_map where plant = @plant and kostl = @kostl and ablad = @ablad.
  if sy-subrc ne 0 or l_tmplpreqno is initial.
    concatenate plant kostl+4 into l_tmplpreqno.
  endif.

  delete lt_auth_plant where field <> 'WERKS'.


  select single * into ls_T024W from t024w where werks = plant and ( ekorg = 'C103' or ekorg = 'C106' or ekorg = 'C108' ).
  if sy-subrc <> 0.
    select single * into ls_T024W from t024w where werks = plant and ekorg like 'P%'.
    if sy-subrc <> 0.
      exit.
    endif.
  endif.


  read table lt_auth_purchorg into ls_auth_purchorg with key von = ls_T024W-ekorg.
  if sy-subrc = 0.
    wr_purchorg-sign = 'I'.
    wr_purchorg-option = 'EQ'.
    wr_purchorg-low = ls_auth_purchorg-von.
    append wr_purchorg to r_purchorg.
  else.
    read table lt_auth_purchorg into ls_auth_purchorg with key field = 'EKORG' von = '*'.
    if sy-subrc = 0.
      wr_purchorg-sign = 'I'.
      wr_purchorg-option = 'EQ'.
      wr_purchorg-low = ls_T024W-ekorg.
      append wr_purchorg to r_purchorg.
    endif.
  endif.


  read table lt_auth_plant with key von = plant transporting no fields.
  if sy-subrc ne 0.
    read table lt_auth_plant with key von = '*' transporting no fields.
    if sy-subrc ne 0.
      exit.
    endif.
  endif.

*SELECT SINGLE LAND1 INTO l_country FROM T001W WHERE WERKS = PLANT.
*IF sy-subrc = 0.
*  SELECT SINGLE WAERS INTO l_WAERS FROM T001 WHERE LAND1 = l_country.
*ENDIF.

  if plant eq 'PPYG' or plant eq 'PYGN'.
    l_WAERS = 'MMK'.
  else.
    select single waers into l_WAERS from t001w inner join t001 on t001w~land1 = t001~land1 where werks = plant.
  endif.


  select sign opti low high into table r_autopo from tvarvc
    where name = 'ZMARKETLIST_AUTOPO'
    and type = 'S'.

  select distinct eord~flifn as fixed, marc~kautb, lfm1~kzaut,lfm1~ekorg, eord~meins as omein ,marc~matnr, mara~matkl, makt~maktx, mara~meins as lmein, eord~lifnr, lfa1~name1 as vdrname
 into corresponding fields of table @lt_marc
     from ( ( marc
            inner join mara
            on  mara~matnr = marc~matnr
            inner join makt
            on  makt~matnr = marc~matnr
            inner join mbew
            on marc~matnr = mbew~matnr and marc~werks = mbew~bwkey
            ) left join eord
            on marc~matnr = eord~matnr and marc~werks = eord~werks and eord~vdatu le @l_enddate and eord~bdatu ge @l_startdate )
            left join lfm1
            on eord~lifnr = lfm1~lifnr
            left join lfa1
            on eord~lifnr = lfa1~lifnr
          where marc~werks = @plant
        and mara~labor = '999'
            and mara~mstae = ''
            and marc~mmsta = ''
        and marc~lvorm <> 'X'
            and makt~spras = @sy-langu
        and makt~maktx not like 'ZZ%'

   order by marc~matnr ascending, eord~flifn descending, marc~kautb descending, lfm1~kzaut descending.



  select distinct 'I','EQ',marc~matnr
  into table @ra_matnr
      from ( ( marc
             inner join mara
             on  mara~matnr = marc~matnr
             inner join makt
             on  makt~matnr = marc~matnr
             inner join mbew
             on marc~matnr = mbew~matnr and marc~werks = mbew~bwkey
             ) left join eord
             "on MARC~MATNR = EORD~MATNR AND MARC~WERKS = EORD~WERKS AND EORD~VDATU LE @l_startdate AND EORD~BDATU GE @l_startdate )
             on marc~matnr = eord~matnr and marc~werks = eord~werks and eord~vdatu le @l_enddate and eord~bdatu ge @l_startdate )
             left join lfm1
             on eord~lifnr = lfm1~lifnr
           where marc~werks = @plant
         and mara~labor = '999'
             and mara~mstae = ''
             and marc~mmsta = ''
         and marc~lvorm <> 'X'
             and makt~spras = @sy-langu
         and makt~maktx not like 'ZZ%'.


  select distinct 'I','EQ',eord~lifnr
  into table @ra_lifnr
      from ( ( marc
             inner join mara
             on  mara~matnr = marc~matnr
             inner join makt
             on  makt~matnr = marc~matnr
             inner join mbew
             on marc~matnr = mbew~matnr and marc~werks = mbew~bwkey
             ) left join eord
             "on MARC~MATNR = EORD~MATNR AND MARC~WERKS = EORD~WERKS AND EORD~VDATU LE @l_startdate AND EORD~BDATU GE @l_startdate )
             on marc~matnr = eord~matnr and marc~werks = eord~werks and eord~vdatu le @l_enddate and eord~bdatu ge @l_startdate )
             left join lfm1
             on eord~lifnr = lfm1~lifnr
           where marc~werks = @plant
         and mara~labor = '999'
             and mara~mstae = ''
             and marc~mmsta = ''
         and marc~lvorm <> 'X'
             and makt~spras = @sy-langu
         and makt~maktx not like 'ZZ%'.


  select eord~matnr, eord~lifnr,eord~vdatu,eord~bdatu into table @lt_EORD
    from eord
    where werks = @plant and lifnr in @ra_lifnr and flifn = 'X'
    order by matnr.

  if lt_marc[] is initial.
    exit.
  endif.

  "DELETE lt_marc WHERE MATNR <> '000000001000013493'.
  "DELETE ra_matnr WHERE LOW <> '000000001000013493'.
  delete lt_marc where lifnr is not initial and ekorg not in r_purchorg.
  delete adjacent duplicates from lt_marc comparing matnr.


  select eina~matnr eina~lifnr eine~ekorg eine~werks eine~minbm eina~meins  into table lt_EINA from eina
    inner join eine
    on eina~infnr = eine~infnr and eine~ekorg = ls_T024W-ekorg
    where
    eina~loekz = '' and eine~loekz = ''
    and eina~matnr in ra_matnr
    and eina~lifnr in ra_lifnr
    order by matnr lifnr.



  if 'C103' in r_purchorg or 'C106' in r_purchorg or 'C108' in r_purchorg.
    " Purch Org Price

    select ekorg lifnr matnr knumh datbi esokz into corresponding fields of table lt_KNUMH from a018
     where
       a018~ekorg in r_purchorg
       and a018~matnr in ra_matnr
       and a018~lifnr in ra_lifnr
       and a018~datbi >= l_startdate
       and a018~esokz = '0'
      order by matnr lifnr.

*REFRESH ra_KNUMH[].
*LOOP AT lt_KNUMH INTO ls_KNUMH.
*     READ TABLE lt_EINA WITH KEY EKORG = ls_KNUMH-EKORG MATNR = ls_KNUMH-MATNR LIFNR = ls_KNUMH-LIFNR TRANSPORTING NO FIELDS.
*     IF sy-subrc eq 0.
*       ra_KNUMH-sign = 'I'.
*       ra_KNUMH-option = 'EQ'.
*       ra_KNUMH-low = ls_KNUMH-KNUMH.
*       append ra_KNUMH.
*     ENDIF.
*ENDLOOP.

    select 'I','EQ', knumh into table @ra_KNUMH from a018
     where
       a018~ekorg in @r_purchorg
       and a018~matnr in @ra_matnr
       and a018~lifnr in @ra_lifnr
       and a018~datbi >= @sy-datum
       and a018~esokz = '0'.

  else.
* Plant Specific Price
    select ekorg werks lifnr matnr knumh datbi esokz into corresponding fields of table lt_KNUMH from a017
     where
       a017~ekorg in r_purchorg
       and a017~werks = plant
       and a017~matnr in ra_matnr
       and a017~lifnr in ra_lifnr
       and a017~datbi >= sy-datum
       and a017~esokz = '0'
      order by matnr lifnr.

*REFRESH ra_KNUMH[].
*LOOP AT lt_KNUMH INTO ls_KNUMH.
*     READ TABLE lt_EINA WITH KEY EKORG = ls_KNUMH-EKORG WERKS = ls_KNUMH-WERKS  MATNR = ls_KNUMH-MATNR LIFNR = ls_KNUMH-LIFNR TRANSPORTING NO FIELDS.
*     IF sy-subrc eq 0.
*       ra_KNUMH-sign = 'I'.
*       ra_KNUMH-option = 'EQ'.
*       ra_KNUMH-low = ls_KNUMH-KNUMH.
*       append ra_KNUMH.
*     ENDIF.
*ENDLOOP.
    select 'I','EQ', knumh into table @ra_KNUMH from a017
     where
       a017~ekorg in @r_purchorg
       and a017~werks = @plant
       and a017~matnr in @ra_matnr
       and a017~lifnr in @ra_lifnr
       and a017~datbi >= @sy-datum
       and a017~esokz = '0'.

  endif.

  select konp~knumh konp~kbetr konp~kpein konp~kmein konp~loevm_ko
        into table lt_KONP
        from konp
        where konp~knumh in ra_KNUMH
        and konp~kbetr > 0
        and konp~loevm_ko = ''
        order by konp~knumh konp~kbetr ascending.

  delete adjacent duplicates from lt_KONP comparing knumh kbetr.

  DELETE MKLISTDETAIL WHERE KOSTL = KOSTL AND PLANT = PLANT AND ABLAD = ABLAD.

  ls_MKLISTDETAIL-KOSTL = KOSTL.
  ls_MKLISTDETAIL-PLANT = PLANT.
  ls_MKLISTDETAIL-ABLAD = ABLAD.

  loop at lt_marc assigning <ls_marc>.


    clear ls_mmlist.
    ls_mmlist-matnr = <ls_marc>-matnr.
    ls_mmlist-maktx = <ls_marc>-maktx.
    ls_mmlist-waers = l_WAERS.
    ls_mmlist-lmein = <ls_marc>-lmein.
    ls_mmlist-omein = <ls_marc>-omein.


    refresh ra_KNUMH[].

    if plant in r_autopo.
      ls_mmlist-locked = 'X'.
    endif.

    if <ls_marc>-fixed = 'X'.
      if l_showvendor = 'X'.
        ls_mmlist-vdrname = <ls_marc>-vdrname.
      endif.

      loop at lt_EORD into ls_EORD where matnr = ls_mmlist-matnr.
        l_date = l_startdate.

        do 7 times.
          assign component ( 49 + sy-index ) of structure ls_mmlist to <l_field>.

          if ( l_date ge ls_EORD-vdatu and l_date le ls_EORD-bdatu ).
            <l_field> = 'X'.
          endif.
          l_date = l_date + 1.
        enddo.

      endloop.

      loop at lt_KNUMH into ls_KNUMH where matnr = <ls_marc>-matnr and lifnr = <ls_marc>-lifnr.
        rs_KNUMH-sign = 'I'.
        rs_KNUMH-option = 'EQ'.
        rs_KNUMH-low = ls_KNUMH-knumh.
        append rs_KNUMH TO ra_KNUMH.
      endloop.
    else.
      loop at lt_KNUMH into ls_KNUMH where matnr = <ls_marc>-matnr.
        rs_KNUMH-sign = 'I'.
        rs_KNUMH-option = 'EQ'.
        rs_KNUMH-low = ls_KNUMH-knumh.
        append rs_KNUMH TO ra_KNUMH.
      endloop.
    endif.


    if sy-subrc eq 0.
      clear l_MENGE.
      clear l_PRICEUNIT.

      ls_mmlist-netpr = 0.


      loop at lt_KONP into ls_KONP where knumh in ra_KNUMH.

        if ls_mmlist-netpr = 0 or ls_KONP-kbetr < ls_mmlist-netpr.
          ls_mmlist-netpr = ls_KONP-kbetr.
          l_PRICEUNIT = ls_KONP-kpein.
          if ls_mmlist-omein is initial.
            ls_mmlist-omein = ls_KONP-kmein.
          endif.

          if plant in r_autopo.
            if ( <ls_marc>-fixed = 'X' and <ls_marc>-kautb = 'X' and <ls_marc>-kzaut = 'X' and ls_mmlist-netpr > 0 ).
              ls_mmlist-locked = ''.
            endif.
          endif.
        endif.
      endloop.

      if ls_KONP-kmein ne ls_mmlist-lmein.
        call function 'MD_CONVERT_MATERIAL_UNIT'
          exporting
            i_matnr              = ls_mmlist-matnr
            i_in_me              = ls_KONP-kmein
            i_out_me             = ls_mmlist-lmein
            i_menge              = 1
          importing
            e_menge              = l_MENGE
          exceptions
            error_in_application = 1
            error                = 2
            others               = 3.
        if sy-subrc <> 0.
          l_MENGE = ls_KONP-kpein.
        endif.
      else.
        l_MENGE = ls_KONP-kpein.
      endif.
      ls_mmlist-peinh = l_MENGE.

      if ls_mmlist-omein ne ls_mmlist-lmein.
        call function 'MD_CONVERT_MATERIAL_UNIT'
          exporting
            i_matnr              = ls_mmlist-matnr
            i_in_me              = ls_mmlist-omein
            i_out_me             = ls_mmlist-lmein
            i_menge              = 1
          importing
            e_menge              = l_MENGE
          exceptions
            error_in_application = 1
            error                = 2
            others               = 3.
        if sy-subrc <> 0.
          l_MENGE = 1.
        endif.
      else.
        l_MENGE = 1.
      endif.
      ls_mmlist-umrez = l_MENGE.
    else.
      ls_mmlist-peinh = 1.
      if ls_mmlist-omein is initial.
        ls_mmlist-omein = ls_mmlist-lmein.
      endif.
    endif.



    read table lt_T006 with key msehi = ls_mmlist-omein into ls_T006.
    if sy-subrc eq 0.
      if ls_T006-andec ne 0.
        ls_mmlist-allowdec = 'X'.
      endif.
    endif.

    read table lt_EINA with key matnr = <ls_marc>-matnr  lifnr = <ls_marc>-lifnr into ls_EINA .
    if sy-subrc = 0.
      ls_mmlist-minbm = ls_EINA-minbm.
    endif.

    MOVE-CORRESPONDING ls_mmlist to ls_MKLISTDETAIL.
    APPEND ls_MKLISTDETAIL TO MKLISTDETAIL.

  endloop.

  refresh lt_marc.
  refresh lt_EINA.
  refresh lt_KONP.
  refresh lt_KNUMH.
  free lt_marc.
  free lt_EINA.
  free lt_KONP.
  free lt_KNUMH.



  endmethod.
ENDCLASS.
