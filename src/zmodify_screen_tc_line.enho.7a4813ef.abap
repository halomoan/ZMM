"Name: \TY:CL_TABLE_VIEW_MM\ME:MODIFY_SCREEN_TC_LINE\SE:END\EI
ENHANCEMENT 0 ZMODIFY_SCREEN_TC_LINE.
*>>> CR #20 - Enhancement to force Short Text (Master data description) on PO screens.
*    Created by Ramses on 11.09.2013  - START   P30K905872

* Reverse back fieldstatus of metafield '69' (Metafield for Short Text column) to the original value '*' <-- Display
* after BADI ME_PROCESS_PO_CUST~PROCESS_ITEM to overwrite Short Text value with Master Data Description

*  CHECK sy-tcode EQ 'ME22N' OR       "Apply for all PO related screens (ME21N, ME22N, ME23N)
*        sy-tcode EQ 'ME23N'.

  DATA: l_items_cnt TYPE i.                                     "PO items counter

  DESCRIBE TABLE items LINES l_items_cnt.

  CHECK <tc>-current_line LE l_items_cnt.                       "Apply only to table with PO line items

  FIELD-SYMBOLS: <fs> LIKE LINE OF my_fieldselection.

  READ TABLE my_fieldselection ASSIGNING <fs>                   "Update fieldstatus of metafield '69'
                      WITH TABLE KEY metafield = '69'.

  IF sy-subrc = 0.
    <fs>-fieldstatus = '*'.
    UNASSIGN <fs>.
  ENDIF.

  LOOP AT SCREEN.

    CHECK SCREEN-NAME EQ 'MEPO1211-TXZ01'.                      "Re-process only for Short Text column based on updated fieldstatus on metafield '69'

    READ TABLE my_dynpro_fields INTO l_dynpro_field
                                WITH TABLE KEY screenname = screen-name.

    CHECK sy-subrc IS INITIAL.

    READ TABLE my_fieldselection INTO l_fieldselection
                      WITH TABLE KEY metafield = l_dynpro_field-metafield.
    IF sy-subrc IS INITIAL.
      l_field_status = l_fieldselection-fieldstatus.
    ELSE.
      l_field_status = default_field_status.
    ENDIF.

* special rule: display only fields
    IF l_dynpro_field-display_only EQ mmpur_yes.
      IF l_field_status EQ '.' OR l_field_status EQ '+'.
        l_field_status = '*'.
      ENDIF.
    ENDIF.

    CASE l_field_status.
      WHEN '+'.
        screen-required = '0'.
        screen-input    = '1'.
        screen-output   = '1'.
        screen-invisible = '0'.
      WHEN '.'.
        screen-required = '0'.
        screen-input    = '1'.
        screen-output   = '1'.
        screen-invisible = '0'.
      WHEN '-'.
        screen-required = '0'.
        screen-input = '0'.
*       screen-output = '0'.
        screen-output = '1'.   "Because of Field transports(note 541862)
        screen-invisible = '1'."out + invi => invisibel + aktiv #664320
*       screen-invisible = '0'."Becaus of Invisible Column
      WHEN '*'.
        screen-required = '0'.
        screen-input = '0'.
    ENDCASE.

* special rule: no display when initial
    IF l_dynpro_field-initial_no_disp EQ mmpur_yes.
      ASSIGN COMPONENT l_dynpro_field-position OF STRUCTURE
             <dyn_data> TO <f1>.
      IF sy-subrc IS INITIAL.
        IF <f1> IS INITIAL.
          screen-output = '0'.
        ENDIF.
      ENDIF.
    ENDIF.
* special rule: inactive when initial
    IF l_dynpro_field-initial_is_inactive EQ mmpur_yes.
      ASSIGN COMPONENT l_dynpro_field-position OF STRUCTURE
             <dyn_data> TO <f1>.
      IF sy-subrc IS INITIAL.
        IF <f1> IS INITIAL.
          screen-active = '0'.
        ENDIF.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.


ENDENHANCEMENT.
