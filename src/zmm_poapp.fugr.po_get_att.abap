FUNCTION PO_GET_ATT.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_PONUMBER) TYPE  EBELN
*"     VALUE(I_FILENAME) TYPE  STRING OPTIONAL
*"  EXPORTING
*"     VALUE(PO_ATT) TYPE  ZTT_POATT
*"     VALUE(RT_MESSAGES) TYPE  BAPIRETTAB
*"  EXCEPTIONS
*"      FILE_NOT_FOUND
*"      PO_HASNO_FILES
*"----------------------------------------------------------------------
data: ls_lporb type sibflporb.
data: lt_sood type standard table of sood,
      ls_sood like line of lt_sood.

data: dec_kb TYPE P.
data: l_hasFile TYPE C VALUE IS INITIAL.
data: ls_po_att like line of PO_ATT.

ls_lporb-typeid = 'BUS2012'.
ls_lporb-instid = I_PONUMBER.

TRANSLATE I_FILENAME TO UPPER CASE.

call method ZCL_GOS_FILE=>GOS_GET_FILE_LIST
EXPORTING
  IS_LPORB = LS_LPORB
IMPORTING
  T_ATTACHMENTS = lt_sood
  rt_messages = rt_messages.

if rt_messages[] is initial.
  IF lt_sood[] IS INITIAL.
    RAISE PO_HASNO_FILES.
  ENDIF.

  loop at lt_sood into ls_sood.


     dec_kb = ls_sood-objlen / 1024.
     if dec_kb < 1.
       dec_kb = 1.
     endif.
     ls_po_att-FILENAME = ls_sood-objdes.
     ls_po_att-FILETYPE = ls_sood-acnam.
     ls_po_att-SIZE = dec_kb.
     ls_po_att-OWNER = ls_sood-OWNNAM.
     ls_po_att-CRDAT = ls_sood-CRDAT.

     IF I_FILENAME IS INITIAL.
       l_hasFile = 'X'.
       APPEND ls_po_att TO PO_ATT.
     ELSE.
       TRANSLATE ls_sood-objdes TO UPPER CASE.
       IF I_FILENAME eq ls_sood-objdes.
          call method ZCL_GOS_FILE=>gos_get_file_xstring
          exporting
            folder_region     = 'B'
            doctp             = ls_sood-objtp
            docyr             = ls_sood-objyr
            docno             = ls_sood-objno
          importing
            "o_file_name       = l_filename
            o_content_hex     = ls_po_att-hexcontent
            o_mimetype        = ls_po_att-mimetype
            rt_messages       = rt_messages.

          l_hasFile = 'X'.
          APPEND ls_po_att TO PO_ATT.
       ENDIF.

     ENDIF.

  endloop.

  if l_hasFile IS INITIAL.
    RAISE FILE_NOT_FOUND.
  endif.

endif.

ENDFUNCTION.
