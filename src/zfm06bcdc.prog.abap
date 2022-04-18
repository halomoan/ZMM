FORM CD_CALL_BANF                          .
  IF   ( UPD_EBAN                           NE SPACE )
    OR ( UPD_EBKN                           NE SPACE )
    OR ( UPD_ICDTXT_BANF            NE SPACE )
  .
    CALL FUNCTION 'SWE_REQUESTER_TO_UPDATE'.
    CALL FUNCTION 'BANF_WRITE_DOCUMENT           ' IN UPDATE TASK
        EXPORTING
          OBJECTID                = OBJECTID
          TCODE                   = TCODE
          UTIME                   = UTIME
          UDATE                   = UDATE
          USERNAME                = USERNAME
          PLANNED_CHANGE_NUMBER   = PLANNED_CHANGE_NUMBER
          OBJECT_CHANGE_INDICATOR = CDOC_UPD_OBJECT
          PLANNED_OR_REAL_CHANGES = CDOC_PLANNED_OR_REAL
          NO_CHANGE_POINTERS      = CDOC_NO_CHANGE_POINTERS
          UPD_EBAN
                      = UPD_EBAN
          UPD_EBKN
                      = UPD_EBKN
          UPD_ICDTXT_BANF
                      = UPD_ICDTXT_BANF
        TABLES
          ICDTXT_BANF
                      = ICDTXT_BANF
          XEBAN
                      = XEBAN
          YEBAN
                      = YEBAN
          XEBKN
                      = XEBKN
          YEBKN
                      = YEBKN
    .
  ENDIF.
  CLEAR PLANNED_CHANGE_NUMBER.
ENDFORM.
