class ZAICO_EVENT_IMPORT_PORT_TYPE definition
  public
  inheriting from CL_PROXY_CLIENT
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !LOGICAL_PORT_NAME type PRX_LOGICAL_PORT_NAME optional
    raising
      CX_AI_SYSTEM_FAULT .
  methods EVENT_IMPORT_OPERATION
    importing
      !INPUT type ZAIEVENT_IMPORT_REQUEST_MESSA1
    exporting
      !OUTPUT type ZAIEVENT_IMPORT_REPLY_MESSAGE1
    raising
      CX_AI_SYSTEM_FAULT .
protected section.
private section.
ENDCLASS.



CLASS ZAICO_EVENT_IMPORT_PORT_TYPE IMPLEMENTATION.


  method CONSTRUCTOR.

  super->constructor(
    class_name          = 'ZAICO_EVENT_IMPORT_PORT_TYPE'
    logical_port_name   = logical_port_name
  ).

  endmethod.


  method EVENT_IMPORT_OPERATION.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'INPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of INPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'OUTPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of OUTPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'EVENT_IMPORT_OPERATION'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.
ENDCLASS.
