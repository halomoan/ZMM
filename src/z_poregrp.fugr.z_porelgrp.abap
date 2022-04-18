FUNCTION z_porelgrp.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(UNAME) TYPE  SY-UNAME DEFAULT SY-UNAME
*"  TABLES
*"      IT_EKPO TYPE  ZZEKPO
*"  EXCEPTIONS
*"      REL_CODE_NOT_FOUND
*"      REL_GRP_NOT_FOUND
*"----------------------------------------------------------------------
  DATA : obj1 TYPE usr12-objct,
         obj2 TYPE usr12-objct .
  DATA : usr TYPE usr04-bname.
  DATA : wa_ekpo TYPE ekpo.
  DATA : it_us335 TYPE STANDARD TABLE OF us335 WITH HEADER LINE,
         it_t16fv TYPE STANDARD TABLE OF t16fv WITH HEADER LINE,
         it_ekko TYPE STANDARD TABLE OF ekko WITH HEADER LINE.
  RANGES : r_frggr FOR t16fv-frggr,
           r_frgco FOR t16fv-frgco,
           r_werks FOR ekpo-werks.
  FIELD-SYMBOLS <fs> TYPE t16fv.
  DATA ctr TYPE sy-tabix.

  DATA: it_ekko_fin TYPE STANDARD TABLE OF ekko WITH HEADER LINE.
  DATA: v_f1 TYPE string,
        v_f2 TYPE string,
        v_f3 TYPE string,
        v_f4 TYPE string,
        v_f5 TYPE string.
  FIELD-SYMBOLS: <fs_pre>  TYPE ANY,
                 <fs_post> TYPE ANY.
  DATA: idx_count TYPE sysubrc,
        v_xlen    TYPE sysubrc,
        v_diff    TYPE sysubrc.

  REFRESH : it_us335[],it_t16fv[],r_frggr[],r_frgco[],it_ekko[],r_werks[].
  CLEAR : obj1,obj2,it_us335,it_t16fv,r_frggr,r_frgco,it_ekko,r_werks,ctr.

  usr = uname.
  obj1 = 'M_EINK_FRG'.
  obj2 = 'M_BEST_WRK'.

  CALL FUNCTION 'GET_AUTH_VALUES'
    EXPORTING
      object1           = obj1
      object2           = obj2
      user              = uname
    TABLES
      values            = it_us335
    EXCEPTIONS
      user_doesnt_exist = 1
      OTHERS            = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  LOOP AT it_us335 WHERE field = 'FRGGR'.
    r_frggr-low = it_us335-lowval.
    r_frggr-sign = 'I'.
    r_frggr-option = 'EQ'.
    APPEND r_frggr.
    CLEAR r_frggr.
  ENDLOOP.
  IF sy-subrc <> 0.
    RAISE rel_grp_not_found.
  ENDIF.

  LOOP AT it_us335 WHERE field = 'FRGCO'.
    r_frgco-low = it_us335-lowval.
    r_frgco-sign = 'I'.
    r_frgco-option = 'EQ'.
    APPEND r_frgco.
    CLEAR r_frgco.
  ENDLOOP.
  IF sy-subrc <> 0.
    RAISE rel_code_not_found.
  ENDIF.


  REFRESH: it_ekko_fin.
  CLEAR: it_ekko_fin.

  LOOP AT r_frgco.
    REFRESH: it_t16fv.
    CLEAR: it_t16fv.
    SELECT * INTO TABLE it_t16fv FROM t16fv WHERE frggr IN r_frggr
                                              AND frgco EQ r_frgco-low.
    CHECK NOT it_t16fv[] IS INITIAL.
    REFRESH: it_ekko.
    CLEAR: it_ekko.
    SELECT * INTO TABLE it_ekko FROM ekko FOR ALL ENTRIES IN it_t16fv
                                            WHERE frggr = it_t16fv-frggr
                                              AND frgsx = it_t16fv-frgsx.
    DELETE it_ekko WHERE frgke = 'R'.
    LOOP AT it_ekko.
      READ TABLE it_t16fv WITH KEY frggr = it_ekko-frggr
                                   frgsx = it_ekko-frgsx.
* Clear data holders
      CLEAR: v_f1,
             v_f2,
             v_f3,
             v_f4,
             v_f5.
      CLEAR: v_xlen,
             v_diff.
* Declare dynamic symbols
      v_f1 = 'IT_T16FV'.
      v_f2 = '-FRGA'.
      CLEAR: idx_count.
      DO 8 TIMES.
        idx_count = idx_count + 1.
* Assign values
        v_f3 = idx_count.
        CONCATENATE v_f2 v_f3 INTO v_f4.
        CONCATENATE v_f1 v_f4 INTO v_f5.
* Calculate position of X
        ASSIGN (v_f1) TO <fs_pre>.
        IF sy-subrc EQ 0.
          ASSIGN (v_f5) TO <fs_post>.
          IF sy-subrc EQ 0.
            IF <fs_post> EQ 'X'.
              EXIT.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDDO.

* Current release position
      v_xlen = STRLEN( it_ekko-frgzu ).

* Calculate the desired level
      v_diff = idx_count - v_xlen.

      IF it_ekko-frgzu IS INITIAL.
        IF it_t16fv-frga1 <> 'X'.
          DELETE it_ekko.
          CONTINUE.
        ENDIF.
      ENDIF.

      IF v_diff NE 1.
        DELETE it_ekko.
        CONTINUE.
      ENDIF.

    ENDLOOP.
    APPEND LINES OF it_ekko TO it_ekko_fin.
  ENDLOOP.


  LOOP AT it_us335 WHERE field = 'WERKS'.
    r_werks-low = it_us335-lowval.
    r_werks-sign = 'I'.
    r_werks-option = 'EQ'.
    APPEND r_werks.
    CLEAR r_werks.
  ENDLOOP.

  LOOP AT it_ekko_fin.
    CLEAR wa_ekpo.
    SELECT SINGLE * INTO wa_ekpo FROM ekpo WHERE ebeln = it_ekko_fin-ebeln
                                             AND werks IN r_werks.
    IF sy-subrc = 0.
      AUTHORITY-CHECK OBJECT 'M_BEST_WRK'
               ID 'ACTVT' FIELD '02'
               ID 'WERKS' FIELD wa_ekpo-werks.
      IF sy-subrc <> 0.
        DELETE it_ekko_fin.
        CONTINUE.
      ENDIF.
    ELSE.
      DELETE it_ekko_fin.
      CONTINUE.
    ENDIF.
    it_ekpo-ebeln = it_ekko_fin-ebeln.
    it_ekpo-frggr = it_ekko_fin-frggr.
    SELECT SINGLE frggt INTO it_ekpo-frggt FROM t16fh WHERE spras = sy-langu
                                                        AND frggr = it_ekpo-frggr.
    it_ekpo-frgsx = it_ekko_fin-frgsx.
    SELECT SINGLE frgxt INTO it_ekpo-frgxt FROM t16ft WHERE spras = sy-langu
                                                       AND frggr = it_ekpo-frggr
                                                       AND frgsx = it_ekko_fin-frgsx.
    it_ekpo-werks = wa_ekpo-werks.
    APPEND it_ekpo.
    CLEAR it_ekpo.
  ENDLOOP.


ENDFUNCTION.
