*&---------------------------------------------------------------------*
*&  Include           ZXM06U44
*&---------------------------------------------------------------------*

*   GOS attachment transfer from PR to PO

    IF sy-tcode EQ 'ME21N' OR
       sy-tcode EQ 'ME59N' OR
       sy-tcode EQ 'ZME59N'.

      IF NOT I_EKKO-EBELN IS INITIAL.

         LOOP AT XEKPO WHERE BANFN IS NOT INITIAL.

           CALL FUNCTION 'ZMM_GOS_EBAN_EKKO'
             EXPORTING
*              GS_OBJECT       =
               i_ebeln         = I_EKKO-EBELN
               i_banfn         = XEKPO-BANFN
                     .
         ENDLOOP.

      ENDIF.

    ENDIF.


*   PO Approval notifications based on Release Group and Release Code
CHECK I_EKKO-FRGGR IS NOT INITIAL AND
      I_EKKO-FRGSX IS NOT INITIAL AND
      I_EKKO-FRGKE IS NOT INITIAL.

DATA: ins_items TYPE c,
      upd_items TYPE c.


    IF sy-tcode EQ 'ME21N' OR
       sy-tcode EQ 'ME29N' OR
       sy-tcode EQ 'ME59N' OR
       sy-tcode EQ 'ZME59N' OR
       sy-tcode EQ 'ZMM_0007' OR
       SY-CPROG EQ 'ZMMRGB_0006'.

      PERFORM po_approver_email(ZMM_PO_APPROVER_NOTIFICATION) TABLES XEKPO
                                                                     XEKET
                                                              USING  I_EKKO
                                                                     I_EKKO_OLD.

    ELSEIF sy-tcode EQ 'ME22N' OR
           sy-tcode EQ 'ME23N'.

*   If PO changes are performed from ME22N/ME23N screens
*   further checks are needed before executing email notification program


**     Check just inserted items
*      LOOP AT XEKPO WHERE KZ = 'I' .
*        ins_items = 'X'.
*        EXIT.
*      ENDLOOP.

**     Check just deleted/undeleted and changed items
*      LOOP AT XEKPO WHERE KZ = 'U'.
*        READ TABLE YEKPO WITH KEY ebeln = xekpo-ebeln
*                                  ebelp = xekpo-ebelp.
*        IF sy-subrc = 0.
*          IF xekpo-loekz NE yekpo-loekz OR
*             xekpo-netwr NE yekpo-netwr.
*              upd_items = 'X'.
*          ENDIF.
*        ENDIF.
*      ENDLOOP.

      CHECK ( I_EKKO_OLD-FRGGR NE I_EKKO-FRGGR ) OR                             "Purch Org changed --> impact on Release Group change
            ( I_EKKO_OLD-FRGSX NE I_EKKO-FRGSX ) OR                             "Purch Org changed --> impact on Release Strategy change
            ( I_EKKO_OLD-FRGKE EQ 'G' AND I_EKKO-FRGKE EQ 'B' ) OR              "Price or Amount changed --> impact on Release Code is reset
            ( I_EKKO_OLD-PROCSTAT EQ '08' AND I_EKKO-PROCSTAT EQ '03') "OR       "PO Rejection is cancelled
*            ( ins_items IS NOT INITIAL ) OR
*            ( upd_items IS NOT INITIAL )
      .

      PERFORM po_approver_email(ZMM_PO_APPROVER_NOTIFICATION) TABLES XEKPO
                                                                     XEKET
                                                              USING  I_EKKO
                                                                     I_EKKO_OLD.

    ENDIF.
