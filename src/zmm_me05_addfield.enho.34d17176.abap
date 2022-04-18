"Name: \PR:SAPFM06I\FO:W3_ALV_FILL_TABLE\SE:END\EI
ENHANCEMENT 0 ZMM_ME05_ADDFIELD.
IF sy-tcode EQ 'ZME05'.
  IF lt_outtab_me05 IS NOT INITIAL.
    TYPES: BEGIN OF lty_makt,
            matnr TYPE mara-matnr,
            maktx TYPE makt-maktx,
           END OF lty_makt,
           BEGIN OF lty_lfa1,
            lifnr TYPE lfa1-lifnr,
            name1 TYPE lfa1-name1,
           END OF lty_lfa1,
           BEGIN OF lty_eine,
             MATNR TYPE eina-MATNR,
             lifnr TYPE eina-lifnr,
             WERKS TYPE EINE-WERKS,
             EKORG TYPE EINE-EKORG,
             NETPR TYPE EINE-NETPR,
             WAERS TYPE EINE-WAERS,
             PEINH TYPE EINE-PEINH,
             BPRME TYPE EINE-BPRME,
             PRDAT TYPE EINE-PRDAT,
           END OF lty_eine.

    DATA: lt_makt TYPE STANDARD TABLE OF lty_makt,
          lt_lfa1 TYPE STANDARD TABLE OF lty_lfa1,
          lt_eine TYPE STANDARD TABLE OF lty_eine.

    DATA(lt_me05_tmp) = lt_outtab_me05.

    FIELD-SYMBOLS: <lfs_ekorg> TYPE abap_bool.
    FIELD-SYMBOLS: <lfs_werks> TYPE abap_bool.
    FIELD-SYMBOLS: <lfs_low>   TYPE abap_bool.
    FIELD-SYMBOLS: <lfs_zero>  TYPE abap_bool.

    SORT lt_me05_tmp by matnr.
    delete ADJACENT DUPLICATES FROM lt_me05_tmp COMPARING matnr.
    SELECT a~matnr b~maktx
      INTO TABLE lt_makt
      FROM mara as a
      INNER JOIN makt as b
      on a~matnr = b~matnr
      FOR ALL ENTRIES IN lt_me05_tmp
    WHERE a~matnr = lt_me05_tmp-matnr
      AND b~spras = sy-langu.
    REFRESH lt_me05_tmp.
    lt_me05_tmp = lt_outtab_me05.
    SORT lt_me05_tmp by lifnr.
    delete ADJACENT DUPLICATES FROM lt_me05_tmp COMPARING lifnr.

    SELECT lifnr name1
      FROM lfa1
      INTO TABLE lt_lfa1
      FOR ALL ENTRIES IN lt_me05_tmp
      WHERE lifnr = lt_me05_tmp-lifnr.

    ASSIGN ('(RM06W003)W_LOW') TO <lfs_low>.
    ASSIGN ('(RM06W003)W_ZERO') TO <lfs_zero>.
    ASSIGN ('(RM06W003)W_EKRG') TO <lfs_ekorg>.
    ASSIGN ('(RM06W003)W_WRKS') TO <lfs_werks>.

    IF <lfs_ekorg> IS ASSIGNED AND <lfs_ekorg> IS NOT INITIAL.
*      SELECT
*         MATNR
*         lifnr
*         WERKS
*         EKORG
*         NETPR
*         WAERS
*         PEINH
*         BPRME
*         prdat INTO TABLE lt_eine
*        FROM eina as a
*          INNER JOIN eine as b
*          on a~INFNR = b~INFNR
*        FOR ALL ENTRIES IN lt_outtab_me05
*        WHERE MATNR = lt_outtab_me05-matnr
*          AND lifnr = lt_outtab_me05-lifnr
*          AND EKORG = lt_outtab_me05-EKORG.
**          AND werks = lt_outtab_me05-WERKS.
**          AND prdat <= lt_outtab_me05-bdatu.
      SELECT
         a~MATNR
         a~lifnr
*         WERKS
         a~EKORG
         b~kbetr AS NETPR
         b~konwa AS WAERS
         b~kpein AS PEINH
         b~kmein AS BPRME
         a~datbi AS prdat
          INTO CORRESPONDING FIELDS OF TABLE lt_eine
        FROM a018 as a
          INNER JOIN konp as b
          on a~knumh = b~knumh
        FOR ALL ENTRIES IN lt_outtab_me05
        WHERE a~kappl = 'M'
          AND a~kschl = 'PB00'
          AND a~lifnr = lt_outtab_me05-lifnr
          AND a~MATNR = lt_outtab_me05-matnr
          AND a~EKORG = lt_outtab_me05-EKORG
          AND a~datbi >= lt_outtab_me05-vdatu
          AND b~loevm_ko NE 'X'.
