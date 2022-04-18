*eject
*----------------------------------------------------------------------*
*        Zeile Bezugsquelle Rahmenvertrag                              *
*----------------------------------------------------------------------*
FORM ban_zuord USING baz_flag.
* All Move-Instructions were replaced by Concatenate-Instructions, see
* note 448478
  CLEAR hline.
*- Text zm Status aus T16LA -------------------------------------------*
  CLEAR t16la.
  IF ban-updk1 NE space.
    IF ban-updk1 NE zner.
      SELECT SINGLE * FROM t16la WHERE spras EQ sy-langu
                                   AND updkz EQ ban-updk1.
    ELSE.
      SELECT SINGLE * FROM t16la WHERE spras EQ sy-langu
                                   AND updkz EQ znew.
    ENDIF.
  ENDIF.

  IF ban-updk1 EQ znew OR
     ban-updk1 EQ zold OR
     ban-updk1 EQ zner.
*- Rahmenvertrag ------------------------------------------------------*
    IF ban-konnr NE space.
*     MOVE  text-052  TO hline(77).
*     MOVE  ban-konnr TO hline+19(10).
*     MOVE  ban-ktpnr TO hline+30(5).
      CONCATENATE space text-052 INTO hline(77).
      CONCATENATE space ban-konnr INTO hline(29) SEPARATED BY hline(19).
      CONCATENATE space ban-ktpnr INTO hline(35) SEPARATED BY hline(30).
      IF ban-flief NE space.
*        MOVE text-058 TO hline+36(10).
*        MOVE ban-flief TO hline+46(10).
        CONCATENATE space text-058 INTO hline(46) SEPARATED BY hline(36).
        CONCATENATE space ban-flief INTO hline(56) SEPARATED BY hline(46).
      ELSE.
        IF ban-reswk NE space.
*          MOVE text-062 TO hline+36(10).
*          MOVE ban-reswk TO hline+47(04).
          CONCATENATE space text-062 INTO hline(46) SEPARATED BY hline(36).
          CONCATENATE space ban-reswk INTO hline(51) SEPARATED BY hline(47).
        ENDIF.
      ENDIF.
* Begin CCP
*      IF BAN-EKORG NE SPACE.
      IF ban-ekorg NE space AND ban-beswk NE space.
*        MOVE text-cc1  TO hline+57(7).
*        MOVE ban-ekorg TO hline+63(4).
*        MOVE text-cc2  TO hline+68(4).
*        MOVE ban-beswk TO hline+72(4).
        CONCATENATE space text-cc1 INTO hline(64) SEPARATED BY hline(57).
        CONCATENATE space ban-ekorg INTO hline(67) SEPARATED BY hline(63).
        CONCATENATE space text-cc2 INTO hline(72) SEPARATED BY hline(68).
        CONCATENATE space ban-beswk INTO hline(76) SEPARATED BY hline(72).
      ELSEIF ban-ekorg EQ space AND ban-beswk NE space.
*        MOVE text-cc4  TO hline+57(12).
*        MOVE ban-beswk TO hline+69(4).
        CONCATENATE space text-cc4 INTO hline(69) SEPARATED BY hline(57).
        CONCATENATE space ban-beswk INTO hline(73) SEPARATED BY hline(69).
      ELSEIF ban-ekorg NE space.
* End CCP
*        MOVE text-061 TO hline+57(12).
*        MOVE ban-ekorg TO hline+69(4).
        CONCATENATE space text-061 INTO hline(69) SEPARATED BY hline(57).
        CONCATENATE space ban-ekorg INTO hline(73) SEPARATED BY hline(69).
      ENDIF.
*- Infosatz -----------------------------------------------------------*
    ELSEIF ban-infnr NE space.
*      MOVE  text-051  TO hline(77).
*      MOVE  ban-infnr TO hline+19(10).
*      MOVE  text-058  TO hline+30(10).
*      MOVE  ban-flief TO hline+40(10).
      CONCATENATE space text-051 INTO hline(77).
      CONCATENATE space ban-infnr INTO hline(29) SEPARATED BY hline(19).
      CONCATENATE space text-058 INTO hline(40) SEPARATED BY hline(30).
      CONCATENATE space ban-flief INTO hline(50) SEPARATED BY hline(40).
* Begin CCP
*      MOVE  text-061  TO hline+51(12).
*      MOVE  ban-ekorg TO hline+63(4).
*      MOVE  text-cc1  TO hline+51(6).                        "448478
*      MOVE  ban-ekorg TO hline+57(4).                        "448478
      CONCATENATE space text-cc1 INTO hline(57) SEPARATED BY hline(51).
      CONCATENATE space ban-ekorg INTO hline(61) SEPARATED BY hline(57).
