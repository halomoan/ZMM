*eject
*
* 152367 12.05.1999 PH Banf zur Anfrage vormerken
*
*----------------------------------------------------------------------*
*        Lesen Infosätze zum Material zur Anfragezuordnung             *
*----------------------------------------------------------------------*
FORM lesen_info.

* PERFORM MATERIALNUMMER_SETZEN                       "152367
*             USING                                   "152367
*                BAN-MATNR                            "152367
*                BAN-EMATN                            "152367
*                BAN-MPROF                            "152367
*                SEL_MATNR.                           "152367

  CLEAR bqpim.
* BQPIM-MATNR = SEL_MATNR.                            "152367
  bqpim-matnr = ban-matnr.                                  "152367
  bqpim-ematn = ban-ematn.                                  "152367
  bqpim-mprof = ban-mprof.
  bqpim-matkl = ban-matkl.
  bqpim-satnr = ban-satnr.
  bqpim-attyp = ban-attyp.
  bqpim-pstyp = ban-pstyp.
* Begin CCP
*  BQPIM-WERKS = BAN-WERKS.
  IF ban-beswk IS INITIAL.
    bqpim-werks = ban-werks.
  ELSE.
    bqpim-werks = ban-beswk.
  ENDIF.
* End CCP
  bqpim-noaus = 'X'.

  CALL FUNCTION 'ME_READ_INFORECORDS_MAT'
    EXPORTING
      comim     = bqpim
    TABLES
      xlief     = alfu
    EXCEPTIONS
      not_found = 01.

  IF sy-subrc NE 0.
    EXIT.
  ENDIF.

  CLEAR alf.
  LOOP AT alfu.
    alfkey-banfn = ban-banfn.
    alfkey-bnfpo = ban-bnfpo.
    alfkey-lifnr = alfu-lifnr.
    alfkey-ekorg = alfu-ekorg.
    READ TABLE alf WITH KEY alfkey BINARY SEARCH.
    CASE sy-subrc.
      WHEN 04.
        MOVE-CORRESPONDING alfkey TO alf.
        alf-beswk = bqpim-beswk. " CCP
        INSERT alf INDEX sy-tabix.
      WHEN 08.
        MOVE-CORRESPONDING alfkey TO alf.
        alf-beswk = bqpim-beswk. " CCP
        APPEND alf.
    ENDCASE.
  ENDLOOP.

ENDFORM.                    "LESEN_INFO
