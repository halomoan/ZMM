"Name: \PR:RM06W003\IC:RM06W003\SE:END\EI
ENHANCEMENT 0 ZMM_ME05_ADDPARAM.
*  at selection-screen output.
    LOOP AT SCREEN.
      CASE screen-name.
        WHEN 'W_EKRG' OR 'W_WRKS' OR 'W_LOW' OR 'W_ZERO'.
          IF sy-tcode EQ 'ZME05'.
            screen-active = 1.
            screen-invisible = 0.
          ELSE.
            screen-active = 0.
            screen-invisible = 1.
          ENDIF.
          modify screen.
      ENDCASE.
    ENDLOOP.

  INITIALIZATION.
    IF sy-tcode EQ 'ZME05'.
      %_W_LOW_%_APP_%-TEXT = |Select only the lowest price|.
      %_W_ZERO_%_APP_%-TEXT = |Ignore zero|.
      %_W_EKRG_%_APP_%-TEXT = |Purchasing Org.|.
      %_W_WRKS_%_APP_%-TEXT = |Plant|.
    ENDIF.
ENDENHANCEMENT.