* CCP procuring plant
      IF ban-beswk NE space.
*        MOVE text-cc2  TO hline+62(7).
*        MOVE ban-beswk TO hline+69(4).
        CONCATENATE space text-cc2 INTO hline(69) SEPARATED BY hline(62).
        CONCATENATE space ban-beswk INTO hline(73) SEPARATED BY hline(69).
      ENDIF.
* End CPP
*- Rahmenbestellung ---------------------------------------------------*
    ELSEIF ban-fordn NE space.
*      MOVE  text-070  TO hline(77).
*      MOVE  ban-fordn TO hline+19(10).
*      MOVE  ban-fordp TO hline+30(5).
      CONCATENATE space text-070 INTO hline(77).
      CONCATENATE space ban-fordn INTO hline(29) SEPARATED BY hline(19).
      CONCATENATE space ban-fordp INTO hline(35) SEPARATED BY hline(30).
      IF ban-flief NE space.
*        MOVE text-058 TO hline+36(10).
*        MOVE ban-flief TO hline+46(10).
        CONCATENATE space text-058 INTO hline(46) SEPARATED BY hline(36).
        CONCATENATE space ban-flief INTO hline(56) SEPARATED BY hline(46).
      ENDIF.
* Begin CCP
*      IF ban-ekorg NE space.
* CCP procuring plant
      IF ban-ekorg NE space AND ban-beswk NE space.
*        MOVE text-cc1  TO hline+57(7).
*        MOVE ban-ekorg TO hline+64(4).
*        MOVE text-cc2  TO hline+68(6).
*        MOVE ban-beswk TO hline+74(4).
        CONCATENATE space text-cc1 INTO hline(64) SEPARATED BY hline(57).
        CONCATENATE space ban-ekorg INTO hline(68) SEPARATED BY hline(64).
        CONCATENATE space text-cc2 INTO hline(74) SEPARATED BY hline(68).
        CONCATENATE space ban-beswk INTO hline(78) SEPARATED BY hline(74).
      ELSEIF ban-ekorg EQ space AND ban-beswk NE space.
*        MOVE text-cc4  TO hline+57(12).
*        MOVE ban-beswk TO hline+69(4).
        CONCATENATE space text-cc4 INTO hline(69) SEPARATED BY hline(57).
        CONCATENATE space ban-beswk INTO hline(73) SEPARATED BY hline(69).
      ELSEIF ban-ekorg NE space.
* End CCP
*        MOVE text-061 TO hline+57(12).
*        MOVE ban-ekorg TO hline+69(4).
        CONCATENATE space text-061 INTO hline(69) SEPARATED BY hline(57).
        CONCATENATE space ban-ekorg INTO hline(73) SEPARATED BY hline(69).
      ENDIF.
*- Fester Lieferant ---------------------------------------------------*
    ELSEIF ban-flief NE space.
      CLEAR lfa1-name1.
* ALRK021852 begin insert
      CALL FUNCTION 'WY_LFA1_GET_NAME'
        EXPORTING
          pi_lifnr         = ban-flief
        IMPORTING
          po_name1         = lfa1-name1
        EXCEPTIONS
          no_records_found = 1
          OTHERS           = 2.
*ALRK021852 end insert - begin delete
*     call function 'ME_GET_SUPPLIER'
*       exporting
*         supplier   = ban-flief
*       importing
*         name       = lfa1-name1
*       exceptions
*         error_message = 01.
*ALRK021852 end delete
*      MOVE  text-050  TO hline(77).
*      MOVE  ban-flief TO hline+19(10).
*      MOVE  lfa1-name1  TO hline+30(30).
      CONCATENATE space text-050 INTO hline(77).
      CONCATENATE space ban-flief INTO hline(29) SEPARATED BY hline(19).
      CONCATENATE space lfa1-name1 INTO hline(60) SEPARATED BY hline(30).
* Begin CCP
*      IF ban-ekorg NE space.
* CCP procuring plant
      IF ban-ekorg NE space AND ban-beswk NE space.
*        MOVE text-cc1  TO hline+51(7).
*        MOVE ban-ekorg TO hline+59(4).
*        MOVE text-cc2  TO hline+64(4).
*        MOVE ban-beswk TO hline+69(4).
        CONCATENATE space text-cc1 INTO hline(58) SEPARATED BY hline(51).
        CONCATENATE space ban-ekorg INTO hline(63) SEPARATED BY hline(59).
        CONCATENATE space text-cc2 INTO hline(68) SEPARATED BY hline(64).
        CONCATENATE space ban-beswk INTO hline(73) SEPARATED BY hline(69).
      ELSEIF ban-ekorg EQ space AND ban-beswk NE space.
