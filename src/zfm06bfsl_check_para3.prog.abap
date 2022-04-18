*&---------------------------------------------------------------------*
*&      Form  CHECK_PARA3
*&---------------------------------------------------------------------*
FORM CHECK_PARA3.

  REJECT = 'X'.

* check s_kostl.
* check s_psext.
* check s_aufnr.
* check s_anln1.
* check s_anln2.
* check s_nplnr.
* check s_vbeln.
* check s_vbelp.

  CLEAR REJECT.

ENDFORM.
