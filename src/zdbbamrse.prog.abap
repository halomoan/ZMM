
*----------------------------------------------------------------------*
* Select-Options an Log. Datenbank BAM übergeben                       *
*----------------------------------------------------------------------*
FORM selopt_bam_1.

  LOOP AT s_werks.
    MOVE s_werks TO ba_werks.
    APPEND ba_werks.
  ENDLOOP.
  LOOP AT s_bsart.
    MOVE s_bsart TO ba_bsart.
    APPEND ba_bsart.
  ENDLOOP.
  LOOP AT r_pstyp.
    MOVE r_pstyp TO ba_pstyp.
    APPEND ba_pstyp.
  ENDLOOP.
  LOOP AT s_knttp.
    MOVE s_knttp TO ba_knttp.
    APPEND ba_knttp.
  ENDLOOP.
  LOOP AT s_lfdat.
    MOVE s_lfdat TO ba_lfdat.
    APPEND ba_lfdat.
  ENDLOOP.
  LOOP AT s_frgdt.
    MOVE s_frgdt TO ba_frgdt.
    APPEND ba_frgdt.
  ENDLOOP.
  LOOP AT s_dispo.
    MOVE s_dispo TO ba_dispo.
    APPEND ba_dispo.
  ENDLOOP.
  LOOP AT s_statu.
    MOVE s_statu TO ba_statu.
    APPEND ba_statu.
  ENDLOOP.
  LOOP AT s_flief.
    MOVE s_flief TO ba_flief.
    APPEND ba_flief.
  ENDLOOP.

  LOOP AT s_banpr.
    MOVE s_banpr TO ba_banpr.
    APPEND ba_banpr.
  ENDLOOP.
  LOOP AT s_beswk.
    MOVE s_beswk TO ba_beswk.
    APPEND ba_beswk.
  ENDLOOP.
  LOOP AT s_blckd.
    MOVE s_blckd TO ba_blckd.
    APPEND ba_blckd.
  ENDLOOP.

  IF NOT p_afnam IS INITIAL.
    CLEAR ba_afnam.
    ba_afnam-sign = 'I'.
    ba_afnam-option = 'CP'.
    ba_afnam-low = p_afnam.
    APPEND ba_afnam.
  ENDIF.
  IF NOT p_txz01 IS INITIAL.
    CLEAR ba_txz01.
    ba_txz01-sign = 'I'.
    ba_txz01-option = 'CP'.
    ba_txz01-low = p_txz01.
    APPEND ba_txz01.
  ENDIF.

ENDFORM.                    "selopt_bam_1
*----------------------------------------------------------------------*
* Spezielle Selektionen an Log. Datenbank BAM übergeben                *
*----------------------------------------------------------------------*
FORM selopt_bam_2 USING sb2_erlba sb2_zugba.

  IF sb2_erlba EQ space.
    CLEAR ba_loekz.
    ba_loekz-sign = 'I'.
    ba_loekz-option = 'EQ'.
    APPEND ba_loekz.

*
* log. database should select open requisitions only
* parameter is shared by the log. database and creates another
* where-clause to the select statement
* (performance and memory overflow / note 311324)
*
    pba_ofba = 'X'.

  ENDIF.
  IF sb2_zugba EQ space.
    CLEAR ba_zugba.
    ba_zugba-sign = 'I'.
    ba_zugba-option = 'EQ'.
    APPEND ba_zugba.
  ENDIF.

ENDFORM.                    "selopt_bam_2
*----------------------------------------------------------------------*
* Spezielle Selektionen an Log. Datenbank BAM übergeben                *
*----------------------------------------------------------------------*
FORM selopt_bam_3.


  LOOP AT s_aufnr.
    MOVE s_aufnr TO bk_aufnr.
    APPEND bk_aufnr.
  ENDLOOP.

  LOOP AT s_kostl.
    MOVE s_kostl TO bk_kostl.
    APPEND bk_kostl.
  ENDLOOP.

  LOOP AT s_anln1.
    MOVE s_anln1 TO bk_anln1.
    APPEND bk_anln1.
  ENDLOOP.

  LOOP AT s_anln2.
    MOVE s_anln2 TO bk_anln2.
    APPEND bk_anln2.
  ENDLOOP.

  LOOP AT s_psext.
    MOVE s_psext TO bk_psext.
    APPEND bk_psext.
  ENDLOOP.

  LOOP AT s_nplnr.
    MOVE s_nplnr TO bk_nplnr.
    APPEND bk_nplnr.
  ENDLOOP.

  LOOP AT s_vornr.
    MOVE s_vornr TO bk_vornr.
    APPEND bk_vornr.
  ENDLOOP.

  LOOP AT s_vbeln.
    MOVE s_vbeln TO bk_vbeln.
    APPEND bk_vbeln.
  ENDLOOP.

  LOOP AT s_vbelp.
    MOVE s_vbelp TO bk_vbelp.
    APPEND bk_vbelp.
  ENDLOOP.

ENDFORM.                    "selopt_bam_3

*&---------------------------------------------------------------------*
*&      Form  selopt_bam_4
*&---------------------------------------------------------------------*
*       Sets upper limit for selection with ME_READ_EBAN_MULTIPLE
*       new with ERP 1.0 PA
*----------------------------------------------------------------------*
*      -->IM_P_CNTLMT  upper limit for selection
*----------------------------------------------------------------------*
FORM selopt_bam_4  USING im_p_cntlmt.

  CHECK NOT im_p_cntlmt EQ space.
  p_qcount = im_p_cntlmt.

ENDFORM.                    " selopt_bam_4
