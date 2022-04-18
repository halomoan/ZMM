*eject
*----------------------------------------------------------------------*
*  Funktionsberechtigung
*----------------------------------------------------------------------*
FORM INIT_EFUBE.

  CLEAR T160D.
  T160D-EPRSA = 'X'.
  T160D-EPRSZ = 'X'.
  T160D-EOHNM = 'X'.
  T160D-ERFBL = 'X'.
  T160D-ERFAN = 'X'.
  T160D-ERFAG = 'X'.
  T160D-ERFKA = 'X'.
  T160D-ERFKM = 'X'.
  T160D-ERFKW = 'X'.
  T160D-ERFBA = 'X'.
  T160D-ERFB1 = 'X'.
  T160D-ERFB2 = 'X'.
  T160D-ERFIN = 'X'.
  T160D-EMANU = 'X'.
  T160D-EBZKA = 'X'.
  T160D-EBZKM = 'X'.
  T160D-EBZKW = 'X'.
  T160D-EBZIN = 'X'.
  T160D-EBZOM = 'X'.
  T160D-ERES1 = 'X'.
  T160D-ERES2 = 'X'.
  T160D-ERES3 = 'X'.
  GET PARAMETER ID 'EFB' FIELD EFUBE.
  SELECT SINGLE * FROM T160D WHERE EFUBU = EFUBE.

*- Steuerung Vorschlagswerte -----------------------------------------*
  GET PARAMETER ID 'EVO' FIELD EVOPA.
  IF EVOPA NE T160V-EVOPA.
    SELECT SINGLE * FROM T160V WHERE EVOPA = EVOPA.
  ENDIF.

ENDFORM.
