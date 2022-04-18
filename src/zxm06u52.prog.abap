**&---------------------------------------------------------------------*
*&  Include           ZXM06U52
*&---------------------------------------------------------------------*
* FRICE#     : MMGBE_013
* Title      : PR Source Determination
* Author     : Ellen H. Lagmay
* Date       : 11.10.2010
* Specification Given By: Audrey Chui
* Purpose	 : For PR - To assign the source automatically based on the
*            lowest price deteremined when there are multiple sources.
*---------------------------------------------------------------------*
* Modification Log
* Date         Author         Num        Description
* 31.12.2010   VEGOPALARTH   P30K901381  Fix applied for ME53N
*----------------------------------------------------------------------*

DATA: l_ucomm(20) ,               "memory ID
      l_cnt(10),           "table entries
      l_msg(100),
      it_sources_po LIKE t_sources OCCURS 0 WITH HEADER LINE,
      it_sources_con LIKE t_sources OCCURS 0 WITH HEADER LINE.

*<<< SUPPORT TICKET T007325 - ADDED BY RAMSES 15.05.2012 - START    P30K901381
DATA: wa_eban TYPE EBAN,
      WA_A017 TYPE A017,
      WA_A018 TYPE A018.

TYPES: BEGIN OF ty_it_sources_kbetr.
         INCLUDE STRUCTURE SRC_DETERM.
TYPES:   KBETR TYPE KONP-KBETR,
      END OF ty_it_sources_kbetr.

DATA: IT_SOURCES_KBETR TYPE TABLE OF ty_it_sources_kbetr WITH HEADER LINE.
*<<< SUPPORT TICKET T007325 - ADDED BY RAMSES 15.05.2012 - END

CONSTANTS: c_tcode(10) VALUE 'ZME56',
           c_po(10)    VALUE  'ME51N',
           c_pr(10)     VALUE 'ME52N',
           c_msg(50) VALUE 'No source lists found for document',
*Start of changes by Venkatesh <VEGOPALARATH> on 31.12.2010
           c_tog(20)  TYPE c  VALUE 'ME_SOURCE_SINGLE_TOG',
           c_me53n(5) TYPE c VALUE 'ME53N'.
*End of changes by Venkatesh <VEGOPALARATH> on 31.12.2010

CLEAR: l_ucomm, l_cnt, it_sources_po[], it_sources_con[].
IMPORT l_ucomm FROM MEMORY ID 'ZSDL' .
IF ( sy-tcode = c_tcode AND sy-ucomm = l_ucomm ) OR
     sy-tcode =  c_po OR sy-tcode = c_pr OR
*Start of changes by Venkatesh <VEGOPALARATH> on 31.12.2010
   ( sy-tcode = c_me53n AND sy-ucomm = c_tog ).
*End of changes by Venkatesh <VEGOPALARATH> on 31.12.2010

*_1. check for authorization
  AUTHORITY-CHECK OBJECT 'S_TCODE'
           ID 'TCD' FIELD c_tcode.
  IF sy-subrc = 0.

*<<< SUPPORT TICKET T007325 - ADDED BY RAMSES 15.05.2012 - START    P30K901381
    SELECT SINGLE * FROM EBAN
      INTO WA_EBAN
     WHERE BANFN = I_BANFN
       AND BNFPO = I_BNFPO.
*<<< SUPPORT TICKET T007325 - ADDED BY RAMSES 15.05.2012 - END

    DESCRIBE TABLE  t_sources LINES l_cnt.
    CONDENSE l_cnt.
*_2.1. for multiple entries found at T_source
    IF l_cnt > 1.
*_check EBELN is not initial and lowest price(NETPR)
      it_sources_po[] = t_sources[].
      SORT it_sources_po BY netpr ebeln DESCENDING.
      DELETE it_sources_po WHERE ebeln IS INITIAL.

*<<< SUPPORT TICKET T007325 - ADDED BY RAMSES 15.05.2012 - START    P30K901381
      IT_SOURCES_KBETR[] = IT_SOURCES_PO[].

      LOOP AT IT_SOURCES_KBETR.

        CLEAR WA_A017.
        CLEAR WA_A018.

        IF IT_SOURCES_KBETR-WERKS IS INITIAL.       "Price condition without Plant - A018

          SELECT SINGLE * FROM A018
            INTO WA_A018
           WHERE KAPPL = 'M'
             AND KSCHL = 'PB00'
             AND LIFNR = IT_SOURCES_KBETR-LIFNR
             AND MATNR = WA_EBAN-MATNR
             AND EKORG = IT_SOURCES_KBETR-EKORG
