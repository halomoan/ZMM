*&---------------------------------------------------------------------*
*&  Include           ZMM_LMEREPD06
*&---------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       CLASS lcl_factory DEFINITION
*---------------------------------------------------------------------*
CLASS lcl_factory DEFINITION.

  PUBLIC SECTION.

    METHODS: get_datablades_controller
                IMPORTING im_service    TYPE sy-cprog
                          im_options    TYPE mepo_initiator_options "#EC *
                EXPORTING ex_datablades TYPE mmpur_datablades
                          ex_controller TYPE REF TO
                          lcl_reporting_cnt_general,

* is generic reporting available for the report?
             is_supported IMPORTING im_service TYPE sy-repid
                          RETURNING value(re_category) TYPE lty_reporting_category,
* is generic reporting activated in customizing
             is_active    IMPORTING im_service TYPE sy-cprog
                                    im_scope   TYPE string40
                          RETURNING value(re_bool) TYPE mmpur_bool,
* build the log_group from customzing info
             get_log_group IMPORTING im_service TYPE sy-cprog "#EC *
                           RETURNING value(re_log_group)
                           TYPE slis_loggr,
* customizing purchdoc
             is_active_purchdoc IMPORTING im_scope TYPE string40
                                RETURNING value(re_bool) TYPE mmpur_bool,

* customizing requisitions
             is_active_eban     IMPORTING im_scope TYPE string40
                                RETURNING value(re_bool) TYPE mmpur_bool,

* others
             is_active_others   RETURNING value(re_bool) TYPE mmpur_bool.

  PRIVATE SECTION.
    DATA:
     mv_trace_active TYPE mmpur_bool.

    METHODS:
     get_purchdoc_controllers
        IMPORTING iv_service TYPE sycprog
        RETURNING value(et_datablades)  TYPE mmpur_datablades.

ENDCLASS.                    "lcl_factory
