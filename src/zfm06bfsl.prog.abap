***INCLUDE FM06BFSL.

* Hinw. Datum    Rel. NN  Text
* 88504 25.11.97 4.0B KB: erledigte RV-Banfen

*----------------------------------------------------------------------*
*        Allgemeine Select-Options und Parameter                       *
*----------------------------------------------------------------------*
*INCLUDE FM06BCS1.
*INCLUDE FM06BCS2.
*
*  INCLUDE FM06BFSL_AENDANZ_PRUEFEN .  " AENDANZ_PRUEFEN
*
*  INCLUDE FM06BFSL_BAN_AUFBAUEN .  " BAN_AUFBAUEN
*
*
*  INCLUDE FM06BFSL_KONTIERUNG .  " KONTIERUNG
*
*  INCLUDE FM06BFSL_CHECK_PARA1 .  " CHECK_PARA1
*
*  INCLUDE FM06BFSL_CHECK_PARA2 .  " CHECK_PARA2
*  INCLUDE FM06BFSL_ANZAHL_POS_BAN .  " ANZAHL_POS_BAN
*  INCLUDE FM06BFSL_MATERIALNUMMER_SETZEN .  " MATERIALNUMMER_SETZEN
*  INCLUDE FM06BFSL_CHECK_PARA3 .  " CHECK_PARA3
*  INCLUDE FM06BFSL_BAN_ARCHIVE_DATE_SET .  " BAN_ARCHIVE_DATE_SET
INCLUDE zfm06bcs1.
INCLUDE zfm06bcs2.

INCLUDE zfm06bfsl_aendanz_pruefen .  " AENDANZ_PRUEFEN

INCLUDE zfm06bfsl_ban_aufbauen .  " BAN_AUFBAUEN


INCLUDE zfm06bfsl_kontierung .  " KONTIERUNG

INCLUDE zfm06bfsl_check_para1 .  " CHECK_PARA1

INCLUDE zfm06bfsl_check_para2 .  " CHECK_PARA2
INCLUDE zfm06bfsl_anzahl_pos_ban .  " ANZAHL_POS_BAN
INCLUDE zfm06bfsl_materialnummer_setze .  " MATERIALNUMMER_SETZEN
INCLUDE zfm06bfsl_check_para3 .  " CHECK_PARA3
INCLUDE zfm06bfsl_ban_archive_date_set .  " BAN_ARCHIVE_DATE_SET
