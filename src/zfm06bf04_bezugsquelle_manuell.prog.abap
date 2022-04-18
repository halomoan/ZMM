*eject
*---------------------------------------------------------------------*
*       Bezugsquelle manuell zuordnen                                 *
*---------------------------------------------------------------------*
FORM bezugsquelle_manuell.

  DATA: s_eban-konnr LIKE eban-konnr,                       "161369
        s_eban-ktpnr LIKE eban-ktpnr,                       "161369
        s_eban-flief LIKE eban-flief,                       "161369
        s_eban-infnr LIKE eban-infnr,                       "161369
        s_eban-reswk LIKE eban-reswk,                       "161369
        s_eban-beswk LIKE eban-beswk, " CCP
        s_eban-ekorg LIKE eban-ekorg,                       "161369
        s_eban-matkl LIKE eban-matkl,                       "161369
        s_eban-matnr LIKE eban-matnr.                       "161369

  CLEAR: lfa1, t024e.

* Sichern der Eingaben von Dynpro 0104 und anschließendes Rücksichern
* ansonsten werden die Eingabedaten mit den Werten in den entsprechenden
* BAN-Feldern überschrieben                                 "161369
  MOVE eban-konnr TO s_eban-konnr.                          "161369
  MOVE eban-ktpnr TO s_eban-ktpnr.                          "161369
  MOVE eban-flief TO s_eban-flief.                          "161369
  MOVE eban-infnr TO s_eban-infnr.                          "161369
  MOVE eban-ekorg TO s_eban-ekorg.                          "161369
  MOVE eban-reswk TO s_eban-reswk.                          "161369
  MOVE eban-matkl TO s_eban-matkl.                          "161369
  MOVE eban-matnr TO s_eban-matnr.                          "161369
  MOVE eban-beswk TO s_eban-beswk. " CCP

  MOVE-CORRESPONDING ban TO eban.

* die Dynprofelder (EBAN-Felder) werden nur unter bestimmten
* Voraussetzungen mit den Werten des vorherigen Durchlaufs gefüllt
  IF ( s_eban-matnr EQ ban-matnr AND ban-matnr NE space ) OR
     ( s_eban-matkl EQ ban-matkl AND ban-matkl NE space
                                 AND ban-matnr EQ space
                                 AND s_eban-matnr EQ space ).
    MOVE s_eban-konnr TO eban-konnr.                        "161369
    MOVE s_eban-ktpnr TO eban-ktpnr.                        "161369
    MOVE s_eban-flief TO eban-flief.                        "161369
    MOVE s_eban-infnr TO eban-infnr.                        "161369
    MOVE s_eban-ekorg TO eban-ekorg.                        "161369
    MOVE s_eban-beswk TO eban-beswk.    " CCP
    IF ban-pstyp EQ pstyp-umlg.                             "161369
      MOVE s_eban-reswk TO eban-reswk.                      "161369
    ENDIF.                                                  "161369
  ENDIF.

  IF eban-flief NE space.
* ALRK021854 begin insert
    CALL FUNCTION 'WY_LFA1_GET_NAME'
      EXPORTING
        pi_lifnr         = eban-flief
      IMPORTING
        po_name1         = lfa1-name1
      EXCEPTIONS
        no_records_found = 1
        OTHERS           = 2.
* ALRK021854 end insert - begin delete
*   call function 'ME_GET_SUPPLIER'
*        exporting
*             supplier = eban-flief
*        importing
*             name = lfa1-name1.
* ALRK021854 end delete
  ENDIF.
  IF eban-ekorg NE space.
    SELECT SINGLE * FROM t024e WHERE ekorg EQ eban-ekorg.
  ENDIF.
  CALL SCREEN 104 STARTING AT 12 10
                  ENDING AT   65 17.

ENDFORM.                    "BEZUGSQUELLE_MANUELL
