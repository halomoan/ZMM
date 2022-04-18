************************************************************************
*        Listanzeige Bestellanforderungen                              *
************************************************************************
* FRICE#     : MMGBE_013
* Title      : PR Source Determination
* Author     : Ellen H. Lagmay
* Date       : 11.10.2010
* Specification Given By: Audrey Chui
* Purpose	 : For PR - To assign the source automatically based on the
*            lowest price deteremined when there are multiple sources.
*---------------------------------------------------------------------*
* Modification Log
* Date         Author   Num Description
*
* -----------  -------  ---  -----------------------------------------*
*----------------------------------------------------------------------*
*-- Datenteil ---------------------------------------------------------*
INCLUDE ZFM06BTOP.
*INCLUDE FM06BTOP.

*-- Routinen für die Listaufbereitung ---------------------------------*
INCLUDE ZFM06BF01.
*INCLUDE FM06BF01.

*-- User-Command-Routinen ---------------------------------------------*
INCLUDE ZFM06BF02.
*INCLUDE FM06BF02.

*-- Routinen für interaktive Bearbeitung der Grundliste ---------------*
INCLUDE ZFM06BF03.
*INCLUDE FM06BF03.

*-- Allgemeine Unterroutinen ------------------------------------------*
INCLUDE ZFM06BF04.
*INCLUDE FM06BF04.

*-- Routinen für interaktive Bearbeitung der Zuorddnungsliste ---------*
INCLUDE ZFM06BF05.
*INCLUDE FM06BF05.

*-- Unterroutinen zur Tabelle ALF - Mehrere Lieferanten zur Anfragebear.
INCLUDE ZFM06BFAL.
*INCLUDE FM06BFAL.
*-- Unterroutinen zur Listaufbereitung der Grundliste -----------------*
INCLUDE ZFM06BFLI.
*INCLUDE FM06BFLI.
INCLUDE ZFM06BFLZ.
*INCLUDE FM06BFLZ.             "Kundenspezifische Routinen
*-- Unterroutinen zur zusätzlichen Datenbeschaffung -------------------*
INCLUDE ZFM06BFDA.
*INCLUDE FM06BFDA.
INCLUDE ZFM06BFDZ.
*INCLUDE FM06BFDZ.             "Kundenspezifische Routinen
*-- Unterroutinen aus Selektionsreports -------------------------------*
INCLUDE ZFM06BFSL.
*INCLUDE FM06BFSL.

*ENHANCEMENT-POINT SAPFM06B_01 SPOTS ES_SAPFM06B STATIC.
INCLUDE ZFM06B_AUTHORITY_BESWKF01.
*INCLUDE FM06B_AUTHORITY_BESWKF01.

INCLUDE ZFM06BFPH.
*INCLUDE FM06BFPH.
