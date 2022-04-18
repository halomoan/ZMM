*&---------------------------------------------------------------------*
*&  Include           FM06BFPH
*&---------------------------------------------------------------------*
FORM modify_parkhold.


* new with park&hold TS
* in case for public sector customers select-option for memorytype
* shall be visible
* new badi to control park&hold functionality
* park&hold shall only be provided for public sector customers.
* standard customers should not be affected at all.
*  DATA badi               TYPE REF TO ME_PARKHOLD.
  DATA lv_parkhold_active TYPE c.

* check if park&hold is active in the system               "park&hold TS
  IF cl_parkhold_active=>parkhold_is_active( ) = cl_mmpur_constants=>yes.
    lv_parkhold_active = cl_mmpur_constants=>yes.
  ELSE.
    lv_parkhold_active = cl_mmpur_constants=>no.
  ENDIF.

* modify screen acording to park&hold
  IF lv_parkhold_active EQ cl_mmpur_constants=>yes.
    LOOP AT SCREEN.
      SEARCH screen-name FOR 'S_MEMTYP'.
      IF sy-subrc EQ 0.
        screen-active = '1'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      SEARCH screen-name FOR 'S_MEMTYP'.
      IF sy-subrc EQ 0.
        screen-active = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.
