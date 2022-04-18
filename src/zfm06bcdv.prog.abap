* declaration for the long text
DATA: BEGIN OF ICDTXT_BANF            OCCURS 20.
        INCLUDE STRUCTURE CDTXT.
DATA: END OF ICDTXT_BANF           .

DATA: UPD_ICDTXT_BANF            TYPE C.

* table with the NEW content of: EBAN
DATA: BEGIN OF XEBAN                           OCCURS 20.
        INCLUDE TYPE UEBAN                         .
DATA: END OF XEBAN                          .

* table with the OLD content of: EBAN
DATA: BEGIN OF YEBAN                           OCCURS 20.
        INCLUDE TYPE UEBAN                         .
DATA: END OF YEBAN                          .

DATA: UPD_EBAN                           TYPE C.


* table with the NEW content of: EBKN
DATA: BEGIN OF XEBKN                           OCCURS 20.
        INCLUDE STRUCTURE UEBKN                         .
DATA: END OF XEBKN                          .

* table with the OLD content of: EBKN
DATA: BEGIN OF YEBKN                           OCCURS 20.
        INCLUDE STRUCTURE UEBKN                         .
DATA: END OF YEBKN                          .

DATA: UPD_EBKN                           TYPE C.
