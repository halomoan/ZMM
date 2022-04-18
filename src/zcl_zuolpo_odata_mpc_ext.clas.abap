class ZCL_ZUOLPO_ODATA_MPC_EXT definition
  public
  inheriting from ZCL_ZUOLPO_ODATA_MPC
  create public .

public section.

  types:
    BEGIN OF TS_DEEP.
          INCLUDE TYPE TS_POROOT.
          TYPES: POHeaderSet TYPE STANDARD TABLE OF TS_POHEADER WITH DEFAULT KEY,
                 POItemSet TYPE STANDARD TABLE OF TS_POITEM WITH DEFAULT KEY,
                 ItemScheduleSet TYPE STANDARD TABLE OF TS_ITEMSCHEDULE WITH DEFAULT KEY,
                 ItemAccountSet TYPE STANDARD TABLE OF TS_ITEMACCOUNT WITH DEFAULT KEY,
                 PotextitemSet TYPE STANDARD TABLE OF TS_POTEXTITEM WITH DEFAULT KEY,
         END OF TS_DEEP .

  methods DEFINE
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZUOLPO_ODATA_MPC_EXT IMPLEMENTATION.


  method DEFINE.
    super->define( ).


*******************************************************************	*****************************************************************
*   ENTITY - Deep Entity
******************************************************************  *****************************************************************
DATA: lo_entity_type    TYPE REF TO /iwbep/if_mgw_odata_entity_typ.

lo_entity_type = model->get_entity_type( iv_entity_name = 'POHeader' ). "#EC NOTEXT
lo_entity_type->bind_structure( iv_structure_name  = 	'ZCL_ZUOLPO_ODATA_MPC_EXT=>TS_DEEP' )."#EC NOTEXT

  endmethod.
ENDCLASS.
