class ZAICO_AWARD_DOWNLOAD_PORT_TYPE definition
  public
  inheriting from CL_PROXY_CLIENT
  create public .

public section.

  methods AWARD_DOWNLOAD_OPERATION
    importing
      !INPUT type ZAIAWARD_DOWNLOAD_REQUEST_MES1
    exporting
      !OUTPUT type ZAIAWARD_DOWNLOAD_REPLY_MESSA1
    raising
      CX_AI_SYSTEM_FAULT .
  methods CONSTRUCTOR
    importing
      !LOGICAL_PORT_NAME type PRX_LOGICAL_PORT_NAME optional
    raising
      CX_AI_SYSTEM_FAULT .
protected section.
private section.
ENDCLASS.



CLASS ZAICO_AWARD_DOWNLOAD_PORT_TYPE IMPLEMENTATION.


  method AWARD_DOWNLOAD_OPERATION.

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
      method_name = 'AWARD_DOWNLOAD_OPERATION'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method CONSTRUCTOR.

  super->constructor(
    class_name          = 'ZAICO_AWARD_DOWNLOAD_PORT_TYPE'
    logical_port_name   = logical_port_name
  ).

  endmethod.
ENDCLASS.
