*eject
*----------------------------------------------------------------------*
*        Übergabestruktur beim Auswählen füllen                        *
*----------------------------------------------------------------------*
FORM CUEB_FUELLEN.

  CLEAR CUEB.
  CUEB-BANFN = BAN-BANFN.
  CUEB-BNFPO = BAN-BNFPO.
  EXPORT CUEB TO MEMORY ID 'XYZ'.
  LEAVE.

ENDFORM.