*        MOVE text-cc4  TO hline+51(19).
*        MOVE ban-beswk TO hline+69(4).
        CONCATENATE space text-cc4 INTO hline(70) SEPARATED BY hline(51).
        CONCATENATE space ban-beswk INTO hline(73) SEPARATED BY hline(69).
      ELSEIF ban-ekorg NE space.
* End CCP
*        MOVE text-061   TO hline+51(12).
*        MOVE ban-ekorg TO hline+63(4).
        CONCATENATE space text-061 INTO hline(63) SEPARATED BY hline(51).
        CONCATENATE space ban-ekorg INTO hline(67) SEPARATED BY hline(63).

      ENDIF.
*- Lieferwerk ---------------------------------------------------------*
    ELSE.
      IF ban-reswk NE space.                                "82362
*        MOVE  text-053 TO hline(77).
*        MOVE  ban-reswk TO hline+19(4).
        CONCATENATE space text-053 INTO hline(77).
        CONCATENATE space ban-reswk INTO hline(23) SEPARATED BY hline(19).
      ENDIF.                                                "82362
* Begin CCP
*      IF ban-ekorg NE space.
* CCP procuring plant
      IF ban-ekorg NE space AND ban-beswk NE space.
*        MOVE text-cc1  TO hline+51(7).
*        MOVE ban-ekorg TO hline+59(4).
*        MOVE text-cc2  TO hline+64(4).
*        MOVE ban-beswk TO hline+69(4).
        CONCATENATE space text-cc1 INTO hline(58) SEPARATED BY hline(51).
        CONCATENATE space ban-ekorg INTO hline(63) SEPARATED BY hline(59).
        CONCATENATE space text-cc2 INTO hline(68) SEPARATED BY hline(64).
        CONCATENATE space ban-beswk INTO hline(73) SEPARATED BY hline(69).
      ELSEIF ban-ekorg EQ space AND ban-beswk NE space.
*        MOVE text-cc4  TO hline+51(19).
*        MOVE ban-beswk TO hline+69(4).
        CONCATENATE space text-cc4 INTO hline(70) SEPARATED BY hline(51).
        CONCATENATE space ban-beswk INTO hline(73) SEPARATED BY hline(69).
      ELSEIF ban-ekorg NE space.
* End CCP
*        MOVE text-061   TO hline+51(12).
*        MOVE ban-ekorg TO hline+63(4).
        CONCATENATE space text-061 INTO hline(63) SEPARATED BY hline(51).
        CONCATENATE space ban-ekorg INTO hline(67) SEPARATED BY hline(63).
      ENDIF.
    ENDIF.
    IF baz_flag NE space.
*      MOVE text-063 TO hline+74(3).
      CONCATENATE space text-063 INTO hline(77) SEPARATED BY hline(74).
    ENDIF.
*- Anfragezuordnung ---------------------------------------------------*
  ELSEIF ban-updk1 EQ anfr.
*    MOVE  text-103 TO hline(77).
    CONCATENATE space text-103 INTO hline(77).
*- Anfragezuordnung mit Lieferant -------------------------------------*
  ELSEIF ban-updk1 EQ alif.
*    MOVE  text-105 TO hline(77).
*    MOVE ban-slief TO hline+48(10).
    CONCATENATE space text-105 INTO hline(77).
    CONCATENATE space ban-slief INTO hline(58) SEPARATED BY hline(48).
*- Anfragezuordnung mehrere Lieferanten -------------------------------*
  ELSEIF ban-updk1 EQ aman.
*    MOVE  text-107 TO hline(77).
    CONCATENATE space text-107 INTO hline(77).
*- Zuordnung zurückgesetzt --------------------------------------------*
  ELSEIF ban-updk1 EQ zres.
*    MOVE  text-115 TO hline(77).
    CONCATENATE space text-115 INTO hline(77).
* Begin CCP
    IF NOT ban-beswk IS INITIAL.
*      MOVE text-cc4 TO hline+51(17).
*      MOVE ban-beswk TO hline+69(4).
      CONCATENATE space text-cc4 INTO hline(68) SEPARATED BY hline(51).
      CONCATENATE space ban-beswk INTO hline(73) SEPARATED BY hline(69).
    ENDIF.
* End CCP
*- allgemeine Änderung ------------------------------------------------*
  ELSEIF ban-updk1 EQ aend.
