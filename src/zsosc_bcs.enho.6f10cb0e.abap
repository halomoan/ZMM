"Name: \FU:SO_RECIPIENTS_FOR_SEND_GET\SE:END\EI
ENHANCEMENT 0 ZSOSC_BCS.
" We have to do this because UOL want to get the signature from tcode SODIS
" look at class CL_SAPUSER_BCS method GET_SAPUSER enhancement ZSOSC_BCS_GET_ID
data lv_title_compared type char100.
lv_title_compared = 'Purchase Order*'.
TRANSLATE lv_title_compared  to LOWER CASE.
if sender-address = 'ZDONOTREPLY'
 and lv_title cp lv_title_compared.
 select single cronam from sood
                      into @data(lv_cronam)
                      where objtp =  @sosc_entry-objtp
                        and objyr =  @sosc_entry-objyr
                        and objno =  @sosc_entry-objno.
 CALL FUNCTION 'ZFM_SET_USER_ID_DONOTREPLY'
   EXPORTING
     im_uname       = lv_cronam.

endif.
ENDENHANCEMENT.
