*eject
*----------------------------------------------------------------------*
*        Listausgabe starten                                           *
*----------------------------------------------------------------------*
FORM start.

*- Daten aus Selektionsreport holen -----------------------------------*
  IMPORT gs_banf FROM MEMORY ID 'GSFRG'.
  IMPORT cueb FROM MEMORY ID 'XYZ'.
  IMPORT ban com FROM MEMORY ID 'ZYX'. "#EC CI_FLDEXT_OK[2215424] P30K909996
  gpfkey = com-gpfkey.
  gfmkey = com-gfmkey.
  zpfkey = com-zpfkey.
  zfmkey = com-zfmkey.

*- Message-Steuerung initialisieren -----------------------------------*
  PERFORM init_enaco(sapfmmex).

*- Funktionsberechtigungen initialisieren -----------------------------*
  PERFORM init_efube.

*- Listumfang ermitteln -----------------------------------------------*
  PERFORM xt16ll_aufbauen.

*- Zusätzliche Daten lesen---------------------------------------------*
  PERFORM ban_daten_pre.

*- Gelesenen Stand der Banfs sichern ----------------------------------*
  IF gpfkey EQ 'BEAR' OR
     gpfkey EQ 'ZUOR'.
    PERFORM oba_aufbauen.
  ENDIF.

*- Liste beginnt mit Zuordnungsliste ----------------------------------*
  CLEAR t16lh.
  SELECT SINGLE * FROM t16lh WHERE tcode EQ sy-tcode.

  IF t16lh-xzuor NE space.
*... Neue Konsiabwicklung zu 4.0 .....................................*
    IF tcurm IS INITIAL.
      SELECT SINGLE * FROM tcurm.
    ENDIF.
    IF NOT tcurm-konsi IS INITIAL.
*... Konsiabwicklung über Infosatz ...................................*
      SET PF-STATUS zpfkey EXCLUDING 'LKON'.
    ELSE.
      SET PF-STATUS zpfkey.
    ENDIF.
    SET TITLEBAR  zfmkey.
    liste = 'Z'.
    PERFORM zug_zeilen.
*- Liste beginnt mit Grundliste ---------------------------------------*
  ELSE.
*... Neue Konsiabwicklung zu 4.0 .....................................*
    IF tcurm IS INITIAL.
      SELECT SINGLE * FROM tcurm.
    ENDIF.
    IF NOT tcurm-konsi IS INITIAL.
*... Konsiabwicklung über Infosatz ...................................*
      excl-funktion = 'LKON'.
      COLLECT excl.
    ENDIF.
    SET PF-STATUS gpfkey EXCLUDING excl.
    SET TITLEBAR  gfmkey.
    liste = 'G'.
    PERFORM ban_sort.
*- Grundliste als Liste -----------------------------------------------*
    IF t16lb-dynpr EQ 0.
      PERFORM ban_zeilen.
*- Grundliste als SSTEP-Loop ------------------------------------------*
    ELSE.
      PERFORM ban_dynp_call.
    ENDIF.
  ENDIF.

ENDFORM.