*             AND WERKS = IT_SOURCES_KBETR-WERKS
             AND ESOKZ = IT_SOURCES_KBETR-PSTYP
             AND DATBI >= WA_EBAN-LFDAT
             AND DATAB <= WA_EBAN-LFDAT.

          IF NOT WA_A018 IS INITIAL.
            SELECT SINGLE KBETR FROM KONP
              INTO IT_SOURCES_KBETR-KBETR
             WHERE KNUMH = WA_A018-KNUMH
               AND KAPPL = WA_A018-KAPPL
               AND KSCHL = WA_A018-KSCHL.

             IF SY-SUBRC = 0.
               MODIFY IT_SOURCES_KBETR.
             ENDIF.
          ENDIF.

        ELSE.                                       "Price condition with Plant - A017

          SELECT SINGLE * FROM A017
            INTO WA_A017
           WHERE KAPPL = 'M'
             AND KSCHL = 'PB00'
             AND LIFNR = IT_SOURCES_KBETR-LIFNR
             AND MATNR = WA_EBAN-MATNR
             AND EKORG = IT_SOURCES_KBETR-EKORG
             AND WERKS = IT_SOURCES_KBETR-WERKS
             AND ESOKZ = IT_SOURCES_KBETR-PSTYP
             AND DATBI >= WA_EBAN-LFDAT
             AND DATAB <= WA_EBAN-LFDAT.

          IF NOT WA_A017 IS INITIAL.
            SELECT SINGLE KBETR FROM KONP
              INTO IT_SOURCES_KBETR-KBETR
             WHERE KNUMH = WA_A017-KNUMH
               AND KAPPL = WA_A017-KAPPL
               AND KSCHL = WA_A017-KSCHL.

             IF SY-SUBRC = 0.
               MODIFY IT_SOURCES_KBETR.
             ENDIF.
          ENDIF.

        ENDIF.

      ENDLOOP.

      DELETE IT_SOURCES_KBETR WHERE KBETR IS INITIAL.
      SORT IT_SOURCES_KBETR BY KBETR EBELN ASCENDING.
      READ TABLE IT_SOURCES_KBETR INDEX 1.

      IF SY-SUBRC = 0 AND IT_SOURCES_KBETR-EBELN IS NOT INITIAL.
        c_bqpex-flief        = IT_SOURCES_KBETR-lifnr.
        IT_SOURCES_KBETR-lifnr = c_bqpex-lifnr.
        MOVE-CORRESPONDING IT_SOURCES_KBETR  TO  c_bqpex.
*_assign manually
        c_bqpex-konnr = IT_SOURCES_KBETR-ebeln.
        c_bqpex-ktpnr = IT_SOURCES_KBETR-ebelp.
        CLEAR t_sources[].
        MOVE IT_SOURCES_KBETR TO t_sources. APPEND t_sources.

      ELSE.

        IT_SOURCES_KBETR[] = T_SOURCES[].
        LOOP AT IT_SOURCES_KBETR.

          CLEAR WA_A017.
          CLEAR WA_A018.

          IF IT_SOURCES_KBETR-WERKS IS INITIAL.       "Price condition without Plant - A018

            SELECT SINGLE * FROM A018
              INTO WA_A018
             WHERE KAPPL = 'M'
               AND KSCHL = 'PB00'
               AND LIFNR = IT_SOURCES_KBETR-LIFNR
               AND MATNR = WA_EBAN-MATNR
               AND EKORG = IT_SOURCES_KBETR-EKORG
