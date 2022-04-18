*eject
*----------------------------------------------------------------------*
* Listtyp suchen in Sicherungsfelder und aktuellen Listtyp merken      *
*----------------------------------------------------------------------*
FORM LISTE_MERKEN USING LIM_LISTE.

*- Listtyp schon mal aufgerufen -> zurück -----------------------------*
  IF S0LISTE EQ LIM_LISTE OR
     S1LISTE EQ LIM_LISTE.
*- Listtyp in Grundliste ----------------------------------------------*
    IF S0LISTE EQ LIM_LISTE.
      COM-SRTKZ = S0SRTKZ.
      CLEAR DET.
      CLEAR: S0LISTE,
             S0SRTKZ,
             S1LISTE,
             S1SRTKZ,
             S1DET.
*- Listtyp in zweiter Liststufe ---------------------------------------*
    ELSE.
      COM-SRTKZ = S1SRTKZ.
      DET = S1DET.
      CLEAR: S1LISTE,
             S1SRTKZ,
             S1DET.
    ENDIF.
*- Listtyp neu -> alten Listtyp merken --------------------------------*
  ELSE.
*- Grundliste ---------------------------------------------------------*
    IF S0LISTE EQ SPACE.
      S0LISTE = LISTE.
      S0SRTKZ = COM-SRTKZ.
*- 2. Liststufe -------------------------------------------------------*
    ELSE.
      S1LISTE = LISTE.
      S1SRTKZ = COM-SRTKZ.
      S1DET   = DET.
    ENDIF.
  ENDIF.
ENDFORM.
