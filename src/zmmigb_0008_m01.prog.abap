*&---------------------------------------------------------------------*
*&  Include           ZMMIGB_0008_M01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      MC_SSCR_RESTRICT_DATE
*&---------------------------------------------------------------------*
*       Restriction of Selection screen field
*&---------------------------------------------------------------------*
DEFINE MC_SSCR_RESTRICT.
  CASE &1.
    WHEN 'ONLY_EQ'.
      L_WA_RSOPTIONS-EQ = 'X'.
      L_WA_SSCR_OPT_LIST-NAME = &2.
      L_WA_SSCR_OPT_LIST-OPTIONS = L_WA_RSOPTIONS.
      INSERT L_WA_SSCR_OPT_LIST
      INTO TABLE L_S_SSCR_RESTRICT-OPT_LIST_TAB.
      CLEAR L_WA_SSCR_OPT_LIST.

      L_WA_SSCR_ASS-KIND = 'S'.
      L_WA_SSCR_ASS-NAME = &2.
      L_WA_SSCR_ASS-SG_MAIN = 'I'.
      L_WA_SSCR_ASS-OP_MAIN = &2.
      INSERT L_WA_SSCR_ASS INTO TABLE L_S_SSCR_RESTRICT-ASS_TAB.
      CLEAR L_WA_SSCR_ASS.
  ENDCASE.
END-OF-DEFINITION.
*&---------------------------------------------------------------------*
*&      MC_PROGRESS
*&---------------------------------------------------------------------*
*       Display progress indicator in current window
*&---------------------------------------------------------------------*
DEFINE MC_PROGRESS.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      PERCENTAGE = &1
      TEXT       = &2.
END-OF-DEFINITION.
*&---------------------------------------------------------------------*
*&      MC_FCAT
*&---------------------------------------------------------------------*
*       Create Field Catalog for ALV control
*&---------------------------------------------------------------------*
DEFINE MC_FCAT.
  CASE &1.
    WHEN '1'.
      L_WA_FCAT-FIELDNAME = &2.
      L_WA_FCAT-REF_TABNAME = &3.
      L_WA_FCAT-REF_FIELDNAME = &4.

      L_WA_FCAT-DDICTXT = &5.
      L_WA_FCAT-SELTEXT_L = &6.
      L_WA_FCAT-SELTEXT_M = &6.
      L_WA_FCAT-SELTEXT_S = &6.
      L_WA_FCAT-REPTEXT_DDIC = &6.
      INSERT L_WA_FCAT INTO TABLE L_IT_FCAT.
      CLEAR L_WA_FCAT.
    WHEN '2'.
      L_WA_FCAT-FIELDNAME = &2.
      L_WA_FCAT-INTTYPE = &3.
      L_WA_FCAT-OUTPUTLEN = &4.

      L_WA_FCAT-DDICTXT = &5.
      L_WA_FCAT-SELTEXT_L = &6.
      L_WA_FCAT-SELTEXT_M = &6.
      L_WA_FCAT-SELTEXT_S = &6.
      L_WA_FCAT-REPTEXT_DDIC = &6.
      INSERT L_WA_FCAT INTO TABLE L_IT_FCAT.
      CLEAR L_WA_FCAT.
  ENDCASE.
END-OF-DEFINITION.
*&---------------------------------------------------------------------*
*&      MC_AUTH_CHECK_COMPANY
*&---------------------------------------------------------------------*
*       Authority check for a Company
*&---------------------------------------------------------------------*
DEFINE MC_AUTH_CHECK_COMPANY.
  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
                 ID 'BUKRS' FIELD &1
                 ID 'ACTVT' FIELD '03'.
END-OF-DEFINITION.
