"Name: \FU:MEPOBADI_FS_ITEM\SE:END\EI
ENHANCEMENT 0 ZMEPOBADI_FS_ITEM.
*>>> CR #20 - Enhancement to force Short Text (Master data description) on PO screens.
*    Created by Ramses on 11.09.2013  - START   P30K905872

* Update fieldstatus of metafield '69' (Metafield for Short Text column) with value '.' <-- Free Input
* to allow BADI ME_PROCESS_PO_CUST~PROCESS_ITEM to overwrite Short Text value with Master Data Description
* and prevent system reverting back to original inputted Short Text.

*  CHECK sy-tcode EQ 'ME22N' OR       "Apply for all PO related screens (ME21N, ME22N, ME23N)
*        sy-tcode EQ 'ME23N'.

  READ TABLE ch_fieldselection ASSIGNING <fs1> WITH KEY metafield = '69'.
  IF sy-subrc = 0.
    <fs1>-fieldstatus = '.'.
  ENDIF.
*<<< End of Enhancement -   End



*IF NOT l_instance_cust IS INITIAL.
** firewall
*    LOOP AT ch_fieldselection ASSIGNING <fs1> WHERE metafield EQ '69'.
*      INSERT <fs1> INTO TABLE lt_fieldselection.
*    ENDLOOP.
*    IF sy-subrc IS INITIAL.
*      CALL METHOD l_instance_cust->fieldselection_item
*        EXPORTING
*          im_header         = im_header
*          im_item           = im_item
*        CHANGING
*          ch_fieldselection = lt_fieldselection.
*      LOOP AT lt_fieldselection ASSIGNING <fs2>.
*        READ TABLE ch_fieldselection ASSIGNING <fs1> WITH TABLE KEY
*                                metafield = <fs2>-metafield.
*        IF sy-subrc IS INITIAL.
*          <fs1>-fieldstatus = <fs2>-fieldstatus.
*        ENDIF.
*      ENDLOOP.
*    ENDIF.
*  ENDIF.




ENDENHANCEMENT.
