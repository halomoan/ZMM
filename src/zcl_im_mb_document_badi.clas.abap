class ZCL_IM_MB_DOCUMENT_BADI definition
  public
  final
  create public .

*"* public components of class ZCL_IM_MB_DOCUMENT_BADI
*"* do not include other source files here!!!
public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_MB_DOCUMENT_BADI .
protected section.
*"* protected components of class ZCL_IM_MB_DOCUMENT_BADI
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_IM_MB_DOCUMENT_BADI
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_IM_MB_DOCUMENT_BADI IMPLEMENTATION.


METHOD if_ex_mb_document_badi~mb_document_before_update.
break zdevams.
ENDMETHOD.


method IF_EX_MB_DOCUMENT_BADI~MB_DOCUMENT_UPDATE.
  break zdevams.
endmethod.
ENDCLASS.
