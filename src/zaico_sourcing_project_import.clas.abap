class ZAICO_SOURCING_PROJECT_IMPORT definition
  public
  inheriting from CL_PROXY_CLIENT
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !LOGICAL_PORT_NAME type PRX_LOGICAL_PORT_NAME optional
    raising
      CX_AI_SYSTEM_FAULT .
  methods SOURCING_PROJECT_IMPORT_OPERAT
    importing
      !INPUT type ZAISOURCING_PROJECT_IMPORT_RE1
    exporting
      !OUTPUT type ZAISOURCING_PROJECT_IMPORT_RE2
    raising
      CX_AI_SYSTEM_FAULT .
protected section.
private section.
ENDCLASS.



CLASS ZAICO_SOURCING_PROJECT_IMPORT IMPLEMENTATION.


  method CONSTRUCTOR.

  super->constructor(
    class_name          = 'ZAICO_SOURCING_PROJECT_IMPORT'
    logical_port_name   = logical_port_name
  ).

  endmethod.


  method SOURCING_PROJECT_IMPORT_OPERAT.

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
      method_name = 'SOURCING_PROJECT_IMPORT_OPERAT'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.
ENDCLASS.
