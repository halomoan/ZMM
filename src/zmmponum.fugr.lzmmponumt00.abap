*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZMMGB_NUMRANGE..................................*
DATA:  BEGIN OF STATUS_ZMMGB_NUMRANGE                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMMGB_NUMRANGE                .
CONTROLS: TCTRL_ZMMGB_NUMRANGE
            TYPE TABLEVIEW USING SCREEN '0001'.
*...processing: ZMM_PO_EMAIL....................................*
DATA:  BEGIN OF STATUS_ZMM_PO_EMAIL                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMM_PO_EMAIL                  .
CONTROLS: TCTRL_ZMM_PO_EMAIL
            TYPE TABLEVIEW USING SCREEN '0002'.
*.........table declarations:.................................*
TABLES: *ZMMGB_NUMRANGE                .
TABLES: *ZMM_PO_EMAIL                  .
TABLES: ZMMGB_NUMRANGE                 .
TABLES: ZMM_PO_EMAIL                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