*    MOVE  text-123 TO hline(77).
      CONCATENATE space text-123 INTO hline(77).
* Begin CCP
* CCP  procuring plant
  ELSEIF ban-updk1 EQ space AND NOT ban-beswk IS INITIAL.
*    MOVE text-cc4 TO hline+51(16).
*    MOVE ban-beswk TO hline+69(4).
      CONCATENATE space text-cc4 INTO hline(67) SEPARATED BY hline(51).
      CONCATENATE space ban-beswk INTO hline(73) SEPARATED BY hline(69).
* End CCP
  ENDIF.

*- Freigabe -----------------------------------------------------------*
  CLEAR fline.
*- Text zm Status aus T16LA -------------------------------------------*
  CLEAR *t16la.
  IF ban-updk3 NE space.
    SELECT SINGLE * FROM t16la INTO *t16la
                               WHERE spras EQ sy-langu
                                 AND updkz EQ ban-updk3.
  ENDIF.
*- Freigabe -----------------------------------------------------------*
  IF ban-frgst NE space.
    IF ban-frggr NE space.
*      fline(2) = ban-frggr.
*      fline+2(1) = '/'.
*      fline+3(2) = ban-frgst.
      CONCATENATE space ban-frggr INTO fline(2).
      CONCATENATE space '/' INTO fline(3) SEPARATED BY fline(2).
      CONCATENATE space ban-frgst INTO fline(5) SEPARATED BY fline(3).
      IF t16ft-frggr NE ban-frggr OR
         t16ft-frgsx NE ban-frgst.
        SELECT SINGLE * FROM t16ft WHERE spras EQ sy-langu
                                     AND frggr EQ ban-frggr
                                     AND frgsx EQ ban-frgst.
      ENDIF.
*      fline+6(20) = t16ft-frgxt.
    CONCATENATE space t16ft-frgxt INTO fline(26) SEPARATED BY fline(6).
    ELSE.
*      fline(2) = ban-frgst.
      CONCATENATE space ban-frgst INTO fline(2).
    ENDIF.

*    fline+27(1) = ban-frgkz.
    CONCATENATE space ban-frgkz INTO fline(28) SEPARATED BY fline(27).
    IF t161u-frgkz NE ban-frgkz.
      SELECT SINGLE * FROM t161u WHERE spras EQ sy-langu
                                   AND frgkz EQ ban-frgkz.
    ENDIF.
*    fline+29(20) = t161u-fkztx.
    CONCATENATE space t161u-fkztx INTO fline(49) SEPARATED BY fline(29).
    IF ban-updk3 EQ fres.
*      MOVE  text-104 TO fline+50(27).
      CONCATENATE space text-104 INTO fline(77) SEPARATED BY fline(50).
      WRITE icon_green_light TO icon_field.
*- Einzelfreigabe -----------------------------------------------------*
    ELSEIF ban-updk3 EQ free.
*      MOVE  text-106 TO fline+50(27).
      CONCATENATE space text-106 INTO fline(77) SEPARATED BY fline(50).
      WRITE icon_green_light TO icon_field.
*- Einzelfreigabe - nur Änderung ---------------
    ELSEIF ban-updk3 EQ scha.
*      MOVE  text-117 TO fline+50(27).
      CONCATENATE space text-117 INTO fline(77) SEPARATED BY fline(50).
*- Einzelfreigabe - Freigabe zurückgenommen ----
    ELSEIF ban-updk3 EQ nfre.
*      MOVE  text-109 TO fline+50(27).
      CONCATENATE space text-109 INTO fline(77) SEPARATED BY fline(50).
    ELSE.
      IF sy-tcode EQ 'ME55' OR sy-tcode EQ 'ME5F'.
        IF ban-selkf EQ 0.
          IF NOT ban-gsfrg IS INITIAL AND
                 ban-az_pos NE ban-sl_pos.
*... Banf ist nur über die Einzelfreigabe bearbeitbar, da nicht alle .*
*... Positionen selektiert wurden ....................................*
*            MOVE  text-110 TO fline+50(27).
            CONCATENATE space text-110 INTO fline(77) SEPARATED BY fline(50).
            WRITE icon_red_light TO icon_field.
          ELSE.
            WRITE icon_red_light TO icon_field.
*            MOVE  text-108 TO fline+50(27).
            CONCATENATE space text-108 INTO fline(77) SEPARATED BY fline(50).
          ENDIF.
        ELSE.
*          MOVE  text-109 TO fline+50(27).
          CONCATENATE space text-109 INTO fline(77) SEPARATED BY fline(50).
          WRITE icon_yellow_light TO icon_field.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    "BAN_ZUORD
