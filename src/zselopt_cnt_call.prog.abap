*&---------------------------------------------------------------------*
*&  Include           SELOPT_CNT_CALL
*&---------------------------------------------------------------------*

* (Hidden) select options for call of report in workload count mode
* and/or for call from Purchasing Agent Portal
* - P_WLMEM  Memory-ID to pass workload to calling programm; also switch
*            for count mode (if not SPACE)
* - P_ALV    Flag to force display of results of selection as ALV grid
* - P_CNTLMT Upper limit for selection in workload count mode
* new for ERP 1.0 PA

PARAMETERS: p_wlmem  TYPE memory_id DEFAULT space NO-DISPLAY,
            p_alv    TYPE c         DEFAULT space NO-DISPLAY,
            p_cntlmt TYPE i         DEFAULT space NO-DISPLAY.
