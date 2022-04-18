*---------------------------------------------------------------------*
*       FORM BAN_GESAMTFRG_001                                        *
*---------------------------------------------------------------------*
*  'Kopfzeile' für Banfen, die der Gesamtfreigabe unterliegen          *
*---------------------------------------------------------------------*
FORM BAN_GSFRG_001.
  CHECK NOT GS_BANF    IS INITIAL.
  CHECK NOT EBAN-GSFRG IS INITIAL.
*... 'Kopfzeilen' der Banf bei Gesamtfreigabe kennzeichnen ...........*
  HIDE-GSFRG = EBAN-GSFRG.
  WRITE: /  SY-VLINE.
  IF T16LH-XMKEX NE SPACE.
    WRITE 2 BAN-SELKZ AS CHECKBOX.
  ELSE.
    WRITE 2 BAN-SELKZ AS CHECKBOX INPUT OFF.
  ENDIF.
*ENHANCEMENT-SECTION     FM06BFLI_BAN_GSFRG_001_01 SPOTS ES_SAPFM06B.
  WRITE:  4 EBAN-BANFN,
            TEXT-077,
         54 ICON_FIELD AS ICON,
         81 SY-VLINE.
* write at 50 icon_yellow_light as icon.
  HIDE: HIDE-INDEX, HIDE-GSFRG.
  WRITE: / SY-VLINE,
         4 FLINE,
        81 SY-VLINE.
*END-ENHANCEMENT-SECTION.
  HIDE: HIDE-INDEX, HIDE-GSFRG.
ENDFORM.
