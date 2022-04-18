*eject
*----------------------------------------------------------------------*
*        Zurück                                                        *
*----------------------------------------------------------------------*
FORM UCOMM_ZURU.

*- Ausflug (Konsiliste): 1 Liststufe zurück ---------------------------*
  IF SY-PFKEY EQ 'KONS' OR
     SY-PFKEY EQ 'KONA'.
    IF T16LB-DYNPR EQ 0.
      SY-LSIND = 0.
      EXIT.
    ELSE.
      LEAVE.
    ENDIF.
  ENDIF.
*- Grundliste: Bearbeitung beenden ------------------------------------*
  IF S0LISTE EQ SPACE.
    PERFORM UCOMM_ENDE.
  ELSE.
*- 2. oder 3. Liste: Eine Liste zurück---------------------------------*
    SY-LSIND = 0.
    CLEAR ZUG.
*- Daten aus letzter Liststufe setzen ---------------------------------*
    IF S1LISTE NE SPACE.
      LISTE = S1LISTE.
      COM-SRTKZ = S1SRTKZ.
      DET = S1DET.
      CLEAR: S1LISTE,
             S1SRTKZ,
             S1DET.
    ELSE.
      LISTE = S0LISTE.
      COM-SRTKZ = S0SRTKZ.
      CLEAR DET.
      CLEAR: S0LISTE,
             S0SRTKZ.
    ENDIF.
*- Mehrfachzuordnung Anfrage entfernen --------------------------------*
    LOOP AT BAN WHERE UPDK2 EQ AMAN.
      DELETE BAN.
    ENDLOOP.

    IF LISTE EQ 'G'.
      SET PF-STATUS GPFKEY EXCLUDING EXCL.
      SET TITLEBAR  GFMKEY.
      PERFORM BAN_SORT.
      IF T16LB-DYNPR EQ 0.
        PERFORM BAN_ZEILEN.
        SCROLL LIST INDEX 1 TO FIRST PAGE LINE LI_STARO.
      ELSE.
        LEAVE.
      ENDIF.
    ELSE.
      SET PF-STATUS ZPFKEY.
      SET TITLEBAR  ZFMKEY.
      PERFORM ZUG_ZEILEN.
    ENDIF.
  ENDIF.

ENDFORM.
