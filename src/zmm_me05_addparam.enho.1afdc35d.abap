"Name: \PR:RM06W003\IC:FM06ICW8\SE:END\EI
ENHANCEMENT 0 ZMM_ME05_ADDPARAM.
* Addtional selection to show only lowest price vendor
*BREAK-POINT.
*IF sy-tcode EQ 'ZME05'.
*  PARAMETERS:  w_zero TYPE xfeld.
*  PARAMETERS:  w_low TYPE xfeld.
*  PARAMETER :  w_ekrg RADIOBUTTON GROUP GR1,
*               w_wrks RADIOBUTTON GROUP GR1.
*ENDIF.
ENDENHANCEMENT.
