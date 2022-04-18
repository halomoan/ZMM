*&--------------------------------------------------------------------*
*&      Form  fieldcat_init_grid
*&--------------------------------------------------------------------*
FORM fieldcat_init_grid USING  l_fieldcat TYPE slis_t_fieldcat_alv.

  DATA: fieldcat TYPE slis_fieldcat_alv.

  g_tabname_grid = 'GT_OUTTAB_GRID'.

*- Liste aus NAST automat. erzeugen
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_internal_tabname     = g_tabname_grid
      i_structure_name       = 'NAST'
      i_client_never_display = 'X'
    CHANGING
      ct_fieldcat            = l_fieldcat
    EXCEPTIONS
      OTHERS                 = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
*- Ergebnisse modifizieren
  LOOP AT l_fieldcat INTO fieldcat.
    CASE fieldcat-fieldname.
      WHEN 'KAPPL'.
        CLEAR fieldcat-key.
        fieldcat-no_out = 'X'.
      WHEN 'OBJKY'.
        CLEAR fieldcat-key.
        fieldcat-no_out = 'X'.
      WHEN 'KSCHL'.
        CLEAR fieldcat-key.
        fieldcat-emphasize = 'X'.
      WHEN 'SPRAS'.
        CLEAR fieldcat-key.
      WHEN 'PARNR'.
        CLEAR fieldcat-key.
      WHEN 'PARVW'.
        CLEAR fieldcat-key.
      WHEN 'ERDAT'.
        CLEAR fieldcat-key.
      WHEN 'ERUHR'.
        CLEAR fieldcat-key.
      WHEN 'VSZTP'.
      WHEN 'MANUE'.
      WHEN 'USNAM'.
      WHEN 'LDEST'.
      WHEN 'DSNAM'.
      WHEN 'TELFX'.
      WHEN 'AENDE'.
      WHEN OTHERS.
        fieldcat-no_out = 'X'.
    ENDCASE.
    MODIFY l_fieldcat FROM fieldcat.
  ENDLOOP.
* Belegnummer
  CLEAR fieldcat.
  fieldcat-fieldname    = 'EBELN'.
  fieldcat-tabname      =  g_tabname_grid.
  fieldcat-ref_tabname  = 'EKKO'.
  APPEND fieldcat TO l_fieldcat.
* Lieferant
  CLEAR fieldcat.
  fieldcat-fieldname    = 'LIFNR'.
  fieldcat-tabname      =  g_tabname_grid.
  fieldcat-ref_tabname  = 'EKKO'.
  APPEND fieldcat TO l_fieldcat.
* Lieferantenname
  CLEAR fieldcat.
  fieldcat-fieldname    = 'NAME1'.
  fieldcat-tabname      =  g_tabname_grid.
  fieldcat-ref_tabname  = 'LFA1'.
  APPEND fieldcat TO l_fieldcat.
* Einkäufergruppe
  CLEAR fieldcat.
  fieldcat-fieldname    = 'EKGRP'.
  fieldcat-tabname      =  g_tabname_grid.
  fieldcat-ref_tabname  = 'EKKO'.
  APPEND fieldcat TO l_fieldcat.
* Belegdatum
  CLEAR fieldcat.
  fieldcat-fieldname    = 'BEDAT'.
  fieldcat-tabname      =  g_tabname_grid.
  fieldcat-ref_tabname  = 'EKKO'.
  APPEND fieldcat TO l_fieldcat.
* Created by field                                                                Added_19032012
  CLEAR fieldcat.
  fieldcat-fieldname    = 'ERNAM'.
  fieldcat-tabname      =  g_tabname_grid.
  fieldcat-ref_tabname  = 'EKKO'.
  APPEND fieldcat TO l_fieldcat.


* Status
  CLEAR fieldcat.
  fieldcat-fieldname    = 'SYMBOL'.
  fieldcat-tabname      =  g_tabname_grid.
  fieldcat-icon         = 'X'.
  fieldcat-col_pos      = 0.
  fieldcat-outputlen    = 2.
  fieldcat-seltext_l    = text-012.
  fieldcat-seltext_m    = text-012.
  fieldcat-seltext_s    = text-012.
  fieldcat-ddictxt      = 'M'.
  APPEND fieldcat TO l_fieldcat.

ENDFORM.                    "fieldcat_init_grid

*&--------------------------------------------------------------------*
*&      Form  listausgabe_grid
*&--------------------------------------------------------------------*
FORM listausgabe_grid.

  g_layout-box_fieldname = 'BOX'.
  g_layout-box_tabname   = g_tabname_item.
  g_layout-zebra         = 'X'.
  g_layout-f2code        = '9NDE'.

  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name                  = icon_checked
      info                  = text-010
    IMPORTING
      RESULT                = gf_icon_checked
    EXCEPTIONS
      icon_not_found        = 1
      outputfield_too_short = 2
      OTHERS                = 3.
  IF sy-subrc <> 0.
    gf_icon_checked = icon_checked.
  ENDIF.

  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name                  = icon_incomplete
      info                  = text-011
    IMPORTING
      RESULT                = gf_icon_incomplete
    EXCEPTIONS
      icon_not_found        = 1
      outputfield_too_short = 2
      OTHERS                = 3.
  IF sy-subrc <> 0.
    gf_icon_incomplete = icon_incomplete.
  ENDIF.


  LOOP AT xitem.
    IF xitem-vstat EQ '1'.
      xitem-symbol = gf_icon_checked.
      MODIFY xitem.
    ELSEIF xitem-vstat EQ '2'.
      xitem-symbol = gf_icon_incomplete.
      MODIFY xitem.
    ENDIF.
  ENDLOOP.

* merge xheader and xitem
  CLEAR gt_outtab_grid[].
  LOOP AT xheader.
    LOOP AT xitem WHERE ebeln EQ xheader-ebeln.
      MOVE-CORRESPONDING xheader TO gt_outtab_grid.
      MOVE-CORRESPONDING xitem   TO gt_outtab_grid.
      APPEND gt_outtab_grid.
    ENDLOOP.
  ENDLOOP.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = g_repid
      i_callback_pf_status_set = 'STATUS'
      i_callback_user_command  = 'USER_COMMAND'
      is_layout                = g_layout
      it_fieldcat              = g_fieldcat[]
      i_save                   = 'A'
      is_variant               = g_variant
    IMPORTING
      es_exit_caused_by_user   = i_slis_exit_by_user
    TABLES
      t_outtab                 = gt_outtab_grid
    EXCEPTIONS
      OTHERS                   = 0.

  IF i_slis_exit_by_user-exit NE space OR
     i_slis_exit_by_user-back NE space OR
     i_slis_exit_by_user-cancel NE space.
    IF updat NE space.                 " wird nicht mehr verwendet
      CALL FUNCTION 'RV_MESSAGES_UPDATE'
        EXPORTING
          msg_no_update_task = 'X'.
    ENDIF.
    COMMIT WORK.
    IF sy-calld EQ space.
      LEAVE TO TRANSACTION sy-tcode.
    ELSE.
      LEAVE.
    ENDIF.
  ENDIF.

ENDFORM.                    "listausgabe_grid

*&--------------------------------------------------------------------*
*&      Form  variante_ermitteln_grid
*&--------------------------------------------------------------------*
FORM variante_ermitteln_grid.
  CLEAR g_variant.
  g_repid = sy-repid.
  g_variant-report = g_repid.
  g_variant-handle = '0001'.
ENDFORM.                    "variante_ermitteln_grid