*          AND a~datab >= lt_outtab_me05-vdatu.
*          AND a~datbi <= lt_outtab_me05-bdatu.
    ELSEIF <lfs_werks> IS ASSIGNED AND <lfs_werks> IS NOT INITIAL.
*      SELECT
*         MATNR
*         lifnr
*         WERKS
*         EKORG
*         NETPR
*         WAERS
*         PEINH
*         BPRME
*         prdat INTO TABLE lt_eine
*        FROM eina as a
*          INNER JOIN eine as b
*          on a~INFNR = b~INFNR
*        FOR ALL ENTRIES IN lt_outtab_me05
*        WHERE MATNR = lt_outtab_me05-matnr
*          AND lifnr = lt_outtab_me05-lifnr
**          AND EKORG = lt_outtab_me05-EKORG.
*          AND werks = lt_outtab_me05-WERKS.
**          AND prdat <= lt_outtab_me05-bdatu.
      SELECT
         a~MATNR
         a~lifnr
         a~WERKS
         a~EKORG
         b~kbetr AS NETPR
         b~konwa AS WAERS
         b~kpein AS PEINH
         b~kmein AS BPRME
         a~datbi AS prdat
          INTO TABLE lt_eine
        FROM a017 as a
          INNER JOIN konp as b
          on a~knumh = b~knumh
        FOR ALL ENTRIES IN lt_outtab_me05
        WHERE a~kappl = 'M'
          AND a~kschl = 'PB00'
          AND a~lifnr = lt_outtab_me05-lifnr
          AND a~MATNR = lt_outtab_me05-matnr
          AND a~EKORG = lt_outtab_me05-EKORG
          AND a~WERKS = lt_outtab_me05-WERKS
          AND a~datbi >= lt_outtab_me05-vdatu
          AND b~loevm_ko NE 'X'.
*          AND a~datab >= lt_outtab_me05-vdatu.
*          AND a~datbi <= lt_outtab_me05-bdatu.
    ENDIF.
    LOOP AT lt_outtab_me05 ASSIGNING FIELD-SYMBOL(<lfs_out>).
      READ TABLE lt_makt WITH KEY matnr = <lfs_out>-matnr INTO DATA(ls_makt).
      IF sy-subrc eq 0.
        <lfs_out>-maktx = ls_makt-maktx.
      ENDIF.
      READ TABLE lt_lfa1 WITH KEY lifnr = <lfs_out>-lifnr INTO DATA(ls_lfa1).
      IF sy-subrc eq 0.
        <lfs_out>-name1 = ls_lfa1-name1.
      ENDIF.
      IF <lfs_ekorg> IS ASSIGNED AND <lfs_ekorg> IS NOT INITIAL.
        READ TABLE lt_eine INTO DATA(ls_eine) WITH KEY matnr = <lfs_out>-matnr
                                                       lifnr = <lfs_out>-lifnr
*                                                       WERKS = <lfs_out>-WERKS
                                                       EKORG = <lfs_out>-EKORG.
      ELSEIF <lfs_werks> IS ASSIGNED AND <lfs_werks> IS NOT INITIAL.
        READ TABLE lt_eine INTO ls_eine WITH KEY matnr = <lfs_out>-matnr
                                                 lifnr = <lfs_out>-lifnr
                                                 WERKS = <lfs_out>-WERKS.
      ENDIF.
      IF sy-subrc eq 0.
        IF ls_eine-prdat GE <lfs_out>-vdatu. " AND ls_eine-prdat LE <lfs_out>-bdatu.
          <lfs_out>-netpr = ls_eine-netpr.
          <lfs_out>-WAERS = ls_eine-WAERS.
          <lfs_out>-PEINH = ls_eine-PEINH.
          <lfs_out>-ZZBPRME = ls_eine-BPRME.
        ELSE.
          IF <lfs_low> IS ASSIGNED and <lfs_low> EQ abap_true.
            <lfs_out>-status_text = 'expired'.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

*   Filter by lowest price vendor
    IF <lfs_zero> IS ASSIGNED AND <lfs_zero> EQ abap_true.
      DELETE lt_outtab_me05 WHERE netpr IS INITIAL.
    ENDIF.
    IF <lfs_low> IS ASSIGNED and <lfs_low> EQ abap_true.
      SORT lt_outtab_me05 BY status_text.
      DELETE lt_outtab_me05 WHERE status_text EQ 'will not be changed'.
*      DELETE lt_outtab_me05 WHERE status_text EQ 'expired'.
      SORT lt_outtab_me05 BY matnr werks ekorg netpr ASCENDING.
      DELETE ADJACENT DUPLICATES FROM lt_outtab_me05 COMPARING matnr werks ekorg.
    ENDIF.
    REFRESH cht_outtab[].
    cht_outtab[] = lt_outtab_me05.
  ENDIF.
ENDIF.
ENDENHANCEMENT.
