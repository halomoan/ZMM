*&---------------------------------------------------------------------*
*&  Include           ZXM06U17
*&---------------------------------------------------------------------*
INCLUDE mm_messages_mac.
DATA : numki LIKE zmmgb_numrange-numki,
       nr LIKE inri-nrrangenr,
       obj LIKE inri-object,
       qty  LIKE  inri-quantity,
       retcode  LIKE  inri-returncode,
       num TYPE char20.
DATA : werks LIKE ekpo-werks.
*SAPMEGUI
*DATA: i_prog(30) TYPE c VALUE '(SAPMM06E)XEKPO[]'.
DATA: i_prog(30) TYPE c VALUE '(SAPLMEPO)XEKPO[]'.
FIELD-SYMBOLS: <ekpo> TYPE ANY TABLE,
               <wa_ekpo> TYPE uekpo.

ASSIGN (i_prog) TO <ekpo>.

CLEAR: numki,nr,obj,qty,retcode,num,werks.
IF nekko-bstyp = 'F'.
  LOOP AT <ekpo> ASSIGNING <wa_ekpo>. "#EC CI_FLDEXT_OK[2215424] P30K910032
    IF <wa_ekpo>-loekz = space.
      EXIT.
    ENDIF.
  ENDLOOP.

  SELECT SINGLE numki INTO numki FROM zmmgb_numrange WHERE werks = <wa_ekpo>-werks
                                                       AND bsart = nekko-bsart.
  IF sy-subrc = 0.
    range = numki.
  ELSE.
    mmpur_message_forced 'E' 'ZMM' '001' '' '' '' ''.
  ENDIF.
ENDIF.