*               AND WERKS = IT_SOURCES_KBETR-WERKS
               AND ESOKZ = IT_SOURCES_KBETR-PSTYP
               AND DATBI >= WA_EBAN-LFDAT
               AND DATAB <= WA_EBAN-LFDAT.

            IF NOT WA_A018 IS INITIAL.
              SELECT SINGLE KBETR FROM KONP
                INTO IT_SOURCES_KBETR-KBETR
               WHERE KNUMH = WA_A018-KNUMH
                 AND KAPPL = WA_A018-KAPPL
                 AND KSCHL = WA_A018-KSCHL.

               IF SY-SUBRC = 0.
                 MODIFY IT_SOURCES_KBETR.
               ENDIF.
             ENDIF.

          ELSE.                                       "Price condition with Plant - A017

             SELECT SINGLE * FROM A017
               INTO WA_A017
              WHERE KAPPL = 'M'
                AND KSCHL = 'PB00'
                AND LIFNR = IT_SOURCES_KBETR-LIFNR
                AND MATNR = WA_EBAN-MATNR
                AND EKORG = IT_SOURCES_KBETR-EKORG
                AND WERKS = IT_SOURCES_KBETR-WERKS
                AND ESOKZ = IT_SOURCES_KBETR-PSTYP
                AND DATBI >= WA_EBAN-LFDAT
                AND DATAB <= WA_EBAN-LFDAT.

             IF NOT WA_A017 IS INITIAL.
               SELECT SINGLE KBETR FROM KONP
                 INTO IT_SOURCES_KBETR-KBETR
                WHERE KNUMH = WA_A017-KNUMH
                  AND KAPPL = WA_A017-KAPPL
                  AND KSCHL = WA_A017-KSCHL.

                IF SY-SUBRC = 0.
                  MODIFY IT_SOURCES_KBETR.
                ENDIF.
             ENDIF.

          ENDIF.

        ENDLOOP.

        DELETE IT_SOURCES_KBETR WHERE KBETR IS INITIAL.
        SORT IT_SOURCES_KBETR BY KBETR infnr  ASCENDING.
        DELETE IT_SOURCES_KBETR WHERE infnr  IS INITIAL.
        READ TABLE IT_SOURCES_KBETR INDEX 1.
        IF sy-subrc = 0.
          c_bqpex-flief        = IT_SOURCES_KBETR-lifnr.
          IT_SOURCES_KBETR-lifnr = c_bqpex-lifnr.
          MOVE-CORRESPONDING IT_SOURCES_KBETR  TO  c_bqpex.
          CLEAR t_sources[].
          MOVE IT_SOURCES_KBETR TO t_sources. APPEND t_sources.
        ENDIF.

      ENDIF.
*<<< SUPPORT TICKET T007325 - ADDED BY RAMSES 15.05.2012 - END


*<<< SUPPORT TICKET T007325 - REMARKED BY RAMSES 15.05.2012 - START    P30K901381
*      READ TABLE it_sources_po INDEX 1.
*      IF sy-subrc = 0 AND it_sources_po-ebeln IS NOT INITIAL.
*        c_bqpex-flief        = it_sources_po-lifnr.
*        it_sources_po-lifnr = c_bqpex-lifnr.
*        MOVE-CORRESPONDING it_sources_po  TO  c_bqpex.
**_assign manually
*        c_bqpex-konnr = it_sources_po-ebeln.
*        c_bqpex-ktpnr = it_sources_po-ebelp.
*        CLEAR t_sources[].
*        MOVE it_sources_po TO t_sources. APPEND t_sources.
**_2.2. without EBELN, then use INFNR and lowest price(NETPR)
*      ELSE.
*        it_sources_con[] = t_sources[].
*        SORT it_sources_con BY netpr infnr  DESCENDING.
*        DELETE it_sources_con WHERE infnr  IS INITIAL.
*        READ TABLE it_sources_con INDEX 1.
*        IF sy-subrc = 0.
*          c_bqpex-flief        = it_sources_con-lifnr.
*          it_sources_con-lifnr = c_bqpex-lifnr.
*          MOVE-CORRESPONDING it_sources_con  TO  c_bqpex.
*          CLEAR t_sources[].
*          MOVE it_sources_con TO t_sources. APPEND t_sources.
*        ENDIF.
*      ENDIF.
*<<< SUPPORT TICKET T007325 - REMARKED BY RAMSES 15.05.2012 - END

*_ no source list available
    ELSEIF l_cnt = 0.
      CONCATENATE c_msg i_banfn i_bnfpo INTO l_msg SEPARATED BY space.
      MESSAGE l_msg TYPE 'S'.
    ENDIF.
*_transport cnt of t_source to det if source list available or not
*_1.1 no authorization
  ELSE.
    MESSAGE i172(00) WITH c_tcode.
    EXIT.
  ENDIF.

ENDIF.
